import 'package:collection/collection.dart' show ListEquality;

@TestAnnotation(['class', 'user'])
class TestUserSimple {
  @TestAnnotation(['static field', 'version'])
  static final double version = 1.0;
  static final bool withReflection = false;

  @TestAnnotation(['static method', 'version checker'])
  static bool isVersion(double ver) => version == ver;

  @TestAnnotation(['field', 'name'])
  final String name;

  String? email;

  String password;

  TestUserSimple(this.name, this.email, this.password);

  @TestAnnotation(['method', 'password checker'])
  bool checkThePassword(
      @TestAnnotation(['parameter', 'password']) String password,
      {bool ignoreCase = false}) {
    if (ignoreCase) {
      return this.password.toLowerCase() == password.toLowerCase();
    } else {
      return this.password == password;
    }
  }

  bool hasEmail() => email != null && email!.isNotEmpty;
}

class TestAnnotation {
  final List<String> list;

  const TestAnnotation([this.list = const <String>[]]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestAnnotation &&
          runtimeType == other.runtimeType &&
          ListEquality<String>().equals(list, other.list);

  @override
  int get hashCode => list.hashCode;

  @override
  String toString() {
    return 'TestAnnotation{list: $list}';
  }
}
