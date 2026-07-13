String addFlavorDimension(String content, String dimension, {required bool isKotlinDsl}) {
  if (isKotlinDsl) {
    final flavorDimensionsRegex = RegExp(r'flavorDimensions\s*\+=?\s*"([^"]+)"');
    if (flavorDimensionsRegex.hasMatch(content)) {
      return content;
    }
    final androidSectionRegex = RegExp(r'android\s*\{');
    final match = androidSectionRegex.firstMatch(content);
    if (match != null) {
      return content.replaceRange(match.end, match.end, '''

    flavorDimensions += "$dimension"''');
    }
    throw Exception('The android section not found in the build.gradle.kts file.');
  }

  final flavorDimensionsRegex = RegExp(r'flavorDimensions\s+"([^"]+)"');
  if (flavorDimensionsRegex.hasMatch(content)) {
    return content;
  }
  final androidSectionRegex = RegExp(r'android\s*\{');
  final match = androidSectionRegex.firstMatch(content);
  if (match != null) {
    return content.replaceRange(match.end, match.end, '''

    flavorDimensions "$dimension"''');
  }
  throw Exception('The android section not found in the build.gradle file.');
}

/// AGP 9 disables the `resValues` build feature by default, but generated
/// flavors rely on resValue("string", "app_name", ...). Groovy DSL (old
/// Gradle/AGP) is left untouched — resValues is enabled by default there.
String ensureResValuesEnabled(String content, {required bool isKotlinDsl}) {
  if (!isKotlinDsl) return content;
  if (RegExp(r'resValues\s*=\s*true').hasMatch(content)) {
    return content;
  }

  final buildFeaturesMatch = RegExp(r'buildFeatures\s*\{').firstMatch(content);
  if (buildFeaturesMatch != null) {
    return content.replaceRange(buildFeaturesMatch.end, buildFeaturesMatch.end, '''

        resValues = true''');
  }

  final androidMatch = RegExp(r'android\s*\{').firstMatch(content);
  if (androidMatch != null) {
    return content.replaceRange(androidMatch.end, androidMatch.end, '''

    buildFeatures {
        // Required for resValue("string", "app_name", ...) on AGP 9+.
        resValues = true
    }''');
  }
  throw Exception('The android section not found in the build.gradle.kts file.');
}

bool flavorExistsInGradle(String content, String flavorName, {required bool isKotlinDsl}) {
  if (isKotlinDsl) {
    return RegExp('create\\s*\\(\\s*"$flavorName"\\s*\\)').hasMatch(content);
  }
  return RegExp('\\b$flavorName\\s*\\{').hasMatch(content);
}

String addOrUpdateProductFlavors(
    String content, String flavorName, String dimension, String displayName, String androidPackage,
    {required bool isKotlinDsl}) {
  if (flavorExistsInGradle(content, flavorName, isKotlinDsl: isKotlinDsl)) {
    print('Android flavor "$flavorName" already exists, skipping.');
    return content;
  }

  final productFlavorsRegex = RegExp(r'productFlavors\s*\{');

  if (isKotlinDsl) {
    final flavorBlock = '''

        create("$flavorName") {
            dimension = "$dimension"
            resValue("string", "app_name", "$displayName")
            applicationId = "$androidPackage"
        }
''';
    final match = productFlavorsRegex.firstMatch(content);
    if (match != null) {
      return content.replaceRange(match.end, match.end, flavorBlock);
    }
    final androidSectionRegex = RegExp(r'android\s*\{');
    final androidMatch = androidSectionRegex.firstMatch(content);
    if (androidMatch != null) {
      return content.replaceRange(androidMatch.end, androidMatch.end, '''

    productFlavors {$flavorBlock
    }''');
    }
    throw Exception('The android section not found in the build.gradle.kts file.');
  }

  final flavorBlock = '''

        $flavorName {
            dimension "$dimension"
            resValue "string", "app_name", "$displayName"
            applicationId "$androidPackage"
        }
''';
  final match = productFlavorsRegex.firstMatch(content);
  if (match != null) {
    return content.replaceRange(match.end, match.end, flavorBlock);
  }
  final androidSectionRegex = RegExp(r'android\s*\{');
  final androidMatch = androidSectionRegex.firstMatch(content);
  if (androidMatch != null) {
    return content.replaceRange(androidMatch.end, androidMatch.end, '''

    productFlavors {$flavorBlock
    }''');
  }
  throw Exception('The android section not found in the build.gradle file.');
}
