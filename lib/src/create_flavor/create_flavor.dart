import 'dart:io';

import 'package:flavor_tools/src/create_flavor/android/create_android_flavor.dart';
import 'package:flavor_tools/src/create_flavor/ios/create_xc_flavor.dart';

abstract class CreateFlavorExit {
  static void notFound({String? message}) {
    print('${message ?? ''} Not found');
    exit(404);
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
  final String plistPath = 'ios/Runner/Info.plist';
  final String manifestPath = 'android/app/src/main/AndroidManifest.xml';
  final String buildGradlePath = 'android/app/build.gradle';
  final String iosTeamId;

  FlavorConfig({
    this.xcPath = 'ios/Runner.xcodeproj/project.pbxproj',
    required this.iosPackageName,
    required this.androidPackageName,
    required this.displayName,
    required this.flavorName,
    required this.iosTeamId,
    this.dimension = 'default',
  });
}

Future<void> createFlavor(FlavorConfig config) async {
  await createXcFlavor(config);
  await createAndroidFlavor(config);
}
