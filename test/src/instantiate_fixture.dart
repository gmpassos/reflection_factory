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

typedef TestCheck = bool Function(int n);

/// Defaults whose reflected value (`ParameterReflection.defaultValue`) has
/// another type than the parameter: `0` is an `int`, `const []` a
/// `List<dynamic>`. A direct call must pass the parameter's own default.
@EnableReflection()
class TestDefaultsWithReflection {
  final double score;
  final List<String> tags;
  final Map<String, int> counts;
  final TestCheck? check;

  TestDefaultsWithReflection({
    this.score = 0,
    this.tags = const [],
    this.counts = const {},
    this.check,
  });

  TestDefaultsWithReflection.positional([
    this.score = 1,
    this.tags = const ['x'],
  ]) : counts = const {},
       check = null;
}

enum TestLevel { low, high }

/// More defaults that only have their parameter's type in a typed context
/// (`ParameterReflection.defaultValue` is a `Set<dynamic>`, a
/// `Map<dynamic, dynamic>`, ...), and a nullable parameter with a non-null
/// default.
@EnableReflection()
class TestMoreDefaultsWithReflection {
  static const int defaultLimit = 3;

  final Set<int> ids;
  final Map<String, List<int>> groups;
  final Duration timeout;
  final TestLevel level;
  final int limit;
  final String? label;

  TestMoreDefaultsWithReflection({
    this.ids = const {},
    this.groups = const {},
    this.timeout = const Duration(seconds: 1),
    this.level = TestLevel.high,
    this.limit = defaultLimit,
    this.label = 'label',
  });
}

/// Parameters typed by the class type parameter: no `invoker` (the type
/// parameter isn't in scope in generated code), so `Function.apply` is used.
@EnableReflection()
class TestGenericBoxWithReflection<T> {
  final List<T> items;
  final T Function()? factory;
  final String name;

  TestGenericBoxWithReflection(this.items, {this.factory, this.name = 'box'});

  TestGenericBoxWithReflection.named(this.name)
    : items = const [],
      factory = null;
}

/// Counts its calls, and throws when [fail] is given.
@EnableReflection()
class TestThrowingWithReflection {
  static int calls = 0;

  final String a;

  TestThrowingWithReflection(this.a, {String? fail}) {
    ++calls;
    if (fail != null) throw ArgumentError(fail);
  }
}

/// A constructor with a required named parameter, and a nullable named
/// parameter with a non-null default.
@EnableReflection()
class TestRequiredNamedWithReflection {
  final String a;
  final String? b;

  TestRequiredNamedWithReflection({required this.a, this.b = 'B'});
}
