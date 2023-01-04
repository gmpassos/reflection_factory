import 'dart:async';
import 'dart:convert' as dart_convert;
import 'dart:typed_data';

import 'package:base_codecs/base_codecs.dart' as base_codecs;
import 'package:collection/collection.dart';
import 'package:mime/mime.dart';

import 'reflection_factory_base.dart';
import 'reflection_factory_type.dart';

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

typedef ToEncodableJsonProvider = ToEncodableJson? Function(Object object);

typedef JsonValueDecoder<O> = O? Function(
    Object? o, Type type, JsonDecoder jsonDecoder);

typedef JsonValueDecoderProvider<O> = JsonValueDecoder<O>? Function(
    Type type, Object? value);

typedef JsomMapDecoder<O> = O? Function(
    Map<String, Object?> map, JsonDecoder jsonDecoder);

typedef JsomMapDecoderProvider = JsomMapDecoder? Function(
    Type type, Map<String, Object?> map);

typedef JsomMapDecoderAsync<O> = FutureOr<O?> Function(
    Map<String, Object?> map, JsonDecoder jsonDecoder);

typedef JsomMapDecoderAsyncProvider = JsomMapDecoderAsync? Function(
    Type type, Map<String, Object?> map);

typedef IterableCaster = Object? Function(Iterable value, TypeReflection type);

typedef MapCaster = Object? Function(Map value, TypeReflection type);

/// JSON codec integrated with [ReflectionFactory].
class JsonCodec {
  static final JsonCodec defaultCodec =
      JsonCodec._(JsonEncoder.defaultEncoder, JsonDecoder.defaultDecoder);

  factory JsonCodec(
      {JsonFieldMatcher? maskField,
      String maskText = '***',
      JsonFieldMatcher? removeField,
      bool removeNullFields = false,
      ToEncodableJsonProvider? toEncodableProvider,
      ToEncodableJson? toEncodable,
      JsonValueDecoderProvider? jsonValueDecoderProvider,
      JsomMapDecoderProvider? jsomMapDecoderProvider,
      JsomMapDecoder? jsomMapDecoder,
      JsomMapDecoderAsyncProvider? jsomMapDecoderAsyncProvider,
      JsomMapDecoderAsync? jsomMapDecoderAsync,
      IterableCaster? iterableCaster,
      MapCaster? mapCaster,
      JsonEntityCache? entityCache,
      bool forceDuplicatedEntitiesAsID = false,
      autoResetEntityCache = true}) {
    if (maskField == null &&
        removeField == null &&
        !removeNullFields &&
        toEncodableProvider == null &&
        toEncodable == null &&
        jsomMapDecoderProvider == null &&
        jsomMapDecoder == null &&
        jsomMapDecoderAsyncProvider == null &&
        jsomMapDecoderAsync == null &&
        iterableCaster == null &&
        mapCaster == null &&
        entityCache == null &&
        !forceDuplicatedEntitiesAsID &&
        autoResetEntityCache) {
      return defaultCodec;
    }

    return JsonCodec._(
        _JsonEncoder(
            maskField,
            maskText,
            removeField,
            removeNullFields,
            toEncodableProvider,
            toEncodable,
            entityCache,
            forceDuplicatedEntitiesAsID,
            autoResetEntityCache),
        _JsonDecoder(
            jsonValueDecoderProvider,
            jsomMapDecoderProvider,
            jsomMapDecoder,
            jsomMapDecoderAsyncProvider,
            jsomMapDecoderAsync,
            iterableCaster,
            mapCaster,
            entityCache,
            forceDuplicatedEntitiesAsID,
            autoResetEntityCache));
  }

  /// The [JsonEncoder] of this instance.
  final JsonEncoder encoder;

  /// The [JsonDecoder] of this instance.
  final JsonDecoder decoder;

  JsonCodec._(this.encoder, this.decoder);

  /// Converts [o] to a JSON collection/data.
  /// - [maskField] when preset indicates if a field value should be masked with [maskText].
  T? toJson<T>(Object? o,
      {bool duplicatedEntitiesAsID = false, bool? autoResetEntityCache}) {
    return encoder.toJson<T>(o,
        duplicatedEntitiesAsID: duplicatedEntitiesAsID,
        autoResetEntityCache: autoResetEntityCache);
  }

  /// Converts [o] to [type].
  O? fromJson<O>(Object? o,
      {Type? type,
      TypeInfo? typeInfo,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache}) {
    return decoder.fromJson<O>(o,
        type: type,
        typeInfo: typeInfo,
        duplicatedEntitiesAsID: duplicatedEntitiesAsID,
        autoResetEntityCache: autoResetEntityCache);
  }

  /// Converts [o] to [type] allowing async calls ([Future] and [FutureOr]).
  FutureOr<O?> fromJsonAsync<O>(Object? o,
      {Type? type,
      TypeInfo? typeInfo,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache}) {
    return decoder.fromJsonAsync<O>(o,
        type: type,
        typeInfo: typeInfo,
        duplicatedEntitiesAsID: duplicatedEntitiesAsID,
        autoResetEntityCache: autoResetEntityCache);
  }

  /// Converts [o] to as [List] of [type].
  List<O?> fromJsonList<O>(Iterable o,
      {Type? type,
      TypeInfo? typeInfo,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache}) {
    return decoder.fromJsonList<O>(o,
        type: type,
        typeInfo: typeInfo,
        duplicatedEntitiesAsID: duplicatedEntitiesAsID,
        autoResetEntityCache: autoResetEntityCache);
  }

  /// Converts [o] to as [List] of [type] allowing async calls ([Future] and [FutureOr]).
  FutureOr<List<O?>> fromJsonListAsync<O>(FutureOr<Iterable> o,
      {Type? type,
      TypeInfo? typeInfo,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache}) {
    return decoder.fromJsonListAsync<O>(o,
        type: type,
        typeInfo: typeInfo,
        duplicatedEntitiesAsID: duplicatedEntitiesAsID,
        autoResetEntityCache: autoResetEntityCache);
  }

  /// Converts [map] to [type].
  O fromJsonMap<O>(Map<String, Object?> map,
      {Type? type,
      TypeInfo? typeInfo,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache}) {
    return decoder.fromJsonMap<O>(map,
        type: type,
        typeInfo: typeInfo,
        duplicatedEntitiesAsID: duplicatedEntitiesAsID,
        autoResetEntityCache: autoResetEntityCache);
  }

  /// Converts [map] to [type] allowing async calls ([Future] and [FutureOr]).
  FutureOr<O> fromJsonMapAsync<O>(FutureOr<Map<String, Object?>> map,
      {Type? type,
      TypeInfo? typeInfo,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache}) {
    return decoder.fromJsonMapAsync<O>(map,
        type: type,
        typeInfo: typeInfo,
        duplicatedEntitiesAsID: duplicatedEntitiesAsID,
        autoResetEntityCache: autoResetEntityCache);
  }

  /// Transforms [o] to an encoded JSON.
  /// - If [pretty] is `true` generates a pretty JSON, with indentation and line break.
  String encode(Object? o,
      {bool pretty = false,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache}) {
    return encoder.encode(o,
        pretty: pretty,
        duplicatedEntitiesAsID: duplicatedEntitiesAsID,
        autoResetEntityCache: autoResetEntityCache);
  }

  /// Sames as [encode] but returns a [Uint8List].
  Uint8List encodeToBytes(Object? o,
          {bool pretty = false,
          bool duplicatedEntitiesAsID = false,
          bool? autoResetEntityCache}) =>
      encoder.encodeToBytes(o,
          pretty: pretty,
          duplicatedEntitiesAsID: duplicatedEntitiesAsID,
          autoResetEntityCache: autoResetEntityCache);

