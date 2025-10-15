import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:base_codecs/base_codecs.dart' as base_codecs;
import 'package:collection/collection.dart';

import 'reflection_factory_base.dart';
import 'reflection_factory_json.dart';

typedef TypeElementParser<T> = T? Function(Object? o);

/// Lenient parsers for basic Dart types.
class TypeParser {
  /// Returns the parser for the desired type, defined by [T], [obj] or [type].
  static TypeElementParser<T>? parserFor<T>({
    Object? obj,
    Type? type,
    TypeInfo? typeInfo,
  }) => _parserForImpl<T>(obj, type, typeInfo) as TypeElementParser<T>?;

  static TypeElementParser? _parserForImpl<T>(
    Object? obj,
    Type? type,
    TypeInfo? typeInfo,
  ) {
    if (obj != null) {
      var f = _parserForObj(obj);
      if (f != null) return f;
    }

    typeInfo ??= TypeInfo.from(type ?? T);
    return _parserForTypeInfo(typeInfo);
  }

  static TypeElementParser<T>? parserForTypeInfo<T>(TypeInfo typeInfo) =>
      _parserForTypeInfo(typeInfo) as TypeElementParser<T>?;

  static TypeElementParser? _parserForTypeInfo(TypeInfo typeInfo) {
    if (typeInfo.isString) {
      return parseString;
    } else if (typeInfo.isMap) {
      if (typeInfo.argumentsLength == 2) {
        return typeInfo.callCastedArgumentsAB(<K, V>() {
          return parseMap<K, V>;
        });
      }
      return parseMap;
    } else if (typeInfo.isSet) {
      if (typeInfo.argumentsLength == 1) {
        return typeInfo.callCastedArgumentA(<E>() {
          return parseSet<E>;
        });
      }
      return parseSet;
    } else if (typeInfo.isOf(Uint8List)) {
      return parseUInt8List;
    } else if (typeInfo.isList || typeInfo.isIterable) {
      if (typeInfo.argumentsLength == 1) {
        return typeInfo.callCastedArgumentA(<E>() {
          return parseList<E>;
        });
      }
      return parseList;
    } else if (typeInfo.isInt) {
      return parseInt;
    } else if (typeInfo.isDouble) {
      return parseDouble;
    } else if (typeInfo.isNum) {
      return parseNum;
    } else if (typeInfo.isBool) {
      return parseBool;
    } else if (typeInfo.isOf(BigInt)) {
      return parseBigInt;
    } else if (typeInfo.isOf(DateTime)) {
      return parseDateTime;
    } else if (typeInfo.isOf(Duration)) {
      return parseDuration;
    } else {
      return null;
    }
  }

  static TypeElementParser? _parserForObj(Object obj) {
    if (obj is String) {
      return parseString;
    } else if (obj is Map) {
      return parseMap;
    } else if (obj is Set) {
      return parseSet;
    } else if (obj is Uint8List) {
      return parseUInt8List;
    } else if (obj is List || obj is Iterable) {
      return parseList;
    } else if (obj is int) {
      return parseInt;
    } else if (obj is double) {
      return parseDouble;
    } else if (obj is num) {
      return parseNum;
    } else if (obj is bool) {
      return parseBool;
    } else if (obj is BigInt) {
      return parseBigInt;
    } else if (obj is DateTime) {
      return parseDateTime;
    } else if (obj is Duration) {
      return parseDuration;
    } else {
      return null;
    }
  }

  /// Parses [value] using a [parserFor] [type].
  /// Returns [value] if can't parse.
  static V? parseValueForType<V>(Type type, Object? value, [V? def]) {
    if (value == null) return def;

    var typeInfo = TypeInfo.from(type);
    var valueTypeInfo = TypeInfo.from(value);

    if (valueTypeInfo == typeInfo) {
      return value as V;
    }

    var parser = parserFor(typeInfo: typeInfo);

    if (parser != null) {
      var parsed = parser(value);
      return parsed ?? def;
    } else {
      return def;
    }
  }

  static final RegExp _regexpListDelimiter = RegExp(r'\s*[,;]\s*');

  /// Tries to parse a [List].
  /// - Returns [def] if [value] is `null` or an empty [String].
  /// - [elementParser] is an optional parser for the elements of the parsed [List].
  static List<T>? parseList<T>(
    Object? value, {
    List<T>? def,
    TypeElementParser<T>? elementParser,
  }) {
    if (value == null) return def;

    var l = _parseListImpl(value);
    if (l == null) return def;

    if (elementParser != null) {
      l = l.map(elementParser).toList();
    }

    if (l is List<T>) {
      return l;
    } else if (elementParser != null) {
      l = l.whereType<T>().toList();
    } else {
      var parser = parserFor<T>();
      if (parser != null) {
        l = l.map(parser).toList();
      }
    }

    if (l is List<T>) {
      return l;
    } else {
      return l.whereType<T>().toList();
    }
  }

  static List? _parseListImpl<T>(Object value) {
    if (value is List) {
      return value;
    } else if (value is Iterable) {
      return value.toList();
    } else if (value is int) {
      return [value];
    } else if (value is double) {
      return [value];
    } else if (value is bool) {
      return [value];
    } else {
      var s = '$value'.trim();
      if (s.isEmpty) return null;
      var l = s.split(_regexpListDelimiter);
      return l;
    }
  }

  /// Tries to parse a [Set].
  ///
  /// See [parseList].
  static Set<T>? parseSet<T>(
    Object? value, {
    Set<T>? def,
    TypeElementParser<T>? elementParser,
  }) {
    var l = parseList<T>(value, elementParser: elementParser);
    return l?.toSet() ?? def;
  }

  static final RegExp _regexpPairDelimiter = RegExp(r'\s*[;&]\s*');
  static final RegExp _regexpKeyValueDelimiter = RegExp(r'\s*[:=]\s*');

  /// Tries to parse a [Map].
  /// - Returns [def] if [value] is `null` or an empty [String].
  static Map<K, V>? parseMap<K, V>(
    Object? value, {
    Map<K, V>? def,
    TypeElementParser<K>? keyParser,
    TypeElementParser<V>? valueParser,
  }) {
    if (value == null) return def;

    if (value is Map<K, V>) {
      return value;
    }

    keyParser ??= parserFor<K>();
    keyParser ??= (k) => k as K;

    valueParser ??= parserFor<V>();
    valueParser ??= (v) => v as V;

    if (value is Map) {
      return value.map(
        (k, v) => MapEntry(keyParser!(k) as K, valueParser!(v) as V),
      );
    } else if (value is Iterable) {
      return Map.fromEntries(
        value
            .map(
              (e) => parseMapEntry<K, V>(
                e,
                keyParser: keyParser,
                valueParser: valueParser,
              ),
            )
            .nonNulls,
      );
    } else if (value is num) {
      var e = parseMapEntry<K, V>(
        value,
        keyParser: keyParser,
        valueParser: valueParser,
      );
      return Map<K, V>.fromEntries([if (e != null) e]);
    } else {
      var s = '$value'.trim();
      if (s.isEmpty) return def;

      var pairs = s.split(_regexpPairDelimiter);
      return Map.fromEntries(
        pairs
            .map(
              (e) => parseMapEntry<K, V>(
                e,
                keyParser: keyParser,
                valueParser: valueParser,
              ),
            )
            .nonNulls,
      );
    }
  }

  /// Tries to parse a [MapEntry].
  /// - Returns [def] if [value] is `null` or an empty [String].
  static MapEntry<K, V>? parseMapEntry<K, V>(
    Object? value, {
    MapEntry<K, V>? def,
    TypeElementParser<K>? keyParser,
    TypeElementParser<V>? valueParser,
  }) {
    if (value == null) return def;

    if (value is MapEntry<K, V>) {
      return value;
    }

    keyParser ??= parserFor<K>();
    keyParser ??= (k) => k as K;

    valueParser ??= parserFor<V>();
    valueParser ??= (v) => v as V;

    if (value is MapEntry) {
      return MapEntry(keyParser(value.key) as K, valueParser(value.value) as V);
    } else if (value is Iterable) {
      var k = value.elementAt(0);
      var v = value.elementAt(1);
      return MapEntry(keyParser(k) as K, valueParser(v) as V);
    } else if (value is num && value is K && null is V) {
      return MapEntry<K, V>(value as K, null as V);
    } else {
      var s = '$value'.trim();
      if (s.isEmpty) return def;

      var idx = s.indexOf(_regexpKeyValueDelimiter);
      if (idx >= 0) {
        var k = s.substring(0, idx);
        var v = s.substring(idx + 1);
        return MapEntry(keyParser(k) as K, valueParser(v) as V);
      }
      return MapEntry(keyParser(s) as K, null as V);
    }
  }

  /// Tries to parse a [String].
  /// - Returns [def] if [value] is `null`.
  static String? parseString(Object? value, [String? def]) {
    if (value == null) return def;

    if (value is String) {
      return value;
    } else {
      return '$value';
    }
  }

  static final RegExp _regExpNotNumber = RegExp(r'[^\d.+\-eENna]');

  /// Tries to parse an [int].
  /// - Returns [def] if [value] is invalid.
  static int? parseInt(Object? value, [int? def]) {
    if (value == null) return def;

    if (value is int) {
      return value;
    } else if (value is num) {
      return value.toInt();
    } else if (value is DateTime) {
      return value.millisecondsSinceEpoch;
    } else if (value is Duration) {
      return value.inMilliseconds;
    } else {
      var n = _parseNumString(value);
      return n?.toInt() ?? def;
    }
  }

