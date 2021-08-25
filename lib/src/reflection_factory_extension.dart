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
}

final ListEquality<Type> _listEqualityType = ListEquality<Type>();
final MapEquality<String, Type> _mapEqualityType = MapEquality<String, Type>();
