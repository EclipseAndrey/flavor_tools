import 'dart:io';

import 'package:flavor_tools/flavor_tools.dart';
import 'package:flavor_tools/src/create_flavor/android/create_app_name_manifest.dart';
import 'package:flavor_tools/src/create_flavor/android/update_gradle.dart';

Future<void> createAndroidFlavor(FlavorConfig config) async {
  final gradlePath = config.buildGradlePath;
  final flavorName = config.flavorName;
  final dimension = config.dimension;
  final displayName = config.displayName;
  final androidPackage = config.androidPackageName;

  final file = File(gradlePath);
  if (!await file.exists()) {
    print('Error: Gradle file not found at $gradlePath');
    exit(1);
  }
  var content = await file.readAsString();

  final isKotlinDsl = config.isKotlinDsl;
  content = addFlavorDimension(content, dimension, isKotlinDsl: isKotlinDsl);
  content = addOrUpdateProductFlavors(content, flavorName, dimension, displayName, androidPackage, isKotlinDsl: isKotlinDsl);

  await file.writeAsString(content);

  await updateAndroidManifest(config.manifestPath);

  print('New product flavor added or updated successfully.');
}
