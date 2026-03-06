import 'dart:io';

class ExistingFlavorValues {
  final String? iosPackageName;
  final String? iosDisplayName;
  final String? androidPackageName;
  final String? androidDisplayName;

  const ExistingFlavorValues({
    this.iosPackageName,
    this.iosDisplayName,
    this.androidPackageName,
    this.androidDisplayName,
  });

  bool get exists =>
      iosPackageName != null || iosDisplayName != null ||
      androidPackageName != null || androidDisplayName != null;
}

Future<ExistingFlavorValues> readExistingFlavorValues(String flavorName) async {
  String? iosPackage, iosDisplay, androidPackage, androidDisplay;

  // Read from iOS xcconfig
  final xcconfigPath = 'ios/Flutter/Debug-$flavorName.xcconfig';
  final xcconfigFile = File(xcconfigPath);
  if (await xcconfigFile.exists()) {
    final content = await xcconfigFile.readAsString();
    iosPackage = _extractXcconfigValue(content, 'bundle_id');
    iosDisplay = _extractXcconfigValue(content, 'app_display_name');
  }

  // Read from Android gradle
  final ktsFile = File('android/app/build.gradle.kts');
  final gradleFile = ktsFile.existsSync() ? ktsFile : File('android/app/build.gradle');
  final isKotlinDsl = ktsFile.existsSync();
  if (await gradleFile.exists()) {
    final content = await gradleFile.readAsString();
    final values = _extractGradleFlavorValues(content, flavorName, isKotlinDsl);
    androidPackage = values.$1;
    androidDisplay = values.$2;
  }

  return ExistingFlavorValues(
    iosPackageName: iosPackage,
    iosDisplayName: iosDisplay,
    androidPackageName: androidPackage,
    androidDisplayName: androidDisplay,
  );
}

String? _extractXcconfigValue(String content, String key) {
  final match = RegExp('$key\\s*=\\s*(.+)').firstMatch(content);
  return match?.group(1)?.trim();
}

(String?, String?) _extractGradleFlavorValues(String content, String flavorName, bool isKotlinDsl) {
  final RegExp flavorBlockRegex;
  if (isKotlinDsl) {
    flavorBlockRegex = RegExp('create\\s*\\("$flavorName"\\)\\s*\\{([^}]*?)\\}', dotAll: true);
  } else {
    flavorBlockRegex = RegExp('$flavorName\\s*\\{([^}]*?)\\}', dotAll: true);
  }
  final match = flavorBlockRegex.firstMatch(content);
  if (match == null) return (null, null);

  final block = match.group(1)!;
  final appIdMatch = RegExp(r'applicationId\s*[=]?\s*"([^"]*)"').firstMatch(block);
  final resValueMatch = RegExp(r'resValue[(\s]+"string"[\s,]+"app_name"[\s,]+"([^"]*)"').firstMatch(block);

  return (appIdMatch?.group(1), resValueMatch?.group(1));
}

Future<void> updateFlavor({
  required String flavorName,
  String? packageNameIos,
  String? packageNameAndroid,
  String? displayNameIos,
  String? displayNameAndroid,
}) async {
  if (packageNameIos != null || displayNameIos != null) {
    await _updateIosXcconfigs(flavorName, packageNameIos, displayNameIos);
  }
  if (packageNameAndroid != null || displayNameAndroid != null) {
    await _updateAndroidGradle(flavorName, packageNameAndroid, displayNameAndroid);
  }
  print('Flavor "$flavorName" updated successfully.');
}

Future<void> _updateIosXcconfigs(String flavorName, String? packageName, String? displayName) async {
  final configs = ['Debug', 'Release'];
  for (final type in configs) {
    final path = 'ios/Flutter/$type-$flavorName.xcconfig';
    final file = File(path);
    if (!await file.exists()) {
      print('Warning: $path not found, skipping.');
      continue;
    }

    var content = await file.readAsString();
    if (packageName != null) {
      content = content.replaceFirst(RegExp(r'bundle_id\s*=\s*.+'), 'bundle_id = $packageName');
    }
    if (displayName != null) {
      content = content.replaceFirst(RegExp(r'app_display_name\s*=\s*.+'), 'app_display_name = $displayName');
    }
    await file.writeAsString(content);
    print('Updated $path');
  }
}

Future<void> _updateAndroidGradle(String flavorName, String? packageName, String? displayName) async {
  final ktsFile = File('android/app/build.gradle.kts');
  final gradleFile = ktsFile.existsSync() ? ktsFile : File('android/app/build.gradle');
  final isKotlinDsl = ktsFile.existsSync();

  if (!await gradleFile.exists()) {
    print('Warning: ${gradleFile.path} not found, skipping Android update.');
    return;
  }

  var content = await gradleFile.readAsString();

  // Find the flavor block
  final RegExp flavorBlockRegex;
  if (isKotlinDsl) {
    flavorBlockRegex = RegExp('create\\s*\\("$flavorName"\\)\\s*\\{([^}]*?)\\}', dotAll: true);
  } else {
    flavorBlockRegex = RegExp('$flavorName\\s*\\{([^}]*?)\\}', dotAll: true);
  }

  final match = flavorBlockRegex.firstMatch(content);
  if (match == null) {
    print('Warning: flavor "$flavorName" not found in ${gradleFile.path}, skipping.');
    return;
  }

  var flavorBlock = match.group(0)!;

  if (packageName != null) {
    if (isKotlinDsl) {
      flavorBlock = flavorBlock.replaceFirst(RegExp(r'applicationId\s*=\s*"[^"]*"'), 'applicationId = "$packageName"');
    } else {
      flavorBlock = flavorBlock.replaceFirst(RegExp(r'applicationId\s+"[^"]*"'), 'applicationId "$packageName"');
    }
  }

  if (displayName != null) {
    if (isKotlinDsl) {
      flavorBlock = flavorBlock.replaceFirst(
          RegExp(r'resValue\s*\(\s*"string"\s*,\s*"app_name"\s*,\s*"[^"]*"\s*\)'),
          'resValue("string", "app_name", "$displayName")');
    } else {
      flavorBlock = flavorBlock.replaceFirst(
          RegExp(r'resValue\s+"string"\s*,\s*"app_name"\s*,\s*"[^"]*"'),
          'resValue "string", "app_name", "$displayName"');
    }
  }

  content = content.replaceRange(match.start, match.end, flavorBlock);
  await gradleFile.writeAsString(content);
  print('Updated ${gradleFile.path}');
}
