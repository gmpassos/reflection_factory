@TestOn('vm')
library;

import 'dart:io';

import 'package:path/path.dart' as pack_path;
import 'package:reflection_factory/inspector.dart';
import 'package:reflection_factory/reflection_factory.dart';
import 'package:test/test.dart';

void main() {
  group('ReflectionInspector', () {
    setUp(() {});

    test('basic', () async {
      var packDir = _getPackageRootDirectory();
      _touchGeneratedFiles(packDir, includeTestFiles: false);

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
      _touchGeneratedFiles(packDir, includeTestFiles: true);

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

    test('expired reflection: by time and by version', () {
      var dir = Directory.systemTemp.createTempSync('reflection_inspector_');
      addTearDown(() => dir.deleteSync(recursive: true));

      File write(String path, String content) =>
          File(pack_path.join(dir.path, path))
            ..parent.createSync(recursive: true)
            ..writeAsStringSync(content);

      String source(String name) =>
          "import 'package:reflection_factory/reflection_factory.dart';\n"
          "part '$name.reflection.g.dart';\n"
          '@EnableReflection()\n'
          'class ${name.toUpperCase()} {}\n';

      String generated(String name, String version) =>
          '// BUILDER: reflection_factory/$version\n'
          "part of '$name.dart';\n";

      var a = write('lib/a.dart', source('a'));
      var aGen = write(
        'lib/a.reflection.g.dart',
        generated('a', ReflectionFactory.VERSION),
      );
      var b = write('lib/b.dart', source('b'));
      var bGen = write('lib/b.reflection.g.dart', generated('b', '1.0.0'));

      var t = DateTime.now().subtract(Duration(hours: 1));

      // Generated after their sources:
      a.setLastModifiedSync(t);
      aGen.setLastModifiedSync(t.add(Duration(minutes: 1)));
      b.setLastModifiedSync(t);
      bGen.setLastModifiedSync(t.add(Duration(minutes: 1)));

      List<String> expired() =>
          ReflectionInspector(dir).dartFilesWithExpiredReflection
              .map((f) => pack_path.basename(f.path))
              .toList();

      // `b.reflection.g.dart` is from another version:
      expect(expired(), equals(['b.dart']));

      // `a.dart` changed after its reflection was generated:
      a.setLastModifiedSync(t.add(Duration(minutes: 2)));
      expect(expired(), unorderedEquals(['a.dart', 'b.dart']));
    });
  });
}

/// Gives the generated reflection files the current time: in a fresh
/// checkout (CI) the files' times only reflect the order `git` wrote them in,
/// so a source can look newer than its generated file. The generated files
/// are checked by version only (see the 'expired reflection' test for time).
void _touchGeneratedFiles(Directory packDir, {required bool includeTestFiles}) {
  var now = DateTime.now();
  var inspector = ReflectionInspector(
    packDir,
    includeTestFiles: includeTestFiles,
  );
  for (var f in inspector.generatedDartFiles) {
    f.setLastModifiedSync(now);
  }
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
