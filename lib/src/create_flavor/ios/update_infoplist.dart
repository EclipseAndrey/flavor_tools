import 'dart:io';
import 'package:collection/collection.dart';
import 'package:xml/xml.dart';

Future<void> updateInfoPlist(String plistPath, String appDisplayName) async {
  final file = File(plistPath);
  var content = await file.readAsString();

  final document = XmlDocument.parse(content);
  final dict = document.findAllElements('dict').first;

  // Function to update or add key-value pairs
  void updateOrAddKey(XmlElement dict, String key, String value) {
    final existingKey = dict.findElements('key').firstWhereOrNull(
          (element) => element.value == key,
        );

    if (existingKey != null) {
      final valueElement = existingKey.nextElementSibling;
      if (valueElement != null && valueElement.name.local == 'string') {
        valueElement.innerText = value;
      } else {
        // If the next sibling is not a string, replace it with the correct value
        existingKey.nextElementSibling?.replace(XmlElement(XmlName('string'), [], [XmlText(value)]));
      }
    } else {
      dict.children.addAll([
        XmlElement(XmlName('key'))..innerText = key,
        XmlElement(XmlName('string'))..innerText = value,
      ]);
    }
  }

  // Update or add CFBundleDisplayName
  updateOrAddKey(dict, 'CFBundleDisplayName', '\$(APP_DISPLAY_NAME)');

  // Update or add CFBundleName
  updateOrAddKey(dict, 'CFBundleName', '\${app_display_name}');

  // Save the updated content back to the file
  await file.writeAsString(document.toXmlString(pretty: true, indent: '\t'));
  print('Updated Info.plist successfully.');
}
