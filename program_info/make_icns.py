#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-only
# Copyright (C) 2026 Timeless Launcher Contributors

"""Build a PNG-backed ICNS file without requiring macOS iconutil."""

from pathlib import Path
import struct
import sys


RESOURCE_TYPES = (b"icp4", b"icp5", b"icp6", b"ic07", b"ic08", b"ic09", b"ic10")


def main() -> int:
    if len(sys.argv) != len(RESOURCE_TYPES) + 2:
        program = Path(sys.argv[0]).name
        print(f"usage: {program} OUTPUT {len(RESOURCE_TYPES)} PNG_FILES...", file=sys.stderr)
        return 2

    output = Path(sys.argv[1])
    chunks = []
    for resource_type, png_path in zip(RESOURCE_TYPES, sys.argv[2:]):
        data = Path(png_path).read_bytes()
        if not data.startswith(b"\x89PNG\r\n\x1a\n"):
            raise ValueError(f"{png_path} is not a PNG file")
        chunks.append(resource_type + struct.pack(">I", len(data) + 8) + data)

    payload = b"".join(chunks)
    output.write_bytes(b"icns" + struct.pack(">I", len(payload) + 8) + payload)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
