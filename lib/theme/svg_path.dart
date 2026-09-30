import 'dart:typed_data';
import 'dart:ui';

/// Parses an SVG `d` attribute into a [Path].
///
/// Supports the full command set (`M L H V C S Q T A Z`, absolute and
/// relative). Arcs map straight onto [Path.arcToPoint], which takes the same
/// endpoint parameterisation SVG does.
Path parseSvgPath(String d) {
  return _SvgPathParser(d).run();
}

final _number = RegExp(r'[-+]?(?:\d*\.\d+|\d+\.?)(?:[eE][-+]?\d+)?');
final _separator = RegExp(r'[\s,]+');
final _command = RegExp(r'[MmLlHhVvCcSsQqTtAaZz]');

class _SvgPathParser {
  _SvgPathParser(this._d);

  final String _d;
  final Path _path = Path();
  int _i = 0;

  // Current point, the start of the current subpath, and the reflected
  // control points that the smooth variants (S, T) mirror.
  double _x = 0, _y = 0;
  double _startX = 0, _startY = 0;
  double? _lastCubicX, _lastCubicY;
  double? _lastQuadX, _lastQuadY;

  Path run() {
    String? command;
    while (true) {
      _skipSeparators();
      if (_i >= _d.length) break;

      final match = _command.matchAsPrefix(_d, _i);
      if (match != null) {
        command = match.group(0)!;
        _i = match.end;
      } else if (command == null) {
        throw FormatException('SVG path must start with a command', _d, _i);
      } else if (command == 'M') {
        // Extra coordinate pairs after a moveto are implicit linetos.
        command = 'L';
      } else if (command == 'm') {
        command = 'l';
      }

      _run(command);
    }
    return _path;
  }

  void _run(String command) {
    final relative = command == command.toLowerCase();
    switch (command.toUpperCase()) {
      case 'M':
        _moveTo(_num(), _num(), relative);
      case 'L':
        _lineTo(_num(), _num(), relative);
      case 'H':
        _lineTo(_num(), relative ? 0 : _y, relative);
      case 'V':
        _lineTo(relative ? 0 : _x, _num(), relative);
      case 'C':
        _cubicTo(_num(), _num(), _num(), _num(), _num(), _num(), relative);
      case 'S':
        final c1 = _reflected(_lastCubicX, _lastCubicY);
        final x2 = _num(), y2 = _num(), x = _num(), y = _num();
        _cubicToAbsolute(
          c1.dx,
          c1.dy,
          _abs(x2, _x, relative),
          _abs(y2, _y, relative),
          _abs(x, _x, relative),
          _abs(y, _y, relative),
        );
      case 'Q':
        _quadTo(_num(), _num(), _num(), _num(), relative);
      case 'T':
        final c = _reflected(_lastQuadX, _lastQuadY);
        final x = _num(), y = _num();
        _quadToAbsolute(
          c.dx,
          c.dy,
          _abs(x, _x, relative),
          _abs(y, _y, relative),
        );
      case 'A':
        _arcTo(
          _num(),
          _num(),
          _num(),
          _flag(),
          _flag(),
          _num(),
          _num(),
          relative,
        );
      case 'Z':
        _path.close();
        _x = _startX;
        _y = _startY;
        _lastCubicX = _lastCubicY = _lastQuadX = _lastQuadY = null;
      default:
        throw FormatException('Unsupported SVG command "$command"', _d, _i);
    }
  }

  // ── commands ─────────────────────────────────────────────────────────────

  void _moveTo(double x, double y, bool relative) {
    _x = _abs(x, _x, relative);
    _y = _abs(y, _y, relative);
    _startX = _x;
    _startY = _y;
    _path.moveTo(_x, _y);
    _lastCubicX = _lastCubicY = _lastQuadX = _lastQuadY = null;
  }

  void _lineTo(double x, double y, bool relative) {
    _x = _abs(x, _x, relative);
    _y = _abs(y, _y, relative);
    _path.lineTo(_x, _y);
    _lastCubicX = _lastCubicY = _lastQuadX = _lastQuadY = null;
  }

