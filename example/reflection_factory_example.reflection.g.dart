//
// GENERATED CODE - DO NOT MODIFY BY HAND!
// BUILDER: reflection_factory/2.3.3
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

part of 'reflection_factory_example.dart';

typedef __TR<T> = TypeReflection<T>;
typedef __TI<T> = TypeInfo<T>;
typedef __PR = ParameterReflection;

mixin __ReflectionMixin {
  static final Version _version = Version.parse('2.3.3');

  Version get reflectionFactoryVersion => _version;

  List<Reflection> siblingsReflection() => _siblingsReflection();
}

// ignore: non_constant_identifier_names
User User$fromJson(Map<String, Object?> map) =>
    User$reflection.staticInstance.fromJson(map);
// ignore: non_constant_identifier_names
User User$fromJsonEncoded(String jsonEncoded) =>
    User$reflection.staticInstance.fromJsonEncoded(jsonEncoded);

class User$reflection extends ClassReflection<User> with __ReflectionMixin {
  static final Expando<User$reflection> _objectReflections = Expando();

  factory User$reflection([User? object]) {
    if (object == null) return staticInstance;
    return _objectReflections[object] ??= User$reflection._(object);
  }

  User$reflection._([User? object]) : super(User, 'User', object);

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
  Version get languageVersion => Version.parse('3.0.0');

  @override
  User$reflection withObject([User? obj]) =>
      User$reflection(obj)..setupInternalsWith(this);

  static User$reflection? _withoutObjectInstance;
  @override
  User$reflection withoutObjectInstance() => staticInstance;

  static User$reflection get staticInstance =>
      _withoutObjectInstance ??= User$reflection._();

  @override
  User$reflection getStaticInstance() => staticInstance;

  static bool _boot = false;
  static void boot() {
    if (_boot) return;
    _boot = true;
    User$reflection.staticInstance;
  }

  @override
  bool get hasDefaultConstructor => false;
  @override
  User? createInstanceWithDefaultConstructor() => null;

  @override
  bool get hasEmptyConstructor => true;
  @override
  User? createInstanceWithEmptyConstructor() => User.empty();
  @override
  bool get hasNoRequiredArgsConstructor => true;
  @override
  User? createInstanceWithNoRequiredArgsConstructor() => User.empty();

  static const List<String> _constructorsNames = const <String>['', 'empty'];

  @override
  List<String> get constructorsNames => _constructorsNames;

  static final Map<String, ConstructorReflection<User>> _constructors = {};

  @override
  ConstructorReflection<User>? constructor(String constructorName) {
    var c = _constructors[constructorName];
    if (c != null) return c;
    c = _constructorImpl(constructorName);
    if (c == null) return null;
    _constructors[constructorName] = c;
    return c;
  }

