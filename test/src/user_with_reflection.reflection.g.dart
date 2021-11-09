//
// GENERATED CODE - DO NOT MODIFY BY HAND!
// BUILDER: reflection_factory/1.0.17
// BUILD COMMAND: dart run build_runner build
//

// ignore_for_file: unnecessary_const

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
  Version get reflectionFactoryVersion => Version.parse('1.0.17');

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
  Version get reflectionFactoryVersion => Version.parse('1.0.17');

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
  Version get reflectionFactoryVersion => Version.parse('1.0.17');

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
  Version get reflectionFactoryVersion => Version.parse('1.0.17');

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
  List<String> get constructorsNames => const <String>['', 'parse'];

  @override
  ConstructorReflection<TestDomainWithReflection>? constructor<R>(
      String constructorName) {
    var lc = constructorName.trim().toLowerCase();

    switch (lc) {
      case '':
        return ConstructorReflection<TestDomainWithReflection>(
            this,
            '',
            () => (String name, String suffix) =>
                TestDomainWithReflection(name, suffix),
            const <ParameterReflection>[
              ParameterReflection(
                  TypeReflection.tString, 'name', false, true, null, null),
              ParameterReflection(
                  TypeReflection.tString, 'suffix', false, true, null, null)
            ],
            null,
            null,
            null);
      case 'parse':
        return ConstructorReflection<TestDomainWithReflection>(
            this,
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
  bool get hasMethodToJson => true;

  @override
  Object? callMethodToJson([TestDomainWithReflection? obj]) {
    obj ??= object;
    return obj?.toJson();
  }

  @override
  List<String> get fieldsNames => const <String>['hashCode', 'name', 'suffix'];

  @override
  FieldReflection<TestDomainWithReflection, T>? field<T>(String fieldName,
      [TestDomainWithReflection? obj]) {
    obj ??= object;

    var lc = fieldName.trim().toLowerCase();

    switch (lc) {
      case 'name':
        return FieldReflection<TestDomainWithReflection, T>(
          this,
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
      case 'hashcode':
        return FieldReflection<TestDomainWithReflection, T>(
          this,
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
  List<String> get methodsNames => const <String>['toJson', 'toString'];

  @override
  MethodReflection<TestDomainWithReflection, R>? method<R>(String methodName,
      [TestDomainWithReflection? obj]) {
    obj ??= object;

    var lc = methodName.trim().toLowerCase();

    switch (lc) {
      case 'tojson':
        return MethodReflection<TestDomainWithReflection, R>(
            this,
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
  Version get reflectionFactoryVersion => Version.parse('1.0.17');

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
  Version get reflectionFactoryVersion => Version.parse('1.0.17');

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
        return ConstructorReflection<TestUserWithReflection>(this, '',
            () => () => TestUserWithReflection(), null, null, null, null);
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
            'getField',
            TypeReflection.tObject,
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
                  TypeReflection.tObject, 'def', true, false, null, null)
            ],
            null,
            null);
      case 'setfield':
        return MethodReflection<TestUserWithReflection, R>(
            this,
            'setField',
            null,
            false,
            (o) => o!.setField,
            obj,
            false,
            const <ParameterReflection>[
              ParameterReflection(
                  TypeReflection.tString, 'key', false, true, null, null),
              ParameterReflection(
                  TypeReflection.tObject, 'value', true, true, null, null)
            ],
            null,
            const <String, ParameterReflection>{
              'def': ParameterReflection(
                  TypeReflection.tObject, 'def', true, false, null, null)
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
}

extension TestEnumWithReflection$reflectionExtension on TestEnumWithReflection {
  /// Returns a [EnumReflection] for type [TestEnumWithReflection]. (Generated by [ReflectionFactory])
  EnumReflection<TestEnumWithReflection> get reflection =>
      TestEnumWithReflection$reflection(this);

  /// Returns a JSON for type [TestEnumWithReflection]. (Generated by [ReflectionFactory])
  String? toJson() => reflection.toJson();

  /// Returns a JSON [Map] for type [TestEnumWithReflection]. (Generated by [ReflectionFactory])
  Map<String, Object>? toJsonMap() => reflection.toJsonMap();

  /// Returns an encoded JSON [String] for type [TestEnumWithReflection]. (Generated by [ReflectionFactory])
  String toJsonEncoded({bool pretty = false}) =>
      reflection.toJsonEncoded(pretty: pretty);
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
}

List<Reflection> _listSiblingsReflection() => <Reflection>[
      TestUserWithReflection$reflection(),
      TestAddressWithReflection$reflection(),
      TestCompanyWithReflection$reflection(),
      TestDataWithReflection$reflection(),
      TestDomainWithReflection$reflection(),
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
