class TestUserSimple {
  static final double version = 1.0;
  static final bool withReflection = false;

  static bool isVersion(double ver) => version == ver;

  final String name;

  String? email;

  String password;

  TestUserSimple(this.name, this.email, this.password);

  bool checkThePassword(String password, {bool ignoreCase = false}) {
    if (ignoreCase) {
      return this.password.toLowerCase() == password.toLowerCase();
    } else {
      return this.password == password;
    }
  }
}
