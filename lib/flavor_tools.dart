library;

import 'package:flavor_tools/runner_args.dart';

export 'package:flavor_tools/src/create_flavor/create_flavor.dart';

Future<void> flavorTools(List<String> arguments) async {
  await runnerArgs(arguments);
}
