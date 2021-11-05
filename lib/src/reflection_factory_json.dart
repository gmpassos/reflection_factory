import 'dart:async';
import 'dart:convert' as dart_convert;

import 'reflection_factory_base.dart';

typedef JsonFieldMatcher = bool Function(String key);

typedef ToEncodableJson = Object? Function(
    Object? object, JsonEncoder jsonEncoder);

typedef ToEncodableJsonProvider = ToEncodableJson? Function(Object identifier);

typedef JsomMapDecoder<O> = O? Function(
    Map<String, Object?> map, JsonDecoder jsonDecoder);

typedef JsomMapDecoderProvider = JsomMapDecoder? Function(Object identifier);

typedef JsomMapDecoderAsync<O> = FutureOr<O?> Function(
    Map<String, Object?> map, JsonDecoder jsonDecoder);

typedef JsomMapDecoderAsyncProvider = JsomMapDecoderAsync? Function(Type type);

typedef IterableCaster = Object? Function(Iterable value, TypeReflection type);

/// JSON codec integrated with [ReflectionFactory].
class JsonCodec {
  static final JsonCodec defaultCodec =
      JsonCodec._(JsonEncoder.defaultCodec, JsonDecoder.defaultCodec);

  factory JsonCodec(
      {JsonFieldMatcher? maskField,
      String maskText = '***',
      JsonFieldMatcher? removeField,
      bool removeNullFields = false,
      ToEncodableJsonProvider? toEncodableProvider,
      ToEncodableJson? toEncodable,
      JsomMapDecoderProvider? jsomMapDecoderProvider,
      JsomMapDecoder? jsomMapDecoder,
      JsomMapDecoderAsyncProvider? jsomMapDecoderAsyncProvider,
      JsomMapDecoderAsync? jsomMapDecoderAsync,
      IterableCaster? iterableCaster}) {
    if (maskField == null &&
        removeField == null &&
        !removeNullFields &&
        toEncodableProvider == null &&
        toEncodable == null &&
        jsomMapDecoderProvider == null &&
        jsomMapDecoder == null &&
        jsomMapDecoderAsyncProvider == null &&
        jsomMapDecoderAsync == null &&
        iterableCaster == null) {
      return defaultCodec;
    }

    return JsonCodec._(
        _JsonEncoder(maskField, maskText, removeField, removeNullFields,
            toEncodableProvider, toEncodable),
        _JsonDecoder(jsomMapDecoderProvider, jsomMapDecoder,
            jsomMapDecoderAsyncProvider, jsomMapDecoderAsync, iterableCaster));
  }

  /// The [JsonEncoder] of this instance.
  final JsonEncoder encoder;

  /// The [JsonDecoder] of this instance.
  final JsonDecoder decoder;

  JsonCodec._(this.encoder, this.decoder);

  /// Converts [o] to a JSON collection/data.
  /// - [maskField] when preset indicates if a field value should be masked with [maskText].
  T? toJson<T>(Object? o) {
    return encoder.toJson<T>(o);
  }

  /// Converts [o] to [type].
  O? fromJson<O>(Object? o, {Type? type}) {
    return decoder.fromJson<O>(o, type: type);
  }

  /// Converts [o] to [type] allowing async calls ([Future] and [FutureOr]).
  FutureOr<O?> fromJsonAsync<O>(Object? o, {Type? type}) {
    return decoder.fromJsonAsync<O>(o, type: type);
  }

  /// Converts [o] to as [List] of [type].
  List<O?> fromJsonList<O>(Iterable o, {Type? type}) {
    return decoder.fromJsonList<O>(o, type: type);
  }

  /// Converts [o] to as [List] of [type] allowing async calls ([Future] and [FutureOr]).
  FutureOr<List<O?>> fromJsonListAsync<O>(Iterable o, {Type? type}) {
    return decoder.fromJsonListAsync<O>(o, type: type);
  }

  /// Converts [map] to [type].
  O fromJsonMap<O>(Map<String, Object?> map, {Type? type}) {
    return decoder.fromJsonMap<O>(map, type: type);
  }

  /// Converts [map] to [type] allowing async calls ([Future] and [FutureOr]).
  FutureOr<O> fromJsonMapAsync<O>(Map<String, Object?> map, {Type? type}) {
    return decoder.fromJsonMapAsync<O>(map, type: type);
  }

  /// Transforms [o] to an encoded JSON.
  /// - If [pretty] is `true` generates a pretty JSON, with indentation and line break.
  String encode(Object? o, {bool pretty = false}) {
    return encoder.encode(o, pretty: pretty);
  }

