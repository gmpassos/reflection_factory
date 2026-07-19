import 'package:reflection_factory/reflection_factory.dart';
import 'package:test/test.dart';

class _RecordingListener implements ClassProxyListener<String> {
  final calls = <List<Object?>>[];

  Object? response;

  @override
  Object? onCall(
    String instance,
    String methodName,
    Map<String, dynamic> parameters,
    TypeReflection? returnType,
  ) {
    calls.add([instance, methodName, parameters, returnType]);
    return response;
  }
}

void main() {
  group('ClassProxy.returnValue', () {
    test('returns a matching value', () {
      expect(ClassProxy.returnValue<int>(123), equals(123));
      expect(ClassProxy.returnValue<String>('abc'), equals('abc'));
    });

    test('accepts null for a nullable type', () {
      expect(ClassProxy.returnValue<int?>(null), isNull);
    });

    test('throws ClassProxyCallError on a type mismatch', () {
      expect(
        () => ClassProxy.returnValue<int>('not an int'),
        throwsA(isA<ClassProxyCallError>()),
      );
      expect(
        () => ClassProxy.returnValue<int>(null),
        throwsA(isA<ClassProxyCallError>()),
      );
    });
  });

  group('ClassProxy.returnFuture', () {
    test('passes through a matching Future', () async {
      var f = Future<int>.value(10);
      expect(ClassProxy.returnFuture<int>(f), same(f));
      expect(await ClassProxy.returnFuture<int>(f), equals(10));
    });

    test('wraps a plain value into a Future', () async {
      var f = ClassProxy.returnFuture<int>(21);
      expect(f, isA<Future<int>>());
      expect(await f, equals(21));
    });

    test('adapts a Future of another static type', () async {
      // `Future<Object>` holding an `int` is not a `Future<int>`.
      Future<Object> f = Future<Object>.value(7);
      expect(await ClassProxy.returnFuture<int>(f), equals(7));
    });

    test('throws when the awaited value has the wrong type', () {
      Future<Object> f = Future<Object>.value('nope');
      expect(
        ClassProxy.returnFuture<int>(f),
        throwsA(isA<ClassProxyCallError>()),
      );
    });

    test('throws when a plain value has the wrong type', () {
      expect(
        () => ClassProxy.returnFuture<int>('nope'),
        throwsA(isA<ClassProxyCallError>()),
      );
    });
  });

  group('ClassProxy.returnFutureOr', () {
    test('passes through a matching Future', () async {
      var f = Future<int>.value(10);
      expect(ClassProxy.returnFutureOr<int>(f), same(f));
    });

    test('returns a plain matching value synchronously', () {
      expect(ClassProxy.returnFutureOr<int>(5), equals(5));
    });

    test('adapts a Future of another static type', () async {
      Future<Object> f = Future<Object>.value(7);
      expect(await ClassProxy.returnFutureOr<int>(f), equals(7));
    });

    test('throws when the awaited value has the wrong type', () {
      Future<Object> f = Future<Object>.value('nope');
      expect(
        ClassProxy.returnFutureOr<int>(f) as Future,
        throwsA(isA<ClassProxyCallError>()),
      );
    });

    test('throws when a plain value has the wrong type', () {
      expect(
        () => ClassProxy.returnFutureOr<int>('nope'),
        throwsA(isA<ClassProxyCallError>()),
      );
    });
  });

  group('ClassProxyCallError', () {
    test('is a StateError with a descriptive message', () {
      var error = ClassProxyCallError.returnedValueError(int, 'abc');
      expect(error, isA<StateError>());
      expect(error.message, contains('int'));
      expect(error.message, contains('abc'));
    });

    test('plain constructor keeps the message', () {
      expect(ClassProxyCallError('my message').message, equals('my message'));
    });
  });

  group('ClassProxyDelegateListener', () {
    test('delegates onCall to the target listener', () {
      var target = _RecordingListener()..response = 'result';
      var delegate = ClassProxyDelegateListener<String>(target);

      expect(delegate.targetListener, same(target));

      var returnType = TypeReflection.tString;
      var ret = delegate.onCall('inst', 'myMethod', {'a': 1}, returnType);

      expect(ret, equals('result'));
      expect(target.calls, hasLength(1));
      expect(
        target.calls.first,
        equals([
          'inst',
          'myMethod',
          {'a': 1},
          returnType,
        ]),
      );
    });
  });

  group('EnableReflection', () {
    test('defaults', () {
      const a = EnableReflection();
      expect(a.reflectionClassName, isEmpty);
      expect(a.reflectionExtensionName, isEmpty);
      expect(a.optimizeReflectionInstances, isTrue);
    });

    test('custom values', () {
      const a = EnableReflection(
        reflectionClassName: 'MyClass',
        reflectionExtensionName: 'MyExt',
        optimizeReflectionInstances: false,
      );
      expect(a.reflectionClassName, equals('MyClass'));
      expect(a.reflectionExtensionName, equals('MyExt'));
      expect(a.optimizeReflectionInstances, isFalse);
    });
  });

  group('ReflectionBridge', () {
    test('defaults', () {
      const a = ReflectionBridge([int, String]);
      expect(a.classesTypes, equals([int, String]));
      expect(a.bridgeExtensionName, isEmpty);
      expect(a.reflectionClassNames, isEmpty);
      expect(a.reflectionExtensionNames, isEmpty);
      expect(a.optimizeReflectionInstances, isTrue);
    });

    test('custom values', () {
      const a = ReflectionBridge(
        [int],
        bridgeExtensionName: 'BridgeExt',
        reflectionClassNames: {int: 'IntRefl'},
        reflectionExtensionNames: {int: 'IntReflExt'},
        optimizeReflectionInstances: false,
      );
      expect(a.bridgeExtensionName, equals('BridgeExt'));
      expect(a.reflectionClassNames, equals({int: 'IntRefl'}));
      expect(a.reflectionExtensionNames, equals({int: 'IntReflExt'}));
      expect(a.optimizeReflectionInstances, isFalse);
    });
  });

  group('ClassProxy annotation', () {
    test('defaults', () {
      const a = ClassProxy('MyClass');
      expect(a.className, equals('MyClass'));
      expect(a.libraryName, isEmpty);
      expect(a.libraryPath, isEmpty);
      expect(a.reflectionProxyName, isEmpty);
      expect(a.alwaysReturnFuture, isFalse);
      expect(a.traverseReturnTypes, isEmpty);
      expect(a.ignoreParametersTypes, isEmpty);
      expect(a.ignoreMethods, isEmpty);
      expect(a.ignoreMethods2, isEmpty);
    });

    test('custom values', () {
      const a = ClassProxy(
        'MyClass',
        libraryName: 'my_lib',
        libraryPath: 'package:my/my.dart',
        reflectionProxyName: 'MyProxy',
        ignoreMethods: {'a'},
        ignoreMethods2: {'b'},
        alwaysReturnFuture: true,
        traverseReturnTypes: {int},
        ignoreParametersTypes: {String},
      );
      expect(a.libraryName, equals('my_lib'));
      expect(a.libraryPath, equals('package:my/my.dart'));
      expect(a.reflectionProxyName, equals('MyProxy'));
      expect(a.ignoreMethods, equals({'a'}));
      expect(a.ignoreMethods2, equals({'b'}));
      expect(a.alwaysReturnFuture, isTrue);
      expect(a.traverseReturnTypes, equals({int}));
      expect(a.ignoreParametersTypes, equals({String}));
    });

    test('IgnoreClassProxyMethod is instantiable', () {
      expect(const IgnoreClassProxyMethod(), isA<IgnoreClassProxyMethod>());
    });
  });

  group('JsonField', () {
    test('default is visible', () {
      const f = JsonField();
      expect(f.isHidden, isFalse);
      expect(f.isVisible, isTrue);
      expect(f, isA<JsonAnnotation>());
    });

    test('hidden constructor', () {
      const f = JsonField.hidden();
      expect(f.isHidden, isTrue);
      expect(f.isVisible, isFalse);
    });

    test('visible constructor', () {
      const f = JsonField.visible();
      expect(f.isHidden, isFalse);
      expect(f.isVisible, isTrue);
    });

    test('hidden parameter', () {
      expect(const JsonField(hidden: true).isHidden, isTrue);
      expect(const JsonField(hidden: false).isHidden, isFalse);
    });
  });

  group('IterableJsonFieldExtension', () {
    test('hasHidden / hasVisible', () {
      expect(<JsonField>[].hasHidden, isFalse);
      expect(<JsonField>[].hasVisible, isFalse);

      expect(const [JsonField.hidden()].hasHidden, isTrue);
      expect(const [JsonField.hidden()].hasVisible, isFalse);

      expect(const [JsonField.visible()].hasHidden, isFalse);
      expect(const [JsonField.visible()].hasVisible, isTrue);

      const mixed = [JsonField.hidden(), JsonField.visible()];
      expect(mixed.hasHidden, isTrue);
      expect(mixed.hasVisible, isTrue);
    });
  });

  group('JsonFieldAlias', () {
    test('valid names', () {
      expect(const JsonFieldAlias('name').isValid, isTrue);
      expect(const JsonFieldAlias('_name').isValid, isTrue);
      expect(const JsonFieldAlias('name1').isValid, isTrue);
      expect(const JsonFieldAlias('Name_1').isValid, isTrue);
    });

    test('invalid names', () {
      expect(const JsonFieldAlias('').isValid, isFalse);
      expect(const JsonFieldAlias('  ').isValid, isFalse);
      // Not trimmed:
      expect(const JsonFieldAlias(' name').isValid, isFalse);
      expect(const JsonFieldAlias('name ').isValid, isFalse);
      // Can't start with a digit:
      expect(const JsonFieldAlias('1name').isValid, isFalse);
      // Invalid characters:
      expect(const JsonFieldAlias('na-me').isValid, isFalse);
      expect(const JsonFieldAlias('na me').isValid, isFalse);
    });

    test('keeps the name', () {
      expect(const JsonFieldAlias('foo').name, equals('foo'));
    });
  });

  group('IterableJsonFieldAliasExtension', () {
    test('valid / validNames filter out invalid aliases', () {
      const list = [
        JsonFieldAlias('ok'),
        JsonFieldAlias('1bad'),
        JsonFieldAlias('also_ok'),
      ];
      expect(list.valid, hasLength(2));
      expect(list.validNames, equals(['ok', 'also_ok']));
    });

    test('alias is null when empty', () {
      expect(<JsonFieldAlias>[].alias, isNull);
    });

    test('alias is null when there are no valid aliases', () {
      expect(const [JsonFieldAlias('1bad')].alias, isNull);
    });

    test('alias returns the single valid name', () {
      expect(const [JsonFieldAlias('foo')].alias, equals('foo'));
      expect(
        const [JsonFieldAlias('foo'), JsonFieldAlias('1bad')].alias,
        equals('foo'),
      );
    });

    test('alias tolerates repeated identical names', () {
      expect(
        const [JsonFieldAlias('foo'), JsonFieldAlias('foo')].alias,
        equals('foo'),
      );
    });

    test('alias throws on conflicting names', () {
      expect(
        () => const [JsonFieldAlias('foo'), JsonFieldAlias('bar')].alias,
        throwsA(isA<StateError>()),
      );
    });
  });

  group('JsonConstructor', () {
    test('defaults to non mandatory', () {
      const c = JsonConstructor();
      expect(c.mandatory, isFalse);
      expect(c, isA<JsonAnnotation>());
    });

    test('mandatory', () {
      expect(const JsonConstructor(mandatory: true).mandatory, isTrue);
    });
  });
}
