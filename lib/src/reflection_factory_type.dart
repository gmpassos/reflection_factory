import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';

import 'reflection_factory_base.dart';
import 'reflection_factory_json.dart';

typedef TypeElementParser<T> = T? Function(Object? o);

/// Lenient parsers for basic Dart types.
class TypeParser {
  /// Returns the parser for the desired type, defined by [T], [obj] or [type].
  static TypeElementParser? parserFor<T>(
      {Object? obj, Type? type, TypeInfo? typeInfo}) {
    if (obj != null) {
      if (obj is String) {
        return parseString;
      } else if (obj is Map) {
        return parseMap;
      } else if (obj is Set) {
        return parseSet;
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
      } else if (obj is Uint8List) {
        return parseUInt8List;
      }
    }

    typeInfo ??= TypeInfo.from(type ?? T);

    if (typeInfo.isString) {
      return parseString;
    } else if (typeInfo.isMap) {
      return parseMap;
    } else if (typeInfo.isSet) {
      return parseSet;
    } else if (typeInfo.isList || typeInfo.isIterable) {
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
    } else if (typeInfo.isOf(Uint8List)) {
      return parseUInt8List;
    }

    return null;
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
  static List<T>? parseList<T>(Object? value,
      {List<T>? def, TypeElementParser<T>? elementParser}) {
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
  static Set<T>? parseSet<T>(Object? value,
      {Set<T>? def, TypeElementParser<T>? elementParser}) {
    var l = parseList<T>(value, elementParser: elementParser);
    return l?.toSet() ?? def;
  }

  static final RegExp _regexpPairDelimiter = RegExp(r'\s*[;&]\s*');
  static final RegExp _regexpKeyValueDelimiter = RegExp(r'\s*[:=]\s*');

  /// Tries to parse a [Map].
  /// - Returns [def] if [value] is `null` or an empty [String].
  static Map<K, V>? parseMap<K, V>(Object? value,
      {Map<K, V>? def,
      TypeElementParser<K>? keyParser,
      TypeElementParser<V>? valueParser}) {
    if (value == null) return def;

    if (value is Map<K, V>) {
      return value;
    }

    keyParser ??= parserFor<K>() as TypeElementParser<K>?;
    keyParser ??= (k) => k as K;

    valueParser ??= parserFor<V>() as TypeElementParser<V>?;
    valueParser ??= (v) => v as V;

    if (value is Map) {
      return value
          .map((k, v) => MapEntry(keyParser!(k) as K, valueParser!(v) as V));
    } else if (value is Iterable) {
      return Map.fromEntries(value
          .map((e) => parseMapEntry<K, V>(e,
              keyParser: keyParser, valueParser: valueParser))
          .whereNotNull());
    } else {
      var s = '$value'.trim();
      if (s.isEmpty) return def;

      var pairs = s.split(_regexpPairDelimiter);
      return Map.fromEntries(pairs
          .map((e) => parseMapEntry<K, V>(e,
              keyParser: keyParser, valueParser: valueParser))
          .whereNotNull());
    }
  }

  /// Tries to parse a [MapEntry].
  /// - Returns [def] if [value] is `null` or an empty [String].
  static MapEntry<K, V>? parseMapEntry<K, V>(Object? value,
      {MapEntry<K, V>? def,
      TypeElementParser<K>? keyParser,
      TypeElementParser<V>? valueParser}) {
    if (value == null) return def;

    if (value is MapEntry<K, V>) {
      return value;
    }

    keyParser ??= parserFor<K>() as TypeElementParser<K>?;
    keyParser ??= (k) => k as K;

    valueParser ??= parserFor<V>() as TypeElementParser<V>?;
    valueParser ??= (v) => v as V;

    if (value is MapEntry) {
      return MapEntry(keyParser(value.key) as K, valueParser(value.value) as V);
    } else if (value is Iterable) {
      var k = value.elementAt(0);
      var v = value.elementAt(1);
      return MapEntry(keyParser(k) as K, valueParser(v) as V);
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
      if (s.isEmpty || s == 'null' || s == 'empty') return def;

      if (s == 'true' ||
          s == 't' ||
          s == 'yes' ||
          s == 'y' ||
          s == '1' ||
          s == '+' ||
          s == 'ok') {
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
          s == 'err') {
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

  /// Tries to parse a [DateTime].
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
      try {
        var data = base64.decode(s);
        return data;
      } catch (_) {
        return def;
      }
    }
  }

  /// Returns `true` if [type] is primitive ([String], [int], [double], [num] or [bool]).
  static bool isPrimitiveType<T>([Type? type]) {
    type ??= T;
    return TypeInfo.from(type).isPrimitiveType;
  }

  /// Returns `true` if [value] is primitive ([String], [int], [double], [num] or [bool]).
  static bool isPrimitiveValue(Object value) {
    return TypeInfo.from(value).isPrimitiveType;
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
  uInt8List,
  mapEntry,
  future,
  futureOr,
  voidType,
}

class _TypeWrapper {
  final Type type;

  final BasicDartType basicDartType;

  _TypeWrapper(Type type,
      {BasicDartType? basicType, Object? object, bool? hasArguments})
      : type = detectType(type, object),
        basicDartType =
            basicType ?? detectBasicType(type, object, hasArguments);

  static BasicDartType detectBasicType(Type type,
      [Object? object, bool? hasArguments]) {
    if (type == tString || object is String) return BasicDartType.string;
    if (type == tInt || object is int) return BasicDartType.int;
    if (type == tDouble || object is double) return BasicDartType.double;
    if (type == tNum || object is num) return BasicDartType.num;
    if (type == tBool || object is bool) return BasicDartType.bool;
    if (type == tBigInt || object is BigInt) return BasicDartType.bigInt;
    if (type == tDateTime || object is DateTime) return BasicDartType.dateTime;

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

  static final Type tString = String;
  static final Type tInt = int;
  static final Type tDouble = double;
  static final Type tNum = num;
  static final Type tBool = bool;
  static final Type tBigInt = BigInt;
  static final Type tDateTime = DateTime;
  static final Type tUint8List = Uint8List;
  static final Type tList = List;
  static final Type tSet = Set;
  static final Type tMap = Map;
  static final Type tMapEntry = MapEntry;
  static final Type tIterable = Iterable;
  static final Type tFuture = Future;
  static final Type tFutureOr = FutureOr;
  static final Type tObject = Object;
  static final Type tDynamic = dynamic;
  static final Type tVoid = <void>[].listType; // Is there a better way?

  static Type detectType(Type type, [Object? object]) {
    if (type == tString || object is String) return tString;
    if (type == tInt || object is int) return tInt;
    if (type == tDouble || object is double) return tDouble;
    if (type == tNum || object is num) return tNum;
    if (type == tBool || object is bool) return tBool;
    if (type == tBigInt || object is BigInt) return tBigInt;
    if (type == tDateTime || object is DateTime) return tDateTime;
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
  bool get isPrimitiveType => isString || isInt || isDouble || isNum || isBool;

  /// Returns `true` if [type] is a collection ([List], [Iterable], [Map] or [Set]).
  bool get isCollection => isList || isIterable || isMap || isSet;

  /// Returns `true` if [type] [isPrimitiveType] or [isCollection].
  bool get isBasicType => isPrimitiveType || isCollection;

  /// Returns `true` if [type] is `Object` or `dynamic`.
  bool get isAnyType => isObject || isDynamic;

  /// Returns `true` if [type] is `Object`.
  bool get isObject => basicDartType == BasicDartType.object;

  /// Returns `true` if [type] is `dynamic`.
  bool get isDynamic => basicDartType == BasicDartType.dynamic;

  /// Returns `true` if [type] is `dynamic` or `Object`.
  bool get isDynamicOrObject => isDynamic || isObject;

  /// Returns `true` if [type] is `void`.
  bool get isVoid => basicDartType == BasicDartType.voidType;

  /// Returns `true` if [type] is `bool`.
  bool get isBool => basicDartType == BasicDartType.bool;

  /// Returns `true` if [type] is `int`.
  bool get isInt => basicDartType == BasicDartType.int;

  /// Returns `true` if [type] is `double`.
  bool get isDouble => basicDartType == BasicDartType.double;

  /// Returns `true` if [type] is `num`.
  bool get isNum => basicDartType == BasicDartType.num;

  /// Returns `true` if [type] is `int`, `double` or `num`.
  bool get isNumber => isInt || isDouble || isNum;

  /// Returns `true` if [type] is [BigInt].
  bool get isBigInt => basicDartType == BasicDartType.bigInt;

  /// Returns `true` if [type] is [DateTime].
  bool get isDateTime => basicDartType == BasicDartType.dateTime;

  /// Returns `true` if [type] is [DateTime].
  bool get isUInt8List => basicDartType == BasicDartType.uInt8List;

  /// Returns `true` if [type] is `String`.
  bool get isString => basicDartType == BasicDartType.string;

  /// Returns `true` if [type] is a [List].
  bool get isList => basicDartType == BasicDartType.list;

  /// Returns `true` if [type] is a [Iterable].
  bool get isIterable => basicDartType == BasicDartType.iterable;

  /// Returns `true` if [type] is a [Map].
  bool get isMap => basicDartType == BasicDartType.map;

  /// Returns `true` if [type] is a [MapEntry].
  bool get isMapEntry => basicDartType == BasicDartType.mapEntry;

  /// Returns `true` if [type] is a [Set].
  bool get isSet => basicDartType == BasicDartType.set;

  /// Returns `true` if [type] is a [Future].
  bool get isFuture => basicDartType == BasicDartType.future;

  /// Returns `true` if [type] is a [FutureOr].
  bool get isFutureOr => basicDartType == BasicDartType.futureOr;

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
class TypeInfo {
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

  static final TypeInfo tString = TypeInfo._(_TypeWrapper.tString);
  static final TypeInfo tBool = TypeInfo._(_TypeWrapper.tBool);
  static final TypeInfo tInt = TypeInfo._(_TypeWrapper.tInt);
  static final TypeInfo tDouble = TypeInfo._(_TypeWrapper.tDouble);
  static final TypeInfo tNum = TypeInfo._(_TypeWrapper.tNum);
  static final TypeInfo tBigInt = TypeInfo._(_TypeWrapper.tBigInt);
  static final TypeInfo tDateTime = TypeInfo._(_TypeWrapper.tDateTime);
  static final TypeInfo tUint8List = TypeInfo._(_TypeWrapper.tUint8List);

  static final TypeInfo tList = TypeInfo._(_TypeWrapper.tList);
  static final TypeInfo tSet = TypeInfo._(_TypeWrapper.tSet);
  static final TypeInfo tMap = TypeInfo._(_TypeWrapper.tMap);
  static final TypeInfo tIterable = TypeInfo._(_TypeWrapper.tIterable);

  static final TypeInfo tFuture = TypeInfo._(_TypeWrapper.tFuture);
  static final TypeInfo tFutureOr = TypeInfo._wrapper(
      _TypeWrapper(_TypeWrapper.tFutureOr, basicType: BasicDartType.futureOr));

  static final TypeInfo tObject = TypeInfo._(_TypeWrapper.tObject);
  static final TypeInfo tDynamic = TypeInfo._(_TypeWrapper.tDynamic);
  static final TypeInfo tVoid = TypeInfo._(_TypeWrapper.tVoid);

  final _TypeWrapper _typeWrapper;

  /// The main [Type].
  Type get type => _typeWrapper.type;

  /// Returns the [type] name.
  String get typeName {
    if (isFutureOr) {
      return 'FutureOr';
    }

    var typeStr = type.toString();
    var idx = typeStr.indexOf('<');
    if (idx > 0) typeStr = typeStr.substring(0, idx);
    return typeStr;
  }

  /// The [type] arguments (generics).
  final List<TypeInfo> arguments;

  static final _emptyArguments = List<TypeInfo>.unmodifiable([]);

  TypeInfo(Type type, [Iterable<Object>? arguments])
      : this._(type, arguments, null);

  TypeInfo._(Type type,
      [Iterable<Object>? arguments, Object? object, _TypeWrapper? typeWrapper])
      : _typeWrapper = typeWrapper ??
            _TypeWrapper(type,
                object: object,
                hasArguments: arguments != null && arguments.isNotEmpty),
        arguments = arguments == null || arguments.isEmpty
            ? _emptyArguments
            : List<TypeInfo>.unmodifiable(
                arguments.map((o) => TypeInfo.from(o)));

  TypeInfo._wrapper(this._typeWrapper, [Iterable<Object>? arguments])
      : arguments = arguments == null || arguments.isEmpty
            ? _emptyArguments
            : List<TypeInfo>.unmodifiable(
                arguments.map((o) => TypeInfo.from(o)));

  factory TypeInfo.from(Object o,
      [Iterable<Object>? arguments, Object? object]) {
    if (o is TypeInfo) return o;
    if (o is Type) return TypeInfo.fromType(o, arguments, object);

    if (o is ParameterReflection) {
      return TypeInfo.from(o.type, null, object);
    }

    if (o is TypeReflection) {
      var args = arguments ?? o.arguments;
      return TypeInfo._(o.type, args, object);
    }

    if (o is FieldReflection) {
      if (arguments == null && object == null) {
        return o.type.typeInfo;
      } else {
        var args = arguments ?? o.type.arguments;
        return TypeInfo._(o.type.type, args, object);
      }
    }

    return TypeInfo._(o.runtimeType, arguments, object ?? o);
  }

  factory TypeInfo.fromType(Type type,
      [Iterable<Object>? arguments, Object? object]) {
    if (type == _TypeWrapper.tString || object is String) return tString;
    if (type == _TypeWrapper.tInt || object is int) return tInt;
    if (type == _TypeWrapper.tDouble || object is double) return tDouble;
    if (type == _TypeWrapper.tNum || object is num) return tNum;
    if (type == _TypeWrapper.tBool || object is bool) return tBool;
    if (type == _TypeWrapper.tBigInt || object is BigInt) return tBigInt;
    if (type == _TypeWrapper.tDateTime || object is DateTime) return tDateTime;
    if (type == _TypeWrapper.tUint8List || object is Uint8List) {
      return tUint8List;
    }

    if (type == _TypeWrapper.tObject) return tObject;

    var hasArguments = arguments != null && arguments.isNotEmpty;

    if (type == _TypeWrapper.tDynamic) {
      // A FutureOr is a `dynamic` with arguments:
      if (hasArguments) {
        return TypeInfo._(_TypeWrapper.tFutureOr, arguments, object,
            TypeInfo.tFutureOr._typeWrapper);
      } else {
        return tDynamic;
      }
    }

    if (type == _TypeWrapper.tFuture) {
      if (hasArguments) {
        return TypeInfo._(_TypeWrapper.tFuture, arguments, object,
            TypeInfo.tFuture._typeWrapper);
      } else {
        return TypeInfo.tFuture;
      }
    }

    if (type == _TypeWrapper.tVoid) return tVoid;

    if (arguments == null || arguments.isEmpty) {
      if (type == _TypeWrapper.tList || object is List) return tList;
      if (type == _TypeWrapper.tSet || object is Set) return tSet;
      if (type == _TypeWrapper.tMap || object is Map) return tMap;
      if (type == _TypeWrapper.tIterable || object is Iterable) {
        return tIterable;
      }

      if (type == _TypeWrapper.tFuture || object is Future) return tFuture;
    }

    return TypeInfo._(type, arguments, object);
  }

  /// Returns `true` if `this`.[type] equals to [other].[type].
  ///
  /// Resolves some [Type] singleton issues with [List], [Set] and [Map].
  bool equalsType(TypeInfo? other) => _typeWrapper == other?._typeWrapper;

  /// Returns `true` if [equalsType] and [equalsArgumentsTypes] are `true`.
  bool equalsTypeAndArguments(TypeInfo other) =>
      equalsType(other) && equalsArgumentsTypes(other.arguments);

  /// The [arguments] length.
  int get argumentsLength => arguments.length;

  /// Returns `true` if [type] has [arguments].
  bool get hasArguments => arguments.isNotEmpty;

  /// Returns the [TypeInfo] of the argument at [index].
  TypeInfo? argumentType(int index) =>
      index < argumentsLength ? arguments[index] : null;

  /// Returns `true` if [arguments] have equals [types].
  bool equalsArgumentsTypes(List<Object> types) {
    var arguments = this.arguments;
    if (arguments.isEmpty) {
      return types.isEmpty;
    }

    if (arguments.length != types.length) {
      return false;
    }

    return _listEqualityTypeInfo.equals(
        arguments, TypeInfo.toList(types, growable: false));
  }

  /// Returns `true` if [arguments] have equivalent [types].
  bool equivalentArgumentsTypes(List<Object> types) {
    var arguments = this.arguments;
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
  /// See [TypeParser.parserFor].
  TypeElementParser? get parser => TypeParser.parserFor(typeInfo: this);

  /// Returns the parser of the argument at [index].
  TypeElementParser? argumentParser(int index) =>
      index < argumentsLength ? arguments[index].parser : null;

  /// Parse [value] or return [def].
  ///
  /// See [TypeParser.parserFor].
  T? parse<T>(Object? value, [T? def]) {
    if (value == null) return def;

    if (isString) {
      return TypeParser.parseString(value, def as String?) as T?;
    } else if (isInt) {
      return TypeParser.parseInt(value, def as int?) as T?;
    } else if (isBool) {
      return TypeParser.parseBool(value, def as bool?) as T?;
    } else if (isDouble) {
      return TypeParser.parseDouble(value, def as double?) as T?;
    } else if (isNum) {
      return TypeParser.parseNum(value, def as num?) as T?;
    } else if (isDateTime) {
      return TypeParser.parseDateTime(value, def as DateTime?) as T?;
    } else if (isUInt8List) {
      return TypeParser.parseUInt8List(value, def as Uint8List?) as T?;
    } else if (isBigInt) {
      return TypeParser.parseBigInt(value, def as BigInt?) as T?;
    } else if (isList) {
      return TypeParser.parseList(value, elementParser: argumentParser(0))
          as T?;
    } else if (isSet) {
      return TypeParser.parseSet(value, elementParser: argumentParser(0)) as T?;
    } else if (isMap) {
      return TypeParser.parseMap(value,
          keyParser: argumentParser(0), valueParser: argumentParser(1)) as T?;
    } else if (isMapEntry) {
      return TypeParser.parseMapEntry(value,
          keyParser: argumentParser(0), valueParser: argumentParser(1)) as T?;
    } else {
      if (value.runtimeType == type) {
        return value as T;
      }

      return null;
    }
  }

  /// Same as [parse] but if `this` [isFuture] it will traverse
  /// to the [Future] argument.
  T? parseTraversingFuture<T>(Object? value, [T? def]) {
    if (isFuture) {
      var argument = argumentType(0);
      if (argument != null) {
        return argument.parse(value);
      }
    }

    return parse(value);
  }

  /// Returns `true` if [type] is primitive ([bool], [int], [double], [num] or [String]).
  bool get isPrimitiveType => _typeWrapper.isPrimitiveType;

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

  /// Returns `true` if [type] is a [List] of entities.
  bool get isListEntity =>
      isList && hasArguments && !arguments.first.isPrimitiveType;

  /// The [TypeInfo] of the [List] elements type.
  TypeInfo? get listEntityType => isListEntity ? arguments.first : null;

  TypeReflection? _typeReflection;

  /// Returns this instance as [TypeReflection].
  TypeReflection get asTypeReflection =>
      _typeReflection ??= TypeReflection(type, arguments);

  /// Returns `true` if this instances has the same [type] and [arguments].
  bool isOf(Type type, [List<Object>? arguments]) {
    var t = TypeInfo.from(type);

    if (!equalsType(t)) return false;

    if (arguments != null) {
      if (hasArguments) {
        return argumentsLength == arguments.length &&
            _listEqualityTypeInfo.equals(
                this.arguments, TypeInfo.toList(arguments));
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
          runtimeType == other.runtimeType &&
          _typeWrapper == other._typeWrapper &&
          _listEqualityTypeInfo.equals(arguments, other.arguments);

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

    var args1 = arguments;
    var args2 = other.arguments;

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
      _typeWrapper.hashCode ^ _listEqualityTypeInfo.hash(arguments);

  @override
  String toString() {
    return hasArguments ? '$typeName<${arguments.join(',')}>' : typeName;
  }

  Object? fromJson(dynamic json,
      {JsonDecoder? jsonDecoder,
      bool duplicatedEntitiesAsID = true,
      bool? autoResetEntityCache}) {
    return _fromJsonImpl(
        json, jsonDecoder, duplicatedEntitiesAsID, autoResetEntityCache);
  }

  Object? _fromJsonImpl(dynamic json, JsonDecoder? jsonDecoder,
      bool duplicatedEntitiesAsID, bool? autoResetEntityCache) {
    if (isPrimitiveType) {
      return parse(json);
    } else if (isIterable) {
      var list = TypeParser.parseList(json);
      if (list == null) return null;

      if (hasArguments) {
        var arg = argumentType(0);
        if (arg != null) {
          jsonDecoder ??= JsonDecoder.defaultDecoder;

          list = jsonDecoder.fromJsonList(list,
              type: arg.type,
              duplicatedEntitiesAsID: duplicatedEntitiesAsID,
              autoResetEntityCache: autoResetEntityCache);
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

          map = map.map((key, value) => MapEntry(
                arg0._fromJsonImpl(
                    key, jsonDecoder, duplicatedEntitiesAsID, false),
                arg1._fromJsonImpl(
                    value, jsonDecoder, duplicatedEntitiesAsID, false),
              ));

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
      var classReflection =
          ReflectionFactory().getRegisterClassReflection(type);

      if (classReflection != null) {
        jsonDecoder ??= JsonDecoder.defaultDecoder;

        return classReflection.fromJson(json,
            jsonDecoder: jsonDecoder,
            duplicatedEntitiesAsID: duplicatedEntitiesAsID,
            autoResetEntityCache: autoResetEntityCache);
      }
    }

    jsonDecoder ??= JsonDecoder.defaultDecoder;

    return jsonDecoder.fromJson(json,
        type: type,
        duplicatedEntitiesAsID: duplicatedEntitiesAsID,
        autoResetEntityCache: autoResetEntityCache);
  }

  /// Casts [o] to this collection type if a [ReflectionFactory] is registered
  /// for it.
  Object castCollection(Object o) {
    var mainType = isCollection ? (argumentType(0) ?? this) : this;

    var classReflection =
        ReflectionFactory().getRegisterClassReflection(mainType.type);

    if (classReflection != null) {
      return classReflection.castCollection(o, this) ?? o;
    }

    return o;
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
