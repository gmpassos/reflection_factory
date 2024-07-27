//
// GENERATED CODE - DO NOT MODIFY BY HAND!
// BUILDER: reflection_factory/2.4.3
// BUILD COMMAND: dart run build_runner build
//

// coverage:ignore-file
// ignore_for_file: unused_element
// ignore_for_file: no_leading_underscores_for_local_identifiers
// ignore_for_file: camel_case_types
// ignore_for_file: camel_case_extensions
// ignore_for_file: unnecessary_const
// ignore_for_file: unnecessary_cast
// ignore_for_file: unnecessary_type_check

part of 'user_reflection_bridge.dart';

typedef __TR<T> = TypeReflection<T>;
typedef __TI<T> = TypeInfo<T>;
typedef __PR = ParameterReflection;

mixin __ReflectionMixin {
  static final Version _version = Version.parse('2.4.3');

  Version get reflectionFactoryVersion => _version;

  List<Reflection> siblingsReflection() => _siblingsReflection();
}

Future<T> __retFut$<T>(Object? o) => ClassProxy.returnFuture<T>(o);

T __retVal$<T>(Object? o) => ClassProxy.returnValue<T>(o);

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
      : super(TestAddress, r'TestAddress', object);

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
  Version get languageVersion => Version.parse('3.3.0');

  @override
  TestAddress$reflection withObject([TestAddress? obj]) =>
      TestAddress$reflection(obj)..setupInternalsWith(this);

  static TestAddress$reflection? _withoutObjectInstance;
  @override
  TestAddress$reflection withoutObjectInstance() => staticInstance;

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

  static const List<String> _constructorsNames = const <String>[''];

  @override
  List<String> get constructorsNames => _constructorsNames;

  static final Map<String, ConstructorReflection<TestAddress>> _constructors =
      {};

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

  static const List<Object> _classAnnotations = <Object>[];

  @override
  List<Object> get classAnnotations => _classAnnotations;

  static const List<Type> _supperTypes = const <Type>[];

  @override
  List<Type> get supperTypes => _supperTypes;

  @override
  bool get hasMethodToJson => true;

  @override
  Object? callMethodToJson([TestAddress? obj]) {
    obj ??= object;
    return obj?.toJson();
  }

  static const List<String> _fieldsNames = const <String>[
    'city',
    'hashCode',
    'state'
  ];

  @override
  List<String> get fieldsNames => _fieldsNames;

  static final Map<String, FieldReflection<TestAddress, dynamic>>
      _fieldsNoObject = {};

  final Map<String, FieldReflection<TestAddress, dynamic>> _fieldsObject = {};

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
          const [override],
        );
      default:
        return null;
    }
  }

  @override
  Map<String, dynamic> getFieldsValues(TestAddress? obj,
      {bool withHashCode = false}) {
    obj ??= object;
    return <String, dynamic>{
      'state': obj?.state,
      'city': obj?.city,
      if (withHashCode) 'hashCode': obj?.hashCode,
    };
  }

  static const List<String> _staticFieldsNames = const <String>[];

  @override
  List<String> get staticFieldsNames => _staticFieldsNames;

  @override
  StaticFieldReflection<TestAddress, T>? staticField<T>(String fieldName) =>
      null;

  static const List<String> _methodsNames = const <String>['toJson'];

  @override
  List<String> get methodsNames => _methodsNames;

  static final Map<String, MethodReflection<TestAddress, dynamic>>
      _methodsNoObject = {};

  final Map<String, MethodReflection<TestAddress, dynamic>> _methodsObject = {};

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
            null,
            null,
            null,
            null);
      default:
        return null;
    }
  }

  static const List<String> _staticMethodsNames = const <String>[];

  @override
  List<String> get staticMethodsNames => _staticMethodsNames;

  @override
  StaticMethodReflection<TestAddress, R>? staticMethod<R>(String methodName) =>
      null;
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
      : super(TestUserSimple, r'TestUserSimple', object);

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
  Version get languageVersion => Version.parse('3.3.0');

  @override
  TestUserSimple$reflection withObject([TestUserSimple? obj]) =>
      TestUserSimple$reflection(obj)..setupInternalsWith(this);

  static TestUserSimple$reflection? _withoutObjectInstance;
  @override
  TestUserSimple$reflection withoutObjectInstance() => staticInstance;

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

  static const List<String> _constructorsNames = const <String>['', 'empty'];

  @override
  List<String> get constructorsNames => _constructorsNames;

  static final Map<String, ConstructorReflection<TestUserSimple>>
      _constructors = {};

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

  static const List<Object> _classAnnotations = const [
    TestAnnotation(['class', 'user'])
  ];

  @override
  List<Object> get classAnnotations => _classAnnotations;

  static const List<Type> _supperTypes = const <Type>[];

  @override
  List<Type> get supperTypes => _supperTypes;

  @override
  bool get hasMethodToJson => false;

  @override
  Object? callMethodToJson([TestUserSimple? obj]) => null;

  static const List<String> _fieldsNames = const <String>[
    'email',
    'hashCode',
    'name',
    'password'
  ];

  @override
  List<String> get fieldsNames => _fieldsNames;

  static final Map<String, FieldReflection<TestUserSimple, dynamic>>
      _fieldsNoObject = {};

  final Map<String, FieldReflection<TestUserSimple, dynamic>> _fieldsObject =
      {};

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
          true,
          const [
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
          const [override],
        );
      default:
        return null;
    }
  }

  @override
  Map<String, dynamic> getFieldsValues(TestUserSimple? obj,
      {bool withHashCode = false}) {
    obj ??= object;
    return <String, dynamic>{
      'name': obj?.name,
      'email': obj?.email,
      'password': obj?.password,
      if (withHashCode) 'hashCode': obj?.hashCode,
    };
  }

  static const List<String> _staticFieldsNames = const <String>[
    'version',
    'withReflection'
  ];

  @override
  List<String> get staticFieldsNames => _staticFieldsNames;

  static final Map<String, StaticFieldReflection<TestUserSimple, dynamic>>
      _staticFields = {};

  @override
  StaticFieldReflection<TestUserSimple, T>? staticField<T>(String fieldName) {
    var f = _staticFields[fieldName];
    if (f != null) {
      return f as StaticFieldReflection<TestUserSimple, T>;
    }
    f = _staticFieldImpl(fieldName);
    if (f == null) return null;
    _staticFields[fieldName] = f;
    return f as StaticFieldReflection<TestUserSimple, T>;
  }

  StaticFieldReflection<TestUserSimple, dynamic>? _staticFieldImpl(
      String fieldName) {
    var lc = fieldName.trim().toLowerCase();

    switch (lc) {
      case 'version':
        return StaticFieldReflection<TestUserSimple, double>(
          this,
          TestUserSimple,
          __TR.tDouble,
          'version',
          false,
          () => () => TestUserSimple.version,
          null,
          true,
          const [
            TestAnnotation(['static field', 'version'])
          ],
        );
      case 'withreflection':
        return StaticFieldReflection<TestUserSimple, bool>(
          this,
          TestUserSimple,
          __TR.tBool,
          'withReflection',
          false,
          () => () => TestUserSimple.withReflection,
          null,
          true,
          null,
        );
      default:
        return null;
    }
  }

  static const List<String> _methodsNames = const <String>[
    'checkThePassword',
    'hasEmail',
    'toString'
  ];

  @override
  List<String> get methodsNames => _methodsNames;

  static final Map<String, MethodReflection<TestUserSimple, dynamic>>
      _methodsNoObject = {};

  final Map<String, MethodReflection<TestUserSimple, dynamic>> _methodsObject =
      {};

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
            const <__PR>[
              __PR(__TR.tString, 'password', false, true, null, const [
                TestAnnotation(['parameter', 'password'])
              ])
            ],
            null,
            const <String, __PR>{
              'ignoreCase': __PR(__TR.tBool, 'ignoreCase', false, false, false)
            },
            const [
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
            null,
            null,
            null,
            const [override]);
      default:
        return null;
    }
  }

  static const List<String> _staticMethodsNames = const <String>['isVersion'];

  @override
  List<String> get staticMethodsNames => _staticMethodsNames;

  static final Map<String, StaticMethodReflection<TestUserSimple, dynamic>>
      _staticMethods = {};

  @override
  StaticMethodReflection<TestUserSimple, R>? staticMethod<R>(
      String methodName) {
    var m = _staticMethods[methodName];
    if (m != null) {
      return m as StaticMethodReflection<TestUserSimple, R>;
    }
    m = _staticMethodImpl(methodName);
    if (m == null) return null;
    _staticMethods[methodName] = m;
    return m as StaticMethodReflection<TestUserSimple, R>;
  }

  StaticMethodReflection<TestUserSimple, dynamic>? _staticMethodImpl(
      String methodName) {
    var lc = methodName.trim().toLowerCase();

    switch (lc) {
      case 'isversion':
        return StaticMethodReflection<TestUserSimple, bool>(
            this,
            TestUserSimple,
            'isVersion',
            __TR.tBool,
            false,
            () => TestUserSimple.isVersion,
            const <__PR>[__PR(__TR.tDouble, 'ver', false, true)],
            null,
            null,
            const [
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
      case const (TestAddress):
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
      case const (TestUserSimple):
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
    return __retVal$<bool>(ret);
  }

  bool hasEmail() {
    var ret = onCall(this, 'hasEmail', <String, dynamic>{}, __TR.tBool);
    return __retVal$<bool>(ret);
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
    return __retFut$<bool>(ret);
  }

  Future<bool> hasEmail() {
    var ret = onCall(this, 'hasEmail', <String, dynamic>{}, __TR.tFutureBool);
    return __retFut$<bool>(ret);
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
