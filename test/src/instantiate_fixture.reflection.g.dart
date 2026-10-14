//
// GENERATED CODE - DO NOT MODIFY BY HAND!
// BUILDER: reflection_factory/2.12.0
// BUILD COMMAND: dart run build_runner build
//

// coverage:ignore-file
// ignore_for_file: unused_element
// ignore_for_file: no_leading_underscores_for_local_identifiers
// ignore_for_file: camel_case_types
// ignore_for_file: camel_case_extensions
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: unnecessary_const
// ignore_for_file: unnecessary_cast
// ignore_for_file: unnecessary_type_check

part of 'instantiate_fixture.dart';

typedef __TR<T> = TypeReflection<T>;
typedef __TI<T> = TypeInfo<T>;
typedef __PR = ParameterReflection;

mixin __ReflectionMixin {
  static final Version _version = Version.parse('2.12.0');

  Version get reflectionFactoryVersion => _version;

  List<Reflection> siblingsReflection() => _siblingsReflection();
}

Symbol? _getSymbol(String? key) {
  if (key == null) return null;

  switch (key) {
    case r"a":
      return const Symbol(r"a");
    case r"active":
      return const Symbol(r"active");
    case r"age":
      return const Symbol(r"age");
    case r"b":
      return const Symbol(r"b");
    case r"createdAt":
      return const Symbol(r"createdAt");
    case r"id":
      return const Symbol(r"id");
    case r"phone":
      return const Symbol(r"phone");
    case r"score":
      return const Symbol(r"score");
    case r"x":
      return const Symbol(r"x");
    case r"y":
      return const Symbol(r"y");
    default:
      return null;
  }
}

// ignore: non_constant_identifier_names
TestAccountWithReflection TestAccountWithReflection$fromJson(
  Map<String, Object?> map,
) => TestAccountWithReflection$reflection.staticInstance.fromJson(map);
// ignore: non_constant_identifier_names
TestAccountWithReflection TestAccountWithReflection$fromJsonEncoded(
  String jsonEncoded,
) => TestAccountWithReflection$reflection.staticInstance.fromJsonEncoded(
  jsonEncoded,
);
// ignore: non_constant_identifier_names
TestMemberWithReflection TestMemberWithReflection$fromJson(
  Map<String, Object?> map,
) => TestMemberWithReflection$reflection.staticInstance.fromJson(map);
// ignore: non_constant_identifier_names
TestMemberWithReflection TestMemberWithReflection$fromJsonEncoded(
  String jsonEncoded,
) => TestMemberWithReflection$reflection.staticInstance.fromJsonEncoded(
  jsonEncoded,
);
// ignore: non_constant_identifier_names
TestOptPositionalWithReflection TestOptPositionalWithReflection$fromJson(
  Map<String, Object?> map,
) => TestOptPositionalWithReflection$reflection.staticInstance.fromJson(map);
// ignore: non_constant_identifier_names
TestOptPositionalWithReflection TestOptPositionalWithReflection$fromJsonEncoded(
  String jsonEncoded,
) => TestOptPositionalWithReflection$reflection.staticInstance.fromJsonEncoded(
  jsonEncoded,
);
// ignore: non_constant_identifier_names
TestRequiredNamedWithReflection TestRequiredNamedWithReflection$fromJson(
  Map<String, Object?> map,
) => TestRequiredNamedWithReflection$reflection.staticInstance.fromJson(map);
// ignore: non_constant_identifier_names
TestRequiredNamedWithReflection TestRequiredNamedWithReflection$fromJsonEncoded(
  String jsonEncoded,
) => TestRequiredNamedWithReflection$reflection.staticInstance.fromJsonEncoded(
  jsonEncoded,
);
// ignore: non_constant_identifier_names
TestSuperParamsWithReflection TestSuperParamsWithReflection$fromJson(
  Map<String, Object?> map,
) => TestSuperParamsWithReflection$reflection.staticInstance.fromJson(map);
// ignore: non_constant_identifier_names
TestSuperParamsWithReflection TestSuperParamsWithReflection$fromJsonEncoded(
  String jsonEncoded,
) => TestSuperParamsWithReflection$reflection.staticInstance.fromJsonEncoded(
  jsonEncoded,
);

