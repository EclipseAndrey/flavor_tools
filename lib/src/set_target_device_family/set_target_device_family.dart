import 'package:flavor_tools/flavor_tools.dart';
import 'package:xcode_parser/xcode_parser.dart';

String formatDeviceFamily(String input) {
  const allowedValues = ["1", "2"];

  List<String> values = input.split(',').map((e) => e.trim()).toSet().toList()..sort();

  if (values.every((value) => allowedValues.contains(value))) {
    if (values.length == 1) {
      return values.first;
    }
    return '"${values.join(",")}"';
  } else {
    throw FormatException("Invalid input. Allowed values are: ${allowedValues.join(", ")}");
  }
}

Future<void> setTargetDeviceFamily(String targetDeviceFamily) async {
  print('Setting targetDeviceFamily to $targetDeviceFamily');

  var project = await Pbxproj.open('ios/Runner.xcodeproj/project.pbxproj');

  final map = project.find<MapPbx>('objects');

  final section = map?.find<SectionPbx>('XCBuildConfiguration');

  if (section == null) {
    CreateFlavorExit.notFound(message: "XCBuildConfiguration section not found");
  } else {
    final configurations = section.childrenList;
    for (var configuration in configurations) {
      if (configuration is MapPbx) {
        final buildSettings = configuration.find<MapPbx>('buildSettings');
        if (buildSettings == null) {
          CreateFlavorExit.notFound(message: "buildSettings not found");
        } else {
          if (buildSettings.find('TARGETED_DEVICE_FAMILY') != null) {
            buildSettings.remove('TARGETED_DEVICE_FAMILY');
            buildSettings.add(MapEntryPbx('TARGETED_DEVICE_FAMILY', VarPbx(formatDeviceFamily(targetDeviceFamily))));
            print("Set TARGETED_DEVICE_FAMILY to $targetDeviceFamily in ${configuration.comment}");
          } else {
            CreateFlavorExit.notFound(message: "TARGETED_DEVICE_FAMILY not found for ${configuration.comment}");
          }
        }
      }
    }
  }

  await project.save();
}
