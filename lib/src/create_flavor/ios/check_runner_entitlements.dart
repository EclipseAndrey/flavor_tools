import 'dart:io';
import 'package:xml/xml.dart' as xml;

Future<void> checkRunnerEntitlements(String runnerEntitlementsPath) async {
  final file = File(runnerEntitlementsPath);

  if (!await file.exists()) {
    // Создаем XML-документ
    final builder = xml.XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('plist', nest: () {
      builder.attribute('version', '1.0');
      builder.element('dict', nest: () {
        builder.element('key', nest: 'aps-environment');
        builder.element('string', nest: 'development');
      });
    });

    final document = builder.buildDocument();

    // Записываем XML-документ в файл
    await file.writeAsString(document.toXmlString(pretty: true, indent: '\t'));

    print('Runner.entitlements created successfully.');
  }
}
