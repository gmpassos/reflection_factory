@TestOn('vm')
@Tags(['build', 'slow'])
library;

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:reflection_factory/src/analyzer/library.dart';
import 'package:reflection_factory/src/analyzer/type_checker.dart';
import 'package:test/test.dart';

const _pkg = 'test_pkg';
const _asset = 'asset:$_pkg/lib/foo.dart';

const _source = '''
library my_test_lib;

class Ann {
  const Ann();
}

class SubAnn extends Ann {
  const SubAnn();
}

class Other {
  const Other();
}

class Animal {}

abstract class Walker {}

/// Extends [Animal] (super) and implements [Walker] (interface).
class Dog extends Animal implements Walker {
  Dog();
  Dog.named();
}

@Ann()
class WithAnn {}

@SubAnn()
class WithSubAnn {}

@Ann()
@Other()
class WithBoth {}

class NoAnn {}

enum Color { red, green }

@Ann()
enum Flavor { sweet }

mixin Mixy {}

extension IntX on int {}

typedef IntList = List<int>;

void topLevelFn() {}

const topLevelVar = 1;
''';

Future<void> _withLib(
  Future<void> Function(LibraryElement lib, LibraryReader reader) body,
) async {
  await resolveSources({'$_pkg|lib/foo.dart': _source}, (resolver) async {
    var lib = await resolver.libraryFor(AssetId(_pkg, 'lib/foo.dart'));
    await body(lib, LibraryReader(lib));
  });
}

Element _class(LibraryReader reader, String name) =>
    reader.allClassesOrEnums.firstWhere((e) => e.name == name);

