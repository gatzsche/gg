// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:aud/src/licenses/open_source_licence.dart';
import 'package:aud/src/licenses/private_license.dart';
import 'package:aud/tools.dart';
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

    // Add the isOpenSource option
    argParser.addFlag(
      'open-source',
      abbr: 's',
      help: 'Is the package open source?',
      negatable: true,
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
    final isOpenSource = argResults?['open-source'] as bool;

    final updatedOutputDir = outputDir.replaceAll('~', homeDirectory);

    await _CreateDartPackage(
      outputDir: updatedOutputDir,
      packageDir: join(updatedOutputDir, packageName),
      packageName: packageName,
      log: log,
      isOpenSource: isOpenSource,
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
    required this.isOpenSource,
  });

  final String outputDir;
  final String packageDir;
  final String packageName;
  final void Function(String message)? log;
  final bool isOpenSource;

  // ...........................................................................
  Future<void> run() async {
    _checkDirectories();
    _checkPackageName();
    await _createPackage();
    _copyVsCodeSettings();
    _copyOverGitIgnore();
    _copyOverAnalysisOptions();
    _copyOverLicense();

    // Setup checks
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
  void _checkDirectories() {
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
  void _checkPackageName() {
    if (isOpenSource && !packageName.startsWith('gg_')) {
      throw Exception('Open source packages should start with "gg_"');
    }

    if (!isOpenSource && !packageName.startsWith('aud_')) {
      throw Exception('Non open source packages should start with "aud_"');
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
  void _copyVsCodeSettings() {
    // Copy over VScode which are located in project/.vscode
    final vscodeDir = join(audCliDirectory(), '.vscode');
    final targetVscodeDir = join(packageDir, '.vscode');
    _copyDirectory(vscodeDir, targetVscodeDir);
  }

  // ...........................................................................
  void _copyDirectory(String source, String target) {
    Directory(target).createSync(recursive: true);
    final content = Directory(source).listSync(recursive: true);
    for (var entity in content) {
      if (entity is Directory) {
        Directory(join(target, basename(entity.path))) // coverage:ignore-line
            .createSync(recursive: true); // coverage:ignore-line
      } else if (entity is File) {
        entity.copySync(join(target, basename(entity.path)));
      }
    }
  }

  // ...........................................................................
  void _copyFile(String source, String target) {
    File(source).copySync(target);
  }

  // ...........................................................................
  void _copyOverGitIgnore() {
    _copyFile(
      join(audCliDirectory(), '.gitignore'),
      join(packageDir, '.gitignore'),
    );
  }

  // ...........................................................................
  void _copyOverAnalysisOptions() {
    _copyFile(
      join(audCliDirectory(), 'analysis_options.yaml'),
      join(packageDir, 'analysis_options.yaml'),
    );
  }

  // ...........................................................................
  void _copyOverLicense() {
    final license = (isOpenSource ? openSourceLicense : privateLicence)
        .replaceAll('YEAR', DateTime.now().year.toString());

    File(join(packageDir, 'LICENSE')).writeAsStringSync(license);
  }
}
