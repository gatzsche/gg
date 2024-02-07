// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart';

/// Creates a new package in the given directory.
class CreateDartPackage extends Command<dynamic> {
  /// The name of the package
  @override
  final name = 'createDartPackage';

  /// The description shown when running `aud help createDartPackage`.
  @override
  final description = 'Creates a new dart package for our repository';

  /// Constructor
  CreateDartPackage({
    this.log,
  }) {
    // Add the output option
    argParser.addOption(
      'output',
      abbr: 'o',
      help: 'Output directory',
      defaultsTo: '.',
    );

    // Add the package name option
    argParser.addOption(
      'name',
      abbr: 'n',
      help: 'Package name',
      mandatory: true,
    );
  }
  // ...........................................................................
  /// The log function
  final void Function(String message)? log;

  // ...........................................................................
  /// Runs the command
  @override
  void run() async {
    // Get the output directory
    final outputDir = (argResults?['output'] as String).trim();
    final packageName = (argResults?['name'] as String).trim();
    var homeDirectory = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ?? // coverage:ignore-line
        ''; // coverage:ignore-line

    final updatedOutputDir = outputDir.replaceAll('~', homeDirectory);

    await _CreateDartPackage(
      outputDir: updatedOutputDir,
      packageDir: join(updatedOutputDir, packageName),
      packageName: packageName,
      log: log,
    ).run();
  }
}

// #############################################################################
class _CreateDartPackage {
  _CreateDartPackage({
    required this.outputDir,
    required this.packageDir,
    required this.packageName,
    required this.log,
  });

  final String outputDir;
  final String packageDir;
  final String packageName;
  final void Function(String message)? log;

  // ...........................................................................
  Future<void> run() async {
    _check();
    await _createPackage();

    // Copy over VScode settings
    // Copy over .gitignore
    // Copy over analysis options
    // Setup checks
    // Copy LICENSE
    // Add GitHub Pipeline
    // Replace URL in pubspec.yaml
    // Init README.md
    // Init CHANGELog.md
    // Fix all errors and warnings
    // Add missing comments
    // Init git
    // Connect the project to GitHub
    // Push the changes to GitHub
  }

  // ...........................................................................
  void _check() {
    // Target dir exists?
    if (!Directory(outputDir).existsSync()) {
      throw Exception('The directory "$outputDir" does not exist.');
    }

    // Package already exists?
    final packageDir = join(outputDir, packageName);
    if (Directory(packageDir).existsSync()) {
      throw Exception('The directory "$packageDir" already exists.');
    }
  }

  // ...........................................................................
  Future<void> _createPackage() async {
    // .......................
    // Create the dart package
    // Step 2: Create a new Dart package named `aud`
    final result = await Process.run(
      'dart',
      ['create', '-t', 'package', packageName, '--no-pub'],
      workingDirectory: outputDir,
    );

    // Log result
    if (result.stderr != null && (result.stderr as String).isNotEmpty) {
      log?.call(result.stderr as String); // coverage:ignore-line
    }

    if (result.stdout != null && (result.stdout as String).isNotEmpty) {
      log?.call(result.stdout as String);
    }
  }

  // ...........................................................................
  Future<void> _copyVsCodeSettings() async {
    // Copy over VScode which are located in project/.vscode
    final vscodeDir = join(packageDir, '.vscode');
  }
}