  static num? _parseNumString(Object value) {
    var s = _valueAsString(value);
    if (s.isEmpty) {
      return null;
    }

    var n = num.tryParse(s);
    if (n == null) {
      s = s.replaceAll(_regExpNotNumber, '');
      n = num.tryParse(s);
    }

    return n;
  }

  static String _valueAsString(Object value) {
    String s;
    if (value is String) {
      s = value.trim();
    } else {
      s = '$value'.trim();
    }
    return s;
  }

  /// Tries to parse a [double].
  /// - Returns [def] if [value] is invalid.
  static double? parseDouble(Object? value, [double? def]) {
    if (value == null) return def;

    if (value is double) {
      return value;
    } else if (value is num) {
      return value.toDouble();
    } else if (value is DateTime) {
      return value.millisecondsSinceEpoch.toDouble();
    } else if (value is Duration) {
      return value.inMilliseconds.toDouble();
    } else {
      var n = _parseNumString(value);
      return n?.toDouble() ?? def;
    }
  }

  /// Tries to parse a [num].
  /// - Returns [def] if [value] is invalid.
  static num? parseNum(Object? value, [num? def]) {
    if (value == null) return def;

    if (value is num) {
      return value;
    } else if (value is DateTime) {
      return value.millisecondsSinceEpoch;
    } else if (value is Duration) {
      return value.inMilliseconds;
    } else {
      var n = _parseNumString(value);
      return n ?? def;
    }
  }

  /// Tries to parse a [BigInt].
  /// - Returns [def] if [value] is invalid.
  static BigInt? parseBigInt(Object? value, [BigInt? def]) {
    if (value == null) return def;

    if (value is BigInt) {
      return value;
    } else if (value is num) {
      return BigInt.from(value);
    } else if (value is DateTime) {
      return BigInt.from(value.millisecondsSinceEpoch);
    } else if (value is Duration) {
      return BigInt.from(value.inMilliseconds);
    } else {
      var s = _valueAsString(value);
      if (s.isEmpty) {
        return def;
      }

      var n = BigInt.tryParse(s);
      if (n == null) {
        s = s.replaceAll(_regExpNotNumber, '');
        n = BigInt.tryParse(s);
      }

      return n ?? def;
    }
  }

  /// Tries to parse a [bool].
  /// - Returns [def] if [value] is invalid.
  static bool? parseBool(Object? value, [bool? def]) {
    if (value == null) return def;

    if (value is bool) {
      return value;
    } else if (value is num) {
      return value > 0;
    } else {
      var s = _valueAsString(value).toLowerCase();

      if (s.isEmpty ||
          s == 'null' ||
          s == 'empty' ||
          s == '[]' ||
          s == 'undef' ||
          s == 'undefined') {
        return def;
      }

      if (s == 'true' ||
          s == 't' ||
          s == 'yes' ||
          s == 'y' ||
          s == 's' ||
          s == '1' ||
          s == '+' ||
          s == 'ok' ||
          s == 'on' ||
          s == 'enabled' ||
          s == 'selected' ||
          s == 'checked' ||
          s == 'positive') {
        return true;
      }

      if (s == 'false' ||
          s == 'f' ||
          s == 'no' ||
          s == 'n' ||
          s == '0' ||
          s == '-1' ||
          s == '-' ||
          s == 'fail' ||
          s == 'error' ||
          s == 'err' ||
          s == 'off' ||
          s == 'disabled' ||
          s == 'unselected' ||
          s == 'unchecked' ||
          s == 'negative') {
        return false;
      }

      var n = _parseNumString(value);
      if (n != null) {
        return n > 0;
      }

      return def;
    }
  }

  /// Tries to parse a [DateTime].
  /// - Returns [def] if [value] is invalid.
  static DateTime? parseDateTime(Object? value, [DateTime? def]) {
    if (value == null) return def;

    if (value is DateTime) {
      return value;
    } else if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else {
      var s = '$value'.trim();
      var ms = int.tryParse(s);
      if (ms != null) {
        return DateTime.fromMillisecondsSinceEpoch(ms);
      }
      return DateTime.tryParse(s) ?? def;
    }
  }

  static final RegExp _regexpSpaces = RegExp(r'\s+');
  static final RegExp _regexpTimeSeparators = RegExp(r'[:;,-.]+');

  /// Tries to parse a [Duration].
  /// - Returns [def] if [value] is invalid.
  static Duration? parseDuration(Object? value, [Duration? def]) {
    if (value == null) return def;

    if (value is Duration) {
      return value;
    } else if (value is int) {
      return Duration(milliseconds: value);
    } else {
      var s = '$value'.trim().replaceAll(_regexpSpaces, ':');

      var parts = s.split(_regexpTimeSeparators);

      var ns = parts.map((e) => int.tryParse(e) ?? 0).toList();

      var hour = ns.isNotEmpty ? ns[0] : 0;
      var min = ns.length > 1 ? ns[1] : 0;
      var sec = ns.length > 2 ? ns[2] : 0;
      var ms = ns.length > 3 ? ns[3] : 0;
      var mc = ns.length > 4 ? ns[4] : 0;

      return Duration(
        hours: hour,
        minutes: min,
        seconds: sec,
        milliseconds: ms,
        microseconds: mc,
      );
    }
  }

  /// Tries to parse a [Uint8List].
  /// - Returns [def] if [value] is invalid.
  static Uint8List? parseUInt8List(Object? value, [Uint8List? def]) {
    if (value == null) return def;

    if (value is Uint8List) {
      return value;
    } else if (value is List<int>) {
      return Uint8List.fromList(value);
    } else if (value is Iterable<int>) {
      return Uint8List.fromList(value.toList(growable: false));
    } else if (value is Iterable) {
      var list = value.map((e) => parseInt(e)).toList(growable: false);
      if (list.any((e) => e == null)) {
        return def;
      }
      return Uint8List.fromList(list.cast<int>());
    } else {
      var s = value.toString().trim();

      if (s.isEmpty) return Uint8List(0);

      try {
        var data = base64.decode(s);
        return data;
      } catch (_) {}

      try {
        var data = base_codecs.hex.decode(s);
        return data;
      } catch (_) {}

      return def;
    }
  }

  /// Returns `true` if [type] is primitive ([String], [int], [double], [num] or [bool]).
  static bool isPrimitiveType<T>([Type? type]) {
    type ??= T;
    return TypeInfo.isPrimitiveTypeFor(type);
  }

  /// Returns `true` if [value] is primitive ([String], [int], [double], [num] or [bool]).
  static bool isPrimitiveValue(Object value) {
    if (value is TypeInfo) return value.isPrimitiveType;
    if (value is Type) return isPrimitiveType(value);

    if (value is ParameterReflection) {
      return value.type.typeInfo.isPrimitiveType;
    }

    if (value is TypeReflection) {
      return value.typeInfo.isPrimitiveType;
    }

    return isPrimitiveType(value.runtimeType);
  }

  /// Returns `true` if [type] is [Object] or [dynamic].
  static bool isAnyType<T>([Type? type]) {
    type ??= T;
    return TypeInfo.from(type).isAnyType;
  }

  /// Returns `true` if [type] is a collection ([List], [Iterable], [Map] or [Set]).
  static bool isCollectionType<T>([Type? type]) {
    type ??= T;
    return TypeInfo.from(type).isCollection;
  }

  /// Returns `true` if [value] is a collection ([List], [Iterable], [Map] or [Set]).
  static bool isCollectionValue(Object value) {
    return TypeInfo.from(value).isCollection;
  }
}

enum BasicDartType {
  none,
  object,
  dynamic,
  list,
  set,
  map,
  iterable,
  string,
  int,
  double,
  num,
  bool,
  bigInt,
  dateTime,
  duration,
  uInt8List,
  mapEntry,
  future,
  futureOr,
  voidType,
}

class _TypeWrapper {
  final Type type;

  final BasicDartType basicDartType;

  static BasicDartType detectBasicType(
    Type type, [
    Object? object,
    bool? hasArguments,
  ]) {
    if (type == tString || object is String) return BasicDartType.string;
    if (type == tInt || object is int) return BasicDartType.int;
    if (type == tDouble || object is double) return BasicDartType.double;
    if (type == tNum || object is num) return BasicDartType.num;
    if (type == tBool || object is bool) return BasicDartType.bool;
    if (type == tBigInt || object is BigInt) return BasicDartType.bigInt;
    if (type == tDateTime || object is DateTime) return BasicDartType.dateTime;
    if (type == tDuration || object is Duration) return BasicDartType.duration;

    if (type == tUint8List || object is Uint8List) {
      return BasicDartType.uInt8List;
    }

    if (type == tObject) return BasicDartType.object;
    if (type == tDynamic) {
      if (hasArguments != null && hasArguments) {
        return BasicDartType.futureOr;
      }
      return BasicDartType.dynamic;
    }
    if (type == tVoid) return BasicDartType.voidType;

    if (type == tMap || object is Map) return BasicDartType.map;
    if (type == tSet || object is Set) return BasicDartType.set;
    if (type == tList || object is List) return BasicDartType.list;
    if (type == tIterable || object is Iterable) return BasicDartType.iterable;
    if (type == tMapEntry || object is MapEntry) return BasicDartType.mapEntry;

    if (type == tFuture || object is Future) return BasicDartType.future;

    if (type == tFutureOr) {
      return BasicDartType.futureOr;
    }

    return BasicDartType.none;
  }

  _TypeWrapper._(this.type, this.basicDartType);

