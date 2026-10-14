import 'package:reflection_factory/reflection_factory.dart';

part 'instantiate_fixture.reflection.g.dart';

/// An entity with 8 fields and several constructors, shaped like a DB row.
@EnableReflection()
class TestAccountWithReflection {
  int? id;
  String name;
  String email;
  String? phone;
  int age;
  double score;
  bool active;
  DateTime? createdAt;

  TestAccountWithReflection(
    this.name,
    this.email, {
    this.id,
    this.phone,
    this.age = 18,
    this.score = 0.5,
    this.active = true,
    this.createdAt,
  });

  TestAccountWithReflection.basic(this.name, this.email)
    : age = 0,
      score = 0,
      active = false;

  TestAccountWithReflection.create() : this.basic('', '');

  @override
  String toString() =>
      'TestAccountWithReflection{id: $id, name: $name, email: $email, '
      'phone: $phone, age: $age, score: $score, active: $active, '
      'createdAt: $createdAt}';
}

/// The main constructor takes `passwordOrHash`, which doesn't match the
/// `passwordHash` field, so instantiation from a `Map` of fields falls back
/// to [TestMemberWithReflection.create] plus setting fields.
@EnableReflection()
class TestMemberWithReflection {
  int? id;
  String name;
  String email;
  String passwordHash;
  int age;
  double score;
  bool active;
  DateTime? createdAt;

  TestMemberWithReflection(
    this.name,
    this.email,
    String passwordOrHash, {
    this.id,
    this.age = 0,
    this.score = 0,
    this.active = true,
    this.createdAt,
  }) : passwordHash = passwordOrHash;

  TestMemberWithReflection.create()
    : name = '',
      email = '',
      passwordHash = '',
      age = 0,
      score = 0,
      active = false;
}

/// A constructor with optional positional parameters.
@EnableReflection()
class TestOptPositionalWithReflection {
  final String a;
  final String b;
  final int? c;

  TestOptPositionalWithReflection(this.a, [this.b = 'b', this.c]);
}

class TestBaseWithDefault {
  final int x;
  final String y;

  TestBaseWithDefault({this.x = 7, this.y = 'y'});
}

/// Named super-parameters that inherit their defaults.
@EnableReflection()
class TestSuperParamsWithReflection extends TestBaseWithDefault {
  TestSuperParamsWithReflection({super.x, super.y = 'z'});
}

/// A constructor with a required named parameter, and a nullable named
/// parameter with a non-null default.
@EnableReflection()
class TestRequiredNamedWithReflection {
  final String a;
  final String? b;

  TestRequiredNamedWithReflection({required this.a, this.b = 'B'});
}
