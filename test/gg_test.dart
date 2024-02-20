// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:async';

import 'package:gg/src/gg.dart';
import 'package:test/test.dart';

void main() {
  final expectedCommands = ['cp', 'cc', 'help'];

  // ...........................................................................
  final messages = <String>[];
  final zoneSpecification = ZoneSpecification(
    print: (_, __, ___, String msg) {
      messages.add(msg);
    },
  );

  // ...........................................................................
  setUp(() {
    messages.clear();
  });

  // ...........................................................................
  Future<void> exec(List<String> args) async {
    // Capture the print output
    Zone.current.fork(specification: zoneSpecification).run(() async {
      // Run the command
      await gg(
        arguments: args,
        log: print,
      );
    });
  }

  group('aud', () {
    // #########################################################################
    test('invalidCommand should not work', () async {
      await exec(['invalidCommand']);
      expect(
        messages.last,
        contains('Could not find a command named "invalidCommand"'),
      );
    });

    // #########################################################################
    test('should contain all expected commands', () async {
      await exec([]);
      for (final command in expectedCommands) {
        expect(messages.last, contains(command));
      }
    });
  });
}