  factory _TypeWrapper(
    Type type, {
    BasicDartType? basicType,
    Object? object,
    bool? hasArguments,
  }) {
    basicType ??= detectBasicType(type, object, hasArguments);

    switch (basicType) {
      case BasicDartType.string:
        return _TypeWrapper.twString;
      case BasicDartType.int:
        return _TypeWrapper.twInt;
      case BasicDartType.double:
        return _TypeWrapper.twDouble;
      case BasicDartType.num:
        return _TypeWrapper.twNum;
      case BasicDartType.bool:
        return _TypeWrapper.twBool;

      case BasicDartType.object:
        return _TypeWrapper.twObject;
      case BasicDartType.dynamic:
        return _TypeWrapper.twDynamic;

      case BasicDartType.list:
        return _TypeWrapper.twList;
      case BasicDartType.map:
        return _TypeWrapper.twMap;
      case BasicDartType.iterable:
        return _TypeWrapper.twIterable;
      case BasicDartType.set:
        return _TypeWrapper.twSet;

      case BasicDartType.bigInt:
        return _TypeWrapper.twBigInt;
      case BasicDartType.dateTime:
        return _TypeWrapper.twDateTime;
      case BasicDartType.duration:
        return _TypeWrapper.twDuration;
      case BasicDartType.uInt8List:
        return _TypeWrapper.twUint8List;

      case BasicDartType.mapEntry:
        return _TypeWrapper.twMapEntry;

      case BasicDartType.future:
        return _TypeWrapper.twFuture;
      case BasicDartType.futureOr:
        return _TypeWrapper.twFutureOr;

      case BasicDartType.voidType:
        return _TypeWrapper.twVoid;

      case BasicDartType.none:
        {
          type = detectType(type, object);
          return _TypeWrapper._(type, basicType);
        }
    }
  }

  const _TypeWrapper._const(this.type, this.basicDartType);

  static const _TypeWrapper twString = _TypeWrapperString._const();
  static const _TypeWrapper twInt = _TypeWrapperInt._const();
  static const _TypeWrapper twDouble = _TypeWrapperDouble._const();
  static const _TypeWrapper twNum = _TypeWrapperNum._const();
  static const _TypeWrapper twBool = _TypeWrapperBool._const();
  static const _TypeWrapper twBigInt = _TypeWrapperBigInt._const();
  static const _TypeWrapper twDateTime = _TypeWrapperDateTime._const();
  static const _TypeWrapper twDuration = _TypeWrapperDuration._const();
  static const _TypeWrapper twUint8List = _TypeWrapperUInt8List._const();
  static const _TypeWrapper twList = _TypeWrapperList._const();
  static const _TypeWrapper twSet = _TypeWrapperSet._const();
  static const _TypeWrapper twMap = _TypeWrapperMap._const();
  static const _TypeWrapper twMapEntry = _TypeWrapperMapEntry._const();
  static const _TypeWrapper twIterable = _TypeWrapperIterable._const();
  static const _TypeWrapper twFuture = _TypeWrapperFuture._const();
  static const _TypeWrapper twFutureOr = _TypeWrapperFutureOr._const();
  static const _TypeWrapper twObject = _TypeWrapperObject._const();
  static const _TypeWrapper twDynamic = _TypeWrapperDynamic._const();
  static final _TypeWrapper twVoid = _TypeWrapperVoid._const();

  static const Type tString = String;
  static const Type tInt = int;
  static const Type tDouble = double;
  static const Type tNum = num;
  static const Type tBool = bool;
  static const Type tBigInt = BigInt;
  static const Type tDateTime = DateTime;
  static const Type tDuration = Duration;
  static const Type tUint8List = Uint8List;
  static const Type tList = List;
  static const Type tSet = Set;
  static const Type tMap = Map;
  static const Type tMapEntry = MapEntry;
  static const Type tIterable = Iterable;
  static const Type tFuture = Future;
  static const Type tFutureOr = FutureOr;
  static const Type tObject = Object;
  static const Type tDynamic = dynamic;
  static final Type tVoid = <void>[].listType; // Is there a better way?

  static Type detectType(Type type, [Object? object]) {
    if (type == tString || object is String) return tString;
    if (type == tInt || object is int) return tInt;
    if (type == tDouble || object is double) return tDouble;
    if (type == tNum || object is num) return tNum;
    if (type == tBool || object is bool) return tBool;
    if (type == tBigInt || object is BigInt) return tBigInt;
    if (type == tDateTime || object is DateTime) return tDateTime;
    if (type == tDuration || object is Duration) return tDuration;
    if (type == tUint8List || object is Uint8List) return tUint8List;

    if (type == tObject) return tObject;
    if (type == tDynamic) return tDynamic;
    if (type == tVoid) return tVoid;

    if (type == tMap || object is Map) return tMap;
    if (type == tSet || object is Set) return tSet;
    if (type == tList || object is List) return tList;
    if (type == tIterable || object is Iterable) return tIterable;
    if (type == tMapEntry || object is MapEntry) return tMapEntry;

    if (type == tFuture || object is Future) return tFuture;
    if (type == tFutureOr) return tFutureOr;

    return type;
  }

  /// Returns `true` if [type] is primitive ([bool], [int], [double], [num] or [String]).
  /// - A primitive type uses [_TypeWrapperPrimitive].
  bool get isPrimitiveType => false;

  /// Returns `true` if [type] is a collection ([List], [Iterable], [Map] or [Set]).
  /// - A primitive type uses [_TypeWrapperCollection].
  bool get isCollection => false;

  /// Returns `true` if [type] [isPrimitiveType] or [isCollection].
  bool get isBasicType => false;

  /// Returns `true` if [type] is `Object` or `dynamic`.
  bool get isAnyType => false;

  /// Returns `true` if [type] is `Object`.
  bool get isObject => false;

  /// Returns `true` if [type] is `dynamic`.
  bool get isDynamic => false;

  /// Returns `true` if [type] is `dynamic` or `Object`.
  bool get isDynamicOrObject => false;

  /// Returns `true` if [type] is `void`.
  bool get isVoid => false;

  /// Returns `true` if [type] is `bool`.
  bool get isBool => false;

  /// Returns `true` if [type] is `int`.
  bool get isInt => false;

  /// Returns `true` if [type] is `double`.
  bool get isDouble => false;

  /// Returns `true` if [type] is `num`.
  bool get isNum => false;

  /// Returns `true` if [type] is `int`, `double` or `num`.
  bool get isNumber => false;

  /// Returns `true` if [type] is [BigInt].
  bool get isBigInt => false;

  /// Returns `true` if [type] is [DateTime].
  bool get isDateTime => false;

  /// Returns `true` if [type] is [Duration].
  bool get isDuration => false;

  /// Returns `true` if [type] is [UInt8List].
  bool get isUInt8List => false;

  /// Returns `true` if [type] is `String`.
  bool get isString => false;

  /// Returns `true` if [type] is a [List].
  bool get isList => false;

  /// Returns `true` if [type] is a [Iterable].
  bool get isIterable => false;

  /// Returns `true` if [type] is a [Map].
  bool get isMap => false;

  /// Returns `true` if [type] is a [MapEntry].
  bool get isMapEntry => false;

  /// Returns `true` if [type] is a [Set].
  bool get isSet => false;

  /// Returns `true` if [type] is a [Future].
  bool get isFuture => false;

  /// Returns `true` if [type] is a [FutureOr].
  bool get isFutureOr => false;

  /// Parses [value].
  V? parse<V>(Object? value, {V? def, TypeInfo? typeInfo}) {
    if (value == null) return def;

    if (value.runtimeType == type) {
      return value as V;
    }

    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _TypeWrapper &&
          runtimeType == other.runtimeType &&
          ((basicDartType != BasicDartType.none &&
                  basicDartType == other.basicDartType) ||
              type == other.type);

  @override
  int get hashCode =>
      (basicDartType != BasicDartType.none ? type.hashCode : 0) ^
      basicDartType.hashCode;

  @override
  String toString() {
    return '_TypeWrapper{type: $type, basicDartType: $basicDartType}';
  }
}

class _TypeWrapperObject extends _TypeWrapper {
  const _TypeWrapperObject._const()
    : super._const(_TypeWrapper.tObject, BasicDartType.object);

  @override
  bool get isObject => true;

  @override
  bool get isDynamicOrObject => true;

  @override
  bool get isAnyType => true;
}

class _TypeWrapperDynamic extends _TypeWrapper {
  const _TypeWrapperDynamic._const()
    : super._const(_TypeWrapper.tDynamic, BasicDartType.dynamic);

  @override
  bool get isDynamic => true;

  @override
  bool get isDynamicOrObject => true;

  @override
  bool get isAnyType => true;
}

abstract class _TypeWrapperPrimitive extends _TypeWrapper {
  const _TypeWrapperPrimitive._const(super.type, super.basicDartType)
    : super._const();

  @override
  bool get isPrimitiveType => true;

  @override
  bool get isBasicType => true;
}

class _TypeWrapperString extends _TypeWrapperPrimitive {
  const _TypeWrapperString._const()
    : super._const(_TypeWrapper.tString, BasicDartType.string);

  @override
  bool get isString => true;

  @override
  V? parse<V>(Object? value, {V? def, TypeInfo? typeInfo}) =>
      TypeParser.parseString(value, def as String?) as V?;
}

class _TypeWrapperBool extends _TypeWrapperPrimitive {
  const _TypeWrapperBool._const()
    : super._const(_TypeWrapper.tBool, BasicDartType.bool);