void main() {
  group('TypeChecker.fromUrl', () {
    test('isExactly matches the same class', () async {
      await _withLib((lib, reader) async {
        var checker = const TypeChecker.fromUrl('$_asset#Ann');
        expect(checker.isExactly(_class(reader, 'Ann')), isTrue);
        expect(checker.isExactly(_class(reader, 'Other')), isFalse);
      });
    });

    test('isExactly with a null element is false', () {
      expect(const TypeChecker.fromUrl('$_asset#Ann').isExactly(null), isFalse);
    });

    test('isAssignableFrom covers sub classes', () async {
      await _withLib((lib, reader) async {
        var checker = const TypeChecker.fromUrl('$_asset#Ann');
        expect(checker.isAssignableFrom(_class(reader, 'SubAnn')), isTrue);
        expect(checker.isAssignableFrom(_class(reader, 'Other')), isFalse);
      });
    });

    test('isAssignableFrom with a null element is false', () {
      expect(
        const TypeChecker.fromUrl('$_asset#Ann').isAssignableFrom(null),
        isFalse,
      );
    });

    test('isAssignableFrom covers implemented interfaces', () async {
      await _withLib((lib, reader) async {
        var walker = const TypeChecker.fromUrl('$_asset#Walker');
        var dog = _class(reader, 'Dog');
        expect(walker.isAssignableFrom(dog), isTrue);
        // `implements` is not part of the `extends` hierarchy:
        expect(walker.isSuperOf(dog), isFalse);
      });
    });

    test('isSuperOf only follows the extends hierarchy', () async {
      await _withLib((lib, reader) async {
        var animal = const TypeChecker.fromUrl('$_asset#Animal');
        expect(animal.isSuperOf(_class(reader, 'Dog')), isTrue);
        expect(animal.isSuperOf(_class(reader, 'Other')), isFalse);
      });
    });

    test('isSuperOf on a non-interface element is false', () async {
      await _withLib((lib, reader) async {
        var fn = reader.allElements.firstWhere((e) => e.name == 'topLevelFn');
        expect(
          const TypeChecker.fromUrl('$_asset#Animal').isSuperOf(fn),
          isFalse,
        );
      });
    });

    test('isSuperTypeOf / isExactlyType / isAssignableFromType', () async {
      await _withLib((lib, reader) async {
        var dogType = (_class(reader, 'Dog') as InterfaceElement).thisType;
        expect(
          const TypeChecker.fromUrl('$_asset#Animal').isSuperTypeOf(dogType),
          isTrue,
        );
        expect(
          const TypeChecker.fromUrl('$_asset#Dog').isExactlyType(dogType),
          isTrue,
        );
        expect(
          const TypeChecker.fromUrl('$_asset#Animal').isExactlyType(dogType),
          isFalse,
        );
        expect(
          const TypeChecker.fromUrl(
            '$_asset#Walker',
          ).isAssignableFromType(dogType),
          isTrue,
        );
        expect(
          const TypeChecker.fromUrl('$_asset#Ann').isExactlyType(null),
          isFalse,
        );
      });
    });

    test('equality, hashCode and toString', () {
      const a = TypeChecker.fromUrl('$_asset#Ann');
      const b = TypeChecker.fromUrl('$_asset#Ann');
      const c = TypeChecker.fromUrl('$_asset#Other');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
      expect(a, isNot(equals('not a checker')));
      expect(a.toString(), equals('$_asset#Ann'));
    });

    test('accepts a Uri as url', () async {
      await _withLib((lib, reader) async {
        var checker = TypeChecker.fromUrl(Uri.parse('$_asset#Ann'));
        expect(checker.isExactly(_class(reader, 'Ann')), isTrue);
      });
    });

    test('hasSameUrl accepts both String and Uri', () {
      // `hasSameUrl` is only declared on the private `_UriTypeChecker`.
      // ignore: avoid_dynamic_calls
      var checker = const TypeChecker.fromUrl('$_asset#Ann') as dynamic;
      // ignore: avoid_dynamic_calls
      expect(checker.hasSameUrl('$_asset#Ann'), isTrue);
      // ignore: avoid_dynamic_calls
      expect(checker.hasSameUrl(Uri.parse('$_asset#Ann')), isTrue);
      // ignore: avoid_dynamic_calls
      expect(checker.hasSameUrl('$_asset#Other'), isFalse);
    });
  });

  group('TypeChecker.fromPackage', () {
    test('normalizes a package: path to an asset: url', () async {
      await _withLib((lib, reader) async {
        var checker = const TypeChecker.fromPackage(
          'package:$_pkg/foo.dart',
          'Ann',
        );
        expect(checker.isExactly(_class(reader, 'Ann')), isTrue);
        expect(checker.isExactly(_class(reader, 'Other')), isFalse);
        expect(checker.toString(), equals('$_asset#Ann'));
      });
    });

    test('throws ArgumentError when not a package: path', () {
      const checker = TypeChecker.fromPackage('dart:core', 'String');
      expect(() => checker.isExactly(null), throwsArgumentError);
    });
  });

  group('annotations', () {
    test('firstAnnotationOf / hasAnnotationOf', () async {
      await _withLib((lib, reader) async {
        var checker = const TypeChecker.fromUrl('$_asset#Ann');

        expect(checker.firstAnnotationOf(_class(reader, 'WithAnn')), isNotNull);
        expect(checker.hasAnnotationOf(_class(reader, 'WithAnn')), isTrue);

        // No annotations at all (early return path):
        expect(checker.firstAnnotationOf(_class(reader, 'NoAnn')), isNull);
        expect(checker.hasAnnotationOf(_class(reader, 'NoAnn')), isFalse);

        // Has an annotation, but not of this type:
        expect(
          const TypeChecker.fromUrl(
            '$_asset#Other',
          ).firstAnnotationOf(_class(reader, 'WithAnn')),
          isNull,
        );
      });
    });

    test('assignable vs exact', () async {
      await _withLib((lib, reader) async {
        var checker = const TypeChecker.fromUrl('$_asset#Ann');
        var withSubAnn = _class(reader, 'WithSubAnn');

        // `SubAnn extends Ann`: assignable but not exact.
        expect(checker.firstAnnotationOf(withSubAnn), isNotNull);
        expect(checker.hasAnnotationOf(withSubAnn), isTrue);
        expect(checker.firstAnnotationOfExact(withSubAnn), isNull);
        expect(checker.hasAnnotationOfExact(withSubAnn), isFalse);

        var subChecker = const TypeChecker.fromUrl('$_asset#SubAnn');
        expect(subChecker.hasAnnotationOfExact(withSubAnn), isTrue);
      });
    });

    test('firstAnnotationOfExact returns null without annotations', () async {
      await _withLib((lib, reader) async {
        expect(
          const TypeChecker.fromUrl(
            '$_asset#Ann',
          ).firstAnnotationOfExact(_class(reader, 'NoAnn')),
          isNull,
        );
      });
    });

    test('annotationsOf / annotationsOfExact select the right ones', () async {
      await _withLib((lib, reader) async {
        var withBoth = _class(reader, 'WithBoth');

        expect(
          const TypeChecker.fromUrl('$_asset#Ann').annotationsOf(withBoth),
          hasLength(1),
        );
        expect(
          const TypeChecker.fromUrl(
            '$_asset#Other',
          ).annotationsOfExact(withBoth),
          hasLength(1),
        );
        expect(
          const TypeChecker.fromUrl(
            'dart:core#Deprecated',
          ).annotationsOf(withBoth),
          isEmpty,
        );
      });
    });
  });

  group('DartTypeExtension.elementDeclaration', () {
    test('returns null for a non-interface type', () async {
      await _withLib((lib, reader) async {
        var fn =
            reader.allElements.firstWhere((e) => e.name == 'topLevelFn')
                as TopLevelFunctionElement;
        // A function type is not an `InterfaceType`.
        expect(fn.type.elementDeclaration, isNull);
      });
    });

    test('returns the element for an interface type', () async {
      await _withLib((lib, reader) async {
        var dog = _class(reader, 'Dog') as InterfaceElement;
        expect(dog.thisType.elementDeclaration, same(dog));
      });
    });
  });

  group('LibraryReader', () {
    test('allClasses / allEnums / allClassesOrEnums', () async {
      await _withLib((lib, reader) async {
        var classNames = reader.allClasses.map((e) => e.name).toSet();
        expect(
          classNames,
          containsAll(['Ann', 'SubAnn', 'Other', 'Animal', 'Walker', 'Dog']),
        );
        expect(classNames, isNot(contains('Color')));

        expect(
          reader.allEnums.map((e) => e.name).toSet(),
          equals({'Color', 'Flavor'}),
        );

        expect(
          reader.allClassesOrEnums.map((e) => e.name),
          containsAll(['Ann', 'Color', 'Flavor']),
        );
      });
    });

    test('classes / enums typed accessors', () async {
      await _withLib((lib, reader) async {
        expect(reader.classes, everyElement(isA<ClassElement>()));
        expect(reader.enums, everyElement(isA<EnumElement>()));
        expect(reader.enums.map((e) => e.name), containsAll(['Color']));
      });
    });

    test('elementsNames covers every top level declaration kind', () async {
      await _withLib((lib, reader) async {
        expect(
          reader.elementsNames,
          containsAll([
            'Ann',
            'Color',
            'Mixy',
            'topLevelFn',
            'IntX',
            'IntList',
            'topLevelVar',
          ]),
        );
      });
    });

    test('allElements includes non class/enum declarations', () async {
      await _withLib((lib, reader) async {
        expect(
          reader.allElements.map((e) => e.name),
          containsAll(['Mixy', 'topLevelFn', 'IntList']),
        );
      });
    });

    test('allParts is empty for a library without parts', () async {
      await _withLib((lib, reader) async {
        expect(reader.allParts, isEmpty);
      });
    });

    test('allAnnotatedElements filters by kind', () async {
      await _withLib((lib, reader) async {
        var classesOnly = reader
            .allAnnotatedElements(classes: true)
            .map((e) => e.name)
            .toSet();
        expect(classesOnly, equals({'WithAnn', 'WithSubAnn', 'WithBoth'}));

        var enumsOnly = reader
            .allAnnotatedElements(enums: true)
            .map((e) => e.name)
            .toSet();
        expect(enumsOnly, equals({'Flavor'}));

        var both = reader
            .allAnnotatedElements(classes: true, enums: true)
            .map((e) => e.name)
            .toSet();
        expect(both, equals({'WithAnn', 'WithSubAnn', 'WithBoth', 'Flavor'}));

        // Default: every annotated top level element.
        expect(
          reader.allAnnotatedElements().map((e) => e.name),
          containsAll(['WithAnn', 'Flavor']),
        );
      });
    });

    test('annotatedWith returns the annotation and the element', () async {
      await _withLib((lib, reader) async {
        var annotated = reader
            .annotatedWith(const TypeChecker.fromUrl('$_asset#Ann'))
            .toList();

        expect(
          annotated.map((e) => e.element.name).toSet(),
          equals({'WithAnn', 'WithSubAnn', 'WithBoth', 'Flavor'}),
        );
        expect(annotated.every((e) => !e.annotation.isNull), isTrue);
      });
    });
  });

  group('LibraryElementExtension', () {
    test('libraryName uses the declared library name', () async {
      await _withLib((lib, reader) async {
        expect(lib.libraryName, equals('my_test_lib'));
      });
    });

    test('libraryName falls back to the uri when unnamed', () async {
      await resolveSources({'$_pkg|lib/bar.dart': 'class A {}'}, (
        resolver,
      ) async {
        var lib = await resolver.libraryFor(AssetId(_pkg, 'lib/bar.dart'));
        expect(lib.libraryName, equals('package:$_pkg/bar.dart'));
      });
    });

    test('topLevelFragments and topLevelElements agree', () async {
      await _withLib((lib, reader) async {
        expect(
          lib.topLevelFragments.length,
          equals(lib.topLevelElements.length),
        );
        expect(lib.topLevelElements.map((e) => e.name), contains('Ann'));
      });
    });
  });

  group('ElementExtension / IterableElementExtension', () {
    test('isAnnotatedWith', () async {
      await _withLib((lib, reader) async {
        var checker = const TypeChecker.fromUrl('$_asset#Ann');
        expect(_class(reader, 'WithAnn').isAnnotatedWith(checker), isTrue);
        expect(_class(reader, 'NoAnn').isAnnotatedWith(checker), isFalse);
      });
    });

    test('withAnnotation filters an Iterable<Element>', () async {
      await _withLib((lib, reader) async {
        var filtered = reader.allClasses
            .withAnnotation(const TypeChecker.fromUrl('$_asset#Ann'))
            .map((e) => e.name)
            .toSet();
        expect(filtered, equals({'WithAnn', 'WithSubAnn', 'WithBoth'}));
      });
    });

    test('annotatedWith on an Iterable<Element>', () async {
      await _withLib((lib, reader) async {
        var annotated = reader.allClasses
            .annotatedWith(const TypeChecker.fromUrl('$_asset#Other'))
            .toList();
        expect(annotated, hasLength(1));
        expect(annotated.first.element.name, equals('WithBoth'));
      });
    });
  });

  group('ConstructorElementExtension.codeName', () {
    test('unnamed constructor is an empty name', () async {
      await _withLib((lib, reader) async {
        var dog = _class(reader, 'Dog') as ClassElement;
        var unnamed = dog.constructors.firstWhere((c) => c.name == 'new');
        expect(unnamed.codeName, equals(''));
      });
    });

    test('named constructor keeps its name', () async {
      await _withLib((lib, reader) async {
        var dog = _class(reader, 'Dog') as ClassElement;
        var named = dog.constructors.firstWhere((c) => c.name == 'named');
        expect(named.codeName, equals('named'));
      });
    });
  });
}
