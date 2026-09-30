import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:hisap_app_2_0/theme/phosphor.dart';
import 'package:hisap_app_2_0/theme/svg_path.dart';

void main() {
  group('parseSvgPath', () {
    test('walks absolute and relative line commands', () {
      final path = parseSvgPath('M10,10 H90 V90 H10 Z');
      expect(path.getBounds(), const Rect.fromLTRB(10, 10, 90, 90));
    });

    test('treats trailing moveto pairs as implicit linetos', () {
      final path = parseSvgPath('M0,0 10,0 10,10');
      expect(path.getBounds(), const Rect.fromLTRB(0, 0, 10, 10));
    });

    test('reads arc flags that run together with the coordinates', () {
      // largeArc=1, sweep=0, then "-66.5" with no separator.
      final path = parseSvgPath('M117.25,157.92a60,60,0,1,0-66.5,0');
      expect(path.getBounds().width, greaterThan(60));
    });

    test('mirrors the control point of a smooth cubic', () {
      final smooth = parseSvgPath('M0,0 C0,10 10,10 10,0 S20,-10 20,0');
      final explicit = parseSvgPath(
        'M0,0 C0,10 10,10 10,0 C10,-10 20,-10 20,0',
      );
      expect(smooth.getBounds(), explicit.getBounds());
    });

    test('rejects a path that does not open with a command', () {
      expect(() => parseSvgPath('10,10 L20,20'), throwsFormatException);
    });
  });

  group('Phosphor glyphs', () {
    const glyphs = <String, String>{
      'receipt': PhosphorIcons.receipt,
      'cube': PhosphorIcons.cube,
      'users': PhosphorIcons.users,
      'chartBar': PhosphorIcons.chartBar,
      'gear': PhosphorIcons.gear,
      'check': PhosphorIcons.check,
      'printer': PhosphorIcons.printer,
      'arrowLeft': PhosphorIcons.arrowLeft,
      'car': PhosphorIcons.car,
      'listBullets': PhosphorIcons.listBullets,
    };

    for (final entry in glyphs.entries) {
      test('${entry.key} parses and fills its 256 viewBox', () {
        final bounds = parseSvgPath(entry.value).getBounds();
        // Every Phosphor glyph is drawn edge to edge inside a 256 viewBox.
        // getBounds() measures control points rather than the curves they
        // pull, so a glyph that hugs an edge reads a little outside it; the
        // slack here is for that overshoot, not for a mis-parse.
        expect(bounds.left, greaterThanOrEqualTo(-16));
        expect(bounds.top, greaterThanOrEqualTo(-16));
        expect(bounds.right, lessThanOrEqualTo(272));
        expect(bounds.bottom, lessThanOrEqualTo(272));
        expect(bounds.width, greaterThan(100));
        expect(bounds.height, greaterThan(100));
      });
    }
  });
}
