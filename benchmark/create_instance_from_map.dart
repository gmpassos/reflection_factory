// Benchmarks `ClassReflection.createInstanceFromMap` and `fromJson`.
//
// Run with:
//   dart run benchmark/create_instance_from_map.dart --repeat 5
//
// With `--markdown` it prints an entry for `benchmark/HISTORY.md`.
// See `benchmark/README.md`.

import 'dart:io';

import 'package:reflection_factory/reflection_factory.dart';

import '../test/src/instantiate_fixture.dart';

final createdAt = DateTime.utc(2026, 1, 2, 3, 4, 5);

final accountMap = <String, Object?>{
  'id': 101,
  'name': 'Joe',
  'email': 'joe@mail.com',
  'phone': '+1 555 0101',
  'age': 33,
  'score': 9.5,
  'active': true,
  'createdAt': createdAt,
};

final accountJson = <String, Object?>{
  ...accountMap,
  'createdAt': createdAt.toIso8601String(),
};

final memberMap = <String, Object?>{
  'id': 102,
  'name': 'Ann',
  'email': 'ann@mail.com',
  'passwordHash': 'hash:abc',
  'age': 41,
  'score': 7.25,
  'active': false,
  'createdAt': createdAt,
};

class Case {
  final String name;
  final Object? Function() run;

  Case(this.name, this.run);
}

List<Case> cases() {
  var account = TestAccountWithReflection$reflection();
  var member = TestMemberWithReflection$reflection();

  return [
    Case(
      'account: constructor',
      () => account.createInstanceFromMap(accountMap),
    ),
    Case(
      'account: constructor (valuesResolved, exactKeys)',
      () => account.createInstanceFromMap(
        accountMap,
        valuesResolved: true,
        exactKeys: true,
      ),
    ),
    Case('account: fromJson', () => account.fromJson(accountJson)),
    Case(
      'member: create + setters',
      () => member.createInstanceFromMap(memberMap),
    ),
    Case(
      'member: create + setters (valuesResolved, exactKeys)',
      () => member.createInstanceFromMap(
        memberMap,
        valuesResolved: true,
        exactKeys: true,
      ),
    ),
  ];
}

class Result {
  final String name;

  /// ns/op of each round, in the order they ran.
  final List<double> rounds;

  Result(this.name, this.rounds);

  List<double> get _sorted => rounds.toList()..sort();

  double get median => _sorted[rounds.length ~/ 2];
  double get min => _sorted.first;
  double get max => _sorted.last;

  double get opsPerSec => 1e9 / median;
}

/// Calls [f] for [duration], in batches, and returns its ns/op.
double measure(Object? Function() f, Duration duration) {
  const batch = 1000;
  var limit = duration.inMicroseconds;
  var sw = Stopwatch()..start();
  var ops = 0;
  do {
    for (var i = 0; i < batch; ++i) {
      f();
    }
    ops += batch;
  } while (sw.elapsedMicroseconds < limit);
  sw.stop();
  return sw.elapsedMicroseconds * 1000 / ops;
}

void main(List<String> args) {
  var repeat = int.parse(_option(args, 'repeat') ?? '5');
  var duration = Duration(
    milliseconds: (double.parse(_option(args, 'duration') ?? '1') * 1000)
        .round(),
  );
  var markdown = args.contains('--markdown');
  var machine = _option(args, 'machine') ?? _machineModel();

  var results = <Result>[];

  for (var c in cases()) {
    // Warm-up (JIT compilation and caches):
    measure(c.run, duration);

    var rounds = [for (var r = 0; r < repeat; ++r) measure(c.run, duration)];
    var result = Result(c.name, rounds);
    results.add(result);

    if (!markdown) {
      print(
        '${c.name}: ${result.median.toStringAsFixed(0)} ns/op '
        '(${result.opsPerSec.toStringAsFixed(0)} ops/sec; '
        'rounds: ${result.min.toStringAsFixed(0)}–'
        '${result.max.toStringAsFixed(0)} ns/op)',
      );
    }
  }

  if (markdown) {
    print(_toMarkdown(results, machine, repeat, duration));
  }
}

