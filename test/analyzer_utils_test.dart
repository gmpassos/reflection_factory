@TestOn('vm')
library;

import 'package:build/build.dart';
import 'package:reflection_factory/src/analyzer/utils.dart';
import 'package:test/test.dart';

void main() {
  group('computePartUrl', () {
    test('sibling output', () {
      expect(
        computePartUrl(
          AssetId('pkg', 'lib/foo.dart'),
          AssetId('pkg', 'lib/foo.g.dart'),
        ),
        equals('foo.g.dart'),
      );
    });

    test('output in sub directory', () {
      expect(
        computePartUrl(
          AssetId('pkg', 'lib/foo.dart'),
          AssetId('pkg', 'lib/gen/foo.g.dart'),
        ),
        equals('gen/foo.g.dart'),
      );
    });

    test('nested input', () {
      expect(
        computePartUrl(
          AssetId('pkg', 'lib/src/a/foo.dart'),
          AssetId('pkg', 'lib/src/a/foo.g.dart'),
        ),
        equals('foo.g.dart'),
      );
    });
  });

  group('normalizeDartUrl', () {
    test('strips extra path segments', () {
      expect(
        normalizeDartUrl(Uri.parse('dart:core/map.dart')).toString(),
        equals('dart:core'),
      );
    });

    test('keeps single segment', () {
      expect(
        normalizeDartUrl(Uri.parse('dart:async')).toString(),
        equals('dart:async'),
      );
    });

    test('empty path segments returns url unchanged', () {
      var url = Uri(scheme: 'dart', path: '');
      expect(normalizeDartUrl(url), equals(url));
    });
  });

  group('packageToAssetUrl', () {
    test('converts package: to asset:', () {
      expect(
        packageToAssetUrl(
          Uri.parse('package:source_gen/source_gen.dart'),
        ).toString(),
        equals('asset:source_gen/lib/source_gen.dart'),
      );
    });

    test('converts nested package path', () {
      expect(
        packageToAssetUrl(Uri.parse('package:foo/src/bar/baz.dart')).toString(),
        equals('asset:foo/lib/src/bar/baz.dart'),
      );
    });

    test('non package: url is returned unchanged', () {
      var url = Uri.parse('dart:core');
      expect(packageToAssetUrl(url), equals(url));
    });
  });

  group('fileToAssetUrl', () {
    test('file outside of current directory is unchanged', () {
      var url = Uri.parse('file:///definitely/not/within/cwd/foo.dart');
      expect(fileToAssetUrl(url), equals(url));
    });

    test('file within current directory becomes asset:', () {
      var url = Uri.file('${Uri.base.toFilePath()}lib/builder.dart');
      var asset = fileToAssetUrl(url);
      expect(asset.scheme, equals('asset'));
      expect(asset.path, equals('$rootPackageName/lib/builder.dart'));
    });
  });

  group('normalizeUrl', () {
    test('dart: scheme', () {
      expect(
        normalizeUrl(Uri.parse('dart:core/map.dart')).toString(),
        equals('dart:core'),
      );
    });

    test('package: scheme', () {
      expect(
        normalizeUrl(Uri.parse('package:foo/foo.dart')).toString(),
        equals('asset:foo/lib/foo.dart'),
      );
    });

    test('file: scheme outside cwd is unchanged', () {
      var url = Uri.parse('file:///definitely/not/within/cwd/foo.dart');
      expect(normalizeUrl(url), equals(url));
    });

    test('unknown scheme is returned unchanged', () {
      var url = Uri.parse('https://example.com/foo.dart');
      expect(normalizeUrl(url), equals(url));
    });
  });

  group('rootPackageName', () {
    test('resolves from pubspec.yaml', () {
      expect(rootPackageName, equals('reflection_factory'));
    });
  });

  group('isNullLike', () {
    test('null object is null like', () {
      expect(isNullLike(null), isTrue);
    });
  });
}
