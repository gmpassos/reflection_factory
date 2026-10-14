import 'package:reflection_factory/reflection_factory.dart';
import 'package:test/test.dart';

import 'src/instantiate_fixture.dart';
import 'src/user_with_reflection.dart';

/// The result of an instantiation: the instance fields, `null`,
/// or the error type (and message, for a [StateError]).
Object? _outcome<O>(ClassReflection<O> reflection, O? Function() create) {
  try {
    var o = create();
    return o == null ? null : reflection.getFieldsValues(o);
  } on StateError catch (e) {
    return (StateError, e.message);
  } catch (e) {
    return e.runtimeType;
  }
}

/// [c] as generated before `2.12.0`: without an `invoker`.
ConstructorReflection<O> _withoutInvoker<O>(ConstructorReflection<O> c) =>
    ConstructorReflection<O>(
      c.classReflection,
      c.declaringType,
      c.name,
      c.constructorAccessor,
      c.normalParameters,
      c.optionalParameters,
      c.namedParameters,
      c.annotations,
    );

/// A `fieldValueResolver` that keeps every value: it forces the
/// `MethodInvocation` path, as a `fieldValueResolver` disables direct calls
/// from the map.
Object? _keepValue(String field, Object? value, TypeReflection type) => value;

/// Checks that [constructor] gives the same outcome for each of [maps]
/// through: `Function.apply` (no invoker), the invoker from a
/// `MethodInvocation`, and the invoker called directly from the map.
void _expectSameOutcomes<O>(
  ClassReflection<O> reflection,
  ConstructorReflection<O> constructor,
  List<Map<String, Object?>> maps,
) {
  expect(constructor.invoker, isNotNull);

  var legacy = _withoutInvoker(constructor);
  expect(legacy.invoker, isNull);

  for (var map in maps) {
    var expected = _outcome(
      reflection,
      () => reflection.createInstanceWithConstructor(legacy, map),
    );

    var withInvoker = _outcome(
      reflection,
      () => reflection.createInstanceWithConstructor(
        constructor,
        map,
        fieldValueResolver: _keepValue,
      ),
    );

    var direct = _outcome(
      reflection,
      () => reflection.createInstanceWithConstructor(constructor, map),
    );

    expect(withInvoker, equals(expected), reason: 'invoker: $map');
    expect(direct, equals(expected), reason: 'direct: $map');
  }
}