  @override
  bool get isBool => true;

  @override
  V? parse<V>(Object? value, {V? def, TypeInfo? typeInfo}) =>
      TypeParser.parseBool(value, def as bool?) as V?;
}

abstract class _TypeWrapperNumber extends _TypeWrapperPrimitive {
  const _TypeWrapperNumber._const(super.type, super.basicDartType)
    : super._const();

  @override
  bool get isNumber => true;
}

class _TypeWrapperInt extends _TypeWrapperNumber {
  const _TypeWrapperInt._const()
    : super._const(_TypeWrapper.tInt, BasicDartType.int);

  @override
  bool get isInt => true;

  @override
  V? parse<V>(Object? value, {V? def, TypeInfo? typeInfo}) =>
      TypeParser.parseInt(value, def as int?) as V?;
}

class _TypeWrapperDouble extends _TypeWrapperNumber {
  const _TypeWrapperDouble._const()
    : super._const(_TypeWrapper.tDouble, BasicDartType.double);

  @override
  bool get isDouble => true;

  @override
  V? parse<V>(Object? value, {V? def, TypeInfo? typeInfo}) =>
      TypeParser.parseDouble(value, def as double?) as V?;
}

class _TypeWrapperNum extends _TypeWrapperNumber {
  const _TypeWrapperNum._const()
    : super._const(_TypeWrapper.tNum, BasicDartType.num);

  @override
  bool get isNum => true;

  @override
  V? parse<V>(Object? value, {V? def, TypeInfo? typeInfo}) =>
      TypeParser.parseNum(value, def as num?) as V?;
}

abstract class _TypeWrapperCollection extends _TypeWrapper {
  const _TypeWrapperCollection._const(super.type, super.basicDartType)
    : super._const();

  @override
  bool get isCollection => true;

  @override
  bool get isBasicType => true;
}

class _TypeWrapperList extends _TypeWrapperCollection {
  const _TypeWrapperList._const()
    : super._const(_TypeWrapper.tList, BasicDartType.list);

  @override
  bool get isList => true;

  @override
  V? parse<V>(Object? value, {V? def, TypeInfo? typeInfo}) {
    if (typeInfo != null && typeInfo.argumentsLength >= 1) {
      return typeInfo.callCastedArgumentA(
        <A>() =>
            TypeParser.parseList<A>(
                  value,
                  elementParser: typeInfo.argumentParser<A>(0),
                )
                as V?,
      );
    } else {
      return TypeParser.parseList(value) as V?;
    }
  }
}

class _TypeWrapperIterable extends _TypeWrapperCollection {
  const _TypeWrapperIterable._const()
    : super._const(_TypeWrapper.tIterable, BasicDartType.iterable);

  @override
  bool get isIterable => true;

  @override
  V? parse<V>(Object? value, {V? def, TypeInfo? typeInfo}) {
    if (typeInfo != null && typeInfo.argumentsLength >= 1) {
      return typeInfo.callCastedArgumentA(<A>() {
        if (value is Iterable<A>) {
          return value as V?;
        } else if (value is Iterable) {
          var elementParser = typeInfo.argumentParser<A>(0);
          if (elementParser != null) {
            return value.map(elementParser).whereType<A>() as V?;
          } else {
            return value.whereType<A>() as V?;
          }
        } else {
          return TypeParser.parseList<A>(
                value,
                elementParser: typeInfo.argumentParser<A>(0),
              )
              as V?;
        }
      });
    } else {
      if (value is Iterable) {
        return value as V?;
      } else {
        return TypeParser.parseList(value) as V?;
      }
    }
  }
}

class _TypeWrapperMap extends _TypeWrapperCollection {
  const _TypeWrapperMap._const()
    : super._const(_TypeWrapper.tMap, BasicDartType.map);

  @override
  bool get isMap => true;

  @override
  V? parse<V>(Object? value, {V? def, TypeInfo? typeInfo}) {
    if (typeInfo != null) {
      if (typeInfo.argumentsLength >= 2) {
        return typeInfo.callCastedArgumentsAB(
          <A, B>() =>
              TypeParser.parseMap<A, B>(
                    value,
                    keyParser: typeInfo.argumentParser<A>(0),
                    valueParser: typeInfo.argumentParser<B>(1),
                  )
                  as V?,
        );
      } else {
        return TypeParser.parseMap(
              value,
              keyParser: typeInfo.argumentParser(0),
              valueParser: typeInfo.argumentParser(1),
            )
            as V?;
      }
    } else {
      return TypeParser.parseMap(value) as V?;
    }
  }
}

class _TypeWrapperSet extends _TypeWrapperCollection {
  const _TypeWrapperSet._const()
    : super._const(_TypeWrapper.tSet, BasicDartType.set);

  @override
  bool get isSet => true;

  @override
  V? parse<V>(Object? value, {V? def, TypeInfo? typeInfo}) {
    if (typeInfo != null && typeInfo.argumentsLength >= 1) {
      return typeInfo.callCastedArgumentA(
        <A>() =>
            TypeParser.parseSet<A>(
                  value,
                  elementParser: typeInfo.argumentParser<A>(0),
                )
                as V?,
      );
    } else {
      return TypeParser.parseSet(value) as V?;
    }
  }
}

abstract class _TypeWrapperAsync extends _TypeWrapper {
  const _TypeWrapperAsync._const(super.type, super.basicDartType)
    : super._const();
}

class _TypeWrapperFuture extends _TypeWrapperAsync {
  const _TypeWrapperFuture._const()
    : super._const(_TypeWrapper.tFuture, BasicDartType.future);

  @override
  bool get isFuture => true;
}

class _TypeWrapperFutureOr extends _TypeWrapperAsync {
  const _TypeWrapperFutureOr._const()
    : super._const(_TypeWrapper.tFutureOr, BasicDartType.futureOr);

  @override
  bool get isFutureOr => true;
}

class _TypeWrapperBigInt extends _TypeWrapper {
  const _TypeWrapperBigInt._const()
    : super._const(_TypeWrapper.tBigInt, BasicDartType.bigInt);

  @override
  bool get isBigInt => true;

  @override
  V? parse<V>(Object? value, {V? def, TypeInfo? typeInfo}) =>
      TypeParser.parseBigInt(value, def as BigInt?) as V?;
}

class _TypeWrapperMapEntry extends _TypeWrapper {
  const _TypeWrapperMapEntry._const()
    : super._const(_TypeWrapper.tMapEntry, BasicDartType.mapEntry);

  @override
  bool get isMapEntry => true;

  @override
  V? parse<V>(Object? value, {V? def, TypeInfo? typeInfo}) {
    if (typeInfo != null) {
      if (typeInfo.argumentsLength >= 2) {
        return typeInfo.callCastedArgumentsAB(
          <A, B>() =>
              TypeParser.parseMapEntry<A, B>(
                    value,
                    keyParser: typeInfo.argumentParser<A>(0),
                    valueParser: typeInfo.argumentParser<B>(1),
                  )
                  as V?,
        );
      } else {
        return TypeParser.parseMapEntry(
              value,
              keyParser: typeInfo.argumentParser(0),
              valueParser: typeInfo.argumentParser(1),
            )
            as V?;
      }
    } else {
      return TypeParser.parseMapEntry(value) as V?;
    }
  }
}

class _TypeWrapperDateTime extends _TypeWrapper {
  const _TypeWrapperDateTime._const()
    : super._const(_TypeWrapper.tDateTime, BasicDartType.dateTime);

  @override
  bool get isDateTime => true;

  @override
  V? parse<V>(Object? value, {V? def, TypeInfo? typeInfo}) =>
      TypeParser.parseDateTime(value, def as DateTime?) as V?;
}

class _TypeWrapperDuration extends _TypeWrapper {
  const _TypeWrapperDuration._const()
    : super._const(_TypeWrapper.tDuration, BasicDartType.duration);

  @override
  bool get isDuration => true;

  @override
  V? parse<V>(Object? value, {V? def, TypeInfo? typeInfo}) =>
      TypeParser.parseDuration(value, def as Duration?) as V?;
}

class _TypeWrapperUInt8List extends _TypeWrapper {
  const _TypeWrapperUInt8List._const()
    : super._const(_TypeWrapper.tUint8List, BasicDartType.uInt8List);

  @override
  bool get isUInt8List => true;

  @override
  V? parse<V>(Object? value, {V? def, TypeInfo? typeInfo}) =>
      TypeParser.parseUInt8List(value, def as Uint8List?) as V?;
}

class _TypeWrapperVoid extends _TypeWrapper {
  _TypeWrapperVoid._const()
    : super._const(_TypeWrapper.tVoid, BasicDartType.voidType);

  @override
  bool get isVoid => true;
}

class TypeInfoEquality implements Equality<TypeInfo> {
  const TypeInfoEquality();

  @override
  bool equals(TypeInfo e1, TypeInfo e2) => e1 == e2;

  @override
  int hash(TypeInfo e) => e.hashCode;

  @override
  bool isValidKey(Object? o) => o is TypeInfo;
}

class TypeInfoEquivalency implements Equality<TypeInfo> {
  const TypeInfoEquivalency();

  @override
  bool equals(TypeInfo e1, TypeInfo e2) => e1.isEquivalent(e2);

  @override
  int hash(TypeInfo e) => e.hashCode;

  @override
  bool isValidKey(Object? o) => o is TypeInfo;
}

class TypeEquality implements Equality<Type> {
  const TypeEquality();

