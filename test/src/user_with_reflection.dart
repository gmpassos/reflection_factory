import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:reflection_factory/reflection_factory.dart';

part 'reflection/user_with_reflection.g.dart';

@EnableReflection()
enum TestEnumWithReflection {
  x,
  y,
  z,
  Z;

  String get nameLC => name.toLowerCase();

  static int get length => values.length;
}

@EnableReflection()
class TestUserWithReflection {
  static final double version = 1.1;
  static final bool withReflection = true;

  static bool isVersion(double ver) => version == ver;

  int? id;

  final String name;

  String? email;

  String password;

  bool enabled;

  TestEnumWithReflection axis;

  @JsonFieldAlias('theLevel')
  int? level;

  TestUserWithReflection.fields(
      this.name, this.email, @JsonFieldAlias('password') String passphrase,
      {this.enabled = true,
      this.axis = TestEnumWithReflection.x,
      this.level,
      this.id})
      : password = passphrase.trim();

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
          axis == other.axis &&
          level == other.level &&
          id == other.id;

  @override
  int get hashCode =>
      name.hashCode ^
      email.hashCode ^
      password.hashCode ^
      enabled.hashCode ^
      axis.hashCode ^
      level.hashCode ^
      id.hashCode;

  @override
  String toString() {
    return 'TestUserWithReflection{id: $id, name: $name, email: $email, password: $password, enabled: $enabled, axis: $axis, level: $level}';
  }
}

@EnableReflection(optimizeReflectionInstances: false)
class TestAddressWithReflection {
  int? id;

  final String state;

  final String city;

  TestAddressWithReflection.simple(this.state, {this.id}) : city = '';

  @JsonConstructor(mandatory: true)
  TestAddressWithReflection.withCity(this.state, {this.city = '', this.id});

  TestAddressWithReflection.empty() : this.simple('');

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
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'state': state,
        'city': city,
      };

  @override
  String toString() {
    return 'TestAddressWithReflection{id: $id, state: $state, city: $city}';
  }
}

@EnableReflection()
class TestCompanyWithReflection {
  final String name;
  TestAddressWithReflection? mainAddress;

  final List<String> extraNames;

  List<TestAddressWithReflection> branchesAddresses;

  List<TestAddressWithReflection> extraAddresses;

  TestCompanyWithReflection(this.name, this.mainAddress,
      {this.extraAddresses = const <TestAddressWithReflection>[],
      this.branchesAddresses = const <TestAddressWithReflection>[],
      this.extraNames = const <String>[]});

  TestCompanyWithReflection.noBranches(this.name, this.mainAddress,
      {this.extraAddresses = const <TestAddressWithReflection>[],
      this.extraNames = const <String>[]})
      : branchesAddresses = [];

  @JsonField.hidden()
  bool local = false;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestCompanyWithReflection &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          mainAddress == other.mainAddress &&
          ListEquality<String>().equals(extraNames, other.extraNames) &&
          ListEquality<TestAddressWithReflection>()
              .equals(branchesAddresses, other.branchesAddresses) &&
          ListEquality<TestAddressWithReflection>()
              .equals(extraAddresses, other.extraAddresses);

  @override
  int get hashCode =>
      name.hashCode ^
      mainAddress.hashCode ^
      ListEquality<TestAddressWithReflection>().hash(branchesAddresses) ^
      ListEquality<TestAddressWithReflection>().hash(extraAddresses) ^
      ListEquality<String>().hash(extraNames);

  @override
  String toString() {
    return 'TestCompanyWithReflection{name: $name, mainAddress: $mainAddress, extraNames: $extraNames, branchesAddresses: $branchesAddresses, extraAddresses: $extraAddresses, local: $local}';
  }
}

@EnableReflection()
class TestFranchiseWithReflection {
  final String name;

  Map<String, TestAddressWithReflection> addresses;

  TestFranchiseWithReflection(this.name, this.addresses);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestFranchiseWithReflection &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          MapEquality<String, TestAddressWithReflection>()
              .equals(addresses, other.addresses);

  @override
  int get hashCode =>
      name.hashCode ^
      MapEquality<String, TestAddressWithReflection>().hash(addresses);

  @override
  String toString() {
    return 'TestFranchiseWithReflection{name: $name, addresses: $addresses}';
  }
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

typedef DomainFunction = bool Function(int x);

typedef TypedFunction<T> = bool Function(T x);

@EnableReflection()
class TestDomainWithReflection {
  final String name;
  final String suffix;
  final DomainFunction? domainFunction;
  final bool Function()? extraFunction;

  TestDomainWithReflection(this.name, this.suffix,
      [this.domainFunction, this.extraFunction]);

  TestDomainWithReflection.named(
      {required this.name,
      this.suffix = 'net',
      this.domainFunction,
      this.extraFunction});

  factory TestDomainWithReflection.parse(String s) {
    var parts = s.split('.');
    return TestDomainWithReflection(parts[0], parts[1]);
  }

  bool typedFunction<T>(TypedFunction<T> f, T x) => f(x);

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

mixin WithValue<T> {
  T? value;
}

@EnableReflection()
class TestOpWithReflection<T> with WithValue<T> {
  static int staticField = 1;

  static bool staticMethod() => true;

  final String type;

  TestOpWithReflection(this.type, T? value) {
    this.value = value;
  }

  TestOpWithReflection.empty() : this('', null);

  bool isEmptyType() => type.isEmpty;
}

@EnableReflection()
class TestOpAWithReflection extends TestOpWithReflection<int> {
  static int staticFieldA = 2;

  @override
  int get value => super.value!;

  @override
  set value(int? v) => super.value = v ?? 0;

  TestOpAWithReflection(int value) : super('a', value);

  bool methodA() => true;
}

@EnableReflection()
class TestOpBWithReflection extends TestOpWithReflection<double> {
  static bool staticMethodB() => false;

  double get amount => value!;

  set amount(double v) => value = v;

  TestOpBWithReflection(double amount) : super('b', amount);

  Set<T> methodB<T>() => <T>{};
}

@EnableReflection()
class TestTransactionWithReflection {
  final TestUserWithReflection fromUser;

  final TestUserWithReflection toUser;

  final int amount;

  TestTransactionWithReflection.fromTo(this.amount, this.fromUser, this.toUser);
}

@EnableReflection()
class TestName {
  String? name;

  bool get isEmpty => nameNormalized().isEmpty;

  String nameNormalized() {
    var n = name ?? '';
    return n.toLowerCase().trim();
  }

  @override
  String toString() {
    return 'TestName{name: $name}';
  }
}

@EnableReflection()
class TestEmpty {}
