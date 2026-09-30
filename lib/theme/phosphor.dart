import 'package:flutter/widgets.dart';

import 'nocturne.dart';
import 'svg_path.dart';

/// The Phosphor glyphs the design uses, as their `d` attributes.
///
/// The system calls for Phosphor throughout; these are the exact paths from
/// the artboards, drawn rather than pulled in as a font so the app keeps its
/// empty dependency list.
abstract final class PhosphorIcons {
  static const receipt =
      'M224,48H32A16,16,0,0,0,16,64V192a16,16,0,0,0,16,16H224a16,16,0,0,0,'
      '16-16V64A16,16,0,0,0,224,48Zm0,144H32V64H224V192ZM56,96a8,8,0,0,1,8-8H192'
      'a8,8,0,0,1,0,16H64A8,8,0,0,1,56,96Zm0,32a8,8,0,0,1,8-8h64a8,8,0,0,1,0,16'
      'H64A8,8,0,0,1,56,128Zm0,32a8,8,0,0,1,8-8h40a8,8,0,0,1,0,16H64A8,8,0,0,1,'
      '56,160Z';

  static const cube =
      'M223.68,66.15,135.68,18a15.94,15.94,0,0,0-15.36,0l-88,48.17a16,16,0,0,0'
      '-8.32,14v95.64a16,16,0,0,0,8.32,14l88,48.17a15.88,15.88,0,0,0,15.36,0l88'
      '-48.17a16,16,0,0,0,8.32-14V80.18A16,16,0,0,0,223.68,66.15ZM128,32l80.34,'
      '44-29.77,16.3-80.35-44ZM128,120,47.66,76l33.9-18.56,80.34,44ZM40,90l80,'
      '43.78v85.79L40,175.82Zm176,85.78h0l-80,43.79V133.82l32-17.51V152a8,8,0,0,'
      '0,16,0V107.55L216,90v85.77Z';

  static const users =
      'M117.25,157.92a60,60,0,1,0-66.5,0A95.83,95.83,0,0,0,3.53,195.63a8,8,0,1,'
      '0,13.4,8.74,80,80,0,0,1,134.14,0,8,8,0,0,0,13.4-8.74A95.83,95.83,0,0,0,'
      '117.25,157.92ZM40,108a44,44,0,1,1,44,44A44.05,44.05,0,0,1,40,108Zm210.14,'
      '98.7a8,8,0,0,1-11.07-2.33A79.83,79.83,0,0,0,172,168a8,8,0,0,1,0-16,44,44,'
      '0,1,0-16.34-84.87,8,8,0,1,1-6.08-14.8,60,60,0,0,1,55.67,105.59,95.83,'
      '95.83,0,0,1,47.22,37.71A8,8,0,0,1,250.14,206.7Z';

  static const chartBar =
      'M224,200h-8V40a8,8,0,0,0-8-8H152a8,8,0,0,0-8,8V80H96a8,8,0,0,0-8,8v40H48'
      'a8,8,0,0,0-8,8v64H32a8,8,0,0,0,0,16H224a8,8,0,0,0,0-16ZM160,48h40V200H160'
      'Zm-56,48h40V200H104Zm-48,48H88v56H56Z';

