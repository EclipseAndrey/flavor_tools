import 'dart:io';

import 'package:flavor_tools/flavor_tools.dart';
import 'package:flavor_tools/src/create_flavor/ios/check_runner_entitlements.dart';
import 'package:flavor_tools/src/create_flavor/ios/update_infoplist.dart';
import 'package:flavor_tools/src/create_flavor/models/create_xc_configuration.dart';
import 'package:flavor_tools/src/create_flavor/models/create_xc_scheme.dart';
import 'package:flavor_tools/src/create_flavor/models/existing_project_settings.dart';
import 'package:xcode_parser/xcode_parser.dart';

createXcFlavor(FlavorConfig config) async {
  final String flavor = config.flavorName;
  final String package = config.iosPackageName;
  final String displayName = config.displayName;

  await checkRunnerEntitlements(config.runnerEntitlementsPath);
  await updateInfoPlist(config.plistPath, displayName);

  var project = await Pbxproj.open(config.xcPath);

  if (_flavorExistsInProject(project, flavor)) {
    print('iOS flavor "$flavor" already exists, skipping.');
    return;
  }

  final projectSettings = ExistingProjectSettings.fromProject(project);
  print('Using project settings: SWIFT_VERSION=${projectSettings.swiftVersion}, '
      'IPHONEOS_DEPLOYMENT_TARGET=${projectSettings.iphoneosDeploymentTarget}, '
      'TARGETED_DEVICE_FAMILY=${projectSettings.targetedDeviceFamily}');

  String uuid() => project.generateUuid();

  // UUIDs for xcconfig files (only Debug & Release have their own files)
  final fileUuid = {BuildType.release: uuid(), BuildType.debug: uuid()};
  final refUuid = {BuildType.release: uuid(), BuildType.debug: uuid()};

  // UUIDs for build configurations (all three types)
  final configUuid1 = {for (var t in BuildType.values) t: uuid()};
  final configUuid2 = {for (var t in BuildType.values) t: uuid()};

  // Profile reuses Release xcconfig ref
  String refFor(BuildType type) => refUuid[type] ?? refUuid[BuildType.release]!;

  await createXcConfig(BuildType.release, flavor, package, displayName);
  await createXcConfig(BuildType.debug, flavor, package, displayName);

  await createXcodeScheme(
    project: project,
    flavor: flavor,
  );

  // Debug & Release: file references, build files, groups, resources
  for (final type in [BuildType.release, BuildType.debug]) {
    addPBXBuildFile(project, type, flavor, fileUuid[type]!, refUuid[type]!);
    addPBXFileReference(project, type, flavor, refUuid[type]!);
    addPBXGroup(project, type, flavor, refUuid[type]!);
    addPBXResourcesBuildPhase(project, type, flavor, fileUuid[type]!);
  }

  // All three types: configuration lists and build configurations
  for (final type in BuildType.values) {
    addXCConfigurationList(project, type, flavor, configUuid1[type]!);
    addXCConfigurationListNativeTarget(project, type, flavor, configUuid2[type]!);
    addXCBuildConfiguration(project, type, refFor(type), configUuid1[type]!, config, projectSettings);
    addXCBuildConfigurationSecond(project, type, flavor, refFor(type), configUuid2[type]!, projectSettings);
  }

  await project.save();
}

Future<void> createXcConfig(BuildType buildType, String flavor, String package, String displayName) async {
  final filePath = 'ios/Flutter/$buildType-$flavor.xcconfig';
  final directoryPath = 'ios/Flutter';
  final directory = Directory(directoryPath);
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }
  final file = File(filePath);
  if (!await file.exists()) {
    await file.create();
  }
  final content = StringBuffer();
  content.writeln('#include? "Pods/Target Support Files/Pods-Runner/Pods-Runner.${buildType.name}.xcconfig"');
  content.writeln('#include "Generated.xcconfig"');
  content.writeln('bundle_id = $package');
  content.writeln('app_display_name = $displayName');
  content.writeln('app_display_icon = AppIcon-$flavor');
  await file.writeAsString(content.toString());
  print('Created $filePath');
}

Pbxproj addPBXBuildFile(Pbxproj project, BuildType buildType, String flavor, String uuidFile, String uuidRef) {
  final map = project.find<MapPbx>('objects');
  final section = map?.find<SectionPbx>('PBXBuildFile');
  final insertValue = MapPbx(
    uuid: uuidFile,
    comment: '$buildType-$flavor.xcconfig in Resources',
    children: [
      MapEntryPbx('isa', VarPbx('PBXBuildFile')),
      MapEntryPbx('fileRef', VarPbx(uuidRef), comment: '$buildType-$flavor.xcconfig'),
    ],
  );
  section?.add(insertValue);
  if (section == null) CreateFlavorExit.notFound();
  return project;
}

