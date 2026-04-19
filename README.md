# SwiftMac

SwiftMac is a native macOS cleaning utility I built with SwiftUI, SwiftData, and Swift concurrency. The repository contains the app source, a lightweight bootstrap script for validating the checkout and generating the Xcode project, and the XcodeGen manifest used to produce the Xcode project on macOS.

## What it does

- Smart scan across the main cleanup categories
- System junk, user cache, Xcode cache, Homebrew cache, mail downloads, trash, large files, and purgeable-space scanning
- App uninstaller with leftover file discovery
- Duplicate file finder
- Privacy cleanup for common browser and recent-item data
- Disk map view
- Login items view
- Scan history with SwiftData
- Menu bar utility and scheduled cleaning support

## Build

SwiftMac is set up to build from source on macOS.

```bash
git clone https://github.com/dharmanan/mcclean-macos.git
cd mcclean-macos
brew install xcodegen
xcodegen generate
open SwiftMac.xcodeproj
```

Single-command build and test smoke test on macOS:

```bash
./smoke-test-macos.sh
```

The script regenerates the Xcode project, runs a clean build-for-testing pass, then runs test-without-building. Logs are written under `build/smoke-logs/`.

Command-line build:

```bash
xcodebuild -project SwiftMac.xcodeproj -scheme SwiftMac -configuration Debug build
```

## Repository layout

```text
SwiftMac/          Application source
SwiftMacHelper/    Helper target
SwiftMacTests/     Unit tests
SwiftMacUITests/   UI tests
project.yml        XcodeGen manifest
setup.sh           Bootstrap script
smoke-test-macos.sh macOS build and test smoke test
```

## Notes

- `setup.sh` validates the checkout and can generate the Xcode project in a macOS environment.
- `project.yml` is the source of truth for the Xcode target layout.
- Bundle identifiers are set to `com.dharmanan.*` in `project.yml` and `SwiftMac/Resources/Info.plist`; if you fork, update both and also update `SwiftMacHelper/main.swift` trusted client allowlist.
- `FEATURE_CHECKLIST.md` contains a manual verification list for the README feature set.
- In this Linux workspace the app project cannot be generated because `xcodegen` and Xcode are not available. On macOS, `xcodegen generate` is enough.
- `ExportOptions.plist` still requires a real Apple team ID before archive/export.

## Contributing

If you want to contribute, the basic workflow is documented in [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT. See [LICENSE](LICENSE).
