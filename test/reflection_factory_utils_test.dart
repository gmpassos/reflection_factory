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
  });
}
