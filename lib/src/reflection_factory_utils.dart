import 'package:collection/collection.dart';

/// An [UnmodifiableListView] that counts usage of elements and can return
/// a sorted list by usage.
class ListSortedByUsage<E> extends UnmodifiableListView<E> {
  ListSortedByUsage(Iterable<E> source) : super(source);

  List<int>? _usageCounter;

  /// Notifies the usage of [element] (increments it's counting).
  bool notifyUsage(E element) {
    var idx = indexOf(element);
    if (idx < 0) return false;

    var usageCounter = _usageCounter ??= List.filled(length, 0);

    var count = ++usageCounter[idx];

    // Avoid count overflow for long lived instances:
    if (count > _countOverflowLimit) {
      _clampCount(usageCounter);
    }

    var sortedByUsage = _sortedByUsage;
    if (sortedByUsage != null) {
      // If the used `element` is the 1st of the sorted list the
      // order won't be affected.
      if (sortedByUsage.first != element) {
        _sortedByUsage = null;
      }
    }

    return true;
  }

  static const _countOverflowLimit = 1999999999;
  static const _countClampLimit = 9999;

  void _clampCount(List<int> usageCounter) {
    final length = usageCounter.length;

    final min = usageCounter.min;
    if (min > 0) {
      for (var i = 0; i < length; ++i) {
        usageCounter[i] -= min;
      }
    }

    final limit = _countClampLimit;

    final max = usageCounter.max;
    // If reached the limit re-scale the count values.
    if (max > limit) {
      for (var i = 0; i < length; ++i) {
        var c = usageCounter[i];
        usageCounter[i] = ((c / max) * limit).toInt();
      }
    }
  }

  UnmodifiableListView<E>? _sortedByUsage;

  /// Returns this list sorted by usage count.
  UnmodifiableListView<E> sortedByUsage() =>
      _sortedByUsage ??= _sortedByUsageIml();

  UnmodifiableListView<E> _sortedByUsageIml() {
    var usageCounter = _usageCounter;
    if (usageCounter == null) return this;

    var entries = mapIndexed((i, e) => MapEntry(e, usageCounter[i])).toList();

    entries.sort((a, b) => b.value.compareTo(a.value));

    return UnmodifiableListView(entries.map((e) => e.key));
  }
}
