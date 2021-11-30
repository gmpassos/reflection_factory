import 'package:reflection_factory/reflection_factory.dart';
import 'package:test/test.dart';

import 'src/user_simple.dart';
import 'src/user_with_reflection.dart';

void main() {
  group('TypeInfo', () {
    setUp(() {});

    test('basic', () async {
      {
        var typeInfo = TypeInfo.from(123);
        expect(typeInfo.isInt, isTrue);
        expect(typeInfo.isNumber, isTrue);
        expect(typeInfo.isDouble, isFalse);

        expect(typeInfo.isNum, isFalse);
        expect(typeInfo.isDynamic, isFalse);
        expect(typeInfo.isObject, isFalse);
      }

      {
        var typeInfo = TypeInfo.from(12.3);
        expect(typeInfo.isDouble, isTrue);
        expect(typeInfo.isInt, isFalse);
        expect(typeInfo.isNumber, isTrue);

        expect(typeInfo.isNum, isFalse);
        expect(typeInfo.isDynamic, isFalse);
        expect(typeInfo.isObject, isFalse);
      }

      {
        var typeInfo = TypeInfo.from(num);
        expect(typeInfo.isNum, isTrue);
        expect(typeInfo.isDouble, isFalse);
        expect(typeInfo.isInt, isFalse);
        expect(typeInfo.isNumber, isTrue);

        expect(typeInfo.isDynamic, isFalse);
        expect(typeInfo.isObject, isFalse);
      }

      {
        var typeInfo = TypeInfo.from(Object);
        expect(typeInfo.isNum, isFalse);
        expect(typeInfo.isDouble, isFalse);
        expect(typeInfo.isInt, isFalse);
        expect(typeInfo.isNumber, isFalse);
        expect(typeInfo.isDynamic, isFalse);

        expect(typeInfo.isObject, isTrue);
        expect(typeInfo.isDynamicOrObject, isTrue);
      }

      {
        var typeInfo = TypeInfo.from(dynamic);
        expect(typeInfo.isNum, isFalse);
        expect(typeInfo.isDouble, isFalse);
        expect(typeInfo.isInt, isFalse);
        expect(typeInfo.isNumber, isFalse);
        expect(typeInfo.isObject, isFalse);

        expect(typeInfo.isDynamic, isTrue);
        expect(typeInfo.isDynamicOrObject, isTrue);
      }

      {
        var typeInfo = TypeInfo(List, [TestUserWithReflection]);

        expect(typeInfo.isList, isTrue);
        expect(typeInfo.isListEntity, isTrue);

        expect(typeInfo.isDynamic, isFalse);
        expect(typeInfo.isObject, isFalse);

        expect(typeInfo.listEntityType,
            equals(TypeInfo.from(TestUserWithReflection)));
      }

      {
        expect(TypeInfo.from(bool).isPrimitiveType, isTrue);
        expect(TypeInfo.from(int).isPrimitiveType, isTrue);
        expect(TypeInfo.from(double).isPrimitiveType, isTrue);
        expect(TypeInfo.from(num).isPrimitiveType, isTrue);
        expect(TypeInfo.from(String).isPrimitiveType, isTrue);

        expect(TypeInfo.from(List).isPrimitiveType, isFalse);
        expect(TypeInfo.from(Map).isPrimitiveType, isFalse);
        expect(TypeInfo.from(Set).isPrimitiveType, isFalse);
        expect(TypeInfo.from(TestUserSimple).isPrimitiveType, isFalse);
      }

      {
        expect(TypeInfo.from(List).isCollection, isTrue);
        expect(TypeInfo.from(Map).isCollection, isTrue);
        expect(TypeInfo.from(Set).isCollection, isTrue);

        expect(TypeInfo.from(bool).isCollection, isFalse);
        expect(TypeInfo.from(int).isCollection, isFalse);
        expect(TypeInfo.from(double).isCollection, isFalse);
        expect(TypeInfo.from(num).isCollection, isFalse);
        expect(TypeInfo.from(String).isCollection, isFalse);

        expect(TypeInfo.from(TestUserSimple).isCollection, isFalse);
      }

      {
        expect(TypeInfo.from(int).isBasicType, isTrue);
        expect(TypeInfo.from(bool).isBasicType, isTrue);
        expect(TypeInfo.from(List).isBasicType, isTrue);
        expect(TypeInfo.from(Map).isBasicType, isTrue);

        expect(TypeInfo.from(TestUserSimple).isBasicType, isFalse);
      }

      {
        expect(TypeInfo.accepts<int>(int), isTrue);
        expect(TypeInfo.accepts<int>(double), isFalse);

        expect(TypeInfo.accepts<String>(String), isTrue);
        expect(TypeInfo.accepts<String>(int), isFalse);

        expect(TypeInfo.accepts<Object>(int), isTrue);
        expect(TypeInfo.accepts<Object>(double), isTrue);
        expect(TypeInfo.accepts<Object>(Object), isTrue);
        expect(TypeInfo.accepts<Object>(dynamic), isTrue);

        expect(TypeInfo.accepts<dynamic>(int), isTrue);
        expect(TypeInfo.accepts<dynamic>(double), isTrue);
        expect(TypeInfo.accepts<dynamic>(Object), isTrue);
        expect(TypeInfo.accepts<dynamic>(dynamic), isTrue);
      }

      {
        var t1 = TypeInfo(List);
        var t2 = TypeInfo(List);

        expect(t1.isList, isTrue);
        expect(t2.isList, isTrue);

        expect(t1.isIterable, isTrue);
        expect(t2.isIterable, isTrue);

        expect(t1.type, equals(t2.type));

        var t3 = TypeInfo.from([]);
        expect(t3.type, equals(t1.type));

        var company = TestCompanyWithReflection(
            'FooInc', TestAddressWithReflection('State1', 'City1'), [
          TestAddressWithReflection('State2', 'City2'),
          TestAddressWithReflection('State3', 'City3')
        ]);

        var fieldExtraAddressesTypeInfo =
            company.reflection.field('extraAddresses')!.type.typeInfo;

        expect(fieldExtraAddressesTypeInfo.type, equals(t1.type));

        var t4 = TypeInfo.from([TestAddressWithReflection.empty()],
            [TestAddressWithReflection.empty()]);
        expect(fieldExtraAddressesTypeInfo.type, equals(t4.type));
        expect(fieldExtraAddressesTypeInfo, equals(t4));
      }

      {
        var typeReflection =
            TypeReflection(Future, [TypeReflection(TestUserWithReflection)]);

        var typeInfo = typeReflection.typeInfo;

        expect(typeInfo.isFuture, isTrue);
        expect(typeInfo.equalsArgumentsTypes([TestUserWithReflection]), isTrue);
      }

      {
        var typeReflection =
            TypeReflection(FutureOr, [TypeReflection(TestUserWithReflection)]);

        var typeInfo = typeReflection.typeInfo;

        expect(typeInfo.isDynamic, isTrue);
        expect(typeInfo.equalsArgumentsTypes([TestUserWithReflection]), isTrue);
      }

      {
        var typeReflection =
            TypeReflection(Future, [TestOpAWithReflection(123)]);

        var typeInfo = typeReflection.typeInfo;

        expect(typeInfo.isFuture, isTrue);
        expect(typeInfo.equalsArgumentsTypes([TestOpAWithReflection]), isTrue);

        expect(typeInfo, equals(TypeInfo(Future, [TestOpAWithReflection])));
      }

      {
        var typeReflection =
            TypeReflection(Future, [TestOpWithReflection<int>('test', 123)]);

        var typeInfo = typeReflection.typeInfo;

        expect(typeInfo.isFuture, isTrue);
        expect(
            typeInfo
                .equalsArgumentsTypes([TestOpWithReflection<int>('test', 456)]),
            isTrue);

        expect(typeInfo,
            equals(TypeInfo(Future, [TestOpWithReflection<int>('test', 789)])));

        expect(typeInfo.asTypeReflection, equals(typeReflection));
      }

      {
        var typeReflection = TypeReflection(
            Future, [TestOpWithReflection$reflection().reflectedType]);

        var typeInfo = typeReflection.typeInfo;

        print(typeInfo);

        expect(typeInfo.isFuture, isTrue);
        expect(typeInfo.equalsArgumentsTypes([TestOpWithReflection]), isTrue);

        expect(typeInfo, equals(TypeInfo(Future, [TestOpWithReflection])));
      }

      {
        var typeInfo1 = TypeInfo(Future, [
          TypeInfo(TestOpWithReflection, [int])
        ]);
        var typeInfo2 = TypeInfo(Future, [
          TypeInfo(TestOpWithReflection, [dynamic])
        ]);
        var typeInfo3 = TypeInfo(Future, [
          TypeInfo(TestOpWithReflection, [Object])
        ]);
        var typeInfo4 = TypeInfo(Future, [TestOpWithReflection]);

        expect(typeInfo1 == typeInfo2, isFalse);
        expect(typeInfo1 == typeInfo3, isFalse);
        expect(typeInfo1 == typeInfo4, isFalse);

        expect(typeInfo2 == typeInfo3, isFalse);
        expect(typeInfo2 == typeInfo4, isFalse);

        expect(typeInfo3 == typeInfo4, isFalse);

        expect(typeInfo2.isEquivalent(typeInfo3), isTrue);
        expect(typeInfo2.isEquivalent(typeInfo4), isTrue);
        expect(typeInfo2.isEquivalent(typeInfo1), isFalse);

        expect(typeInfo3.isEquivalent(typeInfo2), isTrue);
        expect(typeInfo4.isEquivalent(typeInfo2), isTrue);
        expect(typeInfo1.isEquivalent(typeInfo2), isFalse);

        //expect(typeInfo.equalsArgumentsTypes([TestOpWithReflection]), isTrue);

      }
    });

    test('TypeInfo.parse', () async {
      {
        var t = TypeInfo(bool);
        expect(t.parse(true), isTrue);
        expect(t.parse(false), isFalse);
        expect(t.parse('1'), isTrue);
        expect(t.parse(' 0 '), isFalse);
      }

      {
        var t = TypeInfo(int);
        expect(t.parse('123'), equals(123));
        expect(t.parse(' 123 '), equals(123));
        expect(t.parse(123), equals(123));
      }

      {
        var t = TypeInfo(double);
        expect(t.parse('123'), equals(123.0));
        expect(t.parse(' 123.1 '), equals(123.1));
        expect(t.parse(123.2), equals(123.2));
      }

      {
        var t = TypeInfo(String);
        expect(t.parse('123'), equals('123'));
        expect(t.parse(' 123 '), equals(' 123 '));
        expect(t.parse(123), equals('123'));
      }

      {
        var t = TypeInfo(DateTime);
        var dateTime = DateTime.fromMillisecondsSinceEpoch(1577934245000);
        expect(t.parse('1577934245000'), equals(dateTime));
        expect(t.parse(' 1577934245000 '), equals(dateTime));
        expect(t.parse(1577934245000), equals(dateTime));
        expect(t.parse('2020-01-02 03:04:05.000Z'), equals(dateTime.toUtc()));
      }

      {
        var t = TypeInfo(BigInt);
        var n = BigInt.from(1577934245000);
        expect(t.parse('1577934245000'), equals(n));
        expect(t.parse(' 1577934245000 '), equals(n));
        expect(t.parse(1577934245000), equals(n));
      }

      {
        var t = TypeInfo(List);
        var l = ['a', 'b', 'c'];
        expect(t.parse('a,b,c'), equals(l));
        expect(t.parse('a;b;c'), equals(l));
        expect(t.parse(['a', 'b', 'c']), equals(l));
      }

      {
        var t = TypeInfo(Set);
        var l = {'a', 'b', 'c'};
        expect(t.parse('a,b,c'), equals(l));
        expect(t.parse('a;b;c'), equals(l));
        expect(t.parse({'a', 'b', 'c'}), equals(l));
      }

      {
        var t = TypeInfo(Map);
        var m = {'a': '1', 'b': '2', 'c': '3'};
        expect(t.parse('a:1;b:2;c:3'), equals(m));
        expect(t.parse({'a': '1', 'b': '2', 'c': '3'}), equals(m));
      }

      {
        var t = TypeInfo(MapEntry);
        var m = t.parse<MapEntry>('a:1')!;
        expect(m.key, equals('a'));
        expect(m.value, equals('1'));
      }
    });
  });

  group('TypeParser', () {
    test('TypeParser.isPrimitiveType/isPrimitiveValue', () async {
      expect(TypeParser.isPrimitiveType(bool), isTrue);
      expect(TypeParser.isPrimitiveType(int), isTrue);
      expect(TypeParser.isPrimitiveType(double), isTrue);
      expect(TypeParser.isPrimitiveType(num), isTrue);
      expect(TypeParser.isPrimitiveType(String), isTrue);
      expect(TypeParser.isPrimitiveType(TestUserWithReflection), isFalse);

      expect(TypeParser.isPrimitiveValue(123), isTrue);
      expect(TypeParser.isPrimitiveValue(TestUserWithReflection()), isFalse);
    });

    test('TypeParser.isAnyType', () async {
      expect(TypeParser.isAnyType(bool), isFalse);
      expect(TypeParser.isAnyType(int), isFalse);
      expect(TypeParser.isAnyType(double), isFalse);
      expect(TypeParser.isAnyType(num), isFalse);
      expect(TypeParser.isAnyType(String), isFalse);
      expect(TypeParser.isAnyType(TestUserWithReflection), isFalse);

      expect(TypeParser.isAnyType(Object), isTrue);
      expect(TypeParser.isAnyType(dynamic), isTrue);
    });

    test('TypeParser.isCollectionType/isCollectionValue', () async {
      expect(TypeParser.isCollectionType(bool), isFalse);
      expect(TypeParser.isCollectionType(int), isFalse);
      expect(TypeParser.isCollectionType(double), isFalse);
      expect(TypeParser.isCollectionType(num), isFalse);
      expect(TypeParser.isCollectionType(String), isFalse);
      expect(TypeParser.isCollectionType(TestUserWithReflection), isFalse);
      expect(TypeParser.isCollectionType(Object), isFalse);
      expect(TypeParser.isCollectionType(dynamic), isFalse);

      expect(TypeParser.isCollectionType(List), isTrue);
      expect(TypeParser.isCollectionType(Set), isTrue);
      expect(TypeParser.isCollectionType(Map), isTrue);

      expect(TypeParser.isCollectionValue(true), isFalse);
      expect(TypeParser.isCollectionValue(123), isFalse);
      expect(TypeParser.isCollectionValue(12.3), isFalse);
      expect(TypeParser.isCollectionValue('x'), isFalse);

      expect(TypeParser.isCollectionValue([1, 2]), isTrue);
      expect(TypeParser.isCollectionValue({'a': 1}), isTrue);
      expect(TypeParser.isCollectionValue({1, 2}), isTrue);
    });

    test('TypeParser.parseInt', () async {
      expect(TypeParser.parseInt(10), equals(10));
      expect(TypeParser.parseInt('11'), equals(11));
      expect(TypeParser.parseInt(' 12 '), equals(12));
      expect(TypeParser.parseInt(' -12 '), equals(-12));
      expect(TypeParser.parseInt(13.1), equals(13));
      expect(TypeParser.parseInt(" '123' "), equals(123));
      expect(TypeParser.parseInt(" '-123' "), equals(-123));
      expect(TypeParser.parseInt(' -1.2345e3 '), equals(-1234));
      expect(TypeParser.parseInt(' 123,456.78 '), equals(123456));
      expect(TypeParser.parseInt(' -123,456.78 '), equals(-123456));
      expect(TypeParser.parseInt(' "123,456.78 " '), equals(123456));
      expect(TypeParser.parseInt(' "-123,456.78 " '), equals(-123456));
      expect(TypeParser.parseInt(DateTime.utc(2020, 1, 2, 3, 4, 5, 0, 0)),
          equals(1577934245000));
      expect(TypeParser.parseInt(null, 404), equals(404));
      expect(TypeParser.parseInt('', 404), equals(404));
      expect(TypeParser.parseInt(' x ', 404), equals(404));
      expect(TypeParser.parseInt(null), isNull);

      expect(TypeParser.parseInt(BigInt.two), equals(2));
    });

    test('TypeParser.parseDouble', () async {
      expect(TypeParser.parseDouble(10), equals(10));
      expect(TypeParser.parseDouble(10.11), equals(10.11));
      expect(TypeParser.parseDouble('11'), equals(11.0));
      expect(TypeParser.parseDouble(' 12 '), equals(12.0));
      expect(TypeParser.parseDouble(' -12 '), equals(-12.0));
      expect(TypeParser.parseDouble(13.1), equals(13.1));
      expect(TypeParser.parseDouble(" '123' "), equals(123.0));
      expect(TypeParser.parseDouble(" '-123' "), equals(-123.0));
      expect(TypeParser.parseDouble(" '123.4' "), equals(123.4));
      expect(TypeParser.parseDouble(" '-123.4' "), equals(-123.4));
      expect(TypeParser.parseDouble('    -1.2345e3 '), equals(-1234.5));
      expect(TypeParser.parseDouble('   " 1.2345e3 "'), equals(1234.5));
      expect(TypeParser.parseDouble('   " -1.2345e3 "'), equals(-1234.5));
      expect(TypeParser.parseDouble(' 123,456.78 '), equals(123456.78));
      expect(TypeParser.parseDouble(' -123,456.78 '), equals(-123456.78));
      expect(TypeParser.parseDouble(' "123,456.78 " '), equals(123456.78));
      expect(TypeParser.parseDouble(' "-123,456.78 " '), equals(-123456.78));
      expect(TypeParser.parseDouble(DateTime.utc(2020, 1, 2, 3, 4, 5, 0, 0)),
          equals(1577934245000));
      expect(TypeParser.parseDouble(null, 404), equals(404));
      expect(TypeParser.parseDouble('', 404), equals(404));
      expect(TypeParser.parseDouble(' x ', 404), equals(404));
      expect(TypeParser.parseDouble(null), isNull);
    });

    test('TypeParser.parseNum', () async {
      expect(TypeParser.parseNum(10), equals(10));
      expect(TypeParser.parseNum(10.11), equals(10.11));
      expect(TypeParser.parseNum('11'), equals(11.0));
      expect(TypeParser.parseNum(' 12 '), equals(12));
      expect(TypeParser.parseNum(' -12 '), equals(-12));
      expect(TypeParser.parseNum(13.1), equals(13.1));
      expect(TypeParser.parseNum(" '123' "), equals(123));
      expect(TypeParser.parseNum(" '-123' "), equals(-123));
      expect(TypeParser.parseNum(" '123.4' "), equals(123.4));
      expect(TypeParser.parseNum(" '-123.4' "), equals(-123.4));
      expect(TypeParser.parseNum('    -1.2345e3 '), equals(-1234.5));
      expect(TypeParser.parseNum('   " 1.2345e3 "'), equals(1234.5));
      expect(TypeParser.parseNum('   " -1.2345e3 "'), equals(-1234.5));
      expect(TypeParser.parseNum(' 123,456.78 '), equals(123456.78));
      expect(TypeParser.parseNum(' -123,456.78 '), equals(-123456.78));
      expect(TypeParser.parseNum(' "123,456.78 " '), equals(123456.78));
      expect(TypeParser.parseNum(' "-123,456.78 " '), equals(-123456.78));
      expect(TypeParser.parseNum(DateTime.utc(2020, 1, 2, 3, 4, 5, 0, 0)),
          equals(1577934245000));
      expect(TypeParser.parseNum(null, 404), equals(404));
      expect(TypeParser.parseNum('', 404), equals(404));
      expect(TypeParser.parseNum(' x ', 404), equals(404));
      expect(TypeParser.parseNum(null), isNull);
    });

    test('TypeParser.parseBool', () async {
      expect(TypeParser.parseBool(true), isTrue);
      expect(TypeParser.parseBool(false), isFalse);

      expect(TypeParser.parseBool(1), isTrue);
      expect(TypeParser.parseBool(0), isFalse);
      expect(TypeParser.parseBool(-1), isFalse);

      expect(TypeParser.parseBool(' x ', true), isTrue);
      expect(TypeParser.parseBool(' x ', false), isFalse);

      expect(TypeParser.parseBool('null', true), isTrue);
      expect(TypeParser.parseBool('null', false), isFalse);

      expect(TypeParser.parseBool('1'), isTrue);
      expect(TypeParser.parseBool('0'), isFalse);
      expect(TypeParser.parseBool('-1'), isFalse);

      expect(TypeParser.parseBool('true'), isTrue);
      expect(TypeParser.parseBool('t'), isTrue);
      expect(TypeParser.parseBool('yes'), isTrue);
      expect(TypeParser.parseBool('ok'), isTrue);

      expect(TypeParser.parseBool('false'), isFalse);
      expect(TypeParser.parseBool('f'), isFalse);
      expect(TypeParser.parseBool('no'), isFalse);
      expect(TypeParser.parseBool('fail'), isFalse);
      expect(TypeParser.parseBool('error'), isFalse);
    });

    test('TypeParser.parseMap', () async {
      expect(TypeParser.parseMap({'a': 1, 'b': 2}), equals({'a': 1, 'b': 2}));
      expect(TypeParser.parseMap('a:1&b:2'), equals({'a': '1', 'b': '2'}));

      expect(TypeParser.parseMap<String, int>({'a': '1', 'b': '2'}),
          equals({'a': 1, 'b': 2}));
      expect(TypeParser.parseMap<String, int>('a:1&b:2'),
          equals({'a': 1, 'b': 2}));

      expect(TypeParser.parseMap(['a:1', 'b:2']), equals({'a': '1', 'b': '2'}));
    });

    test('TypeParser.parseMapEntry', () async {
      expect(TypeParser.parseMapEntry(MapEntry('a', 1)).toString(),
          equals('MapEntry(a: 1)'));

      expect(
          TypeParser.parseMapEntry('a:1').toString(), equals('MapEntry(a: 1)'));
      expect(
          TypeParser.parseMapEntry('a=1').toString(), equals('MapEntry(a: 1)'));

      expect(TypeParser.parseMapEntry(['x', 12]).toString(),
          equals('MapEntry(x: 12)'));

      expect(TypeParser.parseMapEntry('y').toString(),
          equals('MapEntry(y: null)'));

      {
        var me = TypeParser.parseMapEntry<String, int>(MapEntry('A', '123'))!;
        expect(me.key, equals('A'));
        expect(me.value, equals(123));
      }

      {
        var me = TypeParser.parseMapEntry<String, double>(['X', 123])!;
        expect(me.key, equals('X'));
        expect(me.value, equals(123.0));
      }
    });

    test('TypeParser.parserFor', () async {
      expect(TypeParser.parserFor<int>()!('123'), isA<int>());
      expect(TypeParser.parserFor<double>()!('123,4'), isA<double>());
      expect(TypeParser.parserFor<num>()!('123,4'), isA<num>());
      expect(TypeParser.parserFor<bool>()!('true'), isA<bool>());
      expect(TypeParser.parserFor<String>()!('x'), isA<String>());
      expect(TypeParser.parserFor<Map>()!('a:1'), isA<Map>());
      expect(TypeParser.parserFor<Set>()!('1,2'), isA<Set>());
      expect(TypeParser.parserFor<List>()!('1,2'), isA<List>());
      expect(TypeParser.parserFor<Iterable>()!('1,2'), isA<List>());

      expect(TypeParser.parserFor(type: int)!('123'), isA<int>());
      expect(TypeParser.parserFor(type: double)!('123,4'), isA<double>());
      expect(TypeParser.parserFor(type: num)!('123,4'), isA<num>());
      expect(TypeParser.parserFor(type: bool)!('t'), isA<bool>());
      expect(TypeParser.parserFor(type: String)!('x'), isA<String>());
      expect(TypeParser.parserFor(type: Map)!('a:1'), isA<Map>());
      expect(TypeParser.parserFor(type: Set)!('1,2'), isA<Set>());
      expect(TypeParser.parserFor(type: List)!('1,2'), isA<List>());
      expect(TypeParser.parserFor(type: Iterable)!('1,2'), isA<Iterable>());

      expect(TypeParser.parserFor(obj: 123)!('123'), isA<int>());
      expect(TypeParser.parserFor(obj: 123.4)!('123,4'), isA<double>());
      expect(TypeParser.parserFor(obj: 123)!('123,4'), isA<num>());
      expect(TypeParser.parserFor(obj: true)!('123,4'), isA<bool>());
      expect(TypeParser.parserFor(obj: 'x')!('x'), isA<String>());

      expect(
          TypeParser.parserFor(obj: BigInt.from(101))!('101'), isA<BigInt>());
      expect(
          TypeParser.parserFor(obj: DateTime(2020, 1, 2, 3, 4, 5, 0, 0))!(
              '2020-01-02 03:04:05.000Z'),
          isA<DateTime>());

      expect(TypeParser.parserFor(obj: {'a': 1})!('a:1'), isA<Map>());
      expect(TypeParser.parserFor(obj: {1, 2})!('1,2'), isA<Set>());
      expect(TypeParser.parserFor(obj: [1, 2])!('1,2'), isA<List>());
      expect(TypeParser.parserFor(obj: [1, 2].map((e) => e))!('1,2'),
          isA<Iterable>());
    });

    test('TypeParser.parserFor', () async {
      expect(TypeParser.parseValueForType(double, '12.3'), equals(12.3));

      expect(TypeParser.parseValueForType(BigInt, '123'),
          equals(BigInt.from(123)));

      expect(TypeParser.parseValueForType(DateTime, '2020-01-02 03:04:05.000Z'),
          equals(DateTime.parse('2020-01-02 03:04:05.000Z')));
    });

    test('TypeParser.parseList', () async {
      expect(TypeParser.parseList([1, 2, 3]), equals([1, 2, 3]));
      expect(TypeParser.parseList('1,2,3'), equals(['1', '2', '3']));
      expect(TypeParser.parseList('1,2,3', elementParser: TypeParser.parseInt),
          equals([1, 2, 3]));
      expect(TypeParser.parseList<int>('1,2,3'), equals([1, 2, 3]));
    });

    test('TypeParser.parseSet', () async {
      expect(TypeParser.parseSet([1, 2, 3]), equals({1, 2, 3}));
      expect(TypeParser.parseSet('1,2,3'), equals({'1', '2', '3'}));
      expect(TypeParser.parseSet('1,2,3', elementParser: TypeParser.parseInt),
          equals({1, 2, 3}));
      expect(TypeParser.parseSet<int>('1,2,3'), equals({1, 2, 3}));
    });

    test('TypeParser.parseMap', () async {
      expect(TypeParser.parseMap({'a': 1, 'b': 2}), equals({'a': 1, 'b': 2}));
      expect(TypeParser.parseMap('a:1&b:2'), equals({'a': '1', 'b': '2'}));
      expect(
          TypeParser.parseMap('a:1&b:2',
              keyParser: TypeParser.parseString,
              valueParser: TypeParser.parseInt),
          equals({'a': 1, 'b': 2}));
      expect(TypeParser.parseMap<String, int>('a:1&b:2'),
          equals({'a': 1, 'b': 2}));
    });

    test('TypeParser.parseDateTime', () async {
      expect(TypeParser.parseDateTime(DateTime.utc(2020, 1, 2, 3, 4, 5, 0, 0)),
          equals(DateTime.utc(2020, 1, 2, 3, 4, 5, 0, 0)));

      expect(TypeParser.parseDateTime('2020-01-02 03:04:05.000Z'),
          equals(DateTime.utc(2020, 1, 2, 3, 4, 5, 0, 0)));

      expect(TypeParser.parseDateTime(1577934245000),
          equals(DateTime.fromMillisecondsSinceEpoch(1577934245000)));
    });

    test('TypeParser.parseBigInt', () async {
      expect(TypeParser.parseBigInt(1577934245000),
          equals(BigInt.from(1577934245000)));

      expect(TypeParser.parseBigInt('1577934245000'),
          equals(BigInt.from(1577934245000)));

      expect(TypeParser.parseBigInt(' 1577934245000 '),
          equals(BigInt.from(1577934245000)));

      expect(TypeParser.parseBigInt(' -1577934245000 '),
          equals(BigInt.from(-1577934245000)));

      expect(TypeParser.parseBigInt('1,577,934,245,000'),
          equals(BigInt.from(1577934245000)));

      expect(TypeParser.parseBigInt('-1,577,934,245,000'),
          equals(BigInt.from(-1577934245000)));

      expect(TypeParser.parseBigInt(DateTime.utc(2020, 10, 2, 3, 4, 5, 0, 0)),
          equals(BigInt.from(1601607845000)));
    });
  });
}
