# (WIP) Building Transmission for Mac OS X 10.6

The repository provides a `macos-10.6` CMake preset for Snow Leopard backporting:

```bash
cmake --preset macos-10.6
cmake --build --preset macos-10.6
```

The preset uses `cmake/MacOSLegacyToolchain.cmake` with a 10.6 deployment target and SDK.

## ARC notes

The main lesson from the Snow Leopard port: keep ARC enabled. Transmission's macOS code assumes ARC ownership semantics everywhere.

Snow's Xcode 4.2 clang knows that ARC apps targeting 10.6 need an ARC-lite (`libarclite_macosx.a`) archive, but my Xcode just... doesn't have the Mac archive. Only the iOS ones. Apple's Xcode 4.6.1 notes (not supported on 10.6, of course) confirm this:
> '4.6 had a Snow launch crash for ARC apps, and 4.6.1 fixed "Crash on launch on OS X v10.6 with apps using ARC built with Xcode 4.6" (13129783)'

Mike Ash's [ARC writeup](https://www.mikeash.com/pyblog/friday-qa-2011-09-30-automatic-reference-counting.html) explains why: ARC emits runtime helpers like `objc_retain`, `objc_release`, and autorelease pool calls instead of plain Objective-C messages. On 10.6, those symbols aren't in the system runtime, so the final link must pull in ARC-lite. With CMake compiling and linking separately, `-fobjc-arc` at compile time isn't enough. The Snow link also needs to force-load `libarclite_macosx.a` so the executable contains the fallback code before dyld sees it.

Weak references were the second trap. `-fobjc-weak` isn't available for 10.6 targets. The current Snow build keeps `weak`/`__weak` in the source and uses [PLWeakCompatibility](https://www.mikeash.com/pyblog/introducing-plweakcompatibility.html) with `-Xclang -fobjc-runtime-has-weak` to supply the weak runtime entry points.
