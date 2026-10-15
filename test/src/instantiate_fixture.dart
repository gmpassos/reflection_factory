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

/// Inherits `factory` (`T Function()?`) with `T` as `int`: reflected as
/// `int Function()?`.
@EnableReflection()
class TestIntBoxWithReflection extends TestGenericBoxWithReflection<int> {
  TestIntBoxWithReflection(super.items);
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

/// Many parameters of the same type: an argument in the wrong position
/// would go unnoticed (no `TypeError`). The named parameters aren't declared
/// in alphabetical order, and mix required, defaults and nullables.
@EnableReflection()
class TestWideWithReflection {
  final String a;
  final String b;
  final String c;
  final String zeta;
  final String? alpha;
  final String mid;
  final String beta;
  final String? omega;
  final int n1;
  final int n2;
  final int? n3;

  TestWideWithReflection(
    this.a,
    this.b,
    this.c, {
    this.zeta = 'Z',
    this.alpha,
    required this.mid,
    this.beta = 'B',
    this.omega,
    this.n2 = 2,
    this.n1 = 1,
    this.n3,
  });
}

/// A generic wrapper from outside the reflected classes, as an entity
/// reference: parameters typed `TestRef<TestAccountWithReflection>`.
class TestRef<T> {
  final T? value;

  const TestRef(this.value);

  @override
  bool operator ==(Object other) =>
      other is TestRef &&
      other.runtimeType == runtimeType &&
      other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'TestRef<$T>($value)';
}

typedef TestJsonMap = Map<String, dynamic>;

/// Parameters typed by generic classes with type arguments (entity
/// references and lists), maps, a `typedef` of a map, nullable elements,
/// an enum, `Object?` and `dynamic`.
@EnableReflection()
class TestOrderWithReflection {
  final int? id;
  final TestRef<TestAccountWithReflection> account;
  final List<TestAccountWithReflection>? items;
  final Map<String, dynamic>? extra;
  final TestJsonMap? meta;
  final List<String?> notes;
  final List<List<int>>? matrix;
  final TestLevel? level;
  final DateTime? date;
  final Object? any;
  final dynamic raw;

  TestOrderWithReflection(
    this.account, {
    this.id,
    this.items,
    this.extra,
    this.meta,
    this.notes = const [],
    this.matrix,
    this.level,
    this.date,
    this.any,
    this.raw,
  });
}

/// Record types as parameters.
@EnableReflection()
class TestRecordWithReflection {
  final (int, String) pair;
  final ({int x, int y})? point;

  TestRecordWithReflection(this.pair, {this.point});
}

/// Two constructors with a parameter of the same name and different types:
/// the first one that fits the value is used.
@EnableReflection()
class TestMultiCtorWithReflection {
  final Object value;
  final String kind;

  TestMultiCtorWithReflection.fromInt(int this.value) : kind = 'int';

  TestMultiCtorWithReflection.fromString(String this.value) : kind = 'string';
}

/// A (non-mandatory) `@JsonConstructor`, and another constructor.
@EnableReflection()
class TestJsonCtorWithReflection {
  final String name;
  final int qty;
  final String? note;

  @JsonConstructor()
  TestJsonCtorWithReflection(this.name, {this.qty = 1, this.note});

  TestJsonCtorWithReflection.full(this.name, this.qty, this.note);
}

/// Instantiated with `create()` plus setters: a final field (only set by a
/// constructor) and a nullable field with a non-null initial value.
@EnableReflection()
class TestSettersWithReflection {
  final String code;
  String? phone = 'initial';
  int count = 0;
  List<String> tags = [];

  TestSettersWithReflection.create() : code = 'c';
}

int testTriple(int n) => n * 3;

const testNegative = -3;

/// Defaults that are function tear-offs (a static method by its bare name and
/// a top-level function), negative numbers, a string with escapes, const
/// collections of enums, and a const instance of a generic class.
@EnableReflection()
class TestEdgeDefaultsWithReflection {
  static int identity(int n) => n;

  final int Function(int) mapper;
  final int Function(int) mapper2;
  final int neg;
  final double negD;
  final String text;
  final List<TestLevel> levels;
  final Map<TestLevel, List<String>> byLevel;
  final TestRef<int> ref;

  TestEdgeDefaultsWithReflection({
    this.mapper = identity,
    this.mapper2 = testTriple,
    this.neg = testNegative,
    this.negD = -1,
    this.text = 'a\$b "q" \'s\' \\n',
    this.levels = const [TestLevel.low, TestLevel.high],
    this.byLevel = const {
      TestLevel.low: ['x'],
    },
    this.ref = const TestRef(1),
  });
}

/// Every kind of constructor: `const`, private, `factory`, redirecting, and
/// redirecting `factory`.
@EnableReflection()
class TestCtorKindsWithReflection {
  final String kind;
  final int n;

  const TestCtorKindsWithReflection(this.kind, {this.n = 0});

  const TestCtorKindsWithReflection._private(this.n) : kind = 'private';

  factory TestCtorKindsWithReflection.parse(String s) =>
      TestCtorKindsWithReflection('parsed', n: int.parse(s));

  const TestCtorKindsWithReflection.redirect(int n) : this('redirect', n: n);

  const factory TestCtorKindsWithReflection.redirectingFactory(int n) =
      TestCtorKindsWithReflection._private;

  static TestCtorKindsWithReflection privateOf(int n) =>
      TestCtorKindsWithReflection._private(n);
}
