//
// GENERATED CODE - DO NOT MODIFY BY HAND!
// BUILDER: reflection_factory/2.0.3
// BUILD COMMAND: dart run build_runner build
//

// coverage:ignore-file
// ignore_for_file: unused_element
// ignore_for_file: unnecessary_const
// ignore_for_file: unnecessary_cast
// ignore_for_file: unnecessary_type_check

part of 'user_reflection_bridge.dart';

typedef __TR<T> = TypeReflection<T>;
typedef __TI<T> = TypeInfo<T>;
typedef __PR = ParameterReflection;

mixin __ReflectionMixin {
  static final Version _version = Version.parse('2.0.3');

  Version get reflectionFactoryVersion => _version;

  List<Reflection> siblingsReflection() => _siblingsReflection();
}

// ignore: non_constant_identifier_names
TestAddress TestAddress$fromJson(Map<String, Object?> map) =>
    TestAddress$reflection.staticInstance.fromJson(map);
// ignore: non_constant_identifier_names
TestAddress TestAddress$fromJsonEncoded(String jsonEncoded) =>
    TestAddress$reflection.staticInstance.fromJsonEncoded(jsonEncoded);
// ignore: non_constant_identifier_names
TestUserSimple TestUserSimple$fromJson(Map<String, Object?> map) =>
    TestUserSimple$reflection.staticInstance.fromJson(map);
// ignore: non_constant_identifier_names
TestUserSimple TestUserSimple$fromJsonEncoded(String jsonEncoded) =>
    TestUserSimple$reflection.staticInstance.fromJsonEncoded(jsonEncoded);

