import 'package:collection/collection.dart';

import 'reflection_factory_base.dart';

/// [MethodReflection] extension.
extension IterableMethodReflectionExtension<O>
    on Iterable<MethodReflection<O>> {
  /// Returns the [MethodReflection] without parameters.
  Iterable<MethodReflection<O>> whereNoParameters() =>
      where((m) => m.hasNoParameters);

  /// Returns the [MethodReflection] that matches the parameters:
  /// [normalParameters], [optionalParameters] and [namedParameters].
  Iterable<MethodReflection<O>> whereParametersTypes({
    List<Type>? normalParameters,
    List<Type>? optionalParameters,
    Map<String, Type>? namedParameters,
  }) {
    var ret = this;

    if (normalParameters == null &&
        optionalParameters == null &&
        namedParameters == null) {
      return ret;
    }

    if (normalParameters != null) {
      ret = ret.where((m) =>
          _listEqualityType.equals(m.normalParametersTypes, normalParameters));
    }

    if (optionalParameters != null) {
      ret = ret.where((m) => _listEqualityType.equals(
          m.optionalParametersTypes, optionalParameters));
    }

    if (namedParameters != null) {
      ret = ret.where((m) =>
          _mapEqualityType.equals(m.namedParametersTypes, namedParameters));
    }

    return ret;
  }

  /// Returns the [MethodReflection] without annotations.
  Iterable<MethodReflection<O>> whereNotAnnotated() =>
      where((m) => m.annotations.isEmpty);

  /// Returns the [MethodReflection] that matches annotations [test].
  /// If [test] is `null`, will match methods with any annotation.
  Iterable<MethodReflection<O>> whereAnnotated(
      [bool Function(List<Object> annotations)? test]) {
    if (test != null) {
      return where((m) {
        return test(m.annotations);
      });
    }
    return where((m) => m.annotations.isNotEmpty);
  }

  /// Returns the [MethodReflection] that matches [annotations].
  Iterable<MethodReflection<O>> whereAnnotatedWith(List<Object> annotations) {
    if (annotations.isEmpty) {
      return whereNotAnnotated();
    }
    return where((m) => _listEqualityObject.equals(m.annotations, annotations));
  }

  /// Returns the [MethodReflection] that matches any [annotations].
  Iterable<MethodReflection<O>> whereAnnotatedWithAnyOf(
      List<Object> annotations) {
    if (annotations.isEmpty) {
      return <MethodReflection<O>>[];
    }
    return where((m) => m.annotations.any((o) => annotations.contains(o)));
  }

  /// Returns the [MethodReflection] that has an annotation of type [T].
  Iterable<MethodReflection<O>> whereAnnotatedWithType<T>() =>
      where((m) => m.annotations.any((o) => o is T));
}

final ListEquality<Type> _listEqualityType = ListEquality<Type>();
final ListEquality<Object> _listEqualityObject = ListEquality<Object>();
final MapEquality<String, Type> _mapEqualityType = MapEquality<String, Type>();
