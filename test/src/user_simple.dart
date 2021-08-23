class TestUserSimple {
  static final double version = 1.0;
  static final bool withReflection = false;

  final String name;

  String? email;

  String password;

  TestUserSimple(this.name, this.email, this.password);

  bool checkThePassword(String password) => this.password == password;
}
