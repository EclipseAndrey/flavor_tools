import 'dart:io';

import 'package:flavor_tools/flavor_tools.dart';

Future<void> createXcodeScheme({
  required String blueprintIdentifierProfile,
  required String blueprintIdentifierDebug,
  required String blueprintIdentifierRelease,
  required String flavor,
}) async {
  final String filePath = 'ios/Runner.xcodeproj/xcshareddata/xcschemes/$flavor.xcscheme';
  final String directoryPath = 'ios/Runner.xcodeproj/xcshareddata/xcschemes';
  final directory = Directory(directoryPath);
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }
  final File file = File(filePath);
  if (!await file.exists()) {
    await file.create();
  }

  final StringBuffer content = StringBuffer();
  content.writeln('<?xml version="1.0" encoding="UTF-8"?>');
  content.writeln('<Scheme LastUpgradeVersion = "1340" version = "1.3">');
  content.writeln('  <BuildAction parallelizeBuildables = "YES" buildImplicitDependencies = "YES">');
  content.writeln('    <BuildActionEntries>');
  content.writeln(
      '      <BuildActionEntry buildForTesting = "YES" buildForRunning = "YES" buildForProfiling = "YES" buildForArchiving = "YES" buildForAnalyzing = "YES">');
  content.writeln(
      '        <BuildableReference BuildableIdentifier = "primary" BlueprintIdentifier = "$blueprintIdentifierDebug" BuildableName = "Runner.app" BlueprintName = "Runner" ReferencedContainer = "container:Runner.xcodeproj"/>');
  content.writeln('      </BuildActionEntry>');
  content.writeln('    </BuildActionEntries>');
  content.writeln('  </BuildAction>');
  content.writeln(
      '  <TestAction buildConfiguration = "${BuildType.debug}-$flavor" selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv = "YES">');
  content.writeln('    <Testables></Testables>');
  content.writeln('  </TestAction>');
  content.writeln(
      '  <LaunchAction buildConfiguration = "${BuildType.debug}-$flavor" selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB" launchStyle = "0" useCustomWorkingDirectory = "NO" ignoresPersistentStateOnLaunch = "NO" debugDocumentVersioning = "YES" debugServiceExtension = "internal" allowLocationSimulation = "YES">');
  content.writeln('    <BuildableProductRunnable runnableDebuggingMode = "0">');
  content.writeln(
      '      <BuildableReference BuildableIdentifier = "primary" BlueprintIdentifier = "$blueprintIdentifierDebug" BuildableName = "Runner.app" BlueprintName = "Runner" ReferencedContainer = "container:Runner.xcodeproj"/>');
  content.writeln('    </BuildableProductRunnable>');
  content.writeln('    <CommandLineArguments>');
  content.writeln('      <CommandLineArgument argument = "--dart-define=FLAVOR=$flavor" isEnabled = "YES"/>');
  content.writeln('      <CommandLineArgument argument = "--flavor=$flavor" isEnabled = "YES"/>');
  content.writeln('    </CommandLineArguments>');
  content.writeln('  </LaunchAction>');
  content.writeln(
      '  <ProfileAction buildConfiguration = "${BuildType.profile}-$flavor" shouldUseLaunchSchemeArgsEnv = "YES" savedToolIdentifier = "" useCustomWorkingDirectory = "NO" debugDocumentVersioning = "YES">');
  content.writeln('    <BuildableProductRunnable runnableDebuggingMode = "0">');
  content.writeln(
      '      <BuildableReference BuildableIdentifier = "primary" BlueprintIdentifier = "$blueprintIdentifierProfile" BuildableName = "Runner.app" BlueprintName = "Runner" ReferencedContainer = "container:Runner.xcodeproj"/>');
  content.writeln('    </BuildableProductRunnable>');
  content.writeln('  </ProfileAction>');
  content.writeln('  <AnalyzeAction buildConfiguration = "${BuildType.debug}-$flavor"></AnalyzeAction>');
  content.writeln(
      '  <ArchiveAction buildConfiguration = "${BuildType.release}-$flavor" revealArchiveInOrganizer = "YES">');
  content.writeln('  </ArchiveAction>');
  content.writeln('</Scheme>');

  await file.writeAsString(content.toString());
  print('Created scheme file at $filePath');
}