  ConstructorReflection<User>? _constructorImpl(String constructorName) {
    var lc = constructorName.trim().toLowerCase();

    switch (lc) {
      case '':
        return ConstructorReflection<User>(
            this,
            User,
            '',
            () => (String? email, String pass) => User(email, pass),
            const <__PR>[
              __PR(__TR.tString, 'email', true, true),
              __PR(__TR.tString, 'pass', false, true)
            ],
            null,
            null,
            null);
      case 'empty':
        return ConstructorReflection<User>(this, User, 'empty',
            () => () => User.empty(), null, null, null, null);
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
  Object? callMethodToJson([User? obj]) => null;

  static const List<String> _fieldsNames = const <String>[
    'email',
    'hasEmail',
    'pass'
  ];

  @override
  List<String> get fieldsNames => _fieldsNames;

  static final Map<String, FieldReflection<User, dynamic>> _fieldsNoObject = {};

  final Map<String, FieldReflection<User, dynamic>> _fieldsObject = {};

  @override
  FieldReflection<User, T>? field<T>(String fieldName, [User? obj]) {
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

  FieldReflection<User, T>? _fieldNoObjectImpl<T>(String fieldName) {
    final f = _fieldsNoObject[fieldName];
    if (f != null) {
      return f as FieldReflection<User, T>;
    }
    final f2 = _fieldImpl(fieldName, null);
    if (f2 == null) return null;
    _fieldsNoObject[fieldName] = f2;
    return f2 as FieldReflection<User, T>;
  }

  FieldReflection<User, T>? _fieldObjectImpl<T>(String fieldName) {
    final f = _fieldsObject[fieldName];
    if (f != null) {
      return f as FieldReflection<User, T>;
    }
    var f2 = _fieldNoObjectImpl<T>(fieldName);
    if (f2 == null) return null;
    f2 = f2.withObject(object!);
    _fieldsObject[fieldName] = f2;
    return f2;
  }

  FieldReflection<User, dynamic>? _fieldImpl(String fieldName, User? obj) {
    obj ??= object;

    var lc = fieldName.trim().toLowerCase();

    switch (lc) {
      case 'email':
        return FieldReflection<User, String?>(
          this,
          User,
          __TR.tString,
          'email',
          true,
          (o) => () => o!.email,
          (o) => (v) => o!.email = v,
          obj,
          false,
        );
      case 'pass':
        return FieldReflection<User, String>(
          this,
          User,
          __TR.tString,
          'pass',
          false,
          (o) => () => o!.pass,
          (o) => (v) => o!.pass = v,
          obj,
          false,
        );
      case 'hasemail':
        return FieldReflection<User, bool>(
          this,
          User,
          __TR.tBool,
          'hasEmail',
          false,
          (o) => () => o!.hasEmail,
          null,
          obj,
          false,
        );
      default:
        return null;
    }
  }

  @override
  Map<String, dynamic> getFieldsValues(User? obj, {bool withHashCode = false}) {
    obj ??= object;
    return <String, dynamic>{
      'email': obj?.email,
      'pass': obj?.pass,
      'hasEmail': obj?.hasEmail,
      if (withHashCode) 'hashCode': obj?.hashCode,
    };
  }

  static const List<String> _staticFieldsNames = const <String>[];

  @override
  List<String> get staticFieldsNames => _staticFieldsNames;

  @override
  StaticFieldReflection<User, T>? staticField<T>(String fieldName) => null;

  static const List<String> _methodsNames = const <String>['checkPassword'];

  @override
  List<String> get methodsNames => _methodsNames;

  static final Map<String, MethodReflection<User, dynamic>> _methodsNoObject =
      {};

  final Map<String, MethodReflection<User, dynamic>> _methodsObject = {};

  @override
  MethodReflection<User, R>? method<R>(String methodName, [User? obj]) {
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

  MethodReflection<User, R>? _methodNoObjectImpl<R>(String methodName) {
    final m = _methodsNoObject[methodName];
    if (m != null) {
      return m as MethodReflection<User, R>;
    }
    final m2 = _methodImpl(methodName, null);
    if (m2 == null) return null;
    _methodsNoObject[methodName] = m2;
    return m2 as MethodReflection<User, R>;
  }

  MethodReflection<User, R>? _methodObjectImpl<R>(String methodName) {
    final m = _methodsObject[methodName];
    if (m != null) {
      return m as MethodReflection<User, R>;
    }
    var m2 = _methodNoObjectImpl<R>(methodName);
    if (m2 == null) return null;
    m2 = m2.withObject(object!);
    _methodsObject[methodName] = m2;
    return m2;
  }

  MethodReflection<User, dynamic>? _methodImpl(String methodName, User? obj) {
    obj ??= object;

    var lc = methodName.trim().toLowerCase();

    switch (lc) {
      case 'checkpassword':
        return MethodReflection<User, bool>(
            this,
            User,
            'checkPassword',
            __TR.tBool,
            false,
            (o) => o!.checkPassword,
            obj,
            const <__PR>[__PR(__TR.tString, 'pass', false, true)],
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
  StaticMethodReflection<User, R>? staticMethod<R>(String methodName) => null;
}

extension User$reflectionExtension on User {
  /// Returns a [ClassReflection] for type [User]. (Generated by [ReflectionFactory])
  ClassReflection<User> get reflection => User$reflection(this);

  /// Returns a JSON for type [User]. (Generated by [ReflectionFactory])
  Object? toJson({bool duplicatedEntitiesAsID = false}) =>
      reflection.toJson(null, null, duplicatedEntitiesAsID);

  /// Returns a JSON [Map] for type [User]. (Generated by [ReflectionFactory])
  Map<String, dynamic>? toJsonMap({bool duplicatedEntitiesAsID = false}) =>
      reflection.toJsonMap(duplicatedEntitiesAsID: duplicatedEntitiesAsID);

  /// Returns an encoded JSON [String] for type [User]. (Generated by [ReflectionFactory])
  String toJsonEncoded(
          {bool pretty = false, bool duplicatedEntitiesAsID = false}) =>
      reflection.toJsonEncoded(
          pretty: pretty, duplicatedEntitiesAsID: duplicatedEntitiesAsID);

  /// Returns a JSON for type [User] using the class fields. (Generated by [ReflectionFactory])
  Object? toJsonFromFields({bool duplicatedEntitiesAsID = false}) => reflection
      .toJsonFromFields(duplicatedEntitiesAsID: duplicatedEntitiesAsID);
}

List<Reflection> _listSiblingsReflection() => <Reflection>[
      User$reflection(),
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