  @override
  bool equals(Type e1, Type e2) {
    var t1 = TypeInfo.from(e1);
    var t2 = TypeInfo.from(e2);
    return t1 == t2;
  }

  @override
  int hash(Type e) {
    var t = TypeInfo.from(e);
    return t.hashCode;
  }

  @override
  bool isValidKey(Object? o) => o is Type;
}

class TypeEquivalency implements Equality<Type> {
  const TypeEquivalency();

  @override
  bool equals(Type e1, Type e2) {
    var t1 = TypeInfo.from(e1);
    var t2 = TypeInfo.from(e2);
    return t1.isEquivalent(t2);
  }

  @override
  int hash(Type e) {
    var t = TypeInfo.from(e);
    return t.hashCode;
  }

  @override
  bool isValidKey(Object? o) => o is Type;
}

class TypeInfoListEquality extends ListEquality<TypeInfo> {
  const TypeInfoListEquality() : super(const TypeInfoEquality());
}

class TypeInfoListEquivalency extends ListEquality<TypeInfo> {
  const TypeInfoListEquivalency() : super(const TypeInfoEquivalency());
}

class TypeListEquality extends ListEquality<Type> {
  const TypeListEquality() : super(const TypeEquality());
}

/// Represents a [Type] and its [arguments].
class TypeInfo<T> {
  /// Returns `true` if [T] accepts a value of [type].
  static bool accepts<T>(Type type) {
    return T == type || T == Object || T == dynamic;
  }

  /// Converts [list] to a [List] of [TypeInfo].
  static List<TypeInfo> toList(Iterable<Object> list, {bool growable = false}) {
    return list.map((e) => TypeInfo.from(e)).toList(growable: growable);
  }

  /// Returns `true` if [List] of [Type] [a] is equals to [b].
  static bool equalsTypeList(List<Type> a, List<Type> b) =>
      equalsTypeInfoList(toList(a), toList(b));

  /// Returns `true` if [List] of [TypeInfo] [a] is equals to [b].
  static bool equalsTypeInfoList(List<TypeInfo> a, List<TypeInfo> b) =>
      _listEqualityTypeInfo.equals(a, b);

  /// Returns `true` if [List] of [Type] [a] is equivalent to [b].
  ///
  /// See [isEquivalent].
  static bool equivalentTypeList(List<Type> a, List<Type> b) =>
      equivalentTypeInfoList(toList(a), toList(b));

  /// Returns `true` if [List] of [TypeInfo] [a] is equivalent to [b].
  ///
  /// See [isEquivalent].
  static bool equivalentTypeInfoList(List<TypeInfo> a, List<TypeInfo> b) =>
      _listEquivalencyTypeInfo.equals(a, b);

  static const TypeInfo<String> tString = TypeInfo._const(
    _TypeWrapper.twString,
  );
  static const TypeInfo<bool> tBool = TypeInfo._const(_TypeWrapper.twBool);
  static const TypeInfo<int> tInt = TypeInfo._const(_TypeWrapper.twInt);
  static const TypeInfo<double> tDouble = TypeInfo._const(
    _TypeWrapper.twDouble,
  );
  static const TypeInfo<num> tNum = TypeInfo._const(_TypeWrapper.twNum);
  static const TypeInfo<BigInt> tBigInt = TypeInfo._const(
    _TypeWrapper.twBigInt,
  );
  static const TypeInfo<DateTime> tDateTime = TypeInfo._const(
    _TypeWrapper.twDateTime,
  );
  static const TypeInfo<Duration> tDuration = TypeInfo._const(
    _TypeWrapper.twDuration,
  );
  static const TypeInfo<Uint8List> tUint8List = TypeInfo._const(
    _TypeWrapper.twUint8List,
  );

  static const TypeInfo<List> tList = TypeInfo._const(_TypeWrapper.twList);
  static const TypeInfo<Set> tSet = TypeInfo._const(_TypeWrapper.twSet);
  static const TypeInfo<Map> tMap = TypeInfo._const(_TypeWrapper.twMap);
  static const TypeInfo<Map> tMapEntry = TypeInfo._const(
    _TypeWrapper.twMapEntry,
  );
  static const TypeInfo<Iterable> tIterable = TypeInfo._const(
    _TypeWrapper.twIterable,
  );

  static const TypeInfo<Future> tFuture = TypeInfo._const(
    _TypeWrapper.twFuture,
  );
  static const TypeInfo<FutureOr> tFutureOr = TypeInfo._const(
    _TypeWrapper.twFutureOr,
  );

  static const TypeInfo<Object> tObject = TypeInfo._const(
    _TypeWrapper.twObject,
  );
  static const TypeInfo<dynamic> tDynamic = TypeInfo._const(
    _TypeWrapper.twDynamic,
  );
  static final TypeInfo<void> tVoid = TypeInfo._wrapper(_TypeWrapper.twVoid);

  final _TypeWrapper _typeWrapper;

  /// The main [Type].
  Type get type => _typeWrapper.type;

  /// The generic `T` [Type].
  Type get genericType => T;

  /// Returns `true` if [genericType] matches [type].
  bool get isValidGenericType {
    var genericType = this.genericType;
    var type = this.type;

    if (genericType == type) {
      return true;
    }

    if (hasArguments) {
      if (isIterable) {
        var arg = _arguments[0];
        var valid = arg.isValidGenericType;
        if (valid) {
          TypeInfo<Iterable> iterableTypeInfo;
          if (isSet) {
            iterableTypeInfo = arg.toSetType();
          } else if (isList) {
            iterableTypeInfo = arg.toListType();
          } else {
            iterableTypeInfo = arg.toIterableType();
          }

          var genericType2 = iterableTypeInfo.genericType;
          if (genericType2 == genericType) {
            return true;
          }
        }
      } else if (isMap || isMapEntry) {
        var arg0 = _arguments[0];
        var arg1 = _arguments[1];

        var valid = arg0.isValidGenericType && arg1.isValidGenericType;
        if (valid) {
          var typeInfo = isMapEntry
              ? arg0.toMapEntryType(arg1)
              : arg0.toMapType(arg1);
          var genericType2 = typeInfo.genericType;
          if (genericType2 == genericType) {
            return true;
          }
        }
      }
    }

    return false;
  }

  /// Returns the [type] name.
  String get typeName {
    if (isFutureOr) {
      return 'FutureOr';
    }

    var typeStr = type.toString();
    typeStr = removeTypeGenerics(typeStr);

    return typeStr;
  }

  static final RegExp _regexpGenerics = RegExp(r"<[^<>]+>");

  /// Removes generics from the type or record type string.
  static String removeTypeGenerics(String type) {
    while (true) {
      var type2 = type.replaceAll(_regexpGenerics, '');

      if (type2.length == type.length) {
        return type;
      } else {
        type = type2;
      }
    }
  }

  /// The [type] arguments (generics).
  final List<TypeInfo> _arguments;

  List<TypeInfo> get arguments => _arguments is UnmodifiableListView<TypeInfo>
      ? _arguments
      : UnmodifiableListView<TypeInfo>(_arguments);

  static const _emptyArguments = <TypeInfo>[];

  TypeInfo(Type type, [Iterable<Object>? arguments])
    : this._(type, arguments, null);

  TypeInfo._(
    Type type, [
    Iterable<Object>? arguments,
    Object? object,
    _TypeWrapper? typeWrapper,
  ]) : _typeWrapper =
           typeWrapper ??
           _TypeWrapper(
             type,
             object: object,
             hasArguments: arguments != null && arguments.isNotEmpty,
           ),
       _arguments = arguments == null || arguments.isEmpty
           ? _emptyArguments
           : List<TypeInfo>.unmodifiable(
               arguments.map((o) => TypeInfo.from(o)),
             );

  const TypeInfo._wrapper(this._typeWrapper) : _arguments = _emptyArguments;

  const TypeInfo._const(this._typeWrapper) : _arguments = _emptyArguments;

  factory TypeInfo.from(
    Object o, [
    Iterable<Object>? arguments,
    Object? object,
  ]) {
    if (o is TypeInfo) return o as TypeInfo<T>;
    if (o is Type) return TypeInfo<T>.fromType(o, arguments, object);

    if (o is ParameterReflection) {
      return o.type.typeInfo as TypeInfo<T>;
    }

    if (o is TypeReflection) {
      return o.typeInfo as TypeInfo<T>;
    }

    if (o is T) {
      return TypeInfo<T>.fromObject(o as T, arguments, object);
    } else {
      return TypeInfo<T>.fromType(o.runtimeType, arguments, object ?? o);
    }
  }

  factory TypeInfo.fromObject(
    T o, [
    Iterable<Object>? arguments,
    Object? object,
  ]) {
    if (arguments == null || arguments.isEmpty) {
      return TypeInfo<T>.fromType(o.runtimeType, null, object ?? o);
    }

    return TypeInfo<T>.fromType(o.runtimeType, arguments, object ?? o);
  }

  factory TypeInfo.fromListType(Object listType) {
    var t = TypeInfo.from(listType);
    return TypeInfo<T>.fromType(List, [t]);
  }

  factory TypeInfo.fromSetType(Object setType) {
    var t = TypeInfo.from(setType);
    return TypeInfo<T>.fromType(Set, [t]);
  }

  factory TypeInfo.fromIterableType(Object itrType) {
    var t = TypeInfo.from(itrType);
    return TypeInfo<T>.fromType(Iterable, [t]);
  }

  factory TypeInfo.fromMapType(Object keyType, Object valueType) {
    var k = TypeInfo.from(keyType);
    var v = TypeInfo.from(valueType);
    return TypeInfo<T>.fromType(Map, [k, v]);
  }

