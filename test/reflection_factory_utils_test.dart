import 'package:reflection_factory/src/reflection_factory_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Utils', () {
    test('ListSortedByUsage', () {
      var l = ListSortedByUsage(['a', 'b', 'c']);

      expect(l.sortedByUsage(), ['a', 'b', 'c']);

      l.notifyUsage('b');
      expect(l.sortedByUsage(), ['b', 'a', 'c']);

      l.notifyUsage('c');
      expect(l.sortedByUsage(), ['b', 'c', 'a']);

      l.notifyUsage('b');
      expect(l.sortedByUsage(), ['b', 'c', 'a']);

      l.notifyUsage('b');
      expect(l.sortedByUsage(), ['b', 'c', 'a']);

      l.notifyUsage('b');
      expect(l.sortedByUsage(), ['b', 'c', 'a']);

      l.notifyUsage('c');
      expect(l.sortedByUsage(), ['b', 'c', 'a']);

      l.notifyUsage('c');
      l.notifyUsage('c');
      expect(l.sortedByUsage(), ['b', 'c', 'a']);

      l.notifyUsage('a');
      expect(l.sortedByUsage(), ['b', 'c', 'a']);

      l.notifyUsage('c');
      expect(l.sortedByUsage(), ['c', 'b', 'a']);

      expect(l, ['a', 'b', 'c']);
    });

    test('ListSortedByUsage: unknown element', () {
      var l = ListSortedByUsage(['a', 'b', 'c']);

      expect(l.notifyUsage('z'), isFalse);
      expect(l.notifyUsage('a'), isTrue);

      // An unknown element must not affect the ordering:
      expect(l.sortedByUsage(), ['a', 'b', 'c']);
    });

    test('ListSortedByUsage: empty list', () {
      var l = ListSortedByUsage(<String>[]);

      expect(l.notifyUsage('a'), isFalse);
      expect(l.sortedByUsage(), isEmpty);
    });

    test('ListSortedByUsage: without usage returns itself', () {
      var l = ListSortedByUsage(['a', 'b', 'c']);

      // With no usage counter the same instance is returned:
      expect(l.sortedByUsage(), same(l));
    });

    test('ListSortedByUsage: result is cached until the order can change', () {
      var l = ListSortedByUsage(['a', 'b', 'c']);

      l.notifyUsage('b');

      var sorted1 = l.sortedByUsage();
      expect(sorted1, ['b', 'a', 'c']);

      // Re-using the 1st element can't change the order: cache is kept.
      l.notifyUsage('b');
      expect(l.sortedByUsage(), same(sorted1));

      // Using another element may change the order: cache is invalidated.
      l.notifyUsage('c');
      l.notifyUsage('c');
      l.notifyUsage('c');
      var sorted2 = l.sortedByUsage();
      expect(sorted2, isNot(same(sorted1)));
      expect(sorted2, ['c', 'b', 'a']);
    });

    test('ListSortedByUsage.clampCount: shifts by the minimum count', () {
      var l = ListSortedByUsage(['a', 'b', 'c']);

      var counter = [5, 10, 15];
      l.clampCount(counter);

      expect(counter, equals([0, 5, 10]));
    });

    test('ListSortedByUsage.clampCount: no shift when the minimum is 0', () {
      var l = ListSortedByUsage(['a', 'b']);

      var counter = [0, 3];
      l.clampCount(counter);

      expect(counter, equals([0, 3]));
    });

    test('ListSortedByUsage.clampCount: re-scales above the limit', () {
      var l = ListSortedByUsage(['a', 'b']);

      var counter = [0, 20000];
      l.clampCount(counter);

      expect(counter, equals([0, 9999]));
    });

    test('ListSortedByUsage.clampCount: shifts and re-scales', () {
      var l = ListSortedByUsage(['a', 'b', 'c']);

      // Shifted to [0, 10000, 20000], then re-scaled by 9999/20000.
      var counter = [10000, 20000, 30000];
      l.clampCount(counter);

      expect(counter, equals([0, 4999, 9999]));
    });

    test('ListSortedByUsage.clampCount: preserves the relative order', () {
      var l = ListSortedByUsage(['a', 'b', 'c', 'd']);

      var counter = [30000, 10000, 40000, 20000];
      l.clampCount(counter);

      expect(counter.every((c) => c >= 0 && c <= 9999), isTrue);
      // Same ranking as the original counts:
      expect(counter[2] > counter[0], isTrue);
      expect(counter[0] > counter[3], isTrue);
      expect(counter[3] > counter[1], isTrue);
    });

    test('ListSortedByUsage.clampCount: equal counts collapse to zero', () {
      var l = ListSortedByUsage(['a', 'b']);

      var counter = [7, 7];
      l.clampCount(counter);

      expect(counter, equals([0, 0]));
    });

    test('ListSortedByUsage: is unmodifiable', () {
      var l = ListSortedByUsage(['a', 'b']);

      expect(() => l.add('c'), throwsUnsupportedError);
      expect(() => l[0] = 'z', throwsUnsupportedError);
    });
  });
}
