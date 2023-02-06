import 'package:benchmark/benchmark.dart';
import 'package:reflection_factory/builder.dart';
import '../test/src/user_with_reflection.dart';

void main() {
  late ClassReflection<TestUserWithReflection> reflection;
  late TestUserWithReflection user;
  late ClassReflection<TestUserWithReflection> userReflection;

  setUpEach(() {
    reflection = TestUserWithReflection$reflection();
    var c = reflection.constructor('fields');
    user = c!.invoke(['Joe', 'joe@mail.com', 'pass123']);
    userReflection = user.reflection;

    reflection.staticField('version');
    reflection.staticMethod('isVersion');
    reflection.method('checkPassword');
    reflection.field('name');
  });

  benchmark('reflection.constructor', () {
    reflection.constructor('fields')!;
  }, iterations: 1000000, duration: Duration(seconds: 5));

  benchmark('userReflection.constructor', () {
    userReflection.constructor('fields')!;
  }, iterations: 1000000, duration: Duration(seconds: 5));

  benchmark('reflection.staticField', () {
    reflection.staticField('version')!;
  }, iterations: 1000000, duration: Duration(seconds: 5));

  benchmark('reflection.staticMethod', () {
    reflection.staticMethod('isVersion')!;
  }, iterations: 1000000, duration: Duration(seconds: 5));

  benchmark('reflection.method', () {
    userReflection.method('checkPassword')!;
  }, iterations: 1000000, duration: Duration(seconds: 5));

  benchmark('userReflection.method', () {
    userReflection.method('checkPassword')!;
  }, iterations: 1000000, duration: Duration(seconds: 5));

  benchmark('reflection.field', () {
    reflection.field('name')!;
  }, iterations: 1000000, duration: Duration(seconds: 5));

  benchmark('userReflection.field', () {
    userReflection.field('name')!;
  }, iterations: 1000000, duration: Duration(seconds: 5));
}