  factory TypeInfo.fromType(
    Type type, [
    Iterable<Object>? arguments,
    Object? object,
  ]) {
    if (type == _TypeWrapper.tString || object is String) {
      return tString as TypeInfo<T>;
    }
    if (type == _TypeWrapper.tInt || object is int) return tInt as TypeInfo<T>;
    if (type == _TypeWrapper.tDouble || object is double) {
      return tDouble as TypeInfo<T>;
    }
    if (type == _TypeWrapper.tNum || object is num) return tNum as TypeInfo<T>;
    if (type == _TypeWrapper.tBool || object is bool) {
      return tBool as TypeInfo<T>;
    }
    if (type == _TypeWrapper.tBigInt || object is BigInt) {
      return tBigInt as TypeInfo<T>;
    }
    if (type == _TypeWrapper.tDateTime || object is DateTime) {
      return tDateTime as TypeInfo<T>;
    }
    if (type == _TypeWrapper.tDuration || object is Duration) {
      return tDuration as TypeInfo<T>;
    }
    if (type == _TypeWrapper.tUint8List || object is Uint8List) {
      return tUint8List as TypeInfo<T>;
    }

    if (type == _TypeWrapper.tObject) return tObject as TypeInfo<T>;

    var hasArguments = arguments != null && arguments.isNotEmpty;

    if (type == _TypeWrapper.tDynamic) {
      // A FutureOr is a `dynamic` with arguments:
      if (hasArguments) {
        return TypeInfo._(
          _TypeWrapper.tFutureOr,
          arguments,
          object,
          TypeInfo.tFutureOr._typeWrapper,
        );
      } else {
        return tDynamic as TypeInfo<T>;
      }
    }

    if (type == _TypeWrapper.tFuture) {
      if (hasArguments) {
        return TypeInfo._(
          _TypeWrapper.tFuture,
          arguments,
          object,
          TypeInfo.tFuture._typeWrapper,
        );
      } else {
        return TypeInfo.tFuture as TypeInfo<T>;
      }
    }

    if (type == _TypeWrapper.tVoid) return tVoid as TypeInfo<T>;

    if (arguments == null || arguments.isEmpty) {
      if (type == _TypeWrapper.tList || object is List) {
        return tList as TypeInfo<T>;
      }
      if (type == _TypeWrapper.tSet || object is Set) {
        return tSet as TypeInfo<T>;
      }
      if (type == _TypeWrapper.tMap || object is Map) {
        return tMap as TypeInfo<T>;
      }
      if (type == _TypeWrapper.tIterable || object is Iterable) {
        return tIterable as TypeInfo<T>;
      }

      if (type == _TypeWrapper.tFuture || object is Future) {
        return tFuture as TypeInfo<T>;
      }
    }

    return TypeInfo<T>._(type, arguments, object);
  }

  static bool isPrimitiveTypeFor(Type type) {
    return type == _TypeWrapper.tString ||
        type == _TypeWrapper.tInt ||
        type == _TypeWrapper.tDouble ||
        type == _TypeWrapper.tNum ||
        type == _TypeWrapper.tBool;
  }

  /// Calls [f] casting [T].
  R callCasted<R>(R Function<E>() f) {
    return f<T>();
  }

  /// Calls [f] casting [A] as [arguments0] `T`.
  // ignore: avoid_types_as_parameter_names
  R callCastedArgumentA<R, A>(R Function<A>() f) {
    var arg0 = _arguments[0];
    return arg0.callCasted(f);
  }

  /// Calls [f] casting [A] as [arguments0] `T` and [B] as [arguments1] `T`.
  // ignore: avoid_types_as_parameter_names
  R callCastedArgumentsAB<R, A, B>(R Function<A, B>() f) {
    var arg0 = _arguments[0];
    var arg1 = _arguments[1];
    // ignore: avoid_types_as_parameter_names
    return arg0.callCasted(<A>() {
      // ignore: avoid_types_as_parameter_names
      return arg1.callCasted(<B>() => f<A, B>());
    });
  }

  /// Returns `this` as a [TypeInfo] for `List<T>`.
  TypeInfo<List<T>> toListType() => TypeInfo.fromType(List, [this]);

  /// Returns `this` as a [TypeInfo] for `Set<T>`.
  TypeInfo<Set<T>> toSetType() => TypeInfo.fromType(Set, [this]);

  /// Returns `this` as a [TypeInfo] for `Iterable<T>`.
  TypeInfo<Iterable<T>> toIterableType() => TypeInfo.fromType(Iterable, [this]);

  /// Returns `this` as a [TypeInfo] for `Map<K,T>`.
  TypeInfo<Map<K, T>> toMapValueType<K>({TypeInfo? keyType}) {
    keyType ??= TypeInfo.fromType(K);
    return TypeInfo.fromType(Map, [keyType, this]);
  }

  /// Returns `this` as a [TypeInfo] for `Map<T,V>`.
  TypeInfo<Map<T, V>> toMapKeyType<V>({TypeInfo? valueType}) {
    valueType ??= TypeInfo.fromType(V);
    return TypeInfo.fromType(Map, [this, valueType]);
  }

  /// Returns `this` as a [TypeInfo] for `Map<T,V>` ensuring that `V` is the same as [valueType].
  TypeInfo<Map<T, V>> toMapType<V>(TypeInfo valueType) {
    return valueType.callCasted(<E>() {
      return toMapKeyType<E>(valueType: valueType) as TypeInfo<Map<T, V>>;
    });
  }

  /// Returns `this` as a [TypeInfo] for `MapEntry<K,T>`.
  TypeInfo<MapEntry<K, T>> toMapEntryValueType<K>({TypeInfo? keyType}) {
    keyType ??= TypeInfo.fromType(K);
    return TypeInfo.fromType(MapEntry, [keyType, this]);
  }

  /// Returns `this` as a [TypeInfo] for `MapEntry<T,V>`.
  TypeInfo<MapEntry<T, V>> toMapEntryKeyType<V>({TypeInfo? valueType}) {
    valueType ??= TypeInfo.fromType(V);
    return TypeInfo.fromType(MapEntry, [this, valueType]);
  }

  /// Returns `this` as a [TypeInfo] for `MapEntry<T,V>` ensuring that `V` is the same as [valueType].
  TypeInfo<MapEntry<T, V>> toMapEntryType<V>(TypeInfo valueType) {
    return valueType.callCasted(<E>() {
      return toMapEntryKeyType<E>(valueType: valueType)
          as TypeInfo<MapEntry<T, V>>;
    });
  }

  /// Returns `true` if `this`.[type] equals to [other].[type].
  ///
  /// Resolves some [Type] singleton issues with [List], [Set] and [Map].
  bool equalsType(TypeInfo? other) => _typeWrapper == other?._typeWrapper;

  /// Returns `true` if [equalsType] and [equalsArgumentsTypes] are `true`.
  bool equalsTypeAndArguments(TypeInfo other) =>
      equalsType(other) && equalsArgumentsTypes(other._arguments);

  /// The [arguments] length.
  int get argumentsLength => _arguments.length;

  /// Returns `true` if [type] has [arguments].
  bool get hasArguments => _arguments.isNotEmpty;

  /// Returns the [TypeInfo] of the argument at [index].
  TypeInfo? argumentType(int index) =>
      index < argumentsLength ? _arguments[index] : null;

  /// Returns `true` if [arguments] have equals [types].
  bool equalsArgumentsTypes(List<Object> types) {
    var arguments = _arguments;
    if (arguments.isEmpty) {
      return types.isEmpty;
    }

    if (arguments.length != types.length) {
      return false;
    }

    return _listEqualityTypeInfo.equals(
      arguments,
      TypeInfo.toList(types, growable: false),
    );
  }

  /// Returns `true` if [arguments] have equivalent [types].
  bool equivalentArgumentsTypes(List<Object> types) {
    var arguments = _arguments;
    if (arguments.isEmpty) {
      return types.isEmpty;
    }

    if (arguments.length != types.length) {
      return false;
    }

    return _listEquivalencyTypeInfo.equals(arguments, TypeInfo.toList(types));
  }

  /// Returns the [type] parser.
  ///
  /// See [TypeParser.parserForTypeInfo].
  TypeElementParser<T>? get parser => TypeParser.parserForTypeInfo<T>(this);

  /// Returns the parser of the argument at [index].
  TypeElementParser<A>? argumentParser<A>(int index) => index < argumentsLength
      ? _arguments[index].parser as TypeElementParser<A>?
      : null;

  /// Parse [value] or return [def].
  ///
  /// See [TypeParser.parserFor].
  V? parse<V>(Object? value, [V? def]) =>
      _typeWrapper.parse(value, def: def, typeInfo: this);

  /// Same as [parse] but if `this` [isFuture] it will traverse
  /// to the [Future] argument.
  V? parseTraversingFuture<V>(Object? value, [V? def]) {
    if (isFuture) {
      var argument = argumentType(0);
      if (argument != null) {
        return argument.parse<V>(value);
      }
    }

    return parse<V>(value);
  }

  /// Returns `true` if [type] is primitive ([bool], [int], [double], [num] or [String]).
  bool get isPrimitiveType => _typeWrapper.isPrimitiveType;

  /// Returns `true` if [type] [isPrimitiveType] or [isDynamicOrObject].
  bool get isPrimitiveOrDynamicOrObjectType =>
      _typeWrapper.isPrimitiveType || _typeWrapper.isDynamicOrObject;

