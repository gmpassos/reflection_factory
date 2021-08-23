import 'package:meta/meta_meta.dart';

/// Enables reflection for a class.
@Target({TargetKind.classType})
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
