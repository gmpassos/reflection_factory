//
// GENERATED CODE - DO NOT MODIFY BY HAND!
// BUILDER: "reflection_factory"
// BUILD COMMAND: dart run build_runner build
//

part of 'user_reflection_bridge.dart';

class TestUserSimple$reflection extends ClassReflection<TestUserSimple> {
  TestUserSimple$reflection([TestUserSimple? object])
      : super(TestUserSimple, object);

  bool _registered = false;
  @override
  void register() {
    if (!_registered) {
      _registered = true;
      super.register();
    }
  }

  @override
  TestUserSimple$reflection withObject([TestUserSimple? obj]) =>
      TestUserSimple$reflection(obj);

  @override
  Version get languageVersion => Version.parse('2.13.0');

  @override
  List<String> get fieldsNames => const <String>['email', 'name', 'password'];

  @override
  FieldReflection<TestUserSimple, T>? field<T>(String fieldName,
      [TestUserSimple? obj]) {
    obj ??= object!;

    var lc = fieldName.trim().toLowerCase();

    switch (lc) {
      case 'name':
        return FieldReflection<TestUserSimple, T>(this, 'name', String, false,
            () => obj!.name as T, null, obj, false, true);
      case 'email':
        return FieldReflection<TestUserSimple, T>(
            this,
            'email',
            String,
            true,
            () => obj!.email as T,
            (T v) => obj!.email = v as String?,
            obj,
            false,
            false);
      case 'password':
        return FieldReflection<TestUserSimple, T>(
            this,
            'password',
            String,
            false,
            () => obj!.password as T,
            (T v) => obj!.password = v as String,
            obj,
            false,
            false);
      default:
        return null;
    }
  }

  @override
  List<String> get staticFieldsNames =>
      const <String>['version', 'withReflection'];

  @override
  FieldReflection<TestUserSimple, T>? staticField<T>(String fieldName) {
    var lc = fieldName.trim().toLowerCase();

    switch (lc) {
      case 'version':
        return FieldReflection<TestUserSimple, T>(this, 'version', double,
            false, () => TestUserSimple.version as T, null, null, true, true);
      case 'withreflection':
        return FieldReflection<TestUserSimple, T>(
            this,
            'withReflection',
            bool,
            false,
            () => TestUserSimple.withReflection as T,
            null,
            null,
            true,
            true);
      default:
        return null;
    }
  }

  @override
  List<String> get methodsNames => const <String>['checkThePassword'];

  @override
  MethodReflection<TestUserSimple>? method(String methodName,
      [TestUserSimple? obj]) {
    obj ??= object!;

    var lc = methodName.trim().toLowerCase();

    switch (lc) {
      case 'checkthepassword':
        return MethodReflection<TestUserSimple>(
            this,
            'checkThePassword',
            bool,
            false,
            obj.checkThePassword,
            obj,
            false,
            const <Type>[String],
            const <String>['password'],
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
  MethodReflection<TestUserSimple>? staticMethod(String methodName) {
    return null;
  }
}

extension TestUserReflectionBridge$reflectionExtension
    on TestUserReflectionBridge {
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
  ClassReflection<TestUserSimple> get reflection =>
      TestUserSimple$reflection(this);

  Map<String, dynamic> toJson() => reflection.toJson();

  String toJsonEncoded() => reflection.toJsonEncoded();
}
