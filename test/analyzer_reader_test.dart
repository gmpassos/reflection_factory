@TestOn('vm')
@Tags(['build', 'slow'])
library;

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:reflection_factory/src/analyzer/library.dart';
import 'package:reflection_factory/src/analyzer/reader.dart';
import 'package:reflection_factory/src/analyzer/type_checker.dart';
import 'package:reflection_factory/src/analyzer/utils.dart';
import 'package:test/test.dart';

const _pkg = 'test_pkg';
const _asset = 'asset:$_pkg/lib/foo.dart';

const _source = '''
class Base {
  final int baseField;
  const Base(this.baseField);
}

class Ann extends Base {
  final bool b;
  final int i;
  final double d;
  final String s;
  final List<int> list;
  final Set<int> set;
  final Map<String, int> map;
  final Symbol sym;
  final Type type;
  final String? nil;

  const Ann({
    this.b = true,
    this.i = 123,
    this.d = 1.5,
    this.s = 'hello',
    this.list = const [1, 2, 3],
    this.set = const {4, 5},
    this.map = const {'a': 1},
    this.sym = #mySymbol,
    this.type = Base,
    this.nil,
  }) : super(42);
}

@Ann()
class Target {}
''';

/// Resolves [_source] and hands the `@Ann()` annotation to [body].
Future<void> _withAnnotation(
  Future<void> Function(ConstantReader ann, LibraryElement lib) body,
) async {
  await resolveSources({'$_pkg|lib/foo.dart': _source}, (resolver) async {
    var lib = await resolver.libraryFor(AssetId(_pkg, 'lib/foo.dart'));
    var target = LibraryReader(
      lib,
    ).allClasses.firstWhere((e) => e.name == 'Target');

    var annotation = const TypeChecker.fromUrl(
      '$_asset#Ann',
    ).firstAnnotationOf(target)!;

    await body(ConstantReader(annotation), lib);
  });
}