  /// Decodes [encodedJson] to a JSON collection/data.
  T decode<T>(String encodedJson, {Type? type}) {
    return decoder.decode<T>(encodedJson, type: type);
  }

  /// Decodes [encodedJson] to a JSON collection/data allowing async calls ([Future] and [FutureOr]).
  FutureOr<T> decodeAsync<T>(FutureOr<String> encodedJson, {Type? type}) {
    return decoder.decodeAsync<T>(encodedJson, type: type);
  }
}

/// JSON decoder integrated with [ReflectionFactory].
abstract class JsonConverter<S, T> implements dart_convert.Converter<S, T> {
  static bool isPrimitiveType(Type type) {
    return type == String ||
        type == int ||
        type == double ||
        type == num ||
        type == bool ||
        type == Null;
  }

  static bool isCollectionType(Type type) {
    return type == List || type == Set || type == Map || type == Iterable;
  }

  static bool isValidEntityType(Type type) {
    return type != dynamic &&
        type != Object &&
        !isCollectionType(type) &&
        !isPrimitiveType(type);
  }
}

abstract class JsonEncoder extends JsonConverter<Object?, String> {
  static final JsonEncoder defaultCodec = _JsonEncoder.defaultCodec;

  factory JsonEncoder(
      {JsonFieldMatcher? maskField,
      String maskText = '***',
      JsonFieldMatcher? removeField,
      bool removeNullFields = false,
      ToEncodableJsonProvider? toEncodableProvider,
      ToEncodableJson? toEncodable}) {
    if (maskField == null &&
        removeField == null &&
        !removeNullFields &&
        toEncodableProvider == null &&
        toEncodable == null) {
      return defaultCodec;
    }

    return _JsonEncoder._(maskField, maskText, removeField, removeNullFields,
        toEncodableProvider, toEncodable);
  }

  /// Converts [o] to a JSON collection/data.
  /// - [maskField] when preset indicates if a field value should be masked with [maskText].
  T? toJson<T>(Object? o);

  /// Converts [map] tree to a JSON.
  Map<String, dynamic> mapToJson(Map map);

  /// Transforms [o] to an encoded JSON.
  /// - If [pretty] is `true` generates a pretty JSON, with indentation and line break.
  String encode(Object? o, {bool pretty = false});
}

class _JsonEncoder extends dart_convert.Converter<Object?, String>
    implements JsonEncoder {
  static final _JsonEncoder defaultCodec =
      _JsonEncoder._(null, '***', null, false, null, null);

  factory _JsonEncoder(
      JsonFieldMatcher? maskField,
      String maskText,
      JsonFieldMatcher? removeField,
      bool removeNullFields,
      ToEncodableJsonProvider? toEncodableProvider,
      ToEncodableJson? toEncodable) {
    if (maskField == null &&
        removeField == null &&
        !removeNullFields &&
        toEncodableProvider == null &&
        toEncodable == null) {
      return defaultCodec;
    }

    return _JsonEncoder._(maskField, maskText, removeField, removeNullFields,
        toEncodableProvider, toEncodable);
  }

  final JsonFieldMatcher? maskField;
  final String maskText;

  final JsonFieldMatcher? removeField;
  final bool removeNullFields;

  final ToEncodableJsonProvider? toEncodableProvider;

  final ToEncodableJson? toEncodable;

  _JsonEncoder._(
    this.maskField,
    this.maskText,
    this.removeField,
    this.removeNullFields,
    this.toEncodableProvider,
    this.toEncodable,
  );

  @override
  T? toJson<T>(Object? o) {
    return _valueToJson(o) as T;
  }

  Object? _valueToJson(o) {
    if (o == null) {
      return null;
    } else if (o is String || o is num || o is bool) {
      return o;
    } else if (o is DateTime) {
      return _dateTimeToJson(o);
    } else if (o is Map) {
      return mapToJson(o);
    } else if (o is Set) {
      return _iterableToJson(o).toSet();
    } else if (o is Iterable) {
      return _iterableToJson(o).toList();
    } else {
      var entityJson = _entityToJson(o);
      var json = _valueToJson(entityJson);
      return json;
    }
  }

  Iterable<Object?> _iterableToJson(Iterable<dynamic> o) {
    return o.map((e) => _valueToJson(e));
  }

  @override
  Map<String, dynamic> mapToJson(Map map) {
    var oEntries = map.entries;

    var removeField = this.removeField;
    if (removeField != null) {
      if (removeNullFields) {
        oEntries =
            oEntries.where((e) => e.value != null || !removeField(e.key));
      } else {
        oEntries = oEntries.where((e) => !removeField(e.key));
      }
    } else if (removeNullFields) {
      oEntries = oEntries.where((e) => e.value != null);
    }

    var entries = oEntries.map((e) {
      var key = e.key;
      var value = _mapKeyValueToJson(key, e.value);
      return MapEntry<String, dynamic>(key, value);
    });

    return Map<String, dynamic>.fromEntries(entries);
  }

  String _dateTimeToJson(DateTime o) {
    return o.toUtc().toString();
  }

  Object? _mapKeyValueToJson(String k, dynamic o) {
    if (o == null) {
      return null;
    }

    var maskField = this.maskField;
    if (maskField != null) {
      var masked = maskField(k);
      if (masked) {
        return maskText;
      }
    }

    return _valueToJson(o);
  }

  Object? _entityToJson(dynamic o) {
    var toEncodableProvider = this.toEncodableProvider;

    if (toEncodableProvider != null) {
      var encoder = toEncodableProvider(o);

      if (encoder != null) {
        try {
          return encoder(o, this);
        } catch (_) {
          return _entityToJsonDefault(o);
        }
      }
    }

    var toEncodable = this.toEncodable;

    if (toEncodable != null) {
      try {
        return toEncodable(o, this);
      } catch (_) {
        return _entityToJsonDefault(o);
      }
    }

    var oType = o.runtimeType;

    var classReflection = ReflectionFactory().getRegisterClassReflection(oType);

    if (classReflection != null) {
      try {
        return classReflection.toJson(o, this);
      } catch (_) {
        return _entityToJsonDefault(o);
      }
    }

    return _entityToJsonDefault(o);
  }

  static _entityToJsonDefault(dynamic o) {
    try {
      return o.toJson();
    } catch (_) {
      return '$o';
    }
  }

  @override
  String encode(Object? o, {bool pretty = false}) {
    var json = toJson(o);

    if (pretty) {
      return dart_convert.JsonEncoder.withIndent('  ').convert(json);
    } else {
      return dart_convert.json.encode(json);
    }
  }

  @override
  String convert(Object? input) => encode(input);
}

