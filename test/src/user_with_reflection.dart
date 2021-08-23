import 'package:reflection_factory/reflection_factory.dart';

part 'user_with_reflection.reflection.g.dart';

@EnableReflection()
class TestUserWithReflection {
  static final double version = 1.1;
  static final bool withReflection = true;

  final String name;

  String? email;

  String password;

  TestUserWithReflection(this.name, this.email, this.password);

  bool checkPassword(String password) => this.password == password;
}
