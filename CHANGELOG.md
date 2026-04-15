## 2.1.0

### New features
- **`DEVELOPMENT_TEAM` is now written to the `PBXNativeTarget "Runner"` build configurations** (previously only set on the `PBXProject` level). This removes the "Signing for 'Runner' requires a development team" error on first `flutter build ipa` for a fresh flavor. The team value is taken from `team_id` in `flavor_tools.yaml` or the `-t` CLI flag.
- **Optional `pod install` step** — after creating a flavor, `flavor_tools` can automatically run `pod install` in `ios/` so CocoaPods generates flavor-specific `Pods-Runner.{debug,profile,release}-<flavor>.xcconfig` files immediately (previously they appeared only on the next `flutter build`). Enable via:
  - YAML: `pod_install: true` inside a flavor block
  - CLI: `--podInstall` flag for `create` and `create-all`

## 2.0.3

- Added validation for Gradle file existence before Android flavor creation
- Added validation for invalid YAML flavor entries in `create-all` command

## 2.0.2

- Fixed dart analyze warnings
- Updated dependencies
- Updated README.md documentation

## 2.0.0

### New features
- **`create-all` command** — batch flavor creation from YAML config file (`flavor_tools.yaml`)
- **`update` command** — update package name and display name for existing flavors (iOS xcconfig + Android Gradle)
- **Smart diff detection** — `create-all` automatically detects config changes and updates only modified flavors
- **Kotlin DSL support** — auto-detection and support for `build.gradle.kts` alongside Groovy `build.gradle`
- **Duplicate check** — skips flavor creation if it already exists in the project

### Improvements
- **XCBuildConfiguration modernized** to Xcode 16 standards:
  - Removed `ENABLE_BITCODE`
  - `CODE_SIGN_IDENTITY`: `iPhone Developer` → `Apple Development`
  - `CLANG_CXX_LANGUAGE_STANDARD`: `gnu++0x` → `gnu++20`
  - `GCC_C_LANGUAGE_STANDARD`: `gnu99` → `gnu17`
  - `IPHONEOS_DEPLOYMENT_TARGET`: `12.0` → `13.0`
  - `SWIFT_VERSION`: `5.0` → `6.0`
- **Auto-detection of project settings** — reads `SWIFT_VERSION`, `IPHONEOS_DEPLOYMENT_TARGET`, `TARGETED_DEVICE_FAMILY`, `CLANG_CXX_LANGUAGE_STANDARD`, `GCC_C_LANGUAGE_STANDARD` from existing Xcode configurations instead of hardcoding
- **Scheme generation rewritten** with `xml` package — correct `BlueprintIdentifier` from PBXNativeTarget, scheme version `1.7`, `customLLDBInitFile` support
- **Removed unused Profile xcconfig** file references (Profile reuses Release xcconfig per Flutter standard)
- **Refactored `create_xc_flavor.dart`** — eliminated duplication across build types using loops and UUID maps
- **Error handling** — proper exit codes (`exit(1)` instead of `exit(404)`), descriptive context messages for all error points

## 1.0.6

- Updated XCBuildConfiguration.
