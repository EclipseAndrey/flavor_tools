<p align="center">
    <a href="https://pub.dev/packages/xcode_parser" align="center">
        <img src="https://github.com/EclipseAndrey/flavor_tools/blob/main/ft_logo.png?raw=true" width="4000px">
    </a>
</p>





<p align="center">
    <a href="https://github.com/EclipseAndrey/flavor_tools/issues/new" align="center">
        <img src="https://github.com/EclipseAndrey/xcode_parser/blob/main/wrong_button.png?raw=true" width="300px">
    </a>
</p>


# Flavor Tools


## Installation

Incorporate the package into your Dart or Flutter project by adding it as a dependency in your `pubspec.yaml` file:
```yaml
dependencies:
  flavor_tools: ^1.0.6
```
or
```shell
$ dart pub add flavor_tools
```

## Get started

```shell
$ dart pub run flavor_tools create -p com.example.app -f flavorName -d "App display name"
```
#### Additional

- `-t [TeamId]` - include TeamId to flavor.
- `--iconsLauncher=true` - if using package `flutter_launcher_icons` for flavors.
- `-x [path/to/Runner.xcodeproj/project.pbxproj]`



## Run flavor

```shell
$ flutter run --flavor=flavorName
```