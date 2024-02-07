// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:aud/src/commands/create_dart_package.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  final Directory tempDir = Directory.systemTemp;
  final logMessages = <String>[];
  void log(String message) {
    logMessages.add(message);
  }

  // ...........................................................................
  setUp(() {
    logMessages.clear();
  });

  // ...........................................................................
  final r = CommandRunner<dynamic>(
    'aud',
    'Our cli to manage many tasks about audanika software development.',
  )..addCommand(CreateDartPackage(log: log));

  // ...........................................................................

  group('CreateDartPackage', () {
    // #########################################################################
    test('should throw when target directory does not exist', () async {
      // Expect throws exception
      expectLater(
        r.run([
          'createDartPackage',
          '-o',
          'some unknown directory',
          '-n',
          'test_package',
        ]),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            'Exception: The directory "some unknown directory" does not exist.',
          ),
        ),
      );
    });

    // #########################################################################
    test('should throw when the package directory already exists', () {
      // Create a temporary directory
      final tempPackageDir = Directory(join(tempDir.path, 'test_package'));

      // delete the package directory
      if (tempPackageDir.existsSync()) {
        tempPackageDir.deleteSync(recursive: true);
      }

      // Create the package directory
      tempPackageDir.createSync();

      // Expect throws exception
      expect(
        r.run([
          'createDartPackage',
          '-o',
          tempDir.path,
          '-n',
          'test_package',
        ]),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            'Exception: The directory "${tempDir.path}/test_package" already '
                'exists.',
          ),
        ),
      );

      // Delete the temporary directory
      tempPackageDir.deleteSync(recursive: true);
    });

    // #########################################################################
    test('should create a dart package with the right name', () async {
      // Create a temporary directory
      final tempPackageDir = Directory(join(tempDir.path, 'test_package'));

      // delete the package directory
      if (tempPackageDir.existsSync()) {
        tempPackageDir.deleteSync(recursive: true);
      }

      // Expect does not throw exception
      await r.run([
        'createDartPackage',
        '-o',
        tempDir.path,
        '-n',
        'test_package',
      ]);

      // The package should exist
      expect(tempPackageDir.existsSync(), true);

      // Delete the temporary directory
      tempPackageDir.deleteSync(recursive: true);
    });
  });
}
