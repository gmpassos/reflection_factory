# Benchmarks

## `create_instance_from_map.dart`

Times `ClassReflection.createInstanceFromMap` and `fromJson` on the
entities in [`test/src/instantiate_fixture.dart`](../test/src/instantiate_fixture.dart),
which have 8 fields each:

| Case | What runs |
|---|---|
| `account: constructor` | The main constructor (2 normal + 6 named parameters), with the default name resolution and no `fieldValueResolver`, so it's called straight from the map |
| `account: constructor (valuesResolved, exactKeys)` | The same, for a map whose keys and values are already resolved (e.g. DB rows) |
| `account: fromJson` | `ClassReflection.fromJson` of the same entity, with a `DateTime` as an ISO string |
| `member: create + setters` | No constructor matches the map (`passwordOrHash` ≠ `passwordHash`), so it creates an instance without arguments and sets the fields |
| `member: create + setters (valuesResolved, exactKeys)` | The same, with the options |

```bash
dart run benchmark/create_instance_from_map.dart --repeat 5
```

| Option | Default | |
|---|---|---|
| `--repeat` | `5` | Measured rounds per case: the median round is reported, with the range of all of them |
| `--duration` | `1` | Seconds per round; each case also warms up for one round first |
| `--markdown` | off | Print a [HISTORY.md](HISTORY.md) entry |
| `--machine` | the model and CPU (macOS) | A label for the machine |

Results from previous runs are in [HISTORY.md](HISTORY.md).

### Reading the results

- `ns/op` is the median round's mean time per call; `ops/sec` is `1s / ns/op`.
- Numbers are only comparable between runs on **the same machine**, ideally
  idle and on power, in the same mode: `dart run` (JIT, the default here) or
  a `dart compile exe` build (AOT), which gives different numbers.
- To compare two versions, alternate their runs: a machine's speed drifts.

### Recording a result

Commit first, so the entry names a commit without `(modified)`, then run
with `--markdown` and paste the printed entry at the top of the entries in
[HISTORY.md](HISTORY.md). Add its date's column to the progression table
there too.

```bash
dart run benchmark/create_instance_from_map.dart --repeat 5 --markdown
```

## `reflection_factory_benchmark.dart`

The `package:benchmark` suite (`dart run benchmark`): lookups of
constructors, fields and methods, `toJson`, `fromJson` and
`createInstanceFromMap`. It reports totals rounded for display, so use
`create_instance_from_map.dart` to compare versions.
