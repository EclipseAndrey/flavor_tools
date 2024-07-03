<p align="center">
    <a href="https://pub.dev/packages/xcode_parser" align="center">
        <img src="https://github.com/EclipseAndrey/flaor_tools/blob/main/ft_logo.png?raw=true" width="4000px">
    </a>
</p>

[//]: # (<p align="center">)

[//]: # (  <a href="https://codecov.io/gh/EclipseAndrey/xcode_parser"><img src="https://codecov.io/gh/EclipseAndrey/xcode_parser/branch/main/graph/badge.svg" alt="codecov"></a>)

[//]: # (  <a href="https://github.com/EclipseAndrey/xcode_parser/actions"><img src="https://github.com/EclipseAndrey/xcode_parser/actions/workflows/dart.yml/badge.svg" alt="xcode_parser"></a>)

[//]: # (  <a href="https://github.com/EclipseAndrey/xcode_parser/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License: MIT"></a>)

[//]: # (</p>)



<p align="center">
    <a href="https://github.com/EclipseAndrey/xcode_parser/issues/new" align="center">
        <img src="https://github.com/EclipseAndrey/xcode_parser/blob/main/wrong_button.png?raw=true" width="300px">
    </a>
</p>


# Xcode Parser

Xcode Parser is a package for working with Xcode project files (`.pbxproj`).
This package allows you to read, modify, and save changes in `.pbxproj`
files, which is especially useful for automating iOS development tasks.
## Features

- Reading and analyzing the contents of .pbxproj files.
- Modifying project settings and configurations.
- Saving changes to .pbxproj files.


| Dart                                                                                    | example.pbxproj                                                                       |
|-----------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------|
| ![before](https://github.com/EclipseAndrey/xcode_parser/blob/main/sc_dart.png?raw=true) | ![before](https://github.com/EclipseAndrey/xcode_parser/blob/main/sc_xc.png?raw=true) |

## Installation

Incorporate the package into your Dart or Flutter project by adding it as a dependency in your `pubspec.yaml` file:
```yaml
dependencies:
  xcode_parser: ^1.1.1
```
or
```shell
dart pub add xcode_parser
```

# Index
- [Installation](#installation)
- [Index](#index)
- [Objects and examples](#objects)
- - [Pbxproj](#pbxproj)
- - [SectionPbx](#sectionpbx)
- - [MapPbx](#MapPbx)
- - [MapEntryPbx](#MapEntryPbx)
- - [VarPbx](#VarPbx)
- - [ElementOfListPbx](#ElementOfListPbx)
- - [ListPbx](#ListPbx)



## Objects

### Pbxproj


- Read and analyze project data.
- Make changes to the project configuration.
- Save modifications back to the .pbxproj file, ensuring the project is updated according to the changes made.
#### Methods

##### Note:
```text
`open` may take a few seconds, 
if your program needs to continue working 
during parsing, it is recommended to use 
isolates to prevent blocking the main thread.
```

- `static Future<Pbxproj> open(String path)` - Opens and analyzes the .pbxproj file at the specified path. Parameter path - path to the .pbxproj file. Returns: Future<Pbxproj> — an asynchronous result that contains an instance of Pbxproj after reading and analyzing the file.
- `Future<void> save()` - Saves the current state of the Pbxproj object back to the .pbxproj file.
- `String generateUuid()` - Generates a unique identifier (UUID), which can be used for new project components.
- `void add(NamedComponent component)` - Adds a new component to the project.
- `void remove(String uuid)` - Removes a component from the project by its UUID.
- `void replaceOrAdd(NamedComponent component)` - Replaces an existing component in the project or adds a new one if a component with such UUID is not found.
- `NamedComponent? operator [](String key)` - Allows access to a component by its UUID.

#### Example

```dart
void main() async {
  // Load the project
  var project = await Pbxproj.open('path/to/Runner.xcodeproj/project.pbxproj');

  // Add a new build configuration
  var uuid = project.generateUuid();
  var config = MapPbx(
    uuid: uuid,
    children: [
      MapEntryPbx('isa', VarPbx('XCBuildConfiguration')),
      MapEntryPbx('name', VarPbx('"CustomDebug"')),
      MapPbx(
        uuid: 'buildSettings',
        children: [
          MapEntryPbx('SWIFT_VERSION', VarPbx('5.0')),
          MapEntryPbx('IPHONEOS_DEPLOYMENT_TARGET', VarPbx('12.0')),
        ],
      ),
    ],
  );
  project.add(config);

  // Save changes
  await project.save();
}
```

### SectionPbx

`SectionPbx` is a specialized component within the xcode_parser
library that manages sections in Xcode project files (`*.pbxproj`).
Sections in such files usually contain groups of related elements, such
as source files, build configurations, resources, etc.

#### Methods

- `void add(NamedComponent component)` - Adds a new component to the section.
- `void remove(String uuid) - Removes` a component from the section by its UUID.
- `NamedComponent? find(String uuid)` - Searches for a component in the section by its UUID.
- `replaceOrAdd(NamedComponent component)` - Replaces an existing component in the section or adds a new one if a component with such UUID is not found.
- `find<T extends NamedComponent>(String key)` - Searches for a component in the section by its UUID and returns it if found. Returns null if the component is not found.
- `findComment<T extends NamedComponent>(String comment)` - Searches for a component by comment. This is useful if components have been marked with comments for further identification.
#### Example

```dart
void main() {
  // Create a section for build settings
  var buildConfigs = SectionPbx(name: 'XCBuildConfiguration');

  // Add a build setting for debug mode
  buildConfigs.add(MapPbx(
    uuid: 'debugConfig',
    children: [
      MapEntryPbx('name', VarPbx('Debug')),
      MapEntryPbx('buildSettings', VarPbx('{SETTINGS}')),
    ],
  ));

  // Output information about the section
  print(buildConfigs);
}
```

### MapPbx

`MapPbx` is a component of the `xcode_parser` library designed to
manage mappings in Xcode project files (`*.pbxproj`).

#### Methods

- `void add(NamedComponent component)` - Adds a new component to the mapping.
- `void remove(String uuid)` - Removes a component from the mapping by its UUID.
- `NamedComponent? find(String uuid)` - Searches for a component in the mapping by its UUID and returns it if found. Returns null if the component is not found.
- `replaceOrAdd(NamedComponent component)` - Replaces an existing component in the mapping or adds a new one if a component with such UUID is not found.
- `find<T extends NamedComponent>(String key)` - Searches for a component in the mapping by its UUID and returns it if found. Returns null if the component is not found.
- `findComment<T extends NamedComponent>(String comment)` - Searches for a component by comment. This is useful if components have been marked with comments for further identification.

#### Example

```dart
void main() {
  // Create a MapPbx object for build settings
  var buildSettings = MapPbx(
      uuid: 'buildSettings',
      children: [
        MapEntryPbx('SWIFT_VERSION', VarPbx('5.0')),
        MapEntryPbx('IPHONEOS_DEPLOYMENT_TARGET', VarPbx('12.0')),
      ],
      comment: 'Main build settings'
  );

  // Add an additional configuration
  buildSettings.add(MapEntryPbx(
      'GCC_OPTIMIZATION_LEVEL',
      VarPbx('s')
  ));

  // Output information about the mapping
  print(buildSettings);
}
```

### MapEntryPbx

`MapEntryPbx` is a component of the `xcode_parser` library
designed to represent individual entries within the mappings of Xcode
project files (`*.pbxproj`). This component is used to store key-value pairs,
where each key is represented by a UUID and the value can be any component
derived from PbxprojComponent.
#### Methods

- `String toString({int indentLevel = 0, bool removeN = false})` - Converts the MapEntryPbx object to a string representation, which can be used for output or writing to a file. The indentLevel parameter controls the indentation level for better readability, and removeN determines whether to add line breaks.
- `MapEntryPbx copyWith({String? uuid, T? value, String? comment})` - Creates a copy of the MapEntryPbx object with the ability to replace its components. This is useful for modifying existing entries when only part of the data needs to be changed.
#### Example

```dart
void main() {
  // Create a MapEntryPbx object for a build setting
  var swiftVersion = MapEntryPbx(
      'SWIFT_VERSION',
      VarPbx('5.0'),
      comment: 'Swift version for the build configuration'
  );

  // Output information about the entry
  print(swiftVersion);

  // Create a copy with a changed value
  var updatedSwiftVersion = swiftVersion.copyWith(
      value: VarPbx('5.2'),
      comment: 'Updated Swift version'
  );

  // Output updated information
  print(updatedSwiftVersion);
}
```
### VarPbx
`VarPbx` is a component of the `xcode_parser` library used
to represent parameter values in Xcode project files (`*.pbxproj`).
This component is designed to store simple data such as strings,
numbers, or boolean values that are part of the Xcode project configuration.
#### Methods

- `String toString({int indentLevel = 0, bool removeN = false})` - Converts the VarPbx object to a string representation. This method facilitates integrating the VarPbx value into .pbxproj files in the appropriate format.
#### Example

```dart
void main() {
  // Create a VarPbx object to store the Swift version
  var swiftVersion = VarPbx('5.0');

  // Output the Swift version value
  print('Swift Version: ${swiftVersion}');

  // Use VarPbx in a MapEntryPbx for project configuration
  var buildSetting = MapEntryPbx(
      'SWIFT_VERSION',
      swiftVersion,
      comment: 'Specify the Swift version used for the build'
  );

  // Output the full build setting entry
  print(buildSetting);
}
```

### ElementOfListPbx

`ElementOfListPbx` is a component of the `xcode_parser` library
intended to represent elements in a list used in Xcode project files (`*.pbxproj`).
This component is typically used to represent values in lists of parameters,
such as a list of source files, resources, and other group settings.


#### Methods

- `String toString({int indentLevel = 0, bool removeN = false})` - Converts the ElementOfListPbx object to a string representation, considering the indentation level and the need to include line breaks. The method is convenient for forming the correct format for recording elements in a .pbxproj file.
- `ElementOfListPbx copyWith({String? value, String? comment})` - Creates a copy of the current list element with the possibility of changing its value or comment. This is useful for modifying existing elements when needed.
#### Example

```dart
void main() {
  // Create a list element with a comment
  var sourceFile = ElementOfListPbx(
      'MainViewController.swift',
      comment: 'Main view controller of the application'
  );

  // Output information about the list element
  print(sourceFile);

  // Create a copy of the element with a changed comment
  var updatedSourceFile = sourceFile.copyWith(
      comment: 'Updated main view controller file'
  );

  // Output information about the updated list element
  print(updatedSourceFile);
}
```

### ListPbx
`ListPbx` is a component of the `xcode_parser` library designed to
manage lists in Xcode project files (`*.pbxproj`). This component
is used to represent arrays of values, such as files,
configurations, and other collections of elements related to the project.


#### Methods

- `operator [](int index)` - Provides access to list elements by index.
- `int get length` - Returns the number of elements in the list.
- `void add(ElementOfListPbx element)` - Adds an element to the list.
- `String toString({int indentLevel = 0, bool removeN = false})` - Returns a string representation of the object, considering the indentation level and the need to remove line breaks. Designed to form a correct output of the list in a .pbxproj file.
- `ListPbx copyWith({String? uuid, List<ElementOfListPbx>? children, String? comment})` - Creates a copy of the current list object with the possibility of replacing its components. This is useful when needing to change the list without affecting the original object.


#### Example

```dart
void main() {
  // Create a list for project files
  var fileList = ListPbx(
      'FILE_LIST',
      [
        ElementOfListPbx('AppDelegate.swift'),
        ElementOfListPbx('ViewController.swift'),
      ],
      comment: 'List of source files'
  );

  // Add a new file to the list
  fileList.add(ElementOfListPbx('MainViewController.swift'));

  // Output information about the file list
  print(fileList);

  // Create a copy of the list with a changed comment
  var updatedFileList = fileList.copyWith(
      comment: 'Updated list of source files'
  );

  // Output updated information about the list
  print(updatedFileList);
}
```

