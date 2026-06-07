# (WIP) Building Transmission for Mac OS X 10.6

The repository provides a `macos-10.6` CMake preset for Snow Leopard backporting:

```bash
cmake --preset macos-10.6
cmake --build --preset macos-10.6
```

The preset uses `cmake/MacOSLegacyToolchain.cmake` with a 10.6 deployment target and SDK.
