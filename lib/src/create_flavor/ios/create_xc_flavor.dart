import 'dart:io';

import 'package:flavor_tools/flavor_tools.dart';
import 'package:flavor_tools/src/create_flavor/ios/check_runner_entitlements.dart';
import 'package:flavor_tools/src/create_flavor/ios/update_infoplist.dart';
import 'package:flavor_tools/src/create_flavor/models/create_xc_configuration.dart';
import 'package:flavor_tools/src/create_flavor/models/create_xc_scheme.dart';
import 'package:xcode_parser/xcode_parser.dart';

createXcFlavor(FlavorConfig config) async {
  final String flavor = config.flavorName;
  final String package = config.iosPackageName;
  final String displayName = config.displayName;

  await checkRunnerEntitlements(config.runnerEntitlementsPath);
  await updateInfoPlist(config.plistPath, displayName);

  var project = await Pbxproj.open(config.xcPath);
  final blueprintIdentifierProfile = project.generateUuid();
  final blueprintIdentifierRelease = project.generateUuid();
  final blueprintIdentifierDebug = project.generateUuid();

  final uuidReleaseFile = project.generateUuid();
  final uuidDebugFile = project.generateUuid();

  final uuidReleaseRef = project.generateUuid();
  final uuidDebugRef = project.generateUuid();
  final uuidProfileRef = project.generateUuid();

  final uuidReleaseBuildConfiguration1 = project.generateUuid();
  final uuidDebugBuildConfiguration1 = project.generateUuid();
  final uuidProfileBuildConfiguration1 = project.generateUuid();

  final uuidReleaseBuildConfiguration2 = project.generateUuid();
  final uuidDebugBuildConfiguration2 = project.generateUuid();
  final uuidProfileBuildConfiguration2 = project.generateUuid();

  await createXcConfig(BuildType.release, flavor, package, displayName);
  await createXcConfig(BuildType.debug, flavor, package, displayName);

  await createXcodeScheme(
    blueprintIdentifierDebug: blueprintIdentifierDebug,
    blueprintIdentifierProfile: blueprintIdentifierProfile,
    blueprintIdentifierRelease: blueprintIdentifierRelease,
    flavor: flavor,
  );

  //addPBXBuildFile
  addPBXBuildFile(project, BuildType.release, flavor, uuidReleaseFile, uuidReleaseRef);
  addPBXBuildFile(project, BuildType.debug, flavor, uuidDebugFile, uuidDebugRef);
  //addPBXFileReference
  addPBXFileReference(project, BuildType.release, flavor, uuidReleaseRef);
  addPBXFileReference(project, BuildType.debug, flavor, uuidDebugRef);
  addPBXFileReference(project, BuildType.profile, flavor, uuidProfileRef);
  //addPBXGroup
  addPBXGroup(project, BuildType.release, flavor, uuidReleaseRef);
  addPBXGroup(project, BuildType.debug, flavor, uuidDebugRef);
  //addPBXResourcesBuildPhase
  addPBXResourcesBuildPhase(project, BuildType.release, flavor, uuidReleaseFile);
  addPBXResourcesBuildPhase(project, BuildType.debug, flavor, uuidDebugFile);
  //addXCConfigurationList
  addXCConfigurationList(project, BuildType.release, flavor, uuidReleaseBuildConfiguration1);
  addXCConfigurationList(project, BuildType.debug, flavor, uuidDebugBuildConfiguration1);
  addXCConfigurationList(project, BuildType.profile, flavor, uuidProfileBuildConfiguration1);
  //addXCConfigurationListNativeTarget
  addXCConfigurationListNativeTarget(project, BuildType.release, flavor, uuidReleaseBuildConfiguration2);
  addXCConfigurationListNativeTarget(project, BuildType.debug, flavor, uuidDebugBuildConfiguration2);
  addXCConfigurationListNativeTarget(project, BuildType.profile, flavor, uuidProfileBuildConfiguration2);
  //addXCBuildConfiguration
  addXCBuildConfiguration(project, BuildType.release, uuidReleaseRef, uuidReleaseBuildConfiguration1, config);
  addXCBuildConfiguration(project, BuildType.debug, uuidDebugRef, uuidDebugBuildConfiguration1, config);
  addXCBuildConfiguration(project, BuildType.profile, uuidReleaseRef, uuidProfileBuildConfiguration1, config);
  //addXCBuildConfigurationSecond
  addXCBuildConfigurationSecond(project, BuildType.release, flavor, uuidReleaseRef, uuidReleaseBuildConfiguration2);
  addXCBuildConfigurationSecond(project, BuildType.debug, flavor, uuidDebugRef, uuidDebugBuildConfiguration2);
  addXCBuildConfigurationSecond(project, BuildType.profile, flavor, uuidReleaseRef, uuidProfileBuildConfiguration2);

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

Pbxproj addXCBuildConfiguration(
    Pbxproj project, BuildType buildType, String uuidRef, String uuidConfiguration, FlavorConfig config) {
  //XCBuildConfiguration section
  final map = project.find<MapPbx>('objects');
  final section = map?.find<SectionPbx>('XCBuildConfiguration');
  final insertValue = createXCConfigurationFirstDebug(buildType, uuidRef, uuidConfiguration, config);
  section?.add(insertValue);
  if (section == null) CreateFlavorExit.notFound();
  return project;
}

Pbxproj addXCBuildConfigurationSecond(
    Pbxproj project, BuildType buildType, String flavor, String uuidRef, String uuid) {
  //XCBuildConfiguration section
  final map = project.find<MapPbx>('objects');
  final section = map?.find<SectionPbx>('XCBuildConfiguration');
  final insertValue = createXCConfigurationSecond(buildType, flavor, uuidRef, uuid);
  section?.add(insertValue);
  if (section == null) CreateFlavorExit.notFound();
  return project;
}