  /// Returns `true` if [type] is a collection ([List], [Iterable], [Map] or [Set]).
  bool get isCollection => _typeWrapper.isCollection;

  /// Returns `true` if [type] [isPrimitiveType] or [isCollection].
  bool get isBasicType => _typeWrapper.isBasicType;

  /// Returns `true` if [type] is `Object` or `dynamic`.
  bool get isAnyType => _typeWrapper.isAnyType;

  /// Returns `true` if [type] is `Object`.
  bool get isObject => _typeWrapper.isObject;

  /// Returns `true` if [type] is `dynamic`.
  bool get isDynamic => _typeWrapper.isDynamic;

  /// Returns `true` if [type] is `dynamic` or `Object`.
  bool get isDynamicOrObject => _typeWrapper.isDynamicOrObject;

  /// Returns `true` if [type] is `bool`.
  bool get isBool => _typeWrapper.isBool;

  /// Returns `true` if [type] is `int`.
  bool get isInt => _typeWrapper.isInt;

  /// Returns `true` if [type] is `double`.
  bool get isDouble => _typeWrapper.isDouble;

  /// Returns `true` if [type] is `num`.
  bool get isNum => _typeWrapper.isNum;

  /// Returns `true` if [type] is `int`, `double` or `num`.
  bool get isNumber => _typeWrapper.isNumber;

  /// Returns `true` if [type] is [BigInt].
  bool get isBigInt => _typeWrapper.isBigInt;

  /// Returns `true` if [type] is [DateTime].
  bool get isDateTime => _typeWrapper.isDateTime;

  /// Returns `true` if [type] is [Duration].
  bool get isDuration => _typeWrapper.isDuration;

  /// Returns `true` if [type] is [Uint8List].
  bool get isUInt8List => _typeWrapper.isUInt8List;

  /// Returns `true` if [type] is `String`.
  bool get isString => _typeWrapper.isString;

  /// Returns `true` if [type] is a [List].
  bool get isList => _typeWrapper.isList;

  /// Returns `true` if [type] is a [Set].
  bool get isSet => _typeWrapper.isSet;

  /// Returns `true` if [type] is a [Iterable].
  bool get isIterable =>
      _typeWrapper.isIterable || _typeWrapper.isList || _typeWrapper.isSet;

  /// Returns `true` if [type] is a [Map].
  bool get isMap => _typeWrapper.isMap;

  /// Returns `true` if [type] is a [MapEntry].
  bool get isMapEntry => _typeWrapper.isMapEntry;

  /// Returns `true` if [type] is a [Future].
  bool get isFuture => _typeWrapper.isFuture;

  /// Returns `true` if [type] is a [FutureOr].
  bool get isFutureOr => _typeWrapper.isFutureOr;

  /// Returns `true` if [type] is `void`.
  bool get isVoid => _typeWrapper.isVoid;

  /// Returns `true` if [type] can be an entity (![isDynamicOrObject] && ![isBasicType]).
  bool get isEntityType => !isDynamicOrObject && !isBasicType;

  /// Returns `true` if [type] is a [List] of entities.
  bool get isListEntity =>
      isList && hasArguments && _arguments.first.isEntityType;

  /// The [TypeInfo] of the [List] elements type.
  TypeInfo? get listEntityType => isListEntity ? _arguments.first : null;

  /// Returns this instance as [TypeReflection].
  TypeReflection get asTypeReflection => TypeReflection<T>(
    type,
    _arguments.map((e) => e.asTypeReflection).toList(growable: false),
  );

  /// Returns `true` if this instances has the same [type] and [arguments].
  bool isOf(Type type, [List<Object>? arguments]) {
    var t = TypeInfo.from(type);

    if (!equalsType(t)) return false;

    if (arguments != null) {
      if (hasArguments) {
        return argumentsLength == arguments.length &&
            _listEqualityTypeInfo.equals(
              _arguments,
              TypeInfo.toList(arguments),
            );
      } else {
        return arguments.isEmpty;
      }
    } else {
      return true;
    }
  }

  /// Checks for equality, [other] should be exactly the same.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TypeInfo &&
          _typeWrapper == other._typeWrapper &&
          _listEqualityTypeInfo.equals(_arguments, other._arguments);

  /// Checks for equivalence, if the instances are similar:
  /// - `Object` and `dynamic` are equivalent.
  /// - A type without arguments will be the equivalent of one with only `dynamic` and `Object` arguments.
  ///
  /// NOTE: Equality from operator [==] will check if [other] is exactly the same.
  bool isEquivalent(TypeInfo other) {
    if (identical(this, other)) return true;

    if (_typeWrapper != other._typeWrapper) {
      if (_typeWrapper.isDynamicOrObject &&
          other._typeWrapper.isDynamicOrObject) {
        return true;
      } else {
        return false;
      }
    }

    var args1 = _arguments;
    var args2 = other._arguments;

    if (args1.isEmpty) {
      return args2.where((e) => !e.isDynamic && !e.isObject).isEmpty;
    } else if (args2.isEmpty) {
      return args1.where((e) => !e.isDynamic && !e.isObject).isEmpty;
    } else {
      return _listEquivalencyTypeInfo.equals(args1, args2);
    }
  }

  @override
  int get hashCode =>
      _typeWrapper.hashCode ^ _listEqualityTypeInfo.hash(_arguments);

  @override
  String toString({bool withT = true}) {
    var typeName = this.typeName;
    if (withT) typeName = '<T:$T> $typeName';

    return hasArguments
        ? '$typeName<${_arguments.map((e) => e.toString(withT: withT)).join(',')}>'
        : typeName;
  }

  Object? fromJson(
    dynamic json, {
    JsonDecoder? jsonDecoder,
    bool duplicatedEntitiesAsID = true,
    bool? autoResetEntityCache,
  }) {
    return _fromJsonImpl(
      json,
      jsonDecoder,
      duplicatedEntitiesAsID,
      autoResetEntityCache,
    );
  }

  Object? _fromJsonImpl(
    dynamic json,
    JsonDecoder? jsonDecoder,
    bool duplicatedEntitiesAsID,
    bool? autoResetEntityCache,
  ) {
    if (isPrimitiveType) {
      return parse(json);
    } else if (isIterable) {
      var list = TypeParser.parseList(json);
      if (list == null) return null;

      if (hasArguments) {
        var arg = argumentType(0);
        if (arg != null) {
          jsonDecoder ??= JsonDecoder.defaultDecoder;

          list = jsonDecoder.fromJsonList(
            list,
            typeInfo: arg,
            duplicatedEntitiesAsID: duplicatedEntitiesAsID,
            autoResetEntityCache: autoResetEntityCache,
          );
        }
      }

      return castCollection(list);
    } else if (isMap) {
      var map = TypeParser.parseMap(json);
      if (map == null) return null;

      if (hasArguments) {
        var arg0 = argumentType(0);
        var arg1 = argumentType(1);
        if (arg0 != null && arg1 != null) {
          jsonDecoder ??= JsonDecoder.defaultDecoder;

          map = map.map(
            (key, value) => MapEntry(
              arg0._fromJsonImpl(
                key,
                jsonDecoder,
                duplicatedEntitiesAsID,
                false,
              ),
              arg1._fromJsonImpl(
                value,
                jsonDecoder,
                duplicatedEntitiesAsID,
                false,
              ),
            ),
          );

          if (autoResetEntityCache != null) {
            if (autoResetEntityCache) {
              jsonDecoder.resetEntityCache();
            }
          } else if (jsonDecoder.autoResetEntityCache) {
            jsonDecoder.resetEntityCache();
          }
        }
      }

      return castCollection(map);
    } else {
      var classReflection = ReflectionFactory().getRegisterClassReflection(
        type,
      );

      if (classReflection != null) {
        jsonDecoder ??= JsonDecoder.defaultDecoder;

        return classReflection.fromJson(
          json,
          jsonDecoder: jsonDecoder,
          duplicatedEntitiesAsID: duplicatedEntitiesAsID,
          autoResetEntityCache: autoResetEntityCache,
        );
      }
    }

    jsonDecoder ??= JsonDecoder.defaultDecoder;

    return jsonDecoder.fromJson(
      json,
      typeInfo: this,
      duplicatedEntitiesAsID: duplicatedEntitiesAsID,
      autoResetEntityCache: autoResetEntityCache,
    );
  }

  /// Casts [o] to this collection type if a [ClassReflection] or [EnumReflection]
  /// for it is registered at [ReflectionFactory].
  Object castCollection(Object o, {bool nullable = false}) {
    if (isMap && o is Map) {
      return castMap(o, nullable: nullable);
    }

    var mainType = isCollection ? (argumentType(0) ?? TypeInfo.tDynamic) : this;

    var reflectionFactory = ReflectionFactory();

    var reflection =
        reflectionFactory.getRegisterClassReflection(mainType.type) ??
        reflectionFactory.getRegisterEnumReflection(mainType.type);

    if (reflection != null) {
      return reflection.castCollection(o, this, nullable: nullable) ?? o;
    }

    return o;
  }

