import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flavor_tools/flavor_tools.dart';
import 'package:flavor_tools/src/set_target_device_family/set_target_device_family.dart';
import 'package:flavor_tools/src/update_flavor/update_flavor.dart' show updateFlavor, readExistingFlavorValues;
import 'package:yaml/yaml.dart';

Future<void> runnerArgs(List<String> arguments) async {
  var runner = CommandRunner('flavor_tools', 'A tool for managing application flavors')
    ..addCommand(CreateCommand())
    ..addCommand(CreateAllCommand())
    ..addCommand(UpdateCommand())
    ..addCommand(SetTargetDeviceFamilyCommand());

  await runner.run(arguments).catchError((error) {
    print(error);
    if (error is UsageException) {
      print('\n${error.usage}');
    }
  });
}

class CreateCommand extends Command {
  @override
  final name = 'create';
  @override
  final description = 'Create a new application flavor';

  void _requiredOption(List<String> option) {
    final options = List.generate(option.length, (i) => argResults?[option[i]]);

    if (options.every((test) => test == null)) {
      print('Missing required option: $option\n$usage');
      exit(1);
    }
  }

  CreateCommand() {
    argParser
      ..addOption('packageName', abbr: 'p', help: 'Package name for iOS and Android if common.')
      ..addOption('packageNameIos', abbr: 'i', help: 'Package name specific to iOS.')
      ..addOption('packageNameAndroid', abbr: 'a', help: 'Package name specific to Android.')
      ..addOption('displayName', abbr: 'd', help: 'Display name of the application.')
      ..addOption('flavorName', abbr: 'f', help: 'Flavor name of the application.')
      ..addOption('pathXcProject', abbr: 'x', help: 'Path to the Xcode project (optional).')
      ..addOption('iconsLauncher', help: 'Supports icons (optional).', defaultsTo: 'false')
      ..addOption('teamId', abbr: 't', help: 'Team ID of the IOS application (DEFAULT: none).', defaultsTo: '""');
  }

  @override
  Future<void> run() async {
    _requiredOption(['packageName', 'packageNameIos']);
    _requiredOption(['packageName', 'packageNameAndroid']);
    _requiredOption(['displayName']);
    _requiredOption(['flavorName']);

    var packageName = argResults?['packageName'];
    var packageNameIos = argResults?['packageNameIos'];
    var packageNameAndroid = argResults?['packageNameAndroid'];
    var displayName = argResults?['displayName'];
    var flavorName = argResults?['flavorName'];
    var pathXcProject = argResults?['pathXcProject'];
    var teamId = argResults?['teamId'];

    print('Creating flavor with the following details:');
    print('Package Name: $packageName');
    print('Package Name iOS: $packageNameIos');
    print('Package Name Android: $packageNameAndroid');
    print('Display Name: $displayName');
    print('Flavor Name: $flavorName');
    print('Path to Xcode Project: $pathXcProject');

    final config = FlavorConfig(
        xcPath: pathXcProject ?? 'ios/Runner.xcodeproj/project.pbxproj',
        iosPackageName: (packageNameIos ?? packageName)!,
        androidPackageName: (packageNameAndroid ?? packageName)!,
        displayName: displayName,
        flavorName: flavorName,
        iosTeamId: teamId,
        isEnabledIconsLauncher: (argResults?['iconsLauncher'] ?? 'false') == 'true');

    await createFlavor(config);
  }
}

class CreateAllCommand extends Command {
  @override
  final name = 'create-all';
  @override
  final description = 'Create multiple flavors from a YAML config file';

  CreateAllCommand() {
    argParser
      ..addOption('config', abbr: 'c', help: 'Path to YAML config file.', defaultsTo: 'flavor_tools.yaml')
      ..addOption('pathXcProject', abbr: 'x', help: 'Path to the Xcode project (optional).')
      ..addOption('teamId', abbr: 't', help: 'Team ID of the iOS application.', defaultsTo: '""')
      ..addOption('iconsLauncher', help: 'Supports icons (optional).', defaultsTo: 'false');
  }

