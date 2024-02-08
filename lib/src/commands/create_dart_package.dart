// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:aud/src/snippets/base_dart.dart';
import 'package:aud/src/snippets/file_header.dart';
import 'package:aud/src/snippets/open_source_licence.dart';
import 'package:aud/src/snippets/private_license.dart';
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

    // Add the package name option
    argParser.addOption(
      'description',
      abbr: 'd',
      help: 'Package description. Minimum 60 chars long.',
      mandatory: true,
    );

    // Add the isOpenSource option
    argParser.addFlag(
      'open-source',
      abbr: 's',
      help: 'Is the package open source?',
      negatable: true,
    );

    // Add the push repo option
    argParser.addFlag(
      'push',
      abbr: 'p',
      help: 'Pushes the repository to GitHub at the end.',
      negatable: true,
      defaultsTo: false,
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
    final description = (argResults?['description'] as String).trim();

    var homeDirectory = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ?? // coverage:ignore-line
        ''; // coverage:ignore-line
    final isOpenSource = argResults?['open-source'] as bool;
    final pushToGitHub = argResults?['push'] as bool;

    final updatedOutputDir = outputDir.replaceAll('~', homeDirectory);

    await _CreateDartPackage(
      outputDir: updatedOutputDir,
      packageDir: join(updatedOutputDir, packageName),
      packageName: packageName,
      description: description,
      log: log,
      isOpenSource: isOpenSource,
      pushToGitHub: pushToGitHub,
    ).run();
  }
}

// #############################################################################
class _CreateDartPackage {
  _CreateDartPackage({
    required this.outputDir,
    required this.packageDir,
    required this.packageName,
    required this.description,
    required this.log,
    required this.isOpenSource,
    required this.pushToGitHub,
  });

  final String outputDir;
  final String packageDir;
  final String packageName;
  final String description;
  final void Function(String message)? log;
  final bool isOpenSource;
  final bool pushToGitHub;
  static const gitHubRepo = 'https://github.com/inlavigo';

  // ...........................................................................
  Future<void> run() async {
    _checkDirectories();
    _checkPackageName();
    _checkDescription();
    await _checkGithubOrigin();
    await _createPackage();
    _copyVsCodeSettings();
    _copyGitIgnore();
    _copyAnalysisOptions();
    _copyLicense();
    _copyChecks();
    _copyGitHubActions();
    _preparePubspec();
    _prepareReadme();
    _prepareChangeLog();
    _installDependencies();
    _prepareBaseDart();
    _fixErrorsAndWarnings();
    _initGit();
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
  void _checkDescription() {
    if (description.length < 60) {
      throw Exception('The description must be at least 60 characters long.');
    }
  }

  // ...........................................................................
  Future<void> _checkGithubOrigin() async {
    if (!pushToGitHub) return;

    final repo = 'git@github.com:inlavigo/$packageName.git';

    final result = await Process.run(
      'git',
      ['ls-remote', repo, 'origin'],
      workingDirectory: outputDir,
    );

    if (result.exitCode == 128) {
      throw Exception(
        'The github repository "$repo" does not exist. '
        'Please visit "https://github.com/inlavigo" and create the repository.',
      );
    } else if (result.exitCode != 0) {
      throw Exception('Error while running "git ls-remote $repo origin".\n'
          'Exit code: ${result.exitCode}\n'
          'Error: ${result.stderr}\n');
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
        Directory(join(target, basename(entity.path)))
            .createSync(recursive: true);
      } else if (entity is File) {
        final relativePath = relative(entity.path, from: source);
        final targetPath = join(target, relativePath);

        entity.copySync(targetPath);
      }
    }
  }

  // ...........................................................................
  void _copyFile(String source, String target) {
    File(source).copySync(target);
  }

  // ...........................................................................
  void _copyGitIgnore() {
    _copyFile(
      join(audCliDirectory(), '.gitignore'),
      join(packageDir, '.gitignore'),
    );
  }

  // ...........................................................................
  void _copyAnalysisOptions() {
    _copyFile(
      join(audCliDirectory(), 'analysis_options.yaml'),
      join(packageDir, 'analysis_options.yaml'),
    );
  }

  // ...........................................................................
  void _copyLicense() {
    final license = (isOpenSource ? openSourceLicense : privateLicence)
        .replaceAll('YEAR', DateTime.now().year.toString());

    File(join(packageDir, 'LICENSE')).writeAsStringSync(license);
  }

  // ...........................................................................
  void _copyChecks() {
    // Get all files in the aud_cli directory starting with check
    final audCliDir = audCliDirectory();
    final files = Directory(join(audCliDir))
        .listSync()
        .whereType<File>()
        .map((e) => relative(e.path, from: audCliDir));

    // Copy over file
    final checkFiles = files
        .where(
          (item) => relative(item, from: audCliDirectory()).startsWith('check'),
        )
        .toList();

    for (final file in checkFiles) {
      final sourceFile = File(join(audCliDir, file));
      final targetFile = join(packageDir, basename(file));
      sourceFile.copySync(targetFile);
    }
  }

