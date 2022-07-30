import 'dart:async';
import 'dart:convert' as dart_convert;

import 'package:collection/collection.dart'
    show
        DeepCollectionEquality,
        IterableExtension,
        IterableNullableExtension,
        ListEquality,
        MapEquality,
        binarySearch,
        equalsIgnoreAsciiCase;
import 'package:pub_semver/pub_semver.dart';

import 'reflection_factory_annotation.dart';
import 'reflection_factory_json.dart';
import 'reflection_factory_type.dart';

/// Class with all registered reflections ([ClassReflection]).
class ReflectionFactory {
  // ignore: constant_identifier_names
  static const String VERSION = '1.2.3';

  static final ReflectionFactory _instance = ReflectionFactory._();

  ReflectionFactory._();

  /// Returns the singleton instance of [ReflectionFactory].
  factory ReflectionFactory() => _instance;

  final Map<Type, EnumReflection> _registeredEnumReflection =
      <Type, EnumReflection>{};

  /// Returns `true` if a [EnumReflection] is registered for [enumType].
  bool hasRegisterEnumReflection<O>([Type? enumType]) =>
      _registeredEnumReflection.containsKey(enumType ?? O);

  /// Returns the registered [EnumReflection] for [enumType].
  EnumReflection<O>? getRegisterEnumReflection<O>([Type? enumType]) =>
      _registeredEnumReflection[enumType ?? O] as EnumReflection<O>?;

  /// Called by [EnumReflection] when instantiated for the 1st time.
  void registerEnumReflection<O>(EnumReflection<O> enumReflection) {
    var enumType = enumReflection.enumType;
    var prev = _registeredEnumReflection[enumType];

    if (prev == null || prev.compareTo(enumReflection) < 0) {
      _registeredEnumReflection[enumType] = enumReflection;
    }
  }

  final Map<Type, ClassReflection> _registeredClassReflection =
      <Type, ClassReflection>{};

  /// Returns `true` if a [ClassReflection] is registered for [classType].
  bool hasRegisterClassReflection<O>([Type? classType]) =>
      _registeredClassReflection.containsKey(classType ?? O);

  /// Returns the registered [ClassReflection] for [classType].
  ClassReflection<O>? getRegisterClassReflection<O>([Type? classType]) =>
      _registeredClassReflection[classType ?? O] as ClassReflection<O>?;

  /// Called by [ClassReflection] when instantiated for the 1st time.
  void registerClassReflection<O>(ClassReflection<O> classReflection) {
    var classType = classReflection.classType;
    var prev = _registeredClassReflection[classType];

    if (prev == null || prev.compareTo(classReflection) < 0) {
      _registeredClassReflection[classType] = classReflection;
    }
  }

  /// A JSON encodable transformer, that resolves the registered [ClassReflection]
  /// of the passed [object], and calls [ClassReflection.toJson].
  ///
  /// - [toEncodable] to use when there's no registered [ClassReflection] for [object].
  ///   Defaults to `object.toJson`.
  ///
  /// Usually used with:
  /// ```dart
  ///   json.encode(obj, toEncodable: ReflectionFactory.toJsonEncodable);
  /// ````
  static Object? toJsonEncodable(dynamic object,
      {Object? Function(dynamic object)? toEncodable}) {
    if (object == null) {
      return null;
    }

    if (object is DateTime) {
      return object.toUtc().toString();
    }

    var classReflection =
        _instance.getRegisterClassReflection(object.runtimeType);
    if (classReflection != null) {
      return classReflection.toJson(object);
    }

    var enumReflection =
        _instance.getRegisterEnumReflection(object.runtimeType);
    if (enumReflection != null) {
      return enumReflection.toJson(object);
    }

    if (toEncodable != null) {
      return toEncodable(object);
    }

    try {
      return object.toJson();
    } catch (e) {
      return object;
    }
  }
}

/// Base for reflection.
abstract class Reflection<O> {
  /// The reflected type by this implementation.
  Type get reflectedType;

  /// Register this reflection implementation.
  void register();

  /// Returns `true` if this instances has an associated object ([O]).
  bool get hasObject;

  /// Returns a new instances with [obj] as the associated object ([O]).
  Reflection<O> withObject([O? obj]);

  /// Returns a new instances without an [object] instance.
  Reflection<O> withoutObjectInstance();

  /// Returns the Dart language [Version] of the reflected code.
  Version get languageVersion;

  /// Returns `reflection_factory` [Version] used to generate this reflection code.
  Version get reflectionFactoryVersion;

  /// Returns the reflection name.
  String get reflectionName => reflectedType.toString();

  /// The reflection level (complexity).
  int get reflectionLevel;

  /// Cast [list] to [classType] if [type] == [classType] or return `null`.
  List? castList(List list, Type type) {
    if (type == reflectedType) {
      if (list is List<O>) {
        return list;
      } else {
        return List<O>.from(list);
      }
    } else if (type == dynamic) {
      return List<dynamic>.from(list);
    } else if (type == Object) {
      return List<Object>.from(list);
    }

    return null;
  }

  /// Cast [set] to [classType] if [type] == [classType] or return `null`.
  Set? castSet(Set set, Type type) {
    if (type == reflectedType) {
      if (set is Set<O>) {
        return set;
      } else {
        return Set<O>.from(set);
      }
    } else if (type == dynamic) {
      return Set<dynamic>.from(set);
    } else if (type == Object) {
      return Set<Object>.from(set);
    }

    return null;
  }

  /// Cast [itr] to [classType] if [type] == [classType] or return `null`.
  Iterable? castIterable(Iterable itr, Type type) {
    if (type == reflectedType) {
      if (itr is Iterable<O>) {
        return itr;
      } else {
        return itr.cast<O>();
      }
    } else if (type == dynamic) {
      return itr.cast<dynamic>();
    } else if (type == Object) {
      return itr.cast<Object>();
    }

    return null;
  }

  /// Cast [map] values to [classType] if [type] == [classType] or return `null`.
  Map? castMap(Map map, TypeInfo typeInfo) {
    if (!typeInfo.isMap) {
      return map;
    }

    var keyType = typeInfo.argumentType(0) ?? TypeInfo.tDynamic;
    var valueType = typeInfo.argumentType(1) ?? TypeInfo.tDynamic;

    if (keyType.isString) {
      if (valueType.type == reflectedType) {
        if (map is Map<String, O>) {
          return map;
        } else {
          return map
              .map<String, O>((key, value) => MapEntry<String, O>(key, value));
        }
      } else if (valueType.isDynamic) {
        return map.map<String, dynamic>(
            (key, value) => MapEntry<String, dynamic>(key, value));
      } else if (valueType.isObject) {
        return map.map<String, Object>(
            (key, value) => MapEntry<String, Object>(key, value));
      }
    } else if (keyType.isObject) {
      if (valueType.type == reflectedType) {
        if (map is Map<Object, O>) {
          return map;
        } else {
          return map
              .map<Object, O>((key, value) => MapEntry<Object, O>(key, value));
        }
      } else if (valueType.isDynamic) {
        return map.map<Object, dynamic>(
            (key, value) => MapEntry<Object, dynamic>(key, value));
      } else if (valueType.isObject) {
        return map.map<Object, Object>(
            (key, value) => MapEntry<Object, Object>(key, value));
      }
    } else if (keyType.isDynamic) {
      if (valueType.type == reflectedType) {
        if (map is Map<dynamic, O>) {
          return map;
        } else {
          return map.map<dynamic, O>(
              (key, value) => MapEntry<dynamic, O>(key, value));
        }
      } else if (valueType.isDynamic) {
        return map.map<dynamic, dynamic>(
            (key, value) => MapEntry<dynamic, dynamic>(key, value));
      } else if (valueType.isObject) {
        return map.map<dynamic, Object>(
            (key, value) => MapEntry<dynamic, Object>(key, value));
      }
    }

    return null;
  }

  /// Cast [o] to a collection represented by [typeInfo].
  Object? castCollection(dynamic o, TypeInfo typeInfo) {
    if (o == null) return null;

    var mainType = typeInfo.argumentType(0) ?? typeInfo;

    if (typeInfo.isSet) {
      return castSet(o, mainType.type);
    } else if (typeInfo.isList) {
      return castList(o, mainType.type);
    } else if (typeInfo.isIterable) {
      return castIterable(o, mainType.type);
    } else if (typeInfo.isMap) {
      return castMap(o, typeInfo);
    }

    return null;
  }

  /// Calls [function] with correct casting for [Reflection].
  R callCasted<R>(R Function<O>(Reflection<O> reflection) function) {
    return function<O>(this);
  }

  /// Returns a [List] of siblings [Reflection] (declared in the same code unit).
  List<Reflection> siblingsReflection();

  /// Returns a [Reflection] for [type], [obj] or [T].
  Reflection<T>? siblingReflectionFor<T>({T? obj, Type? type}) {
    type ??= obj?.runtimeType ?? T;

    var reflectionForType =
        siblingsReflection().where((c) => c.reflectedType == type).firstOrNull;
    return reflectionForType as Reflection<T>;
  }

  /// Returns a `const` [List] of class annotations.
  List<Object> get classAnnotations;

  /// Returns a `const` [List] of fields names.
  List<String> get fieldsNames;

  /// Returns a JSON.
  Object? toJson([O? obj, JsonEncoder? jsonEncoder]);

  /// Returns a JSON [Map].
  Map<String, Object?>? toJsonMap({O? obj, JsonEncoder? jsonEncoder});

  /// Returns a JSON encoded. See [toJson].
  String toJsonEncoded({O? obj, JsonEncoder? jsonEncoder, bool pretty = false});

  /// Returns an object instances from [json].
  O fromJson(Object? json);

  /// Returns an object instances from [jsonEncoded].
  O fromJsonEncoded(String jsonEncoded);
}

