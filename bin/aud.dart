#!/usr/bin/env dart
// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_cli/src/aud_cli.dart';

// #############################################################################
Future<void> main(List<String> arguments) async {
  await audCli(arguments: arguments, log: print);
}