  static const gear =
      'M128,80a48,48,0,1,0,48,48A48.05,48.05,0,0,0,128,80Zm0,80a32,32,0,1,1,32'
      '-32A32,32,0,0,1,128,160Zm88-32a87.4,87.4,0,0,0-1.2-14.3l20.7-16.2a8,8,0,'
      '0,0,2.2-9.8,104.2,104.2,0,0,0-20.9-28.9,8,8,0,0,0-9.8-1.3L182.6,71.1a88.6,'
      '88.6,0,0,0-24.9-14.4L153.9,31a8,8,0,0,0-7.4-6.7,105.5,105.5,0,0,0-37,0A8,'
      '8,0,0,0,102.1,31L98.3,56.7a88.6,88.6,0,0,0-24.9,14.4L49.2,59.5a8,8,0,0,0'
      '-9.8,1.3A104.2,104.2,0,0,0,18.5,89.7a8,8,0,0,0,2.2,9.8l20.7,16.2a89.1,'
      '89.1,0,0,0,0,24.6L20.7,156.5a8,8,0,0,0-2.2,9.8,104.2,104.2,0,0,0,20.9,'
      '28.9,8,8,0,0,0,9.8,1.3l24.2-11.6a88.6,88.6,0,0,0,24.9,14.4l3.8,25.7a8,8,'
      '0,0,0,7.4,6.7,105.5,105.5,0,0,0,37,0,8,8,0,0,0,7.4-6.7l3.8-25.7a88.6,'
      '88.6,0,0,0,24.9-14.4l24.2,11.6a8,8,0,0,0,9.8-1.3,104.2,104.2,0,0,0,20.9'
      '-28.9,8,8,0,0,0-2.2-9.8l-20.7-16.2A87.4,87.4,0,0,0,216,128Z';

  static const check =
      'M229.66,77.66l-128,128a8,8,0,0,1-11.32,0l-56-56a8,8,0,0,1,11.32-11.32L96,'
      '188.69,218.34,66.34a8,8,0,0,1,11.32,11.32Z';

  static const printer =
      'M214.67,72H192V40a8,8,0,0,0-8-8H72a8,8,0,0,0-8,8V72H41.33A17.36,17.36,0,0,'
      '0,24,89.33v70.34A17.36,17.36,0,0,0,41.33,177H64v39a8,8,0,0,0,8,8H184a8,8,0,'
      '0,0,8-8V177h22.67A17.36,17.36,0,0,0,232,159.67V89.33A17.36,17.36,0,0,0,'
      '214.67,72ZM80,48h96V72H80ZM176,208H80V160h96Zm40-48.33c0,.72-.61,1.33-1.33,'
      '1.33H192V152a8,8,0,0,0-8-8H72a8,8,0,0,0-8,8v9H41.33c-.72,0-1.33-.61-1.33'
      '-1.33V89.33c0-.72.61-1.33,1.33-1.33H214.67c.72,0,1.33.61,1.33,1.33Z';

  static const listBullets =
      'M80,64a8,8,0,0,1,8-8H216a8,8,0,0,1,0,16H88A8,8,0,0,1,80,64Zm136,56H88a8,'
      '8,0,0,0,0,16H216a8,8,0,0,0,0-16Zm0,64H88a8,8,0,0,0,0,16H216a8,8,0,0,0,0'
      '-16ZM44,52A12,12,0,1,0,56,64,12,12,0,0,0,44,52Zm0,64a12,12,0,1,0,12,12A'
      '12,12,0,0,0,44,116Zm0,64a12,12,0,1,0,12,12A12,12,0,0,0,44,180Z';

  static const car =
      'M240,112H229.2L201.42,49.5A16,16,0,0,0,186.8,40H69.2a16,16,0,0,0-14.62,'
      '9.5L26.8,112H16a8,8,0,0,0,0,16h8v80a16,16,0,0,0,16,16H64a16,16,0,0,0,16'
      '-16V192h96v16a16,16,0,0,0,16,16h24a16,16,0,0,0,16-16V128h8a8,8,0,0,0,0'
      '-16ZM69.2,56H186.8l24.89,56H44.31ZM64,208H40V192H64Zm128,0V192h24v16Zm'
      '24-32H40V128H216ZM56,152a8,8,0,0,1,8-8H80a8,8,0,0,1,0,16H64A8,8,0,0,1,'
      '56,152Zm112,0a8,8,0,0,1,8-8h16a8,8,0,0,1,0,16H176A8,8,0,0,1,168,152Z';

