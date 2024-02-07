// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:args/command_runner.dart';
import 'package:aud/commands.dart';

// #############################################################################
Future<void> main(List<String> arguments) async {
  try {
    final r = CommandRunner<dynamic>(
      'aud',
      'Our cli to manage many tasks about audanika software development.',
    )..addCommand(CreateDartPackage());

    await r.run(arguments);
  } catch (e) {
    print(e);
  }
}