class TestAddress$reflection extends ClassReflection<TestAddress>
    with __ReflectionMixin {
  static final Expando<TestAddress$reflection> _objectReflections = Expando();

  factory TestAddress$reflection([TestAddress? object]) {
    if (object == null) return staticInstance;
    return _objectReflections[object] ??= TestAddress$reflection._(object);
  }

  TestAddress$reflection._([TestAddress? object])
      : super(TestAddress, 'TestAddress', object);

  static bool _registered = false;
  @override
  void register() {
    if (!_registered) {
      _registered = true;
      super.register();
      _registerSiblingsReflection();
    }
  }

  @override
  Version get languageVersion => Version.parse('2.17.0');

  @override
  TestAddress$reflection withObject([TestAddress? obj]) =>
      TestAddress$reflection(obj);

  static TestAddress$reflection? _withoutObjectInstance;
  @override
  TestAddress$reflection withoutObjectInstance() => _withoutObjectInstance ??=
      super.withoutObjectInstance() as TestAddress$reflection;

  static TestAddress$reflection get staticInstance =>
      _withoutObjectInstance ??= TestAddress$reflection._();

  @override
  TestAddress$reflection getStaticInstance() => staticInstance;

  static bool _boot = false;
  static void boot() {
    if (_boot) return;
    _boot = true;
    TestAddress$reflection.staticInstance;
  }

  @override
  bool get hasDefaultConstructor => false;
  @override
  TestAddress? createInstanceWithDefaultConstructor() => null;

  @override
  bool get hasEmptyConstructor => false;
  @override
  TestAddress? createInstanceWithEmptyConstructor() => null;
  @override
  bool get hasNoRequiredArgsConstructor => false;
  @override
  TestAddress? createInstanceWithNoRequiredArgsConstructor() => null;

  @override
  List<String> get constructorsNames => const <String>[''];

  static final Map<String, ConstructorReflection<TestAddress>> _constructors =
      <String, ConstructorReflection<TestAddress>>{};

  @override
  ConstructorReflection<TestAddress>? constructor(String constructorName) {
    var c = _constructors[constructorName];
    if (c != null) return c;
    c = _constructorImpl(constructorName);
    if (c == null) return null;
    _constructors[constructorName] = c;
    return c;
  }

  ConstructorReflection<TestAddress>? _constructorImpl(String constructorName) {
    var lc = constructorName.trim().toLowerCase();

    switch (lc) {
      case '':
        return ConstructorReflection<TestAddress>(
            this,
            TestAddress,
            '',
            () => (String state, String city) => TestAddress(state, city),
            const <__PR>[
              __PR(__TR.tString, 'state', false, true),
              __PR(__TR.tString, 'city', false, true)
            ],
            null,
            null,
            null);
      default:
        return null;
    }
  }

  @override
  List<Object> get classAnnotations => List<Object>.unmodifiable(<Object>[]);

  @override
  List<Type> get supperTypes => const <Type>[];

  @override
  bool get hasMethodToJson => true;

  @override
  Object? callMethodToJson([TestAddress? obj]) {
    obj ??= object;
    return obj?.toJson();
  }

  @override
  List<String> get fieldsNames => const <String>['city', 'hashCode', 'state'];

  static final Map<String, FieldReflection<TestAddress, dynamic>>
      _fieldsNoObject = <String, FieldReflection<TestAddress, dynamic>>{};

  final Map<String, FieldReflection<TestAddress, dynamic>> _fieldsObject =
      <String, FieldReflection<TestAddress, dynamic>>{};

  @override
  FieldReflection<TestAddress, T>? field<T>(String fieldName,
      [TestAddress? obj]) {
    if (obj == null) {
      if (object != null) {
        return _fieldObjectImpl<T>(fieldName);
      } else {
        return _fieldNoObjectImpl<T>(fieldName);
      }
    } else if (identical(obj, object)) {
      return _fieldObjectImpl<T>(fieldName);
    }
    return _fieldNoObjectImpl<T>(fieldName)?.withObject(obj);
  }

  FieldReflection<TestAddress, T>? _fieldNoObjectImpl<T>(String fieldName) {
    final f = _fieldsNoObject[fieldName];
    if (f != null) {
      return f as FieldReflection<TestAddress, T>;
    }
    final f2 = _fieldImpl(fieldName, null);
    if (f2 == null) return null;
    _fieldsNoObject[fieldName] = f2;
    return f2 as FieldReflection<TestAddress, T>;
  }

  FieldReflection<TestAddress, T>? _fieldObjectImpl<T>(String fieldName) {
    final f = _fieldsObject[fieldName];
    if (f != null) {
      return f as FieldReflection<TestAddress, T>;
    }
    var f2 = _fieldNoObjectImpl<T>(fieldName);
    if (f2 == null) return null;
    f2 = f2.withObject(object!);
    _fieldsObject[fieldName] = f2;
    return f2;
  }

  FieldReflection<TestAddress, dynamic>? _fieldImpl(
      String fieldName, TestAddress? obj) {
    obj ??= object;

    var lc = fieldName.trim().toLowerCase();

    switch (lc) {
      case 'state':
        return FieldReflection<TestAddress, String>(
          this,
          TestAddress,
          __TR.tString,
          'state',
          false,
          (o) => () => o!.state,
          null,
          obj,
          false,
          true,
        );
      case 'city':
        return FieldReflection<TestAddress, String>(
          this,
          TestAddress,
          __TR.tString,
          'city',
          false,
          (o) => () => o!.city,
          null,
          obj,
          false,
          true,
        );
      case 'hashcode':
        return FieldReflection<TestAddress, int>(
          this,
          TestAddress,
          __TR.tInt,
          'hashCode',
          false,
          (o) => () => o!.hashCode,
          null,
          obj,
          false,
          false,
          [override],
        );
      default:
        return null;
    }
  }

  @override
  List<String> get staticFieldsNames => const <String>[];

  @override
  FieldReflection<TestAddress, T>? staticField<T>(String fieldName) => null;

  @override
  List<String> get methodsNames => const <String>['toJson'];

  static final Map<String, MethodReflection<TestAddress, dynamic>>
      _methodsNoObject = <String, MethodReflection<TestAddress, dynamic>>{};

  final Map<String, MethodReflection<TestAddress, dynamic>> _methodsObject =
      <String, MethodReflection<TestAddress, dynamic>>{};

  @override
  MethodReflection<TestAddress, R>? method<R>(String methodName,
      [TestAddress? obj]) {
    if (obj == null) {
      if (object != null) {
        return _methodObjectImpl<R>(methodName);
      } else {
        return _methodNoObjectImpl<R>(methodName);
      }
    } else if (identical(obj, object)) {
      return _methodObjectImpl<R>(methodName);
    }
    return _methodNoObjectImpl<R>(methodName)?.withObject(obj);
  }

  MethodReflection<TestAddress, R>? _methodNoObjectImpl<R>(String methodName) {
    final m = _methodsNoObject[methodName];
    if (m != null) {
      return m as MethodReflection<TestAddress, R>;
    }
    final m2 = _methodImpl(methodName, null);
    if (m2 == null) return null;
    _methodsNoObject[methodName] = m2;
    return m2 as MethodReflection<TestAddress, R>;
  }

  MethodReflection<TestAddress, R>? _methodObjectImpl<R>(String methodName) {
    final m = _methodsObject[methodName];
    if (m != null) {
      return m as MethodReflection<TestAddress, R>;
    }
    var m2 = _methodNoObjectImpl<R>(methodName);
    if (m2 == null) return null;
    m2 = m2.withObject(object!);
    _methodsObject[methodName] = m2;
    return m2;
  }

  MethodReflection<TestAddress, dynamic>? _methodImpl(
      String methodName, TestAddress? obj) {
    obj ??= object;

    var lc = methodName.trim().toLowerCase();

    switch (lc) {
      case 'tojson':
        return MethodReflection<TestAddress, Map<String, dynamic>>(
            this,
            TestAddress,
            'toJson',
            __TR.tMapStringDynamic,
            false,
            (o) => o!.toJson,
            obj,
            false,
            null,
            null,
            null,
            null);
      default:
        return null;
    }
  }

  @override
  List<String> get staticMethodsNames => const <String>[];

  @override
  MethodReflection<TestAddress, R>? staticMethod<R>(String methodName) => null;
}