/// Base for Enum reflection.
abstract class EnumReflection<O> extends Reflection<O>
    implements Comparable<EnumReflection<O>> {
  final Type enumType;
  final O? object;

  EnumReflection(this.enumType, [this.object]) {
    register();
  }

  @override
  Type get reflectedType => enumType;

  /// Returns `true` if this instances has an associated object ([O]).
  @override
  bool get hasObject => object != null;

  /// Returns a new instances with [obj] as the associated object ([O]).
  @override
  EnumReflection<O> withObject([O? obj]);

  /// Returns a new instances without an [object] instance.
  @override
  EnumReflection<O> withoutObjectInstance() => hasObject ? withObject() : this;

  /// Returns the `staticInstance` of the generated [EnumReflection].
  EnumReflection<O> getStaticInstance();

  /// Returns the Dart language [Version] of the reflected code.
  @override
  Version get languageVersion;

  /// Returns `reflection_factory` [Version] used to generate this reflection code.
  @override
  Version get reflectionFactoryVersion;

  /// Called automatically when instantiated.
  /// Registers this reflection into [ReflectionFactory].
  @override
  void register() {
    if (!ReflectionFactory().hasRegisterEnumReflection(enumType)) {
      var er = withoutObjectInstance();
      ReflectionFactory().registerEnumReflection(er);
    }
  }

  /// Returns the class name.
  String get enumName => enumType.toString();

  @override
  int get reflectionLevel => fieldsNames.length;

  /// Calls [function] with correct casting for [EnumReflection].
  @override
  R callCasted<R>(R Function<O>(EnumReflection<O> enumReflection) function) {
    return function<O>(this);
  }

  /// Returns a [List] of siblings [ClassReflection] (declared in the same code unit).
  List<EnumReflection> siblingsEnumReflection();

  /// Returns a [siblingsEnumReflection] for [type], [obj] or [T].
  EnumReflection<T>? siblingEnumReflectionFor<T>({T? obj, Type? type}) {
    type ??= obj?.runtimeType ?? T;

    var enumReflectionForType =
        siblingsEnumReflection().where((c) => c.enumType == type).firstOrNull;
    return enumReflectionForType as EnumReflection<T>?;
  }

  /// Returns a `const` [List] of class annotations.
  @override
  List<Object> get classAnnotations;

  /// Returns a `const` [List] of fields names.
  @override
  List<String> get fieldsNames;

  /// Returns a `const` [Map] of values by name.
  Map<String, O> get valuesByName;

  /// Returns the Enum values.
  List<O> get values;

  String? name([O? obj]) {
    obj ??= object;

    if (obj == null) {
      return null;
    }

    return getName(obj);
  }

  /// Returns an Enum instance by [o].
  O? from(Object? o) {
    if (o == null) {
      return null;
    } else if (o is O) {
      return o as O;
    }

    var s = o.toString().trim();

    if (s.startsWith('"') || s.startsWith("'")) {
      s = s.substring(1).trim();
    }

    if (s.endsWith('"') || s.endsWith("'")) {
      s = s.substring(0, s.length - 1).trim();
    }

    var obj = valuesByName[s];
    if (obj != null) {
      return obj;
    }

    for (var e in valuesByName.entries) {
      var name = e.key;
      if (equalsIgnoreAsciiCase(name, s)) {
        return e.value;
      }
    }

    return null;
  }

  /// Returns the name of [enumInstance].
  String? getName(O? enumInstance) {
    if (enumInstance == null) {
      return null;
    }

    for (var e in valuesByName.entries) {
      if (e.value == enumInstance) {
        return e.key;
      }
    }

    return null;
  }

  /// Returns the index of [enumInstance].
  int? getIndex(O? enumInstance) {
    if (enumInstance == null) {
      return null;
    }

    for (var e in valuesByName.entries) {
      var value = e.value;
      if (value == enumInstance) {
        return values.indexOf(value);
      }
    }

    return null;
  }

  /// Returns a enum instance as a JSON value.
  @override
  String? toJson([O? obj, JsonEncoder? jsonEncoder]) {
    obj ??= object;
    if (obj == null) {
      return null;
    }

    if (jsonEncoder == null) {
      var name = getName(obj);
      return name;
    } else {
      return jsonEncoder.toJson(obj, autoResetEntityCache: false);
    }
  }

  /// Returns a enum instance as a JSON [Map].
  @override
  Map<String, Object>? toJsonMap({O? obj, JsonEncoder? jsonEncoder}) {
    obj ??= object;
    if (obj == null) return null;

    var name = getName(obj)!;
    var index = getIndex(obj)!;

    return {'name': name, 'index': index};
  }

  /// Returns a JSON encoded. See [toJson].
  @override
  String toJsonEncoded(
      {O? obj, JsonEncoder? jsonEncoder, bool pretty = false}) {
    obj ??= object;

    if (jsonEncoder == null) {
      var name = getName(obj);
      return dart_convert.json.encode(name);
    } else {
      return jsonEncoder.encode(obj, pretty: pretty);
    }
  }

  /// Returns an Enum instance from [json].
  ///
  /// See [from].
  @override
  O fromJson(Object? json) {
    if (json == null) {
      throw StateError("Null JSON for enum: $enumName");
    }

    var o = from(json);
    if (o == null) {
      throw StateError("No enum `$enumName` for JSON: $json");
    }

    return o;
  }

  /// Returns an Enum instance from [jsonEncoded].
  @override
  O fromJsonEncoded(String jsonEncoded) {
    return from(jsonEncoded)!;
  }

  @override
  int compareTo(EnumReflection<O> other) =>
      reflectionLevel.compareTo(other.reflectionLevel);

  @override
  String toString() {
    return 'EnumReflection{ enum: $enumName }${object != null ? '<$object>' : ''}';
  }
}

