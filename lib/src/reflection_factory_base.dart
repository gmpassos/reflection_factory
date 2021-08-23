import 'dart:convert' as dart_convert;

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

  /// Returns a `const` [List] of static methods names.
  List<String> get staticMethodsNames;

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

/// A class field reflection.
class FieldReflection<O, T> extends ElementReflection<O> {
  /// Returns name of this field.
  final String name;

  /// Returns [Type] of this field.
  final Type type;

  /// Returns `true` if this field is nullable.
  final bool nullable;

  final T Function() _getter;
  final void Function(T v)? _setter;

  /// Returns the associated object ([O]) of this field.
  /// Returns `null` for static fields.
  final O? object;

  /// Returns `true` if this field is final.
  final bool isFinal;

  FieldReflection(
    ClassReflection<O> classReflection,
    this.name,
    this.type,
    this.nullable,
    this._getter,
    this._setter,
    this.object,
    bool isStatic,
    this.isFinal,
  ) : super(classReflection, isStatic);

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

  /// The return [Type] of this method.
  final Type returnType;

  /// `true` if the returned value of this method can be `null`.
  final bool returnNullable;

  final Function _method;

  /// The associated object ([O]) of this method.
  /// `null` for static methods.
  final O? object;

  /// The normal parameters [Type]s of this method.
  final List<Type> normalParameters;

  /// The normal parameters names of this method.
  final List<String> normalParametersNames;

  /// The optional parameters [Type]s of this method.
  final List<Type> optionalParameters;

  /// The optional parameters names of this method.
  final List<String> optionalParametersNames;

  /// The named parameters [Type]s of this method.
  final Map<String, Type> namedParameters;

  MethodReflection(
      ClassReflection<O> classReflection,
      this.name,
      this.returnType,
      this.returnNullable,
      this._method,
      this.object,
      bool isStatic,
      List<Type>? normalParameters,
      List<String>? normalParametersNames,
      List<Type>? optionalParameters,
      List<String>? optionalParametersNames,
      Map<String, Type>? namedParameters)
      : normalParameters =
            List<Type>.unmodifiable(normalParameters ?? <Type>[]),
        normalParametersNames =
            List<String>.unmodifiable(normalParametersNames ?? <String>[]),
        optionalParameters =
            List<Type>.unmodifiable(optionalParameters ?? <Type>[]),
        optionalParametersNames =
            List<String>.unmodifiable(optionalParametersNames ?? <String>[]),
        namedParameters =
            Map<String, Type>.unmodifiable(namedParameters ?? <String, Type>{}),
        super(classReflection, isStatic);

  /// Returns `true` if this methods has no arguments/parameters.
  bool get noArgs =>
      normalParameters.isEmpty &&
      optionalParameters.isEmpty &&
      namedParameters.isEmpty;

  /// Invoke this method.
  R? invoke<R>(Iterable<Object?>? positionalArguments,
      [Map<Symbol, Object?>? namedArguments]) {
    return Function.apply(
        _method, positionalArguments?.toList(), namedArguments);
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
