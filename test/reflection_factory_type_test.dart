import 'dart:convert';
import 'dart:typed_data';

import 'package:reflection_factory/reflection_factory.dart';
import 'package:test/test.dart';

import 'src/user_simple.dart';
import 'src/user_with_reflection.dart';

void main() {
  group('TypeExtension', () {
    test('basic', () async {
      {
        var t = int;
        expect(t.isPrimitiveType, isTrue);
      }

      {
        var t = double;
        expect(t.isPrimitiveType, isTrue);
      }

      {
        var t = num;
        expect(t.isPrimitiveType, isTrue);
      }

      {
        var t = BigInt;
        expect(t.isPrimitiveType, isFalse);
      }

      {
        var t = bool;
        expect(t.isPrimitiveType, isTrue);
      }

      {
        var t = String;
        expect(t.isPrimitiveType, isTrue);
      }
    });
  });

  group('GenericObjectExtension', () {
    test('basic', () async {
      {
        var v = 123;
        expect(v.isPrimitiveValue, isTrue);
        expect(v.isPrimitiveList, isFalse);
        expect(v.isPrimitiveMap, isFalse);
      }
      {
        var v = 12.3;
        expect(v.isPrimitiveValue, isTrue);
        expect(v.isPrimitiveList, isFalse);
        expect(v.isPrimitiveMap, isFalse);
      }
      {
        var v = 'abc';
        expect(v.isPrimitiveValue, isTrue);
        expect(v.isPrimitiveList, isFalse);
        expect(v.isPrimitiveMap, isFalse);
      }
      {
        var v = [123];
        expect(v.isPrimitiveValue, isFalse);
        expect(v.isPrimitiveList, isTrue);
        expect(v.isPrimitiveMap, isFalse);
      }
      {
        var v = [
          [123],
          [456]
        ];
        expect(v.isPrimitiveValue, isFalse);
        expect(v.isPrimitiveList, isFalse);
        expect(v.isPrimitiveMap, isFalse);
      }
      {
        var v = {'a': 123};
        expect(v.isPrimitiveValue, isFalse);
        expect(v.isPrimitiveList, isFalse);
        expect(v.isPrimitiveMap, isTrue);
      }
      {
        var v = {
          'a': [123]
        };
        expect(v.isPrimitiveValue, isFalse);
        expect(v.isPrimitiveList, isFalse);
        expect(v.isPrimitiveMap, isFalse);
      }
    });
  });

  group('TypeInfo', () {
    test('basic', () async {
      var t1 = TypeInfo(List);
      var t2 = TypeInfo<List>(List);

      expect(t1.type, equals(t2.type));

      expect(t1.genericType, equals(dynamic));
      expect(t2.genericType, equals(List));

      var t3 = TypeInfo.from([]);
      expect(t3.type, equals(t1.type));
      expect(t3.isList, isTrue);
      expect(t3.isSet, isFalse);
      expect(t3.isIterable, isTrue);
      expect(t3.isFuture, isFalse);
      expect(t3.isFutureOr, isFalse);
      expect(t3.isDynamic, isFalse);
      expect(t3.equalsType(TypeInfo.from([])), isTrue);
      expect(t3.equalsType(TypeInfo.from(<int>[])), isTrue);
      expect(t3.equalsType(TypeInfo.from(123)), isFalse);
      expect(t3.equalsTypeAndArguments(TypeInfo.from([])), isTrue);
      expect(t3.equalsTypeAndArguments(TypeInfo.from(<bool>[])), isTrue);
      expect(t3.equalsTypeAndArguments(TypeInfo.from({})), isFalse);
      expect(t3.equalsTypeAndArguments(TypeInfo.from(<bool>{})), isFalse);
      expect(t3.equalsTypeAndArguments(TypeInfo.from(123)), isFalse);

      var t4 = TypeInfo.from(<bool>{});
      expect(t4.isSet, isTrue);
      expect(t4.isList, isFalse);
      expect(t4.isIterable, isTrue);
      expect(t4.isFuture, isFalse);
      expect(t4.isFutureOr, isFalse);
      expect(t4.isDynamic, isFalse);
      expect(t4.equalsType(TypeInfo.from([])), isFalse);
      expect(t4.equalsType(TypeInfo.from(<int>[])), isFalse);
      expect(t4.equalsType(TypeInfo.from(123)), isFalse);
      expect(t4.equalsTypeAndArguments(TypeInfo.from(<bool>[])), isFalse);
      expect(t4.equalsTypeAndArguments(TypeInfo.from(<int>[])), isFalse);
      expect(t4.equalsTypeAndArguments(TypeInfo.from(<bool>{})), isTrue);
      expect(t4.equalsTypeAndArguments(TypeInfo.from(<int>{})), isTrue);
      expect(t4.equalsTypeAndArguments(TypeInfo.from(123)), isFalse);

      {
        var t = TypeInfo<List<int>>.fromListType(int);

        expect(t.type, equals(List));
        expect(t.genericType, equals(List<int>));
        expect(t.argumentsLength, equals(1));
        expect(t.argumentType(0), equals(TypeInfo.tInt));
      }

      {
        var t = TypeInfo<Map<String, int>>.fromMapType(String, int);

        expect(t.type, equals(Map));
        expect(t.genericType, equals(Map<String, int>));
        expect(t.argumentsLength, equals(2));
        expect(t.argumentType(0), equals(TypeInfo.tString));
        expect(t.argumentType(1), equals(TypeInfo.tInt));
      }

      {
        var t = TypeInfo<int>.fromType(int);
        var parser = t.parser!;

        expect(parser('123'), equals(123));

        expect(parser('x'), isNull);

        var tList = t.toListType();

        expect(tList, equals(TypeInfo<List<int>>.fromListType(int)));
        expect(tList.type, equals(List));
        expect(tList.argumentType(0), equals(TypeInfo.tInt));
        expect(tList.genericType, equals(List<int>));

        expect(tList.castList(<Object>[1, 2, 3]),
            allOf(equals([1, 2, 3]), isA<List<int>>()));

        var tSet = t.toSetType();

        expect(tSet, equals(TypeInfo<Set<int>>.fromSetType(int)));
        expect(tSet.type, equals(Set));
        expect(tSet.argumentType(0), equals(TypeInfo.tInt));
        expect(tSet.genericType, equals(Set<int>));

        expect(tSet.castSet(<Object>{1, 2, 3}),
            allOf(equals({1, 2, 3}), isA<Set<int>>()));

        var tItr = t.toIterableType();

        expect(
            tItr.castIterable(<Object>[1, 2, 3].map((e) {
              dynamic d = (e as int) * 10;
              return d;
            })),
            allOf(equals([10, 20, 30]), isA<Iterable<int>>()));

        expect(tItr, equals(TypeInfo<Iterable<int>>.fromIterableType(int)));
        expect(tItr.type, equals(Iterable));
        expect(tItr.argumentType(0), equals(TypeInfo.tInt));
        expect(tItr.genericType, equals(Iterable<int>));

        var tMapV = t.toMapValueType<String>();

        expect(
            tMapV,
            equals(TypeInfo<Map<String, int>>.fromType(
                Map, [TypeInfo.tString, TypeInfo.tInt])));

        expect(tMapV.type, equals(Map));
        expect(tMapV.argumentType(0), equals(TypeInfo.tString));
        expect(tMapV.argumentType(1), equals(TypeInfo.tInt));
        expect(tMapV.genericType, equals(Map<String, int>));

        expect(
            tMapV.castMap(<Object, Object>{'a': 1, 'b': 2}),
            allOf(equals(<String, int>{'a': 1, 'b': 2}),
                isA<Map<String, int>>()));

        var tMapK = t.toMapKeyType<String>();

        expect(
            tMapK,
            equals(TypeInfo<Map<int, String>>.fromType(
                Map, [TypeInfo.tInt, TypeInfo.tString])));

        expect(tMapK.type, equals(Map));
        expect(tMapK.argumentType(0), equals(TypeInfo.tInt));
        expect(tMapK.argumentType(1), equals(TypeInfo.tString));
        expect(tMapK.genericType, equals(Map<int, String>));

        expect(
            tMapK.castMap(<Object, Object>{1: 'a', 2: 'b'}),
            allOf(equals(<int, String>{1: 'a', 2: 'b'}),
                isA<Map<int, String>>()));
      }

      {
        var t = TypeInfo<bool>.fromType(bool);
        var parser = t.parser!;

        expect(parser('true'), isTrue);
        expect(parser('ok'), isTrue);
        expect(parser('t'), isTrue);
        expect(parser('1'), isTrue);
        expect(parser('y'), isTrue);

        expect(parser('false'), isFalse);
        expect(parser('no'), isFalse);
        expect(parser('error'), isFalse);
        expect(parser('fail'), isFalse);
        expect(parser('f'), isFalse);
        expect(parser('0'), isFalse);
        expect(parser('n'), isFalse);
      }

      {
        var t = TypeInfo.fromType(List, [String]);
        expect(t.equalsType(TypeInfo.fromType(List, [String])), isTrue);
        expect(t.equalsType(TypeInfo.fromType(List, [int])), isTrue);
        expect(t.equalsType(TypeInfo.fromType(List, [String])), isTrue);
        expect(t.equalsType(TypeInfo.fromType(List)), isTrue);
        expect(t.equalsType(TypeInfo.fromType(Set)), isFalse);
        expect(t.equalsType(TypeInfo.fromType(Set, [String])), isFalse);

        expect(t.equalsTypeAndArguments(TypeInfo.fromType(List, [String])),
            isTrue);
        expect(
            t.equalsTypeAndArguments(TypeInfo.fromType(List, [int])), isFalse);
        expect(t.equalsTypeAndArguments(TypeInfo.fromType(List, [String])),
            isTrue);
        expect(t.equalsTypeAndArguments(TypeInfo.fromType(List)), isFalse);
        expect(t.equalsTypeAndArguments(TypeInfo.fromType(Set, [String])),
            isFalse);
        expect(
            t.equalsTypeAndArguments(TypeInfo.fromType(Set, [int])), isFalse);
        expect(t.equalsTypeAndArguments(TypeInfo.fromType(Set)), isFalse);
      }

      {
        var t = TypeInfo.fromType(List);
        expect(t.equalsType(TypeInfo.fromType(List)), isTrue);
        expect(t.equalsType(TypeInfo.fromType(List, [String])), isTrue);

        expect(t.equalsTypeAndArguments(TypeInfo.fromType(List)), isTrue);
        expect(t.equalsTypeAndArguments(TypeInfo.fromType(List, [String])),
            isFalse);
      }

      var t5 = TypeInfo.fromType(Future, [bool]);
      expect(t5.isFuture, isTrue);
      expect(t5.isFutureOr, isFalse);
      expect(t5.isDynamic, isFalse);
      expect(t5.arguments[0], equals(TypeInfo.tBool));

      var t6 = TypeInfo.fromType(FutureOr, [bool]);
      expect(t6.typeName, equals('FutureOr'));
      expect(t6.isFutureOr, isTrue);
      expect(t6.isFuture, isFalse);
      expect(t6.arguments[0], equals(TypeInfo.tBool));
      expect(t6.equivalentArgumentsTypes([bool]), isTrue);
      expect(t6.equivalentArgumentsTypes([int]), isFalse);

      var t7 = TypeInfo.fromType(Future, [bool]);
      expect(t7.typeName, equals('Future'));
      expect(t7.isFuture, isTrue);
      expect(t7.isFutureOr, isFalse);
      expect(t7.isVoid, isFalse);
      expect(t7.arguments[0], equals(TypeInfo.tBool));
      expect(t7.equivalentArgumentsTypes([bool]), isTrue);
      expect(t7.equivalentArgumentsTypes([int]), isFalse);

      var t8 = TypeInfo.fromType(Future);
      expect(t8.isFuture, isTrue);
      expect(t8.isFutureOr, isFalse);
      expect(t8.isVoid, isFalse);
      expect(t8.hasArguments, isFalse);
      expect(t8.equivalentArgumentsTypes([]), isTrue);
      expect(t8.equivalentArgumentsTypes([int]), isFalse);

      expect(TypeInfo.tVoid.isVoid, isTrue);

      var t9 = TypeInfo.fromType(DateTime);
      expect(t9.isDateTime, isTrue);
      expect(t9.hasArguments, isFalse);
      expect(t9.equivalentArgumentsTypes([]), isTrue);
      expect(t9.equivalentArgumentsTypes([int]), isFalse);

      var t10 = TypeInfo.fromType(Duration);
      expect(t10.isDuration, isTrue);
      expect(t10.hasArguments, isFalse);
      expect(t10.equivalentArgumentsTypes([]), isTrue);
      expect(t10.equivalentArgumentsTypes([int]), isFalse);
    });

    test('from', () async {
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
        expect(TypeInfo<Object>.from(TestUserSimple.empty()).type,
            equals(TestUserSimple));

        expect(TypeInfo<int>.from(TestUserSimple.empty()).type,
            equals(TestUserSimple));
      }

      {
        expect(TypeInfo.from(bool).isPrimitiveType, isTrue);
        expect(TypeInfo.from(int).isPrimitiveType, isTrue);
        expect(TypeInfo.from(double).isPrimitiveType, isTrue);
        expect(TypeInfo.from(num).isPrimitiveType, isTrue);
        expect(TypeInfo.from(String).isPrimitiveType, isTrue);

        expect(TypeInfo.from(DateTime).isPrimitiveType, isFalse);
        expect(TypeInfo.from(Duration).isPrimitiveType, isFalse);
        expect(TypeInfo.from(Uint8List).isPrimitiveType, isFalse);
        expect(TypeInfo.from(List).isPrimitiveType, isFalse);
        expect(TypeInfo.from(Map).isPrimitiveType, isFalse);
        expect(TypeInfo.from(Set).isPrimitiveType, isFalse);
        expect(TypeInfo.from(dynamic).isPrimitiveType, isFalse);
        expect(TypeInfo.from(Object).isPrimitiveType, isFalse);
        expect(TypeInfo.from(TestUserSimple).isPrimitiveType, isFalse);
      }

      {
        expect(TypeInfo.from(dynamic).isPrimitiveOrDynamicOrObjectType, isTrue);
        expect(TypeInfo.from(Object).isPrimitiveOrDynamicOrObjectType, isTrue);
        expect(TypeInfo.from(int).isPrimitiveOrDynamicOrObjectType, isTrue);
        expect(TypeInfo.from(bool).isPrimitiveOrDynamicOrObjectType, isTrue);

        expect(TypeInfo.from(TestUserSimple).isPrimitiveOrDynamicOrObjectType,
            isFalse);
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
        expect(TypeInfo.from(DateTime).isCollection, isFalse);
        expect(TypeInfo.from(Duration).isCollection, isFalse);
        expect(TypeInfo.from(Uint8List).isCollection, isFalse);

        expect(TypeInfo.from(TestUserSimple).isCollection, isFalse);
      }

      {
        expect(TypeInfo.from(int).isBasicType, isTrue);
        expect(TypeInfo.from(bool).isBasicType, isTrue);
        expect(TypeInfo.from(List).isBasicType, isTrue);
        expect(TypeInfo.from(Map).isBasicType, isTrue);

        expect(TypeInfo.from(DateTime).isBasicType, isFalse);
        expect(TypeInfo.from(Duration).isBasicType, isFalse);
        expect(TypeInfo.from(Uint8List).isBasicType, isFalse);

        expect(TypeInfo.from(TestUserSimple).isBasicType, isFalse);
      }

      {
        expect(TypeInfo.from(int).isEntityType, isFalse);
        expect(TypeInfo.from(bool).isEntityType, isFalse);
        expect(TypeInfo.from(String).isEntityType, isFalse);
        expect(TypeInfo.from(Object).isEntityType, isFalse);
        expect(TypeInfo.from(dynamic).isEntityType, isFalse);

        expect(TypeInfo.from(TestUserSimple).isEntityType, isTrue);
      }

      {
        expect(TypeInfo.fromListType(int).isListEntity, isFalse);
        expect(TypeInfo.fromListType(Object).isListEntity, isFalse);
        expect(TypeInfo.fromListType(dynamic).isListEntity, isFalse);

        expect(TypeInfo.fromListType(TestUserSimple).isListEntity, isTrue);
      }

      {
        expect(TypeInfo.fromListType(int).listEntityType, isNull);
        expect(TypeInfo.fromListType(Object).listEntityType, isNull);
        expect(TypeInfo.fromListType(dynamic).listEntityType, isNull);

        expect(TypeInfo.fromListType(TestUserSimple).listEntityType,
            equals(TypeInfo.from(TestUserSimple)));
      }

      {
        expect(TypeInfo.accepts<int>(int), isTrue);
        expect(TypeInfo.accepts<int>(double), isFalse);

        expect(TypeInfo.accepts<String>(String), isTrue);
        expect(TypeInfo.accepts<String>(int), isFalse);

        expect(TypeInfo.accepts<DateTime>(DateTime), isTrue);
        expect(TypeInfo.accepts<DateTime>(int), isFalse);

        expect(TypeInfo.accepts<Duration>(Duration), isTrue);
        expect(TypeInfo.accepts<Duration>(int), isFalse);

        expect(TypeInfo.accepts<Uint8List>(Uint8List), isTrue);
        expect(TypeInfo.accepts<Uint8List>(int), isFalse);

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
        expect(TypeInfo.from(DateTime), equals(TypeInfo.tDateTime));
        expect(TypeInfo.from(String), isNot(equals(TypeInfo.tDateTime)));

        expect(TypeInfo.from(Duration), equals(TypeInfo.tDuration));
        expect(TypeInfo.from(String), isNot(equals(TypeInfo.tDuration)));

        expect(TypeInfo.from(Uint8List), equals(TypeInfo.tUint8List));
        expect(TypeInfo.from(String), isNot(equals(TypeInfo.tUint8List)));

        expect(TypeInfo.from(DateTime.now()), equals(TypeInfo.tDateTime));
        expect(TypeInfo.from(Duration.zero), equals(TypeInfo.tDuration));

        expect(TypeInfo.from(Uint8List.fromList([0])),
            equals(TypeInfo.tUint8List));
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

        var company = TestCompanyWithReflection('FooInc',
            TestAddressWithReflection.withCity('State1', city: 'City1'),
            extraAddresses: [
              TestAddressWithReflection.withCity('State2', city: 'City2'),
              TestAddressWithReflection.withCity('State3', city: 'City3')
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
        var typeReflection = TypeReflection<Future<TestUserWithReflection>>(
            Future, [TypeInfo<TestUserWithReflection>(TestUserWithReflection)]);

        var typeInfo = typeReflection.typeInfo;

        expect(typeInfo.isFuture, isTrue);
        expect(typeInfo.equalsArgumentsTypes([TestUserWithReflection]), isTrue);
      }

      {
        var typeReflection = TypeReflection<FutureOr<TestUserWithReflection>>(
            FutureOr,
            [TypeInfo<TestUserWithReflection>(TestUserWithReflection)]);

        var typeInfo = typeReflection.typeInfo;

        expect(typeInfo.isFutureOr, isTrue);
        expect(typeInfo.isDynamic, isFalse);
        expect(typeInfo.equalsArgumentsTypes([TestUserWithReflection]), isTrue);
      }

      {
        var typeReflection = TypeReflection<Future<TestOpAWithReflection>>(
            Future, [
          TypeInfo<TestOpAWithReflection>.fromObject(TestOpAWithReflection(123))
        ]);

        var typeInfo = typeReflection.typeInfo;

        expect(typeInfo.isFuture, isTrue);
        expect(typeInfo.equalsArgumentsTypes([TestOpAWithReflection]), isTrue);

        expect(typeInfo, equals(TypeInfo(Future, [TestOpAWithReflection])));
      }

      {
        var typeReflection = TypeReflection<Future<TestOpWithReflection<int>>>(
            Future, [TypeInfo.from(TestOpWithReflection<int>('test', 123))]);

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
        var typeReflection = TypeReflection<Future<TestOpWithReflection>>(
            Future, [
          TypeInfo.fromType(TestOpWithReflection$reflection().reflectedType)
        ]);

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

    test('callCasted', () async {
      {
        var t = TypeInfo<List<TestUserSimple>>.fromType(
            List, [TypeInfo<TestUserSimple>.fromType(TestUserSimple)]);

        expect(t.type, equals(List));

        var tArg0 = t.argumentType(0)!;
        expect(tArg0.type, equals(TestUserSimple));

        List<Type> castCall<T>() => <Type>[T];

        expect(t.callCasted(castCall), equals(<Type>[List<TestUserSimple>]));

        expect(t.argumentType(0)?.callCasted(castCall),
            equals(<Type>[TestUserSimple]));

        expect(t.callCastedArgumentA(<A>() => A), equals(TestUserSimple));
      }

      {
        var t = TypeInfo<Map<String, TestUserSimple>>.fromType(
            Map, [String, TypeInfo<TestUserSimple>.fromType(TestUserSimple)]);

        expect(t.type, equals(Map));
        expect(t.genericType, equals(Map<String, TestUserSimple>));

        var tArg0 = t.argumentType(0)!;
        expect(tArg0.type, equals(String));

        var tArg1 = t.argumentType(1)!;
        expect(tArg1.type, equals(TestUserSimple));

        expect(t.callCastedArgumentA(<A>() => A), equals(String));

        expect(t.callCastedArgumentsAB(<A, B>() => [A, B]),
            equals([String, TestUserSimple]));
      }
    });

    test('isCastedList', () async {
      {
        var t = TypeInfo<List<int>>.fromType(List, [int]);

        expect(t.genericType, equals(List<int>));
        expect(t.arguments0?.genericType, equals(int));

        var list = <int>[1, 2, 3];
        var listObj = <Object>[1, 2, 3];

        expect(t.isCastedList(list), isTrue);
        expect(t.isCastedList(listObj), isFalse);

        expect(t.isCastedSet(list), isFalse);
        expect(t.isCastedIterable(list), isTrue);
        expect(t.isCastedMap(list), isFalse);
      }
    });

    test('isCastedSet', () async {
      {
        var t = TypeInfo<Set<int>>.fromType(Set, [int]);

        expect(t.genericType, equals(Set<int>));
        expect(t.arguments0?.genericType, equals(int));

        var set = <int>{1, 2, 3};
        var setObj = <Object>{1, 2, 3};

        expect(t.isCastedSet(set), isTrue);
        expect(t.isCastedSet(setObj), isFalse);

        expect(t.isCastedList(set), isFalse);
        expect(t.isCastedIterable(set), isTrue);
        expect(t.isCastedMap(setObj), isFalse);
      }
    });

    test('isCastedIterable', () async {
      {
        var t = TypeInfo<Iterable<int>>.fromType(Iterable, [int]);

        expect(t.genericType, equals(Iterable<int>));
        expect(t.arguments0?.genericType, equals(int));

        var list = <int>[1, 2, 3];
        var listObj = <Object>[1, 2, 3];

        var set = <int>{1, 2, 3};
        var setObj = <Object>{1, 2, 3};

        expect(t.isCastedIterable(list), isTrue);
        expect(t.isCastedIterable(set), isTrue);
        expect(t.isCastedIterable(listObj), isFalse);
        expect(t.isCastedIterable(setObj), isFalse);

        expect(t.isCastedList(list), isFalse);
        expect(t.isCastedSet(list), isFalse);
        expect(t.isCastedList(set), isFalse);
        expect(t.isCastedSet(set), isFalse);

        expect(t.isCastedMap(setObj), isFalse);
      }
    });

    test('isCastedMap<K,V>', () async {
      {
        var t = TypeInfo<Map<String, int>>.fromType(Map, [String, int]);

        expect(t.genericType, equals(Map<String, int>));
        expect(t.arguments0?.genericType, equals(String));
        expect(t.arguments1?.genericType, equals(int));

        var map = <String, int>{'a': 1, 'b': 2};
        var mapObjKV = <Object, Object>{'a': 1, 'b': 2};
        var mapObjV = <String, Object>{'a': 1, 'b': 2};
        var mapObjK = <Object, int>{'a': 1, 'b': 2};

        expect(t.isCastedMap(map), isTrue);
        expect(t.isCastedMap(mapObjKV), isFalse);
        expect(t.isCastedMap(mapObjV), isFalse);
        expect(t.isCastedMap(mapObjK), isFalse);

        expect(t.isCastedList(map), isFalse);
        expect(t.isCastedSet(map), isFalse);
        expect(t.isCastedIterable(map), isFalse);
      }
    });

    test('isCastedMap<K>', () async {
      {
        var t = TypeInfo<Map<String, dynamic>>.fromType(Map, [String, dynamic]);

        expect(t.genericType, equals(Map<String, dynamic>));
        expect(t.arguments0?.genericType, equals(String));
        expect(t.arguments1?.genericType, equals(dynamic));

        expect(t.arguments0?.isValidGenericType, isTrue);
        expect(t.arguments1?.isValidGenericType, isTrue);

        expect(t.arguments0?.isDynamic, isFalse);
        expect(t.arguments0?.isDynamicOrObject, isFalse);

        expect(t.arguments1?.isDynamic, isTrue);
        expect(t.arguments1?.isDynamicOrObject, isTrue);

        var map1 = <String, int>{'a': 1, 'b': 2};
        var map2 = <String, String>{'a': '1', 'b': '2'};
        var mapObj = <Object, Object>{'a': 1, 'b': 2};

        expect(t.isCastedMap(map1), isTrue);
        expect(t.isCastedMap(map2), isTrue);

        expect(t.isCastedMap(mapObj), isFalse);
      }
    });

    test('isCastedMap<V>', () async {
      {
        var t = TypeInfo<Map<dynamic, int>>.fromType(Map, [dynamic, int]);

        expect(t.genericType, equals(Map<dynamic, int>));
        expect(t.arguments0?.genericType, equals(dynamic));
        expect(t.arguments1?.genericType, equals(int));

        expect(t.arguments0?.isValidGenericType, isTrue);
        expect(t.arguments1?.isValidGenericType, isTrue);

        expect(t.arguments0?.isDynamic, isTrue);
        expect(t.arguments0?.isDynamicOrObject, isTrue);

        expect(t.arguments1?.isDynamic, isFalse);
        expect(t.arguments1?.isDynamicOrObject, isFalse);

        var map1 = <String, int>{'a': 1, 'b': 2};
        var map2 = <int, int>{1: 1, 2: 2};
        var mapObj = <Object, Object>{'a': 1, 'b': 2};

        expect(t.isCastedMap(map1), isTrue);
        expect(t.isCastedMap(map2), isTrue);

        expect(t.isCastedMap(mapObj), isFalse);
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
        var t = TypeInfo(num);
        expect(t.parse('123'), equals(123));
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
        var t = TypeInfo(Duration);
        var duration = Duration(milliseconds: 1000 * 101);
        expect(t.parse(101000), equals(duration));
        expect(t.parse('0:01:41'), equals(duration));

        var duration2 = Duration(hours: 101);
        expect(t.parse('101'), equals(duration2));
        expect(t.parse(' 101 '), equals(duration2));

        var duration3 = Duration(hours: 22, minutes: 11);
        expect(t.parse('22:11'), equals(duration3));
        expect(t.parse(' 22;11 '), equals(duration3));
      }

      {
        var t = TypeInfo(BigInt);
        var n = BigInt.from(1577934245000);
        expect(t.parse('1577934245000'), equals(n));
        expect(t.parse(' 1577934245000 '), equals(n));
        expect(t.parse(1577934245000), equals(n));
      }

      {
        var t = TypeInfo(Uint8List);

        expect(t.parse(base64.encode([10, 9, 8, 7, 6])),
            equals(Uint8List.fromList([10, 9, 8, 7, 6])));
        expect(
            t.parse('0403020100'), equals(Uint8List.fromList([4, 3, 2, 1, 0])));
        expect(t.parse([3, 2, 1, 0]), equals(Uint8List.fromList([3, 2, 1, 0])));
      }

      {
        var t = TypeInfo(List);
        var l = ['a', 'b', 'c'];
        expect(t.parse('a,b,c'), equals(l));
        expect(t.parse('a;b;c'), equals(l));
        expect(t.parse(['a', 'b', 'c']), equals(l));
      }

      {
        var t = TypeInfo(List);
        expect(t.parse(true), equals([true]));
        expect(t.parse(false), equals([false]));
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

      {
        var t = TypeInfo(TestUserSimple);

        expect(t.parse(TestUserSimple.empty()), equals(TestUserSimple.empty()));
      }
    });

    test('TypeInfo.parseTraversingFuture', () async {
      {
        var t = TypeInfo<int>(int);

        expect(t.parse('123'), equals(123));
        expect(t.parseTraversingFuture('123'), equals(123));
      }

      {
        var t = TypeInfo<Future<int>>(Future, [TypeInfo<int>(int)]);

        expect(t.parse('123'), isNull);
        expect(t.parseTraversingFuture('123'), equals(123));
      }
    });

    test('TypeInfo.fromJson', () async {
      {
        TestUserWithReflection$reflection.boot();

        var typeListOfUser = TypeInfo.fromType(List, [TestUserWithReflection]);

        var users = [
          TestUserWithReflection.fields('joe', 'joe@mail.com', 'j123456',
              id: 101),
          TestUserWithReflection.fields('smith', 'smith@mail.com', 's123456',
              id: 102)
        ];

        var usersJson = JsonEncoder.defaultEncoder
            .toJson(users, duplicatedEntitiesAsID: true);

        expect(
            usersJson,
            equals([
              {
                'axis': 'x',
                'email': 'joe@mail.com',
                'enabled': true,
                'id': 101,
                'isEnabled': true,
                'theLevel': null,
                'name': 'joe',
                'password': 'j123456'
              },
              {
                'axis': 'x',
                'email': 'smith@mail.com',
                'enabled': true,
                'id': 102,
                'isEnabled': true,
                'theLevel': null,
                'name': 'smith',
                'password': 's123456'
              }
            ]));

        var usersDecoded = typeListOfUser.fromJson(usersJson);

        expect(
            JsonEncoder.defaultEncoder
                .toJson(usersDecoded, duplicatedEntitiesAsID: true),
            equals([
              {
                'axis': 'x',
                'email': 'joe@mail.com',
                'enabled': true,
                'id': 101,
                'isEnabled': true,
                'theLevel': null,
                'name': 'joe',
                'password': 'j123456'
              },
              {
                'axis': 'x',
                'email': 'smith@mail.com',
                'enabled': true,
                'id': 102,
                'isEnabled': true,
                'theLevel': null,
                'name': 'smith',
                'password': 's123456'
              }
            ]));

        // ignore: avoid_dynamic_calls
        var json2WithRef = [usersJson[0], usersJson[0]['id']];
        var usersDecoded2 = typeListOfUser.fromJson(json2WithRef) as List;

        expect(identical(usersDecoded2[0], usersDecoded2[1]), isTrue);

        expect(
            JsonEncoder.defaultEncoder
                .toJson(usersDecoded2, duplicatedEntitiesAsID: true),
            equals([
              {
                'axis': 'x',
                'email': 'joe@mail.com',
                'enabled': true,
                'id': 101,
                'isEnabled': true,
                'theLevel': null,
                'name': 'joe',
                'password': 'j123456'
              },
              101
            ]));
      }

      {
        TestUserWithReflection$reflection.boot();

        var typeUser =
            TypeInfo<TestUserWithReflection>.fromType(TestUserWithReflection);

        var typeListOfUser =
            TypeInfo<List<TestUserWithReflection>>.fromListType(typeUser);

        var user1 = TestUserWithReflection.fields(
            'joe', 'joe@mail.com', 'j123456',
            id: 101);
        var user2 = TestUserWithReflection.fields(
            'smith', 'smith@mail.com', 's123456',
            id: 102);

        var users = [user1, user2, user1];

        var usersJson = JsonEncoder.defaultEncoder
            .toJson(users, duplicatedEntitiesAsID: true);

        expect(
            usersJson,
            equals([
              {
                'axis': 'x',
                'email': 'joe@mail.com',
                'enabled': true,
                'id': 101,
                'isEnabled': true,
                'theLevel': null,
                'name': 'joe',
                'password': 'j123456'
              },
              {
                'axis': 'x',
                'email': 'smith@mail.com',
                'enabled': true,
                'id': 102,
                'isEnabled': true,
                'theLevel': null,
                'name': 'smith',
                'password': 's123456'
              },
              101
            ]));

        var usersDecoded = typeListOfUser.fromJson(usersJson) as List;

        expect(usersDecoded, equals([user1, user2, user1]));
        expect(usersDecoded, isA<List<TestUserWithReflection>>());

        expect(identical(usersDecoded[0], usersDecoded[1]), isFalse);
        expect(identical(usersDecoded[0], usersDecoded[2]), isTrue);
        expect(identical(usersDecoded[1], usersDecoded[2]), isFalse);

        {
          var typeListOfListOfUser =
              TypeInfo<List<List<TestUserWithReflection>>>.fromListType(
                  typeListOfUser);

          var listUsersDecoded =
              typeListOfListOfUser.fromJson([usersJson]) as List;

          expect(
              listUsersDecoded,
              equals([
                [user1, user2, user1]
              ]));

          expect(listUsersDecoded, isA<List<List<TestUserWithReflection>>>());
        }

        expect(
            JsonEncoder.defaultEncoder
                .toJson(usersDecoded, duplicatedEntitiesAsID: true),
            equals([
              {
                'axis': 'x',
                'email': 'joe@mail.com',
                'enabled': true,
                'id': 101,
                'isEnabled': true,
                'theLevel': null,
                'name': 'joe',
                'password': 'j123456'
              },
              {
                'axis': 'x',
                'email': 'smith@mail.com',
                'enabled': true,
                'id': 102,
                'isEnabled': true,
                'theLevel': null,
                'name': 'smith',
                'password': 's123456'
              },
              101
            ]));
      }

      {
        var typeMapOfUser =
            TypeInfo.fromType(Map, [String, TestUserWithReflection]);

        var users = <String, TestUserWithReflection>{
          'a': TestUserWithReflection.fields('joe', 'j@mail', '123'),
          'b': TestUserWithReflection.fields('smith', 's@mail', 'abc'),
        };

        var usersJson = JsonEncoder.defaultEncoder
            .toJson(users, duplicatedEntitiesAsID: true);

        expect(
            usersJson,
            equals({
              'a': {
                'axis': 'x',
                'email': 'j@mail',
                'enabled': true,
                'id': null,
                'isEnabled': true,
                'theLevel': null,
                'name': 'joe',
                'password': '123'
              },
              'b': {
                'axis': 'x',
                'email': 's@mail',
                'enabled': true,
                'id': null,
                'isEnabled': true,
                'theLevel': null,
                'name': 'smith',
                'password': 'abc'
              }
            }));

        var users2 = typeMapOfUser.fromJson(usersJson);

        expect(users2, equals(users));
      }

      {
        var entityType = TypeInfo<TestCompanyWithReflection>.fromType(
            TestCompanyWithReflection);

        var address1 =
            TestAddressWithReflection.withCity('NY', city: 'New York', id: 1);
        var address2 = TestAddressWithReflection.withCity('CA',
            city: 'Los Angeles', id: 2);
        var address3 =
            TestAddressWithReflection.withCity('MA', city: 'Boston', id: 3);

        var company1 = TestCompanyWithReflection('Comp1', address1,
            branchesAddresses: [address1],
            extraAddresses: [address2, address3]);

        var company1Json = JsonEncoder.defaultEncoder
            .toJson(company1, duplicatedEntitiesAsID: true);

        expect(
            company1Json,
            equals({
              'branchesAddresses': [
                {'id': 1, 'state': 'NY', 'city': 'New York'}
              ],
              'extraAddresses': [
                {'id': 2, 'state': 'CA', 'city': 'Los Angeles'},
                {'id': 3, 'state': 'MA', 'city': 'Boston'}
              ],
              'extraNames': [],
              'mainAddress': 1,
              'name': 'Comp1'
            }));

        var company1Decoded = JsonDecoder.defaultDecoder.fromJson(company1Json,
            type: TestCompanyWithReflection, duplicatedEntitiesAsID: true);
        expect(company1Decoded, equals(company1));

        var company1Decoded2 = entityType.fromJson(company1Json);
        expect(company1Decoded2, equals(company1));

        var company2 = TestCompanyWithReflection('Comp2', address1,
            branchesAddresses: [address2],
            extraAddresses: [address2, address1, address2]);

        var company2Json = JsonEncoder.defaultEncoder
            .toJson(company2, duplicatedEntitiesAsID: true);

        expect(
            company2Json,
            equals({
              'branchesAddresses': [
                {'id': 2, 'state': 'CA', 'city': 'Los Angeles'}
              ],
              'extraAddresses': [
                2,
                {'id': 1, 'state': 'NY', 'city': 'New York'},
                2
              ],
              'extraNames': [],
              'mainAddress': 1,
              'name': 'Comp2'
            }));

        var company2Decoded = JsonDecoder.defaultDecoder.fromJson(company2Json,
            type: TestCompanyWithReflection, duplicatedEntitiesAsID: true);
        expect(company2Decoded, equals(company2));

        var company2Decoded2 = entityType.fromJson(company2Json);
        expect(company2Decoded2, equals(company2));

        var companiesList = <TestCompanyWithReflection>[company1, company2];

        var companiesListType =
            TypeInfo<List<TestCompanyWithReflection>>.fromType(List, [
          TypeInfo<TestCompanyWithReflection>.fromType(
              TestCompanyWithReflection)
        ]);

        var companiesJson = JsonEncoder.defaultEncoder
            .toJson(companiesList, duplicatedEntitiesAsID: true);

        expect(
            companiesJson,
            equals([
              {
                'branchesAddresses': [
                  {'id': 1, 'state': 'NY', 'city': 'New York'}
                ],
                'extraAddresses': [
                  {'id': 2, 'state': 'CA', 'city': 'Los Angeles'},
                  {'id': 3, 'state': 'MA', 'city': 'Boston'}
                ],
                'extraNames': [],
                'mainAddress': 1,
                'name': 'Comp1'
              },
              {
                'branchesAddresses': [2],
                'extraAddresses': [2, 1, 2],
                'extraNames': [],
                'mainAddress': 1,
                'name': 'Comp2'
              }
            ]));

        var companiesDecoded = companiesListType.fromJson(companiesJson);

        expect(companiesDecoded, companiesList);
      }

      {
        var entityType = TypeInfo<TestCompanyWithReflection>.fromType(
            TestCompanyWithReflection);

        var address1 =
            TestAddressWithReflection.withCity('NY', city: 'New York', id: 1);
        var address2 = TestAddressWithReflection.withCity('CA',
            city: 'Los Angeles', id: 2);
        var address3 =
            TestAddressWithReflection.withCity('MA', city: 'Boston', id: 3);

        var company1 = TestCompanyWithReflection('Comp1', address2,
            branchesAddresses: [address1, address3],
            extraAddresses: [address2, address3]);

        var company1Json = JsonEncoder.defaultEncoder
            .toJson(company1, duplicatedEntitiesAsID: true);

        expect(
            company1Json,
            equals({
              'branchesAddresses': [
                {'id': 1, 'state': 'NY', 'city': 'New York'},
                {'id': 3, 'state': 'MA', 'city': 'Boston'}
              ],
              'extraAddresses': [
                {'id': 2, 'state': 'CA', 'city': 'Los Angeles'},
                3
              ],
              'extraNames': [],
              'mainAddress': 2,
              'name': 'Comp1'
            }));

        var company1Decoded = JsonDecoder.defaultDecoder.fromJson(company1Json,
            type: TestCompanyWithReflection, duplicatedEntitiesAsID: true);
        expect(company1Decoded, equals(company1));

        var company1Decoded2 = entityType.fromJson(company1Json);
        expect(company1Decoded2, equals(company1));

        var company1Json2 = {
          'branchesAddresses': [
            {'id': 1, 'state': 'NY', 'city': 'New York'},
            3
          ],
          'extraAddresses': [
            {'id': 2, 'state': 'CA', 'city': 'Los Angeles'},
            {'id': 3, 'state': 'MA', 'city': 'Boston'}
          ],
          'extraNames': [],
          'mainAddress': 2,
          'name': 'Comp1'
        };

        var company1Decoded3 = JsonDecoder.defaultDecoder.fromJson(
            company1Json2,
            type: TestCompanyWithReflection,
            duplicatedEntitiesAsID: true);
        expect(company1Decoded3, equals(company1));

        var company1Decoded4 = entityType.fromJson(company1Json2);
        expect(company1Decoded4, equals(company1));
      }
    });
  });

  group('Equality', () {
    test('TypeEquality', () async {
      TypeEquality teq = TypeEquality();

      expect(teq.isValidKey(int), isTrue);
      expect(teq.isValidKey(123), isFalse);

      expect(teq.equals(int, int), isTrue);
      expect(teq.equals(int, 123.runtimeType), isTrue);

      expect(teq.equals(int, String), isFalse);

      expect(teq.equals(Object, dynamic), isFalse);

      expect(teq.hash(int), equals(teq.hash(int)));
      expect(teq.hash(int), isNot(equals(teq.hash(String))));
    });

    test('TypeEquivalency', () async {
      TypeEquivalency teq = TypeEquivalency();

      expect(teq.isValidKey(int), isTrue);
      expect(teq.isValidKey(123), isFalse);

      expect(teq.equals(int, int), isTrue);
      expect(teq.equals(int, 123.runtimeType), isTrue);

      expect(teq.equals(int, String), isFalse);

      expect(teq.equals(Object, dynamic), isTrue);

      expect(teq.hash(int), equals(teq.hash(int)));
      expect(teq.hash(int), isNot(equals(teq.hash(String))));
    });

    test('TypeListEquality', () async {
      TypeListEquality teq = TypeListEquality();

      expect(teq.isValidKey(<Type>[int]), isTrue);
      expect(teq.isValidKey(<int>[123]), isFalse);
      expect(teq.isValidKey(int), isFalse);
      expect(teq.isValidKey(123), isFalse);

      expect(teq.equals(<Type>[int], <Type>[int]), isTrue);
      expect(teq.equals(<Type>[int], <Type>[String]), isFalse);

      expect(teq.equals(<Type>[int, String], <Type>[int, String]), isTrue);
      expect(teq.equals(<Type>[int, String], <Type>[int, Object]), isFalse);
    });

    test('TypeInfo.equivalentTypeList', () async {
      expect(TypeInfo.equivalentTypeList(<Type>[int], <Type>[int]), isTrue);
      expect(TypeInfo.equivalentTypeList(<Type>[int], <Type>[String]), isFalse);

      expect(
          TypeInfo.equivalentTypeList(<Type>[int, String], <Type>[int, String]),
          isTrue);
      expect(
          TypeInfo.equivalentTypeList(<Type>[String, int], <Type>[int, String]),
          isFalse);
    });

    test('TypeInfo.equalsTypeInfoList', () async {
      expect(
          TypeInfo.equalsTypeInfoList(<TypeInfo>[TypeInfo.fromType(int)],
              <TypeInfo>[TypeInfo.fromType(int)]),
          isTrue);

      expect(
          TypeInfo.equalsTypeInfoList(<TypeInfo>[TypeInfo.fromType(int)],
              <TypeInfo>[TypeInfo.fromType(String)]),
          isFalse);

      expect(
          TypeInfo.equalsTypeInfoList(
              <TypeInfo>[TypeInfo.fromType(int), TypeInfo.fromType(String)],
              <TypeInfo>[TypeInfo.fromType(int), TypeInfo.fromType(String)]),
          isTrue);

      expect(
          TypeInfo.equalsTypeInfoList(
              <TypeInfo>[TypeInfo.fromType(String), TypeInfo.fromType(int)],
              <TypeInfo>[TypeInfo.fromType(int), TypeInfo.fromType(String)]),
          isFalse);
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
      expect(TypeParser.parseInt(Duration(seconds: 11)), equals(11000));
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
      expect(TypeParser.parseDouble(Duration(seconds: 11)), equals(11000));
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
      expect(TypeParser.parseNum(Duration(seconds: 11)), equals(11000));
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
      expect(TypeParser.parseBool('on'), isTrue);
      expect(TypeParser.parseBool('enabled'), isTrue);
      expect(TypeParser.parseBool('selected'), isTrue);
      expect(TypeParser.parseBool('checked'), isTrue);
      expect(TypeParser.parseBool('positive'), isTrue);

      expect(TypeParser.parseBool('false'), isFalse);
      expect(TypeParser.parseBool('f'), isFalse);
      expect(TypeParser.parseBool('no'), isFalse);
      expect(TypeParser.parseBool('fail'), isFalse);
      expect(TypeParser.parseBool('error'), isFalse);
      expect(TypeParser.parseBool('off'), isFalse);
      expect(TypeParser.parseBool('disabled'), isFalse);
      expect(TypeParser.parseBool('unselected'), isFalse);
      expect(TypeParser.parseBool('unchecked'), isFalse);
      expect(TypeParser.parseBool('negative'), isFalse);
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

      expect(TypeParser.parserFor(obj: Duration(hours: -3))!('-3'),
          isA<Duration>());

      expect(TypeParser.parserFor(obj: {'a': 1})!('a:1'), isA<Map>());
      expect(TypeParser.parserFor(obj: {1, 2})!('1,2'), isA<Set>());
      expect(TypeParser.parserFor(obj: [1, 2])!('1,2'), isA<List>());
      expect(TypeParser.parserFor(obj: [1, 2].map((e) => e))!('1,2'),
          isA<Iterable>());

      expect(TypeParser.parserFor(obj: Uint8List(0))!('0001020304'),
          allOf(isA<Uint8List>(), equals([0, 1, 2, 3, 4])));

      expect(
          TypeParser.parserFor(obj: Uint8List(0))!(
              base64.encode([5, 4, 3, 2, 1, 0])),
          allOf(isA<Uint8List>(), equals([5, 4, 3, 2, 1, 0])));

      expect(TypeParser.parserFor(obj: Uint8List(0))!([5, 4, 3]),
          allOf(isA<Uint8List>(), equals([5, 4, 3])));

      expect(
          TypeParser.parserFor(obj: Uint8List(0))!([5, 4, 3].map((n) => n * 2)),
          allOf(isA<Uint8List>(), equals([10, 8, 6])));

      expect(TypeParser.parserFor(obj: Uint8List(0))!(['6', '5', '4', '3']),
          allOf(isA<Uint8List>(), equals([6, 5, 4, 3])));
    });

    test('TypeParser.parserFor', () async {
      expect(TypeParser.parseValueForType(double, '12.3'), equals(12.3));

      expect(TypeParser.parseValueForType(BigInt, '123'),
          equals(BigInt.from(123)));

      expect(TypeParser.parseValueForType(DateTime, '2020-01-02 03:04:05.000Z'),
          equals(DateTime.parse('2020-01-02 03:04:05.000Z')));

      expect(
          TypeParser.parseValueForType(Duration, '11:10:09:303.101'),
          equals(Duration(
              hours: 11,
              minutes: 10,
              seconds: 9,
              milliseconds: 303,
              microseconds: 101)));
    });

    test('TypeParser.parseList', () async {
      expect(TypeParser.parseList([1, 2, 3]), equals([1, 2, 3]));
      expect(TypeParser.parseList('1,2,3'), equals(['1', '2', '3']));
      expect(TypeParser.parseList('1,2,3', elementParser: TypeParser.parseInt),
          equals([1, 2, 3]));
      expect(TypeParser.parseList<int>('1,2,3'), equals([1, 2, 3]));

      expect(TypeParser.parseList(123), equals([123]));
      expect(TypeParser.parseList<int>(123), equals([123]));

      expect(TypeParser.parseList(123.0), equals([123.0]));
      expect(TypeParser.parseList<double>(123), equals([123.0]));

      expect(TypeParser.parseList(123), equals([123]));
      expect(TypeParser.parseList<num>(123), equals([123.0]));
    });

    test('TypeParser.parseSet', () async {
      expect(TypeParser.parseSet([1, 2, 3]), equals({1, 2, 3}));
      expect(TypeParser.parseSet('1,2,3'), equals({'1', '2', '3'}));
      expect(TypeParser.parseSet('1,2,3', elementParser: TypeParser.parseInt),
          equals({1, 2, 3}));
      expect(TypeParser.parseSet<int>('1,2,3'), equals({1, 2, 3}));

      expect(TypeParser.parseSet(123), equals({123}));
      expect(TypeParser.parseSet<int>(123), equals({123}));

      expect(TypeParser.parseSet(123.0), equals({123.0}));
      expect(TypeParser.parseSet<double>(123), equals({123.0}));

      expect(TypeParser.parseSet(123), equals({123}));
      expect(TypeParser.parseSet<num>(123), equals({123.0}));
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

      expect(TypeParser.parseMap(123), equals({123: null}));
      expect(TypeParser.parseMap<int, Object?>(123), equals({123: null}));

      expect(() => TypeParser.parseMap<int, String>(123),
          throwsA(isA<TypeError>()));

      expect(TypeParser.parseMap(12.3), equals({12.3: null}));
      expect(TypeParser.parseMap([123, 456]), equals({123: null, 456: null}));

      expect(TypeParser.parseMap('123:a ; 456:b'),
          equals({'123': 'a', '456': 'b'}));
      expect(TypeParser.parseMap<int, String>('123:a ; 456:b'),
          equals({123: 'a', 456: 'b'}));
    });

    test('TypeParser.parseDateTime', () async {
      expect(TypeParser.parseDateTime(DateTime.utc(2020, 1, 2, 3, 4, 5, 0, 0)),
          equals(DateTime.utc(2020, 1, 2, 3, 4, 5, 0, 0)));

      expect(TypeParser.parseDateTime('2020-01-02 03:04:05.000Z'),
          equals(DateTime.utc(2020, 1, 2, 3, 4, 5, 0, 0)));

      expect(TypeParser.parseDateTime(1577934245000),
          equals(DateTime.fromMillisecondsSinceEpoch(1577934245000)));
    });

    test('TypeParser.parseDuration', () async {
      expect(TypeParser.parseDuration(Duration(hours: -3)),
          equals(Duration(hours: -3)));

      expect(TypeParser.parseDuration('4:10:20'),
          equals(Duration(hours: 4, minutes: 10, seconds: 20)));

      expect(TypeParser.parseDuration(1000 * 60 * 30),
          equals(Duration(milliseconds: 1000 * 60 * 30)));

      expect(TypeParser.parseDuration(-1000 * 60 * 30),
          equals(Duration(milliseconds: -1000 * 60 * 30)));
    });

    test('TypeParser.parseUInt8List', () async {
      expect(TypeParser.parseUInt8List([1, 2, 3, 4, 5]),
          equals(Uint8List.fromList([1, 2, 3, 4, 5])));

      expect(TypeParser.parseUInt8List('aGVsbG8='),
          equals(Uint8List.fromList(base64.decode('aGVsbG8='))));
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