/// Base for Class reflection.
abstract class ClassReflection<O> extends Reflection<O>
    implements Comparable<ClassReflection<O>> {
  final Type classType;
  final O? object;

  ClassReflection(this.classType, [this.object]) {
    register();
  }

  @override
  Type get reflectedType => classType;

  /// Returns `true` if this instances has an associated object ([O]).
  @override
  bool get hasObject => object != null;

  /// Returns a new instances with [obj] as the associated object ([O]).
  @override
  ClassReflection<O> withObject([O? obj]);

  /// Returns a new instances without an [object] instance.
  @override
  ClassReflection<O> withoutObjectInstance() => hasObject ? withObject() : this;

  /// Returns the `staticInstance` of the generated [ClassReflection].
  ClassReflection<O> getStaticInstance();

  /// Called automatically when instantiated.
  /// Registers this reflection into [ReflectionFactory].
  @override
  void register() {
    if (!ReflectionFactory().hasRegisterClassReflection(classType)) {
      var cr = withoutObjectInstance();
      ReflectionFactory().registerClassReflection(cr);
    }
  }

  /// Returns the Dart language [Version] of the reflected code.
  @override
  Version get languageVersion;

  /// Returns `reflection_factory` [Version] used to generate this reflection code.
  @override
  Version get reflectionFactoryVersion;

  /// Returns the class name.
  String get className => classType.toString();

  @override
  int get reflectionLevel =>
      fieldsNames.length +
      staticFieldsNames.length +
      methodsNames.length +
      staticMethodsNames.length;

  /// Calls [function] with correct casting for [ClassReflection].
  @override
  R callCasted<R>(R Function<O>(ClassReflection<O> classReflection) function) {
    return function<O>(this);
  }

  /// Returns a [List] of siblings [ClassReflection] (declared in the same code unit).
  List<ClassReflection> siblingsClassReflection();

  /// Returns a [siblingsClassReflection] for [type], [obj] or [T].
  ClassReflection<T>? siblingClassReflectionFor<T>({T? obj, Type? type}) {
    type ??= obj?.runtimeType ?? T;

    var classReflectionForType =
        siblingsClassReflection().where((c) => c.classType == type).firstOrNull;
    return classReflectionForType as ClassReflection<T>?;
  }

  /// Returns a `const` [List] of class annotations.
  @override
  List<Object> get classAnnotations;

  /// Returns a list of supper types.
  List<Type> get supperTypes;

  List<FieldReflection<O, dynamic>>? _fieldsWithJsonNameAlias;

  /// Returns a [Map] with the fields names aliases.
  Map<String, String> get fieldsJsonNameAliases =>
      Map<String, String>.fromEntries(
          fieldsWithJsonNameAlias.map((f) => MapEntry(f.name, f.jsonName)));

  /// Returns the fields with a valid [JsonFieldAlias].
  List<FieldReflection<O, dynamic>> get fieldsWithJsonNameAlias =>
      _fieldsWithJsonNameAlias ??=
          List<FieldReflection<O, dynamic>>.unmodifiable(
              allFields().where((f) => f.hasJsonNameAlias));

  bool? _hasJsonNameAlias;

  /// Returns `true` if any field or constructor parameter uses a [JsonFieldAlias].
  bool get hasJsonNameAlias =>
      _hasJsonNameAlias ??= fieldsWithJsonNameAlias.isNotEmpty ||
          allConstructors().any((c) => c.hasJsonNameAlias);

  /// Returns `true` if the class has a default constructor.
  bool get hasDefaultConstructor;

  /// Creates an instance using the default constructor (if present),
  /// other wise returns `null`.
  O? createInstanceWithDefaultConstructor();

  /// Returns `true` if the class has an empty constructor.
  bool get hasEmptyConstructor;

  /// Creates an instance using an empty constructor (if present),
  /// other wise returns `null`.
  ///
  /// An empty constructor is a named constructor that can be called without parameters.
  ///
  /// Will return the first matching constructor in the following order:
  /// - An empty constructor with the names: `empty`, `create` or `def` (in this order).
  /// - First empty constructor with any name.
  O? createInstanceWithEmptyConstructor();

  /// Returns `true` if the class has a constructor without required arguments.
  bool get hasNoRequiredArgsConstructor;

  /// Creates an instance using a constructor without required arguments (if present),
  /// other wise returns `null`.
  O? createInstanceWithNoRequiredArgsConstructor();

  /// Creates an instances calling [createInstanceWithDefaultConstructor] or
  /// [createInstanceWithEmptyConstructor].
  O? createInstance() =>
      createInstanceWithDefaultConstructor() ??
      createInstanceWithEmptyConstructor() ??
      createInstanceWithNoRequiredArgsConstructor();

  /// Returns `true` if [createInstance] can return an instantiated instance
  /// without any constructor argument.
  bool get canCreateInstanceWithoutArguments =>
      hasDefaultConstructor ||
      hasEmptyConstructor ||
      hasNoRequiredArgsConstructor;

  /// Returns a `const` [List] of constructors names.
  List<String> get constructorsNames;

  List<ConstructorReflection<O>>? _allConstructors;

  /// Returns a [List] with all constructors [ConstructorReflection].
  List<ConstructorReflection<O>> allConstructors() =>
      _allConstructors ??= List<ConstructorReflection<O>>.unmodifiable(
          constructorsNames.map((e) => constructor(e)!));

  /// Returns a [ConstructorReflection] for [constructorName].
  ConstructorReflection<O>? constructor<R>(String constructorName);

  /// Returns the best [ConstructorReflection] for [requiredParameters], [optionalParameters],
  /// [nullableParameters] and [presentParameters].
  ConstructorReflection<O>? getBestConstructorFor(
      {Iterable<String> requiredParameters = const <String>[],
      Iterable<String> optionalParameters = const <String>[],
      Iterable<String> nullableParameters = const <String>[],
      Iterable<String> presentParameters = const <String>[],
      bool jsonName = false}) {
    if (nullableParameters is! List && nullableParameters is! Set) {
      nullableParameters = nullableParameters.toList(growable: false);
    }

    var constructors = allConstructors();

    if (constructors.isEmpty) return null;

    var presentParametersResolved = presentParameters.toSet();

    if (requiredParameters.isNotEmpty) {
      var constructorsWithRequired = constructors.where((c) {
        return _elementsInCount<String>(requiredParameters,
                c.resolveAllParametersNames(jsonName), _nameNormalizer) ==
            requiredParameters.length;
      }).toList();

      constructors = constructorsWithRequired;
      if (constructors.isEmpty) return null;

      presentParametersResolved.addAll(requiredParameters);
    }

    if (nullableParameters.isNotEmpty) {
      var constructorsWithNullables = constructors.where((c) {
        var paramsNullable = c
            .parametersNamesWhere((p) => p.nullable || !p.required,
                jsonName: jsonName)
            .toList();
        return _elementsInCount(
                nullableParameters, paramsNullable, _nameNormalizer) ==
            nullableParameters.length;
      }).toList();

      constructors = constructorsWithNullables;
      if (constructors.isEmpty) return null;

      presentParametersResolved.addAll(nullableParameters);
    }

    presentParametersResolved.addAll(optionalParameters);

    constructors = constructors.where((c) {
      var paramsRequired = c
          .parametersNamesWhere((p) => p.required, jsonName: jsonName)
          .toList();
      return _elementsInCount<String>(
              presentParametersResolved, paramsRequired, _nameNormalizer) ==
          paramsRequired.length;
    }).toList();

    if (constructors.isEmpty) return null;

    if (constructors.length == 1) {
      return constructors.first;
    }

    var constructorsInfo = Map.fromEntries(constructors.map((c) {
      var requiredCount =
          c.getParametersByNames(requiredParameters, jsonName: jsonName).length;
      var optionalCount =
          c.getParametersByNames(optionalParameters, jsonName: jsonName).length;
      return MapEntry(c, [requiredCount, optionalCount]);
    }));

    constructors.sort((c1, c2) {
      var i1 = constructorsInfo[c1]!;
      var i2 = constructorsInfo[c2]!;

      var req1 = i1[0];
      var req2 = i2[0];

      var cmp = req2.compareTo(req1);
      if (cmp == 0) {
        var opt1 = i1[1];
        var opt2 = i2[1];
        cmp = opt2.compareTo(opt1);
      }
      return cmp;
    });

    return constructors.first;
  }

  static String _nameNormalizer(String name) {
    var n = name.toLowerCase().trim();
    if (n.startsWith('_')) {
      n = n.substring(1);
    }
    return n;
  }

  static int _elementsInCount<T>(Iterable<T> list, List<T> inList,
          [T Function(T)? normalizer]) =>
      _elementsIn(list, inList, normalizer).length;

  static Iterable<T> _elementsIn<T>(Iterable<T> list, Iterable<T> inList,
      [T Function(T)? normalizer]) {
    if (normalizer != null) {
      inList = inList.map(normalizer).toList();
      return list.map(normalizer).where((e) => inList.contains(e));
    } else {
      return list.where((e) => inList.contains(e));
    }
  }

  /// Returns a `const` [List] of fields names.
  @override
  List<String> get fieldsNames;

  List<FieldReflection<O, dynamic>>? _allFieldsNoObject;

  /// Returns a [List] with all fields [FieldReflection].
  List<FieldReflection<O, dynamic>> allFields([O? obj]) {
    if (obj == null && object == null) {
      _allFieldsNoObject ??= List<FieldReflection<O, dynamic>>.unmodifiable(
          fieldsNames.map((e) => field(e, obj)!));
    }

    return fieldsNames.map((e) => field(e, obj)!).toList();
  }

  bool? _hasFinalField;

  /// Returns `true` if some [field] is final (ignoring `hashCode`).
  bool get hasFinalField => _hasFinalField ??=
      fieldsWhere((f) => f.name != 'hashCode' && f.isFinal).isNotEmpty;

  bool? _hasFieldWithoutSetter;

  /// Returns `true` if some [field] doesn't have a setter (ignoring `hashCode`).
  bool get hasFieldWithoutSetter => _hasFieldWithoutSetter ??=
      fieldsWhere((f) => f.name != 'hashCode' && !f.hasSetter).isNotEmpty;

  /// Returns a `const` [List] of static fields names.
  List<String> get staticFieldsNames;

  List<FieldReflection<O, dynamic>>? _allStaticFields;

  /// Returns a [List] with all static fields [FieldReflection].
  List<FieldReflection<O, dynamic>> allStaticFields() =>
      _allStaticFields ??= List<FieldReflection<O, dynamic>>.unmodifiable(
          staticFieldsNames.map((e) => staticField(e)!));

  /// Returns a [FieldReflection] for [fieldName], with the optional associated [obj].
  FieldReflection<O, T>? field<T>(String fieldName, [O? obj]);

  /// Returns a static [FieldReflection] for [fieldName].
  FieldReflection<O, T>? staticField<T>(String fieldName);

  /// Returns a [List] of fields [FieldReflection] that matches [test].
  Iterable<FieldReflection<O, dynamic>> fieldsWhere(
      bool Function(FieldReflection<O, dynamic> f) test,
      [O? obj]) {
    return allFields(obj).where(test);
  }

  /// Returns a [List] of fields names that matches [test].
  Iterable<String> fieldsNamesWhere(
      bool Function(FieldReflection<O, dynamic> f) test,
      [O? obj,
      bool jsonName = false]) {
    return fieldsWhere(test, obj).map((e) => e.resolveName(jsonName));
  }

  /// Returns a [List] of static fields [FieldReflection] that matches [test].
  Iterable<FieldReflection<O, dynamic>> staticFieldsWhere(
      bool Function(FieldReflection<O, dynamic> f) test) {
    return allStaticFields().where(test);
  }

  /// Returns a [ElementResolver] for a [FieldReflection] for a field with [fieldName].
  ElementResolver<FieldReflection<O, T>> fieldResolver<T>(String fieldName) =>
      ElementResolver<FieldReflection<O, T>>(() => field<T>(fieldName));

  /// Returns a [ElementResolver] for a [FieldReflection] for a static field with [fieldName].
  ElementResolver<FieldReflection<O, T>> staticFieldResolver<T>(
          String fieldName) =>
      ElementResolver<FieldReflection<O, T>>(() => staticField<T>(fieldName));

  /// Returns a `const` [List] of methods names.
  List<String> get methodsNames;

  List<MethodReflection<O, dynamic>>? _allMethodsNoObject;

  /// Returns a [List] with all methods [MethodReflection].
  List<MethodReflection<O, dynamic>> allMethods([O? obj]) {
    if (obj == null && object == null) {
      return _allMethodsNoObject ??=
          List<MethodReflection<O, dynamic>>.unmodifiable(
              methodsNames.map((e) => method(e)!));
    }

    return methodsNames.map((e) => method(e, obj)!).toList();
  }

  /// Returns a `const` [List] of static methods names.
  List<String> get staticMethodsNames;

  List<MethodReflection<O, dynamic>>? _allStaticMethods;

  /// Returns a [List] with all static methods [MethodReflection].
  List<MethodReflection<O, dynamic>> allStaticMethods() =>
      _allStaticMethods ??= List<MethodReflection<O, dynamic>>.unmodifiable(
          staticMethodsNames.map((e) => staticMethod(e)!));

  /// Returns a [MethodReflection] for [methodName], with the optional associated [obj].
  MethodReflection<O, R>? method<R>(String methodName, [O? obj]);

  /// Returns a static [MethodReflection] for [methodName].
  MethodReflection<O, R>? staticMethod<R>(String methodName);

  /// Returns a [List] of methods [MethodReflection] that matches [test].
  Iterable<MethodReflection<O, dynamic>> methodsWhere(
      bool Function(MethodReflection<O, dynamic> f) test,
      [O? obj]) {
    return allMethods(obj).where(test);
  }

  /// Returns a [List] of static methods [MethodReflection] that matches [test].
  Iterable<MethodReflection<O, dynamic>> staticMethodsWhere(
      bool Function(MethodReflection<O, dynamic> f) test) {
    return allStaticMethods().where(test);
  }

  /// Returns a [ElementResolver] for a [MethodReflection] for a method with [methodName].
  ElementResolver<MethodReflection<O, R>> methodResolver<R>(
          String methodName) =>
      ElementResolver<MethodReflection<O, R>>(() => method<R>(methodName));

  /// Returns a [ElementResolver] for a [MethodReflection] for a static method with [methodName].
  ElementResolver<MethodReflection<O, R>> staticMethodResolver<R>(
          String methodName) =>
      ElementResolver<MethodReflection<O, R>>(
          () => staticMethod<R>(methodName));

  /// Returns the field value for [fieldName].
  T? getField<T>(String fieldName, [O? obj]) {
    var field = this.field<T>(fieldName, obj);
    return field?.get();
  }

  /// Sets the field [value] for [fieldName].
  void setField<T>(String fieldName, T value, [O? obj]) {
    var field = this.field<T>(fieldName, obj);
    field?.set(value);
  }

  /// Returns the static field value for [fieldName].
  T? getStaticField<T>(String fieldName) {
    var field = staticField<T>(fieldName);
    return field?.get();
  }

  /// Sets the static field [value] for [fieldName].
  void setStaticField<T>(String fieldName, T value) {
    var field = staticField<T>(fieldName);
    return field?.set(value);
  }

  /// Invokes the method for [methodName].
  R? invokeMethod<R>(String methodName, Iterable<Object?>? positionalArguments,
      [Map<Symbol, Object?>? namedArguments]) {
    var method = this.method(methodName);
    return method?.invoke(positionalArguments, namedArguments);
  }

  /// Invokes the method for [methodName] with the associated [object].
  R? invokeMethodWith<R>(
      String methodName, O object, Iterable<Object?>? positionalArguments,
      [Map<Symbol, Object?>? namedArguments]) {
    var method = this.method(methodName, object);
    return method?.invoke(positionalArguments, namedArguments);
  }

  /// Invokes the static method for [methodName].
  R? invokeStaticMethod<R>(
      String methodName, Iterable<Object?>? positionalArguments,
      [Map<Symbol, Object?>? namedArguments]) {
    var method = staticMethod(methodName);
    return method?.invoke(positionalArguments, namedArguments);
  }

  bool get hasMethodToJson;

  Object? callMethodToJson([O? obj]);

  /// Returns a JSON.
  /// If the class implements `toJson` calls it.
  ///
  /// - If [obj] is not provided, uses [object] as instance.
  @override
  Object? toJson(
      [O? obj,
      JsonEncoder? jsonEncoder,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache]) {
    obj ??= object;
    if (obj == null) return null;

    if (hasMethodToJson) {
      var json = callMethodToJson(obj);

      if (jsonEncoder != null) {
        return jsonEncoder.toJson(json,
            duplicatedEntitiesAsID: duplicatedEntitiesAsID,
            autoResetEntityCache: autoResetEntityCache);
      } else {
        return json;
      }
    }

    return toJsonFromFields(
        obj: obj,
        jsonEncoder: jsonEncoder,
        duplicatedEntitiesAsID: duplicatedEntitiesAsID,
        autoResetEntityCache: autoResetEntityCache);
  }

  /// Returns a JSON [Map].
  /// If the class implements `toJson` calls it.
  ///
  /// - If [obj] is not provided, uses [object] as instance.
  @override
  Map<String, dynamic>? toJsonMap(
      {O? obj,
      JsonEncoder? jsonEncoder,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache}) {
    obj ??= object;
    if (obj == null) return null;

    if (hasMethodToJson) {
      var json = callMethodToJson(obj);

      if (jsonEncoder != null) {
        json = jsonEncoder.toJson(json,
            duplicatedEntitiesAsID: duplicatedEntitiesAsID,
            autoResetEntityCache: autoResetEntityCache);
      }

      if (json is Map) {
        var map = json is Map<String, dynamic>
            ? json
            : json.map((key, value) => MapEntry('$key', value));
        return map;
      }
    }

    return toJsonFromFields(
        obj: obj,
        jsonEncoder: jsonEncoder,
        duplicatedEntitiesAsID: duplicatedEntitiesAsID,
        autoResetEntityCache: autoResetEntityCache);
  }

  /// Returns a JSON [Map] from [fieldsNames], calling [getField] for each one.
  ///
  /// - If [obj] is not provided, uses [object] as instance.
  Map<String, dynamic> toJsonFromFields(
      {O? obj,
      JsonEncoder? jsonEncoder,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache}) {
    obj ??= object;
    if (obj == null) {
      StateError("Null object!");
    }

    var entries = fieldsWhere((f) => f.isEntityField, obj).map((f) {
      var val = f.get();
      var name = f.jsonName;
      return MapEntry(name, val);
    });

    var map = Map<String, dynamic>.fromEntries(entries);

    jsonEncoder ??= JsonEncoder.defaultEncoder;
    return jsonEncoder.toJson(map,
        duplicatedEntitiesAsID: duplicatedEntitiesAsID,
        autoResetEntityCache: autoResetEntityCache);
  }

  /// Returns a JSON encoded. See [toJson].
  @override
  String toJsonEncoded(
      {O? obj,
      JsonEncoder? jsonEncoder,
      bool pretty = false,
      bool duplicatedEntitiesAsID = false}) {
    obj ??= object;

    jsonEncoder ??= JsonEncoder.defaultEncoder;
    return jsonEncoder.encode(obj,
        pretty: pretty, duplicatedEntitiesAsID: duplicatedEntitiesAsID);
  }

  /// Returns a class instance from [json].
  @override
  O fromJson(Object? json,
      {JsonDecoder? jsonDecoder,
      bool duplicatedEntitiesAsID = true,
      bool? autoResetEntityCache}) {
    if (json == null) {
      throw StateError("Null JSON for class: $className");
    }

    if (json is Map) {
      var map = json is Map<String, Object?>
          ? json
          : json.map((k, v) => MapEntry(k.toString(), v));

      jsonDecoder ??= JsonDecoder.defaultDecoder;

      return jsonDecoder.fromJsonMap<O>(map,
          type: classType,
          duplicatedEntitiesAsID: duplicatedEntitiesAsID,
          autoResetEntityCache: autoResetEntityCache);
    } else {
      throw StateError(
          "JSON needs to be a Map to decode a class object: $className");
    }
  }

  /// Returns a class instance from [jsonEncoded].
  @override
  O fromJsonEncoded(String jsonEncoded) {
    return JsonDecoder.defaultDecoder
        .decode<O>(jsonEncoded, type: classType, duplicatedEntitiesAsID: true);
  }

  static String? _defaultFieldNameResolver(
      String field, Map<String, Object?> map) {
    if (map.containsKey(field)) {
      return field;
    }

    String? field2 = field;

    if (field.startsWith('_')) {
      field2 = field.substring(1);
      if (map.containsKey(field2)) {
        return field2;
      }
    }

    for (var k in map.keys) {
      if (equalsIgnoreAsciiCase(k, field2)) {
        return k;
      }
    }

    return null;
  }

  /// Creates an instance with the constructor returned by [getBestConstructorForMap],
  /// using [map] entries.
  O? createInstanceWithBestConstructor(Map<String, Object?> map,
      {FieldNameResolver? fieldNameResolver,
      FieldValueResolver? fieldValueResolver}) {
    var constructor = getBestConstructorForMap(map,
        fieldNameResolver: fieldNameResolver,
        fieldValueResolver: fieldValueResolver);

    if (constructor == null) return null;

    var usesJsonNameAlias = hasJsonNameAlias;

    var methodInvocation = constructor.methodInvocationFromMap(map,
        reviver: fieldValueResolver,
        nameResolver: fieldNameResolver,
        jsonName: usesJsonNameAlias);

    try {
      var o = methodInvocation.invoke(constructor.constructor);
      return o;
    } catch (e) {
      // Tries a second parameter resolution if some value was resolved.
      // This will allow use of the  current cached entities in a `JsonEntityCache`
      // (if used by `fieldValueResolver`).
      var map2 = methodInvocation.parametersToMap();

      if (!DeepCollectionEquality().equals(map, map2)) {
        var methodInvocation2 = constructor.methodInvocationFromMap(map2,
            reviver: fieldValueResolver,
            nameResolver: fieldNameResolver,
            jsonName: usesJsonNameAlias);

        try {
          var o = methodInvocation2.invoke(constructor.constructor);
          return o;
        } catch (e2) {
          _showInvokeError(constructor, methodInvocation2, map2, e2);
          rethrow;
        }
      } else {
        _showInvokeError(constructor, methodInvocation, map, e);
        rethrow;
      }
    }
  }

  void _showInvokeError(
      ConstructorReflection constructor,
      MethodInvocation methodInvocation,
      Map<String, dynamic> map,
      Object? error) {
    print('Error invoking>\n'
        '  - constructor: $constructor\n'
        '  - map: $map\n'
        '  - methodInvocation: $methodInvocation\n'
        '  - error: $error\n');
  }

  Map<_KeyParametersNames, ConstructorReflection<O>?>?
      _getBestConstructorForMapCache;

  /// Returns the best constructor to instantiate with [map] entries.
  ConstructorReflection<O>? getBestConstructorForMap(Map<String, Object?> map,
      {FieldNameResolver? fieldNameResolver,
      FieldValueResolver? fieldValueResolver}) {
    fieldNameResolver ??= _defaultFieldNameResolver;

    var fieldsResolved = _resolveFieldsNames(fieldNameResolver, map);

    var presentFields = fieldsResolved.keys;

    List<String> presentParameters;

    if (map.length > fieldsResolved.length) {
      var mapUsedKeys = fieldsResolved.values.toList();
      var mapUnusedKeys = map.keys.where((k) => !mapUsedKeys.contains(k));

      presentParameters = <String>[...presentFields, ...mapUnusedKeys];
    } else {
      presentParameters = presentFields.toList();
    }

    var key = _KeyParametersNames(presentParameters);

    var cache = getStaticInstance()._getBestConstructorForMapCache ??=
        <_KeyParametersNames, ConstructorReflection<O>?>{};

    var constructor = cache.putIfAbsent(key, () {
      key.sort();

      if (hasJsonNameAlias) {
        return _getBestConstructorForMapImpl(presentParameters, true) ??
            _getBestConstructorForMapImpl(presentParameters, false);
      } else {
        return _getBestConstructorForMapImpl(presentParameters, false);
      }
    });

    return constructor;
  }

  ConstructorReflection<O>? _getBestConstructorForMapImpl(
      List<String> presentParameters, bool jsonName) {
    var fieldsNotPresent = fieldsNamesWhere((f) =>
        f.isEntityField &&
        !presentParameters.contains(f.resolveName(jsonName))).toList();

    var fieldsRequired =
        fieldsNamesWhere((f) => f.isEntityField && !f.hasSetter).toList();

    var fieldsOptional = fieldsNamesWhere((f) =>
        f.isEntityField &&
        !fieldsRequired.contains(f.resolveName(jsonName))).toList();

    var constructor = getBestConstructorFor(
        requiredParameters: fieldsRequired,
        optionalParameters: fieldsOptional,
        nullableParameters: fieldsNotPresent,
        presentParameters: presentParameters,
        jsonName: jsonName);

    if (constructor == null && fieldsRequired.isNotEmpty) {
      constructor = getBestConstructorFor(
          optionalParameters: fieldsOptional,
          nullableParameters: fieldsNotPresent,
          presentParameters: presentParameters,
          jsonName: jsonName);
    }

    if (constructor == null && fieldsNotPresent.isNotEmpty) {
      constructor = getBestConstructorFor(
          optionalParameters: fieldsOptional,
          presentParameters: presentParameters,
          jsonName: jsonName);
    }

    return constructor;
  }

  O? createInstanceFromMap(Map<String, Object?> map,
      {FieldNameResolver? fieldNameResolver,
      FieldValueResolver? fieldValueResolver}) {
    fieldNameResolver ??= _defaultFieldNameResolver;

    if (hasFieldWithoutSetter || !canCreateInstanceWithoutArguments) {
      var o = createInstanceWithBestConstructor(map,
          fieldNameResolver: fieldNameResolver,
          fieldValueResolver: fieldValueResolver);
      if (o != null) return o;
    }

    // `class.field` to `map.key`:
    var fieldsResolved = _resolveFieldsNames(fieldNameResolver, map);

    var fieldsNamesInMap =
        fieldsNames.where((f) => fieldsResolved.containsKey(f)).toList();

    if (!_canSetFieldsInMap(fieldsNamesInMap, fieldsResolved)) {
      var o = createInstanceWithBestConstructor(map,
          fieldNameResolver: fieldNameResolver,
          fieldValueResolver: fieldValueResolver);
      if (o != null) return o;
    }

    var o = createInstance();
    if (o == null) return null;

    for (var f in fieldsNamesInMap) {
      var field = this.field(f, o)!;
      var key = fieldsResolved[f];

      if (key == null) {
        if (!field.isFinal && field.nullable) {
          field.set(null);
        }
        continue;
      }

      var val = map[key];

      if (fieldValueResolver != null) {
        val = fieldValueResolver(key, val, field.type);
      }

      if (val != null) {
        if (field.isFinal) {
          throw StateError(
              "Can't create instance from `Map` due final field `$f`. $key = $val");
        }

        if (field.hasSetter) {
          field.set(val);
        }
      } else if (field.nullable) {
        if (field.hasSetter) {
          field.set(null);
        }
      }
    }

    return o;
  }

  bool _canSetFieldsInMap(
      List<String> fieldsNamesInMap, Map<String, String> fieldsResolved) {
    for (var f in fieldsNamesInMap) {
      var key = fieldsResolved[f];
      if (key == null) continue;

      var field = this.field(f)!;
      if (field.isFinal) {
        return false;
      }
    }
    return true;
  }

  /// Returns a mapping from [fieldsNames] to [map] keys.
  Map<String, String> _resolveFieldsNames(
      FieldNameResolver fieldNameResolver, Map<String, Object?> map) {
    var entries = fieldsNames.map((f) {
      var f2 = fieldNameResolver(f, map);
      return f2 != null ? MapEntry(f, f2) : null;
    }).whereNotNull();
    return Map<String, String>.fromEntries(entries);
  }

  @override
  int compareTo(ClassReflection<O> other) =>
      reflectionLevel.compareTo(other.reflectionLevel);

  @override
  String toString() {
    return 'ClassReflection{ class: $className }${object != null ? '<$object>' : ''}';
  }

  /// Dispose internal caches.
  void disposeCache() {
    var cache = getStaticInstance()._getBestConstructorForMapCache;
    cache?.clear();
  }
}

