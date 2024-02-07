// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_cli/src/create_package.dart';
import 'package:test/test.dart';

void main() {
  group('createPackage', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('should create a package', () {
      expect(Awesome.isAwesome, isTrue);
    });
  });
}