  /// Decodes [encodedJson] to a JSON collection/data.
  T decode<T>(String encodedJson,
      {Type? type,
      TypeInfo? typeInfo,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache}) {
    return decoder.decode<T>(encodedJson,
        type: type,
        typeInfo: typeInfo,
        duplicatedEntitiesAsID: duplicatedEntitiesAsID,
        autoResetEntityCache: autoResetEntityCache);
  }

  /// Sames as [decode] but from a [Uint8List].
  T decodeFromBytes<T>(Uint8List encodedJsonBytes,
      {Type? type,
      TypeInfo? typeInfo,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache}) {
    return decoder.decodeFromBytes<T>(encodedJsonBytes,
        type: type,
        typeInfo: typeInfo,
        duplicatedEntitiesAsID: duplicatedEntitiesAsID,
        autoResetEntityCache: autoResetEntityCache);
  }

  /// Decodes [encodedJson] to a JSON collection/data allowing async calls ([Future] and [FutureOr]).
  FutureOr<T> decodeAsync<T>(FutureOr<String> encodedJson,
      {Type? type,
      TypeInfo? typeInfo,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache}) {
    return decoder.decodeAsync<T>(encodedJson,
        type: type,
        typeInfo: typeInfo,
        duplicatedEntitiesAsID: duplicatedEntitiesAsID,
        autoResetEntityCache: autoResetEntityCache);
  }

  /// Sames as [decodeAsync] but from a [Uint8List].
  FutureOr<T> decodeFromBytesAsync<T>(FutureOr<Uint8List> encodedJsonBytes,
      {Type? type,
      TypeInfo? typeInfo,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache}) {
    return decoder.decodeFromBytesAsync<T>(encodedJsonBytes,
        type: type,
        typeInfo: typeInfo,
        duplicatedEntitiesAsID: duplicatedEntitiesAsID,
        autoResetEntityCache: autoResetEntityCache);
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
        type != DateTime &&
        !isCollectionType(type) &&
        !isPrimitiveType(type);
  }
}

typedef JsonTypeToEncodable<T> = Object? Function(T object);

/// A JSON encoder.
abstract class JsonEncoder extends JsonConverter<Object?, String> {
  static final Map<Type, ToEncodableJson> _registeredTypeToEncodable =
      <Type, ToEncodableJson>{};

  static void registerTypeToEncodable(Type type, ToEncodableJson toEncodable) {
    _registeredTypeToEncodable[type] = toEncodable;
  }

  static ToEncodableJson? getTypeToEncodable(Type type) =>
      _registeredTypeToEncodable[type];

  static ToEncodableJson? removeTypeToEncodable(Type type) =>
      _registeredTypeToEncodable.remove(type);

  static final JsonEncoder defaultEncoder = _JsonEncoder._defaultEncoder;

  factory JsonEncoder(
      {JsonFieldMatcher? maskField,
      String maskText = '***',
      JsonFieldMatcher? removeField,
      bool removeNullFields = false,
      ToEncodableJsonProvider? toEncodableProvider,
      ToEncodableJson? toEncodable,
      JsonEntityCache? entityCache,
      bool forceDuplicatedEntitiesAsID = false,
      autoResetEntityCache = true}) {
    if (maskField == null &&
        removeField == null &&
        !removeNullFields &&
        toEncodableProvider == null &&
        toEncodable == null &&
        entityCache == null &&
        !forceDuplicatedEntitiesAsID &&
        autoResetEntityCache) {
      return defaultEncoder;
    }

    return _JsonEncoder._(
        maskField,
        maskText,
        removeField,
        removeNullFields,
        toEncodableProvider,
        toEncodable,
        entityCache,
        forceDuplicatedEntitiesAsID,
        autoResetEntityCache);
  }

  /// Returns `true` if the entity cache is automatically reset for each
  /// encoding session.
  bool get autoResetEntityCache;

  /// Resets the entities cache used to resolve duplicated entities in the same tree.
  void resetEntityCache();

  /// Converts [o] to a JSON collection/data.
  /// - [maskField] when preset indicates if a field value should be masked with [maskText].
  T? toJson<T>(Object? o,
      {bool duplicatedEntitiesAsID = false, bool? autoResetEntityCache});

  /// Converts [map] tree to a JSON.
  Map<String, dynamic> mapToJson(Map map,
      {bool duplicatedEntitiesAsID = false, bool? autoResetEntityCache});

  /// Transforms [o] to an encoded JSON.
  /// - If [pretty] is `true` generates a pretty JSON, with indentation and line break.
  String encode(Object? o,
      {bool pretty = false,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache});

  /// Sames as [encode] but returns a [Uint8List].
  Uint8List encodeToBytes(Object? o,
      {bool pretty = false,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache});
}