class _KeyParametersNames {
  final List<String> _fields;

  _KeyParametersNames(this._fields);

  bool _sorted = false;

  void sort() {
    _fields.sort();
    _sorted = true;
  }

  bool equalsFields(_KeyParametersNames other) {
    if (_sorted) {
      return _equalsFieldsImpl(other);
    } else if (other._sorted) {
      return _equalsFieldsImpl(other);
    } else {
      throw StateError('One of the instances should be sorted');
    }
  }

  bool _equalsFieldsImpl(_KeyParametersNames other) {
    var length = _fields.length;

    var otherFields = other._fields;
    if (otherFields.length != length) return false;

    if (other._sorted) {
      var fields = _fields;

      for (var i = 0; i < length; ++i) {
        var o1 = fields[i];
        var o2 = otherFields[i];
        if (o1 != o2) return false;
      }

      return true;
    } else {
      for (var i = 0; i < length; ++i) {
        var o = otherFields[i];
        if (binarySearch(_fields, o) < 0) return false;
      }

      return true;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _KeyParametersNames &&
          runtimeType == other.runtimeType &&
          equalsFields(other);

  @override
  int get hashCode => _fields.length;
}

/// A simple element of type [T] [resolver].
class ElementResolver<T> {
  final T? Function() resolver;

  ElementResolver(this.resolver);

  bool _resolved = false;

  /// Returns `true` if the element is resolved.
  bool get isResolved => _resolved;

  T? _element;

  /// Returns the last resolved element [T].
  T? get() {
    if (!_resolved) {
      _element = resolver();
      _resolved = true;
    }
    return _element;
  }

  /// Resets, clearing resolved element.
  void reset() {
    _resolved = false;
    _element = null;
  }
}

/// Base for element reflection.
abstract class ElementReflection<O> {
  /// The [ClassReflection] of this element.
  final ClassReflection<O> classReflection;

  /// The [Type] that declared this element.
  final Type declaringType;

  /// Returns `true` if this element is static.
  final bool isStatic;

  ElementReflection(this.classReflection, this.declaringType, this.isStatic);

  /// Returns the class name of this element.
  String get className => classReflection.className;
}

final List<Object> _annotationsEmpty = List<Object>.unmodifiable(<Object>[]);

final List<ParameterReflection> _parametersEmpty =
    List<ParameterReflection>.unmodifiable(<ParameterReflection>[]);

final Map<String, ParameterReflection> _namedParametersEmpty =
    Map<String, ParameterReflection>.unmodifiable(
        <String, ParameterReflection>{});

/// A parameter reflection, used method arguments or class fields.
class ParameterReflection {
  /// The [Type] of the parameter.
  final TypeReflection type;

  /// The name of the parameter.
  final String name;

  /// `true` if this parameter can be `null`.
  final bool nullable;

  /// `true` if this parameter is required.
  /// - Normal parameters: `true`.
  /// - Optional parameters: `false`.
  /// - Named parameters: `true` if declared as `required`.
  /// - Fields: `true` if is NOT [nullable].
  final bool required;

  /// The default value of this parameter.
  ///
  /// Only exists for optional and named parameters.
  final Object? defaultValue;

  final List<Object>? _annotations;

  /// The parameter annotations.
  List<Object>? get annotations => _annotations != null
      ? List<Object>.unmodifiable(_annotations!)
      : _annotationsEmpty;

  const ParameterReflection(this.type, this.name, this.nullable, this.required,
      this.defaultValue, this._annotations);

  /// Returns `true` if [defaultValue] is NOT `null`.
  bool get hasDefaultValue => defaultValue != null;

  /// Returns the [JsonAnnotation] of this field/parameter.
  ///
  /// See [JsonField] and [JsonFieldAlias].
  List<JsonAnnotation> get jsonAnnotations =>
      _annotations?.whereType<JsonAnnotation>().toList() ?? <JsonAnnotation>[];

  /// Returns the [JsonFieldAlias] of this field/parameter.
  List<JsonFieldAlias> get jsonFieldAliasAnnotations =>
      jsonAnnotations.whereType<JsonFieldAlias>().toList();

  /// Returns the [JsonFieldAlias] alias name or the declared [name] of this field/parameter.
  String get jsonName => jsonFieldAliasAnnotations.alias ?? name;

  /// Returns `true` if this field/parameter has a [JsonFieldAlias] with a valid name.
  bool get hasJsonNameAlias => jsonFieldAliasAnnotations.alias != null;

  /// Resolves to [name] or to [jsonName].
  String resolveName(bool jsonName) => jsonName ? this.jsonName : name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParameterReflection &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          name == other.name &&
          nullable == other.nullable &&
          required == other.required;

  @override
  int get hashCode =>
      type.hashCode ^ name.hashCode ^ nullable.hashCode ^ required.hashCode;

  @override
  String toString() {
    return 'ParameterReflection{type: $type${nullable ? '?' : ''}, name: $name${required ? ', required' : ''}}';
  }
}

/// Dart [Type] reflection.
class TypeReflection {
  static const TypeReflection tObject = TypeReflection(Object);
  static const TypeReflection tDynamic = TypeReflection(dynamic);
  static final TypeReflection tVoid = TypeReflection.from(TypeInfo.tVoid);
  static const TypeReflection tString = TypeReflection(String);
  static const TypeReflection tDouble = TypeReflection(double);
  static const TypeReflection tInt = TypeReflection(int);
  static const TypeReflection tNum = TypeReflection(num);
  static const TypeReflection tBool = TypeReflection(bool);
  static const TypeReflection tBigInt = TypeReflection(BigInt);
  static const TypeReflection tList = TypeReflection(List);
  static const TypeReflection tMap = TypeReflection(Map);
  static const TypeReflection tSet = TypeReflection(Set);
  static const TypeReflection tFuture = TypeReflection(Future);
  static const TypeReflection tFutureOr = TypeReflection(FutureOr);
  static const TypeReflection tFunction = TypeReflection(Function);

  static const TypeReflection tListObject =
      TypeReflection(List, [TypeReflection.tObject]);
  static const TypeReflection tListDynamic =
      TypeReflection(List, [TypeReflection.tDynamic]);
  static const TypeReflection tListString =
      TypeReflection(List, [TypeReflection.tString]);
  static const TypeReflection tListDouble =
      TypeReflection(List, [TypeReflection.tDouble]);
  static const TypeReflection tListInt =
      TypeReflection(List, [TypeReflection.tInt]);
  static const TypeReflection tListNum =
      TypeReflection(List, [TypeReflection.tNum]);
  static const TypeReflection tListBool =
      TypeReflection(List, [TypeReflection.tBool]);

  static const TypeReflection tMapStringObject =
      TypeReflection(Map, [TypeReflection.tString, TypeReflection.tObject]);
  static const TypeReflection tMapStringDynamic =
      TypeReflection(Map, [TypeReflection.tString, TypeReflection.tDynamic]);
  static const TypeReflection tMapStringString =
      TypeReflection(Map, [TypeReflection.tString, TypeReflection.tString]);
  static const TypeReflection tMapObjectObject =
      TypeReflection(Map, [TypeReflection.tObject, TypeReflection.tObject]);

  static const TypeReflection tSetObject =
      TypeReflection(Set, [TypeReflection.tObject]);
  static const TypeReflection tSetDynamic =
      TypeReflection(Set, [TypeReflection.tDynamic]);
  static const TypeReflection tSetString =
      TypeReflection(Set, [TypeReflection.tString]);
  static const TypeReflection tSetInt =
      TypeReflection(Set, [TypeReflection.tInt]);

  static const TypeReflection tFutureObject =
      TypeReflection(Future, [TypeReflection.tObject]);
  static const TypeReflection tFutureDynamic =
      TypeReflection(Future, [TypeReflection.tDynamic]);
  static const TypeReflection tFutureString =
      TypeReflection(Future, [TypeReflection.tString]);
  static const TypeReflection tFutureBool =
      TypeReflection(Future, [TypeReflection.tBool]);
  static const TypeReflection tFutureInt =
      TypeReflection(Future, [TypeReflection.tInt]);

  static const TypeReflection tFutureOrObject =
      TypeReflection(FutureOr, [TypeReflection.tObject]);
  static const TypeReflection tFutureOrDynamic =
      TypeReflection(FutureOr, [TypeReflection.tDynamic]);
  static const TypeReflection tFutureOrString =
      TypeReflection(FutureOr, [TypeReflection.tString]);
  static const TypeReflection tFutureOrBool =
      TypeReflection(FutureOr, [TypeReflection.tBool]);
  static const TypeReflection tFutureOrInt =
      TypeReflection(FutureOr, [TypeReflection.tInt]);

  static String? getConstantName(String typeName,
      [List<String> args = const <String>[]]) {
    switch (typeName) {
      case 'Object':
        return 'tObject';
      case 'dynamic':
        return 'tDynamic';
      case 'String':
        return 'tString';
      case 'double':
        return 'tDouble';
      case 'int':
        return 'tInt';
      case 'num':
        return 'tNum';
      case 'BigInt':
        return 'tBigInt';
      case 'bool':
        return 'tBool';
      case 'List':
        {
          if (args.length != 1) {
            return 'tList';
          }
          switch (args[0]) {
            case 'Object':
              return 'tListObject';
            case 'dynamic':
              return 'tListDynamic';
            case 'String':
              return 'tListString';
            case 'double':
              return 'tListDouble';
            case 'int':
              return 'tListInt';
            case 'num':
              return 'tListNum';
            case 'bool':
              return 'tListBool';
            default:
              return null;
          }
        }
      case 'Map':
        {
          if (args.length != 2) {
            return 'tMap';
          }

          var a = '${args[0]};${args[1]}';

          switch (a) {
            case 'Object;Object':
              return 'tMapObjectObject';
            case 'String;String':
              return 'tMapStringString';
            case 'String;dynamic':
              return 'tMapStringDynamic';
            case 'String;Object':
              return 'tMapStringObject';
            default:
              return null;
          }
        }
      case 'Set':
        {
          {
            if (args.length != 1) {
              return 'tSet';
            }
            switch (args[0]) {
              case 'Object':
                return 'tSetObject';
              case 'dynamic':
                return 'tSetDynamic';
              case 'String':
                return 'tSetString';
              case 'int':
                return 'tSetInt';
              default:
                return null;
            }
          }
        }
      case 'Future':
        {
          {
            if (args.length != 1) {
              return 'tFuture';
            }
            switch (args[0]) {
              case 'Object':
                return 'tFutureObject';
              case 'dynamic':
                return 'tFutureDynamic';
              case 'String':
                return 'tFutureString';
              case 'int':
                return 'tFutureInt';
              case 'bool':
                return 'tFutureBool';
              default:
                return null;
            }
          }
        }
      case 'FutureOr':
        {
          {
            if (args.length != 1) {
              return 'tFutureOr';
            }
            switch (args[0]) {
              case 'Object':
                return 'tFutureOrObject';
              case 'dynamic':
                return 'tFutureOrDynamic';
              case 'String':
                return 'tFutureOrString';
              case 'int':
                return 'tFutureOrInt';
              case 'bool':
                return 'tFutureOrBool';
              default:
                return null;
            }
          }
        }
      case 'Function':
        return 'tFunction';
      default:
        return null;
    }
  }

  static List<TypeReflection> toList(Iterable<Object> list,
      {bool growable = false}) {
    return list.map((e) => TypeReflection.from(e)).toList(growable: growable);
  }

  /// The Dart [Type].
  final Type type;

  /// Returns the [type] name.
  String get typeName {
    if (hasArguments && type == dynamic) {
      return 'FutureOr';
    }

    var typeStr = type.toString();
    var idx = typeStr.indexOf('<');
    if (idx > 0) typeStr = typeStr.substring(0, idx);
    return typeStr;
  }

  /// Returns `true` if the parameter [type] is equals to field [type].
  ///
  /// - If [arguments] is provided, also checks [equalsArgumentsTypes].
  bool isOfType(Type type, [List<Type>? arguments]) {
    return typeInfo.isOf(type, arguments);
  }

  /// The [Type] arguments.
  ///
  /// Example: `Map<String, int>` will return `[String, int]`.
  final List<Object>? _arguments;

  // Internal [TypeInfo] to avoid unnecessary instantiation.
  final TypeInfo? _typeInfo;

  const TypeReflection(this.type, [this._arguments]) : _typeInfo = null;

  const TypeReflection._(this.type, [this._arguments, this._typeInfo]);

  factory TypeReflection.from(Object o) {
    if (o is TypeReflection) {
      return o;
    } else if (o is Type) {
      return TypeReflection._(o, null, TypeInfo.from(o));
    } else if (o is TypeInfo) {
      return TypeReflection._(o.type, toList(o.arguments), o);
    } else if (o is List<Type>) {
      var t = o[0];
      if (o.length > 1) {
        var args = o.sublist(1).map((e) => TypeReflection.from(e)).toList();
        return TypeReflection._(t, args, TypeInfo.from(t, args));
      } else {
        return TypeReflection._(t, null, TypeInfo.from(t));
      }
    } else {
      throw ArgumentError("Invalid type: $o");
    }
  }

  static final Expando<TypeInfo> _typeReflectionToTypeInfo =
      Expando('TypeReflection_to_TypeInfo');

  static TypeInfo _toTypeInfo(TypeReflection typeReflection) {
    var typeInfo = _typeReflectionToTypeInfo[typeReflection];
    if (typeInfo == null) {
      typeInfo = TypeInfo.from(typeReflection, typeReflection._arguments);
      _typeReflectionToTypeInfo[typeReflection] = typeInfo;
    }
    return typeInfo;
  }

  /// Returns a [TypeInfo] of this instance.
  TypeInfo get typeInfo => _typeInfo ?? _toTypeInfo(this);

  /// Returns the [arguments] length.
  int get argumentsLength {
    var arguments = _arguments;
    return arguments != null ? arguments.length : 0;
  }

  /// Returns the arguments of this type.
  List<TypeReflection> get arguments {
    var arguments = _arguments;
    return arguments == null
        ? <TypeReflection>[]
        : arguments
            .map((e) => e is TypeReflection ? e : TypeReflection.from(e))
            .toList();
  }

  /// Returns `true` if this type has [arguments].
  bool get hasArguments => _arguments != null && _arguments!.isNotEmpty;

  /// Returns `true` if [arguments] have equals [types].
  bool equalsArgumentsTypes(List<Type> types) {
    if (!hasArguments) {
      return types.isEmpty;
    }

    return typeInfo.equalsArgumentsTypes(types);
  }

  /// Returns `true` if [type] is `String`, `int`, `double`, `num` or `bool`.
  bool get isPrimitiveType =>
      isStringType || isIntType || isDoubleType || isNumType || isBoolType;

  /// Returns `true` if [type] is a collection ([List], [Iterable], [Map] or [Set]).
  bool get isCollectionType => typeInfo.isCollection;

  /// Returns `true` if [type] is `Map`.
  bool get isMapType => typeInfo.isMap;

  /// Returns `true` if [type] is `Iterable`.
  bool get isIterableType => typeInfo.isIterable;

  /// Returns `true` if [type] is `int`.
  bool get isIntType => type == int;

  /// Returns `true` if [type] is `double`.
  bool get isDoubleType => type == double;

  /// Returns `true` if [type] is `num`.
  bool get isNumType => type == num;

  /// Returns `true` if [type] is [BigInt].
  bool get isBigInt => type == BigInt;

  /// Returns `true` if [type] is `int`, `double` or `num`.
  bool get isNumberType => isIntType || isDoubleType || isNumType;

  /// Returns `true` if [type] is `int`, `double`, `num` or [BigInt].
  /// See [isNumberType] and [isBigInt]
  bool get isNumericType => isNumberType || isBigInt;

  /// Returns `true` if [type] is `bool`.
  bool get isBoolType => type == bool;

  /// Returns `true` if [type] is `String`.
  bool get isStringType => type == String;

  /// Returns `true` if [type] is `Object`.
  bool get isObjectType => type == Object;

  /// Returns `true` if [type] is `dynamic`.
  bool get isDynamicType => type == dynamic;

  /// Returns `true` if [type] is `Object` or `dynamic`.
  bool get isObjectOrDynamicType => isObjectType || isDynamicType;

  /// Returns `true` if [type] is a [List].
  bool get isListType => typeInfo.isList;

  /// Returns `true` if [type] is a [Set].
  bool get isSetType => typeInfo.isSet;

  /// Returns `true` if [type] [isPrimitiveType] or [isCollection].
  bool get isBasicType => isPrimitiveType || isCollectionType;

  /// Returns `true` if [type] can be an entity (![isBasicType]).
  bool get isEntityType => !isBasicType;

  /// Returns `true` if [type] is a [List] of entities.
  bool get isListEntity =>
      isListType && hasArguments && arguments.first.isEntityType;

  /// Returns `true` if [type] [isIterableType] of entities.
  bool get isIterableEntity =>
      isIterableType && hasArguments && arguments.first.isEntityType;

  /// The [TypeReflection] of the [List] elements type.
  TypeReflection? get listEntityType => isIterableType ? arguments.first : null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TypeReflection &&
          runtimeType == other.runtimeType &&
          typeInfo == other.typeInfo;

  @override
  int get hashCode =>
      type.hashCode ^ _listEqualityTypeReflection.hash(arguments);

  @override
  String toString() {
    return hasArguments ? '$typeName<${arguments.join(',')}>' : typeName;
  }
}

typedef FieldGetter<T> = T Function();
typedef FieldSetter<T> = void Function(T? v);

typedef FieldReflectionGetterAccessor<O, T> = FieldGetter<T> Function(O? obj);
typedef FieldReflectionSetterAccessor<O, T> = FieldSetter<T> Function(O? obj);

typedef FieldNameResolver = String? Function(
    String field, Map<String, Object?> map);

typedef FieldValueResolver = Object? Function(
    String field, Object? value, TypeReflection type);

/// A class field reflection.
class FieldReflection<O, T> extends ElementReflection<O>
    implements ParameterReflection {
  /// Returns [Type] of this field.
  @override
  final TypeReflection type;

  /// Returns name of this field.
  @override
  final String name;

  /// Returns `true` if this field is nullable.
  @override
  final bool nullable;

  /// Returns `true` if this field is NOT [nullable].
  @override
  bool get required => !nullable;

  /// The default value of the field.
  ///
  /// ** Not implemented for fields: always `null`.
  @override
  Object? get defaultValue => null;

  /// Returns `true` if [defaultValue] is NOT `null`.
  ///
  /// ** Not implemented for fields: always `false`.
  @override
  bool get hasDefaultValue => false;

  /// A [Function] that returns the field getter.
  final FieldReflectionGetterAccessor<O, T> getterAccessor;

  /// A [Function] that returns the field setter.
  final FieldReflectionSetterAccessor<O, T>? setterAccessor;

  /// Returns the associated object ([O]) of this field.
  /// Returns `null` for static fields.
  final O? object;

  /// Returns `true` if this field is final.
  final bool isFinal;

  @override
  final List<Object> _annotations;

  /// The field annotations.
  @override
  List<Object> get annotations => _annotations;

  /// Returns the [JsonField] of this field.
  List<JsonField> get jsonFieldAnnotations =>
      _annotations.whereType<JsonField>().toList();

  /// Returns the [JsonAnnotation] of this field.
  ///
  /// See [JsonField] and [JsonFieldAlias].
  @override
  List<JsonAnnotation> get jsonAnnotations =>
      _annotations.whereType<JsonAnnotation>().toList();

  /// Returns the [JsonFieldAlias] of this field.
  @override
  List<JsonFieldAlias> get jsonFieldAliasAnnotations =>
      jsonAnnotations.whereType<JsonFieldAlias>().toList();

  FieldReflection(
    ClassReflection<O> classReflection,
    Type declaringType,
    this.type,
    this.name,
    this.nullable,
    this.getterAccessor,
    this.setterAccessor,
    this.object,
    bool isStatic,
    this.isFinal,
    List<Object>? annotations,
  )   : _annotations = annotations == null || annotations.isEmpty
            ? _annotationsEmpty
            : List<Object>.unmodifiable(annotations),
        super(classReflection, declaringType, isStatic);

  FieldReflection._(
    ClassReflection<O> classReflection,
    Type declaringType,
    this.type,
    this.name,
    this.nullable,
    this.getterAccessor,
    this.setterAccessor,
    this.object,
    bool isStatic,
    this.isFinal,
    this._annotations,
  ) : super(classReflection, declaringType, isStatic);

  /// Returns a new instance that references [object].
  FieldReflection<O, T> withObject(O object) {
    return FieldReflection<O, T>._(
        classReflection,
        declaringType,
        type,
        name,
        nullable,
        getterAccessor,
        setterAccessor,
        object,
        isStatic,
        isFinal,
        _annotations);
  }

  String? _jsonName;

  @override
  String get jsonName => _jsonName ??= jsonFieldAliasAnnotations.alias ?? name;

  bool? _hasJsonNameAlias;

  @override
  bool get hasJsonNameAlias =>
      _hasJsonNameAlias ??= jsonFieldAliasAnnotations.alias != null;

  @override
  String resolveName(bool jsonName) => jsonName ? this.jsonName : name;

  FieldGetter<T>? _getter;

  /// Returns this field value.
  T get() {
    var getter = _getter ??= getterAccessor(object);
    return getter();
  }

  FieldSetter<T>? _setter;

  bool get hasSetter => _setter != null || setterAccessor != null;

  /// Sets this field value.
  void set(T? v) {
    var setter = _setter;
    if (setter == null && setterAccessor != null) {
      setter = _setter = setterAccessor!(object);
    }

    if (setter != null) {
      setter(v);
    } else {
      if (isFinal) {
        throw StateError('Final field: $className.$name');
      } else {
        throw StateError('Field without setter: $className.$name');
      }
    }
  }

  /// Returns `true` if this [Field] can be an entity field.
  /// Usually an entity field can be used in a `JSON`, `toJson` and `fromJson`.
  bool get isEntityField {
    var ok = hasSetter || isFinal || type.isCollectionType;

    if (ok) {
      return !isJsonFieldHidden;
    } else {
      return isJsonFieldVisible;
    }
  }

  /// Returns `true` if this field has a [JsonField] annotation with [JsonField.isVisible].
  bool get isJsonFieldVisible {
    for (var a in jsonFieldAnnotations) {
      if (a.isVisible) {
        return true;
      }
    }
    return false;
  }

  /// Returns `true` if this field has a [JsonField] annotation with [JsonField.isHidden].
  bool get isJsonFieldHidden {
    for (var a in jsonFieldAnnotations) {
      if (a.isHidden) {
        return true;
      }
    }
    return false;
  }

  @override
  String toString() {
    return 'FieldReflection{ class: $className, name: $name, type: ${nullable ? '$type?' : '$type'}, static: $isStatic, final: $isFinal }${object != null ? '<$object>' : ''}';
  }
}

final Object absentParameterValue = _AbsentParameterValue();

class _AbsentParameterValue {
  const _AbsentParameterValue();

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => 0;
}

/// Base class fro methods and constructors.
abstract class FunctionReflection<O, R> extends ElementReflection<O>
    implements Comparable<FunctionReflection> {
  /// The name of this method.
  final String name;

  /// The return [Type] of this method. Returns `null` for void type.
  final TypeReflection? returnType;

  /// `true` if the returned value of this method can be `null`.
  final bool returnNullable;

  /// The normal parameters [Type]s of this method.
  final List<ParameterReflection> normalParameters;

  /// The optional parameters [Type]s of this method.
  final List<ParameterReflection> optionalParameters;

  /// The named parameters [Type]s of this method.
  final Map<String, ParameterReflection> namedParameters;

  List<ParameterReflection>? _allParameters;

  /// Returns all the parameters: [normalParameters], [optionalParameters], [namedParameters].
  List<ParameterReflection> get allParameters =>
      _allParameters ??= List<ParameterReflection>.unmodifiable([
        ...normalParameters,
        ...optionalParameters,
        ...namedParameters.values
      ]);

  List<String>? _allParametersNames;

  /// Returns [allParameters] names.
  List<String> get allParametersNames => _allParametersNames ??=
      List<String>.unmodifiable(allParameters.map((e) => e.name));

  List<String>? _allJsonParametersNames;

  /// Returns [allParameters] names.
  List<String> get allJsonParametersNames => _allJsonParametersNames ??=
      List<String>.unmodifiable(allParameters.map((e) => e.jsonName));

  List<String> resolveAllParametersNames(bool jsonName) =>
      jsonName ? allJsonParametersNames : allParametersNames;

  bool? _hasJsonNameAlias;

  /// Returns `true` if any field or constructor parameter uses a [JsonFieldAlias].
  bool get hasJsonNameAlias =>
      _hasJsonNameAlias ??= allParameters.any((p) => p.hasJsonNameAlias);

  /// The method annotations.
  List<Object> annotations;

  /// The Dart function for the method or constructor.
  Function get _function;

  FunctionReflection(
    ClassReflection<O> classReflection,
    Type declaringType,
    this.name,
    this.returnType,
    this.returnNullable,
    bool isStatic,
    List<ParameterReflection>? normalParameters,
    List<ParameterReflection>? optionalParameters,
    Map<String, ParameterReflection>? namedParameters,
    List<Object>? annotations,
  )   : normalParameters = normalParameters == null || normalParameters.isEmpty
            ? _parametersEmpty
            : List<ParameterReflection>.unmodifiable(normalParameters),
        optionalParameters =
            optionalParameters == null || optionalParameters.isEmpty
                ? _parametersEmpty
                : List<ParameterReflection>.unmodifiable(optionalParameters),
        namedParameters = namedParameters == null || namedParameters.isEmpty
            ? _namedParametersEmpty
            : Map<String, ParameterReflection>.unmodifiable(namedParameters),
        annotations = annotations == null || annotations.isEmpty
            ? _annotationsEmpty
            : List<Object>.unmodifiable(annotations),
        super(classReflection, declaringType, isStatic);

  FunctionReflection._(
    ClassReflection<O> classReflection,
    Type declaringType,
    this.name,
    this.returnType,
    this.returnNullable,
    bool isStatic,
    this.normalParameters,
    this.optionalParameters,
    this.namedParameters,
    this.annotations,
  ) : super(classReflection, declaringType, isStatic);

  /// Returns the amount of parameters.
  int get parametersLength =>
      normalParameters.length +
      optionalParameters.length +
      namedParameters.length;

  /// Returns the amount of positional parameters ([normalParameters] + [optionalParameters]).
  int get positionalParametersLength =>
      normalParameters.length + optionalParameters.length;

  /// Returns `true` if this methods has no arguments/parameters.
  bool get hasNoParameters =>
      normalParameters.isEmpty &&
      optionalParameters.isEmpty &&
      namedParameters.isEmpty;

  /// Returns the amount of required parameters.
  int get requiredParametersLength =>
      normalParameters.length +
      namedParameters.values.where((p) => p.required).length;

  List<TypeReflection>? _normalParametersTypeReflection;

  /// Returns the [normalParameters] [TypeReflection]s.
  List<TypeReflection> get normalParametersTypeReflection =>
      _normalParametersTypeReflection ??= List<TypeReflection>.unmodifiable(
          normalParameters.map((e) => e.type));

  List<Type>? _normalParametersTypes;

  /// Returns the [normalParameters] [Type]s.
  List<Type> get normalParametersTypes => _normalParametersTypes ??=
      List<Type>.unmodifiable(normalParameters.map((e) => e.type.type));

  List<String>? _normalParametersNames;

  /// Returns the [normalParameters] names.
  List<String> get normalParametersNames => _normalParametersNames ??=
      List<String>.unmodifiable(normalParameters.map((e) => e.name));

  List<TypeReflection>? _optionalParametersTypeReflection;

  /// Returns the [optionalParameters] [TypeReflection]s.
  List<TypeReflection> get optionalParametersTypeReflection =>
      _optionalParametersTypeReflection ??= List<TypeReflection>.unmodifiable(
          optionalParameters.map((e) => e.type));

  List<Type>? _optionalParametersTypes;

  /// Returns the [optionalParameters] [Type]s.
  List<Type> get optionalParametersTypes => _optionalParametersTypes ??=
      List<Type>.unmodifiable(optionalParameters.map((e) => e.type.type));

  List<String>? _optionalParametersNames;

  /// Returns the [optionalParameters] names.
  List<String> get optionalParametersNames => _optionalParametersNames ??=
      List<String>.unmodifiable(optionalParameters.map((e) => e.name));

  /// Returns the [namedParameters] [TypeReflection]s.
  Map<String, TypeReflection> get namedParametersTypeReflection =>
      namedParameters.map((k, v) => MapEntry(k, v.type));

  /// Returns the [namedParameters] [Type]s.
  Map<String, Type> get namedParametersTypes =>
      namedParameters.map((k, v) => MapEntry(k, v.type.type));

  List<String>? _namedParametersNames;

  /// Returns the [namedParameters] names.
  List<String> get namedParametersNames => _namedParametersNames ??=
      List<String>.unmodifiable(namedParameters.keys.toList());

  /// Returns a [List] of [ParameterReflection] that matches [test].
  Iterable<ParameterReflection> parametersWhere(
          bool Function(ParameterReflection parameter) test) =>
      allParameters.where(test);

  /// Returns a [List] of parameters names that matches [test].
  Iterable<String> parametersNamesWhere(
          bool Function(ParameterReflection parameter) test,
          {bool jsonName = false}) =>
      allParameters.where(test).map((e) => e.resolveName(jsonName));

  /// Returns a [ParameterReflection] by [name].
  ParameterReflection? getParameterByName(String name,
      {bool jsonName = false}) {
    for (var p in normalParameters) {
      if (p.resolveName(jsonName) == name) return p;
    }

    for (var p in optionalParameters) {
      if (p.resolveName(jsonName) == name) return p;
    }

    for (var p in namedParameters.values) {
      if (p.resolveName(jsonName) == name) return p;
    }

    return null;
  }

  /// Returns [allParameters] in [names] list.
  List<ParameterReflection> getParametersByNames(Iterable<String> names,
          {bool jsonName = false}) =>
      allParameters
          .where((p) => names.contains(p.resolveName(jsonName)))
          .toList();

  /// Returns a [ParameterReflection] by [index].
  ParameterReflection? getParameterByIndex(int index) {
    if (index < normalParameters.length) {
      return normalParameters[index];
    }

    var offset = normalParameters.length;

    if (index < offset + optionalParameters.length) {
      return optionalParameters[index - offset];
    }

    if (index < offset + namedParameters.length) {
      return namedParameters.values.elementAt(index - offset);
    }

    return null;
  }

  /// Returns `true` if [parameters] is equals to [normalParameters].
  bool equalsNormalParametersTypes(List<Type> parameters,
          {bool equivalency = false}) =>
      equivalency
          ? TypeInfo.equivalentTypeList(normalParametersTypes, parameters)
          : TypeInfo.equalsTypeList(normalParametersTypes, parameters);

  /// Returns `true` if [parameters] is equals to [optionalParameters].
  bool equalsOptionalParametersTypes(List<Type> parameters,
          {bool equivalency = false}) =>
      equivalency
          ? TypeInfo.equivalentTypeList(optionalParametersTypes, parameters)
          : TypeInfo.equalsTypeList(optionalParametersTypes, parameters);

  /// Returns `true` if [parameters] is equals to [namedParameters].
  bool equalsNamedParametersTypes(Map<String, Type> parameters,
          {bool equivalency = false}) =>
      equivalency
          ? _mapEquivalencyType.equals(namedParametersTypes, parameters)
          : _mapEqualityType.equals(namedParametersTypes, parameters);

  /// Creates a [MethodInvocation] using [map] entries as parameters.
  MethodInvocation<O> methodInvocationFromMap(Map<String, dynamic> map,
      {FieldValueResolver? reviver,
      FieldNameResolver? nameResolver,
      bool jsonName = false}) {
    if (jsonName) {
      var fieldsAliases = classReflection.fieldsJsonNameAliases;
      var fieldsAliasesReverse =
          fieldsAliases.map((key, value) => MapEntry(value, key));

      return methodInvocation((p) {
        var pJsonName = p.jsonName;
        var pName = p.name;
        var fAlias1 = fieldsAliases[pName];
        var fAlias2 = fieldsAliasesReverse[pName];

        if (nameResolver != null) {
          pJsonName = nameResolver(pJsonName, map) ?? pJsonName;
          pName = nameResolver(pName, map) ?? pName;
        }

        var contains = false;
        Object? val;

        if (map.containsKey(pJsonName)) {
          val = map[pJsonName];
          contains = true;
        } else if (map.containsKey(pName)) {
          val = map[pName];
          contains = true;
        } else if (fAlias1 != null && map.containsKey(fAlias1)) {
          val = map[fAlias1];
          contains = true;
        } else if (fAlias2 != null && map.containsKey(fAlias2)) {
          val = map[fAlias2];
          contains = true;
        }

        if (reviver != null) {
          val = reviver(pName, val, p.type);
        }

        if (val != null) return val;
        return contains ? null : absentParameterValue;
      });
    } else {
      return methodInvocation((p) {
        var pName = p.name;

        if (nameResolver != null) {
          pName = nameResolver(pName, map) ?? pName;
        }

        var contains = false;
        Object? val;

        if (map.containsKey(pName)) {
          val = map[pName];
          contains = true;
        }

        if (reviver != null) {
          val = reviver(pName, val, p.type);
        }

        if (val != null) return val;
        return contains ? null : absentParameterValue;
      });
    }
  }

  /// Creates a [MethodInvocation] using [parametersProvider].
  MethodInvocation<O> methodInvocation(
      Object? Function(ParameterReflection parameter) parametersProvider) {
    var normalParameters = this
        .normalParameters
        .map((p) => MapEntry<String, Object?>(p.name, parametersProvider(p)))
        .toList();

    var optionalParameters = this
        .optionalParameters
        .map((p) => MapEntry<String, Object?>(p.name, parametersProvider(p)))
        .toList();

    while (optionalParameters.isNotEmpty) {
      var lastIndex = optionalParameters.length - 1;

      var entry = optionalParameters[lastIndex];
      var value = entry.value;
      var isAbsent = absentParameterValue == value;
      if (value != null && !isAbsent) break;

      var lastParam = this.optionalParameters[lastIndex];

      if (isAbsent) {
        optionalParameters.removeAt(lastIndex);
      } else {
        if (lastParam.hasDefaultValue || lastParam.nullable) {
          optionalParameters.removeAt(lastIndex);
        } else {
          throw StateError(
              "Invalid optional parameter value: $optionalParameters != ${this.optionalParameters}");
        }
      }
    }

    _removeAbsentParameterValue(normalParameters);
    _removeAbsentParameterValue(optionalParameters);

    var namedParameters =
        Map<String, dynamic>.fromEntries(this.namedParameters.entries.map((e) {
      var p = e.value;

      var value = parametersProvider(p);

      var isAbsent = absentParameterValue == value;

      if ((value == null || isAbsent) &&
          (p.nullable || p.hasDefaultValue) &&
          !p.required) {
        return null;
      } else {
        if (isAbsent) {
          throw StateError("Required named parameter `${p.name}` "
              "${p.hasJsonNameAlias ? '(jsonName: p.jsonName)' : ''} "
              "for `MethodInvocation[${classReflection.classType}.$name]`: $p");
        }
        return MapEntry(e.key, value);
      }
    }).whereType<MapEntry<String, dynamic>>());

    var normalParametersValues = normalParameters.map((e) => e.value).toList();
    var optionalParametersValues =
        optionalParameters.map((e) => e.value).toList();

    var positionalParametersNames = <String>[
      ...normalParameters.map((e) => e.key),
      ...optionalParameters.map((e) => e.key),
    ];

    return MethodInvocation<O>.withPositionalParametersNames(
      classReflection.classType,
      name,
      positionalParametersNames,
      normalParametersValues,
      optionalParametersValues,
      namedParameters,
    );
  }

  void _removeAbsentParameterValue(List<MapEntry<String, Object?>> parameters) {
    for (var i = parameters.length - 1; i >= 0; --i) {
      var entry = parameters[i];
      var value = entry.value;
      var isAbsent = absentParameterValue == value;
      if (isAbsent) {
        parameters[i] = MapEntry<String, Object?>(entry.key, null);
      }
    }
  }

  /// Invoke this method.
  R invoke(Iterable<Object?>? positionalArguments,
      [Map<Symbol, Object?>? namedArguments]) {
    try {
      return Function.apply(
          _function, positionalArguments?.toList(), namedArguments);
    } catch (_) {
      print('Error invoking:\n'
          '  - FunctionReflection: $this\n'
          '  - _function: $_function\n'
          '  - positionalArguments: $positionalArguments\n'
          '  - namedArguments: $namedArguments\n');
      rethrow;
    }
  }

  @override
  int compareTo(FunctionReflection other) {
    var cmp = normalParameters.length.compareTo(other.normalParameters.length);
    if (cmp == 0) {
      cmp =
          optionalParameters.length.compareTo(other.optionalParameters.length);
      if (cmp == 0) {
        cmp = namedParameters.length.compareTo(other.namedParameters.length);
      }
    }
    return cmp;
  }
}

typedef ConstructorReflectionAccessor = Function Function();

class ConstructorReflection<O> extends FunctionReflection<O, O> {
  final ConstructorReflectionAccessor constructorAccessor;

  ConstructorReflection(
      ClassReflection<O> classReflection,
      Type declaringType,
      String name,
      this.constructorAccessor,
      List<ParameterReflection>? normalParameters,
      List<ParameterReflection>? optionalParameters,
      Map<String, ParameterReflection>? namedParameters,
      List<Object>? annotations,
      {Type? type})
      : super(
            classReflection,
            declaringType,
            name,
            TypeReflection(type ?? O),
            false,
            true,
            normalParameters,
            optionalParameters,
            namedParameters,
            annotations);

  Function? _constructor;

  Function get constructor => _constructor ??= constructorAccessor();

  @override
  Function get _function => constructor;

  bool get isNamed => name.isNotEmpty;

  bool get isDefaultConstructor => name.isEmpty && hasNoParameters;

  @override
  String toString() {
    return 'ConstructorReflection{ '
        'class: $className, '
        'name: $name, '
        'normalParameters: $normalParameters, '
        'optionalParameters: $optionalParameters, '
        'namedParameters: $namedParameters '
        '}';
  }
}

typedef MethodReflectionAccessor<O> = Function Function(O? obj);

/// A class method reflection.
class MethodReflection<O, R> extends FunctionReflection<O, R> {
  final MethodReflectionAccessor<O> methodAccessor;

  /// The associated object ([O]) of this method.
  /// `null` for static methods.
  final O? object;

  MethodReflection(
    ClassReflection<O> classReflection,
    Type declaringType,
    String name,
    TypeReflection? returnType,
    bool returnNullable,
    this.methodAccessor,
    this.object,
    bool isStatic,
    List<ParameterReflection>? normalParameters,
    List<ParameterReflection>? optionalParameters,
    Map<String, ParameterReflection>? namedParameters,
    List<Object>? annotations,
  ) : super(
            classReflection,
            declaringType,
            name,
            returnType,
            returnNullable,
            isStatic,
            normalParameters,
            optionalParameters,
            namedParameters,
            annotations);

  MethodReflection._(
    ClassReflection<O> classReflection,
    Type declaringType,
    String name,
    TypeReflection? returnType,
    bool returnNullable,
    this.methodAccessor,
    this.object,
    bool isStatic,
    List<ParameterReflection> normalParameters,
    List<ParameterReflection> optionalParameters,
    Map<String, ParameterReflection> namedParameters,
    List<Object> annotations,
  ) : super._(
            classReflection,
            declaringType,
            name,
            returnType,
            returnNullable,
            isStatic,
            normalParameters,
            optionalParameters,
            namedParameters,
            annotations);

  /// Returns a new instance that references [object].
  MethodReflection<O, R> withObject(O object) => MethodReflection._(
      classReflection,
      declaringType,
      name,
      returnType,
      returnNullable,
      methodAccessor,
      object,
      isStatic,
      normalParameters,
      optionalParameters,
      namedParameters,
      annotations);

  Function? _method;

  Function get method => _method ??= methodAccessor(object);

  @override
  Function get _function => method;

  @override
  String toString() =>
      'MethodReflection{ class: $className, name: $name, returnType: ${returnNullable ? '$returnType?' : '$returnType'}, static: $isStatic, normalParameters: $normalParameters, optionalParameters: $optionalParameters, namedParameters: $namedParameters }${object != null ? '<$object>' : ''}';
}

/// Represents a method invocation parameters.
class MethodInvocation<T> {
  /// The class [Type] of this invocation parameters.
  final Type classType;

  /// The method name of this invocation parameters.
  final String methodName;

  /// The normal positional parameters of the related method.
  final List normalParameters;

  /// The optional positional parameters of the related method.
  final List? optionalParameters;

  /// The named parameters of the related method.
  final Map<String, dynamic>? namedParameters;

  /// The list of positional parameters names.
  /// - Needed for [parametersToMap].
  final List<String>? positionalParametersNames;

  MethodInvocation(this.classType, this.methodName, this.normalParameters,
      [this.optionalParameters, this.namedParameters])
      : positionalParametersNames = null;

  /// Constructor with [positionalParametersNames].
  /// See [parametersToMap].
  MethodInvocation.withPositionalParametersNames(this.classType,
      this.methodName, this.positionalParametersNames, this.normalParameters,
      [this.optionalParameters, this.namedParameters]);

  /// The positional arguments, derived from [normalParameters] and [optionalParameters].
  /// Used by [invoke].
  ///
  /// - See: [Function.apply].
  List<dynamic> get positionalArguments {
    var optionalParameters = this.optionalParameters;

    return optionalParameters == null || optionalParameters.isEmpty
        ? normalParameters
        : [
            ...normalParameters,
            ...optionalParameters,
          ];
  }

  /// The named arguments, derived from [namedParameters].
  /// Used by [invoke].
  ///
  /// - See: [Function.apply].
  Map<Symbol, dynamic>? get namedArguments {
    var namedParameters = this.namedParameters;
    if (namedParameters == null || namedParameters.isEmpty) {
      return null;
    }
    return namedParameters.map((key, value) => MapEntry(Symbol(key), value));
  }

  /// Invokes the [Function] [f] with [positionalArguments] and [namedArguments].
  R invoke<R>(Function f) =>
      Function.apply(f, positionalArguments, namedArguments);

  /// Return all parameters as a [Map] with of parameters names and values.
  ///
  /// See [positionalParametersNames].
  Map<String, dynamic> parametersToMap() {
    var map = <String, dynamic>{...?namedParameters};

    var positionalParametersNames =
        this.positionalParametersNames ?? <String>[];

    for (var i = 0; i < normalParameters.length; ++i) {
      var val = normalParameters[i];
      var name = i < positionalParametersNames.length
          ? positionalParametersNames[i]
          : 'arg_$i';
      map[name] = val;
    }

    var optionalParameters = this.optionalParameters;
    if (optionalParameters != null) {
      var pIdxOffset = normalParameters.length;

      for (var i = 0; i < optionalParameters.length; ++i) {
        var val = optionalParameters[i];
        var pIdx = pIdxOffset + i;
        var name = pIdx < positionalParametersNames.length
            ? positionalParametersNames[pIdx]
            : 'arg_$pIdx';
        map[name] = val;
      }
    }

    return map;
  }

  @override
  String toString() {
    return 'MethodInvocation{normalParameters: $normalParameters, optionalParameters: $optionalParameters, namedParameters: $namedParameters}';
  }
}

final ListEquality<TypeReflection> _listEqualityTypeReflection =
    ListEquality<TypeReflection>();

final MapEquality<String, Type> _mapEqualityType =
    MapEquality<String, Type>(values: TypeEquality());

final MapEquality<String, Type> _mapEquivalencyType =
    MapEquality<String, Type>(values: TypeEquivalency());
