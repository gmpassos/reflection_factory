@TestOn('vm')
@Tags(['build'])
library;

import 'dart:io';

import 'package:dart_style/dart_style.dart' show DartFormatter;
import 'package:path/path.dart' as pack_path;
import 'package:pub_semver/pub_semver.dart' show Version;
import 'package:test/test.dart';

/// The generated `*.reflection.g.dart` is formatted by [DartFormatter], using
/// the `dart_style` version that `pub` resolves for **this** package, while the
/// consumers of the generated code check it with the `dart format` bundled in
/// **their** Dart SDK.
///
/// `dart_style` does not guarantee identical output across its own versions:
/// some style fixes are explicitly "not language versioned and apply to all
/// formatted code" (see the `dart_style` 3.1.10 CHANGELOG, which fixed the
/// eager-splitting of an argument list containing a collection literal).
///
/// When the 2 versions disagree, a consumer that runs both
/// `dart format --set-exit-if-changed` and a "the build is up to date" check
/// (`build_verify`) can't satisfy both at once: committing the generator output
/// fails the format check, and committing the formatted output fails the build
/// check, because `build_runner` rewrites the file back.
///
/// That is why `dart_style` has an upper bound in `pubspec.yaml`. This test
/// guards it: if a `dart_style` upgrade starts producing output that the SDK's
/// `dart format` disagrees with, it fails here instead of failing in every
/// downstream package.
void main() {
  group('generated code formatting', () {
    late final List<File> generatedFiles;

    setUpAll(() {
      generatedFiles = _findGeneratedFiles(Directory.current);
    });

    test('the repository has generated files to check', () {
      // Guards the test below against silently passing over an empty list:
      expect(
        generatedFiles,
        isNotEmpty,
        reason:
            "No `*.g.dart` found. Run `dart run build_runner build` "
            "before this test.",
      );
    });

    test('is unchanged by the `dart format` of the Dart SDK', () async {
      var paths = generatedFiles.map((f) => f.path).toList();
      printOnFailure('Checking: $paths');

      var result = await Process.run('dart', [
        'format',
        '-o',
        'none',
        '--set-exit-if-changed',
        ...paths,
      ], workingDirectory: Directory.current.path);

      expect(
        result.exitCode,
        equals(0),
        reason:
            "The generated code is not formatted the way the `dart format` of "
            "the Dart SDK formats it.\n"
            "`DartFormatter` here uses `dart_style` "
            "${_resolvedDartStyleVersion() ?? '?'}, while `dart format` uses "
            "the `dart_style` bundled in the SDK: "
            "${await _sdkDartStyleVersion()}.\n"
            "Align the `dart_style` constraint of `pubspec.yaml` with the "
            "version bundled in the supported SDKs, then regenerate.\n"
            "stdout: ${result.stdout.toString().trim()}\n"
            "stderr: ${result.stderr.toString().trim()}",
      );
    });
  });

  group('DartFormatter vs the SDK `dart format`', () {
    // An argument list whose 3rd argument is a collection literal: this is the
    // shape that `dart_style` 3.1.10 changed the splitting of, and it is
    // exactly what the generated proxy code (`onCall`) looks like.
    //
    // The generated code is *not* checked here, only the formatters: the
    // repository's own `*.g.dart` may not happen to contain a shape that the 2
    // `dart_style` versions disagree on, so the check above can pass while a
    // downstream package with a proxy still breaks.
    const probeCode = '''
void f() {
  var ret = onCall(this, 'mapKeys', <String, dynamic>{
    'map': map,
  }, const TR<Future<List<String>>>(Future, <TR>[TR.tListString]));
  return retFut<List<String>>(ret);
}
''';

    test('agree on an argument list containing a collection literal', () async {
      var languageVersion = _packageLanguageVersion();
      printOnFailure('Package language version: $languageVersion');

      // What the generator would write:
      var byDartFormatter = DartFormatter(
        languageVersion: languageVersion,
      ).format(probeCode);

      // What `dart format` of the SDK would write. The probe file is created
      // inside this package, so `dart format` resolves the same language
      // version that is passed to [DartFormatter] above.
      var probeFile = File(
        pack_path.join(
          Directory.current.path,
          'test',
          '_format_probe.tmp.dart',
        ),
      );

      ProcessResult result;
      try {
        await probeFile.writeAsString(byDartFormatter);

        // `--set-exit-if-changed` is the check itself: exit code 0 means the
        // SDK's `dart format` would leave [DartFormatter]'s output untouched.
        // (Comparing the text of `--output=show` would also capture its
        // trailing "Formatted N files" summary line.)
        result = await Process.run('dart', [
          'format',
          '-o',
          'none',
          '--set-exit-if-changed',
          probeFile.path,
        ], workingDirectory: Directory.current.path);
      } finally {
        if (probeFile.existsSync()) probeFile.deleteSync();
      }

      expect(
        result.exitCode,
        equals(0),
        reason:
            "`DartFormatter` (`dart_style` "
            "${_resolvedDartStyleVersion() ?? '?'}) and the `dart format` of "
            "the Dart SDK (${await _sdkDartStyleVersion()}) format the same "
            "code differently, at language version $languageVersion.\n"
            "Any package that both format-checks and build-verifies the "
            "generated code will break. Align the `dart_style` constraint of "
            "`pubspec.yaml` with the version bundled in the supported SDKs.\n"
            "Formatted by `DartFormatter` as:\n$byDartFormatter",
      );
    });
  });
}

/// The language version of this package, from the `environment: sdk:` lower
/// bound of `pubspec.yaml`. This is the version `dart format` uses for the
/// files of this package, so [DartFormatter] must be given the same one.
Version _packageLanguageVersion() {
  var content = File('pubspec.yaml').readAsStringSync();

  var match = RegExp(r"sdk:\s*['\x22]?>=(\d+)\.(\d+)").firstMatch(content);

  if (match == null) {
    throw StateError("Can't resolve the SDK lower bound of `pubspec.yaml`");
  }

  return Version(int.parse(match.group(1)!), int.parse(match.group(2)!), 0);
}

/// Finds the generated `*.g.dart` files of this package, skipping the
/// build/tool directories.
List<File> _findGeneratedFiles(Directory root) {
  const skipDirs = {'.dart_tool', '.git', 'build', 'coverage'};

  var files = <File>[];

  for (var entity in root.listSync(recursive: true, followLinks: false)) {
    if (entity is! File) continue;

    var relative = pack_path.relative(entity.path, from: root.path);
    var parts = pack_path.split(relative);

    if (parts.any(skipDirs.contains)) continue;
    if (!relative.endsWith('.g.dart')) continue;

    files.add(entity);
  }

  files.sort((a, b) => a.path.compareTo(b.path));
  return files;
}

/// The `dart_style` version resolved for this package, read from
/// `pubspec.lock`. Returns `null` if it can't be determined.
String? _resolvedDartStyleVersion() {
  var lock = File('pubspec.lock');
  if (!lock.existsSync()) return null;

  var match = RegExp(
    r'\n  dart_style:\n(?:.*\n)*?    version: "([^"]+)"',
  ).firstMatch(lock.readAsStringSync());

  return match?.group(1);
}

/// The `dart_style` version bundled in the Dart SDK,
/// from `dart format --version`.
Future<String> _sdkDartStyleVersion() async {
  try {
    var result = await Process.run('dart', ['format', '--version']);
    return result.stdout.toString().trim();
  } catch (_) {
    return '?';
  }
}
