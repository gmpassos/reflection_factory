import 'dart:async';
import 'dart:convert' as dart_convert;

import 'package:collection/collection.dart' show ListEquality, MapEquality;
import 'package:pub_semver/pub_semver.dart';

/// Class with all registered reflections ([ClassReflection]).
class ReflectionFactory {
  static final ReflectionFactory _instance = ReflectionFactory._();

  ReflectionFactory._();

  /// Returns the singleton instance of [ReflectionFactory].
  factory ReflectionFactory() => _instance;

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

    var classReflection =
        _instance.getRegisterClassReflection(object.runtimeType);
    if (classReflection != null) {
      return classReflection.toJson(object);
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

/// Base for Class reflection.
abstract class ClassReflection<O> implements Comparable<ClassReflection<O>> {
  final Type classType;
  final O? object;

  ClassReflection(this.classType, [this.object]) {
    register();
  }

  /// Returns `true` if this instances has an associated object ([O]).
  bool get hasObject => object != null;

  /// Returns a new instances with [obj] as the associated object ([O]).
  ClassReflection<O> withObject([O? obj]);

  /// Called automatically when instantiated.
  /// Registers this reflection into [ReflectionFactory].
  void register() {
    if (!ReflectionFactory().hasRegisterClassReflection(classType)) {
      var cr = hasObject ? withObject() : this;
      ReflectionFactory().registerClassReflection(cr);
    }
  }

  /// Returns the Dart language [Version] of the reflected code.
  Version get languageVersion;

  /// Returns the class name.
  String get className => classType.toString();

  int get reflectionLevel =>
      fieldsNames.length +
      staticFieldsNames.length +
      methodsNames.length +
      staticMethodsNames.length;

  /// Returns a `const` [List] of class annotations.
  List<Object> get classAnnotations;

  /// Returns `true` if the class has a default constructor.
  bool get hasDefaultConstructor;

  /// Creates an instance using the default constructor (if present),
  /// other wise returns `null`.
  O? createInstanceWithDefaultConstructor();

  /// Returns `true` if the class has a empty constructor.
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

  /// Creates an instances calling [createInstanceWithDefaultConstructor] or
  /// [createInstanceWithEmptyConstructor].
  O? createInstance() =>
      createInstanceWithDefaultConstructor() ??
      createInstanceWithEmptyConstructor();

  /// Returns a `const` [List] of constructors names.
  List<String> get constructorsNames;

  /// Returns a [List] with all constructors [ConstructorReflection].
  List<ConstructorReflection<O>> allConstructors() =>
      constructorsNames.map((e) => constructor(e)!).toList();

  /// Returns a [ConstructorReflection] for [constructorName].
  ConstructorReflection<O>? constructor<R>(String constructorName);

  /// Returns a `const` [List] of fields names.
  List<String> get fieldsNames;

  /// Returns a [List] with all fields [FieldReflection].
  List<FieldReflection<O, dynamic>> allFields([O? obj]) =>
      fieldsNames.map((e) => field(e, obj)!).toList();

  /// Returns a `const` [List] of static fields names.
  List<String> get staticFieldsNames;

  /// Returns a [List] with all static fields [FieldReflection].
  List<FieldReflection<O, dynamic>> allStaticFields() =>
      staticFieldsNames.map((e) => staticField(e)!).toList();

  /// Returns a [FieldReflection] for [fieldName], with the optional associated [obj].
  FieldReflection<O, T>? field<T>(String fieldName, [O? obj]);

  /// Returns a static [FieldReflection] for [fieldName].
  FieldReflection<O, T>? staticField<T>(String fieldName);

  /// Returns a [List] of fields [FieldReflection] that matches [test].
  Iterable<FieldReflection<O, dynamic>> fieldsWhere(
      bool Function(FieldReflection<O, dynamic> f) test) {
    return fieldsNames.map((n) => field(n)!).where(test);
  }

  /// Returns a [List] of static fields [FieldReflection] that matches [test].
  Iterable<FieldReflection<O, dynamic>> staticFieldsWhere(
      bool Function(FieldReflection<O, dynamic> f) test) {
    return staticFieldsNames.map((n) => staticField(n)!).where(test);
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

  /// Returns a [List] with all methods [MethodReflection].
  List<MethodReflection<O, dynamic>> allMethods([O? obj]) =>
      methodsNames.map((e) => method(e, obj)!).toList();

  /// Returns a `const` [List] of static methods names.
  List<String> get staticMethodsNames;

  /// Returns a [List] with all static methods [MethodReflection].
  List<MethodReflection<O, dynamic>> allStaticMethods() =>
      staticMethodsNames.map((e) => staticMethod(e)!).toList();

  /// Returns a [MethodReflection] for [methodName], with the optional associated [obj].
  MethodReflection<O, R>? method<R>(String methodName, [O? obj]);

  /// Returns a static [MethodReflection] for [methodName].
  MethodReflection<O, R>? staticMethod<R>(String methodName);

  /// Returns a [List] of methods [MethodReflection] that matches [test].
  Iterable<MethodReflection<O, dynamic>> methodsWhere(
      bool Function(MethodReflection<O, dynamic> f) test) {
    return methodsNames.map((n) => method(n)!).where(test);
  }

  /// Returns a [List] of static methods [MethodReflection] that matches [test].
  Iterable<MethodReflection<O, dynamic>> staticMethodsWhere(
      bool Function(MethodReflection<O, dynamic> f) test) {
    return staticMethodsNames.map((n) => staticMethod(n)!).where(test);
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

  ElementResolver<MethodReflection<O, dynamic>>? _methodToJsonResolver;

  MethodReflection<O, dynamic>? get _methodToJson =>
      (_methodToJsonResolver ??= methodResolver('toJson')).get();

  /// Returns a JSON [Map].
  /// If the class implements `toJson` calls it.
  ///
  /// - If [obj] is not provided, uses [object] as instance.
  Map<String, dynamic> toJson([O? obj]) {
    var m = _methodToJson;

    if (m != null && m.normalParameters.isEmpty && m.returnType?.type == Map) {
      m = m.withObject(obj ?? object!);
      var map = m.invoke([]) as Map;
      return map is Map<String, dynamic>
          ? map
          : map.map((key, value) => MapEntry('$key', value));
    }

    return toJsonFromFields(obj);
  }

  /// Returns a JSON [Map] from [fieldsNames], calling [getField] for each one.
  ///
  /// - If [obj] is not provided, uses [object] as instance.
  Map<String, dynamic> toJsonFromFields([O? obj]) {
    return Map<String, dynamic>.fromEntries(fieldsNames.map((f) {
      var val = getField(f, obj);
      return MapEntry(f, val);
    }));
  }

  /// Returns a JSON [Map]. See [toJson].
  String toJsonEncoded([O? obj]) {
    var json = toJson(obj);
    return dart_convert.json.encode(json);
  }

  @override
  int compareTo(ClassReflection<O> other) =>
      reflectionLevel.compareTo(other.reflectionLevel);

  @override
  String toString() {
    return 'ClassReflection{ '
            'class: $className '
            '}' +
        (object != null ? '<$object>' : '');
  }
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

  /// Returns `true` if this element is static.
  final bool isStatic;

  ElementReflection(this.classReflection, this.isStatic);

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

  final List<Object>? _annotations;

  /// The parameter annotations.
  List<Object>? get annotations => _annotations != null
      ? List<Object>.unmodifiable(_annotations!)
      : _annotationsEmpty;

  const ParameterReflection(
      this.type, this.name, this.nullable, this.required, this._annotations);

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
    return 'ParameterReflection{type: $type${nullable ? '?' : ''}, name: $name${required ? ', required' : ''}';
  }
}

/// Dart [Type] reflection.
class TypeReflection {
  static const TypeReflection tObject = TypeReflection(Object);
  static const TypeReflection tDynamic = TypeReflection(dynamic);
  static const TypeReflection tString = TypeReflection(String);
  static const TypeReflection tDouble = TypeReflection(double);
  static const TypeReflection tInt = TypeReflection(int);
  static const TypeReflection tNum = TypeReflection(num);
  static const TypeReflection tBool = TypeReflection(bool);
  static const TypeReflection tList = TypeReflection(List);
  static const TypeReflection tMap = TypeReflection(Map);
  static const TypeReflection tSet = TypeReflection(Set);
  static const TypeReflection tFuture = TypeReflection(Future);
  static const TypeReflection tFutureOr = TypeReflection(FutureOr);

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

  static String? getConstantName(String type,
      [List<String> args = const <String>[]]) {
    switch (type) {
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

          var a = args[0] + ';' + args[1];

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
      default:
        return null;
    }
  }

  /// The Dart [Type].
  final Type type;

  /// The [Type] arguments.
  ///
  /// Example: `Map<String, int>` will return `[String, int]`.
  final List<Object>? _arguments;

  const TypeReflection(this.type, [this._arguments]);

  factory TypeReflection.from(Object o) {
    if (o is TypeReflection) {
      return o;
    } else if (o is Type) {
      return TypeReflection(o);
    } else if (o is List<Type>) {
      var t = o[0];
      if (o.length > 1) {
        var args = o.sublist(1).map((e) => TypeReflection.from(e)).toList();
        return TypeReflection(t, args);
      } else {
        return TypeReflection(t);
      }
    } else {
      throw ArgumentError("Invalid type: $o");
    }
  }

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
    var argumentsObj = _arguments;
    if (argumentsObj == null || argumentsObj.isEmpty) {
      return types.isEmpty;
    }

    if (argumentsObj.length != types.length) {
      return false;
    }

    return _listEqualityType.equals(
        arguments.map((e) => e.type).toList(), types);
  }

  bool get isPrimitiveType {
    return type == String ||
        type == int ||
        type == double ||
        type == num ||
        type == bool;
  }

  bool get isCollectionType {
    return type == Map || type == List || type == Iterable || type == Set;
  }

  bool get isMapType {
    return type == Map;
  }

  bool get isIterableType {
    return type == List || type == Iterable || type == Set;
  }

  bool get isNumericType {
    return type == int || type == double || type == num;
  }

  bool get isIntType {
    return type == int;
  }

  bool get isDoubleType {
    return type == double;
  }

  bool get isBoolType {
    return type == bool;
  }

  bool get isStringType {
    return type == String;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TypeReflection &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          _listEqualityTypeReflection.equals(arguments, other.arguments);

  @override
  int get hashCode =>
      type.hashCode ^ _listEqualityTypeReflection.hash(arguments);

  @override
  String toString() {
    if (hasArguments) {
      return '$type<${arguments.join(', ')}>';
    } else {
      return '$type';
    }
  }
}

typedef FieldGetter<T> = T Function();
typedef FieldSetter<T> = void Function(T? v);

typedef FieldReflectionGetterAccessor<O, T> = FieldGetter<T> Function(O? obj);
typedef FieldReflectionSetterAccessor<O, T> = FieldSetter<T> Function(O? obj);

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

  FieldReflection(
    ClassReflection<O> classReflection,
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
        super(classReflection, isStatic);

  FieldReflection._(
    ClassReflection<O> classReflection,
    this.type,
    this.name,
    this.nullable,
    this.getterAccessor,
    this.setterAccessor,
    this.object,
    bool isStatic,
    this.isFinal,
    this._annotations,
  ) : super(classReflection, isStatic);

  /// Returns a new instance that references [object].
  FieldReflection<O, T> withObject(O object) {
    return FieldReflection<O, T>._(
        classReflection,
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

  FieldGetter<T>? _getter;

  /// Returns this field value.
  T get() {
    var getter = _getter ??= getterAccessor(object);
    return getter();
  }

  FieldSetter<T>? _setter;

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

  @override
  String toString() {
    return 'FieldReflection{ '
            'class: $className, '
            'name: $name, '
            'type: ${nullable ? '$type?' : '$type'}, '
            'static: $isStatic, '
            'final: $isFinal '
            '}' +
        (object != null ? '<$object>' : '');
  }
}

/// Base class fro methods and constructors.
abstract class FunctionReflection<O, R> extends ElementReflection<O> {
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

  /// Returns all the parameters: [normalParameters], [optionalParameters], [namedParameters].
  List<ParameterReflection> get allParameters =>
      [...normalParameters, ...optionalParameters, ...namedParameters.values];

  /// The method annotations.
  List<Object> annotations;

  /// The Dart function for the method or constructor.
  Function get _function;

  FunctionReflection(
    ClassReflection<O> classReflection,
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
        super(classReflection, isStatic);

  FunctionReflection._(
    ClassReflection<O> classReflection,
    this.name,
    this.returnType,
    this.returnNullable,
    bool isStatic,
    this.normalParameters,
    this.optionalParameters,
    this.namedParameters,
    this.annotations,
  ) : super(classReflection, isStatic);

  /// Returns `true` if this methods has no arguments/parameters.
  bool get hasNoParameters =>
      normalParameters.isEmpty &&
      optionalParameters.isEmpty &&
      namedParameters.isEmpty;

  /// Returns the [normalParameters] [TypeReflection]s.
  List<TypeReflection> get normalParametersTypeReflection =>
      normalParameters.map((e) => e.type).toList();

  /// Returns the [normalParameters] [Type]s.
  List<Type> get normalParametersTypes =>
      normalParameters.map((e) => e.type.type).toList();

  /// Returns the [normalParameters] names.
  List<String> get normalParametersNames =>
      normalParameters.map((e) => e.name).toList();

  /// Returns the [optionalParameters] [TypeReflection]s.
  List<TypeReflection> get optionalParametersTypeReflection =>
      optionalParameters.map((e) => e.type).toList();

  /// Returns the [optionalParameters] [Type]s.
  List<Type> get optionalParametersTypes =>
      optionalParameters.map((e) => e.type.type).toList();

  /// Returns the [optionalParameters] names.
  List<String> get optionalParametersNames =>
      optionalParameters.map((e) => e.name).toList();

  /// Returns the [namedParameters] [TypeReflection]s.
  Map<String, TypeReflection> get namedParametersTypeReflection =>
      namedParameters.map((k, v) => MapEntry(k, v.type));

  /// Returns the [namedParameters] [Type]s.
  Map<String, Type> get namedParametersTypes =>
      namedParameters.map((k, v) => MapEntry(k, v.type.type));

  /// Returns the [namedParameters] names.
  List<String> get namedParametersNames => namedParameters.keys.toList();

  /// Returns `true` if [parameters] is equals to [normalParameters].
  bool equalsNormalParametersTypes(List<Type> parameters) =>
      _listEqualityType.equals(normalParametersTypes, parameters);

  /// Returns `true` if [parameters] is equals to [optionalParameters].
  bool equalsOptionalParametersTypes(List<Type> parameters) =>
      _listEqualityType.equals(optionalParametersTypes, parameters);

  /// Returns `true` if [parameters] is equals to [namedParameters].
  bool equalsNamedParametersTypes(Map<String, Type> parameters) =>
      _mapEqualityType.equals(namedParametersTypes, parameters);

  /// Creates a [MethodInvocation] using [map] entries as parameters.
  MethodInvocation<O> methodInvocationFromMap(Map<String, dynamic> map) {
    return methodInvocation((k) => map[k]);
  }

  /// Creates a [MethodInvocation] using [parametersProvider].
  MethodInvocation<O> methodInvocation(
      Function(String key) parametersProvider) {
    var normalParameters =
        this.normalParameters.map((p) => parametersProvider(p.name)).toList();

    var optionalParameters = this.optionalParameters.map((p) {
      return parametersProvider(p.name);
    }).toList();

    Map<String, dynamic> namedParameters =
        Map<String, dynamic>.fromEntries(this.namedParameters.entries.map((e) {
      var k = e.key;
      var p = e.value;

      var value = parametersProvider(k);

      if (value == null && p.nullable && !p.required) {
        return null;
      } else {
        return MapEntry(k, value);
      }
    }).whereType<MapEntry<String, dynamic>>());

    return MethodInvocation<O>(classReflection.classType, name,
        normalParameters, optionalParameters, namedParameters);
  }

  /// Invoke this method.
  R invoke(Iterable<Object?>? positionalArguments,
      [Map<Symbol, Object?>? namedArguments]) {
    return Function.apply(
        _function, positionalArguments?.toList(), namedArguments);
  }
}

typedef ConstructorReflectionAccessor<O> = Function Function();

class ConstructorReflection<O> extends FunctionReflection<O, O> {
  final ConstructorReflectionAccessor constructorAccessor;

  ConstructorReflection(
      ClassReflection<O> classReflection,
      String name,
      this.constructorAccessor,
      List<ParameterReflection>? normalParameters,
      List<ParameterReflection>? optionalParameters,
      Map<String, ParameterReflection>? namedParameters,
      List<Object>? annotations,
      {Type? type})
      : super(classReflection, name, TypeReflection(type ?? O), false, true,
            normalParameters, optionalParameters, namedParameters, annotations);

  Function? _constructor;

  Function get constructor => _constructor ??= constructorAccessor();

  @override
  Function get _function => constructor();

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
  ) : super(classReflection, name, returnType, returnNullable, isStatic,
            normalParameters, optionalParameters, namedParameters, annotations);

  MethodReflection._(
    ClassReflection<O> classReflection,
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
  ) : super._(classReflection, name, returnType, returnNullable, isStatic,
            normalParameters, optionalParameters, namedParameters, annotations);

  /// Returns a new instance that references [object].
  MethodReflection<O, R> withObject(O object) => MethodReflection._(
      classReflection,
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
  String toString() {
    return 'MethodReflection{ '
            'class: $className, '
            'name: $name, '
            'returnType: ${returnNullable ? '$returnType?' : '$returnType'}, '
            'static: $isStatic, '
            'normalParameters: $normalParameters, '
            'optionalParameters: $optionalParameters, '
            'namedParameters: $namedParameters '
            '}' +
        (object != null ? '<$object>' : '');
  }
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

  MethodInvocation(this.classType, this.methodName, this.normalParameters,
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

  @override
  String toString() {
    return 'MethodInvocation{normalParameters: $normalParameters, optionalParameters: $optionalParameters, namedParameters: $namedParameters}';
  }
}

final ListEquality<TypeReflection> _listEqualityTypeReflection =
    ListEquality<TypeReflection>();

final ListEquality<Type> _listEqualityType = ListEquality<Type>();
final MapEquality<String, Type> _mapEqualityType = MapEquality<String, Type>();
