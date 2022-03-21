//
// GENERATED CODE - DO NOT MODIFY BY HAND!
// BUILDER: reflection_factory/1.0.24
// BUILD COMMAND: dart run build_runner build
//

// ignore_for_file: unnecessary_const
// ignore_for_file: unnecessary_cast
// ignore_for_file: unnecessary_type_check

part of 'user_with_reflection.dart';

// ignore: non_constant_identifier_names
TestAddressWithReflection TestAddressWithReflection$fromJson(
        Map<String, Object?> map) =>
    TestAddressWithReflection$reflection.staticInstance.fromJson(map);
// ignore: non_constant_identifier_names
TestAddressWithReflection TestAddressWithReflection$fromJsonEncoded(
        String jsonEncoded) =>
    TestAddressWithReflection$reflection.staticInstance
        .fromJsonEncoded(jsonEncoded);
// ignore: non_constant_identifier_names
TestCompanyWithReflection TestCompanyWithReflection$fromJson(
        Map<String, Object?> map) =>
    TestCompanyWithReflection$reflection.staticInstance.fromJson(map);
// ignore: non_constant_identifier_names
TestCompanyWithReflection TestCompanyWithReflection$fromJsonEncoded(
        String jsonEncoded) =>
    TestCompanyWithReflection$reflection.staticInstance
        .fromJsonEncoded(jsonEncoded);
// ignore: non_constant_identifier_names
TestDataWithReflection TestDataWithReflection$fromJson(
        Map<String, Object?> map) =>
    TestDataWithReflection$reflection.staticInstance.fromJson(map);
// ignore: non_constant_identifier_names
TestDataWithReflection TestDataWithReflection$fromJsonEncoded(
        String jsonEncoded) =>
    TestDataWithReflection$reflection.staticInstance
        .fromJsonEncoded(jsonEncoded);
// ignore: non_constant_identifier_names
TestDomainWithReflection TestDomainWithReflection$fromJson(
        Map<String, Object?> map) =>
    TestDomainWithReflection$reflection.staticInstance.fromJson(map);
// ignore: non_constant_identifier_names
TestDomainWithReflection TestDomainWithReflection$fromJsonEncoded(
        String jsonEncoded) =>
    TestDomainWithReflection$reflection.staticInstance
        .fromJsonEncoded(jsonEncoded);
// ignore: non_constant_identifier_names
TestEnumWithReflection? TestEnumWithReflection$from(Object? o) =>
    TestEnumWithReflection$reflection.staticInstance.from(o);
// ignore: non_constant_identifier_names
TestOpAWithReflection TestOpAWithReflection$fromJson(
        Map<String, Object?> map) =>
    TestOpAWithReflection$reflection.staticInstance.fromJson(map);
// ignore: non_constant_identifier_names
TestOpAWithReflection TestOpAWithReflection$fromJsonEncoded(
        String jsonEncoded) =>
    TestOpAWithReflection$reflection.staticInstance
        .fromJsonEncoded(jsonEncoded);
// ignore: non_constant_identifier_names
TestOpBWithReflection TestOpBWithReflection$fromJson(
        Map<String, Object?> map) =>
    TestOpBWithReflection$reflection.staticInstance.fromJson(map);
// ignore: non_constant_identifier_names
TestOpBWithReflection TestOpBWithReflection$fromJsonEncoded(
        String jsonEncoded) =>
    TestOpBWithReflection$reflection.staticInstance
        .fromJsonEncoded(jsonEncoded);
// ignore: non_constant_identifier_names
TestOpWithReflection TestOpWithReflection$fromJson(Map<String, Object?> map) =>
    TestOpWithReflection$reflection.staticInstance.fromJson(map);
// ignore: non_constant_identifier_names
TestOpWithReflection TestOpWithReflection$fromJsonEncoded(String jsonEncoded) =>
    TestOpWithReflection$reflection.staticInstance.fromJsonEncoded(jsonEncoded);
// ignore: non_constant_identifier_names
TestUserWithReflection TestUserWithReflection$fromJson(
        Map<String, Object?> map) =>
    TestUserWithReflection$reflection.staticInstance.fromJson(map);
// ignore: non_constant_identifier_names
TestUserWithReflection TestUserWithReflection$fromJsonEncoded(
        String jsonEncoded) =>
    TestUserWithReflection$reflection.staticInstance
        .fromJsonEncoded(jsonEncoded);

