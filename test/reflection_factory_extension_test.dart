import 'package:reflection_factory/reflection_factory.dart';
import 'package:test/test.dart';

void main() {
  group('extensions', () {
    test('tryParseDuration', () {
      expect(Duration(hours: 10).toHumanReadable(), equals('10 h'));
      expect(Duration(hours: 3).toHumanReadable(), equals('3 h'));
      expect(Duration(hours: 0).toHumanReadable(), equals('0'));

      expect(Duration(minutes: 10).toHumanReadable(), equals('10 min'));
      expect(Duration(minutes: 3).toHumanReadable(), equals('3 min'));
      expect(Duration(minutes: 0).toHumanReadable(), equals('0'));

      expect(Duration(seconds: 10).toHumanReadable(), equals('10 sec'));
      expect(Duration(seconds: 3).toHumanReadable(), equals('3 sec'));

      expect(Duration(milliseconds: 10).toHumanReadable(), equals('10 ms'));
      expect(Duration(milliseconds: 3).toHumanReadable(), equals('3 ms'));

      expect(Duration(minutes: 4, seconds: 11).toHumanReadable(),
          equals('4 min 11 sec'));

      expect(Duration(hours: 3, minutes: 4, seconds: 11).toHumanReadable(),
          equals('3 h 4 min 11 sec'));

      expect(
          Duration(hours: 3, minutes: 4, seconds: 11, milliseconds: 101)
              .toHumanReadable(),
          equals('3 h 4 min 11 sec 101 ms'));

      expect(
          Duration(hours: 3, minutes: 0, seconds: 11, milliseconds: 101)
              .toHumanReadable(),
          equals('3 h 0 min 11 sec 101 ms'));

      expect(
          Duration(hours: 3, minutes: 0, seconds: 0, milliseconds: 101)
              .toHumanReadable(),
          equals('3 h 0 min 0 sec 101 ms'));

      expect(
          Duration(hours: 3, minutes: 4, seconds: 0, milliseconds: 101)
              .toHumanReadable(),
          equals('3 h 4 min 0 sec 101 ms'));

      expect(
          Duration(hours: 3, minutes: 4, seconds: 0, milliseconds: 0)
              .toHumanReadable(),
          equals('3 h 4 min'));
    });

    test('tryParseDuration', () {
      expect(tryParseDuration('10 h'), Duration(hours: 10));
      expect(tryParseDuration('10 hr'), Duration(hours: 10));
      expect(tryParseDuration('11 hour'), Duration(hours: 11));
      expect(tryParseDuration('12 hours'), Duration(hours: 12));

      expect(tryParseDuration('10min'), Duration(minutes: 10));
      expect(tryParseDuration('11minutes'), Duration(minutes: 11));
      expect(tryParseDuration('12 minute'), Duration(minutes: 12));

      expect(tryParseDuration('10sec'), Duration(seconds: 10));
      expect(tryParseDuration(' 11 s'), Duration(seconds: 11));
      expect(tryParseDuration('12 second '), Duration(seconds: 12));
      expect(tryParseDuration(' 13 seconds '), Duration(seconds: 13));

      expect(tryParseDuration('10 ms'), Duration(milliseconds: 10));
      expect(tryParseDuration(' 11 millisecond'), Duration(milliseconds: 11));
      expect(tryParseDuration('12 milliseconds '), Duration(milliseconds: 12));

      expect(tryParseDuration('101'), Duration(milliseconds: 101));

      expect(
          tryParseDuration('', Duration(seconds: 103)), Duration(seconds: 103));
      expect(tryParseDuration('x', Duration(seconds: 104)),
          Duration(seconds: 104));
    });
  });
}
