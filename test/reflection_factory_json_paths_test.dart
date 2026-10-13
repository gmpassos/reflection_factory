import 'dart:convert' as dart_convert;
import 'dart:typed_data';

import 'package:mime/mime.dart';
import 'package:reflection_factory/reflection_factory.dart';
import 'package:test/test.dart';

import 'src/user_with_reflection.dart';

// Paths of the JSON codec that the main suite does not reach: the async
// decoder with `Future` inputs and values, the decoder/encoder hooks, the
// fallbacks taken when a hook or `toJson` throws, and the parsing of
// non-canonical scalar representations.

class _NoToJson {
  @override
  String toString() => 'no-to-json';
}

class _WithToJson {
  final int n;

  _WithToJson(this.n);

  Map<String, dynamic> toJson() => {'n': n};
}

class _ThrowingToJson {
  Map<String, dynamic> toJson() => throw StateError('toJson failed');

  @override
  String toString() => 'throwing-to-json';
}

class _Encodable {
  final String v;

  _Encodable(this.v);

  @override
  String toString() => 'encodable:$v';
}

class _Decoded {
  final Object? json;

  _Decoded(this.json);
}

void main() {
  setUpAll(() {
    TestUserWithReflection$reflection.boot();
    TestAddressWithReflection$reflection.boot();
    TestCompanyWithReflection$reflection.boot();
    TestFranchiseWithReflection$reflection.boot();
    TestDataWithReflection$reflection.boot();
  });

  group('JsonDecoder.fromJsonAsync scalars', () {
    final decoder = JsonDecoder.defaultDecoder;

    test('primitives', () async {
      expect(await decoder.fromJsonAsync<int>('12'), equals(12));
      expect(await decoder.fromJsonAsync<double>('1.5'), equals(1.5));
      expect(await decoder.fromJsonAsync<bool>('true'), isTrue);
      expect(await decoder.fromJsonAsync<String>(12), equals('12'));
    });

    test('DateTime / Duration / Uint8List / BigInt', () async {
      var d = DateTime.utc(2024, 1, 2, 3, 4, 5);

      expect(
        await decoder.fromJsonAsync<DateTime>(d.millisecondsSinceEpoch),
        equals(d),
      );
      expect(
        await decoder.fromJsonAsync<Duration>(1500),
        equals(Duration(milliseconds: 1500)),
      );
      expect(
        await decoder.fromJsonAsync<Uint8List>('hex:0aff'),
        equals([10, 255]),
      );
      expect(
        await decoder.fromJsonAsync<BigInt>('123456789012345678901234567890'),
        equals(BigInt.parse('123456789012345678901234567890')),
      );
    });

    test('a Future input', () async {
      expect(await decoder.fromJsonAsync<int>(Future.value('7')), equals(7));
      expect(
        await decoder.fromJsonAsync<BigInt>(Future.value(5)),
        equals(BigInt.from(5)),
      );
    });
  });

  group('JsonDecoder scalar parsing', () {
    final decoder = JsonDecoder.defaultDecoder;

    test('DateTime from an int, an ISO string or an int string', () {
      var d = DateTime.utc(2024, 1, 2, 3, 4, 5);
      var ms = d.millisecondsSinceEpoch;

      expect(decoder.fromJson<DateTime>(ms), equals(d));
      expect(decoder.fromJson<DateTime>(d.toIso8601String()), equals(d));
      expect(decoder.fromJson<DateTime>(' $ms '), equals(d));
      expect(decoder.fromJson<DateTime>(d), same(d));
      expect(decoder.fromJson<DateTime>('not a date'), isNull);
      expect(decoder.fromJson<DateTime>(null), isNull);
    });

    test('BigInt from an int, a string, or garbage', () {
      expect(decoder.fromJson<BigInt>(42), equals(BigInt.from(42)));
      expect(decoder.fromJson<BigInt>('-42'), equals(BigInt.from(-42)));
      expect(decoder.fromJson<BigInt>('x'), isNull);
      expect(decoder.fromJson<BigInt>(null), isNull);
    });

    test('Uint8List from every supported representation', () {
      var bytes = [0, 1, 254, 255];

      expect(decoder.fromJson<Uint8List>('hex:0001feff'), equals(bytes));
      expect(decoder.fromJson<Uint8List>('0001FEFF'), equals(bytes));
      expect(
        decoder.fromJson<Uint8List>(
          'data:application/octet-stream;base64,'
          '${dart_convert.base64.encode(bytes)}',
        ),
        equals(bytes),
      );
      expect(
        decoder.fromJson<Uint8List>('data:text/plain,hi'),
        equals(dart_convert.utf8.encode('hi')),
      );
      expect(decoder.fromJson<Uint8List>(bytes), equals(bytes));
      expect(decoder.fromJson<Uint8List>('!not bytes!'), isNull);
      expect(decoder.fromJson<Uint8List>(null), isNull);
    });
  });

  group('JsonDecoder lists async', () {
    final decoder = JsonDecoder.defaultDecoder;

    final addresses = [
      {'state': 'NY', 'city': 'NYC'},
      {'state': 'CA', 'city': 'LA'},
    ];

    test('fromJsonListAsync with a plain and a Future input', () async {
      for (var input in <FutureOr<Iterable>>[
        addresses,
        Future.value(addresses),
      ]) {
        var l = await decoder.fromJsonListAsync<TestAddressWithReflection>(
          input,
        );
        expect(l, isA<List<TestAddressWithReflection?>>());
        expect(l.map((e) => e!.city), equals(['NYC', 'LA']));
      }
    });

    test('a list whose elements are Futures', () async {
      var l = await decoder.fromJsonListAsync<TestAddressWithReflection>([
        Future.value(addresses[0]),
        addresses[1],
      ]);
      expect(l.map((e) => e!.state), equals(['NY', 'CA']));
    });

    test('an entity map whose values are Futures', () async {
      var u = await decoder.fromJsonAsync<TestUserWithReflection>({
        'name': Future.value('joe'),
        'email': Future.value('joe@mail.com'),
        'passphrase': 'p',
        'enabled': Future.value(false),
      });

      expect(u!.name, equals('joe'));
      expect(u.email, equals('joe@mail.com'));
      expect(u.enabled, isFalse);
    });
  });

  group('JsonDecoder entity cache reset', () {
    test('autoResetEntityCache: true clears the cache', () {
      var decoder = JsonDecoder(autoResetEntityCache: false);
      decoder.entityCache.cacheEntity(
        TestAddressWithReflection.withCity('S', city: 'C', id: 1),
      );
      expect(decoder.entityCache.cachedEntitiesLength, equals(1));

      decoder.fromJson<TestAddressWithReflection>({
        'state': 'NY',
      }, autoResetEntityCache: true);

      expect(decoder.entityCache.cachedEntitiesLength, equals(0));
    });

    test('a decoder with autoResetEntityCache: false keeps entities', () {
      var decoder = JsonDecoder(autoResetEntityCache: false);
      decoder.fromJson<TestAddressWithReflection>({'state': 'NY', 'id': 9});
      expect(decoder.entityCache.cachedEntitiesLength, equals(1));

      decoder.resetEntityCache();
      expect(decoder.entityCache.cachedEntitiesLength, equals(0));
    });
  });

  group('JsonDecoder hooks', () {
    test('jsomMapDecoderAsync for an untyped Map', () async {
      var decoder = JsonDecoder(
        jsomMapDecoderAsync: (map, j) async => {'wrapped': map},
      );

      var r = await decoder.fromJsonAsync<Map>({'a': 1});
      expect(
        r,
        equals({
          'wrapped': {'a': 1},
        }),
      );
    });

    test('jsomMapDecoderAsync for an entity', () async {
      var decoder = JsonDecoder(
        jsomMapDecoderAsync: (map, j) async =>
            TestAddressWithReflection.withCity('HOOK', city: '${map['city']}'),
      );

      var a = await decoder.fromJsonAsync<TestAddressWithReflection>({
        'state': 'NY',
        'city': 'NYC',
      });
      expect(a!.state, equals('HOOK'));
      expect(a.city, equals('NYC'));
    });

    test('jsomMapDecoderAsyncProvider for an entity', () async {
      var decoder = JsonDecoder(
        jsomMapDecoderAsyncProvider: (type, map, j) =>
            type == TestAddressWithReflection
            ? (m, j) =>
                  Future.value(TestAddressWithReflection.withCity('PROVIDED'))
            : null,
      );

      var a = await decoder.fromJsonAsync<TestAddressWithReflection>({
        'state': 'NY',
      });
      expect(a!.state, equals('PROVIDED'));
    });

    test('a registered type decoder, sync and async', () async {
      JsonDecoder.registerTypeDecoder(_Decoded, (json, j, t) => _Decoded(json));
      addTearDown(() => JsonDecoder.unregisterTypeDecoder(_Decoded));

      var decoder = JsonDecoder.defaultDecoder;

      expect(decoder.fromJson<_Decoded>({'a': 1})!.json, equals({'a': 1}));
      expect(
        (await decoder.fromJsonAsync<_Decoded>({'a': 2}))!.json,
        equals({'a': 2}),
      );
      expect(decoder.fromJson<_Decoded>('s')!.json, equals('s'));
      expect(decoder.fromJson<_Decoded>(3)!.json, equals(3));
    });

    test('unregisterTypeDecoder only removes the given decoder', () {
      _Decoded? d1(Object? json, JsonDecoder? j, TypeInfo t) => _Decoded(1);
      _Decoded? d2(Object? json, JsonDecoder? j, TypeInfo t) => _Decoded(2);

      JsonDecoder.registerTypeDecoder(_Decoded, d1);
      addTearDown(() => JsonDecoder.unregisterTypeDecoder(_Decoded));

      expect(JsonDecoder.unregisterTypeDecoder(_Decoded, d2), isFalse);
      expect(JsonDecoder.getTypeDecoder(_Decoded), isNotNull);

      expect(JsonDecoder.unregisterTypeDecoder(_Decoded, d1), isTrue);
      expect(JsonDecoder.getTypeDecoder(_Decoded), isNull);
    });

    test('an unregistered entity type throws, sync and async', () async {
      var decoder = JsonDecoder.defaultDecoder;

      expect(
        () => decoder.fromJson<_NoToJson>({'a': 1}),
        throwsA(isA<UnsupportedError>()),
      );
      expect(
        () => decoder.fromJsonAsync<_NoToJson>({'a': 1}),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('iterableCaster replaces the decoding of a List field', () {
      var calls = <String>[];

      var decoder = JsonDecoder(
        iterableCaster: (value, type, j) {
          calls.add('$type');
          return type.listType?.type == String
              ? value.map((e) => '$e!').toList()
              : null;
        },
      );

      var c = decoder.fromJson<TestCompanyWithReflection>({
        'name': 'co',
        'mainAddress': null,
        'extraNames': ['a', 'b'],
        'branchesAddresses': [
          {'state': 'NY'},
        ],
      })!;

      expect(c.extraNames, equals(['a!', 'b!']));
      // Returning `null` falls back to the default decoding.
      expect(c.branchesAddresses.single.state, equals('NY'));
      expect(calls, isNotEmpty);
    });

    test('mapCaster replaces the decoding of a Map field', () {
      var decoder = JsonDecoder(
        mapCaster: (value, type, j) => value.map(
          (k, v) => MapEntry(
            '$k',
            TestAddressWithReflection.withCity('CAST', city: '$k'),
          ),
        ),
      );

      var f = decoder.fromJson<TestFranchiseWithReflection>({
        'name': 'fr',
        'addresses': {
          'a': {'state': 'NY'},
        },
      })!;

      expect(f.addresses['a']!.state, equals('CAST'));
      expect(f.addresses['a']!.city, equals('a'));
    });

    test('isStandard', () {
      expect(JsonDecoder().isStandard, isTrue);
      expect(identical(JsonDecoder(), JsonDecoder.defaultDecoder), isTrue);

      // A new instance with only a custom (simple) cache is still standard.
      expect(
        JsonDecoder(entityCache: JsonEntityCacheSimple()).isStandard,
        isTrue,
      );
      expect(JsonDecoder(autoResetEntityCache: false).isStandard, isFalse);
      expect(
        JsonDecoder(forceDuplicatedEntitiesAsID: true).isStandard,
        isFalse,
      );
      expect(JsonDecoder(mapCaster: (v, t, j) => null).isStandard, isFalse);
    });
  });

  group('JsonEncoder.callToJson', () {
    test('null', () {
      expect(JsonEncoder.callToJson(null), isNull);
    });

    test('a type with toJson, called repeatedly', () {
      // The second call takes the cached "has `toJson`" path.
      expect(JsonEncoder.callToJson(_WithToJson(1)), equals({'n': 1}));
      expect(JsonEncoder.callToJson(_WithToJson(2)), equals({'n': 2}));
    });

    test('a type without toJson, called repeatedly', () {
      // The second call takes the cached "no `toJson`" path.
      for (var i = 0; i < 2; i++) {
        expect(JsonEncoder.callToJson(_NoToJson()), equals('no-to-json'));
        expect(
          JsonEncoder.callToJson(_NoToJson(), fallback: (o) => 'fb'),
          equals('fb'),
        );
      }
    });

    test('a toJson that throws rethrows, every time', () {
      for (var i = 0; i < 2; i++) {
        expect(
          () => JsonEncoder.callToJson(_ThrowingToJson()),
          throwsA(isA<StateError>()),
        );
      }
    });
  });

  group('JsonEncoder paths', () {
    final encoder = JsonEncoder.defaultEncoder;

    test('Set', () {
      expect(encoder.toJson({1, 2, 'x'}), equals([1, 2, 'x']));
      expect(
        encoder.encode({
          's': {1, 2},
        }),
        equals('{"s":[1,2]}'),
      );
    });

    test('mapToJson', () {
      expect(
        encoder.mapToJson({
          1: 'a',
          'd': Duration(seconds: 1),
          's': {true},
        }),
        equals({
          '1': 'a',
          'd': 1000,
          's': [true],
        }),
      );
    });

    test('BigInt: an int up to 32 bits, a String beyond', () {
      expect(encoder.toJson(BigInt.from(123)), equals(123));
      expect(encoder.toJson(BigInt.from(-123)), equals(-123));

      var big = BigInt.parse('123456789012345678901234567890');
      expect(encoder.toJson(big), equals('123456789012345678901234567890'));
      expect(encoder.toJson(BigInt.from(1) << 32), equals('4294967296'));

      expect(
        JsonDecoder.defaultDecoder.fromJson<BigInt>(encoder.toJson(big)),
        equals(big),
      );
    });

    test('a throwing toEncodableProvider falls back to the default', () {
      var e = JsonEncoder(
        toEncodableProvider: (o) =>
            o is _Encodable ? (o, j) => throw StateError('x') : null,
      );
      expect(e.toJson(_Encodable('a')), equals('encodable:a'));
      expect(e.toJson(_WithToJson(3)), equals({'n': 3}));
    });

    test('a throwing toEncodable falls back to the default', () {
      var e = JsonEncoder(toEncodable: (o, j) => throw StateError('x'));
      expect(e.toJson(_WithToJson(4)), equals({'n': 4}));
      expect(e.toJson(_NoToJson()), equals('no-to-json'));
    });

    test('registerTypeToEncodable / removeTypeToEncodable', () {
      JsonEncoder.registerTypeToEncodable(_Encodable, (o, j) => 'reg:$o');
      addTearDown(() => JsonEncoder.removeTypeToEncodable(_Encodable));

      expect(encoder.toJson(_Encodable('b')), equals('reg:encodable:b'));
      expect(JsonEncoder.getTypeToEncodable(_Encodable), isNotNull);

      expect(JsonEncoder.removeTypeToEncodable(_Encodable), isNotNull);
      expect(JsonEncoder.getTypeToEncodable(_Encodable), isNull);
      expect(encoder.toJson(_Encodable('c')), equals('encodable:c'));
    });

    test('a throwing registered encoder falls back to the default', () {
      JsonEncoder.registerTypeToEncodable(
        _Encodable,
        (o, j) => throw StateError('x'),
      );
      addTearDown(() => JsonEncoder.removeTypeToEncodable(_Encodable));

      expect(encoder.toJson(_Encodable('d')), equals('encodable:d'));
    });

    test('an object whose toJson throws is encoded as its toString', () {
      expect(encoder.toJson(_ThrowingToJson()), equals('throwing-to-json'));
      expect(
        encoder.encode({'x': _ThrowingToJson()}),
        equals('{"x":"throwing-to-json"}'),
      );
    });

    test('autoResetEntityCache: true clears the cache', () {
      var e = JsonEncoder(autoResetEntityCache: false);
      var cache = e.entityCache!;

      // The encoder caches entities only to encode repeats as IDs.
      e.toJson(
        TestAddressWithReflection.withCity('S', id: 1),
        duplicatedEntitiesAsID: true,
      );
      expect(cache.cachedEntitiesLength, equals(1));

      e.toJson(1, autoResetEntityCache: true);
      expect(cache.cachedEntitiesLength, equals(0));

      e.toJson(
        TestAddressWithReflection.withCity('S', id: 2),
        duplicatedEntitiesAsID: true,
      );
      expect(cache.cachedEntitiesLength, equals(1));
      e.resetEntityCache();
      expect(cache.cachedEntitiesLength, equals(0));
    });

    test('isStandard', () {
      expect(identical(JsonEncoder(), JsonEncoder.defaultEncoder), isTrue);
      expect(JsonEncoder().isStandard, isTrue);

      expect(
        JsonEncoder(entityCache: JsonEntityCacheSimple()).isStandard,
        isTrue,
      );
      expect(
        JsonEncoder(
          entityCache: JsonEntityCacheSimple(),
          maskText: '###',
        ).isStandard,
        isFalse,
      );
      expect(JsonEncoder(removeNullFields: true).isStandard, isFalse);
      expect(JsonEncoder(autoResetEntityCache: false).isStandard, isFalse);
    });
  });

  group('MimeTypeResolverExtension', () {
    test('lookupDynamic', () {
      var r = MimeTypeResolver();

      expect(r.lookupDynamic('png'), equals('image/png'));
      expect(r.lookupDynamic(' PNG '), equals('image/png'));
      // A trailing extra character is dropped.
      expect(r.lookupDynamic('pngx'), equals('image/png'));
      // An extra character before the last one is dropped.
      expect(r.lookupDynamic('pnxg'), equals('image/png'));
      expect(r.lookupDynamic('zz-unknown'), equals('application/octet-stream'));
      expect(r.lookupDynamic('zz', defaultMimeType: 'x/y'), equals('x/y'));
    });

    test('addMap / addDynamic / addExtensionAndMagicNumber', () {
      var r = MimeTypeResolver();

      r.addMap({
        'application/x-test-a': 'tsta',
        'application/x-test-b': ['tstb', 'tstbb'],
        'application/x-test-magic': [0xCA, 0xFE, 0x01],
      });

      expect(r.lookup('f.tsta'), equals('application/x-test-a'));
      expect(r.lookup('f.tstbb'), equals('application/x-test-b'));
      expect(
        r.lookup('f', headerBytes: [0xCA, 0xFE, 0x01, 0x00]),
        equals('application/x-test-magic'),
      );

      r.addExtensionAndMagicNumber('tstc', 'application/x-test-c', [
        0xBE,
        0xEF,
      ]);
      expect(r.lookup('f.tstc'), equals('application/x-test-c'));
      expect(
        r.lookup('f', headerBytes: [0xBE, 0xEF]),
        equals('application/x-test-c'),
      );

      // Empty parts are skipped.
      r.addExtensionAndMagicNumber('', 'application/x-test-d', []);
      expect(r.lookup('f.zzunknown'), isNull);
    });
  });
}
