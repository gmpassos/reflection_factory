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

    test('with prefixed imports', () async {
      var packageRoot = _getPackageRootDirectory().path;

      _write(tempDir, 'pubspec.yaml', '''
name: reflection_factory_e2e
environment:
  sdk: '>=3.10.0 <4.0.0'
dependencies:
  reflection_factory:
    path: $packageRoot
dev_dependencies:
  build_runner: ^2.15.0
''');

      _write(tempDir, 'lib/other.dart', '''
class Other {
  int v;
  Other(this.v);
}

class Plain {
  int p;
  Plain(this.p);
}

enum Flavor { sweet, salty }
''');

      // `Other` and `Flavor` are reachable ONLY through the `o` prefix.
      // `Plain` is also imported unprefixed, so it must NOT be qualified.
      _write(tempDir, 'lib/foo.dart', '''
import 'package:reflection_factory/reflection_factory.dart';
import 'other.dart' as o;
import 'other.dart' show Plain;

part 'foo.reflection.g.dart';

@EnableReflection()
class Holder {
  o.Other? other;

  Plain? plain;

  List<o.Other>? many;

  Map<String, o.Other>? byName;

  o.Flavor? flavor;

  int count;

  Holder(this.count);

  o.Other? echo(o.Other? v) => v;
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
      expect(code, contains('o.Other'));
      expect(code, contains('o.Flavor'));
      expect(code, contains('Plain'));
      expect(code, isNot(contains('o.Plain')));
      expect(code, isNot(contains('o.int')));
      expect(code, isNot(contains('o.String')));

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
