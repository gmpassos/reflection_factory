import 'package:collection/collection.dart';
import 'package:reflection_factory/reflection_factory.dart';

part 'user_with_reflection.reflection.g.dart';

@EnableReflection()
class TestUserWithReflection {
  static final double version = 1.1;
  static final bool withReflection = true;

  static bool isVersion(double ver) => version == ver;

  final String name;

  String? email;

  String password;

  bool enabled;

  TestUserWithReflection.fields(this.name, this.email, this.password,
      {this.enabled = true});

  TestUserWithReflection()
      : this.fields(
          '',
          null,
          '',
        );

  bool checkPassword(String password) => this.password == password;

  V? getField<V extends Object>(String key, [V? def]) {
    switch (key) {
      case 'name':
        return name as V?;
      case 'email':
        return email as V?;
      case 'password':
        return password as V?;
      case 'enabled':
        return enabled as V?;
      default:
        return null;
    }
  }

  void setField<V>(String key, V? value, {V? def}) {
    value ??= def;

    switch (key) {
      case 'email':
        {
          email = value as String?;
          break;
        }
      case 'password':
        {
          password = value as String;
          break;
        }
      case 'enabled':
        {
          enabled = value as bool;
          break;
        }
      default:
        break;
    }
  }
}

@EnableReflection()
class TestAddressWithReflection {
  final String state;

  final String city;

  TestAddressWithReflection(this.state, [this.city = '']);

  TestAddressWithReflection.empty() : this('', '');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestAddressWithReflection &&
          runtimeType == other.runtimeType &&
          state == other.state &&
          city == other.city;

  @override
  int get hashCode => state.hashCode ^ city.hashCode;

  // Implements its own `toJson`:
  Map<String, dynamic> toJson() => {'state': state, 'city': city};
}

@EnableReflection()
class TestCompanyWithReflection {
  final String name;
  TestAddressWithReflection mainAddress;

  List<TestAddressWithReflection> extraAddresses;

  TestCompanyWithReflection(this.name, this.mainAddress, this.extraAddresses);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestCompanyWithReflection &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          mainAddress == other.mainAddress &&
          ListEquality<TestAddressWithReflection>()
              .equals(extraAddresses, other.extraAddresses);

  @override
  int get hashCode =>
      name.hashCode ^ mainAddress.hashCode ^ extraAddresses.hashCode;
}
