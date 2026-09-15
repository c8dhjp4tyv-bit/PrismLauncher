#!/usr/bin/env python3
"""Regenerates the hard link tarballs used by ArchiveReader_test.

A real filesystem cannot hold a hard link that points outside its own tree, so the
escaping fixture has to be written entry by entry rather than captured from disk.
Every field that would otherwise vary is pinned so the committed archives are
reproducible: rerunning this must leave the .tar files byte for byte identical.
"""

import io
import pathlib
import tarfile

FIXTURES = pathlib.Path(__file__).resolve().parent.parent / "tests/testdata/ArchiveReader"
PAYLOAD = b"timeless\n"
MTIME = 1745012340  # 2025-04-18 22:39:00 UTC


def info(name, typeflag, mode):
    entry = tarfile.TarInfo(name)
    entry.type = typeflag
    entry.mode = mode
    entry.mtime = MTIME
    entry.uid = entry.gid = 0
    entry.uname = entry.gname = "root"
    return entry


def write(path, link_target):
    with tarfile.open(path, "w", format=tarfile.GNU_FORMAT) as tar:
        tar.addfile(info("bin/", tarfile.DIRTYPE, 0o755))

        payload = info("bin/target", tarfile.REGTYPE, 0o644)
        payload.size = len(PAYLOAD)
        tar.addfile(payload, io.BytesIO(PAYLOAD))

        link = info("bin/link", tarfile.LNKTYPE, 0o644)
        link.linkname = link_target
        tar.addfile(link)


# The link target is relative, the way a portable tarball names its own files.
write(FIXTURES / "hard-link.tar", "bin/target")
# Escapes the extraction root; writeFile() must refuse this one.
write(FIXTURES / "escaping-hard-link.tar", "../../../../../../etc/passwd")