void main() {
  final createdAt = DateTime.utc(2026, 1, 2, 3, 4, 5);

  group('ConstructorReflection.invoker', () {
    test('generated', () {
      var reflection = TestAccountWithReflection$reflection();

      for (var name in reflection.constructorsNames) {
        expect(
          reflection.constructor(name)!.invoker,
          isNotNull,
          reason: 'constructor: $name',
        );
      }
    });

    test('not generated for parameters typed by a type parameter', () {
      var opReflection = TestOpWithReflection$reflection();
      // `TestOpWithReflection(String type, T? value)`:
      expect(opReflection.constructor('')!.invoker, isNull);
      // No parameters:
      expect(opReflection.constructor('empty')!.invoker, isNotNull);

      // `TestOpAWithReflection(int value)`:
      expect(
        TestOpAWithReflection$reflection().constructor('')!.invoker,
        isNotNull,
      );

      var o = opReflection.createInstanceWithConstructor(
        opReflection.constructor('')!,
        {'type': 't', 'value': 10},
      )!;
      expect(o.type, equals('t'));
      expect(o.value, equals(10));
    });

    test('invokeWith == Function.apply', () {
      var reflection = TestAccountWithReflection$reflection();
      var c = reflection.constructor('')!;

      var mi = c.methodInvocationFromMap({
        'name': 'Joe',
        'email': 'joe@mail.com',
        'age': 33,
      });

      var o1 = c.invokeWith(mi);
      var o2 = _withoutInvoker(c).invokeWith(mi);

      expect(
        reflection.getFieldsValues(o1),
        equals(reflection.getFieldsValues(o2)),
      );
      expect(o1.age, equals(33));
      // Omitted named parameters take their defaults:
      expect(o1.score, equals(0.5));
      expect(o1.active, isTrue);
      expect(o1.phone, isNull);
    });

    test('invokeWith: a missing required named parameter', () {
      var reflection = TestRequiredNamedWithReflection$reflection();
      var c = reflection.constructor('')!;

      var mi = MethodInvocation<TestRequiredNamedWithReflection>(
        reflection,
        TestRequiredNamedWithReflection,
        '',
        [],
        null,
        {'b': 'y'},
      );

      // Left to `Function.apply`, which reports it as it always has:
      expect(
        _outcome(reflection, () => c.invokeWith(mi)),
        equals(_outcome(reflection, () => _withoutInvoker(c).invokeWith(mi))),
      );
    });

    test('account: named parameters with defaults', () {
      var reflection = TestAccountWithReflection$reflection();

      _expectSameOutcomes(reflection, reflection.constructor('')!, [
        {
          'id': 101,
          'name': 'Joe',
          'email': 'joe@mail.com',
          'phone': '+1 555 0101',
          'age': 33,
          'score': 9.5,
          'active': false,
          'createdAt': createdAt,
        },
        // Absent named parameters:
        {'name': 'Joe', 'email': 'joe@mail.com'},
        // Null named parameters with defaults:
        {
          'name': 'Joe',
          'email': 'joe@mail.com',
          'age': null,
          'active': null,
          'phone': null,
        },
        // Extra keys:
        {'name': 'Joe', 'email': 'joe@mail.com', 'foo': 1},
        // Absent and null normal parameters:
        {'email': 'joe@mail.com'},
        {'name': null, 'email': 'joe@mail.com'},
        // Wrong types:
        {'name': 1, 'email': 'joe@mail.com'},
        {'name': 'Joe', 'email': 'joe@mail.com', 'age': 'x'},
        {},
      ]);

      _expectSameOutcomes(reflection, reflection.constructor('basic')!, [
        {'name': 'Joe', 'email': 'joe@mail.com'},
        {'name': 'Joe'},
        {'name': 'Joe', 'email': 2},
      ]);
    });

    test('defaults typed by their parameters', () {
      var reflection = TestDefaultsWithReflection$reflection();
      var c = reflection.constructor('')!;

      // The reflected defaults have other types than the parameters:
      expect(c.namedParameters['score']!.defaultValue, isA<int>());
      expect(
        c.namedParameters['tags']!.defaultValue,
        isNot(isA<List<String>>()),
      );

      bool check(int n) => n > 0;

      _expectSameOutcomes(reflection, c, [
        {},
        {'score': 2.5},
        {'score': null, 'tags': null, 'counts': null},
        {
          'tags': ['a'],
          'counts': {'a': 1},
        },
        {'check': check},
        {'score': 'x'},
      ]);

      for (var o in [
        reflection.createInstanceWithConstructor(c, {})!,
        reflection.createInstanceWithConstructor(
          c,
          {},
          fieldValueResolver: _keepValue,
        )!,
        reflection.createInstanceFromMap({}, valuesResolved: true)!,
      ]) {
        expect(o.score, isA<double>());
        expect(o.score, equals(0.0));
        expect(o.tags, isA<List<String>>());
        expect(o.tags, isEmpty);
        expect(o.counts, isA<Map<String, int>>());
        expect(o.check, isNull);
      }

      var withCheck = reflection.createInstanceWithConstructor(c, {
        'check': check,
      })!;
      expect(withCheck.check!(1), isTrue);

      var positional = reflection.constructor('positional')!;

      _expectSameOutcomes(reflection, positional, [
        {},
        {'score': 2.0},
        {
          'score': 2.0,
          'tags': ['y'],
        },
      ]);

      var o = reflection.createInstanceWithConstructor(positional, {})!;
      expect(o.score, isA<double>());
      expect(o.score, equals(1.0));
      expect(o.tags, equals(['x']));
    });

    test('a constructor that throws is called once per attempt', () {
      var reflection = TestThrowingWithReflection$reflection();
      var c = reflection.constructor('')!;
      var legacy = _withoutInvoker(c);

      int calls(ConstructorReflection<TestThrowingWithReflection> c, Map map) {
        var before = TestThrowingWithReflection.calls;
        try {
          reflection.createInstanceWithConstructor(
            c,
            map.cast<String, Object?>(),
          );
        } on ArgumentError catch (_) {}
        return TestThrowingWithReflection.calls - before;
      }

      for (var map in [
        {'a': 'x'},
        {'a': 'x', 'fail': 'boom'},
        // Extra keys: the `MethodInvocation` path calls it a second time,
        // with the parameters as a `Map`:
        {'a': 'x', 'fail': 'boom', 'z': 1},
      ]) {
        expect(calls(c, map), equals(calls(legacy, map)), reason: '$map');
      }

      expect(calls(c, {'a': 'x', 'fail': 'boom'}), equals(1));

      var errors = <Object?>[];
      reflection.createInstanceWithConstructor(c, {
        'a': 'x',
        'fail': 'boom',
      }, onInvocationError: (c, mi, map, e) => errors.add(e));
      expect(errors, [isA<ArgumentError>()]);
    });

    test('required named parameter', () {
      var reflection = TestRequiredNamedWithReflection$reflection();

      _expectSameOutcomes(reflection, reflection.constructor('')!, [
        {'a': 'x'},
        {'a': 'x', 'b': 'y'},
        {'a': 'x', 'b': null},
        {'a': null},
        {'b': 'y'},
        {},
      ]);

      var o = reflection.createInstanceWithConstructor(
        reflection.constructor('')!,
        {'a': 'x', 'b': null},
      )!;

      // A null value for a parameter with a default takes the default:
      expect(o.b, equals('B'));

      expect(
        () => reflection.createInstanceWithConstructor(
          reflection.constructor('')!,
          {'b': 'y'},
        ),
        throwsStateError,
      );
    });

    test('optional positional parameters (no direct call)', () {
      var reflection = TestOptPositionalWithReflection$reflection();
      var c = reflection.constructor('')!;

      expect(c.canInvokeFromResolvedMap, isFalse);

      _expectSameOutcomes(reflection, c, [
        {'a': 'x'},
        {'a': 'x', 'b': 'y'},
        {'a': 'x', 'b': 'y', 'c': 3},
        // A non-trailing absent optional parameter is passed as `null`:
        {'a': 'x', 'c': 3},
        {'a': 'x', 'b': null},
        {},
      ]);

      var o = reflection.createInstanceWithConstructor(c, {'a': 'x'})!;
      expect(o.b, equals('b'));
      expect(o.c, isNull);
    });

    test('super parameters with inherited defaults', () {
      var reflection = TestSuperParamsWithReflection$reflection();

      _expectSameOutcomes(reflection, reflection.constructor('')!, [
        {},
        {'x': 1},
        {'y': 'w'},
        {'x': null, 'y': null},
      ]);

      var o = reflection.createInstanceWithConstructor(
        reflection.constructor('')!,
        {},
      )!;

      expect(o.x, equals(7));
      expect(o.y, equals('z'));
    });

    test('class with JSON name aliases (no direct call)', () {
      var reflection = TestUserWithReflection$reflection();
      expect(reflection.hasJsonNameAlias, isTrue);

      for (var name in reflection.constructorsNames) {
        expect(reflection.constructor(name)!.canInvokeFromResolvedMap, isFalse);
      }
    });
  });

  group('createInstanceFromMap', () {
    final accountMap = <String, Object?>{
      'id': 101,
      'name': 'Joe',
      'email': 'joe@mail.com',
      'phone': '+1 555 0101',
      'age': 33,
      'score': 9.5,
      'active': false,
      'createdAt': createdAt,
    };

    final memberMap = <String, Object?>{
      'id': 102,
      'name': 'Ann',
      'email': 'ann@mail.com',
      'passwordHash': 'hash:abc',
      'age': 41,
      'score': 7.25,
      'active': false,
      'createdAt': createdAt,
    };

    void expectSameInAllModes<O>(
      ClassReflection<O> reflection,
      Map<String, Object?> map,
    ) {
      // The `MethodInvocation` path:
      var expected = _outcome(
        reflection,
        () => reflection.createInstanceFromMap(
          map,
          fieldValueResolver: _keepValue,
        ),
      );

      var direct = _outcome(
        reflection,
        () => reflection.createInstanceFromMap(map),
      );

      var resolved = _outcome(
        reflection,
        () => reflection.createInstanceFromMap(
          map,
          fieldValueResolver: _keepValue,
          valuesResolved: true,
        ),
      );

      var resolvedExact = _outcome(
        reflection,
        () => reflection.createInstanceFromMap(
          map,
          valuesResolved: true,
          exactKeys: true,
        ),
      );

      expect(direct, equals(expected), reason: 'direct: $map');
      expect(resolved, equals(expected), reason: 'valuesResolved: $map');
      expect(
        resolvedExact,
        equals(expected),
        reason: 'valuesResolved + exactKeys: $map',
      );
    }

    test('account (constructor)', () {
      var reflection = TestAccountWithReflection$reflection();

      var o = reflection.createInstanceFromMap(
        accountMap,
        valuesResolved: true,
        exactKeys: true,
      )!;

      expect(reflection.getFieldsValues(o), equals(accountMap));

      expectSameInAllModes(reflection, accountMap);
      expectSameInAllModes(reflection, {'name': 'Joe', 'email': 'j@mail'});
      expectSameInAllModes(reflection, {...accountMap, 'age': null});
      expectSameInAllModes(reflection, {...accountMap, 'age': 'x'});
      expectSameInAllModes(reflection, {...accountMap, 'foo': 1});
      expectSameInAllModes(reflection, {});
    });

    test('member (create + setters)', () {
      var reflection = TestMemberWithReflection$reflection();

      var o = reflection.createInstanceFromMap(
        memberMap,
        valuesResolved: true,
        exactKeys: true,
      )!;

      expect(reflection.getFieldsValues(o), equals(memberMap));

      expectSameInAllModes(reflection, memberMap);
      expectSameInAllModes(reflection, {...memberMap, 'createdAt': null});
      expectSameInAllModes(reflection, {...memberMap, 'age': 'x'});
      expectSameInAllModes(reflection, {'name': 'Ann'});
    });

    test('member: main constructor, int literal default of a double', () {
      var reflection = TestMemberWithReflection$reflection();
      var c = reflection.constructor('')!;

      // `double score = 0`:
      expect(c.namedParameters['score']!.defaultValue, isA<int>());

      _expectSameOutcomes(reflection, c, [
        {'name': 'n', 'email': 'e', 'passwordOrHash': 'h'},
        {'name': 'n', 'email': 'e', 'passwordOrHash': 'h', 'score': null},
      ]);

      var o = reflection.createInstanceWithConstructor(c, {
        'name': 'n',
        'email': 'e',
        'passwordOrHash': 'h',
      })!;
      expect(o.score, isA<double>());
      expect(o.passwordHash, equals('h'));
    });

    test('member: reflection with an object', () {
      var member = TestMemberWithReflection.create()..name = 'bound';
      var reflection = TestMemberWithReflection$reflection(member);

      var o = reflection.createInstanceFromMap(memberMap)!;

      expect(identical(o, member), isFalse);
      expect(o.name, equals('Ann'));
      expect(member.name, equals('bound'));
    });

    test('valuesResolved ignores fieldValueResolver', () {
      var reflection = TestAccountWithReflection$reflection();
      var memberReflection = TestMemberWithReflection$reflection();

      Object? throwingResolver(String f, Object? v, TypeReflection t) =>
          throw StateError('Unexpected call to fieldValueResolver: $f');

      var o = reflection.createInstanceFromMap(
        accountMap,
        fieldValueResolver: throwingResolver,
        valuesResolved: true,
      )!;
      expect(o.name, equals('Joe'));

      var m = memberReflection.createInstanceFromMap(
        memberMap,
        fieldValueResolver: throwingResolver,
        valuesResolved: true,
      )!;
      expect(m.passwordHash, equals('hash:abc'));
    });

    test('exactKeys', () {
      var reflection = TestMemberWithReflection$reflection();

      var map = {...memberMap}
        ..remove('name')
        ..['NAME'] = 'Bob';

      // The default resolver matches keys ignoring case:
      var o1 = reflection.createInstanceFromMap(map)!;
      expect(o1.name, equals('Bob'));

      // With `exactKeys`, `NAME` is an unknown key:
      var o2 = reflection.createInstanceFromMap(
        map,
        valuesResolved: true,
        exactKeys: true,
      );
      expect(o2, isNull);

      // `exactKeys` ignores `fieldNameResolver`:
      var o3 = reflection.createInstanceFromMap(
        memberMap,
        fieldNameResolver: (f, m) => null,
        exactKeys: true,
      )!;
      expect(o3.name, equals('Ann'));
    });
  });
}
