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

  const EnableReflection({
    this.reflectionClassName = '',
    this.reflectionExtensionName = '',
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

  const ReflectionBridge(
    this.classesTypes, {
    this.bridgeExtensionName = '',
    this.reflectionClassNames = const <Type, String>{},
    this.reflectionExtensionNames = const <Type, String>{},
  });
}

/// Informs that a class will be a proxy to a target class with [className],
/// without directly depending on the target class.
///
/// - If [libraryName] is defined, ensures that the target class if from the correct library.
/// - [reflectionProxyName] is the name of the generated proxy.
@Target({TargetKind.classType})
class ClassProxy {
  final String className;
  final String libraryName;
  final String libraryPath;
  final String reflectionProxyName;
  final bool alwaysReturnFuture;
  final Set<Type> traverseReturnTypes;
  final Set<Type> ignoreParametersTypes;
  final Set<String> ignoreMethods;

  const ClassProxy(
    this.className, {
    this.libraryName = '',
    this.libraryPath = '',
    this.reflectionProxyName = '',
    this.ignoreMethods = const <String>{},
    this.alwaysReturnFuture = false,
    this.traverseReturnTypes = const <Type>{},
    this.ignoreParametersTypes = const <Type>{},
  });
}

/// Interface that a proxy class (annotated with [ClassProxy]) should implement
/// to list for proxy calls.
abstract class ClassProxyListener<T> {
  /// Calls made through a [ClassProxy] will be intercepted by [onCall] implementation.
  Object? onCall(T instance, String methodName, Map<String, dynamic> parameters,
      TypeReflection? returnType);
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
