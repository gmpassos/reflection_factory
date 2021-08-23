//
// GENERATED CODE - DO NOT MODIFY BY HAND!
// BUILDER: "reflection_factory"
// BUILD COMMAND: dart run build_runner build
//

part of 'user_with_reflection.dart';

class TestUserWithReflection$reflection
    extends ClassReflection<TestUserWithReflection> {
  TestUserWithReflection$reflection([TestUserWithReflection? object])
      : super(TestUserWithReflection, object);

  @override
  TestUserWithReflection$reflection withObject([TestUserWithReflection? obj]) =>
      TestUserWithReflection$reflection(obj);

  @override
  Version get languageVersion => Version.parse('2.13.0');

  @override
  List<String> get fieldsNames => const <String>['email', 'name', 'password'];

  @override
  FieldReflection<TestUserWithReflection, T>? field<T>(String fieldName,
      [TestUserWithReflection? obj]) {
    obj ??= object!;

    var lc = fieldName.trim().toLowerCase();

    switch (lc) {
      case 'name':
        return FieldReflection<TestUserWithReflection, T>(this, 'name', String,
            false, () => obj!.name as T, null, obj, false, true);
      case 'email':
        return FieldReflection<TestUserWithReflection, T>(
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
        return FieldReflection<TestUserWithReflection, T>(
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
  FieldReflection<TestUserWithReflection, T>? staticField<T>(String fieldName) {
    var lc = fieldName.trim().toLowerCase();

    switch (lc) {
      case 'version':
        return FieldReflection<TestUserWithReflection, T>(
            this,
            'version',
            double,
            false,
            () => TestUserWithReflection.version as T,
            null,
            null,
            true,
            true);
      case 'withreflection':
        return FieldReflection<TestUserWithReflection, T>(
            this,
            'withReflection',
            bool,
            false,
            () => TestUserWithReflection.withReflection as T,
            null,
            null,
            true,
            true);
      default:
        return null;
    }
  }

  @override
  List<String> get methodsNames => const <String>['checkPassword'];

  @override
  MethodReflection<TestUserWithReflection>? method(String methodName,
      [TestUserWithReflection? obj]) {
    obj ??= object!;

    var lc = methodName.trim().toLowerCase();

    switch (lc) {
      case 'checkpassword':
        return MethodReflection<TestUserWithReflection>(
            this,
            'checkPassword',
            bool,
            false,
            obj.checkPassword,
            obj,
            false,
            const <Type>[String],
            const <Type>[],
            const <String, Type>{});
      default:
        return null;
    }
  }

  @override
  List<String> get staticMethodsNames => const <String>[];

  @override
  MethodReflection<TestUserWithReflection>? staticMethod(String methodName) {
    return null;
  }
}

extension TestUserWithReflection$reflectionExtension on TestUserWithReflection {
  ClassReflection<TestUserWithReflection> get reflection =>
      TestUserWithReflection$reflection(this);

  Map<String, dynamic> toJson() => reflection.toJson();

  String toJsonEncoded() => reflection.toJsonEncoded();
}
