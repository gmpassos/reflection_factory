import 'dart:convert';
import 'dart:typed_data';

import 'package:base_codecs/base_codecs.dart';
import 'package:data_serializer/data_serializer.dart';
import 'package:reflection_factory/reflection_factory.dart';
import 'package:test/test.dart';

import 'src/user_with_reflection.dart';

class Foo {
  int id;

  String name;

  Foo(this.id, this.name);

  @override
  String toString() {
    return '#$id[$name]';
  }
}

class AB {
  final int a;

  final int b;

  AB(this.a, this.b);

  AB.fromMap(Map<String, dynamic> o) : this(o['a'], o['b']);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AB &&
          runtimeType == other.runtimeType &&
          a == other.a &&
          b == other.b;

  @override
  int get hashCode => a.hashCode ^ b.hashCode;

  @override
  String toString() => 'AB{a: $a, b: $b}';
}

class Time {
  final int hour;

  final int minute;

  final int second;

  Time(this.hour, this.minute, this.second);

  factory Time.parse(String s) {
    var parts = s.split(':');
    return Time(
      int.parse(parts[0].trim()),
      int.parse(parts[1].trim()),
      int.parse(parts[2].trim()),
    );
  }

  factory Time.fromMap(Map map) => Time(
        map['hour'] ?? map['h'],
        map['minute'] ?? map['min'] ?? map['m'],
        map['second'] ?? map['sec'] ?? map['s'],
      );

  @override
  String toString() {
    return '$hour:$minute:$second';
  }