  void _cubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x,
    double y,
    bool relative,
  ) {
    _cubicToAbsolute(
      _abs(x1, _x, relative),
      _abs(y1, _y, relative),
      _abs(x2, _x, relative),
      _abs(y2, _y, relative),
      _abs(x, _x, relative),
      _abs(y, _y, relative),
    );
  }

  void _cubicToAbsolute(
    double x1,
    double y1,
    double x2,
    double y2,
    double x,
    double y,
  ) {
    _path.cubicTo(x1, y1, x2, y2, x, y);
    _x = x;
    _y = y;
    _lastCubicX = x2;
    _lastCubicY = y2;
    _lastQuadX = _lastQuadY = null;
  }

  void _quadTo(double x1, double y1, double x, double y, bool relative) {
    _quadToAbsolute(
      _abs(x1, _x, relative),
      _abs(y1, _y, relative),
      _abs(x, _x, relative),
      _abs(y, _y, relative),
    );
  }

  void _quadToAbsolute(double x1, double y1, double x, double y) {
    _path.quadraticBezierTo(x1, y1, x, y);
    _x = x;
    _y = y;
    _lastQuadX = x1;
    _lastQuadY = y1;
    _lastCubicX = _lastCubicY = null;
  }

  void _arcTo(
    double rx,
    double ry,
    double rotation,
    bool largeArc,
    bool sweep,
    double x,
    double y,
    bool relative,
  ) {
    final endX = _abs(x, _x, relative);
    final endY = _abs(y, _y, relative);
    if (rx == 0 || ry == 0) {
      _lineTo(endX, endY, false);
      return;
    }
    _path.arcToPoint(
      Offset(endX, endY),
      radius: Radius.elliptical(rx.abs(), ry.abs()),
      rotation: rotation,
      largeArc: largeArc,
      // SVG's sweep flag runs clockwise in a y-down space, as Flutter's does.
      clockwise: sweep,
    );
    _x = endX;
    _y = endY;
    _lastCubicX = _lastCubicY = _lastQuadX = _lastQuadY = null;
  }

  /// The control point a smooth curve mirrors: the previous one reflected
  /// through the current point, or the current point when there was none.
  Offset _reflected(double? px, double? py) {
    if (px == null || py == null) return Offset(_x, _y);
    return Offset(2 * _x - px, 2 * _y - py);
  }

  double _abs(double v, double origin, bool relative) =>
      relative ? origin + v : v;

  // ── scanning ─────────────────────────────────────────────────────────────

  void _skipSeparators() {
    final match = _separator.matchAsPrefix(_d, _i);
    if (match != null) _i = match.end;
  }

  double _num() {
    _skipSeparators();
    final match = _number.matchAsPrefix(_d, _i);
    if (match == null) {
      throw FormatException('Expected a number in SVG path', _d, _i);
    }
    _i = match.end;
    return double.parse(match.group(0)!);
  }

  /// Arc flags are a single `0` or `1` and may run together with what follows
  /// (`a8,8,0,0,18-8`), so they are read a character at a time rather than as
  /// numbers.
  bool _flag() {
    _skipSeparators();
    if (_i >= _d.length) {
      throw FormatException('Expected an arc flag in SVG path', _d, _i);
    }
    final c = _d[_i];
    if (c != '0' && c != '1') {
      throw FormatException('Expected an arc flag, got "$c"', _d, _i);
    }
    _i++;
    return c == '1';
  }
}

/// Scales a path authored in a square viewBox so it fills [size] pixels.
Path scaleSvgPath(Path path, double viewBox, double size) {
  final s = size / viewBox;
  return path.transform(
    Float64List.fromList(<double>[
      s, 0, 0, 0, //
      0, s, 0, 0, //
      0, 0, 1, 0, //
      0, 0, 0, 1, //
    ]),
  );
}
