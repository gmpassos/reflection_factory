import 'package:reflection_factory/reflection_factory.dart';
import 'package:test/test.dart';

import 'src/user_with_reflection.dart';

// Paths of the reflection runtime that the main suite does not reach:
// `MethodInvocation` details, optional positional parameters, `JsonField`
// accessors, `EnumReflection` ordering, static field setters and the errors
// raised when no constructor can build an instance.

void main() {
  setUpAll(() {
    TestUserWithReflection$reflection.boot();
    TestAddressWithReflection$reflection.boot();
  });

  group('MethodInvocation', () {
    final reflection = TestUserWithReflection$reflection();

    test('positional and named arguments', () {
      var inv = MethodInvocation(
        reflection,
        TestUserWithReflection,
        'm',
        [1, 2],
        [3],
        {'a': 4},
      );

      expect(inv.positionalArguments, equals([1, 2, 3]));
      expect(inv.namedArguments, equals({#a: 4}));
      expect(
        inv.toString(),
        equals(
          'MethodInvocation{normalParameters: [1, 2], '
          'optionalParameters: [3], namedParameters: {a: 4}}',
        ),
      );
    });

    test('no optional nor named arguments', () {
      var inv = MethodInvocation(reflection, TestUserWithReflection, 'm', [1]);
      expect(inv.positionalArguments, equals([1]));
      expect(inv.namedArguments, isNull);

      var inv2 = MethodInvocation(
        reflection,
        TestUserWithReflection,
        'm',
        [1],
        [],
        {},
      );
      expect(inv2.positionalArguments, equals([1]));
      expect(inv2.namedArguments, isNull);
    });

    test('invoke', () {
      int f(int a, int b, [int c = 0, int d = 0]) => a + b + c + d;
      int g(int a, {int x = 0}) => a * 10 + x;

      expect(
        MethodInvocation(
          reflection,
          TestUserWithReflection,
          'f',
          [1, 2],
          [3],
        ).invoke<int>(f),
        equals(6),
      );
      expect(
        MethodInvocation(
          reflection,
          TestUserWithReflection,
          'g',
          [1],
          null,
          {'x': 5},
        ).invoke<int>(g),
        equals(15),
      );
    });

    test('parametersToMap with positional names', () {
      var inv = MethodInvocation.withPositionalParametersNames(
        reflection,
        TestUserWithReflection,
        'm',
        ['a', 'b', 'c'],
        [1, 2],
        [3],
        {'n': 4},
      );

      expect(inv.parametersToMap(), equals({'a': 1, 'b': 2, 'c': 3, 'n': 4}));
    });

    test('parametersToMap without (enough) positional names', () {
      var inv = MethodInvocation(
        reflection,
        TestUserWithReflection,
        'm',
        [1, 2],
        [3],
        {'n': 4},
      );
      expect(
        inv.parametersToMap(),
        equals({'arg_0': 1, 'arg_1': 2, 'arg_2': 3, 'n': 4}),
      );

      var partial = MethodInvocation.withPositionalParametersNames(
        reflection,
        TestUserWithReflection,
        'm',
        ['a'],
        [1, 2],
        [3],
      );
      expect(
        partial.parametersToMap(),
        equals({'a': 1, 'arg_1': 2, 'arg_2': 3}),
      );
    });
  });

  group('optional positional parameters', () {
    // `TestUserWithReflection.getField(String key, [V? def])`.
    final user = TestUserWithReflection.fields('joe', 'joe@mail.com', 'pass');
    final method = TestUserWithReflection$reflection(user).method('getField')!;

    test('an absent optional parameter is dropped', () {
      var inv = method.methodInvocationFromMap({'key': 'name'});
      expect(inv.normalParameters, equals(['name']));
      expect(inv.optionalParameters, isEmpty);
      expect(inv.invoke(method.method), equals('joe'));
    });

    test('a null optional parameter is dropped', () {
      var inv = method.methodInvocationFromMap({'key': 'email', 'def': null});
      expect(inv.optionalParameters, isEmpty);
      expect(inv.invoke(method.method), equals('joe@mail.com'));
    });

    test('a given optional parameter is kept', () {
      var inv = method.methodInvocationFromMap({'key': 'zzz', 'def': 'dflt'});
      expect(inv.optionalParameters, equals(['dflt']));
      expect(inv.invoke(method.method), isNull);
    });

    test('positional arguments through invoke', () {
      expect(method.invoke(['name']), equals('joe'));
      expect(method.invoke(['zzz', 'x']), isNull);
    });
  });

  group('JsonField accessors', () {
    test('a class with hidden and visible fields', () {
      var r = TestUserWithReflection$reflection();

      expect(r.hasJsonFieldHidden, isTrue);
      expect(r.hasJsonFieldVisible, isTrue);
      expect(
        r.fieldsWithJsonFieldHidden.map((f) => f.name),
        contains('password'),
      );
      expect(
        r.fieldsWithJsonFieldVisible.map((f) => f.name),
        contains('email'),
      );
      expect(
        () => r.fieldsWithJsonFieldHidden.add(r.fieldsWithJsonFieldHidden[0]),
        throwsUnsupportedError,
      );
    });

    test('a class without them', () {
      var r = TestAddressWithReflection$reflection();
      expect(r.hasJsonFieldHidden, isFalse);
      expect(r.hasJsonFieldVisible, isFalse);
      expect(r.fieldsWithJsonFieldHidden, isEmpty);
      expect(r.fieldsWithJsonFieldVisible, isEmpty);
    });

    test('an instance reflection shares the computed fields', () {
      var user = TestUserWithReflection.fields('joe', 'joe@mail.com', 'pass');
      var r = TestUserWithReflection$reflection();
      var ro = r.withObject(user);

      expect(
        ro.fieldsWithJsonFieldHidden.map((f) => f.name),
        equals(r.fieldsWithJsonFieldHidden.map((f) => f.name)),
      );
      expect(ro.hasJsonFieldVisible, equals(r.hasJsonFieldVisible));
    });
  });

  group('EnumReflection', () {
    final r = TestEnumWithReflection$reflection();

    test('fromJsonEncoded', () {
      expect(r.fromJsonEncoded('y'), equals(TestEnumWithReflection.y));
      expect(r.fromJsonEncoded('Z'), equals(TestEnumWithReflection.Z));
    });

    test('compareTo', () {
      expect(r.compareTo(r), equals(0));
      expect(
        r.compareTo(
          TestEnumWithReflection$reflection(TestEnumWithReflection.x),
        ),
        equals(0),
      );
    });

    test('toString', () {
      expect(
        r.toString(),
        equals('EnumReflection{ enum: TestEnumWithReflection }'),
      );
      expect(
        TestEnumWithReflection$reflection(TestEnumWithReflection.y).toString(),
        equals(
          'EnumReflection{ enum: TestEnumWithReflection }'
          '<TestEnumWithReflection.y>',
        ),
      );
    });
  });

  group('StaticFieldReflection', () {
    test('set / setNullable', () {
      var r = TestOpWithReflection$reflection();
      var field = r.staticField('staticField')!;

      var original = field.get();
      addTearDown(() => field.set(original));

      field.set(10);
      expect(TestOpWithReflection.staticField, equals(10));

      field.setNullable(11);
      expect(TestOpWithReflection.staticField, equals(11));

      expect(() => field.setNullable(null), throwsArgumentError);
      expect(TestOpWithReflection.staticField, equals(11));
    });

    test('a final static field cannot be set', () {
      var field = TestUserWithReflection$reflection().staticField('version')!;
      expect(field.hasSetter, isFalse);
      expect(() => field.set(2.0), throwsStateError);
      expect(() => field.setNullable(2.0), throwsStateError);
      expect(field.get(), equals(1.1));
    });
  });

  group('createInstanceFromMap errors', () {
    test('a map no constructor can take throws the invocation error', () {
      var r = TestAddressWithReflection$reflection();

      // `state` is a `String` in every constructor: the error of the
      // `@JsonConstructor` invocation is rethrown as is.
      expect(
        () => r.createInstanceFromMap({'state': 123, 'city': 'x'}),
        throwsA(
          isA<TypeError>().having(
            (e) => '$e',
            'message',
            contains("'int' is not a subtype of type 'String'"),
          ),
        ),
      );
    });

    test('UnresolvedParameterError message', () {
      var c = TestAddressWithReflection$reflection().constructor('withCity')!;
      var e = UnresolvedParameterError(
        c,
        [MapEntry('state', null)],
        [],
        {'city': 'x'},
      );

      expect(
        e.message,
        startsWith(
          'Constructor[TestAddressWithReflection.withCity] '
          'Unresolved parameter value>',
        ),
      );
      expect(e.toString(), equals(e.message));
    });
  });
}
