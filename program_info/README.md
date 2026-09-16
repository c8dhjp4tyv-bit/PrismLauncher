# Timeless Launcher Program Info

This is Timeless Launcher's program info which contains information about:

- Application name and logo (and branding in general)
- Various URLs and API endpoints
- Desktop file
- MIME type registration and platform-specific application metadata

The values in this directory are configured by `program_info/CMakeLists.txt`
and generated into the build directory during configuration. When changing
the icon, run `genicons.sh` from this directory to regenerate the PNG, ICO,
ICNS and runtime theme assets. The script uses native macOS tools when they
are available and includes a portable PNG-backed ICNS fallback for other
platforms.

Timeless Launcher icon artwork is available under CC BY 4.0. Retained
upstream artwork and its CC BY-SA 4.0 terms are documented separately in
`LICENSE` and `../THIRD_PARTY_NOTICES.md`.
