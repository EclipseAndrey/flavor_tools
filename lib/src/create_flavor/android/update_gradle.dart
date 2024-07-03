String addFlavorDimension(String content, String dimension) {
  final flavorDimensionsRegex = RegExp(r'flavorDimensions\s+"([^"]+)"');
  if (flavorDimensionsRegex.hasMatch(content)) {
    return content;
  } else {
    final androidSectionRegex = RegExp(r'android\s*\{');
    final match = androidSectionRegex.firstMatch(content);

    if (match != null) {
      final insertPosition = match.end;
      final updatedContent = content.replaceRange(insertPosition, insertPosition, '''

    flavorDimensions "$dimension"''');
      return updatedContent;
    } else {
      throw Exception('The android section not found in the build.gradle file.');
    }
  }
}

String addOrUpdateProductFlavors(
    String content, String flavorName, String dimension, String displayName, String androidPackage) {
  final productFlavorsRegex = RegExp(r'productFlavors\s*\{');
  final flavorBlock = '''

        $flavorName {
            dimension "$dimension"
            resValue "string", "app_name", "$displayName"
            applicationId "$androidPackage"
        }
''';

  final match = productFlavorsRegex.firstMatch(content);

  if (match != null) {
    final insertPosition = match.end;
    final updatedContent = content.replaceRange(insertPosition, insertPosition, flavorBlock);
    return updatedContent;
  } else {
    final androidSectionRegex = RegExp(r'android\s*\{');
    final androidMatch = androidSectionRegex.firstMatch(content);

    if (androidMatch != null) {
      final insertPosition = androidMatch.end;
      final updatedContent = content.replaceRange(insertPosition, insertPosition, '''

    productFlavors {$flavorBlock
    }''');
      return updatedContent;
    } else {
      throw Exception('The android section not found in the build.gradle file.');
    }
  }
}