abstract class JsonDecoder extends JsonConverter<String, Object?> {
  static final JsonDecoder defaultCodec = _JsonDecoder.defaultCodec;

  factory JsonDecoder(
      {JsomMapDecoderProvider? jsomMapDecoderProvider,
      JsomMapDecoder? jsomMapDecoder,
      JsomMapDecoderAsyncProvider? jsomMapDecoderAsyncProvider,
      JsomMapDecoderAsync? jsomMapDecoderAsync,
      IterableCaster? iterableCaster}) {
    if (jsomMapDecoderProvider == null &&
        jsomMapDecoder == null &&
        jsomMapDecoderAsyncProvider == null &&
        jsomMapDecoderAsync == null &&
        iterableCaster == null) {
      return defaultCodec;
    }

    return _JsonDecoder._(jsomMapDecoderProvider, jsomMapDecoder,
        jsomMapDecoderAsyncProvider, jsomMapDecoderAsync, iterableCaster);
  }

  /// Converts [o] to [type].
  O? fromJson<O>(Object? o, {Type? type});

  /// Converts [o] to [type] allowing async calls ([Future] and [FutureOr]).
  FutureOr<O?> fromJsonAsync<O>(Object? o, {Type? type});

  /// Converts [o] to as [List] of [type].
  List<O?> fromJsonList<O>(Iterable o, {Type? type});

  /// Converts [o] to as [List] of [type] allowing async calls ([Future] and [FutureOr]).
  FutureOr<List<O?>> fromJsonListAsync<O>(Iterable o, {Type? type});

  /// Converts [map] to [type].
  O fromJsonMap<O>(Map<String, Object?> map, {Type? type});

  /// Converts [map] to [type] allowing async calls ([Future] and [FutureOr]).
  FutureOr<O> fromJsonMapAsync<O>(Map<String, Object?> map, {Type? type});

  /// Decodes [encodedJson] to a JSON collection/data.
  T decode<T>(String encodedJson, {Type? type});

  /// Decodes [encodedJson] to a JSON collection/data.
  FutureOr<T> decodeAsync<T>(FutureOr<String> encodedJson, {Type? type});
}

