# SwiftMac Feature Checklist

This checklist is for manual validation of the features described in the README.

## Smart Scan

- Launch the app and start a smart scan from the dashboard.
- Confirm progress updates as categories finish.
- Confirm the result list contains multiple categories and a non-zero total when junk exists.
- Confirm the same action also works from the menu bar quick scan entry.

## Cleanup Categories

- Create sample junk in cache-like folders and confirm System Junk detects them.
- Create sample files in user cache locations and confirm User Cache detects them.
- Confirm Xcode-derived data or archives appear under Xcode cleanup results when present.
- Confirm Homebrew cache files appear when Homebrew caches exist.
- Place a sample file in Mail Downloads and confirm Mail Attachments finds it.
- Put a sample file in Trash and confirm Trash finds it.
- Place a large file above threshold and confirm Large Files lists it.
- Confirm Purgeable Space returns a category even when no purgeable files are removable.

## App Uninstaller

- Install a test app with a unique bundle identifier.
- Create matching files under Application Support, Preferences, Caches, Containers, and Saved Application State.
- Confirm the app list shows the app and the discovered leftover files.

## Duplicate Finder

- Create two files with identical content and different modification times.
- Run duplicate scan and confirm only the newer duplicate is marked for cleanup.

## Privacy Cleanup

- Create sample browser history or cookie files in supported Safari or Chrome paths.
- Confirm Privacy cleanup lists only the files that exist.

## Disk Map

- Open Disk Map and confirm major directories render with proportional usage values.
- Verify totals update after large test files are added or removed.

## Login Items

- Create a sample LaunchAgent plist in the user LaunchAgents folder.
- Confirm the Login Items screen lists it.

## History

- Run at least one scan and one cleanup.
- Confirm entries persist and appear in the History screen after reopening the app.

## Menu Bar Utility

- Launch the app and confirm the menu bar extra appears.
- Trigger quick scan and open the main app window from the menu bar.

## Scheduled Cleaning

- Enable scheduled cleaning in settings.
- Shorten the interval in a debug session if needed.
- Confirm a scheduled run performs a scan and posts a completion notification.

## Build And Test

- Run `./setup.sh` on macOS and confirm `SwiftMac.xcodeproj` is generated.
- Run `./smoke-test-macos.sh` and confirm build-for-testing and test-without-building both pass.