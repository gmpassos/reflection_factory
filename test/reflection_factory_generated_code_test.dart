@TestOn('vm')
@Tags(['build', 'slow', 'e2e'])
library;

import 'dart:io';

import 'package:path/path.dart' as pack_path;
import 'package:test/test.dart';

/// End-to-end check that generated code actually *compiles*.
///
/// `testBuilder` only asserts on the generated text: it never resolves the
/// generated part against the input library's scope. Bugs where the emitted
/// code is well-formed Dart but does not resolve -- an unqualified type name
/// from a prefixed import, for example -- pass a text assertion and still
/// break every consumer.
///
/// So this builds a throwaway package with `reflection_factory` as a path
/// dependency, runs the real builder over it, and runs `dart analyze` on the
/// result.
void main() {
  group('generated code compiles', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('reflection_factory_e2e_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('with every kind of import', () async {
      var packageRoot = _getPackageRootDirectory().path;

      _write(tempDir, 'pubspec.yaml', '''
name: reflection_factory_e2e
environment:
  sdk: '>=3.10.0 <4.0.0'
dependencies:
  reflection_factory:
    path: $packageRoot
  mime: ^2.0.0
dev_dependencies:
  build_runner: ^2.15.0
''');

      _write(tempDir, 'lib/plain.dart', '''
class PlainA {
  int a;
  PlainA(this.a);
}

class PlainB {
  int b;
  PlainB(this.b);
}
''');

      _write(tempDir, 'lib/shown.dart', '''
class ShownOnly {
  int s;
  ShownOnly(this.s);
}

class NotShown {
  int n;
  NotShown(this.n);
}
''');

      _write(tempDir, 'lib/deep.dart', '''
class Deep {
  int d;
  Deep(this.d);
}
''');

      _write(tempDir, 'lib/facade.dart', '''
export 'deep.dart';

class Facade {
  int f;
  Facade(this.f);
}
''');

      _write(tempDir, 'lib/other.dart', '''
class Other {
  int v;
  Other(this.v);
}

class Hidden {
  int h;
  Hidden(this.h);
}

enum Flavor { sweet, salty }
''');

      // Every way a type can be reached from the input library:
      //   unprefixed  -> `plain.dart`, `shown.dart` (show), `other.dart` (hide)
      //   declared    -> `Local`
      //   prefixed    -> `other.dart` (o), `facade.dart` (f), `package:mime`
      //   re-exported -> `Deep`, reached through the prefixed `facade.dart`
      _write(tempDir, 'lib/foo.dart', '''
import 'package:reflection_factory/reflection_factory.dart';
import 'package:mime/mime.dart' as mime;

import 'plain.dart';
import 'shown.dart' show ShownOnly;
import 'facade.dart' as f;
import 'other.dart' as o;
import 'other.dart' hide Other, Flavor;

part 'foo.reflection.g.dart';

class Local {
  int l;
  Local(this.l);
}

@EnableReflection()
class Holder<T extends o.Other> {
  int count;
  String label;
  PlainA? plainA;
  PlainB? plainB;
  ShownOnly? shown;
  Local? local;
  Hidden? hidden;

  o.Other? other;
  o.Flavor? flavor;
  f.Deep? deep;
  f.Facade? facade;
  mime.MimeTypeResolver? resolver;

  List<o.Other>? many;
  Map<String, o.Other>? byName;
  Map<PlainA, List<f.Deep>>? nested;
  T? bounded;
  // A settable function type with the class type parameter: reflected as
  // `dynamic` (`T` isn't in scope), so its generated setter compiles.
  T Function()? maker;

  Holder(this.count, this.label);

  o.Other? echo(o.Other? v, PlainA? p) => v;
}
''');

      await _run('dart', ['pub', 'get'], tempDir);

      await _run('dart', ['run', 'build_runner', 'build'], tempDir);

      var generated = File(
        pack_path.join(tempDir.path, 'lib', 'foo.reflection.g.dart'),
      );
      expect(generated.existsSync(), isTrue, reason: 'no generated output');

      var code = generated.readAsStringSync();

      // Asserted explicitly as well as compiled, so a failure says *what* went
      // wrong instead of only that analysis failed.
      for (var qualified in [
        'o.Other',
        'o.Flavor',
        'f.Deep',
        'f.Facade',
        'mime.MimeTypeResolver',
      ]) {
        expect(code, contains(qualified), reason: 'missing $qualified');
      }

      for (var unqualified in [
        'PlainA',
        'PlainB',
        'ShownOnly',
        'Local',
        'Hidden',
      ]) {
        expect(code, contains(unqualified), reason: 'missing $unqualified');
      }

      // Nothing reachable unprefixed may pick up a prefix.
      for (var wrong in [
        'o.PlainA',
        'o.Hidden',
        'o.Local',
        'f.PlainA',
        'o.int',
        'o.String',
        'mime.int',
      ]) {
        expect(code, isNot(contains(wrong)), reason: 'wrongly emitted $wrong');
      }

      var analyze = await _run(
        'dart',
        ['analyze'],
        tempDir,
        expectSuccess: false,
      );

      expect(
        analyze.exitCode,
        equals(0),
        reason:
            'the generated code does not compile:\n'
            '${analyze.stdout}\n${analyze.stderr}',
      );
    }, timeout: Timeout(Duration(minutes: 5)));

    // The constructor `invoker`s: they cast their arguments (`strict-casts`,
    // `avoid_dynamic_calls`) and write the default values of omitted
    // parameters in their parameters' type context. A default can come from
    // a prefixed import, from a static member referenced by its bare name, or
    // be inherited by a super-parameter from another library.
    test('constructor invokers: strict analysis and runtime', () async {
      var packageRoot = _getPackageRootDirectory().path;

      _write(tempDir, 'pubspec.yaml', '''
name: reflection_factory_e2e
environment:
  sdk: '>=3.10.0 <4.0.0'
dependencies:
  reflection_factory:
    path: $packageRoot
dev_dependencies:
  build_runner: ^2.15.0
''');

      _write(tempDir, 'analysis_options.yaml', '''
analyzer:
  language:
    strict-casts: true
linter:
  rules:
    - avoid_dynamic_calls
''');

      _write(tempDir, 'lib/other.dart', '''
enum Flavor { sweet, salty }

const int kBonus = 5;

class Base {
  final int level;
  Base({this.level = 4});
}

class Ref<T> {
  final T? value;
  const Ref(this.value);
}

int triple(int n) => n * 3;
''');

      _write(tempDir, 'lib/foo.dart', '''
import 'package:reflection_factory/reflection_factory.dart';

import 'other.dart' as o;

part 'foo.reflection.g.dart';

typedef Check = bool Function(int n);

@EnableReflection()
class Order {
  static const int defaultQty = 2;

  final String id;
  final double price;
  final int qty;
  final List<String> tags;
  final Map<String, int> counts;
  final o.Flavor flavor;
  final int bonus;
  final Duration ttl;
  final Check? check;

  Order(
    this.id, {
    this.price = 0,
    this.qty = defaultQty,
    this.tags = const [],
    this.counts = const {},
    this.flavor = o.Flavor.sweet,
    this.bonus = o.kBonus,
    this.ttl = const Duration(seconds: 5),
    this.check,
  });
}

@EnableReflection()
class Sub extends o.Base {
  Sub({super.level});
}

@EnableReflection()
class Box<T> {
  final List<T> items;
  final T Function()? make;
  // Settable, with the class type parameter: reflected through the raw
  // receiver (`dynamic Function()?`), so its setter compiles (strict-casts).
  T Function()? fallback;
  // Settable, unbounded `T`: `dynamic` and `List<dynamic>`.
  T? value;
  List<T> values = [];

  Box(this.items, {this.make, this.fallback});
}

// The type argument given: `int?`, `List<int>`, `int Function()?`.
@EnableReflection()
class IntBox extends Box<int> {
  IntBox(super.items);
}

// A bound from a prefixed import, and function parameters of every kind:
// reflected as `o.Base Function(int, {required bool flag, String? label})?`
// and `o.Base Function(int, [String?])?`.
@EnableReflection()
class Builder<T extends o.Base> {
  T Function(int n, {required bool flag, String? label})? build;
  T Function(int n, [String? label])? buildOptional;
  // Nullability: a non-nullable function type, nullable return and parameter
  // types, and a nullable function type as a parameter.
  T Function() make;
  T? Function(T? input)? maybe;
  void Function(T Function()? inner)? nested;
  // Settable, with the bound: `o.Base?`, `List<o.Base>` and
  // `Map<String, o.Base Function()?>` (setters that compile under
  // strict-casts: they receive the type they assign).
  T? current;
  List<T> all = [];
  Map<String, T Function()?> byName = {};
  // A `typedef` in a parameter keeps its name: `void Function(Check, o.Base)?`.
  void Function(Check c, T t)? withCheck;

  Builder(this.make);
}

// Parameters typed by a generic class from a prefixed import with a type
// argument (as an entity reference), records, and function defaults: a
// static method by its bare name and a prefixed top-level function.
@EnableReflection()
class Shapes {
  static int identity(int n) => n;

  final o.Ref<o.Base> ref;
  final (int, o.Flavor) pair;
  final List<o.Base>? bases;
  final Map<String, dynamic>? extra;
  final int Function(int) mapper;
  final int Function(int) mapper2;
  final o.Ref<int> constRef;

  Shapes(
    this.ref,
    this.pair, {
    this.bases,
    this.extra,
    this.mapper = identity,
    this.mapper2 = o.triple,
    this.constRef = const o.Ref(1),
  });
}
''');

      _write(tempDir, 'bin/main.dart', r'''
import 'package:reflection_factory/reflection_factory.dart';
import 'package:reflection_factory_e2e/foo.dart';
import 'package:reflection_factory_e2e/other.dart';

void main() {
  void show(String path, Order o) {
    print('$path: price=${o.price is double}:${o.price} qty=${o.qty} '
        'tags=${o.tags is List<String>}:${o.tags} '
        'counts=${o.counts is Map<String, int>} '
        'flavor=${o.flavor == Flavor.sweet} bonus=${o.bonus} '
        'ttl=${o.ttl.inSeconds} check=${o.check == null}');
  }

  var reflection = Order$reflection();

  // Without a `fieldValueResolver`: called straight from the map.
  show('direct', reflection.createInstanceFromMap({'id': 'a'})!);
  // With one (JSON): through a `MethodInvocation` and `invokeWith`.
  show('json', Order$fromJson({'id': 'a'}));

  var o = reflection.createInstanceFromMap({
    'id': 'b',
    'price': 1.5,
    'check': (int n) => n > 0,
  })!;
  print('given: price=${o.price} check=${o.check!(1)}');

  print('sub: level=${Sub$reflection().createInstanceFromMap({})!.level}');

  var box = Box$reflection().createInstanceFromMap({
    'items': [1, 2],
  })!;
  print('box: items=${box.items} invoker=${Box$reflection().constructor('')!.invoker == null ? 'none' : 'yes'}');

  // The function-typed field, through its reflection:
  var fallback = Box$reflection(box).field('fallback')!;
  fallback.set(() => 3);
  print('fallback: ${box.fallback!()} ${fallback.get()!()}');

  var builder = Builder(() => Base(level: 1));
  var builderReflection = Builder$reflection(builder);
  builderReflection.field('maybe')!.set((Base? b) => b);
  builderReflection.field('make')!.set(() => Base(level: 2));
  print('nullability: ${builder.make().level} '
      '${builder.maybe!(null) == null} '
      '${builderReflection.field('nested')!.nullable} '
      '${builderReflection.field('make')!.nullable}');
  Builder$reflection(builder).field('build')!.set(
    (int n, {required bool flag, String? label}) => Base(level: n),
  );
  Builder$reflection(builder).field('buildOptional')!.set(
    (int n, [String? label]) => Base(level: n + 1),
  );
  print('build: ${builder.build!(7, flag: true).level} '
      '${builder.buildOptional!(7).level}');

  // `T` and `List<T>` fields, set through their reflection:
  var boxReflection = Box$reflection(box);
  boxReflection.field('value')!.set(9);
  boxReflection.field('values')!.set([1, 2]);
  builderReflection.field('current')!.set(Base(level: 3));
  builderReflection.field('all')!.set([Base(level: 4)]);
  builderReflection.field('byName')!.set({'a': () => Base(level: 5)});
  print('typed: ${box.value} ${box.values} ${builder.current!.level} '
      '${builder.all.map((b) => b.level).toList()} '
      '${builder.byName['a']!().level} ${builder.byName.keys.single}');

  var intBox = IntBox$reflection().createInstanceFromMap({
    'items': [7],
  })!;
  var intBoxReflection = IntBox$reflection(intBox);
  intBoxReflection.field('value')!.set(6);
  intBoxReflection.field('values')!.set([8]);
  print('int box: ${intBox.value} ${intBox.items} ${intBox.values} '
      '${intBoxReflection.field('values') is FieldReflection<IntBox, List<int>>}');

  var shapes = Shapes$reflection().createInstanceFromMap({
    'ref': Ref<Base>(Base(level: 6)),
    'pair': (1, Flavor.salty),
  }, valuesResolved: true)!;
  print('shapes: ${shapes.ref.value!.level} ${shapes.pair} '
      '${shapes.bases} ${shapes.mapper(2)} ${shapes.mapper2(2)} '
      '${shapes.constRef.value}');
}
''');

      await _run('dart', ['pub', 'get'], tempDir);
      await _run('dart', ['run', 'build_runner', 'build'], tempDir);

      var code = File(
        pack_path.join(tempDir.path, 'lib', 'foo.reflection.g.dart'),
      ).readAsStringSync();

      // Defaults as written, qualified where needed:
      expect(code, contains('Order.defaultQty'));
      expect(code, contains('o.Flavor.sweet'));
      expect(code, contains('o.kBonus'));
      // Typed arguments:
      expect(code, contains('as String'));
      expect(code, contains(r'__argOr$<Check?>('));
      expect(code, contains('as o.Ref<o.Base>'));
      expect(code, contains('as (int, o.Flavor)'));
      expect(code, contains('Shapes.identity'));
      expect(code, contains('o.triple'));

      // Function-typed fields with the class type parameter, through the raw
      // receiver (the bound), with qualified types:
      // (Compared without whitespace: `dart format` breaks them variously.)
      String compact(String s) => s.replaceAll(RegExp(r'\s+'), '');
      var codeCompact = compact(code);
      for (var fieldType in [
        'FieldReflection<Box, dynamic Function()?>',
        'FieldReflection<Builder, o.Base Function(int, {required bool flag, String? label})?>',
        'FieldReflection<Builder, o.Base Function(int, [String?])?>',
        // Nullability as declared:
        'FieldReflection<Builder, o.Base Function()>',
        'FieldReflection<Builder, o.Base? Function(o.Base?)?>',
        'FieldReflection<Builder, void Function(o.Base Function()?)?>',
        // `T` and `List<T>` fields, through the raw class:
        'FieldReflection<Box, dynamic>',
        'FieldReflection<Box, List<dynamic>>',
        'FieldReflection<Builder, o.Base?>',
        'FieldReflection<Builder, List<o.Base>>',
        'FieldReflection<Builder, Map<String, o.Base Function()?>>',
        'FieldReflection<Builder, void Function(Check, o.Base)?>',
        // With the type argument (inherited fields):
        'FieldReflection<IntBox, int?>',
        'FieldReflection<IntBox, List<int>>',
        'FieldReflection<IntBox, int Function()?>',
      ]) {
        expect(codeCompact, contains(compact(fieldType)), reason: fieldType);
      }

      // `lib/`: the generated code (`bin/` checks types on purpose).
      var analyze = await _run(
        'dart',
        ['analyze', '--fatal-infos', 'lib'],
        tempDir,
        expectSuccess: false,
      );

      expect(
        analyze.exitCode,
        equals(0),
        reason:
            'the generated code has issues under strict analysis:\n'
            '${analyze.stdout}\n${analyze.stderr}',
      );

      var run = await _run('dart', ['run', 'bin/main.dart'], tempDir);
      var output = '${run.stdout}'.trim().split('\n');

      const defaults =
          'price=true:0.0 qty=2 tags=true:[] counts=true flavor=true '
          'bonus=5 ttl=5 check=true';

      expect(
        output,
        equals([
          'direct: $defaults',
          'json: $defaults',
          'given: price=1.5 check=true',
          'sub: level=4',
          'box: items=[1, 2] invoker=none',
          'fallback: 3 3',
          'nullability: 2 true true false',
          'build: 7 8',
          'typed: 9 [1, 2] 3 [4] 5 a',
          'int box: 6 [7] [8] true',
          'shapes: 6 (1, Flavor.salty) null 2 6 1',
        ]),
      );
    }, timeout: Timeout(Duration(minutes: 5)));
  });
}

void _write(Directory root, String relativePath, String content) {
  var file = File(pack_path.join(root.path, relativePath));
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(content);
}

Future<ProcessResult> _run(
  String executable,
  List<String> arguments,
  Directory workingDirectory, {
  bool expectSuccess = true,
}) async {
  var result = await Process.run(
    executable,
    arguments,
    workingDirectory: workingDirectory.path,
    runInShell: true,
  );

  if (expectSuccess && result.exitCode != 0) {
    fail(
      '`$executable ${arguments.join(' ')}` failed '
      '(exit ${result.exitCode}):\n${result.stdout}\n${result.stderr}',
    );
  }

  return result;
}

Directory _getPackageRootDirectory() {
  var refFile = 'test/reflection_factory_generated_code_test.dart';

  for (var p in [
    '.',
    '..',
    './reflection_factory',
    '../reflection_factory',
    '../../reflection_factory',
  ]) {
    var file = File('$p/$refFile');

    if (file.existsSync()) {
      return file.absolute.parent.parent;
    }
  }

  return Directory.current.absolute;
}