class TestUserSimple$reflection extends ClassReflection<TestUserSimple>
    with __ReflectionMixin {
  static final Expando<TestUserSimple$reflection> _objectReflections =
      Expando();

  factory TestUserSimple$reflection([TestUserSimple? object]) {
    if (object == null) return staticInstance;
    return _objectReflections[object] ??= TestUserSimple$reflection._(object);
  }

  TestUserSimple$reflection._([TestUserSimple? object])
      : super(TestUserSimple, 'TestUserSimple', object);

  static bool _registered = false;
  @override
  void register() {
    if (!_registered) {
      _registered = true;
      super.register();
      _registerSiblingsReflection();
    }
  }

  @override
  Version get languageVersion => Version.parse('2.17.0');

  @override
  TestUserSimple$reflection withObject([TestUserSimple? obj]) =>
      TestUserSimple$reflection(obj);

  static TestUserSimple$reflection? _withoutObjectInstance;
  @override
  TestUserSimple$reflection withoutObjectInstance() =>
      _withoutObjectInstance ??=
          super.withoutObjectInstance() as TestUserSimple$reflection;

  static TestUserSimple$reflection get staticInstance =>
      _withoutObjectInstance ??= TestUserSimple$reflection._();

  @override
  TestUserSimple$reflection getStaticInstance() => staticInstance;

  static bool _boot = false;
  static void boot() {
    if (_boot) return;
    _boot = true;
    TestUserSimple$reflection.staticInstance;
  }

  @override
  bool get hasDefaultConstructor => false;
  @override
  TestUserSimple? createInstanceWithDefaultConstructor() => null;

  @override
  bool get hasEmptyConstructor => true;
  @override
  TestUserSimple? createInstanceWithEmptyConstructor() =>
      TestUserSimple.empty();
  @override
  bool get hasNoRequiredArgsConstructor => true;
  @override
  TestUserSimple? createInstanceWithNoRequiredArgsConstructor() =>
      TestUserSimple.empty();

  @override
  List<String> get constructorsNames => const <String>['', 'empty'];

  static final Map<String, ConstructorReflection<TestUserSimple>>
      _constructors = <String, ConstructorReflection<TestUserSimple>>{};

  @override
  ConstructorReflection<TestUserSimple>? constructor(String constructorName) {
    var c = _constructors[constructorName];
    if (c != null) return c;
    c = _constructorImpl(constructorName);
    if (c == null) return null;
    _constructors[constructorName] = c;
    return c;
  }

  ConstructorReflection<TestUserSimple>? _constructorImpl(
      String constructorName) {
    var lc = constructorName.trim().toLowerCase();

    switch (lc) {
      case '':
        return ConstructorReflection<TestUserSimple>(
            this,
            TestUserSimple,
            '',
            () => (String name, String? email, String password) =>
                TestUserSimple(name, email, password),
            const <__PR>[
              __PR(__TR.tString, 'name', false, true),
              __PR(__TR.tString, 'email', true, true),
              __PR(__TR.tString, 'password', false, true)
            ],
            null,
            null,
            null);
      case 'empty':
        return ConstructorReflection<TestUserSimple>(
            this,
            TestUserSimple,
            'empty',
            () => () => TestUserSimple.empty(),
            null,
            null,
            null,
            null);
      default:
        return null;
    }
  }

  static const List<Object> _classAnnotations = [
    TestAnnotation(['class', 'user'])
  ];

  @override
  List<Object> get classAnnotations =>
      List<Object>.unmodifiable(_classAnnotations);

  @override
  List<Type> get supperTypes => const <Type>[];

  @override
  bool get hasMethodToJson => false;

  @override
  Object? callMethodToJson([TestUserSimple? obj]) => null;

  @override
  List<String> get fieldsNames =>
      const <String>['email', 'hashCode', 'name', 'password'];

  static final Map<String, FieldReflection<TestUserSimple, dynamic>>
      _fieldsNoObject = <String, FieldReflection<TestUserSimple, dynamic>>{};

  final Map<String, FieldReflection<TestUserSimple, dynamic>> _fieldsObject =
      <String, FieldReflection<TestUserSimple, dynamic>>{};

  @override
  FieldReflection<TestUserSimple, T>? field<T>(String fieldName,
      [TestUserSimple? obj]) {
    if (obj == null) {
      if (object != null) {
        return _fieldObjectImpl<T>(fieldName);
      } else {
        return _fieldNoObjectImpl<T>(fieldName);
      }
    } else if (identical(obj, object)) {
      return _fieldObjectImpl<T>(fieldName);
    }
    return _fieldNoObjectImpl<T>(fieldName)?.withObject(obj);
  }

  FieldReflection<TestUserSimple, T>? _fieldNoObjectImpl<T>(String fieldName) {
    final f = _fieldsNoObject[fieldName];
    if (f != null) {
      return f as FieldReflection<TestUserSimple, T>;
    }
    final f2 = _fieldImpl(fieldName, null);
    if (f2 == null) return null;
    _fieldsNoObject[fieldName] = f2;
    return f2 as FieldReflection<TestUserSimple, T>;
  }

  FieldReflection<TestUserSimple, T>? _fieldObjectImpl<T>(String fieldName) {
    final f = _fieldsObject[fieldName];
    if (f != null) {
      return f as FieldReflection<TestUserSimple, T>;
    }
    var f2 = _fieldNoObjectImpl<T>(fieldName);
    if (f2 == null) return null;
    f2 = f2.withObject(object!);
    _fieldsObject[fieldName] = f2;
    return f2;
  }

  FieldReflection<TestUserSimple, dynamic>? _fieldImpl(
      String fieldName, TestUserSimple? obj) {
    obj ??= object;

    var lc = fieldName.trim().toLowerCase();

    switch (lc) {
      case 'name':
        return FieldReflection<TestUserSimple, String>(
          this,
          TestUserSimple,
          __TR.tString,
          'name',
          false,
          (o) => () => o!.name,
          null,
          obj,
          false,
          true,
          [
            TestAnnotation(['field', 'name'])
          ],
        );
      case 'email':
        return FieldReflection<TestUserSimple, String?>(
          this,
          TestUserSimple,
          __TR.tString,
          'email',
          true,
          (o) => () => o!.email,
          (o) => (v) => o!.email = v,
          obj,
          false,
          false,
        );
      case 'password':
        return FieldReflection<TestUserSimple, String>(
          this,
          TestUserSimple,
          __TR.tString,
          'password',
          false,
          (o) => () => o!.password,
          (o) => (v) => o!.password = v,
          obj,
          false,
          false,
        );
      case 'hashcode':
        return FieldReflection<TestUserSimple, int>(
          this,
          TestUserSimple,
          __TR.tInt,
          'hashCode',
          false,
          (o) => () => o!.hashCode,
          null,
          obj,
          false,
          false,
          [override],
        );
      default:
        return null;
    }
  }

  @override
  List<String> get staticFieldsNames =>
      const <String>['version', 'withReflection'];

  static final Map<String, FieldReflection<TestUserSimple, dynamic>>
      _staticFields = <String, FieldReflection<TestUserSimple, dynamic>>{};

  @override
  FieldReflection<TestUserSimple, T>? staticField<T>(String fieldName) {
    var f = _staticFields[fieldName];
    if (f != null) {
      return f as FieldReflection<TestUserSimple, T>;
    }
    f = _staticFieldImpl(fieldName);
    if (f == null) return null;
    _staticFields[fieldName] = f;
    return f as FieldReflection<TestUserSimple, T>;
  }

  FieldReflection<TestUserSimple, dynamic>? _staticFieldImpl(String fieldName) {
    var lc = fieldName.trim().toLowerCase();

    switch (lc) {
      case 'version':
        return FieldReflection<TestUserSimple, double>(
          this,
          TestUserSimple,
          __TR.tDouble,
          'version',
          false,
          (o) => () => TestUserSimple.version,
          null,
          null,
          true,
          true,
          [
            TestAnnotation(['static field', 'version'])
          ],
        );
      case 'withreflection':
        return FieldReflection<TestUserSimple, bool>(
          this,
          TestUserSimple,
          __TR.tBool,
          'withReflection',
          false,
          (o) => () => TestUserSimple.withReflection,
          null,
          null,
          true,
          true,
          null,
        );
      default:
        return null;
    }
  }

  @override
  List<String> get methodsNames =>
      const <String>['checkThePassword', 'hasEmail', 'toString'];

  static final Map<String, MethodReflection<TestUserSimple, dynamic>>
      _methodsNoObject = <String, MethodReflection<TestUserSimple, dynamic>>{};

  final Map<String, MethodReflection<TestUserSimple, dynamic>> _methodsObject =
      <String, MethodReflection<TestUserSimple, dynamic>>{};

  @override
  MethodReflection<TestUserSimple, R>? method<R>(String methodName,
      [TestUserSimple? obj]) {
    if (obj == null) {
      if (object != null) {
        return _methodObjectImpl<R>(methodName);
      } else {
        return _methodNoObjectImpl<R>(methodName);
      }
    } else if (identical(obj, object)) {
      return _methodObjectImpl<R>(methodName);
    }
    return _methodNoObjectImpl<R>(methodName)?.withObject(obj);
  }

  MethodReflection<TestUserSimple, R>? _methodNoObjectImpl<R>(
      String methodName) {
    final m = _methodsNoObject[methodName];
    if (m != null) {
      return m as MethodReflection<TestUserSimple, R>;
    }
    final m2 = _methodImpl(methodName, null);
    if (m2 == null) return null;
    _methodsNoObject[methodName] = m2;
    return m2 as MethodReflection<TestUserSimple, R>;
  }

  MethodReflection<TestUserSimple, R>? _methodObjectImpl<R>(String methodName) {
    final m = _methodsObject[methodName];
    if (m != null) {
      return m as MethodReflection<TestUserSimple, R>;
    }
    var m2 = _methodNoObjectImpl<R>(methodName);
    if (m2 == null) return null;
    m2 = m2.withObject(object!);
    _methodsObject[methodName] = m2;
    return m2;
  }

  MethodReflection<TestUserSimple, dynamic>? _methodImpl(
      String methodName, TestUserSimple? obj) {
    obj ??= object;

    var lc = methodName.trim().toLowerCase();

    switch (lc) {
      case 'checkthepassword':
        return MethodReflection<TestUserSimple, bool>(
            this,
            TestUserSimple,
            'checkThePassword',
            __TR.tBool,
            false,
            (o) => o!.checkThePassword,
            obj,
            false,
            const <__PR>[
              __PR(__TR.tString, 'password', false, true, null, [
                TestAnnotation(['parameter', 'password'])
              ])
            ],
            null,
            const <String, __PR>{
              'ignoreCase': __PR(__TR.tBool, 'ignoreCase', false, false, false)
            },
            [
              TestAnnotation(['method', 'password checker'])
            ]);
      case 'hasemail':
        return MethodReflection<TestUserSimple, bool>(
            this,
            TestUserSimple,
            'hasEmail',
            __TR.tBool,
            false,
            (o) => o!.hasEmail,
            obj,
            false,
            null,
            null,
            null,
            null);
      case 'tostring':
        return MethodReflection<TestUserSimple, String>(
            this,
            TestUserSimple,
            'toString',
            __TR.tString,
            false,
            (o) => o!.toString,
            obj,
            false,
            null,
            null,
            null,
            [override]);
      default:
        return null;
    }
  }

  @override
  List<String> get staticMethodsNames => const <String>['isVersion'];

  static final Map<String, MethodReflection<TestUserSimple, dynamic>>
      _staticMethods = <String, MethodReflection<TestUserSimple, dynamic>>{};

  @override
  MethodReflection<TestUserSimple, R>? staticMethod<R>(String methodName) {
    var m = _staticMethods[methodName];
    if (m != null) {
      return m as MethodReflection<TestUserSimple, R>;
    }
    m = _staticMethodImpl(methodName);
    if (m == null) return null;
    _staticMethods[methodName] = m;
    return m as MethodReflection<TestUserSimple, R>;
  }

  MethodReflection<TestUserSimple, dynamic>? _staticMethodImpl(
      String methodName) {
    var lc = methodName.trim().toLowerCase();

    switch (lc) {
      case 'isversion':
        return MethodReflection<TestUserSimple, bool>(
            this,
            TestUserSimple,
            'isVersion',
            __TR.tBool,
            false,
            (o) => TestUserSimple.isVersion,
            null,
            true,
            const <__PR>[__PR(__TR.tDouble, 'ver', false, true)],
            null,
            null,
            [
              TestAnnotation(['static method', 'version checker'])
            ]);
      default:
        return null;
    }
  }
}

