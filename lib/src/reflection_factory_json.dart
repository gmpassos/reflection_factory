import 'dart:async';
import 'dart:convert' as dart_convert;
import 'dart:typed_data';

import 'package:base_codecs/base_codecs.dart';
import 'package:mime/mime.dart';

import 'reflection_factory_base.dart';

final MimeTypeResolver jsonMimeTypeResolver = _createMimeTypeResolver();

MimeTypeResolver _createMimeTypeResolver() {
  var mimeTypeResolver = MimeTypeResolver();

  mimeTypeResolver.addMap({
    'application/pkcs8': ['p8', 'key'],
    'application/pkcs10': ['p10', 'csr'],
    'application/pkix-cert': 'cer',
    'application/pkix-crl': 'crl',
    'application/pkcs7-mime': 'p7c',
    'application/x-x509-ca-cert': ['crt', 'der'],
    'application/x-x509-user-cert': 'crt',
    'application/x-pkcs7-crl': 'crl',
    'application/x-pem-file': 'pem',
    'application/x-pkcs12': ['p12', 'pfx'],
    'application/x-pkcs7-certificates': ['p7b', 'spc'],
    'application/x-pkcs7-certreqresp': 'p7r',
    'application/signature-ec': [0, 0, 0, 77],
    'application/signature': 'signature',
  });

  return mimeTypeResolver;
}

extension MimeTypeResolverExtension on MimeTypeResolver {
  String lookupDynamic(String extension,
      {List<int>? headerBytes,
      String defaultMimeType = 'application/octet-stream'}) {
    extension = extension.toLowerCase().trim();

    var mimeType = lookup(extension, headerBytes: headerBytes);
    if (mimeType != null && mimeType.isNotEmpty) {
      return mimeType;
    }

    var fieldNameLength = extension.length;

    if (fieldNameLength > 1) {
      var f2 = extension.substring(0, fieldNameLength - 1);
      mimeType = lookup(f2);
      if (mimeType != null && mimeType.isNotEmpty) {
        return mimeType;
      }
    }

    if (fieldNameLength > 2) {
      var f2 = extension.substring(0, fieldNameLength - 2) +
          extension.substring(fieldNameLength - 1);
      mimeType = lookup(f2);
      if (mimeType != null && mimeType.isNotEmpty) {
        return mimeType;
      }
    }

    return defaultMimeType;
  }

  void addMap(Map<String, dynamic> map) {
    for (var e in map.entries) {
      addDynamic(e.value, e.key);
    }
  }

  void addDynamic(dynamic value, String mimeType) {
    if (value is String) {
      addExtension(value, mimeType);
    } else if (value is List<int>) {
      addMagicNumber(value, mimeType);
    } else if (value is List) {
      for (var v in value) {
        addDynamic(v, mimeType);
      }
    }
  }