  static const plus =
      'M224,128a8,8,0,0,1-8,8H136v80a8,8,0,0,1-16,0V136H40a8,8,0,0,1,0-16h80V40'
      'a8,8,0,0,1,16,0v80h80A8,8,0,0,1,224,128Z';

  static const minus =
      'M224,128a8,8,0,0,1-8,8H40a8,8,0,0,1,0-16H216A8,8,0,0,1,224,128Z';

  static const x =
      'M205.66,194.34a8,8,0,0,1-11.32,11.32L128,139.31,61.66,205.66a8,8,0,0,1'
      '-11.32-11.32L116.69,128,50.34,61.66A8,8,0,0,1,61.66,50.34L128,116.69'
      'l66.34-66.35a8,8,0,0,1,11.32,11.32L139.31,128Z';

  static const trash =
      'M216,48H176V40a24,24,0,0,0-24-24H104A24,24,0,0,0,80,40v8H40a8,8,0,0,0,'
      '0,16h8V208a16,16,0,0,0,16,16H192a16,16,0,0,0,16-16V64h8a8,8,0,0,0,0-16Z'
      'M96,40a8,8,0,0,1,8-8h48a8,8,0,0,1,8,8v8H96Zm96,168H64V64H192Z'
      'M112,104v64a8,8,0,0,1-16,0V104a8,8,0,0,1,16,0Zm48,0v64a8,8,0,0,1-16,0'
      'V104a8,8,0,0,1,16,0Z';

  static const pause =
      'M200,32H160a16,16,0,0,0-16,16V208a16,16,0,0,0,16,16h40a16,16,0,0,0,'
      '16-16V48A16,16,0,0,0,200,32Zm0,176H160V48h40Z'
      'M96,32H56A16,16,0,0,0,40,48V208a16,16,0,0,0,16,16H96a16,16,0,0,0,'
      '16-16V48A16,16,0,0,0,96,32Zm0,176H56V48H96Z';

  static const clock =
      'M128,24A104,104,0,1,0,232,128,104.11,104.11,0,0,0,128,24Zm0,192'
      'a88,88,0,1,1,88-88A88.1,88.1,0,0,1,128,216Zm64-88a8,8,0,0,1-8,8H128'
      'a8,8,0,0,1-8-8V72a8,8,0,0,1,16,0v48h48A8,8,0,0,1,192,128Z';

  static const money =
      'M128,88a40,40,0,1,0,40,40A40,40,0,0,0,128,88Zm0,64a24,24,0,1,1,24-24'
      'A24,24,0,0,1,128,152ZM240,56H16a8,8,0,0,0-8,8V192a8,8,0,0,0,8,8H240'
      'a8,8,0,0,0,8-8V64A8,8,0,0,0,240,56ZM24,72H232V184H24Z';

  static const creditCard =
      'M224,48H32A16,16,0,0,0,16,64V192a16,16,0,0,0,16,16H224a16,16,0,0,0,'
      '16-16V64A16,16,0,0,0,224,48Zm0,16V88H32V64Zm0,128H32V104H224v88Z'
      'm-16-24a8,8,0,0,1-8,8H168a8,8,0,0,1,0-16h32A8,8,0,0,1,208,168Z'
      'm-64,0a8,8,0,0,1-8,8H120a8,8,0,0,1,0-16h16A8,8,0,0,1,144,168Z';

  static const deviceMobile =
      'M176,16H80A24,24,0,0,0,56,40V216a24,24,0,0,0,24,24h96a24,24,0,0,0,'
      '24-24V40A24,24,0,0,0,176,16Zm8,200a8,8,0,0,1-8,8H80a8,8,0,0,1-8-8V40'
      'a8,8,0,0,1,8-8h96a8,8,0,0,1,8,8ZM140,196a12,12,0,1,1-12-12A12,12,0,0,1,'
      '140,196Z';

