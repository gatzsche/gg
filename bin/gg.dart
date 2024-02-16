#!/usr/bin/env dart
// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:gg/src/gg.dart';

// #############################################################################
Future<void> main(List<String> arguments) async {
  await gg(arguments: arguments, log: print);
}
