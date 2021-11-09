import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:reflection_factory/reflection_factory.dart';

part 'user_with_reflection.reflection.g.dart';

@EnableReflection()
enum TestEnumWithReflection {
  x,
  y,
  z,
  Z,
}

@EnableReflection()
class TestUserWithReflection {
  static final double version = 1.1;
  static final bool withReflection = true;

  static bool isVersion(double ver) => version == ver;

  final String name;

  String? email;

  String password;

  bool enabled;

  TestEnumWithReflection axis;

  int? level;

  TestUserWithReflection.fields(this.name, this.email, this.password,
      {this.enabled = true, this.axis = TestEnumWithReflection.x, this.level});

  TestUserWithReflection()
      : this.fields(
          '',
          null,
          '',
        );

  @JsonField.visible()
  bool get isEnabled => enabled;

  @JsonField.hidden()
  bool get isNotEnabled => !enabled;

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestUserWithReflection &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          email == other.email &&
          password == other.password &&
          enabled == other.enabled &&
          axis == other.axis;

  @override
  int get hashCode =>
      name.hashCode ^
      email.hashCode ^
      password.hashCode ^
      enabled.hashCode ^
      axis.hashCode;
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

  final List<String> extraNames;

  List<TestAddressWithReflection> extraAddresses;

  TestCompanyWithReflection(this.name, this.mainAddress, this.extraAddresses,
      {this.extraNames = const <String>[]});

  @JsonField.hidden()
  bool local = false;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestCompanyWithReflection &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          mainAddress == other.mainAddress &&
          ListEquality<TestAddressWithReflection>()
              .equals(extraAddresses, other.extraAddresses) &&
          ListEquality<String>().equals(extraNames, other.extraNames);

  @override
  int get hashCode =>
      name.hashCode ^
      mainAddress.hashCode ^
      ListEquality<TestAddressWithReflection>().hash(extraAddresses) ^
      ListEquality<String>().hash(extraNames);
}

@EnableReflection()
class TestDataWithReflection {
  final String name;

  BigInt id;

  Uint8List bytes;

  TestDomainWithReflection? domain;

  TestDataWithReflection(this.name, this.bytes, {BigInt? id, this.domain})
      : id = id ?? BigInt.zero;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestDataWithReflection &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          id == other.id &&
          domain == other.domain &&
          ListEquality<int>().equals(bytes, other.bytes);

  @override
  int get hashCode =>
      name.hashCode ^
      id.hashCode ^
      (domain?.hashCode ?? 0) ^
      ListEquality<int>().hash(bytes);
}

@EnableReflection()
class TestDomainWithReflection {
  final String name;
  final String suffix;

  TestDomainWithReflection(this.name, this.suffix);

  factory TestDomainWithReflection.parse(String s) {
    var parts = s.split('.');
    return TestDomainWithReflection(parts[0], parts[1]);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestDomainWithReflection &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          suffix == other.suffix;

  @override
  int get hashCode => name.hashCode ^ suffix.hashCode;

  String toJson() => toString();

  @override
  String toString() => '$name.$suffix';
}