extension TestAddress$reflectionExtension on TestAddress {
  /// Returns a [ClassReflection] for type [TestAddress]. (Generated by [ReflectionFactory])
  ClassReflection<TestAddress> get reflection => TestAddress$reflection(this);

  /// Returns a JSON [Map] for type [TestAddress]. (Generated by [ReflectionFactory])
  Map<String, dynamic>? toJsonMap({bool duplicatedEntitiesAsID = false}) =>
      reflection.toJsonMap(duplicatedEntitiesAsID: duplicatedEntitiesAsID);

  /// Returns an encoded JSON [String] for type [TestAddress]. (Generated by [ReflectionFactory])
  String toJsonEncoded(
          {bool pretty = false, bool duplicatedEntitiesAsID = false}) =>
      reflection.toJsonEncoded(
          pretty: pretty, duplicatedEntitiesAsID: duplicatedEntitiesAsID);

  /// Returns a JSON for type [TestAddress] using the class fields. (Generated by [ReflectionFactory])
  Object? toJsonFromFields({bool duplicatedEntitiesAsID = false}) => reflection
      .toJsonFromFields(duplicatedEntitiesAsID: duplicatedEntitiesAsID);
}

extension TestAddressReflectionBridge$reflectionExtension
    on TestAddressReflectionBridge {
  /// Returns a [ClassReflection] for type [T] or [obj]. (Generated by [ReflectionFactory])
  ClassReflection<T> reflection<T>([T? obj]) {
    switch (T) {
      case TestAddress:
        return TestAddress$reflection(obj as TestAddress?)
            as ClassReflection<T>;
      default:
        throw UnsupportedError('<$runtimeType> No reflection for Type: $T');
    }
  }
}

