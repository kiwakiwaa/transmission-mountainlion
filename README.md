<p align="center">
  <img src="docs/images/mountain-lion-icon.png" alt="OS X Mountain Lion" width="150">
</p>

<h1 align="center">Transmission for Mountain Lion</h1>

<p align="center">
  A maintained Mountain Lion build of the latest Transmission: quiet, fast, and still at home on OS X 10.8.
</p>

## What This Is

This fork keeps Transmission building and running on OS X 10.8 Mountain Lion while staying close to the current upstream project.

- Modern macOS builds should continue to follow upstream behavior.
- The Mountain Lion build uses the OS X 10.8 SDK and a dedicated CMake preset.
- Sparkle updates are disabled for 10.8 builds.

## Build For Mountain Lion

Install the OS X 10.8 SDK, CMake, Ninja, OpenSSL, curl, and a compiler capable of building the current source. Then use the dedicated preset:

```bash
cmake --preset macos-10.8
cmake --build --preset macos-10.8
```

The app bundle is written to:

```bash
build-10.8/macosx/Transmission.app
```

See [Building Transmission for OS X 10.8](docs/macOS-10.8.md) for dependency notes and override paths.

For modern builds, use the regular Transmission build documentation:

- [How to Build Transmission](docs/Building-Transmission.md)
- [Transmission documentation](docs/README.md)
- [Official Transmission site](https://transmissionbt.com/)

## Screenshots

| Main Window | Inspector |
| --- | --- |
| Placeholder: `docs/images/screenshot-main-window.png` | Placeholder: `docs/images/screenshot-inspector.png` |

| Preferences | Add Torrent |
| --- | --- |
| Placeholder: `docs/images/screenshot-preferences.png` | Placeholder: `docs/images/screenshot-add-torrent.png` |
