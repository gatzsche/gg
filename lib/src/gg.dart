#!/usr/bin/env dart
// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:args/command_runner.dart';
import 'package:aud_cli_gc/aud_cli_gc.dart';
import 'package:colorize/colorize.dart';
import 'package:gg_check/gg_check.dart';
import 'package:gg_cli_cp/create_dart_package.dart';

// #############################################################################
/// Creates the Audanika developer command line
Future<void> gg({
  required List<String> arguments,
  required void Function(Object msg) log,
}) async {
  try {
    final r = CommandRunner<dynamic>(
      'aud',
      'Our cli to manage many tasks about audanika software development.',
    )
      ..addCommand(CreatePackage(log: log))
      ..addCommand(GenerateCode(log: log))
      ..addCommand(GgCheck(log: log));

    await r.run(arguments);
  } catch (e) {
    final msg = e.toString().replaceAll('Exception: ', '');
    log(Colorize(msg).red());
  }
}
