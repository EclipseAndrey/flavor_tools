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