extension TestUserReflectionBridge$reflectionExtension
    on TestUserReflectionBridge {
  /// Returns a [ClassReflection] for type [T] or [obj]. (Generated by [ReflectionFactory])
  ClassReflection<T> reflection<T>([T? obj]) {
    switch (T) {
      case TestUserSimple:
        return TestUserSimple$reflection(obj as TestUserSimple?)
            as ClassReflection<T>;
      default:
        throw UnsupportedError('<$runtimeType> No reflection for Type: $T');
    }
  }
}

extension TestUserSimple$reflectionExtension on TestUserSimple {
  /// Returns a [ClassReflection] for type [TestUserSimple]. (Generated by [ReflectionFactory])
  ClassReflection<TestUserSimple> get reflection =>
      TestUserSimple$reflection(this);

  /// Returns a JSON for type [TestUserSimple]. (Generated by [ReflectionFactory])
  Object? toJson({bool duplicatedEntitiesAsID = false}) =>
      reflection.toJson(null, null, duplicatedEntitiesAsID);

  /// Returns a JSON [Map] for type [TestUserSimple]. (Generated by [ReflectionFactory])
  Map<String, dynamic>? toJsonMap({bool duplicatedEntitiesAsID = false}) =>
      reflection.toJsonMap(duplicatedEntitiesAsID: duplicatedEntitiesAsID);

