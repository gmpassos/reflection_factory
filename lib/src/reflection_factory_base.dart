import 'dart:convert' as dart_convert;

import 'package:collection/collection.dart' show ListEquality, MapEquality;
import 'package:pub_semver/pub_semver.dart';

/// Class with all registered reflections ([ClassReflection]).
class ReflectionFactory {
  static final ReflectionFactory _instance = ReflectionFactory._();

  ReflectionFactory._();

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

  /// Returns a `const` [List] of fields names.
  List<String> get fieldsNames;

  /// Returns a `const` [List] of static fields names.
  List<String> get staticFieldsNames;

  /// Returns a [FieldReflection] for [fieldName], with the optional associated [obj].
  FieldReflection<O, T>? field<T>(String fieldName, [O? obj]);

  /// Returns a static [FieldReflection] for [fieldName].
  FieldReflection<O, T>? staticField<T>(String fieldName);

  /// Returns a `const` [List] of methods names.
  List<String> get methodsNames;

  /// Returns a [List] with all methods [MethodReflection].
  List<MethodReflection<O>> allMethods([O? obj]) =>
      methodsNames.map((e) => method(e, obj)!).toList();

  /// Returns a `const` [List] of static methods names.
  List<String> get staticMethodsNames;

  /// Returns a [List] with all static methods [MethodReflection].
  List<MethodReflection<O>> allStaticMethods() =>
      staticMethodsNames.map((e) => staticMethod(e)!).toList();

  /// Returns a [MethodReflection] for [methodName], with the optional associated [obj].
  MethodReflection<O>? method(String methodName, [O? obj]);

  /// Returns a static [MethodReflection] for [methodName].
  MethodReflection<O>? staticMethod(String methodName);

  /// Returns the field value for [fieldName].
  T? getField<T>(String fieldName, [O? obj]) {
    var field = this.field<T>(fieldName, obj);
    return field?.get();
  }

  /// Sets the field [value] for [fieldName].
  void setField<T>(String fieldName, T value, [O? obj]) {
    var field = this.field<T>(fieldName, obj);
    return field?.set(value);
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

  /// Returns a JSON [Map].
  ///
  /// - If [obj] is not provided, uses [object] as instance.
  Map<String, dynamic> toJson([O? obj]) {
    var m = method('toJson', obj);

    if (m != null && m.normalParameters.isEmpty) {
      return m.invoke([]);
    }

    return Map<String, dynamic>.fromEntries(fieldsNames.map((f) {
      var val = getField(f);
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
  final Type type;

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

/// A class field reflection.
class FieldReflection<O, T> extends ElementReflection<O>
    implements ParameterReflection {
  /// Returns [Type] of this field.
  @override
  final Type type;

  /// Returns name of this field.
  @override
  final String name;

  /// Returns `true` if this field is nullable.
  @override
  final bool nullable;

  /// Returns `true` if this field is NOT [nullable].
  @override
  bool get required => !nullable;

  final T Function() _getter;
  final void Function(T v)? _setter;

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
    this._getter,
    this._setter,
    this.object,
    bool isStatic,
    this.isFinal,
    List<Object>? annotations,
  )   : _annotations = annotations == null || annotations.isEmpty
            ? _annotationsEmpty
            : List<Object>.unmodifiable(annotations),
        super(classReflection, isStatic);

  /// Returns this field value.
  T get() => _getter();

  /// Sets this field value.
  void set(T v) {
    var setter = _setter;
    if (setter != null) {
      setter(v);
    } else {
      throw StateError('Final field: $className.$name');
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

/// A class method reflection.
class MethodReflection<O> extends ElementReflection<O> {
  /// The name of this method.
  final String name;

  /// The return [Type] of this method. Returns `null` for void type.
  final Type? returnType;

  /// `true` if the returned value of this method can be `null`.
  final bool returnNullable;

  final Function method;

  /// The associated object ([O]) of this method.
  /// `null` for static methods.
  final O? object;

  /// The normal parameters [Type]s of this method.
  final List<ParameterReflection> normalParameters;

  /// The optional parameters [Type]s of this method.
  final List<ParameterReflection> optionalParameters;

  /// The named parameters [Type]s of this method.
  final Map<String, ParameterReflection> namedParameters;

  /// The method annotations.
  List<Object> annotations;

  MethodReflection(
    ClassReflection<O> classReflection,
    this.name,
    this.returnType,
    this.returnNullable,
    this.method,
    this.object,
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

  /// Returns `true` if this methods has no arguments/parameters.
  bool get hasNoParameters =>
      normalParameters.isEmpty &&
      optionalParameters.isEmpty &&
      namedParameters.isEmpty;

  /// Returns the [normalParameters] [Type]s.
  List<Type> get normalParametersTypes =>
      normalParameters.map((e) => e.type).toList();

  /// Returns the [normalParameters] names.
  List<String> get normalParametersNames =>
      normalParameters.map((e) => e.name).toList();

  /// Returns the [optionalParameters] [Type]s.
  List<Type> get optionalParametersTypes =>
      optionalParameters.map((e) => e.type).toList();

  /// Returns the [optionalParameters] names.
  List<String> get optionalParametersNames =>
      optionalParameters.map((e) => e.name).toList();

  /// Returns the [namedParameters] [Type]s.
  Map<String, Type> get namedParametersTypes =>
      namedParameters.map((k, v) => MapEntry(k, v.type));

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
  R? invoke<R>(Iterable<Object?>? positionalArguments,
      [Map<Symbol, Object?>? namedArguments]) {
    return Function.apply(
        method, positionalArguments?.toList(), namedArguments);
  }

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

final ListEquality<Type> _listEqualityType = ListEquality<Type>();
final MapEquality<String, Type> _mapEqualityType = MapEquality<String, Type>();