Pbxproj addPBXFileReference(Pbxproj project, BuildType buildType, String flavor, String uuidRef) {
  final map = project.find<MapPbx>('objects');
  final section = map?.find<SectionPbx>('PBXFileReference');
  final insertValue = MapPbx(
    uuid: uuidRef,
    comment: '$buildType-$flavor.xcconfig',
    children: [
      MapEntryPbx('isa', VarPbx('PBXFileReference')),
      MapEntryPbx('fileEncoding', VarPbx('4')),
      MapEntryPbx('lastKnownFileType', VarPbx('text.xcconfig')),
      MapEntryPbx('name', VarPbx('$buildType-$flavor.xcconfig')),
      MapEntryPbx('path', VarPbx('Flutter/$buildType-$flavor.xcconfig')),
      MapEntryPbx('sourceTree', VarPbx('"<group>"')),
    ],
  );
  section?.add(insertValue);
  if (section == null) CreateFlavorExit.notFound();
  return project;
}

Pbxproj addPBXGroup(Pbxproj project, BuildType buildType, String flavor, String uuid) {
  final map = project.find<MapPbx>('objects');
  final section = map?.find<SectionPbx>('PBXGroup');
  final flutterMap = section?.findComment<MapPbx>('Flutter');
  final listChildren = flutterMap?.find<ListPbx>('children');
  final insertValue = ElementOfListPbx(uuid, comment: '$buildType-$flavor.xcconfig');
  listChildren?.add(insertValue);
  if (listChildren == null) CreateFlavorExit.notFound();
  return project;
}

Pbxproj addPBXResourcesBuildPhase(Pbxproj project, BuildType buildType, String flavor, String uuidFile) {
  final map = project.find<MapPbx>('objects');
  final section = map?.find<SectionPbx>('PBXResourcesBuildPhase');
  final elementResources = section?.findComment<MapPbx>('Resources');
  final arrayFiles = elementResources?.find<ListPbx>('files');
  final insertValue = ElementOfListPbx(uuidFile, comment: '$buildType-$flavor.xcconfig in Resources');
  arrayFiles?.add(insertValue);
  if (arrayFiles == null) CreateFlavorExit.notFound();
  return project;
}

Pbxproj addXCConfigurationList(Pbxproj project, BuildType buildType, String flavor, String uuid) {
  final map = project.find<MapPbx>('objects');
  final section = map?.find<SectionPbx>('XCConfigurationList');
  final elementBuildConfigurationList =
      section?.findComment<MapPbx>('Build configuration list for PBXProject "Runner"');
  final arrayBuildConfigurations = elementBuildConfigurationList?.find<ListPbx>('buildConfigurations');
  final insertValue = ElementOfListPbx(uuid, comment: '$buildType-$flavor');
  arrayBuildConfigurations?.add(insertValue);
  if (arrayBuildConfigurations == null) CreateFlavorExit.notFound();
  return project;
}

Pbxproj addXCConfigurationListNativeTarget(Pbxproj project, BuildType buildType, String flavor, String uuid) {
  final map = project.find<MapPbx>('objects');
  final section = map?.find<SectionPbx>('XCConfigurationList');
  final elementBuildConfigurationList =
      section?.findComment<MapPbx>('Build configuration list for PBXNativeTarget "Runner"');
  final arrayBuildConfigurations = elementBuildConfigurationList?.find<ListPbx>('buildConfigurations');
  final insertValue = ElementOfListPbx(uuid, comment: '$buildType-$flavor');
  arrayBuildConfigurations?.add(insertValue);
  if (arrayBuildConfigurations == null) CreateFlavorExit.notFound();
  return project;
}

Pbxproj addXCBuildConfiguration(Pbxproj project, BuildType buildType, String uuidRef, String uuidConfiguration,
    FlavorConfig config, ExistingProjectSettings projectSettings) {
  final map = project.find<MapPbx>('objects');
  final section = map?.find<SectionPbx>('XCBuildConfiguration');
  final insertValue =
      createXCConfigurationFirst(buildType, uuidRef, uuidConfiguration, config.iosTeamId, config, projectSettings);
  section?.add(insertValue);
  if (section == null) CreateFlavorExit.notFound();
  return project;
}

Pbxproj addXCBuildConfigurationSecond(
    Pbxproj project, BuildType buildType, String flavor, String uuidRef, String uuid, ExistingProjectSettings projectSettings) {
  final map = project.find<MapPbx>('objects');
  final section = map?.find<SectionPbx>('XCBuildConfiguration');
  final insertValue = createXCConfigurationSecond(buildType, flavor, uuidRef, uuid, projectSettings);
  section?.add(insertValue);
  if (section == null) CreateFlavorExit.notFound();
  return project;
}

bool _flavorExistsInProject(Pbxproj project, String flavor) {
  final map = project.find<MapPbx>('objects');
  final section = map?.find<SectionPbx>('XCConfigurationList');
  final configList = section?.findComment<MapPbx>('Build configuration list for PBXProject "Runner"');
  final buildConfigurations = configList?.find<ListPbx>('buildConfigurations');
  if (buildConfigurations == null) return false;
  for (int i = 0; i < buildConfigurations.length; i++) {
    if (buildConfigurations[i].comment?.contains('Debug-$flavor') ?? false) {
      return true;
    }
  }
  return false;
}