  // ...........................................................................
  void _copyGitHubActions() {
    // Copy over GitHub Actions
    final githubActionsDir = join(audCliDirectory(), '.github');
    final targetGitHubActionsDir = join(packageDir, '.github');
    _copyDirectory(githubActionsDir, targetGitHubActionsDir);
  }

  // ...........................................................................
  void _replaceInFile(String file, String search, String replace) {
    final content = File(file).readAsStringSync();

    // Check if the search string is in the file
    final pattern = RegExp(search, multiLine: true);
    if (!pattern.hasMatch(content)) {
      throw Exception('Search string "$search" not found in file "$file"');
    }

    final updatedContent = content.replaceAll(pattern, replace);
    File(file).writeAsStringSync(updatedContent);
  }

  // ...........................................................................
  void _preparePubspec() {
    final pubspecFile = join(packageDir, 'pubspec.yaml');

    // Write repository into file
    _replaceInFile(
      pubspecFile,
      r'^#\srepository:.*',
      'repository: $gitHubRepo/$packageName',
    );

    // Update description
    _replaceInFile(
      pubspecFile,
      r'^description:.*',
      'description: $description',
    );
  }

  // ...........................................................................
  void _prepareReadme() {
    final readmeFile = join(packageDir, 'README.md');
    String content = '';
    content += '# $packageName\n\n';
    content += '$description\n';
    File(readmeFile).writeAsStringSync(content);
  }

  // ...........................................................................
  void _prepareChangeLog() {
    final changeLogFile = File(join(packageDir, 'CHANGELOG.md'));
    String content = '';
    content += '# Change Log\n\n';
    content += '## 1.0.0\n\n';
    content += '- Initial version.\n';
    changeLogFile.writeAsStringSync(content);
  }

  // ...........................................................................
  void _installDependencies() {
    // Execute "dart pub add --dev args coverage pana yaml"
    final result = Process.runSync(
      'dart',
      ['pub', 'add', '--dev', 'args', 'coverage', 'pana', 'yaml'],
      workingDirectory: packageDir,
    );
    if (result.exitCode != 0) {
      throw Exception(
        'Error while running "dart pub add --dev args coverage pana yaml"',
      );
    }
  }

  // ...........................................................................
  void _prepareBaseDart() {
    final baseDart = join(packageDir, 'lib', 'src', '${packageName}_base.dart');
    final content = '$fileHeader\n\n$baseDartSnippet\n';
    File(baseDart).writeAsStringSync(content);
  }

  // ...........................................................................
  void _fixErrorsAndWarnings() {
    // Execute dart fix
    final result = Process.runSync(
      'dart',
      ['fix', '--apply', packageDir],
    );

    if (result.exitCode != 0) {
      throw Exception('Error while running dart fix');
    }

    // Execute dart analyze
    final result2 = Process.runSync(
      'dart',
      ['analyze', packageDir],
    );
    if (result2.exitCode != 0) {
      throw Exception(
        'Error while running dart analyze:\n'
        '${result2.stderr}\n'
        '${result2.stdout}\n'
        'Please adapt "create_dart_package.dart" to fix the issues.',
      );
    }
  }

  // ...........................................................................
  void _initGit() {
    // Execute git init
    final result = Process.runSync(
      'git',
      ['init'],
      workingDirectory: packageDir,
    );

    if (result.exitCode != 0) {
      throw Exception('Error while running git init');
    }

    // Execute git branch -M main
    final result2 = Process.runSync(
      'git',
      ['branch', '-M', 'main'],
      workingDirectory: packageDir,
    );

    if (result2.exitCode != 0) {
      throw Exception('Error while running git branch -M main');
    }

    // Execute git config advice.addIgnoredFile false
    final result3 = Process.runSync(
      'git',
      ['config', 'advice.addIgnoredFile', 'false'],
      workingDirectory: packageDir,
    );

    if (result3.exitCode != 0) {
      throw Exception(
        'Error while running git config advice.addIgnoredFile false',
      );
    }

    // Execute git add *
    final result4 = Process.runSync(
      'git',
      ['add', '*'],
      workingDirectory: packageDir,
    );

    if (result4.exitCode != 0) {
      throw Exception('Error while running git add *');
    }

    // Execute git commit -m"Initial boylerplate"
    final result5 = Process.runSync(
      'git',
      ['commit', '-m"Initial boylerplate"'],
      workingDirectory: packageDir,
    );

    if (result5.exitCode != 0) {
      throw Exception('Error while running git commit -m"Initial boylerplate"');
    }

    // Push repo to GitHub
    if (pushToGitHub) {
      final result6 = Process.runSync(
        'git',
        ['remote', 'add', 'origin', '$gitHubRepo/$packageName.git'],
        workingDirectory: packageDir,
      );

      if (result6.exitCode != 0) {
        throw Exception(
          'Error while running git remote add origin $gitHubRepo/$packageName.git',
        );
      }

      final result7 = Process.runSync(
        'git',
        ['push', '-u', 'origin', 'main'],
        workingDirectory: packageDir,
      );

      if (result7.exitCode != 0) {
        throw Exception('Error while running git push -u origin main');
      }
    }
  }
}
