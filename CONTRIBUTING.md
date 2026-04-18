# Contributing to SwiftMac

This repository is straightforward on purpose. If you want to send a fix or add a feature, keep the change focused and make sure the generated project still matches the checked-in source tree.

## Local setup

```bash
git clone https://github.com/dharmanan/mcclean-macos.git
cd mcclean-macos
brew install xcodegen
xcodegen generate
open SwiftMac.xcodeproj
```

## Expectations

- Keep changes small and reviewable.
- Update `setup.sh` if you add files that should be recreated by the bootstrap flow.
- Update `project.yml` if a new target, source path, or build setting is introduced.
- Add or adjust tests when behavior changes.
- Avoid unrelated formatting-only churn.

## Code conventions

- Use Swift concurrency consistently.
- Keep mutable shared work in actors or well-scoped `@MainActor` view models.
- Prefer simple, explicit code over extra abstraction.

## License

By contributing, you agree that your changes are released under the MIT license.