class _JsonEncoder extends dart_convert.Converter<Object?, String>
    implements JsonEncoder {
  static final _JsonEncoder _defaultEncoder =
      _JsonEncoder._(null, '***', null, false, null, null, null, false, true);

  factory _JsonEncoder(
      JsonFieldMatcher? maskField,
      String maskText,
      JsonFieldMatcher? removeField,
      bool removeNullFields,
      ToEncodableJsonProvider? toEncodableProvider,
      ToEncodableJson? toEncodable,
      JsonEntityCache? entityCache,
      bool forceDuplicatedEntitiesAsID,
      bool autoResetEntityCache) {
    if (maskField == null &&
        removeField == null &&
        !removeNullFields &&
        toEncodableProvider == null &&
        toEncodable == null &&
        entityCache == null &&
        !forceDuplicatedEntitiesAsID &&
        autoResetEntityCache) {
      return _defaultEncoder;
    }

    return _JsonEncoder._(
        maskField,
        maskText,
        removeField,
        removeNullFields,
        toEncodableProvider,
        toEncodable,
        entityCache,
        forceDuplicatedEntitiesAsID,
        autoResetEntityCache);
  }

  final JsonFieldMatcher? maskField;
  final String maskText;

  final JsonFieldMatcher? removeField;
  final bool removeNullFields;

  final ToEncodableJsonProvider? toEncodableProvider;

  final ToEncodableJson? toEncodable;

  final JsonEntityCache entityCache;

  final bool forceDuplicatedEntitiesAsID;

  @override
  final bool autoResetEntityCache;

  _JsonEncoder._(
    this.maskField,
    this.maskText,
    this.removeField,
    this.removeNullFields,
    this.toEncodableProvider,
    this.toEncodable,
    JsonEntityCache? entityCache,
    this.forceDuplicatedEntitiesAsID,
    this.autoResetEntityCache,
  ) : entityCache = entityCache ?? JsonEntityCacheSimple();

  @override
  void resetEntityCache() {
    entityCache.clearCachedEntities();
  }

  @override
  T? toJson<T>(Object? o,
      {bool duplicatedEntitiesAsID = false, bool? autoResetEntityCache}) {
    _resetEntityCache(autoResetEntityCache);
    var json = _valueToJson(o, null, duplicatedEntitiesAsID) as T?;
    _resetEntityCache(autoResetEntityCache);
    return json;
  }

  void _resetEntityCache(bool? resetEntityCache) {
    if (resetEntityCache != null) {
      if (resetEntityCache) {
        entityCache.clearCachedEntities();
      }
    } else if (autoResetEntityCache) {
      entityCache.clearCachedEntities();
    }
  }

  Object? _valueToJson(o, String? fieldName, bool duplicatedEntitiesAsID) {
    if (o == null) {
      return null;
    } else if (o is String || o is num || o is bool) {
      return o;
    } else if (o is Map) {
      return _mapToJsonImpl(o, duplicatedEntitiesAsID);
    } else if (o is Set) {
      return _iterableToJson(o, fieldName, duplicatedEntitiesAsID);
    } else if (o is Iterable) {
      return _iterableToJson(o, fieldName, duplicatedEntitiesAsID);
    } else {
      var objectJson = _objectToJson(o, fieldName, duplicatedEntitiesAsID);
      var json = _valueToJson(objectJson, fieldName, duplicatedEntitiesAsID);
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

    if (mimeType == 'application/octet-stream') {
      var hex = base_codecs.hex.encode(o);
      return 'hex:$hex';
    }

    var base64 = dart_convert.base64.encode(o);
    return 'data:$mimeType;base64,$base64';
  }

  Object? _iterableToJson(
      Iterable<dynamic> o, String? fieldName, bool duplicatedEntitiesAsID) {
    if (o is Uint8List) {
      return _uint8ListToJson(o, fieldName);
    }

    return o
        .map((e) => _valueToJson(e, fieldName, duplicatedEntitiesAsID))
        .toList();
  }

  @override
  Map<String, dynamic> mapToJson(Map map,
      {bool duplicatedEntitiesAsID = false, bool? autoResetEntityCache}) {
    _resetEntityCache(autoResetEntityCache);
    var obj = _mapToJsonImpl(map, duplicatedEntitiesAsID);
    _resetEntityCache(autoResetEntityCache);
    return obj;
  }

  Map<String, dynamic> _mapToJsonImpl(Map map, bool duplicatedEntitiesAsID) {
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
      var value = _mapKeyValueToJson(key, e.value, duplicatedEntitiesAsID);
      return MapEntry<String, dynamic>(key, value);
    });

    var json = Map<String, dynamic>.fromEntries(entries);
    return json;
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

  Object? _mapKeyValueToJson(String k, dynamic o, bool duplicatedEntitiesAsID) {
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

    return _valueToJson(o, k, duplicatedEntitiesAsID);
  }

  void _cacheEntity(Object? obj, bool duplicatedEntitiesAsID) {
    if ((duplicatedEntitiesAsID || forceDuplicatedEntitiesAsID) &&
        obj != null) {
      entityCache.cacheEntity(obj);
    }
  }

  Object? _objectToJson(
      dynamic o, String? fieldName, bool duplicatedEntitiesAsID) {
    if ((duplicatedEntitiesAsID || forceDuplicatedEntitiesAsID) &&
        entityCache.isCachedEntity(o)) {
      var id = entityCache.getEntityID(o);
      if (id != null) {
        return id;
      }
    }

    var toEncodableProvider = this.toEncodableProvider;
    if (toEncodableProvider != null) {
      var encoder = toEncodableProvider(o);

      if (encoder != null) {
        try {
          var enc = encoder(o, this);
          _cacheEntity(o, duplicatedEntitiesAsID);
          return enc;
        } catch (_) {
          return _entityToJsonDefault(o, duplicatedEntitiesAsID);
        }
      }
    }

    var toEncodable =
        this.toEncodable ?? JsonEncoder.getTypeToEncodable(o.runtimeType);

    if (toEncodable != null) {
      try {
        var enc = toEncodable(o, this);
        _cacheEntity(o, duplicatedEntitiesAsID);
        return enc;
      } catch (_) {
        return _entityToJsonDefault(o, duplicatedEntitiesAsID);
      }
    }

    if (o is DateTime) {
      return _dateTimeToJson(o);
    } else if (o is Uint8List) {
      return _uint8ListToJson(o, fieldName);
    } else if (o is BigInt) {
      return _bigIntToJson(o);
    } else if (o is Enum) {
      return _enumToJson(o);
    }

    var oType = o.runtimeType;

    return _entityToJson(o, oType, duplicatedEntitiesAsID);
  }

  Object? _entityToJson(o, Type oType, bool duplicatedEntitiesAsID) {
    var classReflection = ReflectionFactory().getRegisterClassReflection(oType);

    if (classReflection != null) {
      try {
        var json =
            classReflection.toJson(o, this, duplicatedEntitiesAsID, false);
        _cacheEntity(o, duplicatedEntitiesAsID);
        return json;
      } catch (_) {
        return _entityToJsonDefault(o, duplicatedEntitiesAsID);
      }
    }

    return _entityToJsonDefault(o, duplicatedEntitiesAsID);
  }

  Object? _entityToJsonDefault(dynamic o, bool duplicatedEntitiesAsID) {
    try {
      var enc = o.toJson();
      _cacheEntity(o, duplicatedEntitiesAsID);
      return enc;
    } catch (_) {
      var enc = '$o';
      _cacheEntity(o, duplicatedEntitiesAsID);
      return enc;
    }
  }

  @override
  String encode(Object? o,
      {bool pretty = false,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache}) {
    var json = toJson(o,
        duplicatedEntitiesAsID: duplicatedEntitiesAsID,
        autoResetEntityCache: autoResetEntityCache);

    if (pretty) {
      return dart_convert.JsonEncoder.withIndent('  ').convert(json);
    } else {
      return dart_convert.json.encode(json);
    }
  }

  @override
  String convert(Object? input) => encode(input);

  @override
  Uint8List encodeToBytes(Object? o,
      {bool pretty = false,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache}) {
    var json = toJson(o,
        duplicatedEntitiesAsID: duplicatedEntitiesAsID,
        autoResetEntityCache: autoResetEntityCache);

    if (pretty) {
      return dart_convert.JsonUtf8Encoder('  ').convert(json).toUint8List();
    } else {
      return dart_convert.JsonUtf8Encoder().convert(json).toUint8List();
    }
  }
}

typedef JsonTypeDecoder<T> = T? Function(
    Object? json, JsonDecoder? jsonDecoder, TypeInfo typeInfo);

/// A JSON decoder.
abstract class JsonDecoder extends JsonConverter<String, Object?> {
  static final Map<Type, JsonTypeDecoder> _registeredTypeDecoders =
      <Type, JsonTypeDecoder>{};

  /// Register a global [JsonTypeDecoder] for [type].
  static void registerTypeDecoder(Type type, JsonTypeDecoder decoder) {
    _registeredTypeDecoders[type] = decoder;
  }

  /// Unregister a global [JsonTypeDecoder] for [type].
  /// - If [decoder] is provided the registered instance must match [identical] to be removed.
  static bool unregisterTypeDecoder(Type type, [JsonTypeDecoder? decoder]) {
    if (decoder == null) {
      _registeredTypeDecoders.remove(type);
      return true;
    } else {
      var prev = _registeredTypeDecoders[type];
      if (identical(prev, decoder)) {
        _registeredTypeDecoders.remove(type);
        return true;
      } else {
        return false;
      }
    }
  }

  static JsonTypeDecoder? getTypeDecoder(Type type) =>
      _registeredTypeDecoders[type];

  static JsonTypeDecoder? removeTypeDecoder(Type type) =>
      _registeredTypeDecoders.remove(type);

  static final JsonDecoder defaultDecoder = _JsonDecoder._defaultDecoder;

  factory JsonDecoder(
      {JsonValueDecoderProvider? jsonValueDecoderProvider,
      JsomMapDecoderProvider? jsomMapDecoderProvider,
      JsomMapDecoder? jsomMapDecoder,
      JsomMapDecoderAsyncProvider? jsomMapDecoderAsyncProvider,
      JsomMapDecoderAsync? jsomMapDecoderAsync,
      IterableCaster? iterableCaster,
      MapCaster? mapCaster,
      JsonEntityCache? entityCache,
      bool forceDuplicatedEntitiesAsID = false,
      bool autoResetEntityCache = true}) {
    if (jsomMapDecoderProvider == null &&
        jsomMapDecoder == null &&
        jsomMapDecoderAsyncProvider == null &&
        jsomMapDecoderAsync == null &&
        iterableCaster == null &&
        mapCaster == null &&
        entityCache == null &&
        !forceDuplicatedEntitiesAsID &&
        autoResetEntityCache) {
      return defaultDecoder;
    }

    return _JsonDecoder._(
        jsonValueDecoderProvider,
        jsomMapDecoderProvider,
        jsomMapDecoder,
        jsomMapDecoderAsyncProvider,
        jsomMapDecoderAsync,
        iterableCaster,
        mapCaster,
        entityCache,
        forceDuplicatedEntitiesAsID,
        autoResetEntityCache);
  }

