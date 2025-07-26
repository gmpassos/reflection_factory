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
  group('JsonAnnotation', () {
    test('JsonField', () {
      expect(JsonField.hidden().isHidden, isTrue);
      expect(JsonField.hidden().isVisible, isFalse);

      expect(JsonField.visible().isVisible, isTrue);
      expect(JsonField.visible().isHidden, isFalse);
    });

    test('JsonFieldAlias', () {
      expect(JsonFieldAlias('abc').isValid, isTrue);
      expect(JsonFieldAlias('a').isValid, isTrue);
      expect(JsonFieldAlias('b').isValid, isTrue);

      expect(JsonFieldAlias('').isValid, isFalse);
      expect(JsonFieldAlias(' ').isValid, isFalse);
      expect(JsonFieldAlias(' abc ').isValid, isFalse);
      expect(JsonFieldAlias(' ab-c ').isValid, isFalse);

      expect(JsonFieldAlias('123').isValid, isFalse);
      expect(JsonFieldAlias('1').isValid, isFalse);
      expect(JsonFieldAlias('1a').isValid, isFalse);
      expect(JsonFieldAlias('1abc').isValid, isFalse);

      expect(
          [JsonFieldAlias('abc'), JsonFieldAlias('123'), JsonFieldAlias('def')]
              .validNames,
          equals(['abc', 'def']));

      expect(
          [JsonFieldAlias('abc'), JsonFieldAlias('123'), JsonFieldAlias('abc')]
              .alias,
          equals('abc'));

      expect(
          () => [
                JsonFieldAlias('abc'),
                JsonFieldAlias('123'),
                JsonFieldAlias('def')
              ].alias,
          throwsA(isA<StateError>()));
    });
  });

  group('JSON', () {
    test('castListType', () {
      expect(<dynamic>['a', 'b'], isNot(isA<List<String>>()));
      expect(castListType<String>(<String>['a', 'b'], String),
          isA<List<String>>());
      expect(castListType(<dynamic>['a', 'b'], String), isA<List<String>>());
      expect(castListType(<dynamic>[1, 2], int), isA<List<int>>());
      expect(castListType(<dynamic>[1.2, 2.3], double), isA<List<double>>());
      expect(castListType(<dynamic>[1, 2.2], num), isA<List<num>>());
      expect(castListType(<dynamic>[true, false], bool), isA<List<bool>>());
      expect(castListType(<dynamic>[DateTime.now()], DateTime),
          isA<List<DateTime>>());
      expect(castListType(<dynamic>[Duration(hours: -3)], Duration),
          isA<List<Duration>>());
      expect(castListType(<dynamic>[BigInt.from(123)], BigInt),
          isA<List<BigInt>>());
      expect(castListType(<dynamic>[Uint8List(10)], Uint8List),
          isA<List<Uint8List>>());
    });

    test('castMapType', () {
      expect(<dynamic, dynamic>{'a': 'b'}, isNot(isA<Map<String, String>>()));
      expect(
          castMapType<String, String>(
              <String, String>{'a': 'b'}, String, String),
          isA<Map<String, String>>());
      expect(castMapType(<dynamic, dynamic>{'a': 'b'}, String, String),
          isA<Map<String, String>>());
      expect(castMapType(<dynamic, dynamic>{'a': 1}, String, int),
          isA<Map<String, int>>());
      expect(castMapType(<dynamic, dynamic>{'a': 1.2}, String, double),
          isA<Map<String, double>>());
      expect(castMapType(<dynamic, dynamic>{'a': 1.2, 'b': 2}, String, num),
          isA<Map<String, num>>());
      expect(castMapType(<dynamic, dynamic>{'a': true}, String, bool),
          isA<Map<String, bool>>());

      expect(
          castMapType(
              <dynamic, dynamic>{'a': DateTime.now()}, String, DateTime),
          isA<Map<String, DateTime>>());

      expect(
          castMapType(
              <dynamic, dynamic>{'a': Duration(hours: 4)}, String, Duration),
          isA<Map<String, Duration>>());

      expect(castMapType(<dynamic, dynamic>{'a': BigInt.zero}, String, BigInt),
          isA<Map<String, BigInt>>());
      expect(
          castMapType(
              <dynamic, dynamic>{'a': Uint8List(10)}, String, Uint8List),
          isA<Map<String, Uint8List>>());

      expect(castMapType<int, String>(<int, String>{1: 'b'}, int, String),
          isA<Map<int, String>>());

      expect(castMapType(<dynamic, dynamic>{1: 'b'}, int, String),
          isA<Map<int, String>>());
      expect(castMapType(<dynamic, dynamic>{1.2: 'b'}, double, String),
          isA<Map<double, String>>());
      expect(castMapType(<dynamic, dynamic>{1.2: 'b', 1: 'a'}, num, String),
          isA<Map<num, String>>());
      expect(castMapType(<dynamic, dynamic>{true: 'b'}, bool, String),
          isA<Map<bool, String>>());

      expect(
          castMapType(
              <dynamic, dynamic>{DateTime.now(): 'b'}, DateTime, String),
          isA<Map<DateTime, String>>());

      expect(
          castMapType(
              <dynamic, dynamic>{Duration(minutes: 1): 'b'}, Duration, String),
          isA<Map<Duration, String>>());

      expect(castMapType(<dynamic, dynamic>{BigInt.zero: 'b'}, BigInt, String),
          isA<Map<BigInt, String>>());
      expect(
          castMapType(
              <dynamic, dynamic>{Uint8List(10): 'b'}, Uint8List, String),
          isA<Map<Uint8List, String>>());

      expect(castMapType(<dynamic, dynamic>{'a': 1}, String, dynamic),
          isA<Map<String, dynamic>>());

      expect(castMapType(<dynamic, dynamic>{'a': 1}, String, Object),
          isA<Map<String, Object>>());

      expect(castMapType(<dynamic, dynamic>{}, String, dynamic),
          isA<Map<String, dynamic>>());

      expect(castMapType(<dynamic, dynamic>{}, String, Object),
          isA<Map<String, Object>>());

      expect(
          castMapType(
            <dynamic, dynamic>{1: 'a', 'n': 'b'},
            Object,
            String,
          ),
          isA<Map<dynamic, String>>());

      expect(
          castMapType(
            <dynamic, dynamic>{1: 'a', 'n': 'b'},
            Object,
            String,
          ),
          isA<Map<Object, String>>());

      expect(
          castMapType(
            <dynamic, dynamic>{},
            Object,
            String,
          ),
          isA<Map<dynamic, String>>());

      expect(
          castMapType(
            <dynamic, dynamic>{},
            Object,
            String,
          ),
          isA<Map<Object, String>>());
    });
  });

  group('JsonCodec', () {
    setUp(() {});

    test('toJson', () async {
      expect(JsonCodec().toJson(123), equals(123));
      expect(JsonCodec().toJson(DateTime.utc(2021, 1, 2, 3, 4, 5)),
          equals('2021-01-02 03:04:05.000Z'));

      expect(
          JsonCodec().toJson(
              Duration(hours: 4, minutes: 10, seconds: 3, milliseconds: 101)),
          equals((4 * 60 * 60 * 1000) + (10 * 60 * 1000) + (3 * 1000) + 101));

      expect(JsonCodec().toJson(Duration(hours: -3)),
          equals(-(3 * 60 * 60 * 1000)));

      expect(
          JsonCodec().toJson(Duration(
              hours: 4,
              minutes: 10,
              seconds: 3,
              milliseconds: 101,
              microseconds: 13)),
          equals('4:10:3:101:13'));

      expect(JsonCodec().toJson(Duration(hours: -4, microseconds: -13)),
          equals('-4:0:0:0:-13'));

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

      expect(
          JsonCodec().toJson(
              TestAddressWithReflection.withCity('LA', city: 'Los Angeles')),
          equals({'state': 'LA', 'city': 'Los Angeles'}));

      expect(
          JsonCodec(removeField: (k) => k == 'city').toJson(
              TestAddressWithReflection.withCity('LA', city: 'Los Angeles')),
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
            //'password': '123'
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
            //'password': '456'
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
          JsonCodec().toJson(TestCompanyWithReflection('FooInc',
              TestAddressWithReflection.withCity('State1', city: 'City1'),
              extraAddresses: [
                TestAddressWithReflection.withCity('State2', city: 'City2'),
                TestAddressWithReflection.withCity('State3', city: 'City3')
              ])),
          equals({
            'branchesAddresses': [],
            'extraAddresses': [
              {'state': 'State2', 'city': 'City2'},
              {'state': 'State3', 'city': 'City3'}
            ],
            'extraNames': [],
            'mainAddress': {'state': 'State1', 'city': 'City1'},
            'name': 'FooInc'
          }));

      expect(<dynamic>[
        TestAddressWithReflection.withCity('State2', city: 'City2'),
        TestAddressWithReflection.withCity('State3', city: 'City3')
      ], isNot(isA<List<TestAddressWithReflection>>()));

      expect(
          JsonCodec().toJson(TestFranchiseWithReflection(
            'FooInc',
            {
              'main':
                  TestAddressWithReflection.withCity('State1', city: 'City1'),
              'extra':
                  TestAddressWithReflection.withCity('State1', city: 'City2')
            },
          )),
          equals({
            'addresses': {
              'main': {'state': 'State1', 'city': 'City1'},
              'extra': {'state': 'State1', 'city': 'City2'}
            },
            'name': 'FooInc'
          }));

      // List:

      expect(
          TestAddressWithReflection$reflection.staticInstance
              .castCollection(<dynamic>[
            TestAddressWithReflection.withCity('State2', city: 'City2'),
            TestAddressWithReflection.withCity('State3', city: 'City3')
          ], TypeInfo.fromType(List, [TestAddressWithReflection])),
          isA<List<TestAddressWithReflection>>());

      expect(
          TestAddressWithReflection$reflection.staticInstance.castCollection(
              <dynamic>[
                TestAddressWithReflection.withCity('State2', city: 'City2'),
                null
              ],
              TypeInfo.fromType(List, [TestAddressWithReflection]),
              nullable: true),
          isA<List<TestAddressWithReflection?>>());

      expect(
          TestAddressWithReflection$reflection.staticInstance
              .castCollection(<dynamic>[
            TestAddressWithReflection.withCity('State2', city: 'City2'),
            TestAddressWithReflection.withCity('State3', city: 'City3')
          ], TypeInfo.fromType(List, [Object])),
          isA<List<Object>>());

      expect(
          TestAddressWithReflection$reflection.staticInstance
              .castCollection(<dynamic>[
            TestAddressWithReflection.withCity('State2', city: 'City2'),
            null
          ], TypeInfo.fromType(List, [Object]), nullable: true),
          isA<List<Object?>>());

      expect(
          TestAddressWithReflection$reflection.staticInstance
              .castCollection(<dynamic>[
            TestAddressWithReflection.withCity('State2', city: 'City2'),
            TestAddressWithReflection.withCity('State3', city: 'City3')
          ], TypeInfo.fromType(List, [dynamic])),
          isA<List<dynamic>>());

      expect(
          TestAddressWithReflection$reflection.staticInstance.castCollection(
              <dynamic>[123, 456], TypeInfo.fromType(List, [int])),
          isA<List<int>>());

      expect(
          TestAddressWithReflection$reflection.staticInstance.castCollection(
              <dynamic>[123, null], TypeInfo.fromType(List, [int]),
              nullable: true),
          isA<List<int?>>());

      // Iterable:

      expect(
          TestAddressWithReflection$reflection.staticInstance
              .castCollection(<dynamic>[
            TestAddressWithReflection.withCity('State2', city: 'City2'),
            TestAddressWithReflection.withCity('State3', city: 'City3')
          ], TypeInfo.fromType(Iterable, [TestAddressWithReflection])),
          isA<Iterable<TestAddressWithReflection>>());

      expect(
          TestAddressWithReflection$reflection.staticInstance.castCollection(
              <dynamic>[
                TestAddressWithReflection.withCity('State2', city: 'City2'),
                null
              ],
              TypeInfo.fromType(Iterable, [TestAddressWithReflection]),
              nullable: true),
          isA<Iterable<TestAddressWithReflection?>>());

      expect(
          TestAddressWithReflection$reflection.staticInstance
              .castCollection(<dynamic>[
            TestAddressWithReflection.withCity('State2', city: 'City2'),
            TestAddressWithReflection.withCity('State3', city: 'City3')
          ], TypeInfo.fromType(Iterable, [Object])),
          isA<Iterable<Object>>());

      expect(
          TestAddressWithReflection$reflection.staticInstance
              .castCollection(<dynamic>[
            TestAddressWithReflection.withCity('State2', city: 'City2'),
            null
          ], TypeInfo.fromType(Iterable, [Object]), nullable: true),
          isA<Iterable<Object?>>());

      expect(
          TestAddressWithReflection$reflection.staticInstance
              .castCollection(<dynamic>[
            TestAddressWithReflection.withCity('State2', city: 'City2'),
            TestAddressWithReflection.withCity('State3', city: 'City3')
          ], TypeInfo.fromType(Iterable, [dynamic])),
          isA<Iterable<dynamic>>());

      expect(
          TestAddressWithReflection$reflection.staticInstance.castCollection(
              <dynamic>[123, 456], TypeInfo.fromType(Iterable, [int])),
          isA<Iterable<int>>());

      expect(
          TestAddressWithReflection$reflection.staticInstance.castCollection(
              <dynamic>[123, null], TypeInfo.fromType(Iterable, [int]),
              nullable: true),
          isA<Iterable<int?>>());

      // Set:

      expect(
          TestAddressWithReflection$reflection.staticInstance
              .castCollection(<dynamic>{
            TestAddressWithReflection.withCity('State2', city: 'City2'),
            TestAddressWithReflection.withCity('State3', city: 'City3')
          }, TypeInfo.fromType(Set, [TestAddressWithReflection])),
          isA<Set<TestAddressWithReflection>>());

      expect(
          TestAddressWithReflection$reflection.staticInstance.castCollection(
              <dynamic>{
                TestAddressWithReflection.withCity('State2', city: 'City2'),
                null
              },
              TypeInfo.fromType(Set, [TestAddressWithReflection]),
              nullable: true),
          isA<Set<TestAddressWithReflection?>>());

      expect(
          TestAddressWithReflection$reflection.staticInstance
              .castCollection(<dynamic>{
            TestAddressWithReflection.withCity('State2', city: 'City2'),
            TestAddressWithReflection.withCity('State3', city: 'City3')
          }, TypeInfo.fromType(Set, [Object])),
          isA<Set<Object>>());

      expect(
          TestAddressWithReflection$reflection.staticInstance
              .castCollection(<dynamic>{
            TestAddressWithReflection.withCity('State2', city: 'City2'),
            null
          }, TypeInfo.fromType(Set, [Object]), nullable: true),
          isA<Set<Object?>>());

      expect(
          TestAddressWithReflection$reflection.staticInstance
              .castCollection(<dynamic>{
            TestAddressWithReflection.withCity('State2', city: 'City2'),
            TestAddressWithReflection.withCity('State3', city: 'City3')
          }, TypeInfo.fromType(Set, [dynamic])),
          isA<Set<dynamic>>());

      expect(
          TestAddressWithReflection$reflection.staticInstance.castCollection(
              <dynamic>{123, 456}, TypeInfo.fromType(Set, [int])),
          isA<Set<int>>());

      expect(
          TestAddressWithReflection$reflection.staticInstance.castCollection(
              <dynamic>{123, null}, TypeInfo.fromType(Set, [int]),
              nullable: true),
          isA<Set<int?>>());

      // Map:

      expect(
          TestAddressWithReflection$reflection.staticInstance
              .castCollection(<Object, dynamic>{
            'a': TestAddressWithReflection.withCity('State2', city: 'City2'),
            'b': TestAddressWithReflection.withCity('State3', city: 'City3')
          }, TypeInfo.fromType(Map, [String, TestAddressWithReflection])),
          isA<Map<String, TestAddressWithReflection>>());

      expect(
          TestAddressWithReflection$reflection.staticInstance
              .castCollection(<Object, dynamic>{
            'a': TestAddressWithReflection.withCity('State2', city: 'City2'),
            'b': null
          }, TypeInfo.fromType(Map, [String, TestAddressWithReflection]),
                  nullable: true),
          isA<Map<String, TestAddressWithReflection?>>());

      expect(
          TestAddressWithReflection$reflection.staticInstance
              .castCollection(<Object, dynamic>{
            'a': TestAddressWithReflection.withCity('State2', city: 'City2'),
            'b': TestAddressWithReflection.withCity('State3', city: 'City3')
          }, TypeInfo.fromType(Map, [String, dynamic])),
          isA<Map<String, dynamic>>());

      expect(
          TestAddressWithReflection$reflection.staticInstance
              .castCollection(<Object, dynamic>{
            'a': TestAddressWithReflection.withCity('State2', city: 'City2'),
            'b': TestAddressWithReflection.withCity('State3', city: 'City3')
          }, TypeInfo.fromType(Map, [String, Object])),
          isA<Map<String, Object>>());

      expect(
          TestAddressWithReflection$reflection.staticInstance
              .castCollection(<Object, dynamic>{
            'a': TestAddressWithReflection.withCity('State2', city: 'City2'),
            'b': TestAddressWithReflection.withCity('State3', city: 'City3')
          }, TypeInfo.fromType(Map, [Object, TestAddressWithReflection])),
          isA<Map<Object, TestAddressWithReflection>>());

      expect(
          TestAddressWithReflection$reflection.staticInstance
              .castCollection(<Object, dynamic>{
            'a': TestAddressWithReflection.withCity('State2', city: 'City2'),
            'b': TestAddressWithReflection.withCity('State3', city: 'City3')
          }, TypeInfo.fromType(Map, [Object, dynamic])),
          isA<Map<Object, dynamic>>());

      expect(
          TestAddressWithReflection$reflection.staticInstance
              .castCollection(<Object, dynamic>{
            'a': TestAddressWithReflection.withCity('State2', city: 'City2'),
            'b': TestAddressWithReflection.withCity('State3', city: 'City3')
          }, TypeInfo.fromType(Map, [Object, Object])),
          isA<Map<Object, Object>>());

      expect(
          TestAddressWithReflection$reflection.staticInstance
              .castCollection(<Object, dynamic>{
            'a': TestAddressWithReflection.withCity('State2', city: 'City2'),
            'b': TestAddressWithReflection.withCity('State3', city: 'City3')
          }, TypeInfo.fromType(Map, [dynamic, TestAddressWithReflection])),
          isA<Map<dynamic, TestAddressWithReflection>>());

      expect(
          TestAddressWithReflection$reflection.staticInstance
              .castCollection(<Object, dynamic>{
            'a': TestAddressWithReflection.withCity('State2', city: 'City2'),
            'b': TestAddressWithReflection.withCity('State3', city: 'City3')
          }, TypeInfo.fromType(Map, [dynamic, Object])),
          isA<Map<dynamic, Object>>());

      expect(
          TestAddressWithReflection$reflection.staticInstance
              .castCollection(<Object, dynamic>{
            'a': TestAddressWithReflection.withCity('State2', city: 'City2'),
            'b': TestAddressWithReflection.withCity('State3', city: 'City3')
          }, TypeInfo.fromType(Map, [dynamic, dynamic])),
          isA<Map<dynamic, dynamic>>());

      expect(
          TestAddressWithReflection$reflection.staticInstance.castCollection(
              <Object, Object>{'a': 123, 'b': 456},
              TypeInfo.fromType(Map, [String, int])),
          isA<Map<String, int>>());

      expect(
          TestAddressWithReflection$reflection.staticInstance.castCollection(
              <Object, Object?>{'a': 123, 'b': null},
              TypeInfo.fromType(Map, [String, int]),
              nullable: true),
          isA<Map<String, int?>>());

      expect(JsonCodec().toJson(TestOpAWithReflection(10)),
          equals({'type': 'a', 'value': 10}));

      expect(
          TestOpAWithReflection$reflection.staticInstance
              .callCasted(<T>(c) => T),
          equals(TestOpAWithReflection));

      expect(
          TestEnumWithReflection$reflection.staticInstance
              .callCasted(<T>(c) => T),
          equals(TestEnumWithReflection));
    });

    test('fromJson', () async {
      expect(JsonCodec().fromJson(123), equals(123));

      expect(JsonCodec().fromJson('2020-01-02 10:11:12.000Z', type: DateTime),
          equals(DateTime.utc(2020, 1, 2, 10, 11, 12)));

      expect(
          JsonCodec().fromJson('4:20:10:303', type: Duration),
          equals(
              Duration(hours: 4, minutes: 20, seconds: 10, milliseconds: 303)));

      expect(
          () => JsonCodec().fromJson({
                'axis': 'x',
                'enabled': true,
                'isEnabled': true,
                'name': 'Joe',
              }, type: TestUserWithReflection),
          throwsA(isA<StateError>().having((e) => e.message, 'final name',
              contains('due final field `name`'))));

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
          equals(
              TestAddressWithReflection.withCity('LA', city: 'Los Angeles')));

      expect(
          JsonCodec().fromJson({
            'city': 'Los Angeles',
            'state': 'LA',
          }, type: TestAddressWithReflection),
          equals(
              TestAddressWithReflection.withCity('LA', city: 'Los Angeles')));

      expect(
          JsonCodec().fromJson({
            'state': 'LA',
          }, type: TestAddressWithReflection),
          equals(TestAddressWithReflection.withCity('LA')));

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
          equals(TestCompanyWithReflection('FooInc',
              TestAddressWithReflection.withCity('State1', city: 'City1'),
              extraAddresses: [
                TestAddressWithReflection.withCity('State2', city: 'City2'),
                TestAddressWithReflection.withCity('State3', city: 'City3')
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
          equals(TestCompanyWithReflection('FooInc',
              TestAddressWithReflection.withCity('State1', city: 'City1'),
              extraAddresses: [
                TestAddressWithReflection.withCity('State2', city: 'City2'),
                TestAddressWithReflection.withCity('State3', city: 'City3')
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
          equals(TestCompanyWithReflection('FooInc',
              TestAddressWithReflection.withCity('State1', city: 'City1'),
              extraAddresses: [
                TestAddressWithReflection.withCity('State2', city: 'City2'),
                TestAddressWithReflection.withCity('State3', city: 'City3')
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
          equals(TestCompanyWithReflection('FooInc',
              TestAddressWithReflection.withCity('State1', city: 'City1'),
              extraAddresses: [
                TestAddressWithReflection.withCity('State2', city: 'City2'),
                TestAddressWithReflection.withCity('State3', city: 'City3')
              ])));

      expect(
          await JsonCodec.defaultCodec.fromJsonAsync(
              Future.value({
                'addresses': {
                  'a': {'state': 'State', 'city': 'A'},
                  'b': {'state': 'State', 'city': 'B'}
                },
                'name': 'FooFranchise'
              }),
              type: TestFranchiseWithReflection),
          equals(TestFranchiseWithReflection('FooFranchise', {
            'a': TestAddressWithReflection.withCity('State', city: 'A'),
            'b': TestAddressWithReflection.withCity('State', city: 'B'),
          })));

      expect(
          JsonCodec.defaultCodec.fromJsonList([
            TestAddressWithReflection.withCity('State2', city: 'City2'),
            TestAddressWithReflection.withCity('State3', city: 'City3')
          ], type: TestAddressWithReflection),
          equals([
            TestAddressWithReflection.withCity('State2', city: 'City2'),
            TestAddressWithReflection.withCity('State3', city: 'City3')
          ]));

      expect(
          await JsonCodec.defaultCodec.fromJsonListAsync(
              Future.value([
                TestAddressWithReflection.withCity('State2', city: 'City2'),
                TestAddressWithReflection.withCity('State3', city: 'City3')
              ]),
              type: TestAddressWithReflection),
          equals([
            TestAddressWithReflection.withCity('State2', city: 'City2'),
            TestAddressWithReflection.withCity('State3', city: 'City3')
          ]));

      expect(
          JsonCodec.defaultCodec
              .fromJsonList(['x', 'z'], type: TestEnumWithReflection),
          allOf(equals([TestEnumWithReflection.x, TestEnumWithReflection.z]),
              isA<List<TestEnumWithReflection>>()));

      expect(
          JsonCodec.defaultCodec.fromJsonMap(
              {'state': 'State1', 'city': 'City1'},
              type: TestAddressWithReflection),
          equals(
            TestAddressWithReflection.withCity('State1', city: 'City1'),
          ));

      expect(
          await JsonCodec.defaultCodec.fromJsonMapAsync(
              Future.value({'state': 'State1', 'city': 'City1'}),
              type: TestAddressWithReflection),
          equals(
            TestAddressWithReflection.withCity('State1', city: 'City1'),
          ));

      expect(
          await JsonCodec.defaultCodec.fromJsonMapAsync(
              {'state': 'State1', 'city': Future.value('City1')},
              type: TestAddressWithReflection),
          equals(
            TestAddressWithReflection.withCity('State1', city: 'City1'),
          ));

      expect(
          JsonCodec().decode(
              '{"extraAddresses":[{"state":"State2","city":"City2"},{"state":"State3","city":"City3"}],"mainAddress":{"state":"State1","city":"City1"},"name":"FooInc"}',
              type: TestCompanyWithReflection),
          equals(TestCompanyWithReflection('FooInc',
              TestAddressWithReflection.withCity('State1', city: 'City1'),
              extraAddresses: [
                TestAddressWithReflection.withCity('State2', city: 'City2'),
                TestAddressWithReflection.withCity('State3', city: 'City3')
              ])));

      expect(
          TestCompanyWithReflection$fromJsonEncoded(
            '{"extraAddresses":[{"state":"State2","city":"City2"},{"state":"State3","city":"City3"}],"mainAddress":{"state":"State1","city":"City1"},"name":"FooInc"}',
          ),
          equals(TestCompanyWithReflection('FooInc',
              TestAddressWithReflection.withCity('State1', city: 'City1'),
              extraAddresses: [
                TestAddressWithReflection.withCity('State2', city: 'City2'),
                TestAddressWithReflection.withCity('State3', city: 'City3')
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

    test('fromJsonMap', () async {
      var jMap1 = <String, dynamic>{"1": 1000, "2": 2000};
      var typeInfo1 = TypeInfo.fromMapType(int, Duration);

      var map1 = JsonCodec()
          .fromJsonMap<Map<int, Duration>>(jMap1, typeInfo: typeInfo1);

      expect(map1, equals({1: Duration(seconds: 1), 2: Duration(seconds: 2)}));

      var map1Async = await JsonCodec()
          .fromJsonMapAsync<Map<int, Duration>>(jMap1, typeInfo: typeInfo1);

      expect(map1Async,
          equals({1: Duration(seconds: 1), 2: Duration(seconds: 2)}));

      ////

      var typeInfo2 = TypeInfo.fromMapType(String, Duration);

      var map2 = JsonCodec()
          .fromJsonMap<Map<String, Duration>>(jMap1, typeInfo: typeInfo2);

      expect(
          map2, equals({'1': Duration(seconds: 1), '2': Duration(seconds: 2)}));

      var map2Async = await JsonCodec()
          .fromJsonMapAsync<Map<String, Duration>>(jMap1, typeInfo: typeInfo2);

      expect(map2Async,
          equals({'1': Duration(seconds: 1), '2': Duration(seconds: 2)}));

      ////

      var typeInfo3 = TypeInfo.fromMapType(int, dynamic);

      var map3 = JsonCodec()
          .fromJsonMap<Map<int, dynamic>>(jMap1, typeInfo: typeInfo3);

      expect(map3, equals({1: 1000, 2: 2000}));

      var map3Async = await JsonCodec()
          .fromJsonMapAsync<Map<int, dynamic>>(jMap1, typeInfo: typeInfo3);

      expect(map3Async, equals({1: 1000, 2: 2000}));

      ////

      var typeInfo4 = TypeInfo.fromMapType(String, dynamic);

      var map4 = JsonCodec()
          .fromJsonMap<Map<String, dynamic>>(jMap1, typeInfo: typeInfo4);

      expect(map4, equals({'1': 1000, '2': 2000}));

      var map4Async = await JsonCodec()
          .fromJsonMapAsync<Map<String, dynamic>>(jMap1, typeInfo: typeInfo4);

      expect(map4Async, equals({'1': 1000, '2': 2000}));

      ////

      var objMap = {
        'a':
            TestAddressWithReflection.withCity('NY', city: 'New York', id: 101),
        'b': TestAddressWithReflection.withCity('CA',
            city: 'Los Angeles', id: 201),
      };

      var enc = JsonCodec().encode(objMap);
      var jMap2 = JsonCodec().decode(enc);

      var typeInfo5 = TypeInfo.fromType(Map, [
        TypeInfo.tString,
        TypeInfo<TestAddressWithReflection>.fromType(TestAddressWithReflection)
      ]);

      var map5 = JsonCodec()
          .fromJsonMap<Map<String, TestAddressWithReflection>>(jMap2,
              typeInfo: typeInfo5);

      expect(
          map5,
          equals({
            'a': TestAddressWithReflection.withCity('NY',
                city: 'New York', id: 101),
            'b': TestAddressWithReflection.withCity('CA',
                city: 'Los Angeles', id: 201),
          }));

      ////

      var typeInfo6 = TypeInfo.fromType(Map, [
        TypeInfo.tString,
        TypeInfo<dynamic>.fromType(TestAddressWithReflection)
      ]);

      var map6 = JsonCodec()
          .fromJsonMap<Map<String, dynamic>>(jMap2, typeInfo: typeInfo6);

      expect(
          map6,
          equals({
            'a': TestAddressWithReflection.withCity('NY',
                city: 'New York', id: 101),
            'b': TestAddressWithReflection.withCity('CA',
                city: 'Los Angeles', id: 201),
          }));
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
          JsonCodec().encode(TestCompanyWithReflection('FooInc',
              TestAddressWithReflection.withCity('State1', city: 'City1'),
              extraAddresses: [
                TestAddressWithReflection.withCity('State2', city: 'City2'),
                TestAddressWithReflection.withCity('State3', city: 'City3')
              ])),
          equals(
              '{"branchesAddresses":[],"extraAddresses":[{"state":"State2","city":"City2"},{"state":"State3","city":"City3"}],"extraNames":[],"mainAddress":{"state":"State1","city":"City1"},"name":"FooInc"}'));

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
        }, jsonValueDecoderProvider: (t, v, j) {
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
          equals(TestAddressWithReflection.withCity('State3', city: 'City3')));

      expect(
          JsonCodec(jsomMapDecoderAsyncProvider: (type, map, j) {
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
          equals(TestAddressWithReflection.withCity('STATE4', city: 'CITY4')));

      expect(
          JsonCodec(jsomMapDecoderAsyncProvider: (type, map, j) {
            var classReflection =
                ReflectionFactory().getRegisterClassReflection(type)!;
            return (m, j) {
              // Ensure that instance Map comes from here (force values uppercase):
              m = m.map((key, value) => MapEntry(
                  key, key != 'id' ? value.toString().toUpperCase() : value));
              return classReflection.createInstanceFromMap(m);
            };
          }).decodeAsync('{"state":"State4","id":123}',
              type: TestAddressWithReflection),
          equals(TestAddressWithReflection.simple('STATE4', id: 123)));
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

      JsonDecoder.registerTypeDecoder(Time, (json, jsonDecoder, t) {
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

    test('encodeToSink/decodeFromBytes', () async {
      var bytesSink = _MyBytesSink();
      JsonCodec().encodeToSink({'a': 1, 'b': 2}, bytesSink);
      var jsonBytes = bytesSink.bytes;

      expect(utf8.decode(jsonBytes), equals('{"a":1,"b":2}'));
      expect(JsonCodec().decodeFromBytes(jsonBytes), equals({'a': 1, 'b': 2}));

      var bytesSink2 = _MyBytesSink();
      JsonCodec().encodeToSink({'a': 1, 'b': 2}, bytesSink2, pretty: true);
      var jsonBytes2 = bytesSink2.bytes;

      expect(utf8.decode(jsonBytes2), equals('{\n  "a": 1,\n  "b": 2\n}'));
      expect(JsonCodec().decodeFromBytes(jsonBytes2), equals({'a': 1, 'b': 2}));
      expect(await JsonCodec().decodeFromBytesAsync(Future.value(jsonBytes2)),
          equals({'a': 1, 'b': 2}));
    });

    test('entity TestUserWithReflection', () async {
      TestUserWithReflection$reflection.boot();

      var user1 =
          TestUserWithReflection.fields('joe', 'joe@mail.com', '123', id: 101);

      var user2 = TestUserWithReflection.fields('joe', 'joe@mail.com', '123',
          axis: TestEnumWithReflection.z, level: 999, enabled: false);

      var jsonCodec = JsonCodec();

      {
        var encodedJson = jsonCodec.encode(user1);

        expect(
            encodedJson,
            equals(
                '{"axis":"x","email":"joe@mail.com","enabled":true,"id":101,"isEnabled":true,"theLevel":null,"name":"joe"}'));

        var decodedUser1 = jsonCodec.decode<TestUserWithReflection>(
            '{"axis":"x","email":"joe@mail.com","enabled":true,"id":101,"isEnabled":true,"theLevel":null,"name":"joe","password":"123"}',
            type: TestUserWithReflection);

        expect(jsonCodec.encode(decodedUser1), equals(encodedJson));

        var encodedUser1b =
            '{"axis":"x","email":"joe2@mail.com","enabled":true,"id":101,"isEnabled":true,"theLevel":null,"name":"joe","passphrase":"123456"}';
        var decodedUser1b = jsonCodec.decode(encodedUser1b,
            type: TestUserWithReflection) as TestUserWithReflection;

        expect(decodedUser1b.email, equals('joe2@mail.com'));
        expect(decodedUser1b.password, equals('123456'));

        expect(jsonCodec.encode(decodedUser1b),
            equals(encodedUser1b.replaceFirst(',"passphrase":"123456"', '')));
      }

      {
        var encodedJson = jsonCodec.encode(user2);

        expect(
            encodedJson,
            equals(
                '{"axis":"z","email":"joe@mail.com","enabled":false,"id":null,"isEnabled":false,"theLevel":999,"name":"joe"}'));

        var decodedUser2 = jsonCodec.decode(
            encodedJson.replaceFirst('"}', '","password":"123"}'),
            type: TestUserWithReflection) as TestUserWithReflection;
        expect(jsonCodec.encode(decodedUser2), equals(encodedJson));
      }

      {
        var encodedJson = jsonCodec.encode([user1, user1]);

        print(encodedJson);

        expect(
            encodedJson,
            equals('['
                '{"axis":"x","email":"joe@mail.com","enabled":true,"id":101,"isEnabled":true,"theLevel":null,"name":"joe"},'
                '{"axis":"x","email":"joe@mail.com","enabled":true,"id":101,"isEnabled":true,"theLevel":null,"name":"joe"}'
                ']'));

        {
          var decoded = jsonCodec.decode(
              encodedJson.replaceAll('"}', '","password":"123"}'),
              type: TestUserWithReflection) as List;

          print(decoded);

          expect(decoded[0], isA<TestUserWithReflection>());
          expect(decoded[1], isA<TestUserWithReflection>());

          expect(identical(decoded[0], decoded[1]), isFalse);

          expect(jsonCodec.encode([user1, user1]), equals(encodedJson));
        }

        {
          var decoded = JsonCodec(forceDuplicatedEntitiesAsID: true).decode(
              encodedJson.replaceAll('"}', '","password":"123"}'),
              type: TestUserWithReflection) as List;

          print(decoded);

          expect(decoded[0], isA<TestUserWithReflection>());
          expect(decoded[1], isA<TestUserWithReflection>());

          expect(identical(decoded[0], decoded[1]), isTrue);

          expect(jsonCodec.encode([user1, user1]), equals(encodedJson));
        }
      }

      {
        var encodedJson =
            jsonCodec.encode([user1, user1], duplicatedEntitiesAsID: true);

        print(encodedJson);

        expect(
            encodedJson,
            equals('['
                '{"axis":"x","email":"joe@mail.com","enabled":true,"id":101,"isEnabled":true,"theLevel":null,"name":"joe"},'
                '101'
                ']'));

        var decoded = jsonCodec.decode(
            encodedJson.replaceAll('"}', '","password":"123"}'),
            type: TestUserWithReflection,
            duplicatedEntitiesAsID: true) as List;

        print(decoded);

        expect(decoded[0], isA<TestUserWithReflection>());
        expect(decoded[1], isA<TestUserWithReflection>());

        expect(identical(decoded[0], decoded[1]), isTrue);

        expect(jsonCodec.encode([user1, user1], duplicatedEntitiesAsID: true),
            equals(encodedJson));
      }
    });

    test('encode/decode 2', () {
      TestAddressWithReflection$reflection.boot();
      TestCompanyWithReflection$reflection.boot();

      {
        var address =
            TestAddressWithReflection.withCity('NY', city: 'New York', id: 11);

        var addressJson = address.toJson();
        expect(
            addressJson, equals({'id': 11, 'state': 'NY', 'city': 'New York'}));

        expect(
            JsonCodec.defaultCodec
                .fromJson(addressJson, type: TestAddressWithReflection),
            equals(address));

        var company = TestCompanyWithReflection('c1', address);

        var companyJson = company.toJson();
        expect(
            companyJson,
            equals({
              'branchesAddresses': [],
              'extraAddresses': [],
              'extraNames': [],
              'mainAddress': {'id': 11, 'state': 'NY', 'city': 'New York'},
              'name': 'c1'
            }));

        expect(
            JsonCodec.defaultCodec
                .fromJson(companyJson, type: TestCompanyWithReflection),
            equals(company));
      }

      {
        var company = TestCompanyWithReflection('c1', null);

        var companyJson = company.toJson();
        expect(
            companyJson,
            equals({
              'branchesAddresses': [],
              'extraAddresses': [],
              'extraNames': [],
              'mainAddress': null,
              'name': 'c1'
            }));

        expect(
            JsonCodec.defaultCodec
                .fromJson(companyJson, type: TestCompanyWithReflection),
            equals(company));
      }

      {
        var address =
            TestAddressWithReflection.withCity('NY', city: 'New York', id: 11);

        var company =
            TestCompanyWithReflection('c1', null, extraAddresses: [address]);

        var companyJson = company.toJson() as Map;

        companyJson.remove('branchesAddresses');

        expect(
            companyJson,
            equals({
              'extraAddresses': [
                {'id': 11, 'state': 'NY', 'city': 'New York'}
              ],
              'extraNames': [],
              'mainAddress': null,
              'name': 'c1'
            }));

        expect(
            JsonCodec.defaultCodec
                .fromJson(companyJson, type: TestCompanyWithReflection),
            equals(company));
      }

      {
        JsonDecoder.registerTypeDecoder(TestAddressWithReflection,
            (o, jsonDecoder, t) {
          if (o is Map<String, Object?>) {
            return TestAddressWithReflection$reflection.staticInstance
                .createInstanceFromMap(o);
          } else {
            return TestAddressWithReflection.withCity('?', city: '?');
          }
        });

        try {
          {
            var mainAddress = TestAddressWithReflection.withCity('NY',
                city: 'New York', id: 11);

            var company = TestCompanyWithReflection('c1', mainAddress);

            var companyJson = company.toJson();
            expect(
                companyJson,
                equals({
                  'branchesAddresses': [],
                  'extraAddresses': [],
                  'extraNames': [],
                  'mainAddress': {'id': 11, 'state': 'NY', 'city': 'New York'},
                  'name': 'c1'
                }));

            expect(
                JsonCodec.defaultCodec
                    .fromJson(companyJson, type: TestCompanyWithReflection),
                equals(company));
          }

          {
            var company = TestCompanyWithReflection('c1', null);

            var companyJson = company.toJson();
            expect(
                companyJson,
                equals({
                  'branchesAddresses': [],
                  'extraAddresses': [],
                  'extraNames': [],
                  'mainAddress': null,
                  'name': 'c1'
                }));

            expect(
                JsonCodec.defaultCodec
                    .fromJson(companyJson, type: TestCompanyWithReflection),
                equals(TestCompanyWithReflection(
                    'c1', TestAddressWithReflection.withCity('?', city: '?'))));
          }
        } finally {
          JsonDecoder.unregisterTypeDecoder(TestAddressWithReflection);
        }

        {
          var company = TestCompanyWithReflection('c1', null);

          var companyJson = company.toJson();
          expect(
              companyJson,
              equals({
                'branchesAddresses': [],
                'extraAddresses': [],
                'extraNames': [],
                'mainAddress': null,
                'name': 'c1'
              }));

          expect(
              JsonCodec.defaultCodec
                  .fromJson(companyJson, type: TestCompanyWithReflection),
              equals(TestCompanyWithReflection('c1', null)));
        }
      }
    });

    test('entity TestTransactionWithReflection', () async {
      TestUserWithReflection$reflection.boot();
      TestTransactionWithReflection$reflection.boot();

      var user1 =
          TestUserWithReflection.fields('joe', 'joe@mail.com', '123', id: 1001);
      var user2 = TestUserWithReflection.fields(
          'smith', 'smith@mail.com', '456',
          id: 1002);

      var jsonCodec = JsonCodec();

      var transaction1 = TestTransactionWithReflection.fromTo(10, user1, user2);

      {
        var encodedJson =
            jsonCodec.encode(transaction1, duplicatedEntitiesAsID: true);

        print(encodedJson);

        expect(
            encodedJson,
            equals('{"amount":10,'
                '"fromUser":{"axis":"x","email":"joe@mail.com","enabled":true,"id":1001,"isEnabled":true,"theLevel":null,"name":"joe"},'
                '"toUser":{"axis":"x","email":"smith@mail.com","enabled":true,"id":1002,"isEnabled":true,"theLevel":null,"name":"smith"}}'));

        {
          var decoded = jsonCodec.decode(
                  encodedJson.replaceAll('"}', '","password":"123"}'),
                  type: TestTransactionWithReflection)
              as TestTransactionWithReflection;

          print(decoded);

          expect(decoded.fromUser, isA<TestUserWithReflection>());
          expect(decoded.toUser, isA<TestUserWithReflection>());

          expect(decoded.fromUser.id, equals(1001));
          expect(decoded.toUser.id, equals(1002));

          expect(jsonCodec.encode(decoded), equals(encodedJson));
        }
      }

      var transaction2 = TestTransactionWithReflection.fromTo(20, user1, user1);

      {
        var encodedJson =
            jsonCodec.encode(transaction2, duplicatedEntitiesAsID: true);

        print(encodedJson);

        expect(
            encodedJson,
            equals('{"amount":20,'
                '"fromUser":{"axis":"x","email":"joe@mail.com","enabled":true,"id":1001,"isEnabled":true,"theLevel":null,"name":"joe"},'
                '"toUser":1001}'));

        {
          var decoded = jsonCodec.decode(
              encodedJson.replaceAll('"}', '","password":"123"}'),
              type: TestTransactionWithReflection,
              duplicatedEntitiesAsID: true) as TestTransactionWithReflection;

          print(decoded);

          expect(decoded.fromUser, isA<TestUserWithReflection>());
          expect(decoded.toUser, isA<TestUserWithReflection>());

          expect(decoded.fromUser.id, equals(1001));
          expect(decoded.toUser.id, equals(1001));

          expect(jsonCodec.encode(decoded, duplicatedEntitiesAsID: true),
              equals(encodedJson));
        }

        {
          var encodedJson = '{"amount":20,'
              '"fromUser":1001,'
              '"toUser":{"axis":"x","email":"joe@mail.com","enabled":true,"id":1001,"isEnabled":true,"theLevel":null,"name":"joe","password":"123"}'
              '}';

          var decoded = jsonCodec.decode(encodedJson,
              type: TestTransactionWithReflection,
              duplicatedEntitiesAsID: true) as TestTransactionWithReflection;

          print(decoded);

          expect(decoded.fromUser, isA<TestUserWithReflection>());
          expect(decoded.toUser, isA<TestUserWithReflection>());

          expect(decoded.fromUser.id, equals(1001));
          expect(decoded.toUser.id, equals(1001));
        }

        {
          var encodedJson = '{"amount":20,'
              '"toUser":1001,'
              '"fromUser":{"axis":"x","email":"joe@mail.com","enabled":true,"id":1001,"isEnabled":true,"theLevel":null,"name":"joe","password":"123"}'
              '}';

          var decoded = jsonCodec.decode(encodedJson,
              type: TestTransactionWithReflection,
              duplicatedEntitiesAsID: true) as TestTransactionWithReflection;

          print(decoded);

          expect(decoded.fromUser, isA<TestUserWithReflection>());
          expect(decoded.toUser, isA<TestUserWithReflection>());

          expect(decoded.fromUser.id, equals(1001));
          expect(decoded.toUser.id, equals(1001));
        }

        {
          var encodedJson = '{"amount":"x",'
              '"fromUser":1001,'
              '"toUser":{"axis":"x","email":"joe@mail.com","enabled":true,"id":1001,"isEnabled":true,"theLevel":null,"name":"joe","password":"123"}'
              '}';

          expect(
              () => jsonCodec.decode(encodedJson,
                  type: TestTransactionWithReflection,
                  duplicatedEntitiesAsID: true),
              throwsA(isA<UnresolvedParameterError>()));
        }

        {
          var encodedJson = '{"amount":20,'
              '"fromUser":404,'
              '"toUser":{"axis":"x","email":"joe@mail.com","enabled":true,"id":1001,"isEnabled":true,"theLevel":null,"name":"joe","password":"123"}'
              '}';

          expect(
              () => jsonCodec.decode(encodedJson,
                  type: TestTransactionWithReflection,
                  duplicatedEntitiesAsID: true),
              throwsA(isA<UnresolvedParameterError>().having((e) => e.message,
                  'message', contains('<unresolved_parameter>'))));
        }

        {
          var encodedJson = '{"amount":20,'
              '"fromUser":400,'
              '"toUser":404'
              '}';

          expect(
              () => jsonCodec.decode(encodedJson,
                  type: TestTransactionWithReflection,
                  duplicatedEntitiesAsID: true),
              throwsA(isA<UnresolvedParameterError>().having(
                  (e) => e.message,
                  'With unresolved_parameter',
                  contains('<unresolved_parameter>'))));
        }
      }
    });
  });

  group('JsonDecoder', () {
    test('jsomMapDecoderProvider', () {
      var jsonDecoderDefault = JsonDecoder();

      var jsonDecoder = JsonDecoder(jsomMapDecoderProvider: (t, m, j) {
        if (t == TestAddressWithReflection) {
          return (m, j) {
            return TestAddressWithReflection.withCity(m['state'] as String,
                city: (m['city'] as String).toUpperCase(),
                id: (m['id'] as int) * 10);
          };
        }
        return null;
      });

      var address1 =
          TestAddressWithReflection.withCity('NY', city: 'New York', id: 11);
      var company1 = TestCompanyWithReflection('c1', address1);

      var address2 =
          TestAddressWithReflection.withCity('NY', city: 'NEW YORK', id: 110);
      var company2 = TestCompanyWithReflection('c1', address2);

      expect(
          jsonDecoderDefault.fromJson(company1.toJson(),
              type: TestCompanyWithReflection),
          equals(company1));

      expect(
          jsonDecoder.fromJson(company1.toJson(),
              type: TestCompanyWithReflection),
          equals(company2));
    });
  });

  group('JsonEntityCacheSimple', () {
    test('basic', () {
      var mainAddress =
          TestAddressWithReflection.withCity('NY', city: 'New York', id: 11);
      var company = TestCompanyWithReflection('c1', mainAddress);

      var jsonEntityCache1 = JsonEntityCacheSimple();

      var encode1 = JsonCodec(entityCache: jsonEntityCache1).encode(
          [company, mainAddress],
          duplicatedEntitiesAsID: false, autoResetEntityCache: false);

      expect(
          encode1,
          equals('['
              '{"branchesAddresses":[],"extraAddresses":[],"extraNames":[],"mainAddress":{"id":11,"state":"NY","city":"New York"},"name":"c1"},'
              '{"id":11,"state":"NY","city":"New York"}'
              ']'));

      expect(jsonEntityCache1.cachedEntitiesLength, equals(0));

      var decoded1 =
          JsonCodec().decode(encode1, duplicatedEntitiesAsID: true) as List;

      var company1 = JsonCodec(entityCache: jsonEntityCache1)
          .fromJson<TestCompanyWithReflection>(decoded1[0],
              type: TestCompanyWithReflection, duplicatedEntitiesAsID: false);

      var mainAddress1 = JsonCodec(entityCache: jsonEntityCache1)
          .fromJson<TestAddressWithReflection>(decoded1[1],
              type: TestAddressWithReflection, duplicatedEntitiesAsID: false);

      expect(company1, equals(company));
      expect(mainAddress1, equals(mainAddress));

      var jsonEntityCache2 = JsonEntityCacheSimple();

      var encode2 = JsonCodec(entityCache: jsonEntityCache2).encode(
          [company, mainAddress],
          duplicatedEntitiesAsID: true, autoResetEntityCache: false);

      expect(
          encode2,
          equals('['
              '{"branchesAddresses":[],"extraAddresses":[],"extraNames":[],"mainAddress":{"id":11,"state":"NY","city":"New York"},"name":"c1"},'
              '11'
              ']'));

      expect(jsonEntityCache2.cachedEntitiesLength, equals(2));

      var decoded2 =
          JsonCodec().decode(encode2, duplicatedEntitiesAsID: true) as List;

      var company2 = JsonCodec(entityCache: jsonEntityCache2)
          .fromJson<TestCompanyWithReflection>(decoded2[0],
              type: TestCompanyWithReflection,
              duplicatedEntitiesAsID: true,
              autoResetEntityCache: false);

      var mainAddress2 = JsonCodec(entityCache: jsonEntityCache2)
          .fromJson<TestAddressWithReflection>(decoded2[1],
              type: TestAddressWithReflection,
              duplicatedEntitiesAsID: true,
              autoResetEntityCache: false);

      expect(company2, equals(company));
      expect(mainAddress2, equals(mainAddress));

      var jsonEntityCache3 = JsonEntityCacheSimple();

      expect(jsonEntityCache3.cachedEntitiesLength, equals(0));
      expect(jsonEntityCache3.toString(),
          matches(RegExp(r'JsonEntityCacheSimple#\d+\[0\]')));

      jsonEntityCache3.cacheEntities([mainAddress1]);

      expect(jsonEntityCache3.cachedEntitiesLength, equals(1));
      expect(
          jsonEntityCache3.toString(),
          matches(RegExp(
              r'JsonEntityCacheSimple#\d+\[1\]\{TestAddressWithReflection: 1\}')));

      var company3 = JsonCodec(entityCache: jsonEntityCache3)
          .fromJson<TestCompanyWithReflection>(decoded2[0],
              type: TestCompanyWithReflection,
              duplicatedEntitiesAsID: true,
              autoResetEntityCache: false);

      var mainAddress3 = JsonCodec(entityCache: jsonEntityCache3)
          .fromJson<TestAddressWithReflection>(decoded2[1],
              type: TestAddressWithReflection,
              duplicatedEntitiesAsID: true,
              autoResetEntityCache: false);

      expect(company3, equals(company));
      expect(mainAddress3, equals(mainAddress));

      expect(jsonEntityCache3.cachedEntitiesLength, equals(2));

      jsonEntityCache3.removeCachedEntity(mainAddress1?.id,
          type: TestAddressWithReflection);

      expect(jsonEntityCache3.cachedEntitiesLength, equals(1));

      var mainAddress4 = JsonCodec(entityCache: jsonEntityCache3)
          .fromJson<TestAddressWithReflection>(decoded2[1],
              type: TestAddressWithReflection,
              duplicatedEntitiesAsID: true,
              autoResetEntityCache: false);

      expect(mainAddress4, isNull);
    });

    test('cacheEntityInstantiator', () {
      var mainAddress =
          TestAddressWithReflection.withCity('NY', city: 'New York', id: 11);
      var company = TestCompanyWithReflection('c1', mainAddress);

      var jsonEntityCache1 = JsonEntityCacheSimple();

      var encode1 = JsonCodec(entityCache: jsonEntityCache1).encode(
          [company, mainAddress],
          duplicatedEntitiesAsID: false, autoResetEntityCache: false);

      expect(
          encode1,
          equals('['
              '{"branchesAddresses":[],"extraAddresses":[],"extraNames":[],"mainAddress":{"id":11,"state":"NY","city":"New York"},"name":"c1"},'
              '{"id":11,"state":"NY","city":"New York"}'
              ']'));

      var encode2 = JsonCodec(entityCache: jsonEntityCache1).encode(
          [company, mainAddress],
          duplicatedEntitiesAsID: true, autoResetEntityCache: false);

      expect(
          encode2,
          equals('['
              '{"branchesAddresses":[],"extraAddresses":[],"extraNames":[],"mainAddress":{"id":11,"state":"NY","city":"New York"},"name":"c1"},'
              '11'
              ']'));

      var jsonEntityCache2 = JsonEntityCacheSimple();

      expect(jsonEntityCache2.cachedEntitiesLength, equals(0));
      expect(jsonEntityCache2.cachedEntitiesInstantiatorsLength, equals(0));
      expect(jsonEntityCache2.totalCachedEntities, equals(0));

      var instantiated = false;

      jsonEntityCache2.cacheEntityInstantiator(11, () {
        instantiated = true;
        return TestAddressWithReflection$fromJsonEncoded(
            '{"id":11,"state":"NY","city":"New York"}');
      });

      expect(jsonEntityCache2.cachedEntitiesLength, equals(0));
      expect(jsonEntityCache2.cachedEntitiesInstantiatorsLength, equals(1));
      expect(jsonEntityCache2.totalCachedEntities, equals(1));
      expect(instantiated, isFalse);

      expect(jsonEntityCache2.cachedEntities.length, equals(0));

      expect(
          jsonEntityCache2.isCachedEntityByID(10,
              type: TestAddressWithReflection),
          isFalse);

      expect(
          jsonEntityCache2.isCachedEntityByID(11,
              type: TestAddressWithReflection),
          isTrue);

      expect(instantiated, isFalse);

      expect(
          jsonEntityCache2.getCachedEntityByID(10,
              type: TestAddressWithReflection),
          isNull);

      expect(instantiated, isFalse);

      expect(jsonEntityCache2.cachedEntitiesLength, equals(0));
      expect(jsonEntityCache2.cachedEntitiesInstantiatorsLength, equals(1));
      expect(jsonEntityCache2.totalCachedEntities, equals(1));

      expect(jsonEntityCache2.cachedEntities.length, equals(0));

      expect(
          jsonEntityCache2.getCachedEntityByID(11,
              type: TestAddressWithReflection),
          isNotNull);

      expect(instantiated, isTrue);

      expect(jsonEntityCache2.cachedEntitiesLength, equals(1));
      expect(jsonEntityCache2.cachedEntitiesInstantiatorsLength, equals(0));
      expect(jsonEntityCache2.totalCachedEntities, equals(1));

      expect(jsonEntityCache2.cachedEntities.length, equals(1));
      expect(jsonEntityCache2.allCachedEntities.length, equals(1));

      jsonEntityCache2.cacheEntityInstantiator(12, () {
        instantiated = true;
        return TestAddressWithReflection$fromJsonEncoded(
            '{"id":12,"state":"NY","city":"New York"}');
      });

      expect(
        jsonEntityCache2.getCachedEntityByID<TestAddressWithReflection>(11)?.id,
        equals(11),
      );

      expect(
        jsonEntityCache2
            .getCachedEntityByID<TestAddressWithReflection>(12,
                instantiate: false)
            ?.id,
        isNull,
      );

      expect(
        jsonEntityCache2.isCachedEntity(
          TestAddressWithReflection$fromJsonEncoded(
              '{"id":11,"state":"NY","city":"New York"}'),
          identicalEquality: false,
        ),
        isTrue,
      );

      expect(
        jsonEntityCache2.isCachedEntity(
          TestAddressWithReflection$fromJsonEncoded(
              '{"id":11,"state":"NY","city":"New York"}'),
          identicalEquality: false,
          idGetter: (o) => o.id,
        ),
        isTrue,
      );

      expect(jsonEntityCache2.cachedEntitiesLength, equals(1));
      expect(jsonEntityCache2.cachedEntitiesInstantiatorsLength, equals(1));
      expect(jsonEntityCache2.totalCachedEntities, equals(2));

      expect(jsonEntityCache2.cachedEntities.length, equals(1));
      expect(jsonEntityCache2.allCachedEntities.length, equals(2));

      expect(jsonEntityCache2.cachedEntitiesLength, equals(2));
      expect(jsonEntityCache2.cachedEntitiesInstantiatorsLength, equals(0));
      expect(jsonEntityCache2.totalCachedEntities, equals(2));

      expect(
        jsonEntityCache2
            .getCachedEntityByID<TestAddressWithReflection>(1000)
            ?.id,
        isNull,
      );

      expect(
        jsonEntityCache2.getCachedEntityByID<TestAddressWithReflection>(11)?.id,
        equals(11),
      );

      expect(
        jsonEntityCache2.getCachedEntityByID<TestAddressWithReflection>(12)?.id,
        equals(12),
      );

      expect(
        jsonEntityCache2.getCachedEntitiesByIDs<TestAddressWithReflection>(
            [11, 12])?.map((k, v) => MapEntry(k, (v as dynamic).id)),
        equals(
          {11: 11, 12: 12},
        ),
      );

      jsonEntityCache2.cacheEntityInstantiator(10, () {
        instantiated = true;
        return TestAddressWithReflection$fromJsonEncoded(
            '{"id":10,"state":"NY","city":"New York"}');
      });

      expect(jsonEntityCache2.cachedEntitiesLength, equals(2));
      expect(jsonEntityCache2.cachedEntitiesInstantiatorsLength, equals(1));
      expect(jsonEntityCache2.totalCachedEntities, equals(3));

      expect(
        jsonEntityCache2.getCachedEntityByID<TestAddressWithReflection>(10)?.id,
        equals(10),
      );

      expect(jsonEntityCache2.cachedEntitiesLength, equals(3));
      expect(jsonEntityCache2.cachedEntitiesInstantiatorsLength, equals(0));
      expect(jsonEntityCache2.totalCachedEntities, equals(3));

      jsonEntityCache2.cacheEntityInstantiator(9, () {
        return TestAddressWithReflection$fromJsonEncoded(
            '{"id":9,"state":"NY","city":"New York"}');
      });

      jsonEntityCache2.cacheEntityInstantiator(8, () {
        return TestAddressWithReflection$fromJsonEncoded(
            '{"id":8,"state":"NY","city":"New York"}');
      });

      expect(jsonEntityCache2.cachedEntitiesLength, equals(3));
      expect(jsonEntityCache2.cachedEntitiesInstantiatorsLength, equals(2));
      expect(jsonEntityCache2.totalCachedEntities, equals(5));

      expect(
        jsonEntityCache2.getCachedEntitiesByIDs<TestAddressWithReflection>(
            [11, 12, 9])?.map((k, v) => MapEntry(k, (v as dynamic).id)),
        equals(
          {11: 11, 12: 12, 9: 9},
        ),
      );

      expect(jsonEntityCache2.cachedEntitiesLength, equals(4));
      expect(jsonEntityCache2.cachedEntitiesInstantiatorsLength, equals(1));
      expect(jsonEntityCache2.totalCachedEntities, equals(5));

      expect(
        jsonEntityCache2
            .getCachedEntities<TestAddressWithReflection>(instantiate: false)
            ?.map(
                (k, v) => MapEntry(k, v is Function ? -1 : (v as dynamic).id)),
        equals(
          {8: -1, 9: 9, 10: 10, 11: 11, 12: 12},
        ),
      );

      expect(
        jsonEntityCache2.getCachedEntitiesByIDs<TestAddressWithReflection>(
            [11, 8, 9])?.map((k, v) => MapEntry(k, (v as dynamic).id)),
        equals(
          {11: 11, 8: 8, 9: 9},
        ),
      );

      expect(jsonEntityCache2.cachedEntitiesLength, equals(5));
      expect(jsonEntityCache2.cachedEntitiesInstantiatorsLength, equals(0));
      expect(jsonEntityCache2.totalCachedEntities, equals(5));

      expect(
        jsonEntityCache2
            .getCachedEntities<TestAddressWithReflection>()
            ?.map((k, v) => MapEntry(k, (v as dynamic).id)),
        equals(
          {8: 8, 9: 9, 10: 10, 11: 11, 12: 12},
        ),
      );

      jsonEntityCache2.cacheEntityInstantiator(7, () {
        return TestAddressWithReflection$fromJsonEncoded(
            '{"id":7,"state":"NY","city":"New York"}');
      });

      expect(
        jsonEntityCache2.isCachedEntity(
          TestAddressWithReflection$fromJsonEncoded(
              '{"id":7,"state":"NY","city":"New York"}'),
          identicalEquality: false,
          idGetter: (o) => o.id,
        ),
        isTrue,
      );

      jsonEntityCache2.cacheEntityInstantiator(6, () {
        return TestAddressWithReflection$fromJsonEncoded(
            '{"id":6,"state":"NY","city":"New York"}');
      });

      expect(
        jsonEntityCache2.isCachedEntity(
          TestAddressWithReflection$fromJsonEncoded(
              '{"id":6,"state":"NY","city":"New York"}'),
          identicalEquality: false,
        ),
        isTrue,
      );
    });
  });
}

class _MyBytesSink extends ByteConversionSink {
  var output = <List<int>>[];

  Uint8List get bytes => Uint8List.fromList(output.reduce((a, b) => a + b));

  @override
  void add(List<int> chunk) {
    output.add(chunk);
  }

  @override
  void close() {}
}
