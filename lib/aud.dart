#!/usr/bin/env dart

import 'package:args/command_runner.dart';
import 'package:aud_cli/src/create_package.dart';

// #############################################################################
void main(List<String> arguments) {
  CommandRunner<dynamic>(
    'aud',
    'Our cli to manage many tasks about audanika software development.',
  )
    ..addCommand(CreatePackage())
    ..run(arguments);
}
