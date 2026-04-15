import 'dart:io';

import 'package:flavor_tools/src/create_flavor/android/create_android_flavor.dart';
import 'package:flavor_tools/src/create_flavor/ios/create_xc_flavor.dart';

abstract class CreateFlavorExit {
  static void notFound({String? message}) {
    print('Error: ${message ?? 'Required section not found in project.'}');
    exit(1);
  }
}

enum BuildType {
  debug,
  profile,
  release;

  @override
  String toString() {
    return switch (this) {
      BuildType.debug => 'Debug',
      BuildType.release => 'Release',
      BuildType.profile => 'Profile',
    };
  }
}

class FlavorConfig {
  final String xcPath;
  final String iosPackageName;
  final String androidPackageName;
  final String displayName;
  final String flavorName;
  final String dimension;
  final String runnerEntitlementsPath = 'ios/Runner/Runner.entitlements';
  final String plistPath = 'ios/Runner/Info.plist';
  final String manifestPath = 'android/app/src/main/AndroidManifest.xml';
  late final String buildGradlePath = _detectGradlePath();
  final String iosTeamId;
  final bool isEnabledIconsLauncher;
  final bool runPodInstall;

  // ignore: non_constant_identifier_names
  String get ASSETCATALOG_COMPILER_APPICON_NAME => isEnabledIconsLauncher ? '"\${app_display_icon}"' : 'AppIcon';
  // ignore: non_constant_identifier_names
  String get APP_DISPLAY_NAME => '"\${app_display_name}"';

  bool get isKotlinDsl => buildGradlePath.endsWith('.kts');

  FlavorConfig({
    this.xcPath = 'ios/Runner.xcodeproj/project.pbxproj',
    required this.iosPackageName,
    required this.androidPackageName,
    required this.displayName,
    required this.flavorName,
    required this.iosTeamId,
    this.dimension = 'default',
    this.isEnabledIconsLauncher = false,
    this.runPodInstall = false,
  });

  static String _detectGradlePath() {
    final ktsFile = File('android/app/build.gradle.kts');
    if (ktsFile.existsSync()) return 'android/app/build.gradle.kts';
    return 'android/app/build.gradle';
  }
}

Future<void> createFlavor(FlavorConfig config) async {
  await createXcFlavor(config);
  await createAndroidFlavor(config);
  if (config.runPodInstall) {
    print('Running pod install...');
    final result = await Process.run('pod', ['install'], workingDirectory: 'ios', runInShell: true);
    stdout.write(result.stdout);
    stderr.write(result.stderr);
    if (result.exitCode != 0) {
      print('pod install exited with code ${result.exitCode}');
    }
  }
}
