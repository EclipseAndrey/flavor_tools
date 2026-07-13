import 'package:flavor_tools/src/create_flavor/android/update_gradle.dart';
import 'package:test/test.dart';

void main() {
  group('ensureResValuesEnabled', () {
    test('adds buildFeatures block to kts without one', () {
      const content = '''
android {
    namespace = "com.example.app"
}
''';
      final result = ensureResValuesEnabled(content, isKotlinDsl: true);
      expect(result, contains('buildFeatures {'));
      expect(result, contains('resValues = true'));
    });

    test('inserts into existing buildFeatures block', () {
      const content = '''
android {
    buildFeatures {
        buildConfig = true
    }
}
''';
      final result = ensureResValuesEnabled(content, isKotlinDsl: true);
      expect(result, contains('resValues = true'));
      expect(RegExp(r'buildFeatures\s*\{').allMatches(result).length, 1);
    });

    test('skips when resValues already enabled', () {
      const content = '''
android {
    buildFeatures {
        resValues = true
    }
}
''';
      expect(ensureResValuesEnabled(content, isKotlinDsl: true), content);
    });

    test('leaves groovy untouched', () {
      const content = '''
android {
}
''';
      expect(ensureResValuesEnabled(content, isKotlinDsl: false), content);
    });
  });

  group('addOrUpdateProductFlavors kts', () {
    test('creates productFlavors with flavor block', () {
      const content = '''
android {
    namespace = "com.example.app"
}
''';
      final result = addOrUpdateProductFlavors(content, 'dev', 'default', 'Dev App', 'dev.app', isKotlinDsl: true);
      expect(result, contains('create("dev") {'));
      expect(result, contains('applicationId = "dev.app"'));
      expect(result, contains('resValue("string", "app_name", "Dev App")'));
    });

    test('skips existing flavor', () {
      const content = '''
android {
    productFlavors {
        create("dev") {
            dimension = "default"
        }
    }
}
''';
      expect(addOrUpdateProductFlavors(content, 'dev', 'default', 'Dev', 'dev.app', isKotlinDsl: true), content);
    });
  });
}
