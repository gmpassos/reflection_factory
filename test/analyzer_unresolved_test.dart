@TestOn('vm')
@Tags(['build', 'slow'])
library;

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:reflection_factory/src/analyzer/library.dart';
import 'package:reflection_factory/src/analyzer/type_checker.dart';
import 'package:test/test.dart';

const _pkg = 'test_pkg';
const _asset = 'asset:$_pkg/lib/foo.dart';

/// `@UnknownAnn()` can't be resolved: it's never declared or imported.
const _source = '''
class Ann {
  const Ann();
}

@UnknownAnn()
class Broken {}

@Ann()
class Ok {}
''';

void main() {
  group('UnresolvedAnnotationException', () {
    test('throws when an annotation cannot be resolved', () async {
      await resolveSources({'$_pkg|lib/foo.dart': _source}, (resolver) async {
        var lib = await resolver.libraryFor(
          AssetId(_pkg, 'lib/foo.dart'),
          allowSyntaxErrors: true,
        );
        var broken = LibraryReader(
          lib,
        ).allClasses.firstWhere((e) => e.name == 'Broken');

        expect(
          () => const TypeChecker.fromUrl(
            '$_asset#Ann',
          ).firstAnnotationOf(broken),
          throwsA(isA<UnresolvedAnnotationException>()),
        );
      });
    });

    test('does not throw when throwOnUnresolved is false', () async {
      await resolveSources({'$_pkg|lib/foo.dart': _source}, (resolver) async {
        var lib = await resolver.libraryFor(
          AssetId(_pkg, 'lib/foo.dart'),
          allowSyntaxErrors: true,
        );
        var broken = LibraryReader(
          lib,
        ).allClasses.firstWhere((e) => e.name == 'Broken');

        expect(
          const TypeChecker.fromUrl(
            '$_asset#Ann',
          ).firstAnnotationOf(broken, throwOnUnresolved: false),
          isNull,
        );
        expect(
          const TypeChecker.fromUrl(
            '$_asset#Ann',
          ).hasAnnotationOf(broken, throwOnUnresolved: false),
          isFalse,
        );
      });
    });

    test('exposes the annotated element and a source span', () async {
      await resolveSources({'$_pkg|lib/foo.dart': _source}, (resolver) async {
        var lib = await resolver.libraryFor(
          AssetId(_pkg, 'lib/foo.dart'),
          allowSyntaxErrors: true,
        );
        var broken = LibraryReader(
          lib,
        ).allClasses.firstWhere((e) => e.name == 'Broken');

        UnresolvedAnnotationException? error;
        try {
          const TypeChecker.fromUrl('$_asset#Ann').firstAnnotationOf(broken);
        } on UnresolvedAnnotationException catch (e) {
          error = e;
        }

        expect(error, isNotNull);
        expect(error!.annotatedElement.name, equals('Broken'));

        var span = error.annotationSource;
        expect(span, isNotNull);
        expect(span!.text, equals('@UnknownAnn()'));

        var message = error.toString();
        expect(message, contains('Could not resolve annotation'));
        expect(message, contains('@UnknownAnn()'));
      });
    });

    test('resolvable annotations on the same library still work', () async {
      await resolveSources({'$_pkg|lib/foo.dart': _source}, (resolver) async {
        var lib = await resolver.libraryFor(
          AssetId(_pkg, 'lib/foo.dart'),
          allowSyntaxErrors: true,
        );
        var ok = LibraryReader(
          lib,
        ).allClasses.firstWhere((e) => e.name == 'Ok');

        expect(
          const TypeChecker.fromUrl('$_asset#Ann').firstAnnotationOf(ok),
          isNotNull,
        );
      });
    });
  });
}