  static const pencil =
      'M227.31,73.37,182.63,28.68a16,16,0,0,0-22.63,0L36.69,152A15.86,15.86,0,'
      '0,0,32,163.31V208a16,16,0,0,0,16,16H92.69A15.86,15.86,0,0,0,104,219.31'
      'L227.31,96a16,16,0,0,0,0-22.63ZM92.69,208H48V163.31l88-88L180.69,120Z'
      'M192,108.68,147.31,64l24-24L216,84.68Z';

  static const calendarBlank =
      'M208,32H184V24a8,8,0,0,0-16,0v8H88V24a8,8,0,0,0-16,0v8H48A16,16,0,0,0,'
      '32,48V208a16,16,0,0,0,16,16H208a16,16,0,0,0,16-16V48A16,16,0,0,0,208,32Z'
      'M72,48v8a8,8,0,0,0,16,0V48h80v8a8,8,0,0,0,16,0V48h24V80H48V48Z'
      'M208,208H48V96H208V208Z';

  static const caretLeft =
      'M165.66,202.34a8,8,0,0,1-11.32,11.32l-80-80a8,8,0,0,1,0-11.32l80-80a8,8,'
      '0,0,1,11.32,11.32L91.31,128Z';

  static const caretRight =
      'M181.66,133.66l-80,80a8,8,0,0,1-11.32-11.32L164.69,128,90.34,53.66a8,8,'
      '0,0,1,11.32-11.32l80,80A8,8,0,0,1,181.66,133.66Z';

  static const arrowLeft =
      'M224,128a8,8,0,0,1-8,8H59.31l58.35,58.34a8,8,0,0,1-11.32,11.32l-72-72a8,8,'
      '0,0,1,0-11.32l72-72a8,8,0,0,1,11.32,11.32L59.31,120H216A8,8,0,0,1,224,128Z';
}

/// Paints one Phosphor glyph at [size], tinted [color].
class PhosphorIcon extends StatelessWidget {
  const PhosphorIcon(this.path, {super.key, this.size = 22, this.color});

  final String path;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _GlyphPainter(
          path,
          color ?? DefaultTextStyle.of(context).style.color ?? N.text,
          size,
        ),
      ),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.d, this.color, this.extent)
    : _path = scaleSvgPath(parseSvgPath(d), 256, extent);

  final String d;
  final Color color;
  final double extent;
  final Path _path;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      _path,
      Paint()
        ..color = color
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.d != d || old.color != color || old.extent != extent;
}

/// The backspace key's glyph, stroked rather than filled.
///
/// Phosphor draws its regular weight as a filled outline at a 16/256 stroke;
/// stroking the same shape reads identically at interface sizes and keeps the
/// key off a font that may not carry U+232B.
class BackspaceGlyph extends StatelessWidget {
  const BackspaceGlyph({super.key, this.size = 24, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(
      painter: _BackspacePainter(
        color ?? DefaultTextStyle.of(context).style.color ?? N.text,
        size,
      ),
    ),
  );
}

class _BackspacePainter extends CustomPainter {
  _BackspacePainter(this.color, this.extent);

  final Color color;
  final double extent;

  @override
  void paint(Canvas canvas, Size size) {
    final s = extent / 256;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    // The key's outline: a rectangle with its leading edge drawn to a point.
    final body = Path()
      ..moveTo(216 * s, 48 * s)
      ..lineTo(72 * s, 48 * s)
      ..lineTo(16 * s, 128 * s)
      ..lineTo(72 * s, 208 * s)
      ..lineTo(216 * s, 208 * s)
      ..close();
    canvas.drawPath(body, paint);

    // The cross inside it.
    canvas.drawLine(Offset(104 * s, 104 * s), Offset(168 * s, 152 * s), paint);
    canvas.drawLine(Offset(168 * s, 104 * s), Offset(104 * s, 152 * s), paint);
  }

  @override
  bool shouldRepaint(_BackspacePainter old) =>
      old.color != color || old.extent != extent;
}
