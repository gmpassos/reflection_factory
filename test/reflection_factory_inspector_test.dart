@TestOn('vm')
library;

import 'dart:io';

import 'package:path/path.dart' as pack_path;
import 'package:reflection_factory/inspector.dart';
import 'package:test/test.dart';

void main() {
  group('ReflectionInspector', () {
    setUp(() {});

    test('basic', () async {
      var packDir = _getPackageRootDirectory();

      var reflectionInspector = ReflectionInspector(packDir);

      print(reflectionInspector);

      expect(reflectionInspector.dartFiles.length > 5, isTrue);
      expect(reflectionInspector.generatedDartFiles.length >= 2, isTrue);

      expect(
        reflectionInspector.generatedDartFiles.length,
        equals(reflectionInspector.generatedDartFilesPaths.length),
      );

      expect(reflectionInspector.dartFilesWithExpiredReflection, isEmpty);
      expect(
        reflectionInspector.dartFilesMissingGeneratedReflection.length >= 2,
        isTrue,
      );
    });

    test('with tests', () async {
      var packDir = _getPackageRootDirectory();

      var reflectionInspector = ReflectionInspector(
        packDir,
        includeTestFiles: true,
      );

      print(reflectionInspector);

      expect(reflectionInspector.dartFiles.length > 5, isTrue);
      expect(reflectionInspector.generatedDartFiles.length >= 4, isTrue);

      expect(
        reflectionInspector.generatedDartFiles.length,
        equals(reflectionInspector.generatedDartFilesPaths.length),
      );

      expect(reflectionInspector.dartFilesWithExpiredReflection, isEmpty);
      expect(
        reflectionInspector.dartFilesMissingGeneratedReflection.length >= 3,
        isTrue,
      );
    });
  });
}

Directory _getPackageRootDirectory() {
  var refFile = 'test/reflection_factory_inspector_test.dart';

  for (var p in [
    '.',
    '..',
    './reflection_factory',
    '../reflection_factory',
    '../../reflection_factory',
  ]) {
    var file = File('$p/$refFile');

    if (file.existsSync()) {
      var rootDir = file.absolute.parent.parent;
      var parts = pack_path.split(rootDir.path).where((e) => e != '.').toList();
      var rootPath = pack_path.joinAll(parts);
      return Directory(rootPath);
    }
  }

  return Directory.current.absolute;
}
