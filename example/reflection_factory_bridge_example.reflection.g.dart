//
// GENERATED CODE - DO NOT MODIFY BY HAND!
// BUILDER: "reflection_factory"
// BUILD COMMAND: dart run build_runner build
//

part of 'reflection_factory_bridge_example.dart';

class User$reflection extends ClassReflection<User> {
  User$reflection([User? object]) : super(User, object);

  @override
  User$reflection withObject([User? obj]) => User$reflection(obj);

  @override
  Version get languageVersion => Version.parse('2.13.0');

  @override
  List<String> get fieldsNames => const <String>['email', 'hasEmail', 'pass'];

  @override
  FieldReflection<User, T>? field<T>(String fieldName, [User? obj]) {
    obj ??= object!;

    var lc = fieldName.trim().toLowerCase();

    switch (lc) {
      case 'email':
        return FieldReflection<User, T>(
            this,
            'email',
            String,
            true,
            () => obj!.email as T,
            (T v) => obj!.email = v as String?,
            obj,
            false,
            false);
      case 'pass':
        return FieldReflection<User, T>(
            this,
            'pass',
            String,
            false,
            () => obj!.pass as T,
            (T v) => obj!.pass = v as String,
            obj,
            false,
            false);
      case 'hasemail':
        return FieldReflection<User, T>(this, 'hasEmail', bool, false,
            () => obj!.hasEmail as T, null, obj, false, false);
      default:
        return null;
    }
  }

  @override
  List<String> get staticFieldsNames => const <String>[];

  @override
  FieldReflection<User, T>? staticField<T>(String fieldName) {
    return null;
  }

  @override
  List<String> get methodsNames => const <String>['checkPassword'];

  @override
  MethodReflection<User>? method(String methodName, [User? obj]) {
    obj ??= object!;

    var lc = methodName.trim().toLowerCase();

    switch (lc) {
      case 'checkpassword':
        return MethodReflection<User>(
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
  MethodReflection<User>? staticMethod(String methodName) {
    return null;
  }
}

extension User$reflectionExtension on User {
  ClassReflection<User> get reflection => User$reflection(this);

  Map<String, dynamic> toJson() => reflection.toJson();

  String toJsonEncoded() => reflection.toJsonEncoded();
}

extension UserReflectionBridge$reflectionExtension on UserReflectionBridge {
  ClassReflection<T> reflection<T>([T? obj]) {
    switch (T) {
      case User:
        return User$reflection(obj as User?) as ClassReflection<T>;
      default:
        throw UnsupportedError('<$runtimeType> No reflection for Type: $T');
    }
  }
}