  void addExtensionAndMagicNumber(
      String extension, String mimeType, List<int> bytes,
      {List<int>? mask}) {
    if (extension.isNotEmpty) {
      addExtension(extension, mimeType);
    }

    if (bytes.isNotEmpty) {
      addMagicNumber(bytes, mimeType, mask: mask);
    }
  }
}

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
      JsonCodec._(JsonEncoder.defaultDecoder, JsonDecoder.defaultDecoder);

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
  FutureOr<List<O?>> fromJsonListAsync<O>(FutureOr<Iterable> o, {Type? type}) {
    return decoder.fromJsonListAsync<O>(o, type: type);
  }

  /// Converts [map] to [type].
  O fromJsonMap<O>(Map<String, Object?> map, {Type? type}) {
    return decoder.fromJsonMap<O>(map, type: type);
  }

  /// Converts [map] to [type] allowing async calls ([Future] and [FutureOr]).
  FutureOr<O> fromJsonMapAsync<O>(FutureOr<Map<String, Object?>> map,
      {Type? type}) {
    return decoder.fromJsonMapAsync<O>(map, type: type);
  }

  /// Transforms [o] to an encoded JSON.
  /// - If [pretty] is `true` generates a pretty JSON, with indentation and line break.
  String encode(Object? o, {bool pretty = false}) {
    return encoder.encode(o, pretty: pretty);
  }

  /// Sames as [encode] but returns a [Uint8List].
  Uint8List encodeToBytes(Object? o, {bool pretty = false}) =>
      encoder.encodeToBytes(o, pretty: pretty);

  /// Decodes [encodedJson] to a JSON collection/data.
  T decode<T>(String encodedJson, {Type? type}) {
    return decoder.decode<T>(encodedJson, type: type);
  }

  /// Sames as [decode] but from a [Uint8List].
  T decodeFromBytes<T>(Uint8List encodedJsonBytes, {Type? type}) {
    return decoder.decodeFromBytes<T>(encodedJsonBytes, type: type);
  }

  /// Decodes [encodedJson] to a JSON collection/data allowing async calls ([Future] and [FutureOr]).
  FutureOr<T> decodeAsync<T>(FutureOr<String> encodedJson, {Type? type}) {
    return decoder.decodeAsync<T>(encodedJson, type: type);
  }

  /// Sames as [decodeAsync] but from a [Uint8List].
  FutureOr<T> decodeFromBytesAsync<T>(FutureOr<Uint8List> encodedJsonBytes,
      {Type? type}) {
    return decoder.decodeFromBytesAsync<T>(encodedJsonBytes, type: type);
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
  static final JsonEncoder defaultDecoder = _JsonEncoder._defaultEncoder;

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
      return defaultDecoder;
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

  /// Sames as [encode] but returns a [Uint8List].
  Uint8List encodeToBytes(Object? o, {bool pretty = false});
}

class _JsonEncoder extends dart_convert.Converter<Object?, String>
    implements JsonEncoder {
  static final _JsonEncoder _defaultEncoder =
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
      return _defaultEncoder;
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

  Object? _valueToJson(o, {String? fieldName}) {
    if (o == null) {
      return null;
    } else if (o is String || o is num || o is bool) {
      return o;
    } else if (o is DateTime) {
      return _dateTimeToJson(o);
    } else if (o is Uint8List) {
      return _uint8ListToJson(o, fieldName);
    } else if (o is BigInt) {
      return _bigIntToJson(o);
    } else if (o is Enum) {
      return _enumToJson(o);
    } else if (o is Map) {
      return mapToJson(o);
    } else if (o is Set) {
      return _iterableToJson(o, fieldName).toList();
    } else if (o is Iterable) {
      return _iterableToJson(o, fieldName).toList();
    } else {
      var entityJson = _entityToJson(o);
      var json = _valueToJson(entityJson, fieldName: fieldName);
      return json;
    }
  }

  Object? _enumToJson(Enum o) {
    var s = o.toString();
    var idx = s.indexOf('.');
    var name = idx > 0 ? s.substring(idx + 1) : s;
    return name;
  }

  Object? _uint8ListToJson(Uint8List o, String? fieldName) {
    fieldName ??= '?';
    var mimeType =
        jsonMimeTypeResolver.lookupDynamic(fieldName, headerBytes: o);

    var base64 = dart_convert.base64.encode(o);
    return 'data:$mimeType;base64,$base64';
  }

  Iterable<Object?> _iterableToJson(Iterable<dynamic> o, String? fieldName) {
    return o.map((e) => _valueToJson(e, fieldName: fieldName));
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
      var key = e.key?.toString() ?? '';
      var value = _mapKeyValueToJson(key, e.value);
      return MapEntry<String, dynamic>(key, value);
    });

    return Map<String, dynamic>.fromEntries(entries);
  }

  String _dateTimeToJson(DateTime o) {
    return o.toUtc().toString();
  }

  Object _bigIntToJson(BigInt o) {
    if (o.bitLength > 32) {
      return o.toString();
    } else {
      return o.toInt();
    }
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

    return _valueToJson(o, fieldName: k);
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

  @override
  Uint8List encodeToBytes(Object? o, {bool pretty = false}) {
    var json = toJson(o);

    if (pretty) {
      return dart_convert.JsonUtf8Encoder('  ').convert(json).toUint8List();
    } else {
      return dart_convert.JsonUtf8Encoder().convert(json).toUint8List();
    }
  }
}

