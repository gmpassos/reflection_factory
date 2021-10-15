//
// GENERATED CODE - DO NOT MODIFY BY HAND!
// BUILDER: reflection_factory/1.0.14
// BUILD COMMAND: dart run build_runner build
//

part of 'user_with_reflection.dart';

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
      _registerSiblingsClassReflection();
    }
  }

  @override
  Version get languageVersion => Version.parse('2.13.0');

  @override
  TestAddressWithReflection$reflection withObject(
          [TestAddressWithReflection? obj]) =>
      TestAddressWithReflection$reflection(obj);

  @override
  bool get hasDefaultConstructor => false;
  @override
  TestAddressWithReflection? createInstanceWithDefaultConstructor() => null;

  @override
  bool get hasEmptyConstructor => false;
  @override
  TestAddressWithReflection? createInstanceWithEmptyConstructor() => null;

  @override
  List<String> get constructorsNames => const <String>[''];

  @override
  ConstructorReflection<TestAddressWithReflection>? constructor<R>(
      String constructorName) {
    var lc = constructorName.trim().toLowerCase();

    switch (lc) {
      case '':
        return ConstructorReflection<TestAddressWithReflection>(
            this,
            '',
            () => (String state, String city) =>
                TestAddressWithReflection(state, city),
            const <ParameterReflection>[
              ParameterReflection(
                  TypeReflection.tString, 'state', false, true, null, null),
              ParameterReflection(
                  TypeReflection.tString, 'city', false, true, null, null)
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
  List<ClassReflection> siblingsClassReflection() => _siblingsClassReflection();

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
          null,
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
      _registerSiblingsClassReflection();
    }
  }

  @override
  Version get languageVersion => Version.parse('2.13.0');

  @override
  TestUserWithReflection$reflection withObject([TestUserWithReflection? obj]) =>
      TestUserWithReflection$reflection(obj);

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
                    {bool enabled = true}) =>
                TestUserWithReflection.fields(name, email, password,
                    enabled: enabled),
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
              'enabled': ParameterReflection(
                  TypeReflection.tBool, 'enabled', false, false, true, null)
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
  List<ClassReflection> siblingsClassReflection() => _siblingsClassReflection();

  @override
  List<String> get fieldsNames =>
      const <String>['email', 'enabled', 'name', 'password'];

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

  /// Returns an encoded JSON [String] for type [TestAddressWithReflection]. (Generated by [ReflectionFactory])
  String toJsonEncoded() => reflection.toJsonEncoded();
}

extension TestUserWithReflection$reflectionExtension on TestUserWithReflection {
  /// Returns a [ClassReflection] for type [TestUserWithReflection]. (Generated by [ReflectionFactory])
  ClassReflection<TestUserWithReflection> get reflection =>
      TestUserWithReflection$reflection(this);

  /// Returns a JSON [Map] for type [TestUserWithReflection]. (Generated by [ReflectionFactory])
  Map<String, dynamic> toJson() => reflection.toJson();

  /// Returns an encoded JSON [String] for type [TestUserWithReflection]. (Generated by [ReflectionFactory])
  String toJsonEncoded() => reflection.toJsonEncoded();
}

List<ClassReflection> _listSiblingsClassReflection() => <ClassReflection>[
      TestUserWithReflection$reflection(),
      TestAddressWithReflection$reflection(),
    ];

List<ClassReflection>? _siblingsClassReflectionList;
List<ClassReflection> _siblingsClassReflection() =>
    _siblingsClassReflectionList ??=
        List<ClassReflection>.unmodifiable(_listSiblingsClassReflection());

bool _registerSiblingsClassReflectionCalled = false;
void _registerSiblingsClassReflection() {
  if (_registerSiblingsClassReflectionCalled) return;
  _registerSiblingsClassReflectionCalled = true;
  var length = _listSiblingsClassReflection().length;
  assert(length > 0);
}
