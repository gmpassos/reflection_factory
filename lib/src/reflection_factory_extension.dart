import 'package:collection/collection.dart';

import 'reflection_factory_base.dart';

/// [TypeReflection] extension.
extension IterableTypeReflectionExtension on Iterable<TypeReflection> {
  /// Maps to [Type].
  Iterable<Type> toTypes() => map((e) => e.type);

  /// Filter by [TypeReflection.hasArguments].
  Iterable<TypeReflection> withArguments() => where((e) => e.hasArguments);
}

/// [FieldReflection] extension.
extension IterableParameterReflectionExtension<O, T>
    on Iterable<ParameterReflection> {
  /// Maps to [TypeReflection].
  Iterable<TypeReflection> toTypeReflections() => map((e) => e.type);

  /// Maps to [Type].
  Iterable<Type> toTypes() => map((e) => e.type.type);

  /// Maps to [ParameterReflection.name].
  Iterable<String> toNames() => map((e) => e.name);

  /// Filter by [ParameterReflection.nullable].
  Iterable<ParameterReflection> whereNullable() => where((e) => e.nullable);

  /// Filter by [ParameterReflection.required].
  Iterable<ParameterReflection> whereRequired() => where((e) => e.required);
}

/// [FieldReflection] extension.
extension IterableFieldReflectionExtension<O, T>
    on Iterable<FieldReflection<O, T>> {
  /// Maps to [TypeReflection].
  Iterable<TypeReflection> toTypeReflections() => map((e) => e.type);

  /// Maps to [Type].
  Iterable<Type> toTypes() => map((e) => e.type.type);

  /// Maps to [FieldReflection.name].
  Iterable<String> toNames() => map((e) => e.name);

  /// Filter by [FieldReflection.isFinal].
  Iterable<FieldReflection<O, T>> whereFinal() => where((e) => e.isFinal);

  /// Filter by [FieldReflection.isStatic].
  Iterable<FieldReflection<O, T>> whereStatic() => where((e) => e.isStatic);

  /// Filter by [FieldReflection.nullable].
  Iterable<FieldReflection<O, T>> whereNullable() => where((e) => e.nullable);
}