  /// The internal entity cache.
  JsonEntityCache get entityCache;

  /// Returns `true` if the entity cache is automatically reset for each
  /// decoding session.
  bool get autoResetEntityCache;

  /// Resets the entities cache used to resolve duplicated entities in the same tree.
  void resetEntityCache();

  /// Converts [o] to [type].
  O? fromJson<O>(Object? o,
      {Type? type,
      TypeInfo? typeInfo,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache});

  /// Converts [o] to [type] allowing async calls ([Future] and [FutureOr]).
  FutureOr<O?> fromJsonAsync<O>(Object? o,
      {Type? type,
      TypeInfo? typeInfo,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache});

  /// Converts [o] to as [List] of [type].
  List<O?> fromJsonList<O>(Iterable o,
      {Type? type,
      TypeInfo? typeInfo,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache});

  /// Converts [o] to as [List] of [type] allowing async calls ([Future] and [FutureOr]).
  FutureOr<List<O?>> fromJsonListAsync<O>(FutureOr<Iterable> o,
      {Type? type,
      TypeInfo? typeInfo,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache});

  /// Converts [map] to [type].
  O fromJsonMap<O>(Map<String, Object?> map,
      {Type? type,
      TypeInfo? typeInfo,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache});

  /// Converts [map] to [type] allowing async calls ([Future] and [FutureOr]).
  FutureOr<O> fromJsonMapAsync<O>(FutureOr<Map<String, Object?>> map,
      {Type? type,
      TypeInfo? typeInfo,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache});

  /// Decodes [encodedJson] to a JSON collection/data.
  T decode<T>(String encodedJson,
      {Type? type,
      TypeInfo? typeInfo,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache});

  /// Sames as [decode] but from a [Uint8List].
  T decodeFromBytes<T>(Uint8List encodedJsonBytes,
      {Type? type,
      TypeInfo? typeInfo,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache});

  /// Decodes [encodedJson] to a JSON collection/data accepting async values.
  FutureOr<T> decodeAsync<T>(FutureOr<String> encodedJson,
      {Type? type,
      TypeInfo? typeInfo,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache});

  /// Sames as [decodeAsync] but from a [Uint8List].
  FutureOr<T> decodeFromBytesAsync<T>(FutureOr<Uint8List> encodedJsonBytes,
      {Type? type,
      TypeInfo? typeInfo,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache});
}

