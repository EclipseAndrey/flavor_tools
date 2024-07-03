import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flavor_tools/flavor_tools.dart';

Future<void> runnerArgs(List<String> arguments) async {
  var runner = CommandRunner('flavor_tools', 'A tool for managing application flavors')
    ..addCommand(CreateCommand())
    ..addCommand(UpdateCommand());

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
      ..addOption('teamId',
          abbr: 't', help: 'Team ID of the IOS application (DEFAULT: 0000000000).', defaultsTo: '0000000000');
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
        iosTeamId: teamId);

    await createFlavor(config);
  }
}

class UpdateCommand extends Command {
  @override
  final name = 'update';
  @override
  final description = 'Update an existing application flavor';

  UpdateCommand() {
    argParser
      ..addOption('flavorName', help: 'Flavor name of the application.', mandatory: true)
      ..addOption('packageNameIos', help: 'New package name specific to iOS.')
      ..addOption('packageNameAndroid', help: 'New package name specific to Android.')
      ..addOption('displayNameIos', help: 'New display name specific to iOS.')
      ..addOption('displayNameAndroid', help: 'New display name specific to Android.')
      ..addOption('newFlavorName', help: 'New flavor name of the application.');
  }

  @override
  void run() {
    var flavorName = argResults?['flavorName'];
    var packageNameIos = argResults?['packageNameIos'];
    var packageNameAndroid = argResults?['packageNameAndroid'];
    var displayNameIos = argResults?['displayNameIos'];
    var displayNameAndroid = argResults?['displayNameAndroid'];
    var newFlavorName = argResults?['newFlavorName'];

    print('Updating flavor "$flavorName" with the following details:');
    if (packageNameIos != null) print('New Package Name iOS: $packageNameIos');
    if (packageNameAndroid != null) print('New Package Name Android: $packageNameAndroid');
    if (displayNameIos != null) print('New Display Name iOS: $displayNameIos');
    if (displayNameAndroid != null) print('New Display Name Android: $displayNameAndroid');
    if (newFlavorName != null) print('New Flavor Name: $newFlavorName');
  }
}