void main() {
  group('ConstantReader (null)', () {
    final nullReader = ConstantReader(null);

    test('isNull / isLiteral / literalValue', () {
      expect(nullReader.isNull, isTrue);
      expect(nullReader.isLiteral, isTrue);
      expect(nullReader.literalValue, isNull);
    });

    test('all type predicates are false', () {
      expect(nullReader.isBool, isFalse);
      expect(nullReader.isInt, isFalse);
      expect(nullReader.isDouble, isFalse);
      expect(nullReader.isString, isFalse);
      expect(nullReader.isSymbol, isFalse);
      expect(nullReader.isType, isFalse);
      expect(nullReader.isMap, isFalse);
      expect(nullReader.isList, isFalse);
      expect(nullReader.isSet, isFalse);
    });

    test('peek returns null', () {
      expect(nullReader.peek('anything'), isNull);
    });

    test('instanceOf is false', () {
      expect(
        nullReader.instanceOf(const TypeChecker.fromUrl('$_asset#Ann')),
        isFalse,
      );
    });

    test('objectValue throws UnsupportedError', () {
      expect(() => nullReader.objectValue, throwsUnsupportedError);
    });

    test('value accessors throw FormatException', () {
      expect(() => nullReader.boolValue, throwsFormatException);
      expect(() => nullReader.intValue, throwsFormatException);
      expect(() => nullReader.doubleValue, throwsFormatException);
      expect(() => nullReader.stringValue, throwsFormatException);
      expect(() => nullReader.symbolValue, throwsFormatException);
      expect(() => nullReader.typeValue, throwsFormatException);
      expect(() => nullReader.listValue, throwsFormatException);
      expect(() => nullReader.setValue, throwsFormatException);
      expect(() => nullReader.mapValue, throwsFormatException);
    });
  });

  group('ConstantReader (DartObject)', () {
    test('bool field', () async {
      await _withAnnotation((ann, _) async {
        var b = ann.peek('b')!;
        expect(b.isBool, isTrue);
        expect(b.boolValue, isTrue);
        expect(b.isLiteral, isTrue);
        expect(b.literalValue, isTrue);
        expect(b.isNull, isFalse);
        expect(b.isInt, isFalse);
        expect(() => b.intValue, throwsFormatException);
      });
    });

    test('int field', () async {
      await _withAnnotation((ann, _) async {
        var i = ann.peek('i')!;
        expect(i.isInt, isTrue);
        expect(i.intValue, equals(123));
        expect(i.literalValue, equals(123));
        expect(() => i.stringValue, throwsFormatException);
      });
    });

    test('double field', () async {
      await _withAnnotation((ann, _) async {
        var d = ann.peek('d')!;
        expect(d.isDouble, isTrue);
        expect(d.doubleValue, equals(1.5));
        expect(d.literalValue, equals(1.5));
        expect(() => d.boolValue, throwsFormatException);
      });
    });

    test('String field', () async {
      await _withAnnotation((ann, _) async {
        var s = ann.peek('s')!;
        expect(s.isString, isTrue);
        expect(s.stringValue, equals('hello'));
        expect(s.literalValue, equals('hello'));
        expect(() => s.doubleValue, throwsFormatException);
      });
    });

    test('List field', () async {
      await _withAnnotation((ann, _) async {
        var list = ann.peek('list')!;
        expect(list.isList, isTrue);
        expect(list.listValue.length, equals(3));
        expect(
          list.listValue.map((e) => e.toIntValue()).toList(),
          equals([1, 2, 3]),
        );
        expect(() => list.setValue, throwsFormatException);
      });
    });

    test('Set field', () async {
      await _withAnnotation((ann, _) async {
        var set = ann.peek('set')!;
        expect(set.isSet, isTrue);
        expect(set.setValue.map((e) => e.toIntValue()).toSet(), equals({4, 5}));
        expect(() => set.listValue, throwsFormatException);
      });
    });

    test('Map field', () async {
      await _withAnnotation((ann, _) async {
        var map = ann.peek('map')!;
        expect(map.isMap, isTrue);
        expect(map.mapValue.length, equals(1));
        expect(map.mapValue.keys.first!.toStringValue(), equals('a'));
        expect(map.mapValue.values.first!.toIntValue(), equals(1));
        expect(() => map.listValue, throwsFormatException);
      });
    });

    test('Symbol field', () async {
      await _withAnnotation((ann, _) async {
        var sym = ann.peek('sym')!;
        expect(sym.isSymbol, isTrue);
        expect(sym.symbolValue, equals(#mySymbol));
        expect(() => sym.stringValue, throwsFormatException);
      });
    });

    test('Type field', () async {
      await _withAnnotation((ann, _) async {
        var type = ann.peek('type')!;
        expect(type.isType, isTrue);
        expect(type.typeValue.elementDeclaration?.name, equals('Base'));
        // A `Type` is not a literal value.
        expect(type.isLiteral, isFalse);
        expect(() => type.intValue, throwsFormatException);
      });
    });

    test('null field: peek returns null', () async {
      await _withAnnotation((ann, _) async {
        expect(ann.peek('nil'), isNull);
      });
    });

    test('unknown field: peek returns null', () async {
      await _withAnnotation((ann, _) async {
        expect(ann.peek('doesNotExist'), isNull);
      });
    });

    test('peek traverses super class fields', () async {
      await _withAnnotation((ann, _) async {
        var base = ann.peek('baseField')!;
        expect(base.isInt, isTrue);
        expect(base.intValue, equals(42));
      });
    });

    test('instanceOf matches the annotation type', () async {
      await _withAnnotation((ann, _) async {
        expect(
          ann.instanceOf(const TypeChecker.fromUrl('$_asset#Ann')),
          isTrue,
        );
        // Assignable to its super class too.
        expect(
          ann.instanceOf(const TypeChecker.fromUrl('$_asset#Base')),
          isTrue,
        );
        expect(
          ann.instanceOf(const TypeChecker.fromUrl('dart:core#String')),
          isFalse,
        );
      });
    });

    test('the annotation object itself is not a literal', () async {
      await _withAnnotation((ann, _) async {
        expect(ann.isLiteral, isFalse);
        expect(ann.isNull, isFalse);
        expect(() => ann.literalValue, throwsFormatException);
      });
    });

    test('objectValue is exposed and toString describes it', () async {
      await _withAnnotation((ann, _) async {
        expect(ann.objectValue.type!.elementDeclaration!.name, equals('Ann'));
        expect(ann.toString(), startsWith('_DartObjectConstant{'));
      });
    });
  });

  group('getFieldRecursive', () {
    test('null object returns null', () {
      expect(getFieldRecursive(null, 'anything'), isNull);
    });

    test('finds field declared on the class', () async {
      await _withAnnotation((ann, _) async {
        expect(
          getFieldRecursive(ann.objectValue, 'i')?.toIntValue(),
          equals(123),
        );
      });
    });

    test('finds field declared on the super class', () async {
      await _withAnnotation((ann, _) async {
        expect(
          getFieldRecursive(ann.objectValue, 'baseField')?.toIntValue(),
          equals(42),
        );
      });
    });

    test('missing field returns null', () async {
      await _withAnnotation((ann, _) async {
        expect(getFieldRecursive(ann.objectValue, 'nope'), isNull);
      });
    });
  });

  group('urlOfElement', () {
    test('resolves a class element url', () async {
      await _withAnnotation((_, lib) async {
        var target = LibraryReader(
          lib,
        ).allClasses.firstWhere((e) => e.name == 'Target');
        expect(urlOfElement(target), equals('$_asset#Target'));
      });
    });
  });
}
