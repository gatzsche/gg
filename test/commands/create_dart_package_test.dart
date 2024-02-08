// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:aud/src/commands/create_dart_package.dart';
import 'package:aud/src/licenses/open_source_licence.dart';
import 'package:aud/src/licenses/private_license.dart';
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
          'aud_test',
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
      final tempPackageDir = Directory(join(tempDir.path, 'aud_test'));

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
          'aud_test',
        ]),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            'Exception: The directory "${tempDir.path}/aud_test" already '
                'exists.',
          ),
        ),
      );

      // Delete the temporary directory
      tempPackageDir.deleteSync(recursive: true);
    });

    // #########################################################################
    test(
        'should throw when the package is not open source '
        'and the name does not start with "aud_"', () {
      // Expect throws exception
      expect(
        r.run([
          'createDartPackage',
          '-o',
          tempDir.path,
          '-n',
          'xyz_test',
          '--no-open-source',
        ]),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            'Exception: Non open source packages should start with "aud_"',
          ),
        ),
      );
    });

    // #########################################################################
    test(
        'should throw when the package is open source '
        'and the name does not start with "gg_"', () {
      // Expect throws exception
      expect(
        r.run([
          'createDartPackage',
          '-o',
          tempDir.path,
          '-n',
          'xyz_test',
          '--open-source',
        ]),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            'Exception: Open source packages should start with "gg_"',
          ),
        ),
      );
    });

    // #########################################################################
    test('should create a private dart package', () async {
      // Create a temporary directory
      final tempPackageDir = Directory(join(tempDir.path, 'aud_test'));

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
        'aud_test',
      ]);

      // The package should exist
      expect(tempPackageDir.existsSync(), true);

      // The package should contain a lib directory
      expect(Directory(join(tempPackageDir.path, 'lib')).existsSync(), true);

      // The package should contain a test directory
      expect(Directory(join(tempPackageDir.path, 'test')).existsSync(), true);

      // The package should contain a pubspec.yaml file
      expect(
        File(join(tempPackageDir.path, 'pubspec.yaml')).existsSync(),
        true,
      );

      // The package should contain a .gitignore file
      expect(File(join(tempPackageDir.path, '.gitignore')).existsSync(), true);

      // The package should contain a .vscode directory
      expect(
        Directory(join(tempPackageDir.path, '.vscode')).existsSync(),
        true,
      );

      // .....................................................
      // The package should contain a .vscode/launch.json file
      expect(
        File(join(tempPackageDir.path, '.vscode', 'launch.json')).existsSync(),
        true,
      );

      // The package should contain a .vscode/settings.json file
      expect(
        File(join(tempPackageDir.path, '.vscode', 'settings.json'))
            .existsSync(),
        true,
      );

      // The package should contain a .vscode/tasks.json file
      expect(
        File(join(tempPackageDir.path, '.vscode', 'tasks.json')).existsSync(),
        true,
      );

      // The package should contain a .vscode/extensions.json file
      expect(
        File(join(tempPackageDir.path, '.vscode', 'extensions.json'))
            .existsSync(),
        true,
      );

      // .......................................................
      // The package should contain a analysis_options.yaml file
      expect(
        File(join(tempPackageDir.path, 'analysis_options.yaml')).existsSync(),
        true,
      );

      // ............................................
      // The package should contain a .gitignore file
      expect(File(join(tempPackageDir.path, '.gitignore')).existsSync(), true);

      // .............................................
      // The package should contain a private LICENSE file
      // because it is not open source
      expect(
        File(join(tempPackageDir.path, 'LICENSE')).readAsStringSync(),
        privateLicence,
      );

      // .................................
      // Package should contain the checks
      expect(File(join(tempPackageDir.path, 'check')).existsSync(), true);

      // ..............................
      // Delete the temporary directory
      tempPackageDir.deleteSync(recursive: true);
    });

    // #########################################################################
    test('should create open source dart package', () async {
      // Create a temporary directory
      final tempPackageDir = Directory(join(tempDir.path, 'gg_test'));

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
        'gg_test',
        '--open-source',
      ]);

      // The package should exist
      expect(tempPackageDir.existsSync(), true);

      // .............................................
      // The package should contain an open source LICENSE file
      // because it is not open source
      expect(
        File(join(tempPackageDir.path, 'LICENSE')).readAsStringSync(),
        openSourceLicense,
      );

      // Delete the temporary directory
      tempPackageDir.deleteSync(recursive: true);
    });
  });
}