class TestAccountWithReflection$reflection
    extends ClassReflection<TestAccountWithReflection>
    with __ReflectionMixin {
  static final Expando<TestAccountWithReflection$reflection>
  _objectReflections = Expando();

  factory TestAccountWithReflection$reflection([
    TestAccountWithReflection? object,
  ]) {
    if (object == null) return staticInstance;
    return _objectReflections[object] ??=
        TestAccountWithReflection$reflection._(object);
  }

  TestAccountWithReflection$reflection._([TestAccountWithReflection? object])
    : super(TestAccountWithReflection, r'TestAccountWithReflection', object);

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
  Version get languageVersion => Version.parse('3.13.0');

  @override
  TestAccountWithReflection$reflection withObject([
    TestAccountWithReflection? obj,
  ]) => TestAccountWithReflection$reflection(obj)..setupInternalsWith(this);

  static TestAccountWithReflection$reflection? _withoutObjectInstance;
  @override
  TestAccountWithReflection$reflection withoutObjectInstance() =>
      staticInstance;

  @override
  Symbol? getSymbol(String? key) => _getSymbol(key);

  static TestAccountWithReflection$reflection get staticInstance =>
      _withoutObjectInstance ??= TestAccountWithReflection$reflection._();

  @override
  TestAccountWithReflection$reflection getStaticInstance() => staticInstance;

  static bool _boot = false;
  static void boot() {
    if (_boot) return;
    _boot = true;
    TestAccountWithReflection$reflection.staticInstance;
  }

  @override
  bool get hasDefaultConstructor => false;
  @override
  TestAccountWithReflection? createInstanceWithDefaultConstructor() => null;

  @override
  bool get hasEmptyConstructor => true;
  @override
  TestAccountWithReflection? createInstanceWithEmptyConstructor() =>
      TestAccountWithReflection.create();
  @override
  bool get hasNoRequiredArgsConstructor => true;
  @override
  TestAccountWithReflection? createInstanceWithNoRequiredArgsConstructor() =>
      TestAccountWithReflection.create();

  static const List<String> _constructorsNames = const <String>[
    '',
    'basic',
    'create',
  ];

  @override
  List<String> get constructorsNames => _constructorsNames;

  static final Map<String, ConstructorReflection<TestAccountWithReflection>>
  _constructors = {};

  @override
  ConstructorReflection<TestAccountWithReflection>? constructor(
    String constructorName,
  ) {
    var c = _constructors[constructorName];
    if (c != null) return c;
    c = _constructorImpl(constructorName);
    if (c == null) return null;
    _constructors[constructorName] = c;
    return c;
  }

  ConstructorReflection<TestAccountWithReflection>? _constructorImpl(
    String constructorName,
  ) {
    var lc = constructorName.trim().toLowerCase();

    switch (lc) {
      case '':
        return ConstructorReflection<TestAccountWithReflection>(
          this,
          TestAccountWithReflection,
          '',
          () => TestAccountWithReflection.new,
          const <__PR>[
            __PR(__TR.tString, 'name', false, true),
            __PR(__TR.tString, 'email', false, true),
          ],
          null,
          const <String, __PR>{
            'active': __PR(__TR.tBool, 'active', false, false, true),
            'age': __PR(__TR.tInt, 'age', false, false, 18),
            'createdAt': __PR(
              __TR<DateTime>(DateTime),
              'createdAt',
              true,
              false,
            ),
            'id': __PR(__TR.tInt, 'id', true, false),
            'phone': __PR(__TR.tString, 'phone', true, false),
            'score': __PR(__TR.tDouble, 'score', false, false, 0.5),
          },
          null,
          invoker: (a) => TestAccountWithReflection(
            a[0],
            a[1],
            active: a[2],
            age: a[3],
            createdAt: a[4],
            id: a[5],
            phone: a[6],
            score: a[7],
          ),
        );
      case 'basic':
        return ConstructorReflection<TestAccountWithReflection>(
          this,
          TestAccountWithReflection,
          'basic',
          () => TestAccountWithReflection.basic,
          const <__PR>[
            __PR(__TR.tString, 'name', false, true),
            __PR(__TR.tString, 'email', false, true),
          ],
          null,
          null,
          null,
          invoker: (a) => TestAccountWithReflection.basic(a[0], a[1]),
        );
      case 'create':
        return ConstructorReflection<TestAccountWithReflection>(
          this,
          TestAccountWithReflection,
          'create',
          () => TestAccountWithReflection.create,
          null,
          null,
          null,
          null,
          invoker: (a) => TestAccountWithReflection.create(),
        );
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
  bool get hasMethodToJson => false;

  @override
  Object? callMethodToJson([TestAccountWithReflection? obj]) => null;

  static const List<String> _fieldsNames = const <String>[
    'active',
    'age',
    'createdAt',
    'email',
    'id',
    'name',
    'phone',
    'score',
  ];

  @override
  List<String> get fieldsNames => _fieldsNames;

  static final Map<String, FieldReflection<TestAccountWithReflection, dynamic>>
  _fieldsNoObject = {};

  final Map<String, FieldReflection<TestAccountWithReflection, dynamic>>
  _fieldsObject = {};

  @override
  FieldReflection<TestAccountWithReflection, T>? field<T>(
    String fieldName, [
    TestAccountWithReflection? obj,
  ]) {
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

  FieldReflection<TestAccountWithReflection, T>? _fieldNoObjectImpl<T>(
    String fieldName,
  ) {
    final f = _fieldsNoObject[fieldName];
    if (f != null) {
      return f as FieldReflection<TestAccountWithReflection, T>;
    }
    final f2 = _fieldImpl(fieldName, null);
    if (f2 == null) return null;
    _fieldsNoObject[fieldName] = f2;
    return f2 as FieldReflection<TestAccountWithReflection, T>;
  }

  FieldReflection<TestAccountWithReflection, T>? _fieldObjectImpl<T>(
    String fieldName,
  ) {
    final f = _fieldsObject[fieldName];
    if (f != null) {
      return f as FieldReflection<TestAccountWithReflection, T>;
    }
    var f2 = _fieldNoObjectImpl<T>(fieldName);
    if (f2 == null) return null;
    f2 = f2.withObject(object!);
    _fieldsObject[fieldName] = f2;
    return f2;
  }

  FieldReflection<TestAccountWithReflection, dynamic>? _fieldImpl(
    String fieldName,
    TestAccountWithReflection? obj,
  ) {
    obj ??= object;

    var lc = fieldName.trim().toLowerCase();

    switch (lc) {
      case 'id':
        return FieldReflection<TestAccountWithReflection, int?>(
          this,
          TestAccountWithReflection,
          __TR.tInt,
          'id',
          true,
          (o) =>
              () => o!.id,
          (o) =>
              (v) => o!.id = v,
          obj,
          false,
        );
      case 'name':
        return FieldReflection<TestAccountWithReflection, String>(
          this,
          TestAccountWithReflection,
          __TR.tString,
          'name',
          false,
          (o) =>
              () => o!.name,
          (o) =>
              (v) => o!.name = v,
          obj,
          false,
        );
      case 'email':
        return FieldReflection<TestAccountWithReflection, String>(
          this,
          TestAccountWithReflection,
          __TR.tString,
          'email',
          false,
          (o) =>
              () => o!.email,
          (o) =>
              (v) => o!.email = v,
          obj,
          false,
        );
      case 'phone':
        return FieldReflection<TestAccountWithReflection, String?>(
          this,
          TestAccountWithReflection,
          __TR.tString,
          'phone',
          true,
          (o) =>
              () => o!.phone,
          (o) =>
              (v) => o!.phone = v,
          obj,
          false,
        );
      case 'age':
        return FieldReflection<TestAccountWithReflection, int>(
          this,
          TestAccountWithReflection,
          __TR.tInt,
          'age',
          false,
          (o) =>
              () => o!.age,
          (o) =>
              (v) => o!.age = v,
          obj,
          false,
        );
      case 'score':
        return FieldReflection<TestAccountWithReflection, double>(
          this,
          TestAccountWithReflection,
          __TR.tDouble,
          'score',
          false,
          (o) =>
              () => o!.score,
          (o) =>
              (v) => o!.score = v,
          obj,
          false,
        );
      case 'active':
        return FieldReflection<TestAccountWithReflection, bool>(
          this,
          TestAccountWithReflection,
          __TR.tBool,
          'active',
          false,
          (o) =>
              () => o!.active,
          (o) =>
              (v) => o!.active = v,
          obj,
          false,
        );
      case 'createdat':
        return FieldReflection<TestAccountWithReflection, DateTime?>(
          this,
          TestAccountWithReflection,
          const __TR<DateTime>(DateTime),
          'createdAt',
          true,
          (o) =>
              () => o!.createdAt,
          (o) =>
              (v) => o!.createdAt = v,
          obj,
          false,
        );
      default:
        return null;
    }
  }

  @override
  Map<String, dynamic> getFieldsValues(
    TestAccountWithReflection? obj, {
    bool withHashCode = false,
  }) {
    obj ??= object;
    return <String, dynamic>{
      'id': obj?.id,
      'name': obj?.name,
      'email': obj?.email,
      'phone': obj?.phone,
      'age': obj?.age,
      'score': obj?.score,
      'active': obj?.active,
      'createdAt': obj?.createdAt,
      if (withHashCode) 'hashCode': obj?.hashCode,
    };
  }

  static const List<String> _staticFieldsNames = const <String>[];

  @override
  List<String> get staticFieldsNames => _staticFieldsNames;

  @override
  StaticFieldReflection<TestAccountWithReflection, T>? staticField<T>(
    String fieldName,
  ) => null;

  static const List<String> _methodsNames = const <String>['toString'];

  @override
  List<String> get methodsNames => _methodsNames;

  static final Map<String, MethodReflection<TestAccountWithReflection, dynamic>>
  _methodsNoObject = {};

  final Map<String, MethodReflection<TestAccountWithReflection, dynamic>>
  _methodsObject = {};

  @override
  MethodReflection<TestAccountWithReflection, R>? method<R>(
    String methodName, [
    TestAccountWithReflection? obj,
  ]) {
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

  MethodReflection<TestAccountWithReflection, R>? _methodNoObjectImpl<R>(
    String methodName,
  ) {
    final m = _methodsNoObject[methodName];
    if (m != null) {
      return m as MethodReflection<TestAccountWithReflection, R>;
    }
    final m2 = _methodImpl(methodName, null);
    if (m2 == null) return null;
    _methodsNoObject[methodName] = m2;
    return m2 as MethodReflection<TestAccountWithReflection, R>;
  }

  MethodReflection<TestAccountWithReflection, R>? _methodObjectImpl<R>(
    String methodName,
  ) {
    final m = _methodsObject[methodName];
    if (m != null) {
      return m as MethodReflection<TestAccountWithReflection, R>;
    }
    var m2 = _methodNoObjectImpl<R>(methodName);
    if (m2 == null) return null;
    m2 = m2.withObject(object!);
    _methodsObject[methodName] = m2;
    return m2;
  }

  MethodReflection<TestAccountWithReflection, dynamic>? _methodImpl(
    String methodName,
    TestAccountWithReflection? obj,
  ) {
    obj ??= object;

    var lc = methodName.trim().toLowerCase();

    switch (lc) {
      case 'tostring':
        return MethodReflection<TestAccountWithReflection, String>(
          this,
          TestAccountWithReflection,
          'toString',
          __TR.tString,
          false,
          (o) => o!.toString,
          obj,
          null,
          null,
          null,
          const [override],
        );
      default:
        return null;
    }
  }

  static const List<String> _staticMethodsNames = const <String>[];

  @override
  List<String> get staticMethodsNames => _staticMethodsNames;

  @override
  StaticMethodReflection<TestAccountWithReflection, R>? staticMethod<R>(
    String methodName,
  ) => null;
}

class TestMemberWithReflection$reflection
    extends ClassReflection<TestMemberWithReflection>
    with __ReflectionMixin {
  static final Expando<TestMemberWithReflection$reflection> _objectReflections =
      Expando();

  factory TestMemberWithReflection$reflection([
    TestMemberWithReflection? object,
  ]) {
    if (object == null) return staticInstance;
    return _objectReflections[object] ??= TestMemberWithReflection$reflection._(
      object,
    );
  }

  TestMemberWithReflection$reflection._([TestMemberWithReflection? object])
    : super(TestMemberWithReflection, r'TestMemberWithReflection', object);

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
  Version get languageVersion => Version.parse('3.13.0');

  @override
  TestMemberWithReflection$reflection withObject([
    TestMemberWithReflection? obj,
  ]) => TestMemberWithReflection$reflection(obj)..setupInternalsWith(this);

  static TestMemberWithReflection$reflection? _withoutObjectInstance;
  @override
  TestMemberWithReflection$reflection withoutObjectInstance() => staticInstance;

  @override
  Symbol? getSymbol(String? key) => _getSymbol(key);

  static TestMemberWithReflection$reflection get staticInstance =>
      _withoutObjectInstance ??= TestMemberWithReflection$reflection._();

  @override
  TestMemberWithReflection$reflection getStaticInstance() => staticInstance;

  static bool _boot = false;
  static void boot() {
    if (_boot) return;
    _boot = true;
    TestMemberWithReflection$reflection.staticInstance;
  }

  @override
  bool get hasDefaultConstructor => false;
  @override
  TestMemberWithReflection? createInstanceWithDefaultConstructor() => null;

  @override
  bool get hasEmptyConstructor => true;
  @override
  TestMemberWithReflection? createInstanceWithEmptyConstructor() =>
      TestMemberWithReflection.create();
  @override
  bool get hasNoRequiredArgsConstructor => true;
  @override
  TestMemberWithReflection? createInstanceWithNoRequiredArgsConstructor() =>
      TestMemberWithReflection.create();

  static const List<String> _constructorsNames = const <String>['', 'create'];

  @override
  List<String> get constructorsNames => _constructorsNames;

  static final Map<String, ConstructorReflection<TestMemberWithReflection>>
  _constructors = {};

  @override
  ConstructorReflection<TestMemberWithReflection>? constructor(
    String constructorName,
  ) {
    var c = _constructors[constructorName];
    if (c != null) return c;
    c = _constructorImpl(constructorName);
    if (c == null) return null;
    _constructors[constructorName] = c;
    return c;
  }

  ConstructorReflection<TestMemberWithReflection>? _constructorImpl(
    String constructorName,
  ) {
    var lc = constructorName.trim().toLowerCase();

    switch (lc) {
      case '':
        return ConstructorReflection<TestMemberWithReflection>(
          this,
          TestMemberWithReflection,
          '',
          () => TestMemberWithReflection.new,
          const <__PR>[
            __PR(__TR.tString, 'name', false, true),
            __PR(__TR.tString, 'email', false, true),
            __PR(__TR.tString, 'passwordOrHash', false, true),
          ],
          null,
          const <String, __PR>{
            'active': __PR(__TR.tBool, 'active', false, false, true),
            'age': __PR(__TR.tInt, 'age', false, false, 0),
            'createdAt': __PR(
              __TR<DateTime>(DateTime),
              'createdAt',
              true,
              false,
            ),
            'id': __PR(__TR.tInt, 'id', true, false),
            'score': __PR(__TR.tDouble, 'score', false, false, 0),
          },
          null,
          invoker: (a) => TestMemberWithReflection(
            a[0],
            a[1],
            a[2],
            active: a[3],
            age: a[4],
            createdAt: a[5],
            id: a[6],
            score: a[7],
          ),
        );
      case 'create':
        return ConstructorReflection<TestMemberWithReflection>(
          this,
          TestMemberWithReflection,
          'create',
          () => TestMemberWithReflection.create,
          null,
          null,
          null,
          null,
          invoker: (a) => TestMemberWithReflection.create(),
        );
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
  bool get hasMethodToJson => false;

  @override
  Object? callMethodToJson([TestMemberWithReflection? obj]) => null;

  static const List<String> _fieldsNames = const <String>[
    'active',
    'age',
    'createdAt',
    'email',
    'id',
    'name',
    'passwordHash',
    'score',
  ];

  @override
  List<String> get fieldsNames => _fieldsNames;

  static final Map<String, FieldReflection<TestMemberWithReflection, dynamic>>
  _fieldsNoObject = {};

  final Map<String, FieldReflection<TestMemberWithReflection, dynamic>>
  _fieldsObject = {};

  @override
  FieldReflection<TestMemberWithReflection, T>? field<T>(
    String fieldName, [
    TestMemberWithReflection? obj,
  ]) {
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

  FieldReflection<TestMemberWithReflection, T>? _fieldNoObjectImpl<T>(
    String fieldName,
  ) {
    final f = _fieldsNoObject[fieldName];
    if (f != null) {
      return f as FieldReflection<TestMemberWithReflection, T>;
    }
    final f2 = _fieldImpl(fieldName, null);
    if (f2 == null) return null;
    _fieldsNoObject[fieldName] = f2;
    return f2 as FieldReflection<TestMemberWithReflection, T>;
  }

  FieldReflection<TestMemberWithReflection, T>? _fieldObjectImpl<T>(
    String fieldName,
  ) {
    final f = _fieldsObject[fieldName];
    if (f != null) {
      return f as FieldReflection<TestMemberWithReflection, T>;
    }
    var f2 = _fieldNoObjectImpl<T>(fieldName);
    if (f2 == null) return null;
    f2 = f2.withObject(object!);
    _fieldsObject[fieldName] = f2;
    return f2;
  }

  FieldReflection<TestMemberWithReflection, dynamic>? _fieldImpl(
    String fieldName,
    TestMemberWithReflection? obj,
  ) {
    obj ??= object;

    var lc = fieldName.trim().toLowerCase();

    switch (lc) {
      case 'id':
        return FieldReflection<TestMemberWithReflection, int?>(
          this,
          TestMemberWithReflection,
          __TR.tInt,
          'id',
          true,
          (o) =>
              () => o!.id,
          (o) =>
              (v) => o!.id = v,
          obj,
          false,
        );
      case 'name':
        return FieldReflection<TestMemberWithReflection, String>(
          this,
          TestMemberWithReflection,
          __TR.tString,
          'name',
          false,
          (o) =>
              () => o!.name,
          (o) =>
              (v) => o!.name = v,
          obj,
          false,
        );
      case 'email':
        return FieldReflection<TestMemberWithReflection, String>(
          this,
          TestMemberWithReflection,
          __TR.tString,
          'email',
          false,
          (o) =>
              () => o!.email,
          (o) =>
              (v) => o!.email = v,
          obj,
          false,
        );
      case 'passwordhash':
        return FieldReflection<TestMemberWithReflection, String>(
          this,
          TestMemberWithReflection,
          __TR.tString,
          'passwordHash',
          false,
          (o) =>
              () => o!.passwordHash,
          (o) =>
              (v) => o!.passwordHash = v,
          obj,
          false,
        );
      case 'age':
        return FieldReflection<TestMemberWithReflection, int>(
          this,
          TestMemberWithReflection,
          __TR.tInt,
          'age',
          false,
          (o) =>
              () => o!.age,
          (o) =>
              (v) => o!.age = v,
          obj,
          false,
        );
      case 'score':
        return FieldReflection<TestMemberWithReflection, double>(
          this,
          TestMemberWithReflection,
          __TR.tDouble,
          'score',
          false,
          (o) =>
              () => o!.score,
          (o) =>
              (v) => o!.score = v,
          obj,
          false,
        );
      case 'active':
        return FieldReflection<TestMemberWithReflection, bool>(
          this,
          TestMemberWithReflection,
          __TR.tBool,
          'active',
          false,
          (o) =>
              () => o!.active,
          (o) =>
              (v) => o!.active = v,
          obj,
          false,
        );
      case 'createdat':
        return FieldReflection<TestMemberWithReflection, DateTime?>(
          this,
          TestMemberWithReflection,
          const __TR<DateTime>(DateTime),
          'createdAt',
          true,
          (o) =>
              () => o!.createdAt,
          (o) =>
              (v) => o!.createdAt = v,
          obj,
          false,
        );
      default:
        return null;
    }
  }

  @override
  Map<String, dynamic> getFieldsValues(
    TestMemberWithReflection? obj, {
    bool withHashCode = false,
  }) {
    obj ??= object;
    return <String, dynamic>{
      'id': obj?.id,
      'name': obj?.name,
      'email': obj?.email,
      'passwordHash': obj?.passwordHash,
      'age': obj?.age,
      'score': obj?.score,
      'active': obj?.active,
      'createdAt': obj?.createdAt,
      if (withHashCode) 'hashCode': obj?.hashCode,
    };
  }

  static const List<String> _staticFieldsNames = const <String>[];

  @override
  List<String> get staticFieldsNames => _staticFieldsNames;

  @override
  StaticFieldReflection<TestMemberWithReflection, T>? staticField<T>(
    String fieldName,
  ) => null;

  static const List<String> _methodsNames = const <String>[];

  @override
  List<String> get methodsNames => _methodsNames;

  @override
  MethodReflection<TestMemberWithReflection, R>? method<R>(
    String methodName, [
    TestMemberWithReflection? obj,
  ]) => null;
  static const List<String> _staticMethodsNames = const <String>[];

  @override
  List<String> get staticMethodsNames => _staticMethodsNames;

  @override
  StaticMethodReflection<TestMemberWithReflection, R>? staticMethod<R>(
    String methodName,
  ) => null;
}

class TestOptPositionalWithReflection$reflection
    extends ClassReflection<TestOptPositionalWithReflection>
    with __ReflectionMixin {
  static final Expando<TestOptPositionalWithReflection$reflection>
  _objectReflections = Expando();

  factory TestOptPositionalWithReflection$reflection([
    TestOptPositionalWithReflection? object,
  ]) {
    if (object == null) return staticInstance;
    return _objectReflections[object] ??=
        TestOptPositionalWithReflection$reflection._(object);
  }

  TestOptPositionalWithReflection$reflection._([
    TestOptPositionalWithReflection? object,
  ]) : super(
         TestOptPositionalWithReflection,
         r'TestOptPositionalWithReflection',
         object,
       );

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
  Version get languageVersion => Version.parse('3.13.0');

  @override
  TestOptPositionalWithReflection$reflection withObject([
    TestOptPositionalWithReflection? obj,
  ]) =>
      TestOptPositionalWithReflection$reflection(obj)..setupInternalsWith(this);

  static TestOptPositionalWithReflection$reflection? _withoutObjectInstance;
  @override
  TestOptPositionalWithReflection$reflection withoutObjectInstance() =>
      staticInstance;

  @override
  Symbol? getSymbol(String? key) => _getSymbol(key);

  static TestOptPositionalWithReflection$reflection get staticInstance =>
      _withoutObjectInstance ??= TestOptPositionalWithReflection$reflection._();

  @override
  TestOptPositionalWithReflection$reflection getStaticInstance() =>
      staticInstance;

  static bool _boot = false;
  static void boot() {
    if (_boot) return;
    _boot = true;
    TestOptPositionalWithReflection$reflection.staticInstance;
  }

  @override
  bool get hasDefaultConstructor => false;
  @override
  TestOptPositionalWithReflection? createInstanceWithDefaultConstructor() =>
      null;

  @override
  bool get hasEmptyConstructor => false;
  @override
  TestOptPositionalWithReflection? createInstanceWithEmptyConstructor() => null;
  @override
  bool get hasNoRequiredArgsConstructor => false;
  @override
  TestOptPositionalWithReflection?
  createInstanceWithNoRequiredArgsConstructor() => null;

  static const List<String> _constructorsNames = const <String>[''];

  @override
  List<String> get constructorsNames => _constructorsNames;

  static final Map<
    String,
    ConstructorReflection<TestOptPositionalWithReflection>
  >
  _constructors = {};

  @override
  ConstructorReflection<TestOptPositionalWithReflection>? constructor(
    String constructorName,
  ) {
    var c = _constructors[constructorName];
    if (c != null) return c;
    c = _constructorImpl(constructorName);
    if (c == null) return null;
    _constructors[constructorName] = c;
    return c;
  }

  ConstructorReflection<TestOptPositionalWithReflection>? _constructorImpl(
    String constructorName,
  ) {
    var lc = constructorName.trim().toLowerCase();

    switch (lc) {
      case '':
        return ConstructorReflection<TestOptPositionalWithReflection>(
          this,
          TestOptPositionalWithReflection,
          '',
          () => TestOptPositionalWithReflection.new,
          const <__PR>[__PR(__TR.tString, 'a', false, true)],
          const <__PR>[
            __PR(__TR.tString, 'b', false, false, 'b'),
            __PR(__TR.tInt, 'c', true, false),
          ],
          null,
          null,
          invoker: (a) => TestOptPositionalWithReflection(a[0], a[1], a[2]),
        );
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
  bool get hasMethodToJson => false;

  @override
  Object? callMethodToJson([TestOptPositionalWithReflection? obj]) => null;

  static const List<String> _fieldsNames = const <String>['a', 'b', 'c'];

  @override
  List<String> get fieldsNames => _fieldsNames;

  static final Map<
    String,
    FieldReflection<TestOptPositionalWithReflection, dynamic>
  >
  _fieldsNoObject = {};

  final Map<String, FieldReflection<TestOptPositionalWithReflection, dynamic>>
  _fieldsObject = {};

  @override
  FieldReflection<TestOptPositionalWithReflection, T>? field<T>(
    String fieldName, [
    TestOptPositionalWithReflection? obj,
  ]) {
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

  FieldReflection<TestOptPositionalWithReflection, T>? _fieldNoObjectImpl<T>(
    String fieldName,
  ) {
    final f = _fieldsNoObject[fieldName];
    if (f != null) {
      return f as FieldReflection<TestOptPositionalWithReflection, T>;
    }
    final f2 = _fieldImpl(fieldName, null);
    if (f2 == null) return null;
    _fieldsNoObject[fieldName] = f2;
    return f2 as FieldReflection<TestOptPositionalWithReflection, T>;
  }

  FieldReflection<TestOptPositionalWithReflection, T>? _fieldObjectImpl<T>(
    String fieldName,
  ) {
    final f = _fieldsObject[fieldName];
    if (f != null) {
      return f as FieldReflection<TestOptPositionalWithReflection, T>;
    }
    var f2 = _fieldNoObjectImpl<T>(fieldName);
    if (f2 == null) return null;
    f2 = f2.withObject(object!);
    _fieldsObject[fieldName] = f2;
    return f2;
  }

  FieldReflection<TestOptPositionalWithReflection, dynamic>? _fieldImpl(
    String fieldName,
    TestOptPositionalWithReflection? obj,
  ) {
    obj ??= object;

    var lc = fieldName.trim().toLowerCase();

    switch (lc) {
      case 'a':
        return FieldReflection<TestOptPositionalWithReflection, String>(
          this,
          TestOptPositionalWithReflection,
          __TR.tString,
          'a',
          false,
          (o) =>
              () => o!.a,
          null,
          obj,
          true,
        );
      case 'b':
        return FieldReflection<TestOptPositionalWithReflection, String>(
          this,
          TestOptPositionalWithReflection,
          __TR.tString,
          'b',
          false,
          (o) =>
              () => o!.b,
          null,
          obj,
          true,
        );
      case 'c':
        return FieldReflection<TestOptPositionalWithReflection, int?>(
          this,
          TestOptPositionalWithReflection,
          __TR.tInt,
          'c',
          true,
          (o) =>
              () => o!.c,
          null,
          obj,
          true,
        );
      default:
        return null;
    }
  }

  @override
  Map<String, dynamic> getFieldsValues(
    TestOptPositionalWithReflection? obj, {
    bool withHashCode = false,
  }) {
    obj ??= object;
    return <String, dynamic>{
      'a': obj?.a,
      'b': obj?.b,
      'c': obj?.c,
      if (withHashCode) 'hashCode': obj?.hashCode,
    };
  }

  static const List<String> _staticFieldsNames = const <String>[];

  @override
  List<String> get staticFieldsNames => _staticFieldsNames;

  @override
  StaticFieldReflection<TestOptPositionalWithReflection, T>? staticField<T>(
    String fieldName,
  ) => null;

  static const List<String> _methodsNames = const <String>[];

  @override
  List<String> get methodsNames => _methodsNames;

  @override
  MethodReflection<TestOptPositionalWithReflection, R>? method<R>(
    String methodName, [
    TestOptPositionalWithReflection? obj,
  ]) => null;
  static const List<String> _staticMethodsNames = const <String>[];

  @override
  List<String> get staticMethodsNames => _staticMethodsNames;

  @override
  StaticMethodReflection<TestOptPositionalWithReflection, R>? staticMethod<R>(
    String methodName,
  ) => null;
}

class TestRequiredNamedWithReflection$reflection
    extends ClassReflection<TestRequiredNamedWithReflection>
    with __ReflectionMixin {
  static final Expando<TestRequiredNamedWithReflection$reflection>
  _objectReflections = Expando();

  factory TestRequiredNamedWithReflection$reflection([
    TestRequiredNamedWithReflection? object,
  ]) {
    if (object == null) return staticInstance;
    return _objectReflections[object] ??=
        TestRequiredNamedWithReflection$reflection._(object);
  }

  TestRequiredNamedWithReflection$reflection._([
    TestRequiredNamedWithReflection? object,
  ]) : super(
         TestRequiredNamedWithReflection,
         r'TestRequiredNamedWithReflection',
         object,
       );

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
  Version get languageVersion => Version.parse('3.13.0');

  @override
  TestRequiredNamedWithReflection$reflection withObject([
    TestRequiredNamedWithReflection? obj,
  ]) =>
      TestRequiredNamedWithReflection$reflection(obj)..setupInternalsWith(this);

  static TestRequiredNamedWithReflection$reflection? _withoutObjectInstance;
  @override
  TestRequiredNamedWithReflection$reflection withoutObjectInstance() =>
      staticInstance;

  @override
  Symbol? getSymbol(String? key) => _getSymbol(key);

  static TestRequiredNamedWithReflection$reflection get staticInstance =>
      _withoutObjectInstance ??= TestRequiredNamedWithReflection$reflection._();

  @override
  TestRequiredNamedWithReflection$reflection getStaticInstance() =>
      staticInstance;

  static bool _boot = false;
  static void boot() {
    if (_boot) return;
    _boot = true;
    TestRequiredNamedWithReflection$reflection.staticInstance;
  }

  @override
  bool get hasDefaultConstructor => false;
  @override
  TestRequiredNamedWithReflection? createInstanceWithDefaultConstructor() =>
      null;

  @override
  bool get hasEmptyConstructor => false;
  @override
  TestRequiredNamedWithReflection? createInstanceWithEmptyConstructor() => null;
  @override
  bool get hasNoRequiredArgsConstructor => false;
  @override
  TestRequiredNamedWithReflection?
  createInstanceWithNoRequiredArgsConstructor() => null;

  static const List<String> _constructorsNames = const <String>[''];

  @override
  List<String> get constructorsNames => _constructorsNames;

  static final Map<
    String,
    ConstructorReflection<TestRequiredNamedWithReflection>
  >
  _constructors = {};

  @override
  ConstructorReflection<TestRequiredNamedWithReflection>? constructor(
    String constructorName,
  ) {
    var c = _constructors[constructorName];
    if (c != null) return c;
    c = _constructorImpl(constructorName);
    if (c == null) return null;
    _constructors[constructorName] = c;
    return c;
  }

  ConstructorReflection<TestRequiredNamedWithReflection>? _constructorImpl(
    String constructorName,
  ) {
    var lc = constructorName.trim().toLowerCase();

    switch (lc) {
      case '':
        return ConstructorReflection<TestRequiredNamedWithReflection>(
          this,
          TestRequiredNamedWithReflection,
          '',
          () => TestRequiredNamedWithReflection.new,
          null,
          null,
          const <String, __PR>{
            'a': __PR(__TR.tString, 'a', false, true),
            'b': __PR(__TR.tString, 'b', true, false, 'B'),
          },
          null,
          invoker: (a) => TestRequiredNamedWithReflection(a: a[0], b: a[1]),
        );
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
  bool get hasMethodToJson => false;

  @override
  Object? callMethodToJson([TestRequiredNamedWithReflection? obj]) => null;

  static const List<String> _fieldsNames = const <String>['a', 'b'];

  @override
  List<String> get fieldsNames => _fieldsNames;

  static final Map<
    String,
    FieldReflection<TestRequiredNamedWithReflection, dynamic>
  >
  _fieldsNoObject = {};

  final Map<String, FieldReflection<TestRequiredNamedWithReflection, dynamic>>
  _fieldsObject = {};

  @override
  FieldReflection<TestRequiredNamedWithReflection, T>? field<T>(
    String fieldName, [
    TestRequiredNamedWithReflection? obj,
  ]) {
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

  FieldReflection<TestRequiredNamedWithReflection, T>? _fieldNoObjectImpl<T>(
    String fieldName,
  ) {
    final f = _fieldsNoObject[fieldName];
    if (f != null) {
      return f as FieldReflection<TestRequiredNamedWithReflection, T>;
    }
    final f2 = _fieldImpl(fieldName, null);
    if (f2 == null) return null;
    _fieldsNoObject[fieldName] = f2;
    return f2 as FieldReflection<TestRequiredNamedWithReflection, T>;
  }

  FieldReflection<TestRequiredNamedWithReflection, T>? _fieldObjectImpl<T>(
    String fieldName,
  ) {
    final f = _fieldsObject[fieldName];
    if (f != null) {
      return f as FieldReflection<TestRequiredNamedWithReflection, T>;
    }
    var f2 = _fieldNoObjectImpl<T>(fieldName);
    if (f2 == null) return null;
    f2 = f2.withObject(object!);
    _fieldsObject[fieldName] = f2;
    return f2;
  }

  FieldReflection<TestRequiredNamedWithReflection, dynamic>? _fieldImpl(
    String fieldName,
    TestRequiredNamedWithReflection? obj,
  ) {
    obj ??= object;

    var lc = fieldName.trim().toLowerCase();

    switch (lc) {
      case 'a':
        return FieldReflection<TestRequiredNamedWithReflection, String>(
          this,
          TestRequiredNamedWithReflection,
          __TR.tString,
          'a',
          false,
          (o) =>
              () => o!.a,
          null,
          obj,
          true,
        );
      case 'b':
        return FieldReflection<TestRequiredNamedWithReflection, String?>(
          this,
          TestRequiredNamedWithReflection,
          __TR.tString,
          'b',
          true,
          (o) =>
              () => o!.b,
          null,
          obj,
          true,
        );
      default:
        return null;
    }
  }

  @override
  Map<String, dynamic> getFieldsValues(
    TestRequiredNamedWithReflection? obj, {
    bool withHashCode = false,
  }) {
    obj ??= object;
    return <String, dynamic>{
      'a': obj?.a,
      'b': obj?.b,
      if (withHashCode) 'hashCode': obj?.hashCode,
    };
  }

  static const List<String> _staticFieldsNames = const <String>[];

  @override
  List<String> get staticFieldsNames => _staticFieldsNames;

  @override
  StaticFieldReflection<TestRequiredNamedWithReflection, T>? staticField<T>(
    String fieldName,
  ) => null;

  static const List<String> _methodsNames = const <String>[];

  @override
  List<String> get methodsNames => _methodsNames;

  @override
  MethodReflection<TestRequiredNamedWithReflection, R>? method<R>(
    String methodName, [
    TestRequiredNamedWithReflection? obj,
  ]) => null;
  static const List<String> _staticMethodsNames = const <String>[];

  @override
  List<String> get staticMethodsNames => _staticMethodsNames;

  @override
  StaticMethodReflection<TestRequiredNamedWithReflection, R>? staticMethod<R>(
    String methodName,
  ) => null;
}

class TestSuperParamsWithReflection$reflection
    extends ClassReflection<TestSuperParamsWithReflection>
    with __ReflectionMixin {
  static final Expando<TestSuperParamsWithReflection$reflection>
  _objectReflections = Expando();

  factory TestSuperParamsWithReflection$reflection([
    TestSuperParamsWithReflection? object,
  ]) {
    if (object == null) return staticInstance;
    return _objectReflections[object] ??=
        TestSuperParamsWithReflection$reflection._(object);
  }

  TestSuperParamsWithReflection$reflection._([
    TestSuperParamsWithReflection? object,
  ]) : super(
         TestSuperParamsWithReflection,
         r'TestSuperParamsWithReflection',
         object,
       );

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
  Version get languageVersion => Version.parse('3.13.0');

  @override
  TestSuperParamsWithReflection$reflection withObject([
    TestSuperParamsWithReflection? obj,
  ]) => TestSuperParamsWithReflection$reflection(obj)..setupInternalsWith(this);

  static TestSuperParamsWithReflection$reflection? _withoutObjectInstance;
  @override
  TestSuperParamsWithReflection$reflection withoutObjectInstance() =>
      staticInstance;

  @override
  Symbol? getSymbol(String? key) => _getSymbol(key);

  static TestSuperParamsWithReflection$reflection get staticInstance =>
      _withoutObjectInstance ??= TestSuperParamsWithReflection$reflection._();

  @override
  TestSuperParamsWithReflection$reflection getStaticInstance() =>
      staticInstance;

  static bool _boot = false;
  static void boot() {
    if (_boot) return;
    _boot = true;
    TestSuperParamsWithReflection$reflection.staticInstance;
  }

  @override
  bool get hasDefaultConstructor => true;
  @override
  TestSuperParamsWithReflection? createInstanceWithDefaultConstructor() =>
      TestSuperParamsWithReflection();

  @override
  bool get hasEmptyConstructor => false;
  @override
  TestSuperParamsWithReflection? createInstanceWithEmptyConstructor() => null;
  @override
  bool get hasNoRequiredArgsConstructor => false;
  @override
  TestSuperParamsWithReflection?
  createInstanceWithNoRequiredArgsConstructor() => null;

  static const List<String> _constructorsNames = const <String>[''];

  @override
  List<String> get constructorsNames => _constructorsNames;

  static final Map<String, ConstructorReflection<TestSuperParamsWithReflection>>
  _constructors = {};

  @override
  ConstructorReflection<TestSuperParamsWithReflection>? constructor(
    String constructorName,
  ) {
    var c = _constructors[constructorName];
    if (c != null) return c;
    c = _constructorImpl(constructorName);
    if (c == null) return null;
    _constructors[constructorName] = c;
    return c;
  }

  ConstructorReflection<TestSuperParamsWithReflection>? _constructorImpl(
    String constructorName,
  ) {
    var lc = constructorName.trim().toLowerCase();

    switch (lc) {
      case '':
        return ConstructorReflection<TestSuperParamsWithReflection>(
          this,
          TestSuperParamsWithReflection,
          '',
          () => TestSuperParamsWithReflection.new,
          null,
          null,
          const <String, __PR>{
            'x': __PR(__TR.tInt, 'x', false, false, 7),
            'y': __PR(__TR.tString, 'y', false, false, 'z'),
          },
          null,
          invoker: (a) => TestSuperParamsWithReflection(x: a[0], y: a[1]),
        );
      default:
        return null;
    }
  }

  static const List<Object> _classAnnotations = <Object>[];

  @override
  List<Object> get classAnnotations => _classAnnotations;

  static const List<Type> _supperTypes = const <Type>[TestBaseWithDefault];

  @override
  List<Type> get supperTypes => _supperTypes;

  @override
  bool get hasMethodToJson => false;

  @override
  Object? callMethodToJson([TestSuperParamsWithReflection? obj]) => null;

  static const List<String> _fieldsNames = const <String>['x', 'y'];

  @override
  List<String> get fieldsNames => _fieldsNames;

  static final Map<
    String,
    FieldReflection<TestSuperParamsWithReflection, dynamic>
  >
  _fieldsNoObject = {};

  final Map<String, FieldReflection<TestSuperParamsWithReflection, dynamic>>
  _fieldsObject = {};

  @override
  FieldReflection<TestSuperParamsWithReflection, T>? field<T>(
    String fieldName, [
    TestSuperParamsWithReflection? obj,
  ]) {
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

  FieldReflection<TestSuperParamsWithReflection, T>? _fieldNoObjectImpl<T>(
    String fieldName,
  ) {
    final f = _fieldsNoObject[fieldName];
    if (f != null) {
      return f as FieldReflection<TestSuperParamsWithReflection, T>;
    }
    final f2 = _fieldImpl(fieldName, null);
    if (f2 == null) return null;
    _fieldsNoObject[fieldName] = f2;
    return f2 as FieldReflection<TestSuperParamsWithReflection, T>;
  }

  FieldReflection<TestSuperParamsWithReflection, T>? _fieldObjectImpl<T>(
    String fieldName,
  ) {
    final f = _fieldsObject[fieldName];
    if (f != null) {
      return f as FieldReflection<TestSuperParamsWithReflection, T>;
    }
    var f2 = _fieldNoObjectImpl<T>(fieldName);
    if (f2 == null) return null;
    f2 = f2.withObject(object!);
    _fieldsObject[fieldName] = f2;
    return f2;
  }

  FieldReflection<TestSuperParamsWithReflection, dynamic>? _fieldImpl(
    String fieldName,
    TestSuperParamsWithReflection? obj,
  ) {
    obj ??= object;

    var lc = fieldName.trim().toLowerCase();

    switch (lc) {
      case 'x':
        return FieldReflection<TestSuperParamsWithReflection, int>(
          this,
          TestBaseWithDefault,
          __TR.tInt,
          'x',
          false,
          (o) =>
              () => o!.x,
          null,
          obj,
          true,
        );
      case 'y':
        return FieldReflection<TestSuperParamsWithReflection, String>(
          this,
          TestBaseWithDefault,
          __TR.tString,
          'y',
          false,
          (o) =>
              () => o!.y,
          null,
          obj,
          true,
        );
      default:
        return null;
    }
  }

  @override
  Map<String, dynamic> getFieldsValues(
    TestSuperParamsWithReflection? obj, {
    bool withHashCode = false,
  }) {
    obj ??= object;
    return <String, dynamic>{
      'x': obj?.x,
      'y': obj?.y,
      if (withHashCode) 'hashCode': obj?.hashCode,
    };
  }

  static const List<String> _staticFieldsNames = const <String>[];

  @override
  List<String> get staticFieldsNames => _staticFieldsNames;

  @override
  StaticFieldReflection<TestSuperParamsWithReflection, T>? staticField<T>(
    String fieldName,
  ) => null;

  static const List<String> _methodsNames = const <String>[];

  @override
  List<String> get methodsNames => _methodsNames;

  @override
  MethodReflection<TestSuperParamsWithReflection, R>? method<R>(
    String methodName, [
    TestSuperParamsWithReflection? obj,
  ]) => null;
  static const List<String> _staticMethodsNames = const <String>[];

  @override
  List<String> get staticMethodsNames => _staticMethodsNames;

  @override
  StaticMethodReflection<TestSuperParamsWithReflection, R>? staticMethod<R>(
    String methodName,
  ) => null;
}

extension TestAccountWithReflection$reflectionExtension
    on TestAccountWithReflection {
  /// Returns a [ClassReflection] for type [TestAccountWithReflection]. (Generated by [ReflectionFactory])
  ClassReflection<TestAccountWithReflection> get reflection =>
      TestAccountWithReflection$reflection(this);

  /// Returns a JSON for type [TestAccountWithReflection]. (Generated by [ReflectionFactory])
  Object? toJson({bool duplicatedEntitiesAsID = false}) =>
      reflection.toJson(null, null, duplicatedEntitiesAsID);

  /// Returns a JSON [Map] for type [TestAccountWithReflection]. (Generated by [ReflectionFactory])
  Map<String, dynamic>? toJsonMap({bool duplicatedEntitiesAsID = false}) =>
      reflection.toJsonMap(duplicatedEntitiesAsID: duplicatedEntitiesAsID);

  /// Returns an encoded JSON [String] for type [TestAccountWithReflection]. (Generated by [ReflectionFactory])
  String toJsonEncoded({
    bool pretty = false,
    bool duplicatedEntitiesAsID = false,
  }) => reflection.toJsonEncoded(
    pretty: pretty,
    duplicatedEntitiesAsID: duplicatedEntitiesAsID,
  );

  /// Returns a JSON for type [TestAccountWithReflection] using the class fields. (Generated by [ReflectionFactory])
  Object? toJsonFromFields({bool duplicatedEntitiesAsID = false}) => reflection
      .toJsonFromFields(duplicatedEntitiesAsID: duplicatedEntitiesAsID);
}

extension TestMemberWithReflection$reflectionExtension
    on TestMemberWithReflection {
  /// Returns a [ClassReflection] for type [TestMemberWithReflection]. (Generated by [ReflectionFactory])
  ClassReflection<TestMemberWithReflection> get reflection =>
      TestMemberWithReflection$reflection(this);

  /// Returns a JSON for type [TestMemberWithReflection]. (Generated by [ReflectionFactory])
  Object? toJson({bool duplicatedEntitiesAsID = false}) =>
      reflection.toJson(null, null, duplicatedEntitiesAsID);

  /// Returns a JSON [Map] for type [TestMemberWithReflection]. (Generated by [ReflectionFactory])
  Map<String, dynamic>? toJsonMap({bool duplicatedEntitiesAsID = false}) =>
      reflection.toJsonMap(duplicatedEntitiesAsID: duplicatedEntitiesAsID);

  /// Returns an encoded JSON [String] for type [TestMemberWithReflection]. (Generated by [ReflectionFactory])
  String toJsonEncoded({
    bool pretty = false,
    bool duplicatedEntitiesAsID = false,
  }) => reflection.toJsonEncoded(
    pretty: pretty,
    duplicatedEntitiesAsID: duplicatedEntitiesAsID,
  );

  /// Returns a JSON for type [TestMemberWithReflection] using the class fields. (Generated by [ReflectionFactory])
  Object? toJsonFromFields({bool duplicatedEntitiesAsID = false}) => reflection
      .toJsonFromFields(duplicatedEntitiesAsID: duplicatedEntitiesAsID);
}

extension TestOptPositionalWithReflection$reflectionExtension
    on TestOptPositionalWithReflection {
  /// Returns a [ClassReflection] for type [TestOptPositionalWithReflection]. (Generated by [ReflectionFactory])
  ClassReflection<TestOptPositionalWithReflection> get reflection =>
      TestOptPositionalWithReflection$reflection(this);

  /// Returns a JSON for type [TestOptPositionalWithReflection]. (Generated by [ReflectionFactory])
  Object? toJson({bool duplicatedEntitiesAsID = false}) =>
      reflection.toJson(null, null, duplicatedEntitiesAsID);

  /// Returns a JSON [Map] for type [TestOptPositionalWithReflection]. (Generated by [ReflectionFactory])
  Map<String, dynamic>? toJsonMap({bool duplicatedEntitiesAsID = false}) =>
      reflection.toJsonMap(duplicatedEntitiesAsID: duplicatedEntitiesAsID);

  /// Returns an encoded JSON [String] for type [TestOptPositionalWithReflection]. (Generated by [ReflectionFactory])
  String toJsonEncoded({
    bool pretty = false,
    bool duplicatedEntitiesAsID = false,
  }) => reflection.toJsonEncoded(
    pretty: pretty,
    duplicatedEntitiesAsID: duplicatedEntitiesAsID,
  );

  /// Returns a JSON for type [TestOptPositionalWithReflection] using the class fields. (Generated by [ReflectionFactory])
  Object? toJsonFromFields({bool duplicatedEntitiesAsID = false}) => reflection
      .toJsonFromFields(duplicatedEntitiesAsID: duplicatedEntitiesAsID);
}

extension TestRequiredNamedWithReflection$reflectionExtension
    on TestRequiredNamedWithReflection {
  /// Returns a [ClassReflection] for type [TestRequiredNamedWithReflection]. (Generated by [ReflectionFactory])
  ClassReflection<TestRequiredNamedWithReflection> get reflection =>
      TestRequiredNamedWithReflection$reflection(this);

  /// Returns a JSON for type [TestRequiredNamedWithReflection]. (Generated by [ReflectionFactory])
  Object? toJson({bool duplicatedEntitiesAsID = false}) =>
      reflection.toJson(null, null, duplicatedEntitiesAsID);

  /// Returns a JSON [Map] for type [TestRequiredNamedWithReflection]. (Generated by [ReflectionFactory])
  Map<String, dynamic>? toJsonMap({bool duplicatedEntitiesAsID = false}) =>
      reflection.toJsonMap(duplicatedEntitiesAsID: duplicatedEntitiesAsID);

  /// Returns an encoded JSON [String] for type [TestRequiredNamedWithReflection]. (Generated by [ReflectionFactory])
  String toJsonEncoded({
    bool pretty = false,
    bool duplicatedEntitiesAsID = false,
  }) => reflection.toJsonEncoded(
    pretty: pretty,
    duplicatedEntitiesAsID: duplicatedEntitiesAsID,
  );

  /// Returns a JSON for type [TestRequiredNamedWithReflection] using the class fields. (Generated by [ReflectionFactory])
  Object? toJsonFromFields({bool duplicatedEntitiesAsID = false}) => reflection
      .toJsonFromFields(duplicatedEntitiesAsID: duplicatedEntitiesAsID);
}

extension TestSuperParamsWithReflection$reflectionExtension
    on TestSuperParamsWithReflection {
  /// Returns a [ClassReflection] for type [TestSuperParamsWithReflection]. (Generated by [ReflectionFactory])
  ClassReflection<TestSuperParamsWithReflection> get reflection =>
      TestSuperParamsWithReflection$reflection(this);

  /// Returns a JSON for type [TestSuperParamsWithReflection]. (Generated by [ReflectionFactory])
  Object? toJson({bool duplicatedEntitiesAsID = false}) =>
      reflection.toJson(null, null, duplicatedEntitiesAsID);

  /// Returns a JSON [Map] for type [TestSuperParamsWithReflection]. (Generated by [ReflectionFactory])
  Map<String, dynamic>? toJsonMap({bool duplicatedEntitiesAsID = false}) =>
      reflection.toJsonMap(duplicatedEntitiesAsID: duplicatedEntitiesAsID);

  /// Returns an encoded JSON [String] for type [TestSuperParamsWithReflection]. (Generated by [ReflectionFactory])
  String toJsonEncoded({
    bool pretty = false,
    bool duplicatedEntitiesAsID = false,
  }) => reflection.toJsonEncoded(
    pretty: pretty,
    duplicatedEntitiesAsID: duplicatedEntitiesAsID,
  );

  /// Returns a JSON for type [TestSuperParamsWithReflection] using the class fields. (Generated by [ReflectionFactory])
  Object? toJsonFromFields({bool duplicatedEntitiesAsID = false}) => reflection
      .toJsonFromFields(duplicatedEntitiesAsID: duplicatedEntitiesAsID);
}

List<Reflection> _listSiblingsReflection() => <Reflection>[
  TestAccountWithReflection$reflection(),
  TestMemberWithReflection$reflection(),
  TestOptPositionalWithReflection$reflection(),
  TestRequiredNamedWithReflection$reflection(),
  TestSuperParamsWithReflection$reflection(),
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
