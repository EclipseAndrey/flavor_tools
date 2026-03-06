import 'package:xcode_parser/xcode_parser.dart';

class ExistingProjectSettings {
  final String swiftVersion;
  final String targetedDeviceFamily;
  final String iphoneosDeploymentTarget;
  final String clangCxxLanguageStandard;
  final String gccCLanguageStandard;

  const ExistingProjectSettings({
    this.swiftVersion = '6.0',
    this.targetedDeviceFamily = '"1,2"',
    this.iphoneosDeploymentTarget = '13.0',
    this.clangCxxLanguageStandard = '"gnu++20"',
    this.gccCLanguageStandard = 'gnu17',
  });

  factory ExistingProjectSettings.fromProject(Pbxproj project) {
    final map = project.find<MapPbx>('objects');
    final section = map?.find<SectionPbx>('XCBuildConfiguration');
    if (section == null) return const ExistingProjectSettings();

    MapPbx? nativeTargetConfig;
    MapPbx? projectConfig;

    for (final child in section.childrenList) {
      if (child is MapPbx) {
        final buildSettings = child.find<MapPbx>('buildSettings');
        if (buildSettings == null) continue;

        // NativeTarget configs have SWIFT_VERSION, Project configs have SDKROOT
        if (buildSettings.find<MapEntryPbx>('SWIFT_VERSION') != null) {
          nativeTargetConfig ??= buildSettings;
        } else if (buildSettings.find<MapEntryPbx>('SDKROOT') != null) {
          projectConfig ??= buildSettings;
        }

        if (nativeTargetConfig != null && projectConfig != null) break;
      }
    }

    return ExistingProjectSettings(
      swiftVersion: _readValue(nativeTargetConfig, 'SWIFT_VERSION') ?? '6.0',
      targetedDeviceFamily:
          _readValue(nativeTargetConfig, 'TARGETED_DEVICE_FAMILY') ??
              _readValue(projectConfig, 'TARGETED_DEVICE_FAMILY') ??
              '"1,2"',
      iphoneosDeploymentTarget:
          _readValue(projectConfig, 'IPHONEOS_DEPLOYMENT_TARGET') ?? '13.0',
      clangCxxLanguageStandard:
          _readValue(projectConfig, 'CLANG_CXX_LANGUAGE_STANDARD') ??
              '"gnu++20"',
      gccCLanguageStandard:
          _readValue(projectConfig, 'GCC_C_LANGUAGE_STANDARD') ?? 'gnu17',
    );
  }

  static String? _readValue(MapPbx? settings, String key) {
    final entry = settings?.find<MapEntryPbx>(key);
    if (entry == null) return null;
    final value = entry.value;
    if (value is VarPbx) return value.value;
    return null;
  }
}