  Map<String, int> toMap() => {
        'hour': hour,
        'minute': minute,
        'second': second,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Time &&
          runtimeType == other.runtimeType &&
          hour == other.hour &&
          minute == other.minute &&
          second == other.second;

  @override
  int get hashCode => hour.hashCode ^ minute.hashCode ^ second.hashCode;
}

void main() {
  group('JSON', () {
    test('castListType', () {
      expect(<dynamic>['a', 'b'], isNot(isA<List<String>>()));
      expect(castListType(<dynamic>['a', 'b'], String), isA<List<String>>());
      expect(castListType(<dynamic>[1, 2], int), isA<List<int>>());
      expect(castListType(<dynamic>[1.2, 2.3], double), isA<List<double>>());
      expect(castListType(<dynamic>[1, 2.2], num), isA<List<num>>());
      expect(castListType(<dynamic>[true, false], bool), isA<List<bool>>());
      expect(castListType(<dynamic>[DateTime.now()], DateTime),
          isA<List<DateTime>>());
      expect(castListType(<dynamic>[BigInt.from(123)], BigInt),
          isA<List<BigInt>>());
      expect(castListType(<dynamic>[Uint8List(10)], Uint8List),
          isA<List<Uint8List>>());
    });
  });

  group('JsonCodec', () {
    setUp(() {});

    test('toJson', () async {
      expect(JsonCodec().toJson(123), equals(123));
      expect(JsonCodec().toJson(DateTime.utc(2021, 1, 2, 3, 4, 5)),
          equals('2021-01-02 03:04:05.000Z'));

      expect(
          JsonCodec(removeField: (k) => k == 'p')
              .toJson({'a': 1, 'b': 2, 'p': 123}),
          equals({'a': 1, 'b': 2}));

      expect(
          JsonCodec(maskField: (k) => k == 'p')
              .toJson({'a': 1, 'b': 2, 'p': 123}),
          equals({'a': 1, 'b': 2, 'p': '***'}));

      expect(JsonCodec().toJson({'a': 1, 'b': 2, 'foo': Foo(51, 'x')}),
          equals({'a': 1, 'b': 2, 'foo': '#51[x]'}));

      expect(
          JsonCodec(toEncodable: (o, j) => o is Foo ? '${o.id}:${o.name}' : o)
              .toJson(
            {'a': 1, 'b': 2, 'foo': Foo(51, 'x')},
          ),
          equals({'a': 1, 'b': 2, 'foo': '51:x'}));

      expect(JsonCodec().toJson(TestAddressWithReflection('LA', 'Los Angeles')),
          equals({'state': 'LA', 'city': 'Los Angeles'}));

      expect(
          JsonCodec(removeField: (k) => k == 'city')
              .toJson(TestAddressWithReflection('LA', 'Los Angeles')),
          equals({'state': 'LA'}));

      TestUserWithReflection$reflection();

      expect(
          JsonCodec(removeNullFields: true)
              .toJson(TestUserWithReflection.fields('Joe', null, '123')),
          equals({
            'axis': 'x',
            'enabled': true,
            'isEnabled': true,
            'name': 'Joe',
            'password': '123'
          }));

      expect(
          JsonCodec(removeNullFields: true).toJson(
              TestUserWithReflection.fields('Smith', null, '456',
                  axis: TestEnumWithReflection.Z)),
          equals({
            'axis': 'Z',
            'enabled': true,
            'isEnabled': true,
            'name': 'Smith',
            'password': '456'
          }));

      expect(
          JsonCodec(toEncodableProvider: (obj) {
            if (obj is TestUserWithReflection) {
              return (o, j) => o is TestUserWithReflection ? o.email : null;
            }
            return null;
          }).toJson(
              TestUserWithReflection.fields('Joe', 'joe@mail.com', '123')),
          equals('joe@mail.com'));

      expect(
          JsonCodec().toJson(TestCompanyWithReflection(
              'FooInc', TestAddressWithReflection('State1', 'City1'), [
            TestAddressWithReflection('State2', 'City2'),
            TestAddressWithReflection('State3', 'City3')
          ])),
          equals({
            'extraAddresses': [
              {'state': 'State2', 'city': 'City2'},
              {'state': 'State3', 'city': 'City3'}
            ],
            'extraNames': [],
            'mainAddress': {'state': 'State1', 'city': 'City1'},
            'name': 'FooInc'
          }));

      expect(JsonCodec().toJson(TestOpAWithReflection(10)),
          equals({'type': 'a', 'value': 10}));
    });

    test('fromJson', () async {
      expect(JsonCodec().fromJson(123), equals(123));

      expect(JsonCodec().fromJson('2020-01-02 10:11:12.000Z', type: DateTime),
          equals(DateTime.utc(2020, 1, 2, 10, 11, 12)));

      expect(
          JsonCodec().fromJson({
            'axis': 'x',
            'enabled': true,
            'isEnabled': true,
            'name': 'Joe',
            'password': '123'
          }, type: TestUserWithReflection),
          equals(TestUserWithReflection.fields('Joe', null, '123')));

      expect(
          JsonCodec().fromJson({
            'axis': 'x',
            'email': 'joe@mail.com',
            'enabled': true,
            'isEnabled': true,
            'level': 456,
            'name': 'Joe',
            'password': '123'
          }, type: TestUserWithReflection),
          equals(TestUserWithReflection.fields('Joe', 'joe@mail.com', '123',
              level: 456)));

      expect(
          JsonCodec().fromJson({'state': 'LA', 'city': 'Los Angeles'},
              type: TestAddressWithReflection),
          equals(TestAddressWithReflection('LA', 'Los Angeles')));

      expect(
          JsonCodec().fromJson({
            'city': 'Los Angeles',
            'state': 'LA',
          }, type: TestAddressWithReflection),
          equals(TestAddressWithReflection('LA', 'Los Angeles')));

      expect(
          JsonCodec().fromJson({
            'state': 'LA',
          }, type: TestAddressWithReflection),
          equals(TestAddressWithReflection('LA', '')));

      expect(
          JsonCodec().fromJson({
            'extraAddresses': [
              {'state': 'State2', 'city': 'City2'},
              {'state': 'State3', 'city': 'City3'}
            ],
            'mainAddress': {'state': 'State1', 'city': 'City1'},
            'name': 'FooInc',
            'extraNames': ['BarInc', 'BazIn'],
          }, type: TestCompanyWithReflection),
          equals(TestCompanyWithReflection(
              'FooInc', TestAddressWithReflection('State1', 'City1'), [
            TestAddressWithReflection('State2', 'City2'),
            TestAddressWithReflection('State3', 'City3')
          ],
              extraNames: [
                'BarInc',
                'BazIn'
              ])));

      expect(
          TestCompanyWithReflection$fromJson({
            'extraAddresses': [
              {'state': 'State2', 'city': 'City2'},
              {'state': 'State3', 'city': 'City3'}
            ],
            'mainAddress': {'state': 'State1', 'city': 'City1'},
            'name': 'FooInc'
          }),
          equals(TestCompanyWithReflection(
              'FooInc', TestAddressWithReflection('State1', 'City1'), [
            TestAddressWithReflection('State2', 'City2'),
            TestAddressWithReflection('State3', 'City3')
          ])));

      expect(
          TestCompanyWithReflection$fromJson({
            'extraAddresses': [
              {'state': 'State2', 'city': 'City2'},
              {'state': 'State3', 'city': 'City3'}
            ],
            'extraNames': ['BarIn', 'BazInc'],
            'mainAddress': {'state': 'State1', 'city': 'City1'},
            'name': 'FooInc'
          }),
          equals(TestCompanyWithReflection(
              'FooInc', TestAddressWithReflection('State1', 'City1'), [
            TestAddressWithReflection('State2', 'City2'),
            TestAddressWithReflection('State3', 'City3')
          ],
              extraNames: [
                'BarIn',
                'BazInc'
              ])));

      expect(
          await JsonCodec.defaultCodec.fromJsonAsync(
              Future.value({
                'extraAddresses': [
                  {'state': 'State2', 'city': 'City2'},
                  {'state': 'State3', 'city': 'City3'}
                ],
                'mainAddress': {'state': 'State1', 'city': 'City1'},
                'name': 'FooInc'
              }),
              type: TestCompanyWithReflection),
          equals(TestCompanyWithReflection(
              'FooInc', TestAddressWithReflection('State1', 'City1'), [
            TestAddressWithReflection('State2', 'City2'),
            TestAddressWithReflection('State3', 'City3')
          ])));

      expect(
          JsonCodec.defaultCodec.fromJsonList([
            TestAddressWithReflection('State2', 'City2'),
            TestAddressWithReflection('State3', 'City3')
          ], type: TestAddressWithReflection),
          equals([
            TestAddressWithReflection('State2', 'City2'),
            TestAddressWithReflection('State3', 'City3')
          ]));

      expect(
          await JsonCodec.defaultCodec.fromJsonListAsync(
              Future.value([
                TestAddressWithReflection('State2', 'City2'),
                TestAddressWithReflection('State3', 'City3')
              ]),
              type: TestAddressWithReflection),
          equals([
            TestAddressWithReflection('State2', 'City2'),
            TestAddressWithReflection('State3', 'City3')
          ]));

      expect(
          JsonCodec.defaultCodec.fromJsonMap(
              {'state': 'State1', 'city': 'City1'},
              type: TestAddressWithReflection),
          equals(
            TestAddressWithReflection('State1', 'City1'),
          ));

      expect(
          await JsonCodec.defaultCodec.fromJsonMapAsync(
              Future.value({'state': 'State1', 'city': 'City1'}),
              type: TestAddressWithReflection),
          equals(
            TestAddressWithReflection('State1', 'City1'),
          ));

      expect(
          await JsonCodec.defaultCodec.fromJsonMapAsync(
              {'state': 'State1', 'city': Future.value('City1')},
              type: TestAddressWithReflection),
          equals(
            TestAddressWithReflection('State1', 'City1'),
          ));

      expect(
          JsonCodec().decode(
              '{"extraAddresses":[{"state":"State2","city":"City2"},{"state":"State3","city":"City3"}],"mainAddress":{"state":"State1","city":"City1"},"name":"FooInc"}',
              type: TestCompanyWithReflection),
          equals(TestCompanyWithReflection(
              'FooInc', TestAddressWithReflection('State1', 'City1'), [
            TestAddressWithReflection('State2', 'City2'),
            TestAddressWithReflection('State3', 'City3')
          ])));

      expect(
          TestCompanyWithReflection$fromJsonEncoded(
            '{"extraAddresses":[{"state":"State2","city":"City2"},{"state":"State3","city":"City3"}],"mainAddress":{"state":"State1","city":"City1"},"name":"FooInc"}',
          ),
          equals(TestCompanyWithReflection(
              'FooInc', TestAddressWithReflection('State1', 'City1'), [
            TestAddressWithReflection('State2', 'City2'),
            TestAddressWithReflection('State3', 'City3')
          ])));

      expect(
          TestDataWithReflection$fromJsonEncoded(
            '{"bytes":"data:application/octet-stream;base64,SGVsbG8h","id":2,"name":"file"}',
          ),
          equals(TestDataWithReflection(
              'file', Uint8List.fromList(utf8.encode('Hello!')),
              id: BigInt.two)));

      expect(
          TestDataWithReflection$fromJsonEncoded(
            '{"bytes":"data:application/octet-stream;base64,SGkh","domain":"foo.com","id":2,"name":"file"}',
          ),
          equals(TestDataWithReflection(
              'file', Uint8List.fromList(utf8.encode('Hi!')),
              domain: TestDomainWithReflection('foo', 'com'), id: BigInt.two)));

      expect(
          TestDataWithReflection$fromJsonEncoded(
            '{"bytes":"data:application/octet-stream,Hello Plain!","id":2,"name":"file"}',
          ),
          equals(TestDataWithReflection(
              'file', Uint8List.fromList(utf8.encode('Hello Plain!')),
              id: BigInt.two)));

      expect(
          TestDataWithReflection$fromJsonEncoded(
            '{"bytes": "${base16Encode(Uint8List.fromList(utf8.encode('Hello Hex!')))}" ,"id":2,"name":"file"}',
          ),
          equals(TestDataWithReflection(
              'file', Uint8List.fromList(utf8.encode('Hello Hex!')),
              id: BigInt.two)));

      expect(
          TestDataWithReflection$fromJsonEncoded(
            '{"bytes": "${base64Encode(Uint8List.fromList(utf8.encode('Hello Base64!')))}" ,"id":2,"name":"file"}',
          ),
          equals(TestDataWithReflection(
              'file', Uint8List.fromList(utf8.encode('Hello Base64!')),
              id: BigInt.two)));
    });

    test('encode', () async {
      expect(JsonCodec().encode({'a': 1, 'b': 2}), equals('{"a":1,"b":2}'));

      expect(JsonEncoder.defaultEncoder.convert({'a': 1, 'b': 2}),
          equals('{"a":1,"b":2}'));

      expect(
          JsonCodec().encode({'a': 1, 'b': 2}, pretty: true),
          equals('{\n'
              '  "a": 1,\n'
              '  "b": 2\n'
              '}'));

      expect(
          JsonCodec(maskField: (f) => f.contains('pass'))
              .encode({'a': 1, 'pass': 123456}),
          equals('{"a":1,"pass":"***"}'));

      expect(
          JsonCodec(maskField: (f) => f.contains('pass'), maskText: 'x')
              .encode({'a': 1, 'pass': 123456}),
          equals('{"a":1,"pass":"x"}'));

      expect(
          JsonCodec().encode(TestCompanyWithReflection(
              'FooInc', TestAddressWithReflection('State1', 'City1'), [
            TestAddressWithReflection('State2', 'City2'),
            TestAddressWithReflection('State3', 'City3')
          ])),
          equals(
              '{"extraAddresses":[{"state":"State2","city":"City2"},{"state":"State3","city":"City3"}],"extraNames":[],"mainAddress":{"state":"State1","city":"City1"},"name":"FooInc"}'));

      expect(
          JsonCodec().encode(TestDataWithReflection(
              'file', Uint8List.fromList(utf8.encode('Hello!')),
              id: BigInt.two)),
          equals(
              '{"bytes":"hex:48656C6C6F21","domain":null,"id":2,"name":"file"}'));

      expect(
          JsonCodec().encode(TestDataWithReflection(
              'file',
              '89504e470d0a1a0a0000000d49484452000000010000000108060000001f15c4890000000d4944415478da636460f85f0f0002870180eb47ba920000000049454e44ae426082'
                  .decodeHex(),
              id: BigInt.two)),
          equals(
              '{"bytes":"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==","domain":null,"id":2,"name":"file"}'));

      expect(
          JsonCodec().encode(TestDataWithReflection(
              'file', Uint8List.fromList(utf8.encode('Hi!')),
              domain: TestDomainWithReflection('foo', 'com'), id: BigInt.two)),
          equals(
              '{"bytes":"hex:486921","domain":"foo.com","id":2,"name":"file"}'));

      {
        var jsonCodec = JsonCodec(toEncodableProvider: (o) {
          if (o is DateTime) {
            return (o, j) => 'date:$o';
          }
          return null;
        }, jsonValueDecoderProvider: (t, v) {
          if (t == DateTime || '$v'.startsWith('date:')) {
            return (o, t, j) {
              var s = '$o';
              var idx = s.indexOf(':');
              var dateStr = s.substring(idx + 1);
              return DateTime.parse(dateStr).toUtc();
            };
          }
          return null;
        });

        var json = jsonCodec
            .encode({'x': 123, 'date': DateTime.utc(2021, 10, 11, 20, 21, 22)});

        expect(
            json, equals('{"x":123,"date":"date:2021-10-11 20:21:22.000Z"}'));

        var decoded = jsonCodec.decode(json);

        expect(decoded,
            equals({'x': 123, 'date': DateTime.utc(2021, 10, 11, 20, 21, 22)}));
      }
    });

    test('decode', () async {
      var jsonCodec = JsonCodec.defaultCodec;

      expect(jsonCodec.decode('{"a":1,"b":2}'), equals({'a': 1, 'b': 2}));

      expect(JsonDecoder.defaultDecoder.convert('{"a":1,"b":2}'),
          equals({'a': 1, 'b': 2}));

      expect(await jsonCodec.decodeAsync<Map>(Future.value('{"a":1,"b":2}')),
          equals({'a': 1, 'b': 2}));

      expect(
          JsonCodec(jsomMapDecoder: (map, j) {
            return map.map((key, value) {
              switch (key) {
                case 'ab':
                  return MapEntry(
                      key, AB.fromMap(value as Map<String, dynamic>));
                default:
                  return MapEntry(key, value);
              }
            });
          }).decode('{"ab": {"a":1,"b":2}}'),
          equals({'ab': AB(1, 2)}));

      expect(
          JsonCodec().decode('{"state":"State3","city":"City3"}',
              type: TestAddressWithReflection),
          equals(TestAddressWithReflection('State3', 'City3')));

      expect(
          JsonCodec(jsomMapDecoderAsyncProvider: (type, map) {
            var classReflection =
                ReflectionFactory().getRegisterClassReflection(type)!;
            return (m, j) {
              // Ensure that instance Map comes from here (force values uppercase):
              m = m.map((key, value) =>
                  MapEntry(key, value.toString().toUpperCase()));
              return classReflection.createInstanceFromMap(m);
            };
          }).decodeAsync('{"state":"State4","city":"City4"}',
              type: TestAddressWithReflection),
          equals(TestAddressWithReflection('STATE4', 'CITY4')));
    });

    test('encode/decode', () {
      var jsonCodec = JsonCodec.defaultCodec;

      var t1 = Time(10, 11, 12);

      var json1 = jsonCodec.encode(t1);
      expect(json1, equals('"10:11:12"'));

      var m1 = {'id': 123, 'time': Time(20, 21, 22)};

      var json2 = jsonCodec.encode(m1);
      expect(json2, equals('{"id":123,"time":"20:21:22"}'));

      expect(() => jsonCodec.decode(json1, type: Time),
          throwsA(isA<UnsupportedError>()));

      expect(jsonCodec.decode(json2), equals({'id': 123, 'time': '20:21:22'}));

      var l1 = [Time(1, 2, 3), Time(11, 12, 13)];
      var json3 = jsonCodec.encode(l1);
      expect(json3, equals('["1:2:3","11:12:13"]'));

      JsonDecoder.registerTypeDecoder(Time, (json) {
        if (json is String) {
          return Time.parse(json);
        } else if (json is Map) {
          return Time.fromMap(json);
        } else {
          return null;
        }
      });

      var t2 = jsonCodec.decode(json1, type: Time);
      expect(t2, equals(t1));

      expect(
          () => jsonCodec.decode(json2, type: Time), throwsA(isA<TypeError>()));

      var l2 = jsonCodec.decode(json3, type: Time);
      expect(l2, equals(l1));

      JsonEncoder.registerTypeToEncodable(Time, (o, e) => (o as Time).toMap());

      var json4 = jsonCodec.encode(t1);
      expect(json4, equals('{"hour":10,"minute":11,"second":12}'));

      expect(jsonCodec.decode(json4, type: Time), equals(Time(10, 11, 12)));

      expect(JsonDecoder.removeTypeDecoder(Time), isNotNull);
    });

    test('encodeToBytes/decodeFromBytes', () async {
      var jsonBytes = JsonCodec().encodeToBytes({'a': 1, 'b': 2});
      expect(utf8.decode(jsonBytes), equals('{"a":1,"b":2}'));
      expect(JsonCodec().decodeFromBytes(jsonBytes), equals({'a': 1, 'b': 2}));

      var jsonBytes2 =
          JsonCodec().encodeToBytes({'a': 1, 'b': 2}, pretty: true);
      expect(utf8.decode(jsonBytes2), equals('{\n  "a": 1,\n  "b": 2\n}'));
      expect(JsonCodec().decodeFromBytes(jsonBytes2), equals({'a': 1, 'b': 2}));
      expect(await JsonCodec().decodeFromBytesAsync(Future.value(jsonBytes2)),
          equals({'a': 1, 'b': 2}));
    });
  });
}
