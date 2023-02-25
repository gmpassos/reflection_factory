import 'package:collection/collection.dart';
import 'package:reflection_factory/reflection_factory.dart';
import 'package:test/test.dart';

import 'src/user_reflection_bridge.dart';
import 'src/user_simple.dart';
import 'src/user_with_reflection.dart';

void main() {
  group('Reflection', () {
    setUp(() {});

    test('EnableReflection', () async {
      expect(TypeReflection.getConstantName('Object'), equals('tObject'));
      expect(TypeReflection.getConstantName('dynamic'), equals('tDynamic'));
      expect(TypeReflection.getConstantName('String'), equals('tString'));
      expect(TypeReflection.getConstantName('double'), equals('tDouble'));
      expect(TypeReflection.getConstantName('int'), equals('tInt'));
      expect(TypeReflection.getConstantName('num'), equals('tNum'));
      expect(TypeReflection.getConstantName('bool'), equals('tBool'));
      expect(TypeReflection.getConstantName('List'), equals('tList'));
      expect(TypeReflection.getConstantName('Map'), equals('tMap'));
      expect(TypeReflection.getConstantName('Set'), equals('tSet'));
      expect(TypeReflection.getConstantName('Future'), equals('tFuture'));
      expect(TypeReflection.getConstantName('FutureOr'), equals('tFutureOr'));

      expect(TypeReflection.getConstantName('List', ['Object']),
          equals('tListObject'));
      expect(TypeReflection.getConstantName('List', ['dynamic']),
          equals('tListDynamic'));
      expect(TypeReflection.getConstantName('List', ['String']),
          equals('tListString'));
      expect(
          TypeReflection.getConstantName('List', ['int']), equals('tListInt'));
      expect(TypeReflection.getConstantName('List', ['double']),
          equals('tListDouble'));
      expect(
          TypeReflection.getConstantName('List', ['num']), equals('tListNum'));
      expect(TypeReflection.getConstantName('List', ['bool']),
          equals('tListBool'));

      expect(TypeReflection.getConstantName('Map', ['String', 'Object']),
          equals('tMapStringObject'));
      expect(TypeReflection.getConstantName('Map', ['String', 'dynamic']),
          equals('tMapStringDynamic'));
      expect(TypeReflection.getConstantName('Map', ['String', 'String']),
          equals('tMapStringString'));
      expect(TypeReflection.getConstantName('Map', ['Object', 'Object']),
          equals('tMapObjectObject'));

      expect(TypeReflection.getConstantName('Set', ['Object']),
          equals('tSetObject'));
      expect(TypeReflection.getConstantName('Set', ['dynamic']),
          equals('tSetDynamic'));
      expect(TypeReflection.getConstantName('Set', ['String']),
          equals('tSetString'));
      expect(TypeReflection.getConstantName('Set', ['int']), equals('tSetInt'));

      expect(TypeReflection.getConstantName('Future', ['Object']),
          equals('tFutureObject'));
      expect(TypeReflection.getConstantName('Future', ['dynamic']),
          equals('tFutureDynamic'));
      expect(TypeReflection.getConstantName('Future', ['String']),
          equals('tFutureString'));
      expect(TypeReflection.getConstantName('Future', ['int']),
          equals('tFutureInt'));
      expect(TypeReflection.getConstantName('Future', ['bool']),
          equals('tFutureBool'));

      expect(TypeReflection.getConstantName('FutureOr', ['Object']),
          equals('tFutureOrObject'));
      expect(TypeReflection.getConstantName('FutureOr', ['dynamic']),
          equals('tFutureOrDynamic'));
      expect(TypeReflection.getConstantName('FutureOr', ['String']),
          equals('tFutureOrString'));
      expect(TypeReflection.getConstantName('FutureOr', ['int']),
          equals('tFutureOrInt'));
      expect(TypeReflection.getConstantName('FutureOr', ['bool']),
          equals('tFutureOrBool'));

      expect(TypeReflection.from(TypeReflection.tString),
          equals(TypeReflection.tString));
      expect(TypeReflection.from(TypeReflection.tInt),
          equals(TypeReflection.tInt));

      expect(TypeReflection.from(String), equals(TypeReflection.tString));
      expect(TypeReflection.from(int), equals(TypeReflection.tInt));

      expect(TypeReflection.from([List, String]),
          equals(TypeReflection.tListString));
      expect(TypeReflection.from([List, int]), equals(TypeReflection.tListInt));
      expect(TypeReflection.from([List, double]),
          equals(TypeReflection.tListDouble));

      expect(TypeReflection.from([Map, String, Object]),
          equals(TypeReflection.tMapStringObject));
      expect(TypeReflection.from([Map, String, String]),
          equals(TypeReflection.tMapStringString));

      expect(TypeReflection.tListDouble.equalsArgumentsTypes([double]), isTrue);
      expect(
          TypeReflection.tMapStringObject
              .equalsArgumentsTypes([String, Object]),
          isTrue);
      expect(
          TypeReflection.tMapStringString
              .equalsArgumentsTypes([String, String]),
          isTrue);

      expect(TypeReflection.tBool.isPrimitiveType, isTrue);
      expect(TypeReflection.tBool.isStringType, isFalse);
      expect(TypeReflection.tBool.isDoubleType, isFalse);
      expect(TypeReflection.tBool.isIntType, isFalse);
      expect(TypeReflection.tBool.isNumberType, isFalse);
      expect(TypeReflection.tBool.isNumericType, isFalse);
      expect(TypeReflection.tBool.isBoolType, isTrue);
      expect(TypeReflection.tBool.isCollectionType, isFalse);
      expect(TypeReflection.tBool.isIterableType, isFalse);
      expect(TypeReflection.tBool.isMapType, isFalse);

      expect(TypeReflection.tInt.isIntType, isTrue);
      expect(TypeReflection.tInt.isDoubleType, isFalse);
      expect(TypeReflection.tInt.isNumType, isFalse);
      expect(TypeReflection.tInt.isBigInt, isFalse);
      expect(TypeReflection.tInt.isNumberType, isTrue);
      expect(TypeReflection.tInt.isNumericType, isTrue);

      expect(TypeReflection.tDouble.isIntType, isFalse);
      expect(TypeReflection.tDouble.isDoubleType, isTrue);
      expect(TypeReflection.tDouble.isNumType, isFalse);
      expect(TypeReflection.tDouble.isBigInt, isFalse);
      expect(TypeReflection.tDouble.isNumberType, isTrue);
      expect(TypeReflection.tDouble.isNumericType, isTrue);

      expect(TypeReflection.tNum.isIntType, isFalse);
      expect(TypeReflection.tNum.isDoubleType, isFalse);
      expect(TypeReflection.tNum.isNumType, isTrue);
      expect(TypeReflection.tNum.isBigInt, isFalse);
      expect(TypeReflection.tNum.isNumberType, isTrue);
      expect(TypeReflection.tNum.isNumericType, isTrue);

      expect(TypeReflection.tBigInt.isIntType, isFalse);
      expect(TypeReflection.tBigInt.isDoubleType, isFalse);
      expect(TypeReflection.tBigInt.isNumType, isFalse);
      expect(TypeReflection.tBigInt.isBigInt, isTrue);
      expect(TypeReflection.tBigInt.isNumberType, isFalse);
      expect(TypeReflection.tBigInt.isNumericType, isTrue);

      expect(TypeReflection.tString.isIntType, isFalse);
      expect(TypeReflection.tString.isDoubleType, isFalse);
      expect(TypeReflection.tString.isNumType, isFalse);
      expect(TypeReflection.tString.isBigInt, isFalse);
      expect(TypeReflection.tString.isNumberType, isFalse);
      expect(TypeReflection.tString.isNumericType, isFalse);

      expect(TypeReflection.tList.isPrimitiveType, isFalse);
      expect(TypeReflection.tList.isStringType, isFalse);
      expect(TypeReflection.tList.isDoubleType, isFalse);
      expect(TypeReflection.tList.isIntType, isFalse);
      expect(TypeReflection.tList.isNumberType, isFalse);
      expect(TypeReflection.tList.isNumericType, isFalse);
      expect(TypeReflection.tList.isBoolType, isFalse);
      expect(TypeReflection.tList.isCollectionType, isTrue);
      expect(TypeReflection.tList.isIterableType, isTrue);
      expect(TypeReflection.tList.isMapType, isFalse);

      expect(TypeReflection.tMap.isPrimitiveType, isFalse);
      expect(TypeReflection.tMap.isStringType, isFalse);
      expect(TypeReflection.tMap.isDoubleType, isFalse);
      expect(TypeReflection.tMap.isIntType, isFalse);
      expect(TypeReflection.tMap.isNumberType, isFalse);
      expect(TypeReflection.tMap.isNumericType, isFalse);
      expect(TypeReflection.tMap.isBoolType, isFalse);
      expect(TypeReflection.tMap.isCollectionType, isTrue);
      expect(TypeReflection.tMap.isIterableType, isFalse);
      expect(TypeReflection.tMap.isMapType, isTrue);

      expect(TypeReflection.tMap.isOfType(Map), isTrue);
      expect(TypeReflection.tMapStringObject.isOfType(Map), isTrue);
      expect(TypeReflection.tMapStringObject.isOfType(Map, [String, Object]),
          isTrue);
      expect(TypeReflection.tMapStringObject.isOfType(Map, [String, String]),
          isFalse);
    });

    test('EnableReflection', () async {
      expect(
          ReflectionFactory()
              .hasRegisterClassReflection(TestEnumWithReflection),
          isFalse);

      expect(
          ReflectionFactory()
              .hasRegisterClassReflection(TestUserWithReflection),
          isFalse);

      var user =
          TestUserWithReflection.fields('Joe', 'joe@mail.com', '123', id: 1001);

      var userReflection = user.reflection;

      expect(userReflection.classType, equals(TestUserWithReflection));
      expect(userReflection.reflectedType, equals(TestUserWithReflection));
      expect(userReflection.className, equals('TestUserWithReflection'));
      expect(userReflection.reflectionName, equals('TestUserWithReflection'));
      expect(userReflection.languageVersion.toString(), isNotEmpty);
      expect(userReflection.reflectionFactoryVersion.toString(),
          equals(ReflectionFactory.VERSION));

      expect(userReflection.hasJsonNameAlias, isTrue);
      expect(userReflection.canCreateInstanceWithoutArguments, isTrue);

      {
        var allFields = userReflection.allFields();
        expect(allFields.every((f) => identical(f.object, user)), isTrue);
        expect(
            allFields.map((f) => f.name),
            equals([
              'axis',
              'email',
              'enabled',
              'hashCode',
              'id',
              'isEnabled',
              'isNotEnabled',
              'level',
              'name',
              'password'
            ]));

        var user2 = TestUserWithReflection.fields(
            'Joe2', 'joe2@mail.com', '1234',
            id: 1002);

        var allFields2 = userReflection.allFields(user2);
        expect(allFields2.every((f) => identical(f.object, user2)), isTrue);

        var allFieldsNoObj = userReflection.withoutObjectInstance().allFields();
        expect(allFieldsNoObj.every((f) => f.object == null), isTrue);
      }

      {
        var entityFields = userReflection.entityFields();
        expect(entityFields.every((f) => identical(f.object, user)), isTrue);
        expect(
            entityFields.map((f) => f.name),
            equals([
              'axis',
              'email',
              'enabled',
              'id',
              'isEnabled',
              'level',
              'name',
              'password'
            ]));

        var user2 = TestUserWithReflection.fields(
            'Joe2', 'joe2@mail.com', '1234',
            id: 1002);

        var entityFields2 = userReflection.entityFields(user2);
        expect(entityFields2.every((f) => identical(f.object, user2)), isTrue);

        var entityFieldsNoObj =
            userReflection.withoutObjectInstance().entityFields();
        expect(entityFieldsNoObj.every((f) => f.object == null), isTrue);
      }

      {
        var allMethods = userReflection.allMethods();
        expect(allMethods.every((f) => identical(f.object, user)), isTrue);
        expect(allMethods.map((f) => f.name),
            equals(['checkPassword', 'getField', 'setField', 'toString']));

        var user2 = TestUserWithReflection.fields(
            'Joe2', 'joe2@mail.com', '1234',
            id: 1002);

        var allMethods2 = userReflection.allMethods(user2);
        expect(allMethods2.every((f) => identical(f.object, user2)), isTrue);

        var allMethodsNoObj =
            userReflection.withoutObjectInstance().allMethods();
        expect(allMethodsNoObj.every((f) => f.object == null), isTrue);
      }

      expect(
          identical(userReflection.withoutObjectInstance(),
              userReflection.withoutObjectInstance()),
          isTrue);

      expect(userReflection.toString(),
          startsWith('ClassReflection{ class: TestUserWithReflection }'));

      expect(
          ReflectionFactory()
              .hasRegisterClassReflection(TestUserWithReflection),
          isTrue);

      expect(
          TestUserWithReflection$reflection.staticInstance
              .fromJson({'name': 'Foo', 'email': 'a@a.com', 'Password': '123'}),
          equals(TestUserWithReflection.fields('Foo', 'a@a.com', '123')));

      expect(
          TestUserWithReflection$reflection.staticInstance.fromJson({
            'name': 'Foo',
            'email': 'a@a.com',
            'password': '123',
            'foo': 123
          }),
          equals(TestUserWithReflection.fields('Foo', 'a@a.com', '123')));

      expect(
          TestUserWithReflection$reflection.staticInstance.fromJson({
            'name': 'Foo',
            'email': 'a@a.com',
            'password': '123',
            'level': 1001
          }),
          equals(TestUserWithReflection.fields('Foo', 'a@a.com', '123',
              level: 1001)));

      expect(
          TestUserWithReflection$reflection.staticInstance.fromJson({
            'name': 'Foo',
            'email': 'a@a.com',
            'password': '123',
            'thelevel': 1001
          }),
          equals(TestUserWithReflection.fields('Foo', 'a@a.com', '123',
              level: 1001)));

      expect(
          TestUserWithReflection.fields('Foo', 'a@a.com', '123').toJsonMap(),
          equals({
            'axis': 'x',
            'email': 'a@a.com',
            'enabled': true,
            'id': null,
            'isEnabled': true,
            'theLevel': null,
            'name': 'Foo',
            'password': '123'
          }));

      expect(
          TestUserWithReflection.fields('Foo', 'a@a.com', '123', id: 1001)
              .toJsonMap(),
          equals({
            'axis': 'x',
            'email': 'a@a.com',
            'enabled': true,
            'id': 1001,
            'isEnabled': true,
            'theLevel': null,
            'name': 'Foo',
            'password': '123'
          }));

      expect(
          TestUserWithReflection.fields('Foo', 'a@a.com', '123').toJson(),
          equals({
            'axis': 'x',
            'email': 'a@a.com',
            'enabled': true,
            'id': null,
            'isEnabled': true,
            'theLevel': null,
            'name': 'Foo',
            'password': '123'
          }));

      expect(
          TestUserWithReflection.fields('Foo', 'a@a.com', '123')
              .toJsonFromFields(),
          equals({
            'axis': 'x',
            'email': 'a@a.com',
            'enabled': true,
            'id': null,
            'isEnabled': true,
            'theLevel': null,
            'name': 'Foo',
            'password': '123'
          }));

      expect(
          TestUserWithReflection$reflection.staticInstance
              .createInstanceFromMap({
            'axis': TestEnumWithReflection.y,
            'email': 'b@a.com',
            'enabled': true,
            'id': null,
            'isEnabled': true,
            'theLevel': null,
            'name': 'Foo',
            'password': '123'
          })?.toJsonFromFields(),
          equals({
            'axis': 'y',
            'email': 'b@a.com',
            'enabled': true,
            'id': null,
            'isEnabled': true,
            'theLevel': null,
            'name': 'Foo',
            'password': '123'
          }));

      expect(
          TestUserWithReflection$reflection.staticInstance
              .createInstanceFromMap({
            'axis': TestEnumWithReflection.y,
            'email': 'b@a.com',
            'enabled': true,
            'id': null,
            'isEnabled': true,
            'theLevel': null,
            'name': 'Foo',
            'password': '123',
            'extraField1': 123456,
            'extraField2': 123456,
          })?.toJsonFromFields(),
          equals({
            'axis': 'y',
            'email': 'b@a.com',
            'enabled': true,
            'id': null,
            'isEnabled': true,
            'theLevel': null,
            'name': 'Foo',
            'password': '123'
          }));

      expect(TestUserWithReflection$reflection.staticInstance.hasFinalField,
          isTrue);

      expect(TestUserWithReflection$reflection.staticInstance.hasMethodToJson,
          isFalse);

      expect(
          TestUserWithReflection$reflection
              .staticInstance.hasDefaultConstructor,
          isTrue);

      expect(
          TestUserWithReflection$reflection.staticInstance.hasEmptyConstructor,
          isFalse);

      expect(
          TestUserWithReflection$reflection
              .staticInstance.hasFieldWithoutSetter,
          isTrue);

      expect(
          TestUserWithReflection$reflection
              .staticInstance.hasNoRequiredArgsConstructor,
          isFalse);

      expect(
          TypeInfo.from(
              TestUserWithReflection$reflection.staticInstance.field('axis')!),
          equals(TypeInfo.from(TestEnumWithReflection)));

      expect(
          TypeInfo.from(TestUserWithReflection$reflection.staticInstance
              .field('axis')!
              .type),
          equals(TypeInfo.from(TestEnumWithReflection)));

      expect(
          TypeInfo.from(TestUserWithReflection$reflection.staticInstance
              .method('checkPassword')!
              .allParameters[0]),
          equals(TypeInfo.from(String)));

      {
        var t =
            TypeInfo<TestUserWithReflection>.fromType(TestUserWithReflection);

        var tList = t.toListType();

        expect(
            tList,
            equals(TypeInfo<List<TestUserWithReflection>>.fromListType(
                TestUserWithReflection)));

        expect(
            tList.castList(<Object>[
              TestUserWithReflection.fields('Joe', 'joe@mail.com', '123')
            ]),
            allOf(
                equals(<TestUserWithReflection>[
                  TestUserWithReflection.fields('Joe', 'joe@mail.com', '123')
                ]),
                isA<List<TestUserWithReflection>>()));

        var tSet = t.toSetType();

        expect(
            tSet,
            equals(TypeInfo<Set<TestUserWithReflection>>.fromSetType(
                TestUserWithReflection)));

        expect(
            tSet.castSet(<Object>{
              TestUserWithReflection.fields('Joe', 'joe@mail.com', '123')
            }),
            allOf(
                equals(<TestUserWithReflection>{
                  TestUserWithReflection.fields('Joe', 'joe@mail.com', '123')
                }),
                isA<Set<TestUserWithReflection>>()));

        var tItr = t.toIterableType();

        expect(
            tItr,
            equals(TypeInfo<Iterable<TestUserWithReflection>>.fromIterableType(
                TestUserWithReflection)));

        expect(
            tItr.castIterable(<Object>[
              TestUserWithReflection.fields('Joe', 'joe@mail.com', '123')
            ]),
            allOf(
                equals(<TestUserWithReflection>[
                  TestUserWithReflection.fields('Joe', 'joe@mail.com', '123')
                ]),
                isA<Iterable<TestUserWithReflection>>()));

        var tMapK = t.toMapKeyType<String>();

        expect(
            tMapK,
            equals(TypeInfo<Map<TestUserWithReflection, String>>.fromMapType(
                TestUserWithReflection, String)));

        var mapK = tMapK.castMap(<Object, Object>{
          TestUserWithReflection.fields('Joe', 'joe@mail.com', '123'): 'a'
        });

        expect(
            mapK,
            allOf(
                equals(<TestUserWithReflection, String>{
                  TestUserWithReflection.fields('Joe', 'joe@mail.com', '123'):
                      'a'
                }),
                isA<Map<TestUserWithReflection, String>>()),
            reason: '!!! ${mapK.runtimeType}');

        var tMapV = t.toMapValueType<String>();

        expect(tMapV,
            equals(TypeInfo.fromMapType(String, TestUserWithReflection)));

        var mapV = tMapV.castMap(<Object, Object>{
          'a': TestUserWithReflection.fields('Joe', 'joe@mail.com', '123')
        });

        expect(
            mapV,
            allOf(
                equals(<String, TestUserWithReflection>{
                  'a': TestUserWithReflection.fields(
                      'Joe', 'joe@mail.com', '123')
                }),
                isA<Map<String, TestUserWithReflection>>()));

        var tMapKV1 = TypeInfo<
                Map<TestUserWithReflection,
                    TestAddressWithReflection>>.fromMapType(
            TestUserWithReflection, TestAddressWithReflection);

        var mapKV1 = tMapKV1.castMap(<Object, Object>{
          TestUserWithReflection.fields('Joe', 'joe@mail.com', '123'):
              TestAddressWithReflection.withCity('NY', city: 'New York')
        });

        expect(
            mapKV1,
            allOf(
                equals(<TestUserWithReflection, TestAddressWithReflection>{
                  TestUserWithReflection.fields('Joe', 'joe@mail.com', '123'):
                      TestAddressWithReflection.withCity('NY', city: 'New York')
                }),
                isA<Map<TestUserWithReflection, TestAddressWithReflection>>()));

        var tMapKV2 = TypeInfo<
                Map<TestAddressWithReflection,
                    TestAddressWithReflection>>.fromMapType(
            TestAddressWithReflection, TestAddressWithReflection);

        var mapKV2 = tMapKV2.castMap(<Object, Object>{
          TestAddressWithReflection.withCity('CA', city: 'Los Angeles'):
              TestAddressWithReflection.withCity('NY', city: 'New York')
        });

        expect(
            mapKV2,
            allOf(
                equals(<TestAddressWithReflection, TestAddressWithReflection>{
                  TestAddressWithReflection.withCity('CA', city: 'Los Angeles'):
                      TestAddressWithReflection.withCity('NY', city: 'New York')
                }),
                isA<
                    Map<TestAddressWithReflection,
                        TestAddressWithReflection>>()));

        var tMapK2 = TypeInfo<Map<TestUserWithReflection, dynamic>>.fromMapType(
            TestUserWithReflection, TypeInfo.tDynamic);

        var mapK2 = TestUserWithReflection$reflection.staticInstance
            .castMap(<Object, Object>{
          TestUserWithReflection.fields('Joe', 'joe@mail.com', '123'):
              TestAddressWithReflection.withCity('NY', city: 'New York')
        }, tMapK2);

        expect(
            mapK2,
            allOf(
                equals(<TestUserWithReflection, dynamic>{
                  TestUserWithReflection.fields('Joe', 'joe@mail.com', '123'):
                      TestAddressWithReflection.withCity('NY', city: 'New York')
                }),
                isA<Map<TestUserWithReflection, dynamic>>()));

        var tMapV2 = TypeInfo<Map<TestUserWithReflection, dynamic>>.fromMapType(
            TypeInfo.tDynamic, TestUserWithReflection);

        var mapV2 = TestUserWithReflection$reflection.staticInstance
            .castMap(<Object, Object>{
          TestAddressWithReflection.withCity('NY', city: 'New York'):
              TestUserWithReflection.fields('Joe', 'joe@mail.com', '123')
        }, tMapV2);

        expect(
            mapV2,
            allOf(
                equals(<dynamic, TestUserWithReflection>{
                  TestAddressWithReflection.withCity('NY', city: 'New York'):
                      TestUserWithReflection.fields(
                          'Joe', 'joe@mail.com', '123')
                }),
                isA<Map<dynamic, TestUserWithReflection>>()));

        var tMapK3 = TypeInfo<Map<String, TestUserWithReflection>>.fromMapType(
            TypeInfo.tString, TestUserWithReflection);

        var mapK3 = TestUserWithReflection$reflection.staticInstance
            .castMapKeys(<Object, Object>{
          'a': TestUserWithReflection.fields('Joe', 'joe@mail.com', '123')
        }, tMapK3);

        expect(
            mapK3,
            allOf(
                equals(<String, dynamic>{
                  'a': TestUserWithReflection.fields(
                      'Joe', 'joe@mail.com', '123')
                }),
                isA<Map<String, dynamic>>()));

        var tMapV3 = TypeInfo<Map<TestUserWithReflection, String>>.fromMapType(
            TestUserWithReflection, TypeInfo.tString);

        var mapV3 = TestUserWithReflection$reflection.staticInstance
            .castMapValues(<Object, Object>{
          TestUserWithReflection.fields('Joe', 'joe@mail.com', '123'): 'a'
        }, tMapV3);

        expect(
            mapV3,
            allOf(
                equals(<dynamic, String>{
                  TestUserWithReflection.fields('Joe', 'joe@mail.com', '123'):
                      'a'
                }),
                isA<Map<dynamic, String>>()));
      }

      expect(
          TestUserWithReflection$reflection.staticInstance
              .siblingsClassReflection(),
          isNotEmpty);

      expect(
          TestUserWithReflection$reflection.staticInstance
              .siblingClassReflectionFor<TestUserWithReflection>(),
          isNotNull);

      expect(
          TestUserWithReflection$reflection.staticInstance
              .siblingReflectionFor<TestUserWithReflection>(),
          isNotNull);

      expect(
          userReflection.siblingsClassReflection().map((e) => e.classType),
          equals([
            TestUserWithReflection,
            TestAddressWithReflection,
            TestCompanyWithReflection,
            TestFranchiseWithReflection,
            TestDataWithReflection,
            TestDomainWithReflection,
            TestOpWithReflection,
            TestOpAWithReflection,
            TestOpBWithReflection,
            TestTransactionWithReflection,
            TestName,
            TestEmpty,
          ]));

      expect(
          userReflection
              .siblingsClassReflection()
              .sorted()
              .map((e) => e.classType),
          equals([
            TestEmpty,
            TestTransactionWithReflection,
            TestFranchiseWithReflection,
            TestDataWithReflection,
            TestName,
            TestOpWithReflection,
            TestOpAWithReflection,
            TestAddressWithReflection,
            TestCompanyWithReflection,
            TestOpBWithReflection,
            TestDomainWithReflection,
            TestUserWithReflection,
          ]));

      expect(
          TestEnumWithReflection$from('x'), equals(TestEnumWithReflection.x));

      expect(
          TestEnumWithReflection$from('Y'), equals(TestEnumWithReflection.y));

      expect(
          TestEnumWithReflection$from('z'), equals(TestEnumWithReflection.z));

      expect(
          TestEnumWithReflection$from('Z'), equals(TestEnumWithReflection.Z));

      expect(TestEnumWithReflection$from('w'), isNull);

      expect(TestEnumWithReflection.x.reflection.enumName,
          equals('TestEnumWithReflection'));
      expect(TestEnumWithReflection.x.reflection.reflectionName,
          equals('TestEnumWithReflection'));

      expect(TestEnumWithReflection.x.reflection.enumType,
          equals(TestEnumWithReflection));
      expect(TestEnumWithReflection.x.reflection.reflectedType,
          equals(TestEnumWithReflection));

      expect(TestEnumWithReflection.x.reflection.name(), equals('x'));
      expect(TestEnumWithReflection.Z.reflection.name(), equals('Z'));

      expect(TestEnumWithReflection.x.reflection.toJson(), equals('x'));

      expect(
          TestEnumWithReflection.x.reflection.toJsonEncoded(), equals('"x"'));

      expect(TestEnumWithReflection.x.reflection.toJsonMap(),
          equals({'name': 'x', 'index': 0}));

      expect(TestEnumWithReflection$reflection.staticInstance.fromJson('x'),
          equals(TestEnumWithReflection.x));

      expect(
          TestEnumWithReflection$reflection.staticInstance
              .fromJsonEncoded('"Z"'),
          equals(TestEnumWithReflection.Z));

      expect(
          TestEnumWithReflection$reflection.staticInstance.siblingsReflection(),
          isNotEmpty);

      expect(
          TestEnumWithReflection$reflection.staticInstance
              .siblingsEnumReflection()
              .length,
          equals(1));

      expect(
          TestEnumWithReflection$reflection.staticInstance
              .siblingEnumReflectionFor<TestEnumWithReflection>(),
          isNotNull);

      expect(
          TestEnumWithReflection$reflection.staticInstance
              .getIndex(TestEnumWithReflection.Z),
          equals(3));

      expect(TestEnumWithReflection$reflection().values,
          equals(TestEnumWithReflection.values));

      expect(TestEnumWithReflection$reflection().fieldsNames,
          equals(['Z', 'x', 'y', 'z']));

      expect(TestEnumWithReflection$reflection(TestEnumWithReflection.x).name(),
          equals('x'));

      expect(
          TestEnumWithReflection$reflection(TestEnumWithReflection.x)
              .name(TestEnumWithReflection.y),
          equals('y'));

      expect(TestEnumWithReflection$reflection.staticInstance.fromJson('x'),
          equals(TestEnumWithReflection.x));

      expect(TestEnumWithReflection$reflection.staticInstance.fromJson('y'),
          equals(TestEnumWithReflection.y));

      expect(
          () => TestEnumWithReflection$reflection.staticInstance.fromJson('w'),
          throwsA(isA<StateError>()
              .having((e) => e.message, 'Bad JSON', contains('for JSON: w'))));

      expect(
          () => TestEnumWithReflection$reflection.staticInstance.fromJson(null),
          throwsA(isA<StateError>()
              .having((e) => e.message, 'Null JSON', contains('Null JSON'))));

      expect(
          ReflectionFactory()
              .getRegisterEnumReflection(TestEnumWithReflection)!
              .enumType,
          equals(TestEnumWithReflection));

      expect(
          ReflectionFactory()
              .getRegisterEnumReflectionByName('TestEnumWithReflection')!
              .enumType,
          equals(TestEnumWithReflection));

      expect(
          ReflectionFactory()
              .getRegisterClassReflection(TestUserWithReflection)!
              .classType,
          equals(TestUserWithReflection));

      expect(
          ReflectionFactory()
              .getRegisterClassReflectionByName('TestUserWithReflection')!
              .classType,
          equals(TestUserWithReflection));

      expect(userReflection.supperTypes, isEmpty);

      expect(userReflection.constructorsNames, equals(['', 'fields']));

      expect(userReflection.allConstructors().length, equals(2));

      expect(
          (userReflection.allConstructors().toList()..sort())
              .map((e) => e.name),
          equals(['', 'fields']));

      {
        var constructorDefault = userReflection.constructor('');
        expect(constructorDefault, isNotNull);

        expect(constructorDefault!.name, isEmpty);
        expect(constructorDefault.isNamed, isFalse);

        expect(constructorDefault.isDefaultConstructor, isTrue);
        expect(constructorDefault.isStatic, isTrue);

        expect(constructorDefault.hasNoParameters, isTrue);
        expect(constructorDefault.normalParameters, isEmpty);
        expect(constructorDefault.optionalParameters, isEmpty);
        expect(constructorDefault.namedParameters, isEmpty);

        expect(constructorDefault.parametersLength, equals(0));
        expect(constructorDefault.positionalParametersLength, equals(0));
        expect(constructorDefault.requiredParametersLength, equals(0));
      }

      {
        var constructorFields = userReflection.constructor('fields');
        expect(constructorFields, isNotNull);

        expect(constructorFields!.name, isNotEmpty);
        expect(constructorFields.isNamed, isTrue);

        expect(constructorFields.isStatic, isTrue);

        expect(constructorFields.hasNoParameters, isFalse);
        expect(constructorFields.normalParameters.length, equals(3));
        expect(constructorFields.optionalParameters, isEmpty);
        expect(constructorFields.namedParameters.keys,
            equals(['axis', 'enabled', 'id', 'level']));

        expect(constructorFields.parametersLength, equals(7));
        expect(constructorFields.positionalParametersLength, equals(3));
        expect(constructorFields.requiredParametersLength, equals(3));

        expect(constructorFields.getParameterByName('name'), isNotNull);
        expect(constructorFields.getParameterByName('enabled'), isNotNull);
        expect(constructorFields.getParameterByName('foo'), isNull);

        expect(constructorFields.getParameterByIndex(0)?.name, equals('name'));

        expect(constructorFields.getParameterByIndex(1)?.name, equals('email'));
        expect(constructorFields.getParameterByIndex(1)?.jsonName,
            equals('email'));
        expect(constructorFields.getParameterByIndex(1)?.hasJsonNameAlias,
            isFalse);

        expect(constructorFields.getParameterByIndex(2)?.name,
            equals('passphrase'));
        expect(constructorFields.getParameterByIndex(2)?.jsonName,
            equals('password'));
        expect(
            constructorFields.getParameterByIndex(2)?.hasJsonNameAlias, isTrue);

        expect(constructorFields.getParameterByIndex(3)?.name, equals('axis'));
        expect(
            constructorFields.getParameterByIndex(4)?.name, equals('enabled'));
        expect(constructorFields.getParameterByIndex(5)?.name, equals('id'));
        expect(constructorFields.getParameterByIndex(6)?.name, equals('level'));
        expect(constructorFields.getParameterByIndex(7)?.name, isNull);
      }

      {
        expect(userReflection.hasDefaultConstructor, isTrue);
        expect(userReflection.hasEmptyConstructor, isFalse);

        expect(userReflection.createInstanceWithEmptyConstructor(), isNull);

        var user = userReflection.createInstanceWithDefaultConstructor();
        expect(user, isNotNull);

        expect(user!.name, isEmpty);
        expect(user.email, isNull);
        expect(user.password, isEmpty);
        expect(user.axis, equals(TestEnumWithReflection.x));

        expect(user.toJson(), userReflection.createInstance()!.toJson());
      }

      {
        expect(TestEnumWithReflection.x.enumName, equals('x'));
        expect(TestEnumWithReflection.y.enumName, equals('y'));
        expect(TestEnumWithReflection.z.enumName, equals('z'));
        expect(TestEnumWithReflection.Z.enumName, equals('Z'));
      }

      expect(
          userReflection.fieldsNames,
          equals([
            'axis',
            'email',
            'enabled',
            'hashCode',
            'id',
            'isEnabled',
            'isNotEnabled',
            'level',
            'name',
            'password'
          ]));
      expect(userReflection.allFields().map((e) => e.name),
          equals(userReflection.fieldsNames));

      expect(
          userReflection
              .allFields()
              .where((e) => e.hasSetter)
              .map((e) => e.name),
          equals(['axis', 'email', 'enabled', 'id', 'level', 'password']));

      expect(userReflection.fieldsWhere((f) => f.nullable).map((f) => f.name),
          equals(['email', 'id', 'level']));

      expect(
          userReflection
              .fieldsWhere((f) => f.type.isBoolType)
              .map((e) => e.name),
          equals(['enabled', 'isEnabled', 'isNotEnabled']));

      expect(userReflection.staticFieldsNames,
          equals(['version', 'withReflection']));
      expect(
          userReflection.allStaticFields().map((e) => e.name),
          equals(
            userReflection.staticFieldsNames,
          ));

      expect(
          userReflection
              .staticFieldsWhere((f) => f.type.isBoolType)
              .map((f) => f.name),
          equals(['withReflection']));

      expect(userReflection.staticFieldsWhere((f) => f.type.isStringType),
          isEmpty);

      expect(userReflection.methodsNames,
          equals(['checkPassword', 'getField', 'setField', 'toString']));
      expect(userReflection.allMethods().map((e) => e.name),
          equals(userReflection.methodsNames));

      expect(
          userReflection
              .methodsWhere((m) => m.equalsNormalParametersTypes([String]))
              .map((e) => e.name),
          equals(['checkPassword', 'getField']));

      expect(
          userReflection
              .methodsWhere((m) => m.equalsOptionalParametersTypes([dynamic]))
              .map((e) => e.name),
          equals(['getField']));

      expect(
          userReflection
              .methodsWhere((m) => m.hasNoParameters)
              .map((e) => e.name),
          ['toString']);

      expect(userReflection.staticMethodsNames, equals(['isVersion']));
      expect(userReflection.allStaticMethods().map((e) => e.name),
          equals(userReflection.staticMethodsNames));

      expect(
          userReflection
              .staticMethodsWhere(
                  (m) => m.equalsNormalParametersTypes([double]))
              .map((e) => e.name),
          equals(['isVersion']));

      expect(
          userReflection
              .staticMethodsWhere(
                  (m) => m.normalParametersTypeReflection[0].isPrimitiveType)
              .length,
          equals(1));

      expect(
          userReflection.staticMethodsWhere((m) => m.hasNoParameters), isEmpty);

      expect(userReflection.getField('name'), equals('Joe'));
      expect(userReflection.getField('email'), equals('joe@mail.com'));

      expect(userReflection.getField('password'), equals('123'));
      userReflection.setField('password', 'abc');
      expect(userReflection.getField('password'), equals('abc'));

      var field = userReflection.field('email')!;

      expect(field.className, equals('TestUserWithReflection'));
      expect(field.isStatic, isFalse);
      expect(field.name, equals('email'));
      expect(field.type, equals(TypeReflection.tString));
      expect(field.isFinal, isFalse);
      expect(
          field.toString(),
          startsWith(
              'FieldReflection{ class: TestUserWithReflection, name: email, type: String?, static: false,'));

      expect(field.get(), equals('joe@mail.com'));
      field.set('joe@mail.net');
      expect(field.get(), equals('joe@mail.net'));

      expect(userReflection.getStaticField('version'), equals(1.1));
      expect(userReflection.getStaticField('withReflection'), isTrue);

      expect(() {
        userReflection.setStaticField('withReflection', false);
      }, throwsStateError);

      expect(userReflection.getStaticField('withReflection'), isTrue);

      var staticField = userReflection.staticField('version')!;

      expect(staticField.className, equals('TestUserWithReflection'));
      expect(staticField.isStatic, isTrue);
      expect(staticField.name, equals('version'));
      expect(staticField.type, equals(TypeReflection.tDouble));
      expect(staticField.isFinal, isTrue);
      expect(
          staticField.toString(),
          startsWith(
              'FieldReflection{ class: TestUserWithReflection, name: version, type: double, static: true,'));

      expect(staticField.get(), equals(1.1));

      expect(userReflection.invokeMethod('checkPassword', ['abc']), isTrue);
      expect(userReflection.invokeMethod('checkPassword', ['123']), isFalse);

      expect(userReflection.invokeStaticMethod('isVersion', [1.1]), isTrue);
      expect(userReflection.invokeStaticMethod('isVersion', [2.0]), isFalse);

      var user2 = TestUserWithReflection.fields('Joe', 'smith@mail.com', 'xyz');
      expect(userReflection.invokeMethodWith('checkPassword', user2, ['xyz']),
          isTrue);
      expect(userReflection.invokeMethodWith('checkPassword', user2, ['abc']),
          isFalse);

      var method = userReflection.method('checkPassword')!;

      expect(method.className, equals('TestUserWithReflection'));
      expect(method.isStatic, isFalse);
      expect(method.name, equals('checkPassword'));
      expect(method.hasNoParameters, isFalse);
      expect(method.normalParameters.length, equals(1));
      expect(
          method.normalParameters[0],
          equals(ParameterReflection(
              TypeReflection.tString, 'password', false, true, null, null)));
      expect(method.normalParametersTypes.length, equals(1));
      expect(method.normalParametersTypes[0], equals(String));
      expect(method.normalParametersNames.length, equals(1));
      expect(method.normalParametersNames[0], equals('password'));
      expect(
          method.toString(),
          startsWith(
              'MethodReflection{ class: TestUserWithReflection, name: checkPassword, returnType: bool, static: false,'));

      expect(method.normalParametersTypeReflection,
          equals([TypeReflection.tString]));
      expect(method.normalParametersTypes, equals([String]));
      expect(method.normalParameters.length, equals(1));

      expect(method.optionalParametersTypeReflection, isEmpty);
      expect(method.optionalParametersTypes, isEmpty);
      expect(method.optionalParameters, isEmpty);

      expect(method.namedParametersTypeReflection, isEmpty);
      expect(method.namedParametersTypes, isEmpty);
      expect(method.namedParameters, isEmpty);

      expect(method.allParameters.toNames(), equals(['password']));
      expect(method.allParameters.whereNullable(), isEmpty);
      expect(method.allParameters.whereRequired().length, equals(1));
      expect(method.allParameters.toTypes(), equals([String]));
      expect(method.allParameters.toTypeReflections().map((e) => e.type),
          equals([String]));

      expect(
          method.allParameters.map((e) => e.type).toTypes(), equals([String]));

      var allFields = userReflection.allFields();
      expect(
          allFields.toNames(),
          equals([
            'axis',
            'email',
            'enabled',
            'hashCode',
            'id',
            'isEnabled',
            'isNotEnabled',
            'level',
            'name',
            'password'
          ]));
      expect(allFields.whereFinal().toNames(), equals(['name']));
      expect(allFields.whereNullable().toNames(),
          equals(['email', 'id', 'level']));
      expect(
          allFields.toTypes(),
          equals([
            TestEnumWithReflection,
            String,
            bool,
            int,
            int,
            bool,
            bool,
            int,
            String,
            String
          ]));

      var allStaticFields = userReflection.allStaticFields();
      expect(allStaticFields.toNames(), equals(['version', 'withReflection']));
      expect(allStaticFields.whereStatic().toNames(),
          equals(['version', 'withReflection']));

      var allMethods = userReflection.allMethods();
      expect(allMethods.toNames(),
          equals(['checkPassword', 'getField', 'setField', 'toString']));
      expect(
          allMethods.toReturnTypeReflections(),
          equals([
            TypeReflection.tBool,
            TypeReflection.tDynamic,
            TypeReflection.tVoid,
            TypeReflection.tString
          ]));

      expect(allMethods.toReturnTypes(),
          equals([bool, dynamic, TypeInfo.tVoid.type, String]));
      expect(allMethods.whereStatic(), isEmpty);

      var allStaticMethods = userReflection.allStaticMethods();
      expect(allStaticMethods.whereStatic().toNames(), equals(['isVersion']));

      var staticMethod = userReflection.staticMethod('isVersion')!;
      expect(staticMethod.className, equals('TestUserWithReflection'));
      expect(staticMethod.isStatic, isTrue);
      expect(staticMethod.name, equals('isVersion'));
      expect(staticMethod.hasNoParameters, isFalse);
      expect(staticMethod.normalParameters.length, equals(1));
      expect(
          staticMethod.normalParameters[0],
          equals(ParameterReflection(
              TypeReflection.tDouble, 'ver', false, true, null, null)));
      expect(staticMethod.normalParametersNames.length, equals(1));
      expect(staticMethod.normalParametersNames[0], equals('ver'));
      expect(
          staticMethod.toString(),
          startsWith(
              'MethodReflection{ class: TestUserWithReflection, name: isVersion, returnType: bool, static: true,'));

      var fieldResolver = userReflection.fieldResolver('email');
      expect(fieldResolver.isResolved, isFalse);
      expect(fieldResolver.get()!.withObject(user2).get(),
          equals('smith@mail.com'));
      expect(fieldResolver.isResolved, isTrue);
      fieldResolver.reset();
      expect(fieldResolver.isResolved, isFalse);
      expect(fieldResolver.get()!.withObject(user2).get(),
          equals('smith@mail.com'));
      expect(fieldResolver.isResolved, isTrue);

      expect(
          userReflection
              .staticFieldResolver('version')
              .get()!
              .withObject(user2)
              .get(),
          equals(1.1));

      expect(
          userReflection
              .methodResolver('checkPassword')
              .get()!
              .withObject(user2)
              .invoke(['xyz']),
          isTrue);

      expect(
          userReflection
              .staticMethodResolver('isVersion')
              .get()!
              .withObject(user2)
              .invoke([1.1]),
          isTrue);

      var domainReflection = TestDomainWithReflection$reflection.staticInstance;

      expect(domainReflection.supperTypes, isEmpty);

      expect(
          domainReflection.fieldsNames,
          equals([
            'domainFunction',
            'extraFunction',
            'hashCode',
            'name',
            'suffix'
          ]));
      expect(domainReflection.methodsNames,
          equals(['toJson', 'toString', 'typedFunction']));
      expect(
          domainReflection.constructorsNames, equals(['', 'named', 'parse']));

      {
        var constructor = domainReflection.constructor('named')!;

        expect(constructor.allParametersNames,
            equals(['domainFunction', 'extraFunction', 'name', 'suffix']));

        var parameterName = constructor.namedParameters['name']!;
        var parameterSuffix = constructor.namedParameters['suffix']!;

        expect(parameterName.required, isTrue);
        expect(parameterName.nullable, isFalse);
        expect(parameterName.type, equals(TypeReflection.tString));

        expect(parameterSuffix.required, isFalse);
        expect(parameterSuffix.nullable, isFalse);
        expect(parameterSuffix.type, equals(TypeReflection.tString));
      }

      {
        var method = domainReflection.method('typedFunction')!;

        expect(method.parametersLength, equals(2));
        expect(method.allParametersNames, equals(['f', 'x']));

        var parameterF = method.normalParameters[0];
        var parameterX = method.normalParameters[1];

        expect(parameterF.name, equals('f'));
        expect(parameterF.type.type, equals(TypedFunction));
        expect(parameterF.type.argumentsLength, equals(1));

        expect(parameterX.name, equals('x'));
        expect(parameterX.type.type, equals(dynamic));
        expect(parameterX.type.argumentsLength, equals(0));
      }

      var opReflection = TestOpWithReflection$reflection.staticInstance;
      var opAReflection = TestOpAWithReflection$reflection.staticInstance;
      var opBReflection = TestOpBWithReflection$reflection.staticInstance;

      expect(opReflection.supperTypes, equals([WithValue]));
      expect(
          opAReflection.supperTypes, equals([TestOpWithReflection, WithValue]));
      expect(
          opBReflection.supperTypes, equals([TestOpWithReflection, WithValue]));

      expect(opReflection.fieldsNames, equals(['type', 'value']));
      expect(opAReflection.fieldsNames, equals(['type', 'value']));
      expect(opBReflection.fieldsNames, equals(['amount', 'type', 'value']));

      expect(
          opAReflection
              .fieldsWhere((m) => m.declaringType == TestOpWithReflection)
              .map((e) => e.name),
          equals(['type']));

      expect(
          opAReflection
              .fieldsWhere((m) => m.declaringType == TestOpAWithReflection)
              .map((e) => e.name),
          equals(['value']));

      expect(opReflection.staticFieldsNames, equals(['staticField']));
      expect(opAReflection.staticFieldsNames, equals(['staticFieldA']));
      expect(opBReflection.staticFieldsNames, isEmpty);

      expect(opReflection.methodsNames, equals(['isEmptyType']));
      expect(opAReflection.methodsNames, equals(['isEmptyType', 'methodA']));
      expect(opBReflection.methodsNames, equals(['isEmptyType', 'methodB']));

      expect(
          opAReflection
              .methodsWhere((m) => m.declaringType == TestOpWithReflection)
              .map((e) => e.name),
          equals(['isEmptyType']));

      expect(
          opAReflection
              .methodsWhere((m) => m.declaringType == TestOpAWithReflection)
              .map((e) => e.name),
          equals(['methodA']));

      expect(opReflection.staticMethodsNames, equals(['staticMethod']));
      expect(opAReflection.staticMethodsNames, isEmpty);
      expect(opBReflection.staticMethodsNames, equals(['staticMethodB']));

      expect(
          userReflection.toJson(),
          equals({
            'axis': 'x',
            'email': 'joe@mail.net',
            'enabled': true,
            'id': 1001,
            'isEnabled': true,
            'theLevel': null,
            'name': 'Joe',
            'password': 'abc'
          }));
      expect(
          userReflection.toJsonEncoded(),
          equals(
              '{"axis":"x","email":"joe@mail.net","enabled":true,"id":1001,"isEnabled":true,"theLevel":null,"name":"Joe","password":"abc"}'));

      expect(
          ReflectionFactory.toJsonEncodable(user),
          equals({
            'axis': 'x',
            'email': 'joe@mail.net',
            'enabled': true,
            'id': 1001,
            'isEnabled': true,
            'theLevel': null,
            'name': 'Joe',
            'password': 'abc'
          }));

      var userDecoded = TestUserWithReflection$fromJsonEncoded(
          '{"axis":"y","email":null,"enabled":false,"id":1002,"isEnabled":false,"level":123,"name":"Joe","password":"abc"}');

      expect(
          ReflectionFactory.toJsonEncodable(userDecoded),
          equals({
            'axis': 'y',
            'email': null,
            'enabled': false,
            'id': 1002,
            'isEnabled': false,
            'theLevel': 123,
            'name': 'Joe',
            'password': 'abc'
          }));

      expect(ReflectionFactory.toJsonEncodable(TestAddress('NY', 'New York')),
          equals({'state': 'NY', 'city': 'New York'}));

      expect(
          ReflectionFactory.toJsonEncodable(TestAddress('NY', 'New York'),
              toEncodable: (o) => 'wow'),
          equals('wow'));

      var userStaticReflection = TestUserWithReflection$reflection();

      expect(
          userReflection.runtimeType, equals(userStaticReflection.runtimeType));

      expect(userStaticReflection.classType, equals(TestUserWithReflection));

      expect(userStaticReflection.getStaticField('version'), equals(1.1));
      expect(userStaticReflection.getStaticField('withReflection'), isTrue);

      {
        final fieldEmail = userReflection.field('email')!;

        expect(user.email, equals('joe@mail.net'));

        fieldEmail.set('some@mail.com');
        expect(user.email, equals('some@mail.com'));

        fieldEmail.setNullable('some2@mail.com');
        expect(user.email, equals('some2@mail.com'));

        fieldEmail.setNullable(null);
        expect(user.email, isNull);

        fieldEmail.set('joe@mail.net');
        expect(user.email, equals('joe@mail.net'));

        var user2 = TestUserWithReflection.fields(
            'Joe Thims', 'joetm@mail.net', '987',
            id: 2002);

        expect(user.email, equals('joe@mail.net'));
        expect(user2.email, equals('joetm@mail.net'));

        expect(fieldEmail.get(), equals('joe@mail.net'));
        expect(fieldEmail.getFor(user2), equals('joetm@mail.net'));

        fieldEmail.setFor(user2, 'joetm1@mail.com');
        expect(user.email, equals('joe@mail.net'));
        expect(user2.email, equals('joetm1@mail.com'));

        fieldEmail.setNullableFor(user2, 'joetm2@mail.com');
        expect(user.email, equals('joe@mail.net'));
        expect(user2.email, equals('joetm2@mail.com'));
        expect(fieldEmail.getFor(user2), equals('joetm2@mail.com'));
      }

      {
        final fieldPassword = userReflection.field('password')!;

        expect(user.password, equals('abc'));

        fieldPassword.set('p0987');
        expect(user.password, equals('p0987'));

        fieldPassword.setNullable('p09877');
        expect(user.password, equals('p09877'));

        expect(
            () => fieldPassword.setNullable(null),
            throwsA(isA<ArgumentError>().having((e) => e.message, 'message',
                contains("can't be set to `null`"))));

        expect(user.password, equals('p09877'));

        fieldPassword.set('abc');
        expect(user.password, equals('abc'));
      }

      var address =
          TestAddressWithReflection.withCity('CA', city: 'Los Angeles');
      var addressReflection = address.reflection;

      expect(addressReflection, isNotNull);
      expect(addressReflection.hasJsonNameAlias, isFalse);
      expect(addressReflection.canCreateInstanceWithoutArguments, isTrue);
      expect(addressReflection.fieldsNames,
          equals(['city', 'hashCode', 'id', 'state']));
      expect(addressReflection.methodsNames, equals(['toJson', 'toString']));
      expect(addressReflection.constructorsNames,
          equals(['empty', 'simple', 'withCity']));

      expect(ReflectionFactory.toJsonEncodable(address),
          equals({'state': 'CA', 'city': 'Los Angeles'}));

      expect(addressReflection.toJson(address),
          equals({'state': 'CA', 'city': 'Los Angeles'}));

      {
        expect(address.id, isNull);

        addressReflection.setField<int?>('id', 123, address);
        expect(address.id, equals(123));

        addressReflection.setField<int?>('id', null, address);
        expect(address.id, isNull);
      }

      {
        var fieldId = addressReflection.field<int?>('id')!;

        expect(address.id, isNull);

        fieldId.set(1234);
        expect(address.id, equals(1234));

        fieldId.set(null);
        expect(address.id, isNull);

        fieldId.setNullable(12345);
        expect(address.id, equals(12345));

        fieldId.setNullable(null);
        expect(address.id, isNull);
      }

      expect(addressReflection.fromJson({'state': 'NY', 'city': 'New York'}),
          equals(TestAddressWithReflection.withCity('NY', city: 'New York')));

      expect(
          addressReflection
              .fromJson({'state': 'NY2', 'city': 'New York2', 'foo': 123}),
          equals(TestAddressWithReflection.withCity('NY2', city: 'New York2')));

      expect(TestEmpty$reflection().allFields(), isEmpty);
      expect(TestEmpty$reflection().field('foo'), isNull);

      expect(TestEmpty$reflection().allStaticFields(), isEmpty);
      expect(TestEmpty$reflection().staticField('foo'), isNull);

      expect(TestEmpty$reflection().allMethods(), isEmpty);
      expect(TestEmpty$reflection().method('foo'), isNull);

      expect(TestEmpty$reflection().allStaticMethods(), isEmpty);
      expect(TestEmpty$reflection().staticMethod('foo'), isNull);
    });

    test('ReflectionBridge', () async {
      var user = TestUserSimple('Joe', 'joe@mail.com', '123');

      var userReflection = TestUserReflectionBridge().reflection(user);

      expect(userReflection.classType, equals(TestUserSimple));

      expect(
          userReflection.classAnnotations,
          equals([
            TestAnnotation(['class', 'user'])
          ]));

      expect(userReflection.fieldsNames,
          equals(['email', 'hashCode', 'name', 'password']));
      expect(userReflection.staticFieldsNames,
          equals(['version', 'withReflection']));

      expect(userReflection.methodsNames,
          equals(['checkThePassword', 'hasEmail', 'toString']));
      expect(userReflection.staticMethodsNames, equals(['isVersion']));

      expect(userReflection.getField('name'), equals('Joe'));
      expect(userReflection.getField('email'), equals('joe@mail.com'));

      expect(userReflection.getStaticField('version'), equals(1.0));
      expect(userReflection.getStaticField('withReflection'), isFalse);

      expect(userReflection.invokeMethod('checkThePassword', ['abc']), isFalse);
      expect(userReflection.invokeMethod('checkThePassword', ['123']), isTrue);

      userReflection.setField('password', 'abc');

      expect(userReflection.invokeMethod('checkThePassword', ['abc']), isTrue);
      expect(userReflection.invokeMethod('checkThePassword', ['ABC']), isFalse);

      expect(
          userReflection.invokeMethod(
              'checkThePassword', ['ABC'], {Symbol('ignoreCase'): false}),
          isFalse);
      expect(
          userReflection.invokeMethod(
              'checkThePassword', ['ABC'], {Symbol('ignoreCase'): true}),
          isTrue);

      var field = userReflection.field('name')!;

      expect(
          field.annotations,
          equals([
            TestAnnotation(['field', 'name'])
          ]));

      expect(field.type, equals(TypeReflection.tString));
      expect(field.nullable, isFalse);
      expect(field.required, isTrue);

      var method = userReflection.method('checkThePassword')!;

      expect(
          method.annotations,
          equals([
            TestAnnotation(['method', 'password checker'])
          ]));

      expect(method.hasNoParameters, isFalse);
      expect(method.normalParameters.length, equals(1));
      expect(method.normalParametersNames, equals(['password']));
      expect(method.normalParametersTypes, equals([String]));
      expect(method.equalsNormalParametersTypes([String]), isTrue);
      expect(method.equalsNormalParametersTypes([bool]), isFalse);

      expect(
          method.normalParameters[0].annotations,
          equals([
            TestAnnotation(['parameter', 'password'])
          ]));

      expect(method.optionalParameters.length, equals(0));
      expect(method.optionalParametersNames, isEmpty);
      expect(method.optionalParametersTypes, isEmpty);
      expect(method.equalsOptionalParametersTypes([]), isTrue);

      expect(method.namedParameters.length, equals(1));
      expect(method.namedParametersNames, equals(['ignoreCase']));
      expect(method.namedParametersTypes, equals({'ignoreCase': bool}));
      expect(method.equalsNamedParametersTypes({'ignoreCase': bool}), isTrue);
      expect(
          method.equalsNamedParametersTypes({'ignoreCase': String}), isFalse);

      expect(method.namedParameters.values.first.annotations, isEmpty);

      expect(
          method.methodInvocationFromMap({
            'password': '123',
            'ignoreCase': false,
          }).toString(),
          equals(
              'MethodInvocation{normalParameters: [123], optionalParameters: [], namedParameters: {ignoreCase: false}}'));

      expect(
          method.methodInvocationFromMap({
            'password': '123',
            'ignoreCase': false,
          }).invoke(method.method),
          isFalse);

      expect(
          method.methodInvocationFromMap({
            'password': 'abc',
            'ignoreCase': false,
          }).invoke(method.method),
          isTrue);

      expect(
          method.methodInvocationFromMap({
            'password': 'ABC',
            'ignoreCase': false,
          }).invoke(method.method),
          isFalse);

      expect(
          method.methodInvocationFromMap({
            'password': 'ABC',
            'ignoreCase': true,
          }).invoke(method.method),
          isTrue);

      expect(userReflection.allMethods().whereNoParameters().length, equals(2));

      expect(
          userReflection.allMethods().whereParametersTypes().map((e) => e.name),
          ['checkThePassword', 'hasEmail', 'toString']);

      expect(
          userReflection.allMethods().whereParametersTypes(
              normalParameters: [String]).map((e) => e.name),
          ['checkThePassword']);

      expect(
          userReflection.allMethods().whereParametersTypes(
              normalParameters: [bool]).map((e) => e.name),
          []);

      expect(
          userReflection.allMethods().whereParametersTypes(
              optionalParameters: [bool]).map((e) => e.name),
          []);

      expect(
          userReflection
              .allMethods()
              .whereParametersTypes(optionalParameters: []).map((e) => e.name),
          ['checkThePassword', 'hasEmail', 'toString']);

      expect(
          userReflection.allMethods().whereParametersTypes(
              namedParameters: {'ignoreCase': bool}).map((e) => e.name),
          ['checkThePassword']);

      expect(userReflection.allStaticMethods().whereNoParameters(), isEmpty);
      expect(
          userReflection.allStaticMethods().whereParametersTypes(
              normalParameters: [double]).map((e) => e.name),
          ['isVersion']);

      expect(
          userReflection.allMethods().whereAnnotatedWith([
            TestAnnotation(['method', 'password checker'])
          ]).map((e) => e.name),
          equals(['checkThePassword']));

      expect(
          userReflection.allMethods().whereAnnotatedWithAnyOf([
            TestAnnotation(['method', 'password checker'])
          ]).map((e) => e.name),
          equals(['checkThePassword']));

      expect(userReflection.allMethods().whereAnnotated().map((e) => e.name),
          equals(['checkThePassword', 'toString']));

      expect(
          userReflection
              .allMethods()
              .whereAnnotated((as) => as.any((a) => a is TestAnnotation))
              .map((e) => e.name),
          equals(['checkThePassword']));

      expect(
          userReflection
              .allMethods()
              .whereAnnotatedWithType<TestAnnotation>()
              .map((e) => e.name),
          equals(['checkThePassword']));

      expect(userReflection.allMethods().whereNotAnnotated().map((e) => e.name),
          equals(['hasEmail']));

      expect(
          userReflection
              .allStaticMethods()
              .whereNotAnnotated()
              .map((e) => e.name),
          isEmpty);

      var userStaticReflection =
          TestUserReflectionBridge().reflection<TestUserSimple>();

      expect(userStaticReflection.classType, equals(TestUserSimple));

      expect(userStaticReflection.getStaticField('version'), equals(1.0));
      expect(userStaticReflection.getStaticField('withReflection'), isFalse);

      var addressStaticReflection =
          TestAddressReflectionBridge().reflection<TestAddress>();

      expect(addressStaticReflection.hasJsonNameAlias, isFalse);
      expect(
          addressStaticReflection.canCreateInstanceWithoutArguments, isFalse);

      expect(addressStaticReflection.fieldsNames,
          equals(['city', 'hashCode', 'state']));
      expect(addressStaticReflection.methodsNames, equals(['toJson']));
      expect(addressStaticReflection.constructorsNames, equals(['']));

      expect(addressStaticReflection.toJson(TestAddress('NY', 'New York')),
          equals({'state': 'NY', 'city': 'New York'}));

      expect(
          addressStaticReflection.toJsonFromFields(
              obj: TestAddress('NY', 'Buffalo')),
          equals({'state': 'NY', 'city': 'Buffalo'}));

      expect(
          addressStaticReflection.createInstanceFromMap(
              {'state': 'NY', 'city': 'Yonkers'})?.toJson(),
          equals({'state': 'NY', 'city': 'Yonkers'}));
    });

    test('Proxy', () {
      var proxy = TestUserSimpleProxy();

      expect(proxy.checkThePassword('pass123', ignoreCase: true), isTrue);
      expect(proxy.hasEmail(), isFalse);

      expect(
          proxy.calls,
          equals([
            'TestUserSimpleProxy{calls: 0} -> checkThePassword( {password: pass123, ignoreCase: true} ) -> bool',
            'TestUserSimpleProxy{calls: 1} -> hasEmail( {} ) -> bool',
          ]));
    });

    test('Proxy (async)', () async {
      var proxy = TestUserSimpleProxyAsync();

      expect(await proxy.checkThePassword('pass123', ignoreCase: true), isTrue);
      expect(await proxy.hasEmail(), isFalse);

      expect(
          proxy.calls,
          equals([
            'TestUserSimpleProxyAsync{calls: 0} -> checkThePassword( {password: pass123, ignoreCase: true} ) -> Future<bool>',
            'TestUserSimpleProxyAsync{calls: 1} -> hasEmail( {} ) -> Future<bool>',
          ]));
    });
  });
}