class _JsonDecoder extends dart_convert.Converter<String, Object?>
    implements JsonDecoder {
  static final _JsonDecoder _defaultDecoder = _JsonDecoder._(
      null, null, null, null, null, null, null, null, false, true);

  factory _JsonDecoder(
      JsonValueDecoderProvider? jsonValueDecoderProvider,
      JsomMapDecoderProvider? jsomMapDecoderProvider,
      JsomMapDecoder? jsomMapDecoder,
      JsomMapDecoderAsyncProvider? jsomMapDecoderAsyncProvider,
      JsomMapDecoderAsync? jsomMapDecoderAsync,
      IterableCaster? iterableCaster,
      MapCaster? mapCaster,
      JsonEntityCache? entityCache,
      bool forceDuplicatedEntitiesAsID,
      bool autoResetEntityCache) {
    if (jsonValueDecoderProvider == null &&
        jsomMapDecoderProvider == null &&
        jsomMapDecoder == null &&
        jsomMapDecoderAsyncProvider == null &&
        jsomMapDecoderAsync == null &&
        iterableCaster == null &&
        mapCaster == null &&
        entityCache == null &&
        !forceDuplicatedEntitiesAsID &&
        autoResetEntityCache) {
      return _defaultDecoder;
    }

    return _JsonDecoder._(
        jsonValueDecoderProvider,
        jsomMapDecoderProvider,
        jsomMapDecoder,
        jsomMapDecoderAsyncProvider,
        jsomMapDecoderAsync,
        iterableCaster,
        mapCaster,
        entityCache,
        forceDuplicatedEntitiesAsID,
        autoResetEntityCache);
  }

  final JsonValueDecoderProvider? jsonValueDecoderProvider;

  final JsomMapDecoderProvider? jsomMapDecoderProvider;
  final JsomMapDecoder? jsomMapDecoder;

  final JsomMapDecoderAsyncProvider? jsomMapDecoderAsyncProvider;
  final JsomMapDecoderAsync? jsomMapDecoderAsync;

  final IterableCaster? iterableCaster;
  final MapCaster? mapCaster;

  @override
  final JsonEntityCache entityCache;

  final bool forceDuplicatedEntitiesAsID;

  @override
  final bool autoResetEntityCache;

  _JsonDecoder._(
    this.jsonValueDecoderProvider,
    this.jsomMapDecoderProvider,
    this.jsomMapDecoder,
    this.jsomMapDecoderAsyncProvider,
    this.jsomMapDecoderAsync,
    this.iterableCaster,
    this.mapCaster,
    JsonEntityCache? entityCache,
    this.forceDuplicatedEntitiesAsID,
    this.autoResetEntityCache,
  ) : entityCache = entityCache ?? JsonEntityCacheSimple();

  @override
  void resetEntityCache() {
    entityCache.clearCachedEntities();
  }

  @override
  O? fromJson<O>(Object? o,
      {Type? type,
      TypeInfo? typeInfo,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache}) {
    typeInfo = _resolveTypeInfo<O>(typeInfo, type);
    _resetEntityCache(autoResetEntityCache);
    var obj = _fromJsonImpl<O>(o, typeInfo, duplicatedEntitiesAsID);
    _resetEntityCache(autoResetEntityCache);
    return obj;
  }

  O? _fromJsonImpl<O>(
      Object? o, TypeInfo typeInfo, bool duplicatedEntitiesAsID) {
    var type = typeInfo.type;

    if (JsonConverter.isPrimitiveType(type)) {
      return o as O?;
    } else if (type == DateTime) {
      return _parseDateTime(o) as O?;
    } else if (type == Uint8List) {
      return _parseBytes(o) as O?;
    } else if (type == BigInt) {
      return _parseBigInt(o) as O?;
    }

    if (o is Map) {
      var map = o is Map<String, Object>
          ? o
          : o.map((k, v) => MapEntry(k.toString(), v));
      return _fromJsonMapImpl(map, typeInfo, duplicatedEntitiesAsID);
    } else if (o is Iterable) {
      return _fromJsonListImpl(o, typeInfo, duplicatedEntitiesAsID) as O?;
    } else if (o is String) {
      return _entityFromJsonString(typeInfo, o, duplicatedEntitiesAsID);
    } else {
      return _entityFromJsonValue(typeInfo, o, duplicatedEntitiesAsID);
    }
  }

  @override
  FutureOr<O?> fromJsonAsync<O>(Object? o,
      {Type? type,
      TypeInfo? typeInfo,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache}) {
    typeInfo = _resolveTypeInfo<O>(typeInfo, type);
    _resetEntityCache(autoResetEntityCache);
    var obj = _fromJsonAsyncImpl<O>(
        o, typeInfo, duplicatedEntitiesAsID, autoResetEntityCache);
    return _resetEntityCacheAsync(obj, autoResetEntityCache);
  }

  FutureOr<O?> _fromJsonAsyncImpl<O>(Object? o, TypeInfo typeInfo,
      bool duplicatedEntitiesAsID, bool? autoResetEntityCache) {
    var type = typeInfo.type;

    if (o is Future) {
      return o.then((value) => _fromJsonAsyncImpl<O>(
          value, typeInfo, duplicatedEntitiesAsID, autoResetEntityCache));
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
      return fromJsonMapAsync<O>(map, typeInfo: typeInfo);
    } else if (o is Iterable) {
      return _fromJsonListAsyncImpl(
          o, typeInfo, duplicatedEntitiesAsID, autoResetEntityCache) as O?;
    } else if (o is String) {
      return _entityFromJsonString(typeInfo, o, duplicatedEntitiesAsID);
    } else {
      return _entityFromJsonValue(typeInfo, o, duplicatedEntitiesAsID);
    }
  }

  DateTime? _parseDateTime(Object? o) {
    if (o == null) return null;
    if (o is DateTime) return o;

    if (o is int) {
      return DateTime.fromMillisecondsSinceEpoch(o, isUtc: true);
    }

    var s = o.toString().trim();

    var d = DateTime.tryParse(s);
    if (d != null) return d;

    var n = int.tryParse(s);
    if (n != null) {
      return DateTime.fromMillisecondsSinceEpoch(n, isUtc: true);
    }

    return null;
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
      } else if (o.startsWith('hex:')) {
        var hex = o.substring(4);
        return base_codecs.hex.decode(hex);
      } else {
        try {
          return base_codecs.base16Decode(o);
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
  List<O?> fromJsonList<O>(Iterable o,
      {Type? type,
      TypeInfo? typeInfo,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache}) {
    typeInfo = _resolveTypeInfo<O>(typeInfo, type);
    _resetEntityCache(autoResetEntityCache);
    var list = _fromJsonListImpl<O>(o, typeInfo, duplicatedEntitiesAsID);
    _resetEntityCache(autoResetEntityCache);
    return list;
  }

  List<O?> _fromJsonListImpl<O>(
      Iterable o, TypeInfo typeInfo, bool duplicatedEntitiesAsID) {
    var list = o
        .map((e) => _fromJsonImpl<O>(e, typeInfo, duplicatedEntitiesAsID))
        .toList();

    return _castList(list, typeInfo);
  }

  TypeInfo _resolveTypeInfo<O>(TypeInfo? typeInfo, Type? type) {
    if (typeInfo != null) {
      return typeInfo;
    } else if (type != null) {
      return TypeInfo<O>.fromType(type);
    } else {
      return TypeInfo<O>.fromType(O);
    }
  }

  List<O?> _castList<O>(List list, TypeInfo typeInfo) {
    var nullable = list.any((e) => e == null);
    var list2 = typeInfo.toListType().castList(list, nullable: nullable);
    return list2 is List<O?> ? list2 : list2.cast<O?>();
  }

  @override
  FutureOr<List<O?>> fromJsonListAsync<O>(FutureOr<Iterable> o,
      {Type? type,
      TypeInfo? typeInfo,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache}) {
    typeInfo = _resolveTypeInfo<O>(typeInfo, type);

    if (o is Future<Iterable>) {
      return o.then((value) {
        _resetEntityCache(autoResetEntityCache);
        var ret = _fromJsonListAsyncImpl<O>(
            value, typeInfo!, duplicatedEntitiesAsID, autoResetEntityCache);
        return _resetEntityCacheAsync<List<O?>>(ret, autoResetEntityCache);
      });
    } else {
      _resetEntityCache(autoResetEntityCache);
      var ret = _fromJsonListAsyncImpl<O>(
          o, typeInfo, duplicatedEntitiesAsID, autoResetEntityCache);
      return _resetEntityCacheAsync<List<O?>>(ret, autoResetEntityCache);
    }
  }

  FutureOr<List<O?>> _fromJsonListAsyncImpl<O>(Iterable o, TypeInfo typeInfo,
      bool duplicatedEntitiesAsID, bool? autoResetEntityCache) {
    var listAsync = o
        .map((e) => _fromJsonAsyncImpl(
            e, typeInfo, duplicatedEntitiesAsID, autoResetEntityCache))
        .toList();

    return _resolveListAsync<O>(listAsync, typeInfo, autoResetEntityCache);
  }

  FutureOr<List<O?>> _resolveListAsync<O>(
      List list, TypeInfo typeInfo, bool? autoResetEntityCache) {
    var hasFuture = _listHasFuture(list);
    if (hasFuture) {
      var listFutures = _listElementsToFuture(list);
      return Future.wait(listFutures).then((l) {
        _resetEntityCache(autoResetEntityCache);
        return _castList(l, typeInfo);
      });
    } else {
      _resetEntityCache(autoResetEntityCache);
      return _castList(list, typeInfo);
    }
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
  O fromJsonMap<O>(Map<String, Object?> map,
      {Type? type,
      TypeInfo? typeInfo,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache}) {
    typeInfo = _resolveTypeInfo<O>(typeInfo, type);

    _resetEntityCache(autoResetEntityCache);
    var obj = _fromJsonMapImpl<O>(map, typeInfo, duplicatedEntitiesAsID);
    _resetEntityCache(autoResetEntityCache);
    return obj;
  }

  void _resetEntityCache(bool? resetEntityCache) {
    if (resetEntityCache != null) {
      if (resetEntityCache) {
        entityCache.clearCachedEntities();
      }
    } else if (autoResetEntityCache) {
      entityCache.clearCachedEntities();
    }
  }

  FutureOr<O> _resetEntityCacheAsync<O>(
      FutureOr<O> o, bool? autoResetEntityCache) {
    if (o is Future<O>) {
      return o.then((value) {
        _resetEntityCache(autoResetEntityCache);
        return value;
      });
    } else {
      _resetEntityCache(autoResetEntityCache);
      return o;
    }
  }

  O _fromJsonMapImpl<O>(Map<String, Object?> map, TypeInfo typeInfo,
      bool duplicatedEntitiesAsID) {
    var type = typeInfo.type;

    if (JsonConverter.isValidEntityType(type)) {
      return _entityFromJsonMap<O>(typeInfo, map, duplicatedEntitiesAsID);
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
        map is Map<String, bool?> ||
        map is Map<String, DateTime?> ||
        map is Map<String, BigInt?>) {
      return map as O;
    }

    var map2 = map.map((k, v) {
      var v2 = _fromJsonImpl(v, typeInfo, duplicatedEntitiesAsID);
      return MapEntry(k, v2);
    });

    return map2 as O;
  }

  O _entityFromJsonMap<O>(TypeInfo typeInfo, Map<String, Object?> map,
      bool duplicatedEntitiesAsID) {
    var type = typeInfo.type;

    if ((duplicatedEntitiesAsID || forceDuplicatedEntitiesAsID)) {
      var cachedEntity = entityCache.getCachedEntityByMapID(map, type: type);
      if (cachedEntity != null) {
        return cachedEntity as O;
      }
    }

    var jsomMapDecoderProvider = this.jsomMapDecoderProvider;
    if (jsomMapDecoderProvider != null) {
      var fromJsonMap = jsomMapDecoderProvider(type, map);
      if (fromJsonMap != null) {
        var entity = fromJsonMap(map, this);
        _cacheEntity(entity);
        return entity;
      }
    }

    var jsomMapDecoder = this.jsomMapDecoder;
    if (jsomMapDecoder != null) {
      var entity = jsomMapDecoder(map, this);
      if (entity != null) {
        _cacheEntity(entity);
        return entity as O;
      }
    }

    var typeDecoder = JsonDecoder.getTypeDecoder(type);
    if (typeDecoder != null) {
      var obj = typeDecoder(map, this, typeInfo);
      if (obj != null) {
        _cacheEntity(obj);
        return obj as O;
      }
    }

    var classReflection = ReflectionFactory().getRegisterClassReflection(type);

    if (classReflection == null) {
      throw UnsupportedError(
          "Can't find registered ClassReflection for type: $type");
    }

    var entity = classReflection.createInstanceFromMap(map,
        fieldValueResolver: (f, v, t) =>
            _fieldValueResolver(f, v, t, duplicatedEntitiesAsID));

    _cacheEntity(entity);

    return entity;
  }

  void _cacheEntity(Object? entity) {
    if (entity != null) {
      entityCache.cacheEntity(entity);
    }
  }

  O _entityFromJsonString<O>(
      TypeInfo typeInfo, String s, bool duplicatedEntitiesAsID) {
    var type = typeInfo.type;

    var jsonValueDecoderProvider = this.jsonValueDecoderProvider;
    if (jsonValueDecoderProvider != null) {
      var valueDecoder = jsonValueDecoderProvider(type, s);
      if (valueDecoder != null) {
        var obj = valueDecoder(s, type, this) as O;
        if (obj != null) {
          _cacheEntity(obj);
          return obj;
        }
      }
    }

    var typeDecoder = JsonDecoder.getTypeDecoder(type);
    if (typeDecoder != null) {
      var obj = typeDecoder(s, this, typeInfo);
      if (obj != null) {
        _cacheEntity(obj);
        return obj as O;
      }
    }

    if (!JsonConverter.isValidEntityType(type)) {
      return s as O;
    }

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

      var constructorsParamString = constructors
          .where((c) =>
              c.positionalParametersLength >= 1 &&
              c.normalParameters.length <= 1)
          .toList()
        ..sort();

      if (constructorsParamString.isEmpty) {
        throw UnsupportedError(
            "Can't find constructor to instantiate type: $type > $s");
      }

      var c = constructorsParamString.first;

      try {
        var obj = c.invoke([s]);
        _cacheEntity(obj);
        return obj;
      } catch (e) {
        throw UnsupportedError(
            "Error invoking type `$type` constructor: $c > $s");
      }
    }

    throw UnsupportedError(
        "Can't find registered JsonDecoder or Reflection for type: $type > $s");
  }

  O? _entityFromJsonValue<O>(
      TypeInfo typeInfo, Object? value, bool duplicatedEntitiesAsID) {
    var type = typeInfo.type;

    if (value != null &&
        (duplicatedEntitiesAsID || forceDuplicatedEntitiesAsID)) {
      var cachedEntity = entityCache.getCachedEntityByID(value, type: type);
      if (cachedEntity != null) {
        return cachedEntity as O;
      }
    }

    var jsonValueDecoderProvider = this.jsonValueDecoderProvider;
    if (jsonValueDecoderProvider != null) {
      var valueDecoder = jsonValueDecoderProvider(type, value);
      if (valueDecoder != null) {
        var obj = valueDecoder(value, type, this);
        if (obj != null) {
          _cacheEntity(obj);
          return obj as O;
        }
      }
    }

    var typeDecoder = JsonDecoder.getTypeDecoder(type);
    if (typeDecoder != null) {
      var obj = typeDecoder(value, this, typeInfo);
      if (obj != null) {
        _cacheEntity(obj);
        return obj as O;
      }
    }

    if (value == null) return null;

    if (value.runtimeType == type) {
      return value as O;
    }

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
            .where((c) =>
                c.positionalParametersLength >= 1 &&
                c.normalParameters.length <= 1)
            .toList()
          ..sort();
      }

      if (constructors.isNotEmpty) {
        var c = constructors.first;
        var obj = c.invoke([value]);
        _cacheEntity(obj);
        return obj;
      }
    }

    return null;
  }

  @override
  FutureOr<O> fromJsonMapAsync<O>(FutureOr<Map<String, Object?>> map,
      {Type? type,
      TypeInfo? typeInfo,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache}) {
    typeInfo = _resolveTypeInfo<O>(typeInfo, type);

    if (map is Future<Map<String, Object?>>) {
      return map.then((value) {
        _resetEntityCache(autoResetEntityCache);
        var ret =
            _fromJsonMapAsyncImpl<O>(value, typeInfo!, duplicatedEntitiesAsID);
        return _resetEntityCacheAsync<O>(ret, autoResetEntityCache);
      });
    } else {
      _resetEntityCache(autoResetEntityCache);
      var ret = _fromJsonMapAsyncImpl<O>(map, typeInfo, duplicatedEntitiesAsID);
      return _resetEntityCacheAsync<O>(ret, autoResetEntityCache);
    }
  }

  FutureOr<O> _fromJsonMapAsyncImpl<O>(Map<String, Object?> map,
      TypeInfo typeInfo, bool duplicatedEntitiesAsID) {
    if (JsonConverter.isValidEntityType(typeInfo.type)) {
      return _entityFromJsonMapAsync<O>(typeInfo, map, duplicatedEntitiesAsID);
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
      var v2 = _fromJsonImpl(v, typeInfo, duplicatedEntitiesAsID);
      return MapEntry(k, v2);
    });

    return map2 as O;
  }

  FutureOr<O> _entityFromJsonMapAsync<O>(TypeInfo typeInfo,
      Map<String, Object?> map, bool duplicatedEntitiesAsID) {
    var type = typeInfo.type;

    if ((duplicatedEntitiesAsID || forceDuplicatedEntitiesAsID)) {
      var cachedEntity = entityCache.getCachedEntityByMapID(map, type: type);
      if (cachedEntity != null) {
        return cachedEntity as O;
      }
    }

    var jsomMapDecoderAsyncProvider = this.jsomMapDecoderAsyncProvider;
    if (jsomMapDecoderAsyncProvider != null) {
      var fromJsonMapAsync = jsomMapDecoderAsyncProvider(type, map);
      if (fromJsonMapAsync != null) {
        var futureOr = fromJsonMapAsync(map, this);
        return _castFutureOr<O>(futureOr);
      }
    }

    var jsomMapDecoderAsync = this.jsomMapDecoderAsync;
    if (jsomMapDecoderAsync != null) {
      var futureOr = jsomMapDecoderAsync(map, this);
      if (futureOr != null) {
        return _cacheEntityAsync<O>(futureOr);
      }
    }

    var typeDecoder = JsonDecoder.getTypeDecoder(type);
    if (typeDecoder != null) {
      var obj = typeDecoder(map, this, typeInfo);
      if (obj != null) {
        return _cacheEntityAsync<O>(obj);
      }
    }

    var classReflection = ReflectionFactory().getRegisterClassReflection(type);

    if (classReflection == null) {
      throw UnsupportedError(
          "Can't find registered ClassReflection for type: $typeInfo");
    }

    var mapResolved = _resolveMap<String, Object?>(map);

    if (mapResolved is Future<Map<String, Object?>>) {
      return mapResolved.then((mapResolved2) {
        var entity = classReflection.createInstanceFromMap(mapResolved2,
            fieldValueResolver: (f, v, t) =>
                _fieldValueResolver(f, v, t, duplicatedEntitiesAsID));
        _cacheEntity(entity);
        return entity;
      });
    } else {
      var entity = classReflection.createInstanceFromMap(map,
          fieldValueResolver: (f, v, t) =>
              _fieldValueResolver(f, v, t, duplicatedEntitiesAsID));
      _cacheEntity(entity);
      return entity;
    }
  }

  FutureOr<T> _cacheEntityAsync<T>(FutureOr oAsync) {
    if (oAsync is Future) {
      return oAsync.then((obj) {
        _cacheEntity(obj);
        return obj as T;
      });
    } else {
      _cacheEntity(oAsync);
      return oAsync as T;
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

  Object? _fieldValueResolver(String field, Object? value, TypeReflection type,
      bool duplicatedEntitiesAsID) {
    if (type.isIterableType && value is Iterable) {
      return _castEntityList(value, type, duplicatedEntitiesAsID);
    } else if (type.isMapType && value is Map) {
      return _castEntityMap(value, type, duplicatedEntitiesAsID);
    } else {
      return _fromJsonImpl(value, type.typeInfo, duplicatedEntitiesAsID);
    }
  }

  Object? _castEntityList(
      Iterable value, TypeReflection type, bool duplicatedEntitiesAsID) {
    var iterableCaster = this.iterableCaster;
    if (iterableCaster != null) {
      var casted = iterableCaster(value, type);
      if (casted != null) {
        return casted;
      }
    }

    var castTypeRefl = type.listType;

    if (castTypeRefl != null) {
      var castType = castTypeRefl.type;

      var val = _fromJsonListImpl(
          value, castTypeRefl.typeInfo, duplicatedEntitiesAsID);

      var classReflection =
          ReflectionFactory().getRegisterClassReflection(castType);

      if (classReflection != null) {
        var nullable = val.any((e) => e == null);
        return classReflection.castList(val, castType, nullable: nullable) ??
            val;
      }

      return castListType(val, castType);
    } else {
      return value;
    }
  }

  Object? _castEntityMap(
      Map value, TypeReflection type, bool duplicatedEntitiesAsID) {
    var mapCaster = this.mapCaster;
    if (mapCaster != null) {
      var casted = mapCaster(value, type);
      if (casted != null) {
        return casted;
      }
    }

    var castKeyTypeRefl = type.mapKeyType;
    var castValueTypeRefl = type.mapValueType;

    var val = value;

    if (castKeyTypeRefl != null && castKeyTypeRefl.isEntityType) {
      val = val.map((key, value) => MapEntry(
          _fromJsonImpl(key, castKeyTypeRefl.typeInfo, duplicatedEntitiesAsID),
          value));
    }

    if (castValueTypeRefl != null && castValueTypeRefl.isEntityType) {
      val = val.map((key, value) => MapEntry(
          key,
          _fromJsonImpl(
              value, castValueTypeRefl.typeInfo, duplicatedEntitiesAsID)));
    }

    var castKeyType = castKeyTypeRefl?.type;
    var castValueType = castValueTypeRefl?.type;

    var classReflectionKey = castKeyType != null
        ? ReflectionFactory().getRegisterClassReflection(castKeyType)
        : null;
    var classReflectionValue = castValueType != null
        ? ReflectionFactory().getRegisterClassReflection(castValueType)
        : null;

    if (classReflectionKey != null) {
      var nullableKey = val.entries.any((e) => e.key == null);

      val = classReflectionKey.castMapKeys(val, type.typeInfo,
              nullable: nullableKey) ??
          val;
    }

    if (classReflectionValue != null) {
      var nullableVal = val.entries.any((e) => e.value == null);

      val = classReflectionValue.castMapValues(val, type.typeInfo,
              nullable: nullableVal) ??
          val;
    }

    if (castKeyType != null || castValueType != null) {
      return castMapType(val, castKeyType ?? dynamic, castValueType ?? dynamic);
    } else {
      return val;
    }
  }

  @override
  T decode<T>(String encodedJson,
      {Type? type,
      TypeInfo? typeInfo,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache}) {
    typeInfo = _resolveTypeInfo<T>(typeInfo, type);

    var json = dart_convert.json.decode(encodedJson);
    return fromJson<T>(json,
        typeInfo: typeInfo,
        duplicatedEntitiesAsID: duplicatedEntitiesAsID,
        autoResetEntityCache: autoResetEntityCache) as T;
  }

  /// Sames as [decode] but from a [Uint8List].
  @override
  T decodeFromBytes<T>(Uint8List encodedJsonBytes,
      {Type? type,
      TypeInfo? typeInfo,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache}) {
    typeInfo = _resolveTypeInfo<T>(typeInfo, type);

    var encodedJson = dart_convert.utf8.decode(encodedJsonBytes);
    return decode<T>(encodedJson,
        typeInfo: typeInfo,
        duplicatedEntitiesAsID: duplicatedEntitiesAsID,
        autoResetEntityCache: autoResetEntityCache);
  }

  /// Decodes [encodedJson] to a JSON collection/data accepting async values.
  @override
  FutureOr<T> decodeAsync<T>(FutureOr<String> encodedJson,
      {Type? type,
      TypeInfo? typeInfo,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache}) {
    typeInfo = _resolveTypeInfo<T>(typeInfo, type);

    if (encodedJson is Future<String>) {
      return encodedJson.then((value) => decodeAsync<T>(value,
          typeInfo: typeInfo,
          duplicatedEntitiesAsID: duplicatedEntitiesAsID,
          autoResetEntityCache: autoResetEntityCache));
    }

    var json = dart_convert.json.decode(encodedJson);
    return fromJsonAsync<T>(json,
        typeInfo: typeInfo,
        duplicatedEntitiesAsID: duplicatedEntitiesAsID,
        autoResetEntityCache: autoResetEntityCache) as T;
  }

  /// Sames as [decodeAsync] but from a [Uint8List].
  @override
  FutureOr<T> decodeFromBytesAsync<T>(FutureOr<Uint8List> encodedJsonBytes,
      {Type? type,
      TypeInfo? typeInfo,
      bool duplicatedEntitiesAsID = false,
      bool? autoResetEntityCache}) {
    typeInfo = _resolveTypeInfo<T>(typeInfo, type);

    if (encodedJsonBytes is Future<Uint8List>) {
      return encodedJsonBytes.then((value) => decodeFromBytesAsync<T>(value,
          typeInfo: typeInfo,
          duplicatedEntitiesAsID: duplicatedEntitiesAsID,
          autoResetEntityCache: autoResetEntityCache));
    }

    var encodedJson = dart_convert.utf8.decode(encodedJsonBytes);
    return decodeAsync<T>(encodedJson,
        typeInfo: typeInfo,
        duplicatedEntitiesAsID: duplicatedEntitiesAsID,
        autoResetEntityCache: autoResetEntityCache);
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

Map castMapType<K, V>(Map map, Type keyType, Type valueType) {
  if (map is Map<K, V> &&
      K != dynamic &&
      K != Object &&
      V != dynamic &&
      V != Object) {
    return map;
  } else if (keyType == String) {
    return _castMapValueType<String>(map, keyType, valueType);
  } else if (keyType == int) {
    return _castMapValueType<int>(map, keyType, valueType);
  } else if (keyType == double) {
    return _castMapValueType<double>(map, keyType, valueType);
  } else if (keyType == num) {
    return _castMapValueType<num>(map, keyType, valueType);
  } else if (keyType == bool) {
    return _castMapValueType<bool>(map, keyType, valueType);
  } else if (keyType == DateTime) {
    return _castMapValueType<DateTime>(map, keyType, valueType);
  } else if (keyType == BigInt) {
    return _castMapValueType<BigInt>(map, keyType, valueType);
  } else if (keyType == Uint8List) {
    return _castMapValueType<Uint8List>(map, keyType, valueType);
  } else {
    return map;
  }
}

Map _castMapValueType<K>(Map map, Type keyType, Type valueType) {
  assert(K == keyType);

  if (valueType == String) {
    return map.cast<K, String>();
  } else if (valueType == int) {
    return map.cast<K, int>();
  } else if (valueType == double) {
    return map.cast<K, double>();
  } else if (valueType == num) {
    return map.cast<K, num>();
  } else if (valueType == bool) {
    return map.cast<K, bool>();
  } else if (valueType == DateTime) {
    return map.cast<K, DateTime>();
  } else if (valueType == BigInt) {
    return map.cast<K, BigInt>();
  } else if (valueType == Uint8List) {
    return map.cast<K, Uint8List>();
  } else {
    return map;
  }
}

/// A JSON entity encoding/decoding cache.
abstract class JsonEntityCache {
  /// The cache ID.
  int get id;

  /// If `true` it will allow the use of on repository to fetch an entity by an ID reference.
  bool get allowEntityFetch;

  /// Returns the ID value into [map] for [type].
  Object? getEntityIDFromMap(Map<Object?, Object?> map, {Type? type});

  /// Returns the ID value from [object] for [type].
  Object? getEntityID<O>(O object,
      {Type? type, dynamic Function(O o)? idGetter});

  /// Returns a cached entity of [type] with [id].
  O? getCachedEntityByID<O>(dynamic id, {Type? type});

  /// Returns a cached entity of [type] with an id from [map] entries.
  /// See [getEntityIDFromMap].
  O? getCachedEntityByMapID<O>(Map<Object?, Object?> map, {Type? type});

  /// Returns the cached entities of [type] with [ids].
  ///
  /// - If [removeCachedIDs] is `true` it will remove the matching cached entities from [ids].
  Map<dynamic, Object>? getCachedEntitiesByIDs<O>(List<dynamic> ids,
      {Type? type, bool removeCachedIDs = false});

  /// Returns `true` if [entity] is cached.
  /// - If [identicalEquality] is `true` will use [identical] for equality.
  /// - If [type] is defined set it will overwrite [O] or [entity.runtimeType].
  bool isCachedEntity<O>(O entity, {Type? type, bool identicalEquality = true});

  /// Caches [entity]. This is called by the entity decoder/loader.
  /// See [cacheEntities].
  void cacheEntity<O>(O entity, [dynamic Function(O o)? idGetter]);

  /// Caches the [List] [entities]. This is called by the entity decoder/loader.
  /// See [cacheEntity].
  void cacheEntities<O>(List<O> entities, [dynamic Function(O o)? idGetter]);

  /// Clears all cached entities of this cache.
  void clearCachedEntities();
}

/// Simple implementation of [JsonEntityCache].
class JsonEntityCacheSimple implements JsonEntityCache {
  static int _idCount = 0;

  @override
  final int id = ++_idCount;

  @override
  bool get allowEntityFetch => false;

  JsonEntityCacheSimple();

  @override
  Object? getEntityIDFromMap(Map<Object?, Object?> map, {Type? type}) {
    return map['id'] ?? map['ID'];
  }

  @override
  Object? getEntityID<O>(O object,
      {Type? type, dynamic Function(O o)? idGetter}) {
    if (object == null) return null;

    if (idGetter != null) {
      return idGetter(object);
    }

    type ??= object.runtimeType;

    var classReflection = ReflectionFactory().getRegisterClassReflection(type);

    if (classReflection != null) {
      var fieldID = classReflection
          .fieldsWhere((f) => f.name.toLowerCase() == 'id')
          .firstOrNull;
      fieldID ??=
          classReflection.fieldsWhere((f) => f.type.isIntType).firstOrNull;

      return fieldID?.withObject(object).get();
    }

    return null;
  }

  final Map<Type, Map<dynamic, Object>> _entities =
      <Type, Map<dynamic, Object>>{};

  @override
  void clearCachedEntities() {
    _entities.clear();
  }

  /// Returns all cached entities of this cache.
  List<Object> get cachedEntities =>
      _entities.entries.expand((e) => e.value.values).toList();

  /// Returns the total cached entities of this cache.
  int get cachedEntitiesLength =>
      _entities.entries.map((e) => e.value.values.length).sum;

  /// Returns the cached entities of [type].
  Map<dynamic, Object>? getCachedEntities<O>({Type? type}) {
    type ??= O;
    var typeEntities = _entities[type];
    return typeEntities != null ? UnmodifiableMapView(typeEntities) : null;
  }

  @override
  Map<dynamic, Object>? getCachedEntitiesByIDs<O>(List<dynamic> ids,
      {Type? type, bool removeCachedIDs = false}) {
    type ??= O;

    var cachedEntities = _entities[type];
    if (cachedEntities == null) return null;

    var cachedEntitiesByIDs = Map<dynamic, Object>.fromEntries(ids.map((id) {
      var entity = cachedEntities[id];
      return entity != null ? MapEntry(id, entity) : null;
    }).whereNotNull());

    if (cachedEntitiesByIDs.isEmpty) return null;

    if (removeCachedIDs) {
      ids.removeWhere((id) => cachedEntitiesByIDs.containsKey(id));
    }

    return cachedEntitiesByIDs;
  }

  /// Returns a cached entity of [type] with [id].
  @override
  O? getCachedEntityByID<O>(dynamic id, {Type? type}) {
    if (id == null) return null;
    type ??= O;
    var typeEntities = _entities[type];
    var entity = typeEntities?[id] as O?;

    return entity;
  }

  @override
  O? getCachedEntityByMapID<O>(Map<Object?, Object?> map, {Type? type}) {
    var id = getEntityIDFromMap(map, type: type);
    if (id != null) {
      var cachedEntity = getCachedEntityByID(id, type: type);
      if (cachedEntity != null) {
        return cachedEntity as O;
      }
    }
    return null;
  }

  @override
  bool isCachedEntity<O>(O entity,
      {Type? type, bool identicalEquality = true}) {
    type ??= O;
    if (type == Object || type == dynamic) {
      type = entity.runtimeType;
    }

    var typeEntities = _entities[type];
    if (typeEntities == null) return false;

    if (identicalEquality) {
      return typeEntities.values.any((e) => identical(e, entity));
    } else {
      return typeEntities.values.any((e) => e == entity);
    }
  }

  /// Removes an entity of [type] with [id] of this cache.
  O? removeCachedEntity<O>(dynamic id, {Type? type}) {
    if (id == null) return null;
    type ??= O;
    var typeEntities = _entities[type];
    var entity = typeEntities?.remove(id) as O?;
    return entity;
  }

  @override
  void cacheEntity<O>(O entity, [dynamic Function(O o)? idGetter]) {
    var id = getEntityID<O>(entity, idGetter: idGetter);
    if (id == null) return;

    var type = entity.runtimeType;
    var typeEntities = _entities.putIfAbsent(type, () => <dynamic, Object>{});
    typeEntities[id] = entity!;
  }

  @override
  void cacheEntities<O>(List<O> entities, [dynamic Function(O o)? idGetter]) {
    Type? entityTYpe;
    Map<dynamic, Object>? typeEntities;

    for (var e in entities) {
      var id = getEntityID<O>(e, idGetter: idGetter);
      if (id == null) continue;

      if (entityTYpe != e.runtimeType) {
        entityTYpe = e.runtimeType;
        typeEntities =
            _entities.putIfAbsent(entityTYpe, () => <dynamic, Object>{});
      }

      typeEntities![id] = e!;
    }
  }

  @override
  String toString() {
    var total = _entities.values.map((e) => e.length).sum;
    var s = 'JsonEntityCacheSimple#$id[$total]';

    return total == 0
        ? s
        : '$s${_entities.map((key, value) => MapEntry(key, value.length))}';
  }
}

extension _ListIntExtension on List<int> {
  Uint8List toUint8List() {
    var o = this;
    return o is Uint8List ? o : Uint8List.fromList(o);
  }
}
