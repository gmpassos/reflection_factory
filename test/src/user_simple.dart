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

  TestUserSimple.empty() : this('', null, '');

  @TestAnnotation(['method', 'password checker'])
  bool checkThePassword(
    @TestAnnotation(['parameter', 'password']) String password, {
    bool ignoreCase = false,
  }) {
    if (ignoreCase) {
      return this.password.toLowerCase() == password.toLowerCase();
    } else {
      return this.password == password;
    }
  }

  bool hasEmail() => email != null && email!.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestUserSimple &&
          name == other.name &&
          email == other.email &&
          password == other.password;

  @override
  int get hashCode => name.hashCode ^ email.hashCode ^ password.hashCode;

  @override
  String toString() {
    return 'TestUserSimple{name: $name, email: $email}';
  }
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

// No reflection:
class TestAddress {
  final String state;

  final String city;

  TestAddress(this.state, this.city);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestAddress &&
          runtimeType == other.runtimeType &&
          state == other.state &&
          city == other.city;

  @override
  int get hashCode => state.hashCode ^ city.hashCode;

  Map<String, dynamic> toJson() => {'state': state, 'city': city};
}