String _toMarkdown(
  List<Result> results,
  String? machine,
  int repeat,
  Duration duration,
) {
  var date = DateTime.now().toIso8601String().substring(0, 10);
  var commit = _gitCommit();
  var aot = const bool.fromEnvironment('dart.vm.product');

  var s = StringBuffer();
  s.writeln('### $date — ${machine ?? '?'}');
  s.writeln();
  s.writeln(
    '- **reflection_factory:** ${ReflectionFactory.VERSION}'
    '${commit != null ? ' (`$commit`)' : ''}',
  );
  s.writeln(
    '- **Machine:** ${machine ?? '?'}, ${_cpu() ?? '?'}, '
    '${Platform.numberOfProcessors} cores, ${_memory()} RAM',
  );
  s.writeln(
    '- **OS:** ${Platform.operatingSystem} '
    '(${Platform.operatingSystemVersion})',
  );
  s.writeln(
    '- **Dart:** ${Platform.version.split(' ').first} '
    '(${aot ? 'AOT, `dart compile exe`' : 'JIT, `dart run`'})',
  );
  s.writeln(
    '- **Rounds:** ${duration.inMilliseconds / 1000}s '
    '(warm-up ${duration.inMilliseconds / 1000}s) × $repeat, '
    'median shown per case',
  );
  s.writeln();
  s.writeln('| Case | ns/op | ops/sec | rounds (ns/op) |');
  s.writeln('|---|--:|--:|--:|');
  for (var r in results) {
    s.writeln(
      '| `${r.name}` | ${r.median.toStringAsFixed(0)} '
      '| ${r.opsPerSec.toStringAsFixed(0)} '
      '| ${r.min.toStringAsFixed(0)}–${r.max.toStringAsFixed(0)} |',
    );
  }
  return s.toString();
}

String? _option(List<String> args, String name) {
  for (var i = 0; i < args.length; ++i) {
    var a = args[i];
    if (a.startsWith('--$name=')) return a.substring(name.length + 3);
    if (a == '--$name' && i + 1 < args.length) return args[i + 1];
  }
  return null;
}

String? _machineModel() {
  if (!Platform.isMacOS) return null;
  var model = _run('sysctl', ['-n', 'hw.model']);
  var cpu = _cpu();
  if (model == null) return cpu;
  return cpu != null ? '$model ($cpu)' : model;
}

String? _cpu() {
  if (Platform.isMacOS) {
    return _run('sysctl', ['-n', 'machdep.cpu.brand_string']);
  } else if (Platform.isLinux) {
    try {
      var line = File('/proc/cpuinfo')
          .readAsLinesSync()
          .where((l) => l.startsWith('model name'))
          .firstOrNull;
      return line?.split(':').skip(1).join(':').trim();
    } catch (_) {
      return null;
    }
  }
  return null;
}

String _memory() {
  int? bytes;
  if (Platform.isMacOS) {
    bytes = int.tryParse(_run('sysctl', ['-n', 'hw.memsize']) ?? '');
  } else if (Platform.isLinux) {
    try {
      var line = File('/proc/meminfo')
          .readAsLinesSync()
          .where((l) => l.startsWith('MemTotal:'))
          .firstOrNull;
      var kb = int.tryParse(line?.replaceAll(RegExp(r'[^0-9]'), '') ?? '');
      if (kb != null) bytes = kb * 1024;
    } catch (_) {}
  }
  return bytes == null
      ? '?'
      : '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(0)} GB';
}

/// The current `git` commit (short hash), marked `(modified)` when the
/// working tree has uncommitted changes.
String? _gitCommit() {
  var hash = _run('git', ['rev-parse', '--short', 'HEAD']);
  if (hash == null) return null;
  var dirty = _run('git', ['status', '--porcelain']) != null;
  return dirty ? '$hash (modified)' : hash;
}

String? _run(String executable, List<String> args) {
  try {
    var result = Process.runSync(executable, args);
    if (result.exitCode != 0) return null;
    var out = '${result.stdout}'.trim();
    return out.isEmpty ? null : out;
  } catch (_) {
    return null;
  }
}