  /// Returns an encoded JSON [String] for type [TestUserSimple]. (Generated by [ReflectionFactory])
  String toJsonEncoded(
          {bool pretty = false, bool duplicatedEntitiesAsID = false}) =>
      reflection.toJsonEncoded(
          pretty: pretty, duplicatedEntitiesAsID: duplicatedEntitiesAsID);

  /// Returns a JSON for type [TestUserSimple] using the class fields. (Generated by [ReflectionFactory])
  Object? toJsonFromFields({bool duplicatedEntitiesAsID = false}) => reflection
      .toJsonFromFields(duplicatedEntitiesAsID: duplicatedEntitiesAsID);
}

extension TestUserSimpleProxy$reflectionProxy on TestUserSimpleProxy {
  bool checkThePassword(String password, {bool ignoreCase = false}) {
    var ret = onCall(
        this,
        'checkThePassword',
        <String, dynamic>{
          'password': password,
          'ignoreCase': ignoreCase,
        },
        __TR.tBool);
    return ret as dynamic;
  }

  bool hasEmail() {
    var ret = onCall(this, 'hasEmail', <String, dynamic>{}, __TR.tBool);
    return ret as dynamic;
  }
}

extension TestUserSimpleProxyAsync$reflectionProxy on TestUserSimpleProxyAsync {
  Future<bool> checkThePassword(String password, {bool ignoreCase = false}) {
    var ret = onCall(
        this,
        'checkThePassword',
        <String, dynamic>{
          'password': password,
          'ignoreCase': ignoreCase,
        },
        __TR.tFutureBool);
    return ret is Future<bool>
        ? ret as Future<bool>
        : (ret is Future
            ? ret.then((v) => v as bool)
            : Future<bool>.value(ret as dynamic));
  }

  Future<bool> hasEmail() {
    var ret = onCall(this, 'hasEmail', <String, dynamic>{}, __TR.tFutureBool);
    return ret is Future<bool>
        ? ret as Future<bool>
        : (ret is Future
            ? ret.then((v) => v as bool)
            : Future<bool>.value(ret as dynamic));
  }
}

List<Reflection> _listSiblingsReflection() => <Reflection>[
      TestUserSimple$reflection(),
      TestAddress$reflection(),
    ];

List<Reflection>? _siblingsReflectionList;
List<Reflection> _siblingsReflection() => _siblingsReflectionList ??=
    List<Reflection>.unmodifiable(_listSiblingsReflection());

bool _registerSiblingsReflectionCalled = false;
void _registerSiblingsReflection() {
  if (_registerSiblingsReflectionCalled) return;
  _registerSiblingsReflectionCalled = true;
  var length = _listSiblingsReflection().length;
  assert(length > 0);
}
