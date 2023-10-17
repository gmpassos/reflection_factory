import 'dart:async';

import 'package:meta/meta_meta.dart';

import 'reflection_factory_base.dart';

/// Enables reflection for a class.
@Target({TargetKind.classType, TargetKind.enumType})
class EnableReflection {
  /// Name of the generated reflection class (optional).
  /// - Defaults to `class name` + `$reflection`.
  /// - Example: `User$reflection`
  final String reflectionClassName;

  /// Name of the generated reflection extension (optional).
  /// - Defaults to `class name` + `$reflectionExtension`.
  /// - Example: `User$reflectionExtension`
  final String reflectionExtensionName;

  /// If true the [ClassReflection] implementation will use a `factory`
  /// constructor and cache the instances by `object` in an [Expando].
  /// Default: `true`
  final bool optimizeReflectionInstances;

  const EnableReflection({
    this.reflectionClassName = '',
    this.reflectionExtensionName = '',
    this.optimizeReflectionInstances = true,
  });
}

/// Indicates that a class is a reflection bridge of [Type]s in [classesTypes] [List].
@Target({TargetKind.classType})
class ReflectionBridge {
  /// List of classes to generate/enable reflection.
  final List<Type> classesTypes;

  /// Name of the generated reflection bridge extension (optional).
  /// - Defaults to `bridge class name` + `$reflectionExtension`.
  /// - Example: `UserBridge$reflectionExtension`
  final String bridgeExtensionName;

  /// Name of the generated reflection class for [classesTypes] (optional).
  /// See [EnableReflection.reflectionClassName].
  final Map<Type, String> reflectionClassNames;

  /// Name of the generated reflection extension for [classesTypes] (optional).
  /// See [EnableReflection.reflectionExtensionName].
  final Map<Type, String> reflectionExtensionNames;

  /// If true the [ClassReflection] implementation will use a `factory`
  /// constructor and cache the instances by `object` in an [Expando].
  /// Default: `true`
  final bool optimizeReflectionInstances;

  const ReflectionBridge(
    this.classesTypes, {
    this.bridgeExtensionName = '',
    this.reflectionClassNames = const <Type, String>{},
    this.reflectionExtensionNames = const <Type, String>{},
    this.optimizeReflectionInstances = true,
  });
}

/// Informs that a class will be a proxy to a target class with [className],
/// without directly depending on the target class.
///
/// - If [libraryName] is defined, ensures that the target class if from the correct library.
/// - [reflectionProxyName] is the name of the generated proxy.
@Target({TargetKind.classType})
class ClassProxy {
  /// The class name for the proxy.
  final String className;

  /// The Dart library name with the [className].
  final String libraryName;

  /// The library path for [libraryName].
  final String libraryPath;

  /// The name of the generated reflection proxy.
  final String reflectionProxyName;

  /// If `true` all methods will return a Future<R>.
  final bool alwaysReturnFuture;

  /// The list return o types to traverse.
  final Set<Type> traverseReturnTypes;

  /// The parameters types to ignore
  final Set<Type> ignoreParametersTypes;

  /// Methods to ignore.
  final Set<String> ignoreMethods;

  /// Extra methods to ignore.
  final Set<String> ignoreMethods2;

  const ClassProxy(
    this.className, {
    this.libraryName = '',
    this.libraryPath = '',
    this.reflectionProxyName = '',
    this.ignoreMethods = const <String>{},
    this.ignoreMethods2 = const <String>{},
    this.alwaysReturnFuture = false,
    this.traverseReturnTypes = const <Type>{},
    this.ignoreParametersTypes = const <Type>{},
  });

  static T returnValue<T>(Object? ret) {
    if (ret is T) {
      return ret;
    } else {
      throw ClassProxyCallError.returnedValueError(T, ret);
    }
  }

  static Future<T> returnFuture<T>(Object? ret) {
    if (ret is Future<T>) return ret;

    if (ret is Future) {
      return ret.then((v) {
        if (v is! T) {
          throw ClassProxyCallError.returnedValueError(T, v);
        }
        return v;
      });
    } else {
      if (ret is! T) {
        throw ClassProxyCallError.returnedValueError(T, ret);
      }
      return Future<T>.value(ret);
    }
  }

