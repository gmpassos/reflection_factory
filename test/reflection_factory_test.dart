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
      expect(TypeReflection.tBool.isNumericType, isFalse);
      expect(TypeReflection.tBool.isBoolType, isTrue);
      expect(TypeReflection.tBool.isCollectionType, isFalse);
      expect(TypeReflection.tBool.isIterableType, isFalse);
      expect(TypeReflection.tBool.isMapType, isFalse);

      expect(TypeReflection.tList.isPrimitiveType, isFalse);
      expect(TypeReflection.tList.isStringType, isFalse);
      expect(TypeReflection.tList.isDoubleType, isFalse);
      expect(TypeReflection.tList.isIntType, isFalse);
      expect(TypeReflection.tList.isNumericType, isFalse);
      expect(TypeReflection.tList.isBoolType, isFalse);
      expect(TypeReflection.tList.isCollectionType, isTrue);
      expect(TypeReflection.tList.isIterableType, isTrue);
      expect(TypeReflection.tList.isMapType, isFalse);

      expect(TypeReflection.tMap.isPrimitiveType, isFalse);
      expect(TypeReflection.tMap.isStringType, isFalse);
      expect(TypeReflection.tMap.isDoubleType, isFalse);
      expect(TypeReflection.tMap.isIntType, isFalse);
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
              .hasRegisterClassReflection(TestUserWithReflection),
          isFalse);

      var user = TestUserWithReflection.fields('Joe', 'joe@mail.com', '123');

      var userReflection = user.reflection;

      expect(userReflection.classType, equals(TestUserWithReflection));
      expect(userReflection.toString(),
          startsWith('ClassReflection{ class: TestUserWithReflection }'));

      expect(
          ReflectionFactory()
              .hasRegisterClassReflection(TestUserWithReflection),
          isTrue);

      expect(
          ReflectionFactory()
              .getRegisterClassReflection(TestUserWithReflection)!
              .classType,
          equals(TestUserWithReflection));

      expect(userReflection.constructorsNames, equals(['', 'fields']));

      expect(userReflection.allConstructors().length, equals(2));

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
        expect(constructorFields.namedParameters.keys, equals(['enabled']));
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

        expect(user.toJson(), userReflection.createInstance()!.toJson());
      }

      expect(userReflection.fieldsNames,
          equals(['email', 'enabled', 'name', 'password']));
      expect(userReflection.allFields().map((e) => e.name),
          equals(userReflection.fieldsNames));

      expect(userReflection.fieldsWhere((f) => f.nullable).map((f) => f.name),
          equals(['email']));

      expect(
          userReflection
              .fieldsWhere((f) => f.type.isBoolType)
              .map((e) => e.name),
          equals(['enabled']));

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
          equals(['checkPassword', 'getField', 'setField']));
      expect(userReflection.allMethods().map((e) => e.name),
          equals(userReflection.methodsNames));

      expect(
          userReflection
              .methodsWhere((m) => m.equalsNormalParametersTypes([String]))
              .map((e) => e.name),
          equals(['checkPassword', 'getField']));

      expect(
          userReflection
              .methodsWhere((m) => m.equalsOptionalParametersTypes([Object]))
              .map((e) => e.name),
          equals(['getField']));

      expect(userReflection.methodsWhere((m) => m.hasNoParameters), isEmpty);

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
      expect(allFields.toNames(),
          equals(['email', 'enabled', 'name', 'password']));
      expect(allFields.whereFinal().toNames(), equals(['name']));
      expect(allFields.whereNullable().toNames(), equals(['email']));
      expect(allFields.toTypes(), equals([String, bool, String, String]));

      var allStaticFields = userReflection.allStaticFields();
      expect(allStaticFields.toNames(), equals(['version', 'withReflection']));
      expect(allStaticFields.whereStatic().toNames(),
          equals(['version', 'withReflection']));

      var allMethods = userReflection.allMethods();
      expect(allMethods.toNames(),
          equals(['checkPassword', 'getField', 'setField']));
      expect(allMethods.toReturnTypeReflections(),
          equals([TypeReflection.tBool, TypeReflection.tObject, null]));
      expect(allMethods.toReturnTypes(), equals([bool, Object, null]));
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

      expect(
          userReflection.toJson(),
          equals({
            'email': 'joe@mail.net',
            'enabled': true,
            'name': 'Joe',
            'password': 'abc'
          }));
      expect(
          userReflection.toJsonEncoded(),
          equals(
              '{"email":"joe@mail.net","enabled":true,"name":"Joe","password":"abc"}'));

      expect(
          ReflectionFactory.toJsonEncodable(user),
          equals({
            'email': 'joe@mail.net',
            'enabled': true,
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

      var address = TestAddressWithReflection('CA', 'Los Angeles');
      expect(address.reflection, isNotNull);

      expect(ReflectionFactory.toJsonEncodable(address),
          equals({'state': 'CA', 'city': 'Los Angeles'}));
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

      expect(userReflection.fieldsNames, equals(['email', 'name', 'password']));
      expect(userReflection.staticFieldsNames,
          equals(['version', 'withReflection']));

      expect(userReflection.methodsNames,
          equals(['checkThePassword', 'hasEmail']));
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

      expect(userReflection.allMethods().whereNoParameters().length, equals(1));

      expect(
          userReflection.allMethods().whereParametersTypes().map((e) => e.name),
          ['checkThePassword', 'hasEmail']);

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
          ['checkThePassword', 'hasEmail']);

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
          equals(['checkThePassword']));

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
    });
  });
}
