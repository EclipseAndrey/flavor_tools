import 'dart:io';

import 'package:flavor_tools/flavor_tools.dart';
import 'package:xml/xml.dart';
import 'package:xcode_parser/xcode_parser.dart';

String _findRunnerTargetUuid(Pbxproj project) {
  final map = project.find<MapPbx>('objects');
  final section = map?.find<SectionPbx>('PBXNativeTarget');
  if (section != null) {
    for (final child in section.childrenList) {
      if (child is MapPbx && child.comment == 'Runner') {
        return child.uuid;
      }
    }
  }
  return '97C146ED1CF9000F007C117D';
}

Future<void> createXcodeScheme({
  required Pbxproj project,
  required String flavor,
}) async {
  final String filePath = 'ios/Runner.xcodeproj/xcshareddata/xcschemes/$flavor.xcscheme';
  final String directoryPath = 'ios/Runner.xcodeproj/xcshareddata/xcschemes';
  final directory = Directory(directoryPath);
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }

  final runnerUuid = _findRunnerTargetUuid(project);

  XmlElement buildableReference() {
    return XmlElement(XmlName('BuildableReference'), [
      XmlAttribute(XmlName('BuildableIdentifier'), 'primary'),
      XmlAttribute(XmlName('BlueprintIdentifier'), runnerUuid),
      XmlAttribute(XmlName('BuildableName'), 'Runner.app'),
      XmlAttribute(XmlName('BlueprintName'), 'Runner'),
      XmlAttribute(XmlName('ReferencedContainer'), 'container:Runner.xcodeproj'),
    ]);
  }

  final debugConfig = '${BuildType.debug}-$flavor';
  final profileConfig = '${BuildType.profile}-$flavor';
  final releaseConfig = '${BuildType.release}-$flavor';
  const lldbInitFile = r'$(SRCROOT)/Flutter/ephemeral/flutter_lldbinit';

  final scheme = XmlElement(XmlName('Scheme'), [
    XmlAttribute(XmlName('LastUpgradeVersion'), '1600'),
    XmlAttribute(XmlName('version'), '1.7'),
  ], [
    // BuildAction
    XmlElement(XmlName('BuildAction'), [
      XmlAttribute(XmlName('parallelizeBuildables'), 'YES'),
      XmlAttribute(XmlName('buildImplicitDependencies'), 'YES'),
    ], [
      XmlElement(XmlName('BuildActionEntries'), [], [
        XmlElement(XmlName('BuildActionEntry'), [
          XmlAttribute(XmlName('buildForTesting'), 'YES'),
          XmlAttribute(XmlName('buildForRunning'), 'YES'),
          XmlAttribute(XmlName('buildForProfiling'), 'YES'),
          XmlAttribute(XmlName('buildForArchiving'), 'YES'),
          XmlAttribute(XmlName('buildForAnalyzing'), 'YES'),
        ], [
          buildableReference(),
        ]),
      ]),
    ]),
    // TestAction
    XmlElement(XmlName('TestAction'), [
      XmlAttribute(XmlName('buildConfiguration'), debugConfig),
      XmlAttribute(XmlName('selectedDebuggerIdentifier'), 'Xcode.DebuggerFoundation.Debugger.LLDB'),
      XmlAttribute(XmlName('selectedLauncherIdentifier'), 'Xcode.DebuggerFoundation.Launcher.LLDB'),
      XmlAttribute(XmlName('customLLDBInitFile'), lldbInitFile),
      XmlAttribute(XmlName('shouldUseLaunchSchemeArgsEnv'), 'YES'),
    ], [
      XmlElement(XmlName('Testables')),
    ]),
    // LaunchAction
    XmlElement(XmlName('LaunchAction'), [
      XmlAttribute(XmlName('buildConfiguration'), debugConfig),
      XmlAttribute(XmlName('selectedDebuggerIdentifier'), 'Xcode.DebuggerFoundation.Debugger.LLDB'),
      XmlAttribute(XmlName('selectedLauncherIdentifier'), 'Xcode.DebuggerFoundation.Launcher.LLDB'),
      XmlAttribute(XmlName('customLLDBInitFile'), lldbInitFile),
      XmlAttribute(XmlName('launchStyle'), '0'),
      XmlAttribute(XmlName('useCustomWorkingDirectory'), 'NO'),
      XmlAttribute(XmlName('ignoresPersistentStateOnLaunch'), 'NO'),
      XmlAttribute(XmlName('debugDocumentVersioning'), 'YES'),
      XmlAttribute(XmlName('debugServiceExtension'), 'internal'),
      XmlAttribute(XmlName('allowLocationSimulation'), 'YES'),
    ], [
      XmlElement(XmlName('BuildableProductRunnable'), [
        XmlAttribute(XmlName('runnableDebuggingMode'), '0'),
      ], [
        buildableReference(),
      ]),
      XmlElement(XmlName('CommandLineArguments'), [], [
        XmlElement(XmlName('CommandLineArgument'), [
          XmlAttribute(XmlName('argument'), '--dart-define=FLAVOR=$flavor'),
          XmlAttribute(XmlName('isEnabled'), 'YES'),
        ]),
        XmlElement(XmlName('CommandLineArgument'), [
          XmlAttribute(XmlName('argument'), '--flavor=$flavor'),
          XmlAttribute(XmlName('isEnabled'), 'YES'),
        ]),
      ]),
    ]),
    // ProfileAction
    XmlElement(XmlName('ProfileAction'), [
      XmlAttribute(XmlName('buildConfiguration'), profileConfig),
      XmlAttribute(XmlName('shouldUseLaunchSchemeArgsEnv'), 'YES'),
      XmlAttribute(XmlName('savedToolIdentifier'), ''),
      XmlAttribute(XmlName('useCustomWorkingDirectory'), 'NO'),
      XmlAttribute(XmlName('debugDocumentVersioning'), 'YES'),
    ], [
      XmlElement(XmlName('BuildableProductRunnable'), [
        XmlAttribute(XmlName('runnableDebuggingMode'), '0'),
      ], [
        buildableReference(),
      ]),
    ]),
    // AnalyzeAction
    XmlElement(XmlName('AnalyzeAction'), [
      XmlAttribute(XmlName('buildConfiguration'), debugConfig),
    ]),
    // ArchiveAction
    XmlElement(XmlName('ArchiveAction'), [
      XmlAttribute(XmlName('buildConfiguration'), releaseConfig),
      XmlAttribute(XmlName('revealArchiveInOrganizer'), 'YES'),
    ]),
  ]);

  final document = XmlDocument([
    XmlProcessing('xml', 'version="1.0" encoding="UTF-8"'),
    scheme,
  ]);

  final file = File(filePath);
  await file.writeAsString(document.toXmlString(pretty: true, indent: '   '));
  print('Created scheme file at $filePath');
}
