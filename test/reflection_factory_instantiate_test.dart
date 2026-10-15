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

/// A `fieldValueResolver` that keeps every value. Since `2.13.0` a
/// constructor that can be called directly is called with the revived values
/// (see `_revivedMapArguments`); a constructor without an `invoker` (see
/// [_withoutInvoker]) still takes the `MethodInvocation` path with it.
Object? _keepValue(String field, Object? value, TypeReflection type) => value;

/// Checks that [constructor] gives the same outcome for each of [maps]
/// through: `Function.apply` (no invoker), the `MethodInvocation` path with
/// a `fieldValueResolver` (no invoker), and the invoker called directly from
/// the map: with revived values (a `fieldValueResolver`) and as they are.
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

    var legacyRevived = _outcome(
      reflection,
      () => reflection.createInstanceWithConstructor(
        legacy,
        map,
        fieldValueResolver: _keepValue,
      ),
    );

    var revived = _outcome(
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

    expect(legacyRevived, equals(expected), reason: 'legacy revived: $map');
    expect(revived, equals(expected), reason: 'revived: $map');
    expect(direct, equals(expected), reason: 'direct: $map');
  }
}

/// Checks that `createInstanceFromMap` gives the same outcome for [map]
/// with a `fieldValueResolver` (revived values), and called directly from
/// the map: as it is, with `valuesResolved`, and with `valuesResolved` and
/// `exactKeys`. Returns the outcome.
Object? _expectSameInAllModes<O>(
  ClassReflection<O> reflection,
  Map<String, Object?> map, {
  FieldNameResolver? fieldNameResolver,
}) {
  // With revived values:
  var expected = _outcome(
    reflection,
    () => reflection.createInstanceFromMap(
      map,
      fieldNameResolver: fieldNameResolver,
      fieldValueResolver: _keepValue,
    ),
  );

  var direct = _outcome(
    reflection,
    () => reflection.createInstanceFromMap(
      map,
      fieldNameResolver: fieldNameResolver,
    ),
  );

  var resolved = _outcome(
    reflection,
    () => reflection.createInstanceFromMap(
      map,
      fieldNameResolver: fieldNameResolver,
      fieldValueResolver: _keepValue,
      valuesResolved: true,
    ),
  );

  expect(direct, equals(expected), reason: 'direct: $map');
  expect(resolved, equals(expected), reason: 'valuesResolved: $map');

  // `exactKeys` ignores `fieldNameResolver`: only for maps with exact keys.
  if (fieldNameResolver == null) {
    var resolvedExact = _outcome(
      reflection,
      () => reflection.createInstanceFromMap(
        map,
        valuesResolved: true,
        exactKeys: true,
      ),
    );

    expect(
      resolvedExact,
      equals(expected),
      reason: 'valuesResolved + exactKeys: $map',
    );
  }

  return expected;
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

    test('account (constructor)', () {
      var reflection = TestAccountWithReflection$reflection();

      var o = reflection.createInstanceFromMap(
        accountMap,
        valuesResolved: true,
        exactKeys: true,
      )!;

      expect(reflection.getFieldsValues(o), equals(accountMap));

      _expectSameInAllModes(reflection, accountMap);
      _expectSameInAllModes(reflection, {'name': 'Joe', 'email': 'j@mail'});
      _expectSameInAllModes(reflection, {...accountMap, 'age': null});
      _expectSameInAllModes(reflection, {...accountMap, 'age': 'x'});
      _expectSameInAllModes(reflection, {...accountMap, 'foo': 1});
      _expectSameInAllModes(reflection, {});
    });

    test('member (create + setters)', () {
      var reflection = TestMemberWithReflection$reflection();

      var o = reflection.createInstanceFromMap(
        memberMap,
        valuesResolved: true,
        exactKeys: true,
      )!;

      expect(reflection.getFieldsValues(o), equals(memberMap));

      _expectSameInAllModes(reflection, memberMap);
      _expectSameInAllModes(reflection, {...memberMap, 'createdAt': null});
      _expectSameInAllModes(reflection, {...memberMap, 'age': 'x'});
      _expectSameInAllModes(reflection, {'name': 'Ann'});
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

    test('valuesResolved: the values must already have their types', () {
      var reflection = TestDefaultsWithReflection$reflection();

      // JSON values that don't have their parameters' types, on any platform
      // (an `int` for a `double` would fit on the web: both are JS numbers):
      for (var json in <Map<String, Object?>>[
        {'score': '2.5'},
        {
          'tags': <dynamic>['a'],
        },
      ]) {
        // Resolved by `fromJson` (with a `fieldValueResolver`):
        var o = TestDefaultsWithReflection$fromJson(json);
        if (json.containsKey('score')) expect(o.score, equals(2.5));
        if (json.containsKey('tags')) {
          expect(o.tags, isA<List<String>>());
          expect(o.tags, equals(['a']));
        }

        // Passed as resolved, they aren't converted, and don't fit:
        expect(
          () => reflection.createInstanceFromMap(json, valuesResolved: true),
          throwsA(isA<TypeError>()),
          reason: '$json',
        );
      }
    });
  });

  group('defaults in generated code', () {
    test('more defaults typed by their parameters', () {
      var reflection = TestMoreDefaultsWithReflection$reflection();
      var c = reflection.constructor('')!;

      // The reflected defaults lose their types:
      expect(c.namedParameters['ids']!.defaultValue, isNot(isA<Set<int>>()));
      expect(
        c.namedParameters['groups']!.defaultValue,
        isNot(isA<Map<String, List<int>>>()),
      );

      _expectSameOutcomes(reflection, c, [
        {},
        {
          'ids': {1, 2},
        },
        {
          'groups': {
            'a': [1],
          },
        },
        // A null value for a nullable parameter with a default takes the
        // default (it's omitted), as through `Function.apply`:
        {'label': null},
        {'limit': 9, 'level': TestLevel.low},
        {'timeout': 'x'},
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
        expect(o.ids, isA<Set<int>>());
        expect(o.ids, isEmpty);
        expect(o.groups, isA<Map<String, List<int>>>());
        expect(o.timeout, equals(const Duration(seconds: 1)));
        expect(o.level, equals(TestLevel.high));
        // `this.limit = defaultLimit`: a static const by its bare name.
        expect(o.limit, equals(TestMoreDefaultsWithReflection.defaultLimit));
        expect(o.label, equals('label'));
      }
    });

    test('fromJson: omitted fields take typed defaults', () {
      for (var o in [
        TestDefaultsWithReflection$fromJson({}),
        TestDefaultsWithReflection$fromJsonEncoded('{}'),
      ]) {
        expect(o.score, isA<double>());
        expect(o.score, equals(0.0));
        expect(o.tags, isA<List<String>>());
        expect(o.counts, isA<Map<String, int>>());
      }

      var o = TestDefaultsWithReflection$fromJsonEncoded(
        '{"score": 2.5, "tags": ["x", "y"], "counts": {"x": 1}}',
      );
      expect(o.score, equals(2.5));
      expect(o.tags, equals(['x', 'y']));
      expect(o.counts, equals({'x': 1}));
    });

    test('parameters typed by a type parameter: no invoker', () {
      var reflection = TestGenericBoxWithReflection$reflection();

      // `TestGenericBoxWithReflection(List<T> items, {T Function()? factory})`:
      var c = reflection.constructor('')!;
      expect(c.invoker, isNull);
      expect(c.canInvokeFromResolvedMap, isFalse);

      // `named(String name)`:
      expect(reflection.constructor('named')!.invoker, isNotNull);

      var o = reflection.createInstanceWithConstructor(c, {
        'items': [1, 2],
        'factory': () => 3,
      })!;
      expect(o.items, equals([1, 2]));
      expect(o.factory!(), equals(3));
      expect(o.name, equals('box'));

      var o2 = reflection.createInstanceWithConstructor(
        reflection.constructor('named')!,
        {'name': 'n'},
      )!;
      expect(o2.name, equals('n'));
      expect(o2.items, isEmpty);

      // `T Function()? factory`, through the raw `TestGenericBoxWithReflection`
      // (`T` as `dynamic`):
      expect(
        reflection.field('factory'),
        isA<
          FieldReflection<TestGenericBoxWithReflection, dynamic Function()?>
        >(),
      );
    });

    test('a subclass with the type argument: invoker and field types', () {
      var reflection = TestIntBoxWithReflection$reflection();

      // `TestIntBoxWithReflection(super.items)`: `List<int>`.
      var c = reflection.constructor('')!;
      expect(c.invoker, isNotNull);

      var o = reflection.createInstanceWithConstructor(c, {
        'items': <int>[1, 2],
      })!;
      expect(o.items, equals([1, 2]));

      // The inherited `T Function()? factory`, as `int Function()?`:
      var factory = reflection.field('factory', o);
      expect(
        factory,
        isA<FieldReflection<TestIntBoxWithReflection, int Function()?>>(),
      );
      expect(factory!.nullable, isTrue);
      expect(factory.get(), isNull);

      // The inherited `List<T> items`, as `List<int>`:
      var items = reflection.field('items', o);
      expect(
        items,
        isA<FieldReflection<TestIntBoxWithReflection, List<int>>>(),
      );
      expect(items!.get(), equals([1, 2]));
    });

    test('a field from a generic mixin, with the type argument', () {
      // `TestOpBWithReflection extends TestOpWithReflection<double>`, whose
      // `T? value` comes from `WithValue<T>`: `double?`.
      var o = TestOpBWithReflection(1.5);
      var value = TestOpBWithReflection$reflection(o).field('value');
      expect(value, isA<FieldReflection<TestOpBWithReflection, double?>>());
      expect(value!.get(), equals(1.5));

      value.set(2.5);
      expect(o.value, equals(2.5));
      expect(() => value.set('x' as dynamic), throwsA(isA<TypeError>()));
    });
  });

  group('direct call and the MethodInvocation path', () {
    final account = <String, Object?>{'name': 'Joe', 'email': 'j@mail'};

    test('a fieldNameResolver that throws', () {
      var reflection = TestAccountWithReflection$reflection();
      var c = reflection.constructor('')!;

      String? throwing(String f, Map<String, Object?> m) =>
          throw StateError('resolver: $f');

      // The direct call leaves the error to the `MethodInvocation` path:
      expect(
        _outcome(
          reflection,
          () => reflection.createInstanceWithConstructor(
            c,
            account,
            fieldNameResolver: throwing,
          ),
        ),
        equals(
          _outcome(
            reflection,
            () => reflection.createInstanceWithConstructor(
              c,
              account,
              fieldNameResolver: throwing,
              fieldValueResolver: _keepValue,
            ),
          ),
        ),
      );
    });

    test('keys matched by a fieldNameResolver', () {
      var reflection = TestAccountWithReflection$reflection();
      var c = reflection.constructor('')!;

      String? ignoreCase(String f, Map<String, Object?> m) =>
          m.keys.where((k) => k.toLowerCase() == f.toLowerCase()).firstOrNull;

      var map = {'NAME': 'Joe', 'Email': 'j@mail', 'AGE': 40};

      var direct = reflection.createInstanceWithConstructor(
        c,
        map,
        fieldNameResolver: ignoreCase,
      )!;
      var viaMethodInvocation = reflection.createInstanceWithConstructor(
        c,
        map,
        fieldNameResolver: ignoreCase,
        fieldValueResolver: _keepValue,
      )!;

      expect(
        reflection.getFieldsValues(direct),
        equals(reflection.getFieldsValues(viaMethodInvocation)),
      );
      expect(direct.name, equals('Joe'));
      expect(direct.age, equals(40));
    });

    test('invokeWith: parameters that don\'t fit the constructor', () {
      var reflection = TestAccountWithReflection$reflection();
      var c = reflection.constructor('')!;
      var legacy = _withoutInvoker(c);

      for (var mi in [
        // An extra positional argument:
        MethodInvocation<TestAccountWithReflection>(
          reflection,
          TestAccountWithReflection,
          '',
          ['Joe', 'j@mail', 'extra'],
        ),
        // A missing positional argument:
        MethodInvocation<TestAccountWithReflection>(
          reflection,
          TestAccountWithReflection,
          '',
          ['Joe'],
        ),
        // An unknown named argument:
        MethodInvocation<TestAccountWithReflection>(
          reflection,
          TestAccountWithReflection,
          '',
          ['Joe', 'j@mail'],
          null,
          {'unknown': 1},
        ),
      ]) {
        var expected = _outcome(reflection, () => legacy.invokeWith(mi));
        expect(expected, equals(NoSuchMethodError), reason: '$mi');
        expect(
          _outcome(reflection, () => c.invokeWith(mi)),
          equals(expected),
          reason: '$mi',
        );
      }

      var opt = TestOptPositionalWithReflection$reflection();
      var optC = opt.constructor('')!;
      // Too many optional positional arguments:
      var mi = MethodInvocation<TestOptPositionalWithReflection>(
        opt,
        TestOptPositionalWithReflection,
        '',
        ['a'],
        ['b', 1, 'extra'],
      );
      expect(
        _outcome(opt, () => optC.invokeWith(mi)),
        equals(_outcome(opt, () => _withoutInvoker(optC).invokeWith(mi))),
      );
    });

    test('absentArgument', () {
      expect(
        identical(
          ConstructorReflection.absentArgument,
          ConstructorReflection.absentArgument,
        ),
        isTrue,
      );
      expect(ConstructorReflection.absentArgument, isNot(isNull));
      expect(
        ConstructorReflection.absentArgument.toString(),
        equals('absentArgument'),
      );
    });

    test('argOrDefault', () {
      const absent = ConstructorReflection.absentArgument;

      // The default is typed in `T`'s context:
      var d = ConstructorReflection.argOrDefault<double>(absent, 0);
      expect(d, isA<double>());
      expect(d, equals(0.0));

      var l = ConstructorReflection.argOrDefault<List<String>>(
        absent,
        const [],
      );
      expect(l, isA<List<String>>());

      expect(ConstructorReflection.argOrDefault<int?>(absent, null), isNull);

      // A passed argument wins, even `null`:
      expect(ConstructorReflection.argOrDefault<int>(7, 1), equals(7));
      expect(ConstructorReflection.argOrDefault<int?>(null, 1), isNull);

      expect(
        () => ConstructorReflection.argOrDefault<int>('x', 1),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('revived values (a fieldValueResolver)', () {
    final account = <String, Object?>{
      'name': 'Joe',
      'email': 'j@mail',
      'age': 40,
    };

    test('called directly, reviving each parameter once', () {
      var reflection = TestAccountWithReflection$reflection();
      var c = reflection.constructor('')!;
      expect(c.canInvokeFromResolvedMap, isTrue);

      var calls = <String>[];
      Object? revive(String f, Object? v, TypeReflection t) {
        calls.add(f);
        return v is String ? v.toUpperCase() : v;
      }

      var o = reflection.createInstanceWithConstructor(
        c,
        account,
        fieldValueResolver: revive,
      )!;

      expect(o.name, equals('JOE'));
      expect(o.email, equals('J@MAIL'));
      expect(o.age, equals(40));
      // A default for an absent parameter:
      expect(o.score, equals(0.5));

      // Once per parameter (no `MethodInvocation`):
      expect(
        calls,
        unorderedEquals(c.allParameters.map((p) => p.name).toList()),
      );

      var legacy = reflection.createInstanceWithConstructor(
        _withoutInvoker(c),
        account,
        fieldValueResolver: revive,
      )!;
      expect(
        reflection.getFieldsValues(o),
        equals(reflection.getFieldsValues(legacy)),
      );
    });

    test('unresolved values take the MethodInvocation path', () {
      var reflection = TestRequiredNamedWithReflection$reflection();
      var c = reflection.constructor('')!;
      var legacy = _withoutInvoker(c);

      // A non-null value revived to `null` is unresolved: the
      // `MethodInvocation` path resolves it again, then omits it (when it
      // can be omitted) or reports it.
      Object? unresolvedA(String f, Object? v, TypeReflection t) =>
          f == 'a' ? null : v;
      Object? unresolvedB(String f, Object? v, TypeReflection t) =>
          f == 'b' ? null : v;
      Object? unresolvedAll(String f, Object? v, TypeReflection t) => null;

      for (var reviver in [unresolvedA, unresolvedB, unresolvedAll]) {
        for (var map in <Map<String, Object?>>[
          {'a': 'x', 'b': 'y'},
          {'a': 'x'},
          {'a': 'x', 'b': null},
          {'a': null},
          {},
        ]) {
          expect(
            _outcome(
              reflection,
              () => reflection.createInstanceWithConstructor(
                c,
                map,
                fieldValueResolver: reviver,
              ),
            ),
            equals(
              _outcome(
                reflection,
                () => reflection.createInstanceWithConstructor(
                  legacy,
                  map,
                  fieldValueResolver: reviver,
                ),
              ),
            ),
            reason: '$map',
          );
        }
      }

      // `b` unresolved is omitted: it takes its default.
      var o = reflection.createInstanceWithConstructor(c, {
        'a': 'x',
        'b': 'y',
      }, fieldValueResolver: unresolvedB)!;
      expect(o.b, equals('B'));

      // `a` (required) unresolved is reported:
      expect(
        () => reflection.createInstanceWithConstructor(c, {
          'a': 'x',
        }, fieldValueResolver: unresolvedA),
        throwsA(isA<UnresolvedParameterError>()),
      );
    });

    test('a fieldValueResolver that throws', () {
      var reflection = TestAccountWithReflection$reflection();
      var c = reflection.constructor('')!;

      Object? throwing(String f, Object? v, TypeReflection t) =>
          f == 'email' ? throw StateError('reviver: $f') : v;

      // The direct call leaves the error to the `MethodInvocation` path:
      expect(
        _outcome(
          reflection,
          () => reflection.createInstanceWithConstructor(
            c,
            account,
            fieldValueResolver: throwing,
          ),
        ),
        allOf(
          equals((StateError, 'reviver: email')),
          equals(
            _outcome(
              reflection,
              () => reflection.createInstanceWithConstructor(
                _withoutInvoker(c),
                account,
                fieldValueResolver: throwing,
              ),
            ),
          ),
        ),
      );
    });

    test('a revived value for an absent parameter', () {
      var reflection = TestAccountWithReflection$reflection();
      var c = reflection.constructor('')!;

      // A `fieldValueResolver` can give a value for a parameter absent from
      // the map (the `MethodInvocation` path uses it too):
      Object? withDefaults(String f, Object? v, TypeReflection t) =>
          v ??
          switch (f) {
            'age' => 77,
            'phone' => '+0',
            _ => null,
          };

      for (var map in <Map<String, Object?>>[
        {'name': 'Joe', 'email': 'j@mail'},
        {'name': 'Joe', 'email': 'j@mail', 'age': null},
        {'name': 'Joe', 'email': 'j@mail', 'age': 5, 'phone': null},
      ]) {
        expect(
          _outcome(
            reflection,
            () => reflection.createInstanceWithConstructor(
              c,
              map,
              fieldValueResolver: withDefaults,
            ),
          ),
          equals(
            _outcome(
              reflection,
              () => reflection.createInstanceWithConstructor(
                _withoutInvoker(c),
                map,
                fieldValueResolver: withDefaults,
              ),
            ),
          ),
          reason: '$map',
        );
      }

      var o = reflection.createInstanceWithConstructor(c, {
        'name': 'Joe',
        'email': 'j@mail',
      }, fieldValueResolver: withDefaults)!;
      expect(o.age, equals(77));
      expect(o.phone, equals('+0'));
    });

    test('an entity list with a null: unresolved', () {
      var reflection = TestOrderWithReflection$reflection();
      var c = reflection.constructor('')!;
      expect(c.canInvokeFromResolvedMap, isTrue);

      var joe = TestAccountWithReflection('Joe', 'j@mail');

      var calls = 0;
      Object? reviver(String f, Object? v, TypeReflection t) {
        ++calls;
        if (f == 'items') {
          // The second element can't be resolved:
          return [joe, null];
        } else if (f == 'account') {
          return TestRef(joe);
        }
        return v;
      }

      var map = <String, Object?>{
        'account': {'name': 'Joe'},
        'items': [
          {'id': 1},
          {'id': 2},
        ],
      };

      var expected = _outcome(
        reflection,
        () => reflection.createInstanceWithConstructor(
          _withoutInvoker(c),
          map,
          fieldValueResolver: reviver,
        ),
      );

      calls = 0;
      var outcome = _outcome(
        reflection,
        () => reflection.createInstanceWithConstructor(
          c,
          map,
          fieldValueResolver: reviver,
        ),
      );

      expect(outcome, equals(expected));
      // The direct attempt (one per parameter), then the `MethodInvocation`
      // path:
      expect(calls, greaterThan(c.allParameters.length));
    });

    test('unresolved values: the arguments are built once directly', () {
      var reflection = TestRequiredNamedWithReflection$reflection();
      reflection.disposeCache();

      var calls = <String>[];
      Object? unresolvedB(String f, Object? v, TypeReflection t) {
        calls.add(f);
        return f == 'b' ? null : v;
      }

      int create() {
        calls.clear();
        var o = reflection.createInstanceFromMap({
          'a': 'x',
          'b': 'y',
        }, fieldValueResolver: unresolvedB)!;
        expect(o.a, equals('x'));
        expect(o.b, equals('B'));
        return calls.length;
      }

      // The first map (not cached) and the next ones (the shape cached):
      // the same calls, a direct attempt and the `MethodInvocation` path.
      var first = create();
      expect(create(), equals(first));
      expect(create(), equals(first));

      // One direct attempt (2 parameters), and the `MethodInvocation` path
      // resolving them, then again the named ones (one is unresolved):
      expect(first, equals(2 + 2 + 2));
    });

    test('a constructor that throws is called once', () {
      var reflection = TestThrowingWithReflection$reflection();
      var c = reflection.constructor('')!;

      var before = TestThrowingWithReflection.calls;
      var errors = <Object?>[];
      reflection.createInstanceWithConstructor(
        c,
        {'a': 'x', 'fail': 'boom'},
        fieldValueResolver: _keepValue,
        onInvocationError: (c, mi, map, e) => errors.add(e),
      );

      expect(TestThrowingWithReflection.calls - before, equals(1));
      expect(errors, [isA<ArgumentError>()]);
    });
  });

  group('createInstanceFromMap: maps of the same shape', () {
    // Maps with the same keys, in the same order, as the last one reuse its
    // resolution (fields, constructors), and a single constructor is called
    // directly: each map must give the outcome it gives alone.
    final maps = <Map<String, Object?>>[
      {'name': 'a', 'email': 'e', 'age': 1},
      {'name': 'b', 'email': 'f', 'age': 2},
      {'email': 'g', 'name': 'c', 'age': 3},
      {'name': 'd', 'email': 'h'},
      {'NAME': 'e', 'email': 'i', 'age': 4},
      {'name': 'f', 'email': 'j', 'age': 'x'},
      {'name': 'g', 'email': 'k', 'age': 5},
      {},
      {'name': 'h', 'email': 'l', 'age': 6},
    ];

    String? ignoreCase(String f, Map<String, Object?> m) =>
        m.keys.where((k) => k.toLowerCase() == f.toLowerCase()).firstOrNull;

    for (var (name, reflection) in <(String, ClassReflection)>[
      ('constructor', TestAccountWithReflection$reflection()),
      ('create + setters', TestMemberWithReflection$reflection()),
    ]) {
      for (var (mode, nameResolver, valueResolver)
          in <(String, FieldNameResolver?, FieldValueResolver?)>[
            ('default', null, null),
            ('revived', null, _keepValue),
            ('fieldNameResolver', ignoreCase, null),
            ('fieldNameResolver + revived', ignoreCase, _keepValue),
          ]) {
        test('$name: $mode', () {
          Object? create(Map<String, Object?> map) => _outcome(
            reflection,
            () => reflection.createInstanceFromMap(
              map,
              fieldNameResolver: nameResolver,
              fieldValueResolver: valueResolver,
            ),
          );

          Object? alone(Map<String, Object?> map) {
            reflection.disposeCache();
            return create(map);
          }

          var expected = maps.map(alone).toList();

          reflection.disposeCache();
          // Each map twice in a row (the second with the cached shape):
          var inSequence = maps.expand((m) => [create(m), create(m)]).toList();

          expect(inSequence, equals(expected.expand((e) => [e, e]).toList()));
        });
      }
    }

    test('a fieldNameResolver of another identity: not the same shape', () {
      var reflection = TestAccountWithReflection$reflection();
      reflection.disposeCache();

      // The same map shape, resolved to other keys:
      String? swapped(String f, Map<String, Object?> m) => switch (f) {
        'name' => 'EMAIL',
        'email' => 'NAME',
        _ => null,
      };

      var map = {'NAME': 'Joe', 'EMAIL': 'j@mail'};

      for (var i = 0; i < 2; ++i) {
        var byDefault = reflection.createInstanceFromMap(map)!;
        var bySwapped = reflection.createInstanceFromMap(
          map,
          fieldNameResolver: swapped,
        )!;

        expect(byDefault.name, equals('Joe'));
        expect(byDefault.email, equals('j@mail'));
        expect(bySwapped.name, equals('j@mail'));
        expect(bySwapped.email, equals('Joe'));
      }
    });

    test('the same class created inside a fieldValueResolver', () {
      // A nested map of the same class (e.g. a tree of entities) is created
      // while the outer one is: it replaces the cached shape in the middle
      // of the outer creation.
      var reflection = TestAccountWithReflection$reflection();
      reflection.disposeCache();

      var nested = <String, Object?>{'email': 'n@mail', 'name': 'nested'};

      Object? reviver(String f, Object? v, TypeReflection t) {
        if (f == 'name' && v == 'parent') {
          var o = reflection.createInstanceFromMap(nested)!;
          return '${o.name}-parent';
        }
        return v;
      }

      for (var i = 0; i < 3; ++i) {
        var parent = reflection.createInstanceFromMap({
          'name': 'parent',
          'email': 'p@mail',
          'age': i,
        }, fieldValueResolver: reviver)!;
        expect(parent.name, equals('nested-parent'));
        expect(parent.age, equals(i));

        var sibling = reflection.createInstanceFromMap({
          'name': 'sibling',
          'email': 's@mail',
          'age': i,
        }, fieldValueResolver: reviver)!;
        expect(sibling.name, equals('sibling'));
        expect(sibling.email, equals('s@mail'));
      }
    });

    test('disposeCache between maps of the same shape', () {
      var reflection = TestAccountWithReflection$reflection();

      for (var i = 0; i < 4; ++i) {
        if (i.isEven) reflection.disposeCache();
        var o = reflection.createInstanceFromMap({
          'name': 'n$i',
          'email': 'e$i',
          'age': i,
        })!;
        expect(o.name, equals('n$i'));
        expect(o.age, equals(i));
      }
    });

    test('getBestConstructorsForMap with other options in between', () {
      var reflection = TestMemberWithReflection$reflection();
      reflection.disposeCache();

      var map = {'name': 'a', 'email': 'e'};

      List<String> best(bool allowEmpty, bool allowOptionalOnly) => reflection
          .getBestConstructorsForMap(
            map,
            allowEmptyConstructors: allowEmpty,
            allowOptionalOnlyConstructors: allowOptionalOnly,
          )
          .map((c) => c.name)
          .toList();

      List<String> alone(bool allowEmpty, bool allowOptionalOnly) {
        reflection.disposeCache();
        return best(allowEmpty, allowOptionalOnly);
      }

      var options = [
        (true, true),
        (false, true),
        (true, false),
        (false, false),
      ];
      var expected = [for (var (e, o) in options) alone(e, o)];

      reflection.disposeCache();
      for (var round = 0; round < 2; ++round) {
        for (var i = 0; i < options.length; ++i) {
          var (e, o) = options[i];
          expect(best(e, o), equals(expected[i]), reason: '$e, $o');

          // `createInstanceFromMap` in between, with its own options:
          var member = reflection.createInstanceFromMap({
            'name': 'm',
            'email': 'x',
            'passwordHash': 'h',
          });
          expect(member?.passwordHash, equals('h'));
        }
      }
    });

    test('a constructor that throws is called once per map', () {
      var reflection = TestThrowingWithReflection$reflection();
      reflection.disposeCache();

      for (var i = 0; i < 3; ++i) {
        var before = TestThrowingWithReflection.calls;
        expect(
          () => reflection.createInstanceFromMap({'a': 'x', 'fail': 'boom'}),
          throwsArgumentError,
        );
        expect(TestThrowingWithReflection.calls - before, equals(1));
      }
    });
  });

  group('getField', () {
    test('of an object other than the reflection one', () {
      var reflection = TestAccountWithReflection$reflection();
      var joe = TestAccountWithReflection('Joe', 'joe@mail', id: 1);
      var ann = TestAccountWithReflection('Ann', 'ann@mail', id: 2);

      expect(reflection.getField('name', joe), equals('Joe'));
      expect(reflection.getField('id', ann), equals(2));
      expect(reflection.getField('NAME', joe), equals('Joe'));
      expect(reflection.getField('nope', joe), isNull);

      var withJoe = reflection.withObject(joe);
      expect(withJoe.getField('name'), equals('Joe'));
      expect(withJoe.getField('name', joe), equals('Joe'));
      expect(withJoe.getField('name', ann), equals('Ann'));

      for (var f in reflection.fieldsNames) {
        expect(
          reflection.getField(f, ann),
          equals(reflection.field(f, ann)!.get()),
          reason: f,
        );
      }
    });
  });

  group('JsonDecoder: entities from maps', () {
    test('a JSON object (Map<String, dynamic>), not modified', () {
      TestAccountWithReflection$reflection();

      var json = <String, dynamic>{
        'name': 'Joe',
        'email': 'j@mail',
        'age': 30,
        'createdAt': '2026-01-02T03:04:05.000Z',
      };
      var copy = Map<String, dynamic>.of(json);

      for (var i = 0; i < 2; ++i) {
        var o = JsonDecoder.defaultDecoder.fromJson<TestAccountWithReflection>(
          json,
        )!;
        expect(o.name, equals('Joe'));
        expect(o.age, equals(30));
        expect(o.createdAt, equals(DateTime.utc(2026, 1, 2, 3, 4, 5)));
      }

      expect(json, equals(copy));
      expect(json['createdAt'], isA<String>());
    });

    test('maps with other key types (converted to String keys)', () {
      TestAccountWithReflection$reflection();

      for (var map in <Map>[
        <dynamic, dynamic>{'name': 'Joe', 'email': 'j@mail'},
        <Object, Object>{'name': 'Joe', 'email': 'j@mail'},
        <String, Object>{'name': 'Joe', 'email': 'j@mail'},
        <String, String>{'name': 'Joe', 'email': 'j@mail'},
      ]) {
        var o = JsonDecoder.defaultDecoder.fromJson<TestAccountWithReflection>(
          map,
        )!;
        expect(o.name, equals('Joe'), reason: '${map.runtimeType}');
        expect(o.email, equals('j@mail'), reason: '${map.runtimeType}');
      }
    });

    test('a list of maps of the same shape, with nulls and other shapes', () {
      TestAccountWithReflection$reflection();

      var list = <Object?>[
        {'name': 'a', 'email': 'a@mail', 'age': 1},
        {'name': 'b', 'email': 'b@mail', 'age': 2},
        null,
        {'email': 'c@mail', 'name': 'c'},
        {'name': 'd', 'email': 'd@mail', 'age': 4},
        {'name': 'e', 'email': 'e@mail', 'age': null},
      ];

      var decoded = JsonDecoder.defaultDecoder
          .fromJsonList<TestAccountWithReflection>(
            list,
            type: TestAccountWithReflection,
          );

      expect(
        decoded.map((o) => o == null ? null : (o.name, o.age)).toList(),
        equals([('a', 1), ('b', 2), null, ('c', 18), ('d', 4), ('e', 18)]),
      );
    });
  });

  group('JsonEntityCacheSimple', () {
    test('getEntityID and cacheEntity: by the ID field of each type', () {
      // Registers the reflection:
      TestAccountWithReflection$reflection();

      var cache = JsonEntityCacheSimple();
      var joe = TestAccountWithReflection('Joe', 'joe@mail', id: 7);
      var ann = TestAccountWithReflection('Ann', 'ann@mail', id: 8);

      // The ID field is found once per type, and read for each object:
      expect(cache.getEntityID(joe), equals(7));
      expect(cache.getEntityID(ann), equals(8));
      expect(
        cache.getEntityID(joe, idGetter: (o) => 'custom:${o.name}'),
        equals('custom:Joe'),
      );

      cache.cacheEntity(joe);
      cache.cacheEntity(ann);
      expect(
        cache.getCachedEntityByID(7, type: TestAccountWithReflection),
        same(joe),
      );
      expect(
        cache.getCachedEntityByID(8, type: TestAccountWithReflection),
        same(ann),
      );

      // A type without a registered reflection has no ID:
      expect(cache.getEntityID(Object()), isNull);

      // Without an `id` field: its first `int` field.
      var wideReflection = TestWideWithReflection$reflection();
      var wide = TestWideWithReflection(
        'a',
        'b',
        'c',
        mid: 'm',
        n1: 11,
        n2: 22,
      );
      var firstIntField = wideReflection
          .fieldsWhere((f) => f.type.isIntType)
          .first
          .name;
      expect(
        cache.getEntityID(wide),
        equals(wideReflection.getField(firstIntField, wide)),
      );
      expect(cache.getEntityID(wide), isIn([11, 22]));

      // Without an `id` or an `int` field: no ID (and not cached).
      TestRequiredNamedWithReflection$reflection();
      var named = TestRequiredNamedWithReflection(a: 'x');
      expect(cache.getEntityID(named), isNull);
      cache.cacheEntity(named);
      expect(cache.cachedEntitiesLength, equals(2));
    });
  });

  group('parameter shapes', () {
    test('many parameters of the same type: each in its position', () {
      var reflection = TestWideWithReflection$reflection();
      var c = reflection.constructor('')!;

      final full = <String, Object?>{
        'a': 'A',
        'b': 'B.',
        'c': 'C',
        'zeta': 'z',
        'alpha': 'al',
        'mid': 'm',
        'beta': 'be',
        'omega': 'om',
        'n1': 10,
        'n2': 20,
        'n3': 30,
      };

      // A value in the wrong position would fit (same type), so the values
      // are checked field by field, on every path:
      for (var o in [
        reflection.createInstanceWithConstructor(c, full)!,
        reflection.createInstanceWithConstructor(
          c,
          full,
          fieldValueResolver: _keepValue,
        )!,
        reflection.createInstanceWithConstructor(_withoutInvoker(c), full)!,
        reflection.createInstanceFromMap(full)!,
        reflection.createInstanceFromMap(
          full,
          valuesResolved: true,
          exactKeys: true,
        )!,
        TestWideWithReflection$fromJson(full),
      ]) {
        expect(reflection.getFieldsValues(o), equals(full));
      }

      // Omitted named parameters, each with its own default:
      var o = reflection.createInstanceFromMap({
        'a': 'A',
        'b': 'B.',
        'c': 'C',
        'mid': 'm',
      }, valuesResolved: true)!;
      expect(
        reflection.getFieldsValues(o),
        equals({
          'a': 'A',
          'b': 'B.',
          'c': 'C',
          'zeta': 'Z',
          'alpha': null,
          'mid': 'm',
          'beta': 'B',
          'omega': null,
          'n1': 1,
          'n2': 2,
          'n3': null,
        }),
      );

      _expectSameOutcomes(reflection, c, [
        full,
        {'a': 'A', 'b': 'B.', 'c': 'C', 'mid': 'm'},
        {'a': 'A', 'b': 'B.', 'c': 'C', 'mid': 'm', 'n2': 5},
        {'a': 'A', 'b': 'B.', 'c': 'C', 'mid': 'm', 'zeta': null},
        // The required named parameter missing:
        {'a': 'A', 'b': 'B.', 'c': 'C'},
        // Swapped types:
        {...full, 'n1': 'x', 'zeta': 1},
      ]);

      // Named parameters in any order in a `MethodInvocation`:
      var mi = MethodInvocation<TestWideWithReflection>(
        reflection,
        TestWideWithReflection,
        '',
        ['A', 'B.', 'C'],
        null,
        {'n3': 30, 'omega': 'om', 'mid': 'm', 'alpha': 'al', 'n1': 10},
      );
      expect(
        reflection.getFieldsValues(c.invokeWith(mi)),
        equals(reflection.getFieldsValues(_withoutInvoker(c).invokeWith(mi))),
      );
      expect(c.invokeWith(mi).n2, equals(2));
      expect(c.invokeWith(mi).zeta, equals('Z'));
    });

    test('generic classes, collections, enums, `Object?` and `dynamic`', () {
      var reflection = TestOrderWithReflection$reflection();
      var c = reflection.constructor('')!;

      var account = TestAccountWithReflection('Joe', 'joe@mail.com');
      var ref = TestRef<TestAccountWithReflection>(account);

      final full = <String, Object?>{
        'account': ref,
        'id': 1,
        'items': [account],
        'extra': {'a': 1},
        'meta': <String, dynamic>{'m': true},
        'notes': ['x', null],
        'matrix': [
          [1, 2],
          [3],
        ],
        'level': TestLevel.low,
        'date': createdAt,
        'any': 1,
        'raw': 'r',
      };

      _expectSameOutcomes(reflection, c, [
        {'account': ref},
        full,
        {...full, 'notes': null, 'level': null, 'raw': null},
        // Type arguments that don't fit:
        {'account': TestRef<Object?>(account)},
        {
          'account': ref,
          'items': <dynamic>[account],
        },
        {
          'account': ref,
          'extra': <dynamic, dynamic>{'a': 1},
        },
        {
          'account': ref,
          'matrix': [<dynamic>[]],
        },
        {'account': null},
        {},
      ]);

      _expectSameInAllModes(reflection, full);
      _expectSameInAllModes(reflection, {'account': ref});
      _expectSameInAllModes(reflection, {
        'account': ref,
        'items': <dynamic>[account],
      });

      // Values passed as they are (not copied):
      var o = reflection.createInstanceFromMap(full, valuesResolved: true)!;
      expect(identical(o.account, ref), isTrue);
      expect(identical(o.items, full['items']), isTrue);
      expect(o.notes, equals(['x', null]));
      expect(o.level, equals(TestLevel.low));

      // Omitted: `const []` typed as `List<String?>`:
      var o2 = reflection.createInstanceFromMap({
        'account': ref,
      }, valuesResolved: true)!;
      expect(o2.notes, isA<List<String?>>());
      expect(o2.notes, isEmpty);
    });

    test('record types', () {
      var reflection = TestRecordWithReflection$reflection();
      var c = reflection.constructor('')!;
      expect(c.invoker, isNotNull);

      _expectSameOutcomes(reflection, c, [
        {'pair': (1, 'a')},
        {'pair': (1, 'a'), 'point': (x: 1, y: 2)},
        {'pair': (1, 'a'), 'point': null},
        {'pair': (1, 2)},
        {'pair': (1, 'a'), 'point': (1, 2)},
        {'pair': null},
      ]);

      var o = reflection.createInstanceFromMap({
        'pair': (2, 'b'),
        'point': (x: 3, y: 4),
      }, valuesResolved: true)!;
      expect(o.pair, equals((2, 'b')));
      expect(o.point!.y, equals(4));
    });

    test('defaults: tear-offs, negatives, escapes, const instances', () {
      var reflection = TestEdgeDefaultsWithReflection$reflection();
      var c = reflection.constructor('')!;

      expect(
        c.namedParameters['mapper']!.defaultValue,
        equals(TestEdgeDefaultsWithReflection.identity),
      );

      var expected = TestEdgeDefaultsWithReflection();

      for (var o in [
        reflection.createInstanceFromMap({})!,
        reflection.createInstanceFromMap({}, valuesResolved: true)!,
        reflection.createInstanceWithConstructor(
          c,
          {},
          fieldValueResolver: _keepValue,
        )!,
        reflection.createInstanceWithConstructor(_withoutInvoker(c), {})!,
        TestEdgeDefaultsWithReflection$fromJson({}),
      ]) {
        expect(o.mapper(2), equals(2));
        expect(o.mapper2(2), equals(6));
        expect(o.neg, equals(-3));
        expect(o.negD, isA<double>());
        expect(o.negD, equals(-1.0));
        expect(o.text, equals(expected.text));
        expect(o.text, equals('a\$b "q" \'s\' \\n'));
        expect(o.levels, equals([TestLevel.low, TestLevel.high]));
        expect(o.levels, isA<List<TestLevel>>());
        expect(o.byLevel, isA<Map<TestLevel, List<String>>>());
        expect(o.byLevel, equals(expected.byLevel));
        expect(o.ref, isA<TestRef<int>>());
        expect(o.ref, equals(const TestRef(1)));
      }

      int negate(int n) => -n;

      var o = reflection.createInstanceFromMap({
        'mapper': negate,
        'neg': 5,
      }, valuesResolved: true)!;
      expect(o.mapper(2), equals(-2));
      expect(o.neg, equals(5));
      expect(o.mapper2(1), equals(3));
    });

    test('constructor kinds: const, factory, redirecting', () {
      var reflection = TestCtorKindsWithReflection$reflection();

      expect(
        reflection.constructorsNames,
        containsAll(['', 'parse', 'redirect', 'redirectingFactory']),
      );

      for (var name in reflection.constructorsNames) {
        expect(
          reflection.constructor(name)!.invoker,
          isNotNull,
          reason: 'constructor: $name',
        );
      }

      _expectSameOutcomes(reflection, reflection.constructor('')!, [
        {'kind': 'k', 'n': 2},
        {'kind': 'k'},
        {'n': 2},
      ]);
      _expectSameOutcomes(reflection, reflection.constructor('parse')!, [
        {'s': '5'},
        // A `FormatException` thrown by the factory:
        {'s': 'x'},
        {'s': 5},
      ]);
      _expectSameOutcomes(reflection, reflection.constructor('redirect')!, [
        {'n': 3},
        {'n': null},
      ]);
      _expectSameOutcomes(
        reflection,
        reflection.constructor('redirectingFactory')!,
        [
          {'n': 4},
        ],
      );

      var o = reflection.createInstanceWithConstructor(
        reflection.constructor('redirectingFactory')!,
        {'n': 4},
      )!;
      expect(o.kind, equals('private'));
      expect(o.n, equals(4));
      expect(
        reflection.getFieldsValues(o),
        equals(
          reflection.getFieldsValues(TestCtorKindsWithReflection.privateOf(4)),
        ),
      );

      var parsed = reflection.createInstanceWithConstructor(
        reflection.constructor('parse')!,
        {'s': '7'},
      )!;
      expect(parsed.kind, equals('parsed'));
      expect(parsed.n, equals(7));
    });
  });

  group('constructor choice', () {
    test('the first constructor that fits the value', () {
      var reflection = TestMultiCtorWithReflection$reflection();

      // Alternating, so the constructors sorted by usage change order:
      for (var i = 0; i < 3; ++i) {
        for (var (value, kind) in [(1, 'int'), ('x', 'string')]) {
          var outcome = _expectSameInAllModes(reflection, {'value': value});
          expect(outcome, equals({'value': value, 'kind': kind}));
        }
      }

      // No constructor fits: the same error on every path.
      var outcome = _expectSameInAllModes(reflection, {'value': true});
      expect(outcome, isNot(isA<Map>()));
    });

    test('@JsonConstructor (not mandatory)', () {
      var reflection = TestJsonCtorWithReflection$reflection();
      expect(reflection.hasJsonConstructor, isTrue);

      for (var map in <Map<String, Object?>>[
        {'name': 'n'},
        {'name': 'n', 'qty': 2, 'note': 'x'},
        {'name': 'n', 'qty': null},
        {'name': 'n', 'qty': 'x'},
        {'qty': 2},
        {},
      ]) {
        _expectSameInAllModes(reflection, map);
      }

      var o = reflection.createInstanceFromMap({
        'name': 'n',
      }, valuesResolved: true)!;
      expect(o.qty, equals(1));
      expect(o.note, isNull);

      // A JSON round trip:
      var o2 = TestJsonCtorWithReflection.full('a', 3, 'b');
      var json = reflection.withObject(o2).toJsonMap();
      var o3 = TestJsonCtorWithReflection$fromJson(json!);
      expect(
        reflection.getFieldsValues(o3),
        equals(reflection.getFieldsValues(o2)),
      );
      expect(
        reflection.getFieldsValues(
          TestJsonCtorWithReflection$fromJson({'name': 'n'}),
        ),
        equals({'name': 'n', 'qty': 1, 'note': null}),
      );
    });

    test('JSON name aliases (MethodInvocation path in every mode)', () {
      var reflection = TestUserWithReflection$reflection();

      for (var map in <Map<String, Object?>>[
        {
          'name': 'Joe',
          'email': 'joe@mail.com',
          'passphrase': ' 123 ',
          'level': 2,
          'id': 7,
        },
        {
          'name': 'Joe',
          'email': 'joe@mail.com',
          'password': ' 123 ',
          'theLevel': 2,
        },
        {'name': 'Joe', 'email': null, 'password': null},
      ]) {
        _expectSameInAllModes(reflection, map);
      }
    });
  });

  group('field setters (create + set fields)', () {
    test('final, nullable with an initial value, and lists', () {
      var reflection = TestSettersWithReflection$reflection();

      var outcome = _expectSameInAllModes(reflection, {
        'phone': null,
        'count': 2,
        'tags': ['a'],
      });
      // A `null` value sets a nullable field to `null`:
      expect(
        outcome,
        equals({
          'code': 'c',
          'phone': null,
          'count': 2,
          'tags': ['a'],
        }),
      );

      // A `null` value for a non-nullable field is ignored:
      outcome = _expectSameInAllModes(reflection, {'count': null});
      expect(outcome, containsPair('count', 0));
      expect(outcome, containsPair('phone', 'initial'));

      // A final field can't be set:
      outcome = _expectSameInAllModes(reflection, {'code': 'x', 'count': 1});
      var (errorType, message) = outcome as (Type, String);
      expect(errorType, equals(StateError));
      expect(message, contains('final field `code`'));

      _expectSameInAllModes(reflection, {'phone': 'p'});
      _expectSameInAllModes(reflection, {'count': 'x'});

      // Resolved by `fromJson` (with a `fieldValueResolver`), but not when
      // passed as resolved:
      var json = <String, Object?>{
        'tags': <dynamic>['a'],
      };
      expect(TestSettersWithReflection$fromJson(json).tags, equals(['a']));
      expect(
        () => reflection.createInstanceFromMap(json, valuesResolved: true),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('usage patterns', () {
    // A `fieldNameResolver` as an ORM gives one: exact keys first, then
    // ignoring case and `_` (`created_at` -> `createdAt`).
    String? simpleNames(String field, Map<String, Object?> map) {
      if (map.containsKey(field)) return field;
      String simple(String s) => s.replaceAll('_', '').toLowerCase();
      var f = simple(field);
      for (var k in map.keys) {
        if (simple(k) == f) return k;
      }
      return null;
    }

    test('valuesResolved with a fieldNameResolver', () {
      var account = TestAccountWithReflection$reflection();

      final row = <String, Object?>{
        'id': 1,
        'NAME': 'Joe',
        'email': 'joe@mail.com',
        'Phone': null,
        'age': 30,
        'score': 1.5,
        'ACTIVE': false,
        'created_at': createdAt,
      };

      var outcome = _expectSameInAllModes(
        account,
        row,
        fieldNameResolver: simpleNames,
      );
      expect(
        outcome,
        equals({
          'id': 1,
          'name': 'Joe',
          'email': 'joe@mail.com',
          'phone': null,
          'age': 30,
          'score': 1.5,
          'active': false,
          'createdAt': createdAt,
        }),
      );

      // Set through the fields (`create()` + setters):
      var member = TestMemberWithReflection$reflection();
      outcome = _expectSameInAllModes(member, {
        'id': 2,
        'name': 'Ann',
        'email': 'ann@mail.com',
        'password_hash': 'h',
        'age': 41,
        'score': 7.25,
        'active': true,
        'created_at': createdAt,
      }, fieldNameResolver: simpleNames);
      expect(outcome, containsPair('passwordHash', 'h'));
      expect(outcome, containsPair('createdAt', createdAt));
    });

    test('alternating key shapes and modes on one reflection', () {
      var reflection = TestAccountWithReflection$reflection();
      var member = TestMemberWithReflection$reflection();

      final cases = <(ClassReflection, Map<String, Object?>, bool)>[
        (reflection, {'name': 'a', 'email': 'e'}, false),
        (reflection, {'name': 'a', 'email': 'e'}, true),
        (reflection, {'NAME': 'a', 'email': 'e'}, false),
        (reflection, {'NAME': 'a', 'email': 'e'}, true),
        (reflection, {'name': 'a', 'email': 'e', 'age': 3}, true),
        (reflection, {'name': 'a', 'email': 'e', 'age': 'x'}, false),
        (reflection, {'email': 'e'}, true),
        (member, {'name': 'a', 'email': 'e', 'passwordHash': 'h'}, true),
        (member, {'name': 'a', 'email': 'e', 'passwordOrHash': 'h'}, true),
        (member, {'NAME': 'a', 'passwordHash': 'h'}, false),
      ];

      Object? run((ClassReflection, Map<String, Object?>, bool) c) {
        var (r, map, resolved) = c;
        return _outcome(
          r,
          () => r.createInstanceFromMap(
            map,
            valuesResolved: resolved,
            exactKeys: resolved,
          ),
        );
      }

      // The same outcomes in any order (the constructors are cached by the
      // map shape, and the last lookup is reused):
      var forward = cases.map(run).toList();
      var backward = cases.reversed.map(run).toList().reversed.toList();
      var again = cases.map(run).toList();

      expect(backward, equals(forward));
      expect(again, equals(forward));

      // Keys only matched ignoring case aren't used with `exactKeys`:
      expect(forward[2], isA<Map>());
      expect(forward[3], isNull);
    });

    test('a reflection from the ReflectionFactory registry', () {
      TestOrderWithReflection$reflection();

      var reflection = ReflectionFactory()
          .getRegisterClassReflection<TestOrderWithReflection>(
            TestOrderWithReflection,
          )!;

      expect(reflection.constructor('')!.invoker, isNotNull);

      var account = TestAccountWithReflection('Joe', 'joe@mail.com');
      var o = reflection.createInstanceFromMap({
        'account': TestRef(account),
        'id': 3,
      }, valuesResolved: true)!;
      expect(o.id, equals(3));
      expect(o.account.value, same(account));
    });

    test('parameters named as fields have the fields\' types', () {
      // An ORM can resolve values by field type before instantiating (and
      // pass them with `valuesResolved`) when each constructor parameter
      // named as a field has that field's type:
      for (var reflection in <ClassReflection>[
        TestAccountWithReflection$reflection(),
        TestOrderWithReflection$reflection(),
        TestWideWithReflection$reflection(),
        TestRecordWithReflection$reflection(),
      ]) {
        for (var c in reflection.allConstructors()) {
          for (var p in c.allParameters) {
            var field = reflection.field(p.name);
            if (field == null) continue;
            expect(
              p.type.typeInfo,
              equals(field.type.typeInfo),
              reason: '${reflection.className}.${c.name}(${p.name})',
            );
          }
        }
      }

      // Not for a field inherited with a type argument (as in `2.11.0`): the
      // field's `TypeReflection` is its declared type (`List<T>` as
      // `List<dynamic>`), and the parameter's is `List<int>`. Such classes
      // keep resolving values per parameter (a `fieldValueResolver`).
      var intBox = TestIntBoxWithReflection$reflection();
      expect(
        intBox.constructor('')!.normalParameters.single.type.typeInfo,
        equals(TypeReflection.tListInt.typeInfo),
      );
      var items = intBox.field('items')!;
      expect(items.type.typeInfo, equals(TypeReflection.tListDynamic.typeInfo));
      // While the `FieldReflection` itself has the type argument:
      expect(
        items,
        isA<FieldReflection<TestIntBoxWithReflection, List<int>>>(),
      );
    });
  });
}
