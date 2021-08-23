import 'package:test/test.dart';

import 'src/user_reflection_bridge.dart';
import 'src/user_simple.dart';
import 'src/user_with_reflection.dart';

void main() {
  group('Reflection', () {
    setUp(() {});

    test('EnableReflection', () async {
      var user = TestUserWithReflection('Joe', 'joe@mail.com', '123');

      var userReflection = user.reflection;

      expect(userReflection.classType, equals(TestUserWithReflection));

      expect(userReflection.fieldsNames, equals(['email', 'name', 'password']));
      expect(userReflection.staticFieldsNames,
          equals(['version', 'withReflection']));

      expect(userReflection.getField('name'), equals('Joe'));
      expect(userReflection.getField('email'), equals('joe@mail.com'));

      expect(userReflection.getStaticField('version'), equals(1.1));
      expect(userReflection.getStaticField('withReflection'), isTrue);

      expect(userReflection.invokeMethod('checkPassword', ['abc']), isFalse);
      expect(userReflection.invokeMethod('checkPassword', ['123']), isTrue);

      var userStaticReflection = TestUserWithReflection$reflection();

      expect(userStaticReflection.classType, equals(TestUserWithReflection));

      expect(userStaticReflection.getStaticField('version'), equals(1.1));
      expect(userStaticReflection.getStaticField('withReflection'), isTrue);
    });

    test('ReflectionBridge', () async {
      var user = TestUserSimple('Joe', 'joe@mail.com', '123');

      var userReflection = TestUserReflectionBridge().reflection(user);

      expect(userReflection.classType, equals(TestUserSimple));

      expect(userReflection.fieldsNames, equals(['email', 'name', 'password']));
      expect(userReflection.staticFieldsNames,
          equals(['version', 'withReflection']));

      expect(userReflection.getField('name'), equals('Joe'));
      expect(userReflection.getField('email'), equals('joe@mail.com'));

      expect(userReflection.getStaticField('version'), equals(1.0));
      expect(userReflection.getStaticField('withReflection'), isFalse);

      expect(userReflection.invokeMethod('checkThePassword', ['abc']), isFalse);
      expect(userReflection.invokeMethod('checkThePassword', ['123']), isTrue);

      var userStaticReflection =
          TestUserReflectionBridge().reflection<TestUserSimple>();

      expect(userStaticReflection.classType, equals(TestUserSimple));

      expect(userStaticReflection.getStaticField('version'), equals(1.0));
      expect(userStaticReflection.getStaticField('withReflection'), isFalse);
    });
  });
}