  /// Casts [list] to this type (`List<T>`) if a [ClassReflection] or [EnumReflection]
  /// for `T` is registered at [ReflectionFactory].
  List castList(List list, {bool nullable = false}) {
    var mainType = isCollection ? (argumentType(0) ?? TypeInfo.tDynamic) : this;

    if (mainType.isDynamic) {
      return list;
    } else if (mainType.isObject) {
      if (!nullable && list is! List<Object>) {
        return list.cast<Object>();
      }
      return list;
    }

    var reflectionFactory = ReflectionFactory();

    var reflection =
        reflectionFactory.getRegisterClassReflection(mainType.type) ??
        reflectionFactory.getRegisterEnumReflection(mainType.type);

    if (reflection != null) {
      return reflection.castList(list, mainType.type, nullable: nullable) ??
          list;
    }

    if (mainType.isValidGenericType) {
      if (nullable) {
        return mainType.callCasted(<E>() => list.cast<E?>());
      } else {
        return mainType.callCasted(<E>() => list.cast<E>());
      }
    } else {
      return list;
    }
  }

  /// Casts [set] to this type (`Set<T>`) if a [ClassReflection] or [EnumReflection]
  /// for `T` is registered at [ReflectionFactory].
  Set castSet(Set set, {bool nullable = false}) {
    var mainType = isCollection ? (argumentType(0) ?? TypeInfo.tDynamic) : this;

    var reflectionFactory = ReflectionFactory();

    var reflection =
        reflectionFactory.getRegisterClassReflection(mainType.type) ??
        reflectionFactory.getRegisterEnumReflection(mainType.type);

    if (reflection != null) {
      return reflection.castSet(set, mainType.type, nullable: nullable) ?? set;
    }

    if (mainType.isValidGenericType) {
      return mainType.callCasted(<E>() => set.cast<E>());
    } else {
      return set;
    }
  }

  /// Casts [itr] to this type (`Iterable<T>`) if a [ClassReflection] or [EnumReflection]
  /// for `T` is registered at [ReflectionFactory].
  Iterable castIterable(Iterable itr, {bool nullable = false}) {
    var mainType = isCollection ? (argumentType(0) ?? TypeInfo.tDynamic) : this;

    var reflectionFactory = ReflectionFactory();

    var reflection =
        reflectionFactory.getRegisterClassReflection(mainType.type) ??
        reflectionFactory.getRegisterEnumReflection(mainType.type);

    if (reflection != null) {
      return reflection.castIterable(itr, mainType.type, nullable: nullable) ??
          itr;
    }

    if (mainType.isValidGenericType) {
      return mainType.callCasted(<E>() => itr.cast<E>());
    } else {
      return itr;
    }
  }

  /// Casts [map] to this type (`Map<K,V>`), resolving the casting for
  /// `K` and `V` if there's a [ClassReflection] or [EnumReflection]
  /// for them registered at [ReflectionFactory].
  Map castMap(Map map, {bool nullable = false}) {
    var keyType = isCollection
        ? (argumentType(0) ?? TypeInfo.tDynamic)
        : TypeInfo.tDynamic;
    var valueType = isCollection
        ? (argumentType(1) ?? TypeInfo.tDynamic)
        : TypeInfo.tDynamic;

    var reflectionFactory = ReflectionFactory();

    var keyReflection =
        reflectionFactory.getRegisterClassReflection(keyType.type) ??
        reflectionFactory.getRegisterEnumReflection(keyType.type);

    var valueReflection =
        reflectionFactory.getRegisterClassReflection(valueType.type) ??
        reflectionFactory.getRegisterEnumReflection(valueType.type);

    if (keyReflection != null && valueReflection != null) {
      var tMap = TypeInfo.fromMapType(
        keyReflection.typeInfo,
        valueReflection.typeInfo,
      );

      if (valueReflection == keyReflection) {
        return keyReflection.castMap(map, tMap, nullable: nullable) ?? map;
      } else {
        var mapKeysCast =
            keyReflection.castMapKeys(map, tMap, nullable: nullable) ?? map;

        var mapCast =
            valueReflection.castMapValues(
              mapKeysCast,
              this,
              nullable: nullable,
            ) ??
            map;

        return mapCast;
      }
    } else if (keyReflection != null) {
      return keyReflection.castMapKeys(map, this, nullable: nullable) ?? map;
    } else if (valueReflection != null) {
      return valueReflection.castMapValues(map, this, nullable: nullable) ??
          map;
    }

    if (keyType.isValidGenericType && valueType.isValidGenericType) {
      return keyType.callCasted(<K>() {
        return valueType.callCasted(<V>() => map.cast<K, V>());
      });
    } else if (keyType.isValidGenericType) {
      return keyType.callCasted(<K>() => map.cast<K, dynamic>());
    } else if (valueType.isValidGenericType) {
      return valueType.callCasted(<V>() => map.cast<dynamic, V>());
    }

    return map;
  }

  /// The argument at index `0` (in [arguments]).
  TypeInfo? get arguments0 => argumentType(0);

  /// The argument at index `1` (in [arguments]).
  TypeInfo? get arguments1 => argumentType(1);

  /// Returns `true` if [o] is a `List<E>` where `E` is [arguments0] `T`.
  /// - `E` should be valid. See [isValidGenericType].
  /// - This [TypeInfo] should be a [List]. See [isList].
  bool isCastedList(Object? o) {
    if (!isList || o is! List) return false;

    var arg0 = arguments0;
    return arg0 != null &&
        arg0.isValidGenericType &&
        arg0.callCasted(<E>() => o is List<E>);
  }

  /// Returns `true` if [o] is a `Set<E>` where `E` is [arguments0] `T`.
  /// - `E` should be valid. See [isValidGenericType].
  /// - This [TypeInfo] should be a [Set]. See [isSet].
  bool isCastedSet(Object? o) {
    if (!isSet || o is! Set) return false;

    var arg0 = arguments0;
    return arg0 != null &&
        arg0.isValidGenericType &&
        arg0.callCasted(<E>() => o is Set<E>);
  }

  /// Returns `true` if [o] is a `Iterable<E>` where `E` is [arguments0] `T`.
  /// - `E` should be valid. See [isValidGenericType].
  /// - This [TypeInfo] should be an [Iterable]. See [isIterable].
  bool isCastedIterable(Object? o) {
    if (!isIterable || o is! Iterable) return false;

    var arg0 = arguments0;
    return arg0 != null &&
        arg0.isValidGenericType &&
        arg0.callCasted(<E>() => o is Iterable<E>);
  }

  /// Returns `true` if [o] is a `Map<K,V>`
  /// where `K` is [arguments0] `T` and `V` is [arguments1] `T`.
  /// - `K` or `V` should be valid. See [isValidGenericType].
  /// - This [TypeInfo] should be a [Map]. See [isMap].
  bool isCastedMap(Object? o) {
    if (!isMap || o is! Map) return false;

    var arg0 = arguments0;
    var arg1 = arguments1;

    var arg0Ok = arg0 != null && arg0.isValidGenericType;
    var arg1Ok = arg1 != null && arg1.isValidGenericType;

    if (arg0Ok && arg1Ok) {
      return arg0.callCasted(<K>() {
        return arg1.callCasted(<V>() => o is Map<K, V>);
      });
    } else if (arg0Ok) {
      return arg0.callCasted(<K>() => o is Map<K, dynamic>);
    } else if (arg1Ok) {
      return arg1.callCasted(<V>() => o is Map<dynamic, V>);
    } else {
      return false;
    }
  }

  /// Returns `true` if [o] is a `MapEntry<K,V>`
  /// where `K` is [arguments0] `T` and `V` is [arguments1] `T`.
  /// - `K` or `V` should be valid. See [isValidGenericType].
  /// - This [TypeInfo] should be a [MapEntry]. See [isMapEntry].
  bool isCastedMapEntry(Object? o) {
    if (!isMapEntry || o is! MapEntry) return false;

    var arg0 = arguments0;
    var arg1 = arguments1;

    var arg0Ok = arg0 != null && arg0.isValidGenericType;
    var arg1Ok = arg1 != null && arg1.isValidGenericType;

    if (arg0Ok && arg1Ok) {
      return arg0.callCasted(<K>() {
        return arg1.callCasted(<V>() => o is MapEntry<K, V>);
      });
    } else if (arg0Ok) {
      return arg0.callCasted(<K>() => o is MapEntry<K, dynamic>);
    } else if (arg1Ok) {
      return arg1.callCasted(<V>() => o is MapEntry<dynamic, V>);
    } else {
      return false;
    }
  }
}

final TypeInfoListEquality _listEqualityTypeInfo = TypeInfoListEquality();
final TypeInfoListEquivalency _listEquivalencyTypeInfo =
    TypeInfoListEquivalency();

extension _ListExtension<T> on List<T> {
  Type get listType => T;
}

/// Extension for [Type].
extension TypeExtension on Type {
  /// Returns `true` if `this` [Type] is primitive:
  /// [int], [double], [num], [String] or [bool].
  bool get isPrimitiveType {
    var self = this;
    return self == int ||
        self == double ||
        self == num ||
        self == String ||
        self == bool;
  }
}

/// Extension for [Object] nullable.
extension GenericObjectExtension on Object? {
  /// Returns `true` if `this` object is a [num], [String] or [bool].
  bool get isPrimitiveValue {
    var self = this;
    return self is num || self is String || self is bool;
  }

  /// Returns `true` if `this` object is a [List] of primitive values.
  /// See [isPrimitiveValue].
  bool get isPrimitiveList {
    var self = this;
    return self is List &&
        (self is List<num> || self is List<String> || self is List<bool>);
  }

  /// Returns `true` if `this` object is a [Map] of [String] keys and primitive values.
  /// See [isPrimitiveValue].
  bool get isPrimitiveMap {
    var self = this;
    return self is Map &&
        (self is Map<String, num> ||
            self is Map<String, String> ||
            self is Map<String, bool>);
  }
}