class TestAddressWithReflection$reflection
    extends ClassReflection<TestAddressWithReflection> {
  TestAddressWithReflection$reflection([TestAddressWithReflection? object])
      : super(TestAddressWithReflection, object);

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
  Version get languageVersion => Version.parse('2.13.0');

  @override
  Version get reflectionFactoryVersion => Version.parse('1.0.24');

  @override
  TestAddressWithReflection$reflection withObject(
          [TestAddressWithReflection? obj]) =>
      TestAddressWithReflection$reflection(obj);

  static TestAddressWithReflection$reflection? _withoutObjectInstance;
  @override
  TestAddressWithReflection$reflection withoutObjectInstance() =>
      _withoutObjectInstance ??=
          super.withoutObjectInstance() as TestAddressWithReflection$reflection;

  static TestAddressWithReflection$reflection get staticInstance =>
      _withoutObjectInstance ??= TestAddressWithReflection$reflection();

  @override
  TestAddressWithReflection$reflection getStaticInstance() => staticInstance;

  static bool _boot = false;
  static void boot() {
    if (_boot) return;
    _boot = true;
    TestAddressWithReflection$reflection.staticInstance;
  }

  @override
  bool get hasDefaultConstructor => false;
  @override
  TestAddressWithReflection? createInstanceWithDefaultConstructor() => null;

  @override
  bool get hasEmptyConstructor => true;
  @override
  TestAddressWithReflection? createInstanceWithEmptyConstructor() =>
      TestAddressWithReflection.empty();
  @override
  bool get hasNoRequiredArgsConstructor => true;
  @override
  TestAddressWithReflection? createInstanceWithNoRequiredArgsConstructor() =>
      TestAddressWithReflection.empty();

  @override
  List<String> get constructorsNames => const <String>['', 'empty'];

  @override
  ConstructorReflection<TestAddressWithReflection>? constructor<R>(
      String constructorName) {
    var lc = constructorName.trim().toLowerCase();

    switch (lc) {
      case '':
        return ConstructorReflection<TestAddressWithReflection>(
            this,
            TestAddressWithReflection,
            '',
            () => (String state, [String city = '']) =>
                TestAddressWithReflection(state, city),
            const <ParameterReflection>[
              ParameterReflection(
                  TypeReflection.tString, 'state', false, true, null, null)
            ],
            const <ParameterReflection>[
              ParameterReflection(
                  TypeReflection.tString, 'city', false, false, '', null)
            ],
            null,
            null);
      case 'empty':
        return ConstructorReflection<TestAddressWithReflection>(
            this,
            TestAddressWithReflection,
            'empty',
            () => () => TestAddressWithReflection.empty(),
            null,
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
  List<ClassReflection> siblingsClassReflection() =>
      _siblingsReflection().whereType<ClassReflection>().toList();

  @override
  List<Reflection> siblingsReflection() => _siblingsReflection();

  @override
  List<Type> get supperTypes => const <Type>[];

  @override
  bool get hasMethodToJson => true;

  @override
  Object? callMethodToJson([TestAddressWithReflection? obj]) {
    obj ??= object;
    return obj?.toJson();
  }

  @override
  List<String> get fieldsNames => const <String>['city', 'hashCode', 'state'];

  @override
  FieldReflection<TestAddressWithReflection, T>? field<T>(String fieldName,
      [TestAddressWithReflection? obj]) {
    obj ??= object;

    var lc = fieldName.trim().toLowerCase();

    switch (lc) {
      case 'state':
        return FieldReflection<TestAddressWithReflection, T>(
          this,
          TestAddressWithReflection,
          TypeReflection.tString,
          'state',
          false,
          (o) => () => o!.state as T,
          null,
          obj,
          false,
          true,
          null,
        );
      case 'city':
        return FieldReflection<TestAddressWithReflection, T>(
          this,
          TestAddressWithReflection,
          TypeReflection.tString,
          'city',
          false,
          (o) => () => o!.city as T,
          null,
          obj,
          false,
          true,
          null,
        );
      case 'hashcode':
        return FieldReflection<TestAddressWithReflection, T>(
          this,
          TestAddressWithReflection,
          TypeReflection.tInt,
          'hashCode',
          false,
          (o) => () => o!.hashCode as T,
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
  FieldReflection<TestAddressWithReflection, T>? staticField<T>(
      String fieldName) {
    return null;
  }

  @override
  List<String> get methodsNames => const <String>['toJson'];

  @override
  MethodReflection<TestAddressWithReflection, R>? method<R>(String methodName,
      [TestAddressWithReflection? obj]) {
    obj ??= object;

    var lc = methodName.trim().toLowerCase();

    switch (lc) {
      case 'tojson':
        return MethodReflection<TestAddressWithReflection, R>(
            this,
            TestAddressWithReflection,
            'toJson',
            TypeReflection.tMapStringDynamic,
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
  MethodReflection<TestAddressWithReflection, R>? staticMethod<R>(
      String methodName) {
    return null;
  }
}

class TestCompanyWithReflection$reflection
    extends ClassReflection<TestCompanyWithReflection> {
  TestCompanyWithReflection$reflection([TestCompanyWithReflection? object])
      : super(TestCompanyWithReflection, object);

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
  Version get languageVersion => Version.parse('2.13.0');

  @override
  Version get reflectionFactoryVersion => Version.parse('1.0.24');

  @override
  TestCompanyWithReflection$reflection withObject(
          [TestCompanyWithReflection? obj]) =>
      TestCompanyWithReflection$reflection(obj);

  static TestCompanyWithReflection$reflection? _withoutObjectInstance;
  @override
  TestCompanyWithReflection$reflection withoutObjectInstance() =>
      _withoutObjectInstance ??=
          super.withoutObjectInstance() as TestCompanyWithReflection$reflection;

  static TestCompanyWithReflection$reflection get staticInstance =>
      _withoutObjectInstance ??= TestCompanyWithReflection$reflection();

  @override
  TestCompanyWithReflection$reflection getStaticInstance() => staticInstance;

  static bool _boot = false;
  static void boot() {
    if (_boot) return;
    _boot = true;
    TestCompanyWithReflection$reflection.staticInstance;
  }

  @override
  bool get hasDefaultConstructor => false;
  @override
  TestCompanyWithReflection? createInstanceWithDefaultConstructor() => null;

  @override
  bool get hasEmptyConstructor => false;
  @override
  TestCompanyWithReflection? createInstanceWithEmptyConstructor() => null;
  @override
  bool get hasNoRequiredArgsConstructor => false;
  @override
  TestCompanyWithReflection? createInstanceWithNoRequiredArgsConstructor() =>
      null;

  @override
  List<String> get constructorsNames => const <String>[''];

  @override
  ConstructorReflection<TestCompanyWithReflection>? constructor<R>(
      String constructorName) {
    var lc = constructorName.trim().toLowerCase();

    switch (lc) {
      case '':
        return ConstructorReflection<TestCompanyWithReflection>(
            this,
            TestCompanyWithReflection,
            '',
            () => (String name, TestAddressWithReflection mainAddress,
                    List<TestAddressWithReflection> extraAddresses,
                    {List<String> extraNames = const <String>[]}) =>
                TestCompanyWithReflection(name, mainAddress, extraAddresses,
                    extraNames: extraNames),
            const <ParameterReflection>[
              ParameterReflection(
                  TypeReflection.tString, 'name', false, true, null, null),
              ParameterReflection(TypeReflection(TestAddressWithReflection),
                  'mainAddress', false, true, null, null),
              ParameterReflection(
                  TypeReflection(List, [TestAddressWithReflection]),
                  'extraAddresses',
                  false,
                  true,
                  null,
                  null)
            ],
            null,
            const <String, ParameterReflection>{
              'extraNames': ParameterReflection(TypeReflection.tListString,
                  'extraNames', false, false, const <String>[], null)
            },
            null);
      default:
        return null;
    }
  }

  @override
  List<Object> get classAnnotations => List<Object>.unmodifiable(<Object>[]);

  @override
  List<ClassReflection> siblingsClassReflection() =>
      _siblingsReflection().whereType<ClassReflection>().toList();

  @override
  List<Reflection> siblingsReflection() => _siblingsReflection();

  @override
  List<Type> get supperTypes => const <Type>[];

  @override
  bool get hasMethodToJson => false;

  @override
  Object? callMethodToJson([TestCompanyWithReflection? obj]) => null;

  @override
  List<String> get fieldsNames => const <String>[
        'extraAddresses',
        'extraNames',
        'hashCode',
        'local',
        'mainAddress',
        'name'
      ];

  @override
  FieldReflection<TestCompanyWithReflection, T>? field<T>(String fieldName,
      [TestCompanyWithReflection? obj]) {
    obj ??= object;

    var lc = fieldName.trim().toLowerCase();

    switch (lc) {
      case 'name':
        return FieldReflection<TestCompanyWithReflection, T>(
          this,
          TestCompanyWithReflection,
          TypeReflection.tString,
          'name',
          false,
          (o) => () => o!.name as T,
          null,
          obj,
          false,
          true,
          null,
        );
      case 'mainaddress':
        return FieldReflection<TestCompanyWithReflection, T>(
          this,
          TestCompanyWithReflection,
          TypeReflection(TestAddressWithReflection),
          'mainAddress',
          false,
          (o) => () => o!.mainAddress as T,
          (o) => (T? v) => o!.mainAddress = v as TestAddressWithReflection,
          obj,
          false,
          false,
          null,
        );
      case 'extranames':
        return FieldReflection<TestCompanyWithReflection, T>(
          this,
          TestCompanyWithReflection,
          TypeReflection.tListString,
          'extraNames',
          false,
          (o) => () => o!.extraNames as T,
          null,
          obj,
          false,
          true,
          null,
        );
      case 'extraaddresses':
        return FieldReflection<TestCompanyWithReflection, T>(
          this,
          TestCompanyWithReflection,
          TypeReflection(List, [TestAddressWithReflection]),
          'extraAddresses',
          false,
          (o) => () => o!.extraAddresses as T,
          (o) => (T? v) =>
              o!.extraAddresses = v as List<TestAddressWithReflection>,
          obj,
          false,
          false,
          null,
        );
      case 'local':
        return FieldReflection<TestCompanyWithReflection, T>(
          this,
          TestCompanyWithReflection,
          TypeReflection.tBool,
          'local',
          false,
          (o) => () => o!.local as T,
          (o) => (T? v) => o!.local = v as bool,
          obj,
          false,
          false,
          [JsonField.hidden()],
        );
      case 'hashcode':
        return FieldReflection<TestCompanyWithReflection, T>(
          this,
          TestCompanyWithReflection,
          TypeReflection.tInt,
          'hashCode',
          false,
          (o) => () => o!.hashCode as T,
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
  FieldReflection<TestCompanyWithReflection, T>? staticField<T>(
      String fieldName) {
    return null;
  }

  @override
  List<String> get methodsNames => const <String>[];

  @override
  MethodReflection<TestCompanyWithReflection, R>? method<R>(String methodName,
      [TestCompanyWithReflection? obj]) {
    obj ??= object;

    return null;
  }

  @override
  List<String> get staticMethodsNames => const <String>[];

  @override
  MethodReflection<TestCompanyWithReflection, R>? staticMethod<R>(
      String methodName) {
    return null;
  }
}

class TestDataWithReflection$reflection
    extends ClassReflection<TestDataWithReflection> {
  TestDataWithReflection$reflection([TestDataWithReflection? object])
      : super(TestDataWithReflection, object);

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
  Version get languageVersion => Version.parse('2.13.0');

  @override
  Version get reflectionFactoryVersion => Version.parse('1.0.24');

  @override
  TestDataWithReflection$reflection withObject([TestDataWithReflection? obj]) =>
      TestDataWithReflection$reflection(obj);

  static TestDataWithReflection$reflection? _withoutObjectInstance;
  @override
  TestDataWithReflection$reflection withoutObjectInstance() =>
      _withoutObjectInstance ??=
          super.withoutObjectInstance() as TestDataWithReflection$reflection;

  static TestDataWithReflection$reflection get staticInstance =>
      _withoutObjectInstance ??= TestDataWithReflection$reflection();

  @override
  TestDataWithReflection$reflection getStaticInstance() => staticInstance;

  static bool _boot = false;
  static void boot() {
    if (_boot) return;
    _boot = true;
    TestDataWithReflection$reflection.staticInstance;
  }

  @override
  bool get hasDefaultConstructor => false;
  @override
  TestDataWithReflection? createInstanceWithDefaultConstructor() => null;

  @override
  bool get hasEmptyConstructor => false;
  @override
  TestDataWithReflection? createInstanceWithEmptyConstructor() => null;
  @override
  bool get hasNoRequiredArgsConstructor => false;
  @override
  TestDataWithReflection? createInstanceWithNoRequiredArgsConstructor() => null;

  @override
  List<String> get constructorsNames => const <String>[''];

  @override
  ConstructorReflection<TestDataWithReflection>? constructor<R>(
      String constructorName) {
    var lc = constructorName.trim().toLowerCase();

    switch (lc) {
      case '':
        return ConstructorReflection<TestDataWithReflection>(
            this,
            TestDataWithReflection,
            '',
            () => (String name, Uint8List bytes,
                    {BigInt? id, TestDomainWithReflection? domain}) =>
                TestDataWithReflection(name, bytes, id: id, domain: domain),
            const <ParameterReflection>[
              ParameterReflection(
                  TypeReflection.tString, 'name', false, true, null, null),
              ParameterReflection(
                  TypeReflection(Uint8List), 'bytes', false, true, null, null)
            ],
            null,
            const <String, ParameterReflection>{
              'domain': ParameterReflection(
                  TypeReflection(TestDomainWithReflection),
                  'domain',
                  true,
                  false,
                  null,
                  null),
              'id': ParameterReflection(
                  TypeReflection(BigInt), 'id', true, false, null, null)
            },
            null);
      default:
        return null;
    }
  }

  @override
  List<Object> get classAnnotations => List<Object>.unmodifiable(<Object>[]);

  @override
  List<ClassReflection> siblingsClassReflection() =>
      _siblingsReflection().whereType<ClassReflection>().toList();

  @override
  List<Reflection> siblingsReflection() => _siblingsReflection();

  @override
  List<Type> get supperTypes => const <Type>[];

  @override
  bool get hasMethodToJson => false;

  @override
  Object? callMethodToJson([TestDataWithReflection? obj]) => null;

  @override
  List<String> get fieldsNames =>
      const <String>['bytes', 'domain', 'hashCode', 'id', 'name'];

  @override
  FieldReflection<TestDataWithReflection, T>? field<T>(String fieldName,
      [TestDataWithReflection? obj]) {
    obj ??= object;

    var lc = fieldName.trim().toLowerCase();

    switch (lc) {
      case 'name':
        return FieldReflection<TestDataWithReflection, T>(
          this,
          TestDataWithReflection,
          TypeReflection.tString,
          'name',
          false,
          (o) => () => o!.name as T,
          null,
          obj,
          false,
          true,
          null,
        );
      case 'id':
        return FieldReflection<TestDataWithReflection, T>(
          this,
          TestDataWithReflection,
          TypeReflection(BigInt),
          'id',
          false,
          (o) => () => o!.id as T,
          (o) => (T? v) => o!.id = v as BigInt,
          obj,
          false,
          false,
          null,
        );
      case 'bytes':
        return FieldReflection<TestDataWithReflection, T>(
          this,
          TestDataWithReflection,
          TypeReflection(Uint8List),
          'bytes',
          false,
          (o) => () => o!.bytes as T,
          (o) => (T? v) => o!.bytes = v as Uint8List,
          obj,
          false,
          false,
          null,
        );
      case 'domain':
        return FieldReflection<TestDataWithReflection, T>(
          this,
          TestDataWithReflection,
          TypeReflection(TestDomainWithReflection),
          'domain',
          true,
          (o) => () => o!.domain as T,
          (o) => (T? v) => o!.domain = v as TestDomainWithReflection?,
          obj,
          false,
          false,
          null,
        );
      case 'hashcode':
        return FieldReflection<TestDataWithReflection, T>(
          this,
          TestDataWithReflection,
          TypeReflection.tInt,
          'hashCode',
          false,
          (o) => () => o!.hashCode as T,
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
  FieldReflection<TestDataWithReflection, T>? staticField<T>(String fieldName) {
    return null;
  }

  @override
  List<String> get methodsNames => const <String>[];

  @override
  MethodReflection<TestDataWithReflection, R>? method<R>(String methodName,
      [TestDataWithReflection? obj]) {
    obj ??= object;

    return null;
  }

  @override
  List<String> get staticMethodsNames => const <String>[];

  @override
  MethodReflection<TestDataWithReflection, R>? staticMethod<R>(
      String methodName) {
    return null;
  }
}

class TestDomainWithReflection$reflection
    extends ClassReflection<TestDomainWithReflection> {
  TestDomainWithReflection$reflection([TestDomainWithReflection? object])
      : super(TestDomainWithReflection, object);

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
  Version get languageVersion => Version.parse('2.13.0');

  @override
  Version get reflectionFactoryVersion => Version.parse('1.0.24');

  @override
  TestDomainWithReflection$reflection withObject(
          [TestDomainWithReflection? obj]) =>
      TestDomainWithReflection$reflection(obj);

  static TestDomainWithReflection$reflection? _withoutObjectInstance;
  @override
  TestDomainWithReflection$reflection withoutObjectInstance() =>
      _withoutObjectInstance ??=
          super.withoutObjectInstance() as TestDomainWithReflection$reflection;

  static TestDomainWithReflection$reflection get staticInstance =>
      _withoutObjectInstance ??= TestDomainWithReflection$reflection();

  @override
  TestDomainWithReflection$reflection getStaticInstance() => staticInstance;

  static bool _boot = false;
  static void boot() {
    if (_boot) return;
    _boot = true;
    TestDomainWithReflection$reflection.staticInstance;
  }

  @override
  bool get hasDefaultConstructor => false;
  @override
  TestDomainWithReflection? createInstanceWithDefaultConstructor() => null;

  @override
  bool get hasEmptyConstructor => false;
  @override
  TestDomainWithReflection? createInstanceWithEmptyConstructor() => null;
  @override
  bool get hasNoRequiredArgsConstructor => false;
  @override
  TestDomainWithReflection? createInstanceWithNoRequiredArgsConstructor() =>
      null;

  @override
  List<String> get constructorsNames => const <String>['', 'named', 'parse'];

  @override
  ConstructorReflection<TestDomainWithReflection>? constructor<R>(
      String constructorName) {
    var lc = constructorName.trim().toLowerCase();

    switch (lc) {
      case '':
        return ConstructorReflection<TestDomainWithReflection>(
            this,
            TestDomainWithReflection,
            '',
            () => (String name, String suffix,
                    [DomainFunction? domainFunction,
                    bool Function()? extraFunction]) =>
                TestDomainWithReflection(
                    name, suffix, domainFunction, extraFunction),
            const <ParameterReflection>[
              ParameterReflection(
                  TypeReflection.tString, 'name', false, true, null, null),
              ParameterReflection(
                  TypeReflection.tString, 'suffix', false, true, null, null)
            ],
            const <ParameterReflection>[
              ParameterReflection(TypeReflection(DomainFunction),
                  'domainFunction', true, false, null, null),
              ParameterReflection(TypeReflection.tFunction, 'extraFunction',
                  true, false, null, null)
            ],
            null,
            null);
      case 'named':
        return ConstructorReflection<TestDomainWithReflection>(
            this,
            TestDomainWithReflection,
            'named',
            () => (
                    {required String name,
                    String suffix = 'net',
                    DomainFunction? domainFunction,
                    bool Function()? extraFunction}) =>
                TestDomainWithReflection.named(
                    name: name,
                    suffix: suffix,
                    domainFunction: domainFunction,
                    extraFunction: extraFunction),
            null,
            null,
            const <String, ParameterReflection>{
              'domainFunction': ParameterReflection(
                  TypeReflection(DomainFunction),
                  'domainFunction',
                  true,
                  false,
                  null,
                  null),
              'extraFunction': ParameterReflection(TypeReflection.tFunction,
                  'extraFunction', true, false, null, null),
              'name': ParameterReflection(
                  TypeReflection.tString, 'name', false, true, null, null),
              'suffix': ParameterReflection(
                  TypeReflection.tString, 'suffix', false, false, 'net', null)
            },
            null);
      case 'parse':
        return ConstructorReflection<TestDomainWithReflection>(
            this,
            TestDomainWithReflection,
            'parse',
            () => (String s) => TestDomainWithReflection.parse(s),
            const <ParameterReflection>[
              ParameterReflection(
                  TypeReflection.tString, 's', false, true, null, null)
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
  List<ClassReflection> siblingsClassReflection() =>
      _siblingsReflection().whereType<ClassReflection>().toList();

  @override
  List<Reflection> siblingsReflection() => _siblingsReflection();

  @override
  List<Type> get supperTypes => const <Type>[];

  @override
  bool get hasMethodToJson => true;

  @override
  Object? callMethodToJson([TestDomainWithReflection? obj]) {
    obj ??= object;
    return obj?.toJson();
  }

  @override
  List<String> get fieldsNames => const <String>[
        'domainFunction',
        'extraFunction',
        'hashCode',
        'name',
        'suffix'
      ];

  @override
  FieldReflection<TestDomainWithReflection, T>? field<T>(String fieldName,
      [TestDomainWithReflection? obj]) {
    obj ??= object;

    var lc = fieldName.trim().toLowerCase();

    switch (lc) {
      case 'name':
        return FieldReflection<TestDomainWithReflection, T>(
          this,
          TestDomainWithReflection,
          TypeReflection.tString,
          'name',
          false,
          (o) => () => o!.name as T,
          null,
          obj,
          false,
          true,
          null,
        );
      case 'suffix':
        return FieldReflection<TestDomainWithReflection, T>(
          this,
          TestDomainWithReflection,
          TypeReflection.tString,
          'suffix',
          false,
          (o) => () => o!.suffix as T,
          null,
          obj,
          false,
          true,
          null,
        );
      case 'domainfunction':
        return FieldReflection<TestDomainWithReflection, T>(
          this,
          TestDomainWithReflection,
          TypeReflection(DomainFunction),
          'domainFunction',
          true,
          (o) => () => o!.domainFunction as T,
          null,
          obj,
          false,
          true,
          null,
        );
      case 'extrafunction':
        return FieldReflection<TestDomainWithReflection, T>(
          this,
          TestDomainWithReflection,
          TypeReflection.tFunction,
          'extraFunction',
          true,
          (o) => () => o!.extraFunction as T,
          null,
          obj,
          false,
          true,
          null,
        );
      case 'hashcode':
        return FieldReflection<TestDomainWithReflection, T>(
          this,
          TestDomainWithReflection,
          TypeReflection.tInt,
          'hashCode',
          false,
          (o) => () => o!.hashCode as T,
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
  FieldReflection<TestDomainWithReflection, T>? staticField<T>(
      String fieldName) {
    return null;
  }

  @override
  List<String> get methodsNames =>
      const <String>['toJson', 'toString', 'typedFunction'];

  @override
  MethodReflection<TestDomainWithReflection, R>? method<R>(String methodName,
      [TestDomainWithReflection? obj]) {
    obj ??= object;

    var lc = methodName.trim().toLowerCase();

    switch (lc) {
      case 'typedfunction':
        return MethodReflection<TestDomainWithReflection, R>(
            this,
            TestDomainWithReflection,
            'typedFunction',
            TypeReflection.tBool,
            false,
            (o) => o!.typedFunction,
            obj,
            false,
            const <ParameterReflection>[
              ParameterReflection(TypeReflection(TypedFunction, [dynamic]), 'f',
                  false, true, null, null),
              ParameterReflection(
                  TypeReflection.tDynamic, 'x', false, true, null, null)
            ],
            null,
            null,
            null);
      case 'tojson':
        return MethodReflection<TestDomainWithReflection, R>(
            this,
            TestDomainWithReflection,
            'toJson',
            TypeReflection.tString,
            false,
            (o) => o!.toJson,
            obj,
            false,
            null,
            null,
            null,
            null);
      case 'tostring':
        return MethodReflection<TestDomainWithReflection, R>(
            this,
            TestDomainWithReflection,
            'toString',
            TypeReflection.tString,
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
  List<String> get staticMethodsNames => const <String>[];

  @override
  MethodReflection<TestDomainWithReflection, R>? staticMethod<R>(
      String methodName) {
    return null;
  }
}

class TestEnumWithReflection$reflection
    extends EnumReflection<TestEnumWithReflection> {
  TestEnumWithReflection$reflection([TestEnumWithReflection? object])
      : super(TestEnumWithReflection, object);

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
  Version get languageVersion => Version.parse('2.13.0');

  @override
  Version get reflectionFactoryVersion => Version.parse('1.0.24');

  @override
  TestEnumWithReflection$reflection withObject([TestEnumWithReflection? obj]) =>
      TestEnumWithReflection$reflection(obj);

  static TestEnumWithReflection$reflection? _withoutObjectInstance;
  @override
  TestEnumWithReflection$reflection withoutObjectInstance() =>
      _withoutObjectInstance ??=
          super.withoutObjectInstance() as TestEnumWithReflection$reflection;

  static TestEnumWithReflection$reflection get staticInstance =>
      _withoutObjectInstance ??= TestEnumWithReflection$reflection();

  @override
  TestEnumWithReflection$reflection getStaticInstance() => staticInstance;

  static bool _boot = false;
  static void boot() {
    if (_boot) return;
    _boot = true;
    TestEnumWithReflection$reflection.staticInstance;
  }

  @override
  List<Object> get classAnnotations => List<Object>.unmodifiable(<Object>[]);

  @override
  List<EnumReflection> siblingsEnumReflection() =>
      _siblingsReflection().whereType<EnumReflection>().toList();

  @override
  List<Reflection> siblingsReflection() => _siblingsReflection();

  @override
  List<String> get fieldsNames => const <String>['Z', 'x', 'y', 'z'];

  @override
  Map<String, TestEnumWithReflection> get valuesByName =>
      const <String, TestEnumWithReflection>{
        'x': TestEnumWithReflection.x,
        'y': TestEnumWithReflection.y,
        'z': TestEnumWithReflection.z,
        'Z': TestEnumWithReflection.Z,
      };

  @override
  List<TestEnumWithReflection> get values => TestEnumWithReflection.values;
}

class TestOpAWithReflection$reflection
    extends ClassReflection<TestOpAWithReflection> {
  TestOpAWithReflection$reflection([TestOpAWithReflection? object])
      : super(TestOpAWithReflection, object);

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
  Version get languageVersion => Version.parse('2.13.0');

  @override
  Version get reflectionFactoryVersion => Version.parse('1.0.24');

  @override
  TestOpAWithReflection$reflection withObject([TestOpAWithReflection? obj]) =>
      TestOpAWithReflection$reflection(obj);

  static TestOpAWithReflection$reflection? _withoutObjectInstance;
  @override
  TestOpAWithReflection$reflection withoutObjectInstance() =>
      _withoutObjectInstance ??=
          super.withoutObjectInstance() as TestOpAWithReflection$reflection;

  static TestOpAWithReflection$reflection get staticInstance =>
      _withoutObjectInstance ??= TestOpAWithReflection$reflection();

  @override
  TestOpAWithReflection$reflection getStaticInstance() => staticInstance;

  static bool _boot = false;
  static void boot() {
    if (_boot) return;
    _boot = true;
    TestOpAWithReflection$reflection.staticInstance;
  }

  @override
  bool get hasDefaultConstructor => false;
  @override
  TestOpAWithReflection? createInstanceWithDefaultConstructor() => null;

  @override
  bool get hasEmptyConstructor => false;
  @override
  TestOpAWithReflection? createInstanceWithEmptyConstructor() => null;
  @override
  bool get hasNoRequiredArgsConstructor => false;
  @override
  TestOpAWithReflection? createInstanceWithNoRequiredArgsConstructor() => null;

  @override
  List<String> get constructorsNames => const <String>[''];

  @override
  ConstructorReflection<TestOpAWithReflection>? constructor<R>(
      String constructorName) {
    var lc = constructorName.trim().toLowerCase();

    switch (lc) {
      case '':
        return ConstructorReflection<TestOpAWithReflection>(
            this,
            TestOpAWithReflection,
            '',
            () => (int value) => TestOpAWithReflection(value),
            const <ParameterReflection>[
              ParameterReflection(
                  TypeReflection.tInt, 'value', false, true, null, null)
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
  List<ClassReflection> siblingsClassReflection() =>
      _siblingsReflection().whereType<ClassReflection>().toList();

  @override
  List<Reflection> siblingsReflection() => _siblingsReflection();

  @override
  List<Type> get supperTypes => const <Type>[TestOpWithReflection];

  @override
  bool get hasMethodToJson => false;

  @override
  Object? callMethodToJson([TestOpAWithReflection? obj]) => null;

  @override
  List<String> get fieldsNames => const <String>['type', 'value'];

  @override
  FieldReflection<TestOpAWithReflection, T>? field<T>(String fieldName,
      [TestOpAWithReflection? obj]) {
    obj ??= object;

    var lc = fieldName.trim().toLowerCase();

    switch (lc) {
      case 'value':
        return FieldReflection<TestOpAWithReflection, T>(
          this,
          TestOpAWithReflection,
          TypeReflection.tInt,
          'value',
          false,
          (o) => () => o!.value as T,
          (o) => (T? v) => o!.value = v as int,
          obj,
          false,
          false,
          [override, override],
        );
      case 'type':
        return FieldReflection<TestOpAWithReflection, T>(
          this,
          TestOpWithReflection,
          TypeReflection.tString,
          'type',
          false,
          (o) => () => o!.type as T,
          null,
          obj,
          false,
          true,
          null,
        );
      default:
        return null;
    }
  }

  @override
  List<String> get staticFieldsNames => const <String>['staticFieldA'];

  @override
  FieldReflection<TestOpAWithReflection, T>? staticField<T>(String fieldName) {
    var lc = fieldName.trim().toLowerCase();

    switch (lc) {
      case 'staticfielda':
        return FieldReflection<TestOpAWithReflection, T>(
          this,
          TestOpAWithReflection,
          TypeReflection.tInt,
          'staticFieldA',
          false,
          (o) => () => TestOpAWithReflection.staticFieldA as T,
          (o) => (T? v) => TestOpAWithReflection.staticFieldA = v as int,
          null,
          true,
          false,
          null,
        );
      default:
        return null;
    }
  }

  @override
  List<String> get methodsNames => const <String>['isEmptyType', 'methodA'];

  @override
  MethodReflection<TestOpAWithReflection, R>? method<R>(String methodName,
      [TestOpAWithReflection? obj]) {
    obj ??= object;

    var lc = methodName.trim().toLowerCase();

    switch (lc) {
      case 'methoda':
        return MethodReflection<TestOpAWithReflection, R>(
            this,
            TestOpAWithReflection,
            'methodA',
            TypeReflection.tBool,
            false,
            (o) => o!.methodA,
            obj,
            false,
            null,
            null,
            null,
            null);
      case 'isemptytype':
        return MethodReflection<TestOpAWithReflection, R>(
            this,
            TestOpWithReflection,
            'isEmptyType',
            TypeReflection.tBool,
            false,
            (o) => o!.isEmptyType,
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
  MethodReflection<TestOpAWithReflection, R>? staticMethod<R>(
      String methodName) {
    return null;
  }
}

class TestOpBWithReflection$reflection
    extends ClassReflection<TestOpBWithReflection> {
  TestOpBWithReflection$reflection([TestOpBWithReflection? object])
      : super(TestOpBWithReflection, object);

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
  Version get languageVersion => Version.parse('2.13.0');

  @override
  Version get reflectionFactoryVersion => Version.parse('1.0.24');

  @override
  TestOpBWithReflection$reflection withObject([TestOpBWithReflection? obj]) =>
      TestOpBWithReflection$reflection(obj);

  static TestOpBWithReflection$reflection? _withoutObjectInstance;
  @override
  TestOpBWithReflection$reflection withoutObjectInstance() =>
      _withoutObjectInstance ??=
          super.withoutObjectInstance() as TestOpBWithReflection$reflection;

  static TestOpBWithReflection$reflection get staticInstance =>
      _withoutObjectInstance ??= TestOpBWithReflection$reflection();

  @override
  TestOpBWithReflection$reflection getStaticInstance() => staticInstance;

  static bool _boot = false;
  static void boot() {
    if (_boot) return;
    _boot = true;
    TestOpBWithReflection$reflection.staticInstance;
  }

  @override
  bool get hasDefaultConstructor => false;
  @override
  TestOpBWithReflection? createInstanceWithDefaultConstructor() => null;

  @override
  bool get hasEmptyConstructor => false;
  @override
  TestOpBWithReflection? createInstanceWithEmptyConstructor() => null;
  @override
  bool get hasNoRequiredArgsConstructor => false;
  @override
  TestOpBWithReflection? createInstanceWithNoRequiredArgsConstructor() => null;

  @override
  List<String> get constructorsNames => const <String>[''];

  @override
  ConstructorReflection<TestOpBWithReflection>? constructor<R>(
      String constructorName) {
    var lc = constructorName.trim().toLowerCase();

    switch (lc) {
      case '':
        return ConstructorReflection<TestOpBWithReflection>(
            this,
            TestOpBWithReflection,
            '',
            () => (double amount) => TestOpBWithReflection(amount),
            const <ParameterReflection>[
              ParameterReflection(
                  TypeReflection.tDouble, 'amount', false, true, null, null)
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
  List<ClassReflection> siblingsClassReflection() =>
      _siblingsReflection().whereType<ClassReflection>().toList();

  @override
  List<Reflection> siblingsReflection() => _siblingsReflection();

  @override
  List<Type> get supperTypes => const <Type>[TestOpWithReflection];

  @override
  bool get hasMethodToJson => false;

  @override
  Object? callMethodToJson([TestOpBWithReflection? obj]) => null;

  @override
  List<String> get fieldsNames => const <String>['amount', 'type', 'value'];

  @override
  FieldReflection<TestOpBWithReflection, T>? field<T>(String fieldName,
      [TestOpBWithReflection? obj]) {
    obj ??= object;

    var lc = fieldName.trim().toLowerCase();

    switch (lc) {
      case 'amount':
        return FieldReflection<TestOpBWithReflection, T>(
          this,
          TestOpBWithReflection,
          TypeReflection.tDouble,
          'amount',
          false,
          (o) => () => o!.amount as T,
          (o) => (T? v) => o!.amount = v as double,
          obj,
          false,
          false,
          null,
        );
      case 'type':
        return FieldReflection<TestOpBWithReflection, T>(
          this,
          TestOpWithReflection,
          TypeReflection.tString,
          'type',
          false,
          (o) => () => o!.type as T,
          null,
          obj,
          false,
          true,
          null,
        );
      case 'value':
        return FieldReflection<TestOpBWithReflection, T>(
          this,
          TestOpWithReflection,
          TypeReflection.tDynamic,
          'value',
          true,
          (o) => () => o!.value as T,
          (o) => (T? v) => o!.value = v as dynamic,
          obj,
          false,
          false,
          null,
        );
      default:
        return null;
    }
  }

  @override
  List<String> get staticFieldsNames => const <String>[];

  @override
  FieldReflection<TestOpBWithReflection, T>? staticField<T>(String fieldName) {
    return null;
  }

  @override
  List<String> get methodsNames => const <String>['isEmptyType', 'methodB'];

  @override
  MethodReflection<TestOpBWithReflection, R>? method<R>(String methodName,
      [TestOpBWithReflection? obj]) {
    obj ??= object;

    var lc = methodName.trim().toLowerCase();

    switch (lc) {
      case 'methodb':
        return MethodReflection<TestOpBWithReflection, R>(
            this,
            TestOpBWithReflection,
            'methodB',
            TypeReflection.tSetDynamic,
            false,
            (o) => o!.methodB,
            obj,
            false,
            null,
            null,
            null,
            null);
      case 'isemptytype':
        return MethodReflection<TestOpBWithReflection, R>(
            this,
            TestOpWithReflection,
            'isEmptyType',
            TypeReflection.tBool,
            false,
            (o) => o!.isEmptyType,
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
  List<String> get staticMethodsNames => const <String>['staticMethodB'];

  @override
  MethodReflection<TestOpBWithReflection, R>? staticMethod<R>(
      String methodName) {
    var lc = methodName.trim().toLowerCase();

    switch (lc) {
      case 'staticmethodb':
        return MethodReflection<TestOpBWithReflection, R>(
            this,
            TestOpBWithReflection,
            'staticMethodB',
            TypeReflection.tBool,
            false,
            (o) => TestOpBWithReflection.staticMethodB,
            null,
            true,
            null,
            null,
            null,
            null);
      default:
        return null;
    }
  }
}

class TestOpWithReflection$reflection
    extends ClassReflection<TestOpWithReflection> {
  TestOpWithReflection$reflection([TestOpWithReflection? object])
      : super(TestOpWithReflection, object);

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
  Version get languageVersion => Version.parse('2.13.0');

  @override
  Version get reflectionFactoryVersion => Version.parse('1.0.24');

  @override
  TestOpWithReflection$reflection withObject([TestOpWithReflection? obj]) =>
      TestOpWithReflection$reflection(obj);

  static TestOpWithReflection$reflection? _withoutObjectInstance;
  @override
  TestOpWithReflection$reflection withoutObjectInstance() =>
      _withoutObjectInstance ??=
          super.withoutObjectInstance() as TestOpWithReflection$reflection;

  static TestOpWithReflection$reflection get staticInstance =>
      _withoutObjectInstance ??= TestOpWithReflection$reflection();

  @override
  TestOpWithReflection$reflection getStaticInstance() => staticInstance;

  static bool _boot = false;
  static void boot() {
    if (_boot) return;
    _boot = true;
    TestOpWithReflection$reflection.staticInstance;
  }

  @override
  bool get hasDefaultConstructor => false;
  @override
  TestOpWithReflection? createInstanceWithDefaultConstructor() => null;

  @override
  bool get hasEmptyConstructor => true;
  @override
  TestOpWithReflection? createInstanceWithEmptyConstructor() =>
      TestOpWithReflection.empty();
  @override
  bool get hasNoRequiredArgsConstructor => true;
  @override
  TestOpWithReflection? createInstanceWithNoRequiredArgsConstructor() =>
      TestOpWithReflection.empty();

  @override
  List<String> get constructorsNames => const <String>['', 'empty'];

  @override
  ConstructorReflection<TestOpWithReflection>? constructor<R>(
      String constructorName) {
    var lc = constructorName.trim().toLowerCase();

    switch (lc) {
      case '':
        return ConstructorReflection<TestOpWithReflection>(
            this,
            TestOpWithReflection,
            '',
            () => (String type, dynamic value) =>
                TestOpWithReflection(type, value),
            const <ParameterReflection>[
              ParameterReflection(
                  TypeReflection.tString, 'type', false, true, null, null),
              ParameterReflection(
                  TypeReflection.tDynamic, 'value', true, true, null, null)
            ],
            null,
            null,
            null);
      case 'empty':
        return ConstructorReflection<TestOpWithReflection>(
            this,
            TestOpWithReflection,
            'empty',
            () => () => TestOpWithReflection.empty(),
            null,
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
  List<ClassReflection> siblingsClassReflection() =>
      _siblingsReflection().whereType<ClassReflection>().toList();

  @override
  List<Reflection> siblingsReflection() => _siblingsReflection();

  @override
  List<Type> get supperTypes => const <Type>[];

  @override
  bool get hasMethodToJson => false;

  @override
  Object? callMethodToJson([TestOpWithReflection? obj]) => null;

  @override
  List<String> get fieldsNames => const <String>['type', 'value'];

  @override
  FieldReflection<TestOpWithReflection, T>? field<T>(String fieldName,
      [TestOpWithReflection? obj]) {
    obj ??= object;

    var lc = fieldName.trim().toLowerCase();

    switch (lc) {
      case 'type':
        return FieldReflection<TestOpWithReflection, T>(
          this,
          TestOpWithReflection,
          TypeReflection.tString,
          'type',
          false,
          (o) => () => o!.type as T,
          null,
          obj,
          false,
          true,
          null,
        );
      case 'value':
        return FieldReflection<TestOpWithReflection, T>(
          this,
          TestOpWithReflection,
          TypeReflection.tDynamic,
          'value',
          true,
          (o) => () => o!.value as T,
          (o) => (T? v) => o!.value = v as dynamic,
          obj,
          false,
          false,
          null,
        );
      default:
        return null;
    }
  }

  @override
  List<String> get staticFieldsNames => const <String>['staticField'];

  @override
  FieldReflection<TestOpWithReflection, T>? staticField<T>(String fieldName) {
    var lc = fieldName.trim().toLowerCase();

    switch (lc) {
      case 'staticfield':
        return FieldReflection<TestOpWithReflection, T>(
          this,
          TestOpWithReflection,
          TypeReflection.tInt,
          'staticField',
          false,
          (o) => () => TestOpWithReflection.staticField as T,
          (o) => (T? v) => TestOpWithReflection.staticField = v as int,
          null,
          true,
          false,
          null,
        );
      default:
        return null;
    }
  }

  @override
  List<String> get methodsNames => const <String>['isEmptyType'];

  @override
  MethodReflection<TestOpWithReflection, R>? method<R>(String methodName,
      [TestOpWithReflection? obj]) {
    obj ??= object;

    var lc = methodName.trim().toLowerCase();

    switch (lc) {
      case 'isemptytype':
        return MethodReflection<TestOpWithReflection, R>(
            this,
            TestOpWithReflection,
            'isEmptyType',
            TypeReflection.tBool,
            false,
            (o) => o!.isEmptyType,
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
  List<String> get staticMethodsNames => const <String>['staticMethod'];

  @override
  MethodReflection<TestOpWithReflection, R>? staticMethod<R>(
      String methodName) {
    var lc = methodName.trim().toLowerCase();

    switch (lc) {
      case 'staticmethod':
        return MethodReflection<TestOpWithReflection, R>(
            this,
            TestOpWithReflection,
            'staticMethod',
            TypeReflection.tBool,
            false,
            (o) => TestOpWithReflection.staticMethod,
            null,
            true,
            null,
            null,
            null,
            null);
      default:
        return null;
    }
  }
}

class TestUserWithReflection$reflection
    extends ClassReflection<TestUserWithReflection> {
  TestUserWithReflection$reflection([TestUserWithReflection? object])
      : super(TestUserWithReflection, object);

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
  Version get languageVersion => Version.parse('2.13.0');

  @override
  Version get reflectionFactoryVersion => Version.parse('1.0.24');

  @override
  TestUserWithReflection$reflection withObject([TestUserWithReflection? obj]) =>
      TestUserWithReflection$reflection(obj);

  static TestUserWithReflection$reflection? _withoutObjectInstance;
  @override
  TestUserWithReflection$reflection withoutObjectInstance() =>
      _withoutObjectInstance ??=
          super.withoutObjectInstance() as TestUserWithReflection$reflection;

  static TestUserWithReflection$reflection get staticInstance =>
      _withoutObjectInstance ??= TestUserWithReflection$reflection();

  @override
  TestUserWithReflection$reflection getStaticInstance() => staticInstance;

  static bool _boot = false;
  static void boot() {
    if (_boot) return;
    _boot = true;
    TestUserWithReflection$reflection.staticInstance;
  }

  @override
  bool get hasDefaultConstructor => true;
  @override
  TestUserWithReflection? createInstanceWithDefaultConstructor() =>
      TestUserWithReflection();

  @override
  bool get hasEmptyConstructor => false;
  @override
  TestUserWithReflection? createInstanceWithEmptyConstructor() => null;
  @override
  bool get hasNoRequiredArgsConstructor => false;
  @override
  TestUserWithReflection? createInstanceWithNoRequiredArgsConstructor() => null;

  @override
  List<String> get constructorsNames => const <String>['', 'fields'];

  @override
  ConstructorReflection<TestUserWithReflection>? constructor<R>(
      String constructorName) {
    var lc = constructorName.trim().toLowerCase();

    switch (lc) {
      case 'fields':
        return ConstructorReflection<TestUserWithReflection>(
            this,
            TestUserWithReflection,
            'fields',
            () => (String name, String? email, String password,
                    {bool enabled = true,
                    TestEnumWithReflection axis = TestEnumWithReflection.x,
                    int? level}) =>
                TestUserWithReflection.fields(name, email, password,
                    enabled: enabled, axis: axis, level: level),
            const <ParameterReflection>[
              ParameterReflection(
                  TypeReflection.tString, 'name', false, true, null, null),
              ParameterReflection(
                  TypeReflection.tString, 'email', true, true, null, null),
              ParameterReflection(
                  TypeReflection.tString, 'password', false, true, null, null)
            ],
            null,
            const <String, ParameterReflection>{
              'axis': ParameterReflection(
                  TypeReflection(TestEnumWithReflection),
                  'axis',
                  false,
                  false,
                  TestEnumWithReflection.x,
                  null),
              'enabled': ParameterReflection(
                  TypeReflection.tBool, 'enabled', false, false, true, null),
              'level': ParameterReflection(
                  TypeReflection.tInt, 'level', true, false, null, null)
            },
            null);
      case '':
        return ConstructorReflection<TestUserWithReflection>(
            this,
            TestUserWithReflection,
            '',
            () => () => TestUserWithReflection(),
            null,
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
  List<ClassReflection> siblingsClassReflection() =>
      _siblingsReflection().whereType<ClassReflection>().toList();

  @override
  List<Reflection> siblingsReflection() => _siblingsReflection();

  @override
  List<Type> get supperTypes => const <Type>[];

  @override
  bool get hasMethodToJson => false;

  @override
  Object? callMethodToJson([TestUserWithReflection? obj]) => null;

  @override
  List<String> get fieldsNames => const <String>[
        'axis',
        'email',
        'enabled',
        'hashCode',
        'isEnabled',
        'isNotEnabled',
        'level',
        'name',
        'password'
      ];

  @override
  FieldReflection<TestUserWithReflection, T>? field<T>(String fieldName,
      [TestUserWithReflection? obj]) {
    obj ??= object;

    var lc = fieldName.trim().toLowerCase();

    switch (lc) {
      case 'name':
        return FieldReflection<TestUserWithReflection, T>(
          this,
          TestUserWithReflection,
          TypeReflection.tString,
          'name',
          false,
          (o) => () => o!.name as T,
          null,
          obj,
          false,
          true,
          null,
        );
      case 'email':
        return FieldReflection<TestUserWithReflection, T>(
          this,
          TestUserWithReflection,
          TypeReflection.tString,
          'email',
          true,
          (o) => () => o!.email as T,
          (o) => (T? v) => o!.email = v as String?,
          obj,
          false,
          false,
          null,
        );
      case 'password':
        return FieldReflection<TestUserWithReflection, T>(
          this,
          TestUserWithReflection,
          TypeReflection.tString,
          'password',
          false,
          (o) => () => o!.password as T,
          (o) => (T? v) => o!.password = v as String,
          obj,
          false,
          false,
          null,
        );
      case 'enabled':
        return FieldReflection<TestUserWithReflection, T>(
          this,
          TestUserWithReflection,
          TypeReflection.tBool,
          'enabled',
          false,
          (o) => () => o!.enabled as T,
          (o) => (T? v) => o!.enabled = v as bool,
          obj,
          false,
          false,
          null,
        );
      case 'axis':
        return FieldReflection<TestUserWithReflection, T>(
          this,
          TestUserWithReflection,
          TypeReflection(TestEnumWithReflection),
          'axis',
          false,
          (o) => () => o!.axis as T,
          (o) => (T? v) => o!.axis = v as TestEnumWithReflection,
          obj,
          false,
          false,
          null,
        );
      case 'level':
        return FieldReflection<TestUserWithReflection, T>(
          this,
          TestUserWithReflection,
          TypeReflection.tInt,
          'level',
          true,
          (o) => () => o!.level as T,
          (o) => (T? v) => o!.level = v as int?,
          obj,
          false,
          false,
          null,
        );
      case 'isenabled':
        return FieldReflection<TestUserWithReflection, T>(
          this,
          TestUserWithReflection,
          TypeReflection.tBool,
          'isEnabled',
          false,
          (o) => () => o!.isEnabled as T,
          null,
          obj,
          false,
          false,
          [JsonField.visible()],
        );
      case 'isnotenabled':
        return FieldReflection<TestUserWithReflection, T>(
          this,
          TestUserWithReflection,
          TypeReflection.tBool,
          'isNotEnabled',
          false,
          (o) => () => o!.isNotEnabled as T,
          null,
          obj,
          false,
          false,
          [JsonField.hidden()],
        );
      case 'hashcode':
        return FieldReflection<TestUserWithReflection, T>(
          this,
          TestUserWithReflection,
          TypeReflection.tInt,
          'hashCode',
          false,
          (o) => () => o!.hashCode as T,
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

  @override
  FieldReflection<TestUserWithReflection, T>? staticField<T>(String fieldName) {
    var lc = fieldName.trim().toLowerCase();

    switch (lc) {
      case 'version':
        return FieldReflection<TestUserWithReflection, T>(
          this,
          TestUserWithReflection,
          TypeReflection.tDouble,
          'version',
          false,
          (o) => () => TestUserWithReflection.version as T,
          null,
          null,
          true,
          true,
          null,
        );
      case 'withreflection':
        return FieldReflection<TestUserWithReflection, T>(
          this,
          TestUserWithReflection,
          TypeReflection.tBool,
          'withReflection',
          false,
          (o) => () => TestUserWithReflection.withReflection as T,
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
      const <String>['checkPassword', 'getField', 'setField'];

  @override
  MethodReflection<TestUserWithReflection, R>? method<R>(String methodName,
      [TestUserWithReflection? obj]) {
    obj ??= object;

    var lc = methodName.trim().toLowerCase();

    switch (lc) {
      case 'checkpassword':
        return MethodReflection<TestUserWithReflection, R>(
            this,
            TestUserWithReflection,
            'checkPassword',
            TypeReflection.tBool,
            false,
            (o) => o!.checkPassword,
            obj,
            false,
            const <ParameterReflection>[
              ParameterReflection(
                  TypeReflection.tString, 'password', false, true, null, null)
            ],
            null,
            null,
            null);
      case 'getfield':
        return MethodReflection<TestUserWithReflection, R>(
            this,
            TestUserWithReflection,
            'getField',
            TypeReflection.tDynamic,
            true,
            (o) => o!.getField,
            obj,
            false,
            const <ParameterReflection>[
              ParameterReflection(
                  TypeReflection.tString, 'key', false, true, null, null)
            ],
            const <ParameterReflection>[
              ParameterReflection(
                  TypeReflection.tDynamic, 'def', true, false, null, null)
            ],
            null,
            null);
      case 'setfield':
        return MethodReflection<TestUserWithReflection, R>(
            this,
            TestUserWithReflection,
            'setField',
            TypeReflection.tVoid,
            false,
            (o) => o!.setField,
            obj,
            false,
            const <ParameterReflection>[
              ParameterReflection(
                  TypeReflection.tString, 'key', false, true, null, null),
              ParameterReflection(
                  TypeReflection.tDynamic, 'value', true, true, null, null)
            ],
            null,
            const <String, ParameterReflection>{
              'def': ParameterReflection(
                  TypeReflection.tDynamic, 'def', true, false, null, null)
            },
            null);
      default:
        return null;
    }
  }

  @override
  List<String> get staticMethodsNames => const <String>['isVersion'];

  @override
  MethodReflection<TestUserWithReflection, R>? staticMethod<R>(
      String methodName) {
    var lc = methodName.trim().toLowerCase();

    switch (lc) {
      case 'isversion':
        return MethodReflection<TestUserWithReflection, R>(
            this,
            TestUserWithReflection,
            'isVersion',
            TypeReflection.tBool,
            false,
            (o) => TestUserWithReflection.isVersion,
            null,
            true,
            const <ParameterReflection>[
              ParameterReflection(
                  TypeReflection.tDouble, 'ver', false, true, null, null)
            ],
            null,
            null,
            null);
      default:
        return null;
    }
  }
}

extension TestAddressWithReflection$reflectionExtension
    on TestAddressWithReflection {
  /// Returns a [ClassReflection] for type [TestAddressWithReflection]. (Generated by [ReflectionFactory])
  ClassReflection<TestAddressWithReflection> get reflection =>
      TestAddressWithReflection$reflection(this);

  /// Returns a JSON [Map] for type [TestAddressWithReflection]. (Generated by [ReflectionFactory])
  Map<String, dynamic>? toJsonMap() => reflection.toJsonMap();

  /// Returns an encoded JSON [String] for type [TestAddressWithReflection]. (Generated by [ReflectionFactory])
  String toJsonEncoded({bool pretty = false}) =>
      reflection.toJsonEncoded(pretty: pretty);

  /// Returns a JSON for type [TestAddressWithReflection] using the class fields. (Generated by [ReflectionFactory])
  Object? toJsonFromFields() => reflection.toJsonFromFields();
}

extension TestCompanyWithReflection$reflectionExtension
    on TestCompanyWithReflection {
  /// Returns a [ClassReflection] for type [TestCompanyWithReflection]. (Generated by [ReflectionFactory])
  ClassReflection<TestCompanyWithReflection> get reflection =>
      TestCompanyWithReflection$reflection(this);

  /// Returns a JSON for type [TestCompanyWithReflection]. (Generated by [ReflectionFactory])
  Object? toJson() => reflection.toJson();

  /// Returns a JSON [Map] for type [TestCompanyWithReflection]. (Generated by [ReflectionFactory])
  Map<String, dynamic>? toJsonMap() => reflection.toJsonMap();

  /// Returns an encoded JSON [String] for type [TestCompanyWithReflection]. (Generated by [ReflectionFactory])
  String toJsonEncoded({bool pretty = false}) =>
      reflection.toJsonEncoded(pretty: pretty);

  /// Returns a JSON for type [TestCompanyWithReflection] using the class fields. (Generated by [ReflectionFactory])
  Object? toJsonFromFields() => reflection.toJsonFromFields();
}

extension TestDataWithReflection$reflectionExtension on TestDataWithReflection {
  /// Returns a [ClassReflection] for type [TestDataWithReflection]. (Generated by [ReflectionFactory])
  ClassReflection<TestDataWithReflection> get reflection =>
      TestDataWithReflection$reflection(this);

  /// Returns a JSON for type [TestDataWithReflection]. (Generated by [ReflectionFactory])
  Object? toJson() => reflection.toJson();

  /// Returns a JSON [Map] for type [TestDataWithReflection]. (Generated by [ReflectionFactory])
  Map<String, dynamic>? toJsonMap() => reflection.toJsonMap();

  /// Returns an encoded JSON [String] for type [TestDataWithReflection]. (Generated by [ReflectionFactory])
  String toJsonEncoded({bool pretty = false}) =>
      reflection.toJsonEncoded(pretty: pretty);

  /// Returns a JSON for type [TestDataWithReflection] using the class fields. (Generated by [ReflectionFactory])
  Object? toJsonFromFields() => reflection.toJsonFromFields();
}

extension TestDomainWithReflection$reflectionExtension
    on TestDomainWithReflection {
  /// Returns a [ClassReflection] for type [TestDomainWithReflection]. (Generated by [ReflectionFactory])
  ClassReflection<TestDomainWithReflection> get reflection =>
      TestDomainWithReflection$reflection(this);

  /// Returns a JSON [Map] for type [TestDomainWithReflection]. (Generated by [ReflectionFactory])
  Map<String, dynamic>? toJsonMap() => reflection.toJsonMap();

  /// Returns an encoded JSON [String] for type [TestDomainWithReflection]. (Generated by [ReflectionFactory])
  String toJsonEncoded({bool pretty = false}) =>
      reflection.toJsonEncoded(pretty: pretty);

  /// Returns a JSON for type [TestDomainWithReflection] using the class fields. (Generated by [ReflectionFactory])
  Object? toJsonFromFields() => reflection.toJsonFromFields();
}

extension TestEnumWithReflection$reflectionExtension on TestEnumWithReflection {
  /// Returns a [EnumReflection] for type [TestEnumWithReflection]. (Generated by [ReflectionFactory])
  EnumReflection<TestEnumWithReflection> get reflection =>
      TestEnumWithReflection$reflection(this);

  /// Returns the name of the [TestEnumWithReflection] instance. (Generated by [ReflectionFactory])
  String get enumName => TestEnumWithReflection$reflection(this).name()!;

  /// Returns a JSON for type [TestEnumWithReflection]. (Generated by [ReflectionFactory])
  String? toJson() => reflection.toJson();

  /// Returns a JSON [Map] for type [TestEnumWithReflection]. (Generated by [ReflectionFactory])
  Map<String, Object>? toJsonMap() => reflection.toJsonMap();

  /// Returns an encoded JSON [String] for type [TestEnumWithReflection]. (Generated by [ReflectionFactory])
  String toJsonEncoded({bool pretty = false}) =>
      reflection.toJsonEncoded(pretty: pretty);
}

extension TestOpAWithReflection$reflectionExtension on TestOpAWithReflection {
  /// Returns a [ClassReflection] for type [TestOpAWithReflection]. (Generated by [ReflectionFactory])
  ClassReflection<TestOpAWithReflection> get reflection =>
      TestOpAWithReflection$reflection(this);

  /// Returns a JSON for type [TestOpAWithReflection]. (Generated by [ReflectionFactory])
  Object? toJson() => reflection.toJson();

  /// Returns a JSON [Map] for type [TestOpAWithReflection]. (Generated by [ReflectionFactory])
  Map<String, dynamic>? toJsonMap() => reflection.toJsonMap();

  /// Returns an encoded JSON [String] for type [TestOpAWithReflection]. (Generated by [ReflectionFactory])
  String toJsonEncoded({bool pretty = false}) =>
      reflection.toJsonEncoded(pretty: pretty);

  /// Returns a JSON for type [TestOpAWithReflection] using the class fields. (Generated by [ReflectionFactory])
  Object? toJsonFromFields() => reflection.toJsonFromFields();
}

extension TestOpBWithReflection$reflectionExtension on TestOpBWithReflection {
  /// Returns a [ClassReflection] for type [TestOpBWithReflection]. (Generated by [ReflectionFactory])
  ClassReflection<TestOpBWithReflection> get reflection =>
      TestOpBWithReflection$reflection(this);

  /// Returns a JSON for type [TestOpBWithReflection]. (Generated by [ReflectionFactory])
  Object? toJson() => reflection.toJson();

  /// Returns a JSON [Map] for type [TestOpBWithReflection]. (Generated by [ReflectionFactory])
  Map<String, dynamic>? toJsonMap() => reflection.toJsonMap();

  /// Returns an encoded JSON [String] for type [TestOpBWithReflection]. (Generated by [ReflectionFactory])
  String toJsonEncoded({bool pretty = false}) =>
      reflection.toJsonEncoded(pretty: pretty);

  /// Returns a JSON for type [TestOpBWithReflection] using the class fields. (Generated by [ReflectionFactory])
  Object? toJsonFromFields() => reflection.toJsonFromFields();
}

extension TestOpWithReflection$reflectionExtension on TestOpWithReflection {
  /// Returns a [ClassReflection] for type [TestOpWithReflection]. (Generated by [ReflectionFactory])
  ClassReflection<TestOpWithReflection> get reflection =>
      TestOpWithReflection$reflection(this);

  /// Returns a JSON for type [TestOpWithReflection]. (Generated by [ReflectionFactory])
  Object? toJson() => reflection.toJson();

  /// Returns a JSON [Map] for type [TestOpWithReflection]. (Generated by [ReflectionFactory])
  Map<String, dynamic>? toJsonMap() => reflection.toJsonMap();

  /// Returns an encoded JSON [String] for type [TestOpWithReflection]. (Generated by [ReflectionFactory])
  String toJsonEncoded({bool pretty = false}) =>
      reflection.toJsonEncoded(pretty: pretty);

  /// Returns a JSON for type [TestOpWithReflection] using the class fields. (Generated by [ReflectionFactory])
  Object? toJsonFromFields() => reflection.toJsonFromFields();
}

extension TestUserWithReflection$reflectionExtension on TestUserWithReflection {
  /// Returns a [ClassReflection] for type [TestUserWithReflection]. (Generated by [ReflectionFactory])
  ClassReflection<TestUserWithReflection> get reflection =>
      TestUserWithReflection$reflection(this);

  /// Returns a JSON for type [TestUserWithReflection]. (Generated by [ReflectionFactory])
  Object? toJson() => reflection.toJson();

  /// Returns a JSON [Map] for type [TestUserWithReflection]. (Generated by [ReflectionFactory])
  Map<String, dynamic>? toJsonMap() => reflection.toJsonMap();

  /// Returns an encoded JSON [String] for type [TestUserWithReflection]. (Generated by [ReflectionFactory])
  String toJsonEncoded({bool pretty = false}) =>
      reflection.toJsonEncoded(pretty: pretty);

  /// Returns a JSON for type [TestUserWithReflection] using the class fields. (Generated by [ReflectionFactory])
  Object? toJsonFromFields() => reflection.toJsonFromFields();
}

List<Reflection> _listSiblingsReflection() => <Reflection>[
      TestUserWithReflection$reflection(),
      TestAddressWithReflection$reflection(),
      TestCompanyWithReflection$reflection(),
      TestDataWithReflection$reflection(),
      TestDomainWithReflection$reflection(),
      TestOpWithReflection$reflection(),
      TestOpAWithReflection$reflection(),
      TestOpBWithReflection$reflection(),
      TestEnumWithReflection$reflection(),
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