  static FutureOr<T> returnFutureOr<T>(Object? ret) {
    if (ret is Future<T>) return ret;
    if (ret is T) return ret;

    if (ret is Future) {
      return ret.then((v) {
        if (v is! T) {
          throw ClassProxyCallError.returnedValueError(T, v);
        }
        return v;
      });
    } else {
      if (ret is! T) {
        throw ClassProxyCallError.returnedValueError(T, ret);
      }
      return ret;
    }
  }
}

@Target({TargetKind.method})
class IgnoreClassProxyMethod {
  const IgnoreClassProxyMethod();
}

/// A [ClassProxy] call error.
class ClassProxyCallError extends StateError {
  ClassProxyCallError(super.message) : super();

  ClassProxyCallError.returnedValueError(Type t, Object? value)
      : this("Can't cast returned value to `$t`: $value");
}

/// Interface that a proxy class (annotated with [ClassProxy]) should implement
/// to list for proxy calls.
abstract class ClassProxyListener<T> {
  /// Calls made through a [ClassProxy] will be intercepted by [onCall] implementation.
  Object? onCall(T instance, String methodName, Map<String, dynamic> parameters,
      TypeReflection? returnType);
}

/// A [ClassProxyListener] that delegates to [targetListener].
class ClassProxyDelegateListener<T> extends ClassProxyListener<T> {
  /// The target listener that will receive the calls.
  final ClassProxyListener<T> targetListener;

  ClassProxyDelegateListener(this.targetListener);

  @override
  Object? onCall(T instance, String methodName, Map<String, dynamic> parameters,
      TypeReflection? returnType) {
    return targetListener.onCall(instance, methodName, parameters, returnType);
  }
}

abstract class JsonAnnotation {
  const JsonAnnotation();
}

/// Informs that a class field can be hidden [JsonField.hidden] or visible [JsonField.visible]
@Target({TargetKind.field, TargetKind.getter})
class JsonField extends JsonAnnotation {
  final bool _hidden;

  const JsonField({bool hidden = false}) : _hidden = hidden;

  const JsonField.visible() : this(hidden: false);

  const JsonField.hidden() : this(hidden: true);

  /// Returns `true` if the annotated field should be hidden from JSON.
  bool get isHidden => _hidden;

  /// Returns `true` if the annotated field should be visible from JSON.
  bool get isVisible => !_hidden;
}

extension IterableJsonFieldExtension on Iterable<JsonField> {
  bool get hasHidden => any((a) => a.isHidden);

  bool get hasVisible => any((a) => a.isVisible);
}

/// Defines the JSON field name.
/// - If used in a constructor parameter, defines the corresponding JSON field.
@Target({TargetKind.parameter, TargetKind.field, TargetKind.getter})
class JsonFieldAlias extends JsonAnnotation {
  final String name;

  const JsonFieldAlias(this.name);

  static final RegExp _nameFormat = RegExp(r'^[a-zA-Z_]\w*$');

  bool get isValid {
    var n = name.trim();
    if (n.isEmpty || n != name) return false;
    return _nameFormat.hasMatch(name);
  }
}

extension IterableJsonFieldAliasExtension on Iterable<JsonFieldAlias> {
  Iterable<JsonFieldAlias> get valid => where((a) => a.isValid);

  Iterable<String> get validNames => valid.map((a) => a.name);

  String? get alias {
    String? name;
    for (var a in validNames) {
      if (name == null) {
        name = a;
      } else if (name == a) {
        continue;
      } else {
        throw StateError("Multiple JSON field aliases: "
            "${where((a) => a.isValid).map((a) => a.name).toList()}");
      }
    }
    return name;
  }
}

/// Indicates the constructor to be used to instantiate an entity from JSON/[Map].
// `TargetKind.constructor` is not defined yet!:
// @Target({TargetKind.constructor})
class JsonConstructor extends JsonAnnotation {
  /// If `true` indicates that this is the only constructor to be used for JSON.
  /// If multiple constructos are declared as mandatory,
  /// only the 1st to work with the passed parameters will be used.
  final bool mandatory;

  const JsonConstructor({this.mandatory = false});
}
