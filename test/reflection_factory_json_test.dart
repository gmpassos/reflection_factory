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

void main() {
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
          equals({'enabled': true, 'name': 'Joe', 'password': '123'}));

      expect(
          JsonCodec(toEncodableProvider: (obj) {
            if (obj is TestUserWithReflection) {
              return (o, j) => o is TestUserWithReflection ? o.email : null;
            }
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
            'mainAddress': {'state': 'State1', 'city': 'City1'},
            'name': 'FooInc'
          }));

      expect(
          JsonCodec().encode(TestCompanyWithReflection(
              'FooInc', TestAddressWithReflection('State1', 'City1'), [
            TestAddressWithReflection('State2', 'City2'),
            TestAddressWithReflection('State3', 'City3')
          ])),
          equals(
              '{"extraAddresses":[{"state":"State2","city":"City2"},{"state":"State3","city":"City3"}],"mainAddress":{"state":"State1","city":"City1"},"name":"FooInc"}'));
    });

    test('fromJson', () async {
      expect(JsonCodec().fromJson(123), equals(123));

      expect(JsonCodec().fromJson('2020-01-02 10:11:12.000Z', type: DateTime),
          equals(DateTime.utc(2020, 1, 2, 10, 11, 12)));

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
            'name': 'FooInc'
          }, type: TestCompanyWithReflection),
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
            'mainAddress': {'state': 'State1', 'city': 'City1'},
            'name': 'FooInc'
          }),
          equals(TestCompanyWithReflection(
              'FooInc', TestAddressWithReflection('State1', 'City1'), [
            TestAddressWithReflection('State2', 'City2'),
            TestAddressWithReflection('State3', 'City3')
          ])));

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
    });

    test('encode', () async {
      expect(JsonCodec().encode({'a': 1, 'b': 2}), equals('{"a":1,"b":2}'));

      expect(JsonEncoder.defaultCodec.convert({'a': 1, 'b': 2}),
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
    });

    test('decode', () async {
      var jsonCodec = JsonCodec.defaultCodec;

      expect(jsonCodec.decode('{"a":1,"b":2}'), equals({'a': 1, 'b': 2}));

      expect(JsonDecoder.defaultCodec.convert('{"a":1,"b":2}'),
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
          JsonCodec(jsomMapDecoderAsyncProvider: (identifier) {
            var type = identifier is Type ? identifier : identifier.runtimeType;
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
  });
}