abstract class JsonDecoder extends JsonConverter<String, Object?> {
  static final JsonDecoder defaultDecoder = _JsonDecoder._defaultDecoder;

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
      return defaultDecoder;
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
  FutureOr<List<O?>> fromJsonListAsync<O>(FutureOr<Iterable> o, {Type? type});

  /// Converts [map] to [type].
  O fromJsonMap<O>(Map<String, Object?> map, {Type? type});

  /// Converts [map] to [type] allowing async calls ([Future] and [FutureOr]).
  FutureOr<O> fromJsonMapAsync<O>(FutureOr<Map<String, Object?>> map,
      {Type? type});

  /// Decodes [encodedJson] to a JSON collection/data.
  T decode<T>(String encodedJson, {Type? type});

  /// Sames as [decode] but from a [Uint8List].
  T decodeFromBytes<T>(Uint8List encodedJsonBytes, {Type? type});

  /// Decodes [encodedJson] to a JSON collection/data.
  FutureOr<T> decodeAsync<T>(FutureOr<String> encodedJson, {Type? type});

  /// Sames as [decodeAsync] but from a [Uint8List].
  FutureOr<T> decodeFromBytesAsync<T>(FutureOr<Uint8List> encodedJsonBytes,
      {Type? type});
}

class _JsonDecoder extends dart_convert.Converter<String, Object?>
    implements JsonDecoder {
  static final _JsonDecoder _defaultDecoder =
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
      return _defaultDecoder;
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
      return _parseDateTime(o) as O?;
    } else if (type == Uint8List) {
      return _parseBytes(o) as O?;
    } else if (type == BigInt) {
      return _parseBigInt(o) as O?;
    } else if (o is Map) {
      var map = o is Map<String, Object>
          ? o
          : o.map((k, v) => MapEntry(k.toString(), v));
      return fromJsonMap(map, type: type);
    } else if (o is Iterable) {
      return fromJsonList(o, type: type) as O?;
    } else if (o is String) {
      return _entityFromJsonString(type, o);
    } else {
      if (o == null) {
        return null;
      }
      return _entityFromJsonValue(type, o);
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
      return _parseDateTime(o) as O?;
    } else if (type == Uint8List) {
      return _parseBytes(o) as O?;
    } else if (type == BigInt) {
      return _parseBigInt(o) as O?;
    } else if (o is Map) {
      var map = o is Map<String, Object>
          ? o
          : o.map((k, v) => MapEntry(k.toString(), v));
      return fromJsonMapAsync<O>(map, type: type);
    } else if (o is Iterable) {
      return fromJsonListAsync(o, type: type) as O?;
    } else if (o is String) {
      return _entityFromJsonString(type, o);
    } else {
      if (o == null) {
        return null;
      }
      return _entityFromJsonValue(type, o);
    }
  }

  DateTime? _parseDateTime(Object? o) {
    if (o == null) return null;
    if (o is DateTime) return o;
    return DateTime.tryParse(o.toString());
  }

  BigInt? _parseBigInt(Object? o) {
    if (o == null) return null;
    if (o is BigInt) return o;

    if (o is int) {
      return BigInt.from(o);
    } else {
      return BigInt.tryParse(o.toString());
    }
  }

  Uint8List? _parseBytes(Object? o) {
    if (o == null) return null;
    if (o is Uint8List) return o;

    if (o is List<int>) return Uint8List.fromList(o);

    if (o is String) {
      if (o.startsWith('data:')) {
        var idx1 = o.indexOf(';');
        var idx2 = o.indexOf(',');

        String type;
        String encoding;

        if (idx1 < 0) {
          type = o.substring(5, idx2);
          encoding = '';
        } else {
          type = o.substring(5, idx1);
          encoding = o.substring(idx1 + 1, idx2);
        }

        type = type.toLowerCase().trim();
        encoding = encoding.toLowerCase().trim();

        var data = o.substring(idx2 + 1);

        if (encoding == 'base64') {
          return dart_convert.base64.decode(data);
        } else if (encoding.isEmpty) {
          return Uint8List.fromList(dart_convert.utf8.encode(data));
        }
      } else {
        try {
          return base16Decode(o);
        } catch (_) {
          try {
            return dart_convert.base64.decode(o);
          } catch (_) {
            return null;
          }
        }
      }
    }

    return null;
  }

  @override
  List<O?> fromJsonList<O>(Iterable o, {Type? type}) {
    type ??= O;
    return o.map((e) => fromJson(e, type: type)).cast<O>().toList();
  }

  @override
  FutureOr<List<O?>> fromJsonListAsync<O>(FutureOr<Iterable> o, {Type? type}) {
    type ??= O;

    if (o is Future<Iterable>) {
      return o.then((value) => fromJsonListAsync<O>(value, type: type));
    }

    var listAsync = o.map((e) => fromJsonAsync(e, type: type)).toList();
    return _resolveList<O>(listAsync);
  }

  Future _valueToFuture(Object? e) => e is Future ? e : Future.value(e);

  bool _valueHasFuture(Object? e) {
    if (e is Future) {
      return true;
    } else if (e is List) {
      return _listHasFuture(e);
    } else if (e is Map) {
      return _mapHasFuture(e);
    } else {
      return false;
    }
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

  bool _listHasFuture(List list) => list.where(_valueHasFuture).isNotEmpty;

  List<Future> _listElementsToFuture(List list) =>
      list.map((e) => _valueToFuture(e)).toList();

  FutureOr<Map<K, V>> _resolveMap<K, V>(Map map) {
    var hasFuture = _mapHasFuture(map);
    if (hasFuture) {
      var mapEntriesFutures = _mapEntriesToFuture(map);
      return Future.wait(mapEntriesFutures)
          .then((entries) => Map.fromEntries(entries).cast<K, V>());
    } else {
      return map.cast<K, V>();
    }
  }

  List<Future<MapEntry>> _mapEntriesToFuture(Map map) =>
      map.entries.map((e) async {
        var k = await e.key;
        var v = await e.value;
        return Future.value(MapEntry(k, v));
      }).toList();

  bool _mapHasFuture(Map map) => map.entries
      .where((e) => _valueHasFuture(e.key) || _valueHasFuture(e.value))
      .isNotEmpty;

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

  O _entityFromJsonString<O>(Type type, String s) {
    var enumReflection = ReflectionFactory().getRegisterEnumReflection(type);

    if (enumReflection != null) {
      return enumReflection.from(s);
    }

    var classReflection = ReflectionFactory().getRegisterClassReflection(type);

    if (classReflection != null) {
      var constructors = classReflection
          .allConstructors()
          .where((c) => c.parametersLength > 0)
          .where(
              (c) => c.parametersWhere((p) => p.type.isStringType).isNotEmpty)
          .toList();

      var constructorsParamString =
          constructors.where((c) => c.parametersLength == 1).toList();

      var c = constructorsParamString.first;
      var obj = c.invoke([s]);
      return obj;
    }

    throw UnsupportedError("Can't find registered Reflection for type: $type");
  }

  O _entityFromJsonValue<O>(Type type, Object value) {
    if (!JsonConverter.isValidEntityType(type)) {
      return value as O;
    }

    var enumReflection = ReflectionFactory().getRegisterEnumReflection(type);

    if (enumReflection != null) {
      return enumReflection.from(value);
    }

    var classReflection = ReflectionFactory().getRegisterClassReflection(type);

    if (classReflection != null) {
      var valueType = value.runtimeType;

      var constructorsWithParameters = classReflection
          .allConstructors()
          .where((c) => c.parametersLength > 0)
          .toList();

      var constructorsWithParamType = constructorsWithParameters
          .where((c) =>
              c.parametersWhere((p) => p.type.type == valueType).isNotEmpty)
          .toList();

      var constructors = constructorsWithParamType
          .where((c) => c.parametersLength == 1)
          .toList();

      if (constructors.isEmpty) {
        var constructorsWithParamObject = constructorsWithParameters
            .where((c) => c
                .parametersWhere((p) => p.type.isObjectOrDynamicType)
                .isNotEmpty)
            .toList();

        constructors = constructorsWithParamObject
            .where((c) => c.parametersLength == 1)
            .toList();
      }

      if (constructors.isNotEmpty) {
        var c = constructors.first;
        var obj = c.invoke([value]);
        return obj;
      }
    }

    return value as O;
  }

  @override
  FutureOr<O> fromJsonMapAsync<O>(FutureOr<Map<String, Object?>> map,
      {Type? type}) {
    type ??= O;

    if (map is Future<Map<String, Object?>>) {
      return map.then((value) => fromJsonMapAsync<O>(value, type: type));
    }

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

    var mapResolved = _resolveMap<String, Object?>(map);

    if (mapResolved is Future<Map<String, Object?>>) {
      return mapResolved.then((mapResolved2) {
        return classReflection.createInstanceFromMap(mapResolved2,
            fieldValueResolver: _fieldValueResolver);
      });
    } else {
      return classReflection.createInstanceFromMap(map,
          fieldValueResolver: _fieldValueResolver);
    }
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
    if (type.isIterableType && value is Iterable) {
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
    var castType = entityType.type;
    var val = fromJsonList(value, type: castType);

    var classReflection =
        ReflectionFactory().getRegisterClassReflection(castType);

    if (classReflection != null) {
      return classReflection.castList(val, castType) ?? val;
    } else {
      return castListType(val, castType);
    }
  }

  @override
  T decode<T>(String encodedJson, {Type? type}) {
    type ??= T;
    var json = dart_convert.json.decode(encodedJson);
    return fromJson<T>(json, type: type) as T;
  }

  /// Sames as [decode] but from a [Uint8List].
  @override
  T decodeFromBytes<T>(Uint8List encodedJsonBytes, {Type? type}) {
    var encodedJson = dart_convert.utf8.decode(encodedJsonBytes);
    return decode<T>(encodedJson, type: type);
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

  /// Sames as [decodeAsync] but from a [Uint8List].
  @override
  FutureOr<T> decodeFromBytesAsync<T>(FutureOr<Uint8List> encodedJsonBytes,
      {Type? type}) {
    type ??= T;

    if (encodedJsonBytes is Future<Uint8List>) {
      return encodedJsonBytes
          .then((value) => decodeFromBytesAsync<T>(value, type: type));
    }

    var encodedJson = dart_convert.utf8.decode(encodedJsonBytes);
    return decodeAsync<T>(encodedJson, type: type);
  }

  @override
  Object? convert(String input) => decode<dynamic>(input);
}

List castListType<T>(List list, Type type) {
  if (list is List<T> && T != dynamic && T != Object) {
    return list;
  } else if (type == String) {
    return list.cast<String>();
  } else if (type == int) {
    return list.cast<int>();
  } else if (type == double) {
    return list.cast<double>();
  } else if (type == num) {
    return list.cast<num>();
  } else if (type == bool) {
    return list.cast<bool>();
  } else if (type == DateTime) {
    return list.cast<DateTime>();
  } else if (type == BigInt) {
    return list.cast<BigInt>();
  } else if (type == Uint8List) {
    return list.cast<Uint8List>();
  } else {
    return list;
  }
}

extension _ListIntExtension on List<int> {
  Uint8List toUint8List() {
    var o = this;
    return o is Uint8List ? o : Uint8List.fromList(o);
  }
}
