<p align="center">
    <a href="https://pub.dev/packages/flavor_tools" align="center">
        <img src="https://github.com/EclipseAndrey/flavor_tools/blob/main/ft_logo.png?raw=true" width="4000px">
    </a>
</p>

<p align="center">
    <a href="https://github.com/EclipseAndrey/flavor_tools/issues/new" align="center">
        <img src="https://github.com/EclipseAndrey/xcode_parser/blob/main/wrong_button.png?raw=true" width="300px">
    </a>
</p>

# Flavor Tools

A CLI utility for quickly creating and managing flavors in Flutter projects. Automatically configures iOS (Xcode project, xcconfig, schemes) and Android (Gradle, AndroidManifest).

## Features

- Create a flavor for iOS and Android with a single command
- Batch creation from a YAML config (`create-all`)
- Update existing flavors (`update`)
- Configure target device family for iOS
- Support for Kotlin DSL (`build.gradle.kts`) and Groovy (`build.gradle`)
- Auto-detection of settings from an existing Xcode project (SWIFT_VERSION, IPHONEOS_DEPLOYMENT_TARGET, etc.)
- Duplicate checking before creation
- `flutter_launcher_icons` support

## Installation

```yaml
dependencies:
  flavor_tools: ^2.0.1
```

or

```shell
dart pub add flavor_tools
```

### Global installation (optional)

```shell
dart compile exe bin/flavor_tools.dart -o flavor_tools
mv flavor_tools /usr/local/bin/
```

## Commands

### `create` — create a single flavor

```shell
dart run flavor_tools create \
  -p com.example.app \
  -f dev \
  -d "My App Dev"
```

| Flag | Short | Description |
|------|-------|-------------|
| `--packageName` | `-p` | Package name for iOS and Android |
| `--packageNameIos` | `-i` | Package name for iOS only |
| `--packageNameAndroid` | `-a` | Package name for Android only |
| `--flavorName` | `-f` | Flavor name |
| `--displayName` | `-d` | Display name of the application |
| `--teamId` | `-t` | Apple Team ID (default: empty) |
| `--pathXcProject` | `-x` | Path to project.pbxproj |
| `--iconsLauncher` | | `true` if using `flutter_launcher_icons` |

### `create-all` — batch creation from YAML

```shell
dart run flavor_tools create-all -c flavor_tools.yaml
```

`flavor_tools.yaml` format:

```yaml
flavors:
  dev:
    package_name: com.example.app.dev
    display_name: "My App Dev"
  staging:
    package_name: com.example.app.staging
    display_name: "My App Staging"
  prod:
    package_name: com.example.app
    display_name: "My App"
    team_id: "ABC123"
    icons_launcher: true
```

Each flavor supports the following fields:

| Field | Description |
|-------|-------------|
| `package_name` | Shared package name |
| `package_name_ios` | Package name for iOS only |
| `package_name_android` | Package name for Android only |
| `display_name` | Display name |
| `dimension` | Flavor dimension (default: `default`) |
| `team_id` | Apple Team ID |
| `icons_launcher` | flutter_launcher_icons support |

When running `create-all` again, it automatically detects changes and updates only those flavors whose config has changed.

### `update` — update an existing flavor

```shell
dart run flavor_tools update \
  -f dev \
  -p com.example.newpackage \
  -d "New Display Name"
```

| Flag | Description |
|------|-------------|
| `--flavorName` `-f` | Flavor name (required) |
| `--packageName` `-p` | New package name for iOS and Android |
| `--packageNameIos` | New package name for iOS only |
| `--packageNameAndroid` | New package name for Android only |
| `--displayName` `-d` | New display name for iOS and Android |
| `--displayNameIos` | New display name for iOS only |
| `--displayNameAndroid` | New display name for Android only |

### `set-target-device-family` — target iOS devices

```shell
dart run flavor_tools set-target-device-family -d "1,2"
```

- `1` — iPhone
- `2` — iPad
- `1,2` — iPhone and iPad

## Running a flavor

```shell
flutter run --flavor=dev
```

## What gets generated

**iOS:**
- `XCBuildConfiguration` for Debug, Release, Profile
- xcconfig files (`ios/Flutter/Debug-{flavor}.xcconfig`, `Release-{flavor}.xcconfig`)
- Xcode scheme (`ios/Runner.xcodeproj/xcshareddata/xcschemes/{flavor}.xcscheme`)
- `Info.plist` and `Runner.entitlements` updates

**Android:**
- `flavorDimensions` and `productFlavors` in `build.gradle` / `build.gradle.kts`
- `resValue` for `app_name` in each flavor
- `AndroidManifest.xml` updates
