@TestOn('vm')
@Tags(['build', 'slow', 'e2e'])
library;

import 'dart:io';

import 'package:path/path.dart' as pack_path;
import 'package:test/test.dart';

/// End-to-end check that generated code actually *compiles*.
///
/// `testBuilder` only asserts on the generated text: it never resolves the
/// generated part against the input library's scope. Bugs where the emitted
/// code is well-formed Dart but does not resolve -- an unqualified type name
/// from a prefixed import, for example -- pass a text assertion and still
/// break every consumer.
///
/// So this builds a throwaway package with `reflection_factory` as a path
/// dependency, runs the real builder over it, and runs `dart analyze` on the
/// result.
void main() {
  group('generated code compiles', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('reflection_factory_e2e_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('with every kind of import', () async {
      var packageRoot = _getPackageRootDirectory().path;

      _write(tempDir, 'pubspec.yaml', '''
name: reflection_factory_e2e
environment:
  sdk: '>=3.10.0 <4.0.0'
dependencies:
  reflection_factory:
    path: $packageRoot
  mime: ^2.0.0
dev_dependencies:
  build_runner: ^2.15.0
''');

      _write(tempDir, 'lib/plain.dart', '''
class PlainA {
  int a;
  PlainA(this.a);
}

class PlainB {
  int b;
  PlainB(this.b);
}
''');

      _write(tempDir, 'lib/shown.dart', '''
class ShownOnly {
  int s;
  ShownOnly(this.s);
}

class NotShown {
  int n;
  NotShown(this.n);
}
''');

      _write(tempDir, 'lib/deep.dart', '''
class Deep {
  int d;
  Deep(this.d);
}
''');

      _write(tempDir, 'lib/facade.dart', '''
export 'deep.dart';

class Facade {
  int f;
  Facade(this.f);
}
''');

      _write(tempDir, 'lib/other.dart', '''
class Other {
  int v;
  Other(this.v);
}

class Hidden {
  int h;
  Hidden(this.h);
}

enum Flavor { sweet, salty }
''');

      // Every way a type can be reached from the input library:
      //   unprefixed  -> `plain.dart`, `shown.dart` (show), `other.dart` (hide)
      //   declared    -> `Local`
      //   prefixed    -> `other.dart` (o), `facade.dart` (f), `package:mime`
      //   re-exported -> `Deep`, reached through the prefixed `facade.dart`
      _write(tempDir, 'lib/foo.dart', '''
import 'package:reflection_factory/reflection_factory.dart';
import 'package:mime/mime.dart' as mime;

import 'plain.dart';
import 'shown.dart' show ShownOnly;
import 'facade.dart' as f;
import 'other.dart' as o;
import 'other.dart' hide Other, Flavor;

part 'foo.reflection.g.dart';

class Local {
  int l;
  Local(this.l);
}

@EnableReflection()
class Holder<T extends o.Other> {
  int count;
  String label;
  PlainA? plainA;
  PlainB? plainB;
  ShownOnly? shown;
  Local? local;
  Hidden? hidden;

  o.Other? other;
  o.Flavor? flavor;
  f.Deep? deep;
  f.Facade? facade;
  mime.MimeTypeResolver? resolver;

  List<o.Other>? many;
  Map<String, o.Other>? byName;
  Map<PlainA, List<f.Deep>>? nested;
  T? bounded;

  Holder(this.count, this.label);

  o.Other? echo(o.Other? v, PlainA? p) => v;
}
''');

      await _run('dart', ['pub', 'get'], tempDir);

      await _run('dart', ['run', 'build_runner', 'build'], tempDir);

      var generated = File(
        pack_path.join(tempDir.path, 'lib', 'foo.reflection.g.dart'),
      );
      expect(generated.existsSync(), isTrue, reason: 'no generated output');

      var code = generated.readAsStringSync();

      // Asserted explicitly as well as compiled, so a failure says *what* went
      // wrong instead of only that analysis failed.
      for (var qualified in [
        'o.Other',
        'o.Flavor',
        'f.Deep',
        'f.Facade',
        'mime.MimeTypeResolver',
      ]) {
        expect(code, contains(qualified), reason: 'missing $qualified');
      }

      for (var unqualified in [
        'PlainA',
        'PlainB',
        'ShownOnly',
        'Local',
        'Hidden',
      ]) {
        expect(code, contains(unqualified), reason: 'missing $unqualified');
      }

      // Nothing reachable unprefixed may pick up a prefix.
      for (var wrong in [
        'o.PlainA',
        'o.Hidden',
        'o.Local',
        'f.PlainA',
        'o.int',
        'o.String',
        'mime.int',
      ]) {
        expect(code, isNot(contains(wrong)), reason: 'wrongly emitted $wrong');
      }

      var analyze = await _run(
        'dart',
        ['analyze'],
        tempDir,
        expectSuccess: false,
      );

      expect(
        analyze.exitCode,
        equals(0),
        reason:
            'the generated code does not compile:\n'
            '${analyze.stdout}\n${analyze.stderr}',
      );
    }, timeout: Timeout(Duration(minutes: 5)));
  });
}

void _write(Directory root, String relativePath, String content) {
  var file = File(pack_path.join(root.path, relativePath));
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(content);
}

Future<ProcessResult> _run(
  String executable,
  List<String> arguments,
  Directory workingDirectory, {
  bool expectSuccess = true,
}) async {
  var result = await Process.run(
    executable,
    arguments,
    workingDirectory: workingDirectory.path,
    runInShell: true,
  );

  if (expectSuccess && result.exitCode != 0) {
    fail(
      '`$executable ${arguments.join(' ')}` failed '
      '(exit ${result.exitCode}):\n${result.stdout}\n${result.stderr}',
    );
  }

  return result;
}

Directory _getPackageRootDirectory() {
  var refFile = 'test/reflection_factory_generated_code_test.dart';

  for (var p in [
    '.',
    '..',
    './reflection_factory',
    '../reflection_factory',
    '../../reflection_factory',
  ]) {
    var file = File('$p/$refFile');

    if (file.existsSync()) {
      return file.absolute.parent.parent;
    }
  }

  return Directory.current.absolute;
}