/// [MethodReflection] extension.
extension IterableMethodReflectionExtension<O, R>
    on Iterable<MethodReflection<O, R>> {
  /// Maps to returned [TypeReflection].
  Iterable<TypeReflection?> toReturnTypeReflections() =>
      map((e) => e.returnType);

  /// Maps to returned [Type].
  Iterable<Type?> toReturnTypes() => map((e) => e.returnType?.type);

  /// Maps to [MethodReflection.name].
  Iterable<String> toNames() => map((e) => e.name);

  /// Filter by [MethodReflection.isStatic].
  Iterable<MethodReflection<O, R>> whereStatic() => where((e) => e.isStatic);

  /// Returns the [MethodReflection] without parameters.
  Iterable<MethodReflection<O, R>> whereNoParameters() =>
      where((m) => m.hasNoParameters);

  /// Returns the [MethodReflection] that matches the parameters:
  /// [normalParameters], [optionalParameters] and [namedParameters].
  Iterable<MethodReflection<O, R>> whereParametersTypes({
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
  Iterable<MethodReflection<O, R>> whereNotAnnotated() =>
      where((m) => m.annotations.isEmpty);

  /// Returns the [MethodReflection] that matches annotations [test].
  /// If [test] is `null`, will match methods with any annotation.
  Iterable<MethodReflection<O, R>> whereAnnotated(
      [bool Function(List<Object> annotations)? test]) {
    if (test != null) {
      return where((m) {
        return test(m.annotations);
      });
    }
    return where((m) => m.annotations.isNotEmpty);
  }

  /// Returns the [MethodReflection] that matches [annotations].
  Iterable<MethodReflection<O, R>> whereAnnotatedWith(
      List<Object> annotations) {
    if (annotations.isEmpty) {
      return whereNotAnnotated();
    }
    return where((m) => _listEqualityObject.equals(m.annotations, annotations));
  }

  /// Returns the [MethodReflection] that matches any [annotations].
  Iterable<MethodReflection<O, R>> whereAnnotatedWithAnyOf(
      List<Object> annotations) {
    if (annotations.isEmpty) {
      return <MethodReflection<O, R>>[];
    }
    return where((m) => m.annotations.any((o) => annotations.contains(o)));
  }

  /// Returns the [MethodReflection] that has an annotation of type [T].
  Iterable<MethodReflection<O, R>> whereAnnotatedWithType<T>() =>
      where((m) => m.annotations.any((o) => o is T));
}

final ListEquality<Type> _listEqualityType = ListEquality<Type>();
final ListEquality<Object> _listEqualityObject = ListEquality<Object>();
final MapEquality<String, Type> _mapEqualityType = MapEquality<String, Type>();

extension ReflectionDurationExtension on Duration {
  static const int microsecondsPerMillisecond = 1000;

  static const int millisecondsPerSecond = 1000;

  static const int secondsPerMinute = 60;

  static const int minutesPerHour = 60;

  static const int hoursPerDay = 24;

  static const int microsecondsPerSecond =
      microsecondsPerMillisecond * millisecondsPerSecond;

  static const int microsecondsPerMinute =
      microsecondsPerSecond * secondsPerMinute;

  static const int microsecondsPerHour = microsecondsPerMinute * minutesPerHour;

  static const int millisecondsPerMinute =
      millisecondsPerSecond * secondsPerMinute;

  static const int millisecondsPerHour = millisecondsPerMinute * minutesPerHour;

  String toHumanReadable() {
    var microseconds = inMicroseconds;
    var sign = (microseconds < 0) ? "-" : "";

    var hours = microseconds ~/ microsecondsPerHour;
    hours = hours.abs();
    microseconds = microseconds.remainder(microsecondsPerHour);

    if (microseconds < 0) microseconds = -microseconds;

    var minutes = microseconds ~/ microsecondsPerMinute;
    microseconds = microseconds.remainder(microsecondsPerMinute);

    var seconds = microseconds ~/ microsecondsPerSecond;
    microseconds = microseconds.remainder(microsecondsPerSecond);

    var milliseconds = microseconds ~/ microsecondsPerMillisecond;
    microseconds = microseconds.remainder(microsecondsPerMillisecond);

    var hasHour = hours > 0;
    var hasMin = minutes > 0;
    var hasSec = seconds > 0;
    var hasMs = milliseconds > 0;

    var l = [
      if (hasHour) "$sign$hours h",
      if (hasMin || (hasHour && (hasSec || hasMs))) "$minutes min",
      if (hasSec || ((hasHour || hasMin) && (hasSec || hasMs)) ) "$seconds sec",
      if (hasMs) "$milliseconds ms"
    ];

    return l.isEmpty ? '0' : l.join(' ');
  }
}

Duration? tryParseDuration(String? v, [Duration? def]) {
  if (v == null || v.isEmpty) return def;

  var n = int.tryParse(v);
  if (n != null) {
    return Duration(milliseconds: n);
  }

  var s = v.toLowerCase().trim().replaceAll(RegExp(r'\s+'), '');

  n = int.tryParse(s.replaceAll(RegExp(r'\D+'), ''));

  if (n == null) return def;
  if (n == 0) return Duration();

  if (s.endsWith("h") ||
      s.endsWith("hr") ||
      s.endsWith("hs") ||
      s.endsWith("hour") ||
      s.endsWith("hours")) {
    return Duration(hours: n);
  } else if (s.endsWith("ms") ||
      s.endsWith("milliseconds") ||
      s.endsWith("millisecond")) {
    return Duration(milliseconds: n);
  } else if (s.endsWith("min") ||
      s.endsWith("minutes") ||
      s.endsWith("minute")) {
    return Duration(minutes: n);
  } else if (s.endsWith("sec") ||
      s.endsWith("seconds") ||
      s.endsWith("second") ||
      s.endsWith("s")) {
    return Duration(seconds: n);
  } else {
    return def;
  }
}