  @override
  Future<void> run() async {
    final configPath = argResults?['config'] ?? 'flavor_tools.yaml';
    final pathXcProject = argResults?['pathXcProject'];
    final teamId = argResults?['teamId'] ?? '""';
    final iconsLauncher = (argResults?['iconsLauncher'] ?? 'false') == 'true';

    final file = File(configPath);
    if (!await file.exists()) {
      print('Config file not found: $configPath');
      exit(1);
    }

    final content = await file.readAsString();
    final yaml = loadYaml(content);

    if (yaml is! YamlMap || yaml['flavors'] is! YamlMap) {
      print('Invalid config format. Expected "flavors" section.');
      exit(1);
    }

    final flavors = yaml['flavors'] as YamlMap;
    print('Found ${flavors.length} flavor(s) in config.\n');

    for (final entry in flavors.entries) {
      final flavorName = entry.key as String;
      if (entry.value is! YamlMap) {
        print('Skipping "$flavorName": invalid format, expected a map of properties.');
        continue;
      }
      final props = entry.value as YamlMap;

      final packageName = props['package_name'] as String?;
      final packageNameIos = props['package_name_ios'] as String? ?? packageName;
      final packageNameAndroid = props['package_name_android'] as String? ?? packageName;
      final displayName = props['display_name'] as String?;
      final dimension = props['dimension'] as String? ?? 'default';

      if (packageNameIos == null || packageNameAndroid == null || displayName == null) {
        print('Skipping "$flavorName": missing required fields (package_name, display_name).');
        continue;
      }

      // Check if flavor already exists and needs updating
      final existing = await readExistingFlavorValues(flavorName);
      if (existing.exists) {
        final needsIosPackage = packageNameIos != existing.iosPackageName ? packageNameIos : null;
        final needsIosDisplay = displayName != existing.iosDisplayName ? displayName : null;
        final needsAndroidPackage = packageNameAndroid != existing.androidPackageName ? packageNameAndroid : null;
        final needsAndroidDisplay = displayName != existing.androidDisplayName ? displayName : null;

        if (needsIosPackage != null || needsIosDisplay != null || needsAndroidPackage != null || needsAndroidDisplay != null) {
          print('--- Updating flavor: $flavorName ---');
          await updateFlavor(
            flavorName: flavorName,
            packageNameIos: needsIosPackage,
            packageNameAndroid: needsAndroidPackage,
            displayNameIos: needsIosDisplay,
            displayNameAndroid: needsAndroidDisplay,
          );
        } else {
          print('--- Flavor "$flavorName" is up to date ---');
        }
        print('');
        continue;
      }

      print('--- Creating flavor: $flavorName ---');
      final config = FlavorConfig(
        xcPath: pathXcProject ?? 'ios/Runner.xcodeproj/project.pbxproj',
        iosPackageName: packageNameIos,
        androidPackageName: packageNameAndroid,
        displayName: displayName,
        flavorName: flavorName,
        iosTeamId: props['team_id'] as String? ?? teamId,
        dimension: dimension,
        isEnabledIconsLauncher: props['icons_launcher'] as bool? ?? iconsLauncher,
      );

      await createFlavor(config);
      print('');
    }

    print('All flavors processed.');
  }
}

class UpdateCommand extends Command {
  @override
  final name = 'update';
  @override
  final description = 'Update an existing application flavor';

  UpdateCommand() {
    argParser
      ..addOption('flavorName', abbr: 'f', help: 'Flavor name of the application.', mandatory: true)
      ..addOption('packageName', abbr: 'p', help: 'New package name for both iOS and Android.')
      ..addOption('packageNameIos', help: 'New package name specific to iOS.')
      ..addOption('packageNameAndroid', help: 'New package name specific to Android.')
      ..addOption('displayName', abbr: 'd', help: 'New display name for both iOS and Android.')
      ..addOption('displayNameIos', help: 'New display name specific to iOS.')
      ..addOption('displayNameAndroid', help: 'New display name specific to Android.');
  }

  @override
  Future<void> run() async {
    final flavorName = argResults!['flavorName'] as String;
    final packageName = argResults?['packageName'] as String?;
    final packageNameIos = argResults?['packageNameIos'] as String? ?? packageName;
    final packageNameAndroid = argResults?['packageNameAndroid'] as String? ?? packageName;
    final displayName = argResults?['displayName'] as String?;
    final displayNameIos = argResults?['displayNameIos'] as String? ?? displayName;
    final displayNameAndroid = argResults?['displayNameAndroid'] as String? ?? displayName;

    if ([packageNameIos, packageNameAndroid, displayNameIos, displayNameAndroid].every((e) => e == null)) {
      print('Nothing to update. Provide at least one of: --packageName, --displayName, etc.\n$usage');
      exit(1);
    }

    await updateFlavor(
      flavorName: flavorName,
      packageNameIos: packageNameIos,
      packageNameAndroid: packageNameAndroid,
      displayNameIos: displayNameIos,
      displayNameAndroid: displayNameAndroid,
    );
  }
}

class SetTargetDeviceFamilyCommand extends Command {
  @override
  final name = 'set-target-device-family';
  @override
  final description = 'Set target device family for iOS (1 - iPhone, 2 - iPad)';

  SetTargetDeviceFamilyCommand() {
    argParser.addOption(
      'devices',
      abbr: 'd',
      help: 'Target device family for iOS (1 - iPhone, 2 - iPad).',
    );
  }

  @override
  void run() {
    final targetDeviceFamily = argResults?['devices'];
    if (targetDeviceFamily == null) {
      print('Error: Missing required option --devices\n$usage');
      exit(1);
    }

    print('Target device family: $targetDeviceFamily (${targetDeviceFamily.runtimeType})');
    setTargetDeviceFamily(targetDeviceFamily);
  }
}
