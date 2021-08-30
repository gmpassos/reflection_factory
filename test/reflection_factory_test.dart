import 'package:reflection_factory/reflection_factory.dart';
import 'package:test/test.dart';

import 'src/user_reflection_bridge.dart';
import 'src/user_simple.dart';
import 'src/user_with_reflection.dart';

void main() {
  group('Reflection', () {
    setUp(() {});

    test('EnableReflection', () async {
      expect(
          ReflectionFactory()
              .hasRegisterClassReflection(TestUserWithReflection),
          isFalse);

      var user = TestUserWithReflection('Joe', 'joe@mail.com', '123');

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

      expect(userReflection.fieldsNames, equals(['email', 'name', 'password']));
      expect(userReflection.staticFieldsNames,
          equals(['version', 'withReflection']));

      expect(userReflection.methodsNames, equals(['checkPassword']));
      expect(userReflection.staticMethodsNames, equals(['isVersion']));

      expect(userReflection.getField('name'), equals('Joe'));
      expect(userReflection.getField('email'), equals('joe@mail.com'));

      expect(userReflection.getField('password'), equals('123'));
      userReflection.setField('password', 'abc');
      expect(userReflection.getField('password'), equals('abc'));

      var field = userReflection.field('email')!;

      expect(field.className, equals('TestUserWithReflection'));
      expect(field.isStatic, isFalse);
      expect(field.name, equals('email'));
      expect(field.type, equals(String));
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
      expect(staticField.type, equals(double));
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

      var user2 = TestUserWithReflection('Joe', 'joe@mail.com', 'xyz');
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
      expect(method.normalParameters[0],
          equals(ParameterReflection(String, 'password', false, false, null)));
      expect(method.normalParametersTypes.length, equals(1));
      expect(method.normalParametersTypes[0], equals(String));
      expect(method.normalParametersNames.length, equals(1));
      expect(method.normalParametersNames[0], equals('password'));
      expect(
          method.toString(),
          startsWith(
              'MethodReflection{ class: TestUserWithReflection, name: checkPassword, returnType: bool, static: false,'));

      var staticMethod = userReflection.staticMethod('isVersion')!;
      expect(staticMethod.className, equals('TestUserWithReflection'));
      expect(staticMethod.isStatic, isTrue);
      expect(staticMethod.name, equals('isVersion'));
      expect(staticMethod.hasNoParameters, isFalse);
      expect(staticMethod.normalParameters.length, equals(1));
      expect(staticMethod.normalParameters[0],
          equals(ParameterReflection(double, 'ver', false, false, null)));
      expect(staticMethod.normalParametersNames.length, equals(1));
      expect(staticMethod.normalParametersNames[0], equals('ver'));
      expect(
          staticMethod.toString(),
          startsWith(
              'MethodReflection{ class: TestUserWithReflection, name: isVersion, returnType: bool, static: true,'));

      expect(userReflection.toJson(),
          equals({'email': 'joe@mail.net', 'name': 'Joe', 'password': 'abc'}));
      expect(userReflection.toJsonEncoded(),
          equals('{"email":"joe@mail.net","name":"Joe","password":"abc"}'));

      var userStaticReflection = TestUserWithReflection$reflection();

      expect(
          userReflection.runtimeType, equals(userStaticReflection.runtimeType));

      expect(userStaticReflection.classType, equals(TestUserWithReflection));

      expect(userStaticReflection.getStaticField('version'), equals(1.1));
      expect(userStaticReflection.getStaticField('withReflection'), isTrue);
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

      expect(field.type, equals(String));
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