class _JsonDecoder extends dart_convert.Converter<String, Object?>
    implements JsonDecoder {
  static final _JsonDecoder defaultCodec =
      _JsonDecoder._(null, null, null, null, null);

  factory _JsonDecoder(
      JsomMapDecoderProvider? jsomMapDecoderProvider,
      JsomMapDecoder? jsomMapDecoder,
      JsomMapDecoderAsyncProvider? jsomMapDecoderAsyncProvider,
      JsomMapDecoderAsync? jsomMapDecoderAsync,
      IterableCaster? iterableCaster) {
    if (jsomMapDecoderProvider == null &&
        jsomMapDecoder == null &&
        jsomMapDecoderAsyncProvider == null &&
        jsomMapDecoderAsync == null &&
        iterableCaster == null) {
      return defaultCodec;
    }

    return _JsonDecoder._(jsomMapDecoderProvider, jsomMapDecoder,
        jsomMapDecoderAsyncProvider, jsomMapDecoderAsync, iterableCaster);
  }

  final JsomMapDecoderProvider? jsomMapDecoderProvider;
  final JsomMapDecoder? jsomMapDecoder;

  final JsomMapDecoderAsyncProvider? jsomMapDecoderAsyncProvider;
  final JsomMapDecoderAsync? jsomMapDecoderAsync;

  final IterableCaster? iterableCaster;

  _JsonDecoder._(
      this.jsomMapDecoderProvider,
      this.jsomMapDecoder,
      this.jsomMapDecoderAsyncProvider,
      this.jsomMapDecoderAsync,
      this.iterableCaster);

  @override
  O? fromJson<O>(Object? o, {Type? type}) {
    type ??= O;

    if (JsonConverter.isPrimitiveType(type)) {
      return o as O?;
    } else if (type == DateTime) {
      var dateTime = o is DateTime ? o : DateTime.parse(o.toString());
      return dateTime as O?;
    } else if (o is Map) {
      var map = o is Map<String, Object>
          ? o
          : o.map((k, v) => MapEntry(k.toString(), v));
      return fromJsonMap(map, type: type);
    } else if (o is Iterable) {
      return fromJsonList(o, type: type) as O?;
    } else {
      return o as O?;
    }
  }

  @override
  FutureOr<O?> fromJsonAsync<O>(Object? o, {Type? type}) {
    type ??= O;

    if (o is Future) {
      return o.then((value) => fromJsonAsync<O>(value, type: type));
    } else if (JsonConverter.isPrimitiveType(type)) {
      return o as O?;
    } else if (type == DateTime) {
      var dateTime = o is DateTime ? o : DateTime.parse(o.toString());
      return dateTime as O?;
    } else if (o is Map) {
      var map = o is Map<String, Object>
          ? o
          : o.map((k, v) => MapEntry(k.toString(), v));
      return fromJsonMapAsync<O>(map, type: type);
    } else if (o is Iterable) {
      return fromJsonListAsync(o, type: type) as O?;
    } else {
      return o as FutureOr<O?>;
    }
  }

  @override
  List<O?> fromJsonList<O>(Iterable o, {Type? type}) {
    type ??= O;
    return o.map((e) => fromJson(e, type: type)).cast<O>().toList();
  }

  @override
  FutureOr<List<O?>> fromJsonListAsync<O>(Iterable o, {Type? type}) {
    type ??= O;
    var listAsync = o.map((e) => fromJsonAsync(e, type: type)).toList();
    return _resolveList<O>(listAsync);
  }

  FutureOr<List<O?>> _resolveList<O>(List list) {
    var hasFuture = _listHasFuture(list);
    if (hasFuture) {
      var listFutures = _listElementsToFuture(list);
      return Future.wait(listFutures).then((l) => l.cast<O?>());
    } else {
      return list.cast<O?>();
    }
  }

  bool _listHasFuture(List list) => list.whereType<Future>().isNotEmpty;

  List<Future> _listElementsToFuture(List list) =>
      list.map((e) => e is Future ? e : Future.value(e)).toList();

  @override
  O fromJsonMap<O>(Map<String, Object?> map, {Type? type}) {
    type ??= O;

    if (JsonConverter.isValidEntityType(type)) {
      return _entityFromJsonMap<O>(type, map);
    }

    var jsomMapDecoder = this.jsomMapDecoder;
    if (jsomMapDecoder != null) {
      var obj = jsomMapDecoder(map, this);
      if (obj != null) {
        return obj;
      }
    }

    if (map is Map<String, String?> ||
        map is Map<String, num?> ||
        map is Map<String, bool?>) {
      return map as O;
    }

    var map2 = map.map((k, v) {
      var v2 = fromJson(v);
      return MapEntry(k, v2);
    });

    return map2 as O;
  }

  O _entityFromJsonMap<O>(Type type, Map<String, Object?> map) {
    var jsomMapDecoderProvider = this.jsomMapDecoderProvider;
    if (jsomMapDecoderProvider != null) {
      var fromJsonMap = jsomMapDecoderProvider(type);
      if (fromJsonMap != null) {
        return fromJsonMap(map, this);
      }
    }

    var jsomMapDecoder = this.jsomMapDecoder;
    if (jsomMapDecoder != null) {
      var obj = jsomMapDecoder(map, this);
      if (obj != null) {
        return obj;
      }
    }

    var classReflection = ReflectionFactory().getRegisterClassReflection(type);

    if (classReflection == null) {
      throw UnsupportedError(
          "Can't find registered ClassReflection for type: $type");
    }

    return classReflection.createInstanceFromMap(map,
        fieldValueResolver: _fieldValueResolver);
  }

  @override
  FutureOr<O> fromJsonMapAsync<O>(Map<String, Object?> map, {Type? type}) {
    type ??= O;

    if (JsonConverter.isValidEntityType(type)) {
      return _entityFromJsonMapAsync<O>(type, map);
    }

    var jsomMapDecoderAsync = this.jsomMapDecoderAsync;
    if (jsomMapDecoderAsync != null) {
      var futureOr = jsomMapDecoderAsync(map, this);
      if (futureOr != null) {
        return _castFutureOr<O>(futureOr);
      }
    }

    if (map is Map<String, String?> ||
        map is Map<String, num?> ||
        map is Map<String, bool?>) {
      return map as O;
    }

    var map2 = map.map((k, v) {
      var v2 = fromJson(v);
      return MapEntry(k, v2);
    });

    return map2 as O;
  }

  FutureOr<O> _entityFromJsonMapAsync<O>(Type type, Map<String, Object?> map) {
    var jsomMapDecoderAsyncProvider = this.jsomMapDecoderAsyncProvider;
    if (jsomMapDecoderAsyncProvider != null) {
      var fromJsonMapAsync = jsomMapDecoderAsyncProvider(type);
      if (fromJsonMapAsync != null) {
        var futureOr = fromJsonMapAsync(map, this);
        return _castFutureOr<O>(futureOr);
      }
    }

    var jsomMapDecoderAsync = this.jsomMapDecoderAsync;
    if (jsomMapDecoderAsync != null) {
      var futureOr = jsomMapDecoderAsync(map, this);
      if (futureOr != null) {
        return _castFutureOr<O>(futureOr);
      }
    }

    var classReflection = ReflectionFactory().getRegisterClassReflection(type);

    if (classReflection == null) {
      throw UnsupportedError(
          "Can't find registered ClassReflection for type: $type");
    }

    return classReflection.createInstanceFromMap(map,
        fieldValueResolver: _fieldValueResolver);
  }

  FutureOr<T> _castFutureOr<T>(FutureOr futureOr) {
    if (futureOr is T) return futureOr;
    if (futureOr is FutureOr<T>) return futureOr;

    if (futureOr is Future) {
      return futureOr.then((value) => value as T);
    } else {
      return futureOr as T;
    }
  }

  Object? _fieldValueResolver(
      String field, Object? value, TypeReflection type) {
    if (type.isListEntity && value is Iterable) {
      return _castEntityList(value, type);
    } else {
      return fromJson(value, type: type.type);
    }
  }

  Object? _castEntityList(Iterable value, TypeReflection type) {
    var iterableCaster = this.iterableCaster;
    if (iterableCaster != null) {
      var casted = iterableCaster(value, type);
      if (casted != null) {
        return casted;
      }
    }

    var entityType = type.listEntityType!;
    var val = fromJson(value, type: entityType.type);

    var classReflection =
        ReflectionFactory().getRegisterClassReflection(entityType.type);

    if (classReflection != null) {
      return classReflection.castList(val, entityType.type) ?? val;
    } else {
      return val;
    }
  }

  @override
  T decode<T>(String encodedJson, {Type? type}) {
    type ??= T;
    var json = dart_convert.json.decode(encodedJson);
    return fromJson<T>(json, type: type) as T;
  }

  @override
  FutureOr<T> decodeAsync<T>(FutureOr<String> encodedJson, {Type? type}) {
    type ??= T;

    if (encodedJson is Future<String>) {
      return encodedJson.then((value) => decodeAsync<T>(value, type: type));
    }

    var json = dart_convert.json.decode(encodedJson);
    return fromJsonAsync<T>(json, type: type) as T;
  }

  @override
  Object? convert(String input) => decode<dynamic>(input);
}
