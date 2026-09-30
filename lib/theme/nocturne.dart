import 'dart:math' as math;
import 'dart:ui' show Brightness;

import 'package:flutter/widgets.dart';

/// A complete set of Nocturne's colours — one ground, one ink, one accent, and
/// the two ramps that step away from them.
///
/// The system ships two: [nocturne], the night palette the artboards were
/// drawn in, and [daylight], the same design read under a lamp on a workshop
/// counter at noon. A screen asks for a role, never for a palette, so the two
/// are interchangeable underneath [N].
///
/// Both ramps are quoted **relative to the ground, not in absolute lightness**:
/// `neutral900` is the step nearest the ground and `neutral100` the step
/// furthest from it, which is near-black at night and near-white by day. That
/// is what lets one `N.neutral900` pill read as a pill in both palettes.
@immutable
class NPalette {
  const NPalette({
    required this.name,
    required this.brightness,
    required this.bg,
    required this.panel,
    required this.surface,
    required this.text,
    required this.accent,
    required this.divider,
    required this.scrim,
    required this.desk,
    required this.neutral100,
    required this.neutral200,
    required this.neutral300,
    required this.neutral400,
    required this.neutral500,
    required this.neutral600,
    required this.neutral700,
    required this.neutral800,
    required this.neutral900,
    required this.accent100,
    required this.accent200,
    required this.accent300,
    required this.accent400,
    required this.accent500,
    required this.accent600,
    required this.accent700,
    required this.accent800,
    required this.accent900,
    required this.accentFill,
    required this.onAccent,
    required this.highlight,
    required this.success,
    required this.onSuccess,
    required this.successSoft,
    required this.successInk,
    required this.warning,
    required this.onWarning,
    required this.warningSoft,
    required this.warningInk,
    required this.danger,
    required this.onDanger,
    required this.dangerSoft,
    required this.dangerInk,
    required this.shadowMd,
    required this.shadowLg,
    this.inkGamma = 1,
    this.tintScale = 1,
  });

  final String name;
  final Brightness brightness;

  // ── roles ────────────────────────────────────────────────────────────────
  final Color bg;

  /// The artboards sit panels one step above the ground; the system carries it
  /// as a plain fill rather than a ramp step.
  final Color panel;

  final Color surface;
  final Color text;
  final Color accent;

  /// The hairline between rows and panes.
  final Color divider;

  /// What a modal lays over the screen behind it.
  ///
  /// A role of its own rather than a ramp step. Night lays its nearest
  /// neutral over the ground at half, which lifts the screen a little rather
  /// than dimming it — the dialog separates by its shadow and its lighter
  /// surface. Read as a ramp step that would come out pale by day and wash
  /// the screen out, so the day palette dims with its own ink instead.
  final Color scrim;

  /// The surface a printed sheet is laid on.
  ///
  /// The invoice is always ink on white paper, whichever palette is on. At
  /// night the ground is dark and the sheet sits off it by itself; by day a
  /// white sheet on a near-white ground is not a sheet at all, so the day
  /// palette steps back from the paper and gives it a desk to lie on.
  final Color desk;

  // ── neutral ramp ─────────────────────────────────────────────────────────
  final Color neutral100;
  final Color neutral200;
  final Color neutral300;
  final Color neutral400;
  final Color neutral500;
  final Color neutral600;
  final Color neutral700;
  final Color neutral800;
  final Color neutral900;

  // ── accent ramp ──────────────────────────────────────────────────────────
  final Color accent100;
  final Color accent200;
  final Color accent300;
  final Color accent400;
  final Color accent500;
  final Color accent600;
  final Color accent700;
  final Color accent800;
  final Color accent900;

  // ── solid actions and signals ───────────────────────────────────────────
  // The main action on a screen is a solid block of colour, not an outline:
  // it is what a shopkeeper at arm's length has to find first. Status is
  // carried by its own colour as well as its word — paid is green, owed is
  // amber, gone is red — so a bill's state reads before its text does.

  /// The fill of the one main action in an area. By day the accent itself; at
  /// night a deeper step, since the bright accent is chosen for text.
  final Color accentFill;

  /// Text and icons on [accentFill].
  final Color onAccent;

  /// Section titles and kickers: warm, so they stand apart from the blue of
  /// what can be tapped.
  final Color highlight;

  /// Money in: take payment, paid.
  final Color success;
  final Color onSuccess;
  final Color successSoft;

  /// Success as text, on the ground or on [successSoft].
  final Color successInk;

  /// Waiting on something: due, held back, a key that clears.
  final Color warning;
  final Color onWarning;
  final Color warningSoft;
  final Color warningInk;

  /// Removes something for good.
  final Color danger;
  final Color onDanger;
  final Color dangerSoft;
  final Color dangerInk;

  // ── elevation ────────────────────────────────────────────────────────────
  final List<BoxShadow> shadowMd;
  final List<BoxShadow> shadowLg;

  // ── the tone curve ───────────────────────────────────────────────────────
  // Dark ink thinned over a pale ground fades faster than pale ink thinned
  // over a dark one: `text` at 55% reads at 5.2:1 at night and only 3.6:1 by
  // day. So a palette re-quotes the alpha it is asked for, and a label muted
  // to 55% carries the same weight in both.
  //
  // Two bands, because that is how the app asks: ink — labels and secondary
  // text, 0.4 and up — wants that matched contrast, while hairlines and hover
  // tints below 0.2 want to stay faint, and black tints already read stronger
  // than white ones. [inkGamma] is the exponent that matches the first band
  // and [tintScale] the factor that holds back the second; at 1 and 1 the
  // curve is the identity, which is what the night palette wants.

  /// The exponent applied to an ink alpha.
  final double inkGamma;

  /// The factor applied to a hairline or hover-tint alpha.
  final double tintScale;

  /// [alpha] as this palette needs to be asked for it.
  double _requote(double alpha) {
    if (inkGamma == 1 && tintScale == 1) return alpha;
    final tint = alpha * tintScale;
    final ink = math.pow(alpha, inkGamma).toDouble();
    // Crosses from one band to the other between 0.2 and 0.4, where the app
    // asks for nothing today.
    final t = ((alpha - 0.2) / 0.2).clamp(0.0, 1.0);
    return (tint + (ink - tint) * t).clamp(0.0, 1.0);
  }

  /// The ink at [alpha] — the system's `color-mix(text, transparent)`.
  Color ink(double alpha) => text.withValues(alpha: _requote(alpha));

  /// The accent at [alpha], for outlined hover and pressed tints.
  Color tint(double alpha) => accent.withValues(alpha: _requote(alpha));

  /// The night palette: a deep slate ground, a clear blue for what can be
  /// tapped and a warm orange for what names a section.
  static const nocturne = NPalette(
    name: 'Night',
    brightness: Brightness.dark,
    bg: Color(0xFF111827),
    panel: Color(0xFF172033),
    surface: Color(0xFF1F2A3D),
    text: Color(0xFFF1F5F9),
    accent: Color(0xFF60A5FA),
    // The text colour at 20%: an edge that shows without shouting.
    divider: Color(0x33F1F5F9),
    // Dark ground, darker backdrop: the dialog is the only lit thing left.
    scrim: Color(0xB3000000),
    desk: Color(0xFF111827),
    neutral100: Color(0xFFF1F5F9),
    neutral200: Color(0xFFE2E8F0),
    neutral300: Color(0xFFCBD5E1),
    neutral400: Color(0xFFA9B5C7),
    neutral500: Color(0xFF8391A7),
    neutral600: Color(0xFF64748B),
    neutral700: Color(0xFF475569),
    neutral800: Color(0xFF334155),
    neutral900: Color(0xFF243047),
    accent100: Color(0xFFEFF6FF),
    accent200: Color(0xFFDBEAFE),
    accent300: Color(0xFFBFDBFE),
    accent400: Color(0xFF93C5FD),
    accent500: Color(0xFF60A5FA),
    accent600: Color(0xFF3B82F6),
    accent700: Color(0xFF2563EB),
    accent800: Color(0xFF1E3A8A),
    accent900: Color(0xFF172554),
    accentFill: Color(0xFF2563EB),
    onAccent: Color(0xFFFFFFFF),
    highlight: Color(0xFFFB923C),
    success: Color(0xFF15803D),
    onSuccess: Color(0xFFFFFFFF),
    successSoft: Color(0xFF0F3B23),
    successInk: Color(0xFF86EFAC),
    warning: Color(0xFFB45309),
    onWarning: Color(0xFFFFFFFF),
    warningSoft: Color(0xFF45290A),
    warningInk: Color(0xFFFCD34D),
    danger: Color(0xFFB91C1C),
    onDanger: Color(0xFFFFFFFF),
    dangerSoft: Color(0xFF4A1616),
    dangerInk: Color(0xFFFCA5A5),
    // On a dark ground elevation is a hairline edge plus ambient darkness,
    // never a stack of heavy shadows.
    shadowMd: [
      BoxShadow(color: Color(0x8C000000), blurRadius: 18, offset: Offset(0, 6)),
    ],
    shadowLg: [
      BoxShadow(
        color: Color(0xA6000000),
        blurRadius: 40,
        offset: Offset(0, 16),
      ),
    ],
  );

  /// The day palette, and the one a workshop gets until it asks otherwise:
  /// near-black ink on a cool white ground reads best for the most eyes, in
  /// the most light.
  ///
  /// Not an inversion of the night hexes — the accent drops to a deep blue
  /// that carries white text on a button and 6:1 as text, and elevation
  /// becomes a soft cast shadow where at night it was ambient darkness.
  static const daylight = NPalette(
    name: 'Day',
    brightness: Brightness.light,
    bg: Color(0xFFF3F5F9),
    panel: Color(0xFFFAFBFD),
    surface: Color(0xFFFFFFFF),
    text: Color(0xFF0F172A),
    accent: Color(0xFF1D4ED8),
    // The ink at 18%: an edge a tired eye can still find.
    divider: Color(0x2E0F172A),
    scrim: Color(0x730F172A),
    desk: Color(0xFFDDE3EC),
    neutral100: Color(0xFF1E293B),
    neutral200: Color(0xFF293548),
    neutral300: Color(0xFF334155),
    neutral400: Color(0xFF475569),
    neutral500: Color(0xFF64748B),
    neutral600: Color(0xFF94A3B8),
    neutral700: Color(0xFFCBD5E1),
    neutral800: Color(0xFFE2E8F0),
    neutral900: Color(0xFFE9EDF3),
    accent100: Color(0xFF172554),
    accent200: Color(0xFF1E3A8A),
    accent300: Color(0xFF1E40AF),
    accent400: Color(0xFF1D4ED8),
    accent500: Color(0xFF2563EB),
    accent600: Color(0xFF3B82F6),
    accent700: Color(0xFF93C5FD),
    accent800: Color(0xFFDBEAFE),
    accent900: Color(0xFFEFF6FF),
    accentFill: Color(0xFF1D4ED8),
    onAccent: Color(0xFFFFFFFF),
    highlight: Color(0xFFB0400C),
    success: Color(0xFF15803D),
    onSuccess: Color(0xFFFFFFFF),
    successSoft: Color(0xFFDCFCE7),
    successInk: Color(0xFF166534),
    warning: Color(0xFFB45309),
    onWarning: Color(0xFFFFFFFF),
    warningSoft: Color(0xFFFEF3C7),
    warningInk: Color(0xFF854D0E),
    danger: Color(0xFFB91C1C),
    onDanger: Color(0xFFFFFFFF),
    dangerSoft: Color(0xFFFEE2E2),
    dangerInk: Color(0xFF991B1B),
    // Where night has ambient darkness to sit things on, day has to cast a
    // real shadow: a pale sheet on a pale ground separates by nothing else.
    shadowMd: [
      BoxShadow(color: Color(0x1A1E293B), blurRadius: 4, offset: Offset(0, 1)),
      BoxShadow(color: Color(0x1F1E293B), blurRadius: 16, offset: Offset(0, 5)),
    ],
    shadowLg: [
      BoxShadow(color: Color(0x1F1E293B), blurRadius: 6, offset: Offset(0, 2)),
      BoxShadow(
        color: Color(0x3D1E293B),
        blurRadius: 40,
        offset: Offset(0, 16),
      ),
    ],
    inkGamma: 0.7,
    tintScale: 0.85,
  );
}

/// Which palette the app is painted in.
enum NThemeMode {
  /// Whatever the device is set to.
  system('Match device'),

  /// [NPalette.daylight], whatever the device says.
  day('Day'),

  /// [NPalette.nocturne], whatever the device says.
  night('Night');

  const NThemeMode(this.label);

  /// How the setting names itself on screen.
  final String label;

  NPalette resolve(Brightness deviceBrightness) => switch (this) {
    NThemeMode.day => NPalette.daylight,
    NThemeMode.night => NPalette.nocturne,
    NThemeMode.system =>
      deviceBrightness == Brightness.light
          ? NPalette.daylight
          : NPalette.nocturne,
  };

  /// The mode saved under [name], or [fallback] where nothing readable was
  /// saved.
  static NThemeMode byName(String? name, {NThemeMode fallback = defaultMode}) =>
      NThemeMode.values.firstWhere(
        (mode) => mode.name == name,
        orElse: () => fallback,
      );

  /// What a workshop that has never opened the setting gets.
  ///
  /// [day], not [system]: dark ink on a light ground is what reads best for
  /// the most people behind a counter, whatever the device happens to be set
  /// to. Night is there for whoever goes and asks for it.
  static const defaultMode = NThemeMode.day;
}

/// Nocturne design tokens.
///
/// Nothing outside this file should hard-code a colour, a radius or a spacing
/// step. The colours come from whichever [NPalette] is current; the metrics and
/// the type do not change between palettes, so they stay `const`.
abstract final class N {
  /// The palette every role below reads from.
  ///
  /// Set once, high up, before the frame that uses it — [palette] is global
  /// because the tokens are: a screen writes `N.surface`, not
  /// `N.of(context).surface`, and that is the shape the whole app is built in.
  ///
  /// A screen that is a route of its own calls [watch] so that changing this
  /// reaches it.
  static NPalette palette = NPalette.nocturne;

  /// Rebuilds the calling screen when the palette changes.
  ///
  /// The colours are read statically, so nothing about a screen tells Flutter
  /// it depends on them — and a pushed route sits in the navigator's overlay,
  /// where the app rebuilding above it does not reach. One call at the top of
  /// a route's `build` registers that dependency; the tokens below it stay
  /// static.
  static void watch(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<NPaletteScope>();
    // Registering the dependency is the whole point; the palette itself is
    // read through [N]. Missing the scope only costs the screen its repaint,
    // so it is worth an assert rather than a throw.
    assert(scope != null, 'No NPaletteScope above this widget');
  }

  // ── roles ────────────────────────────────────────────────────────────────
  static Color get bg => palette.bg;
  static Color get surface => palette.surface;
  static Color get text => palette.text;
  static Color get accent => palette.accent;
  static Color get panel => palette.panel;
  static Color get divider => palette.divider;
  static Color get scrim => palette.scrim;
  static Color get desk => palette.desk;

  // ── neutral ramp ─────────────────────────────────────────────────────────
  static Color get neutral100 => palette.neutral100;
  static Color get neutral200 => palette.neutral200;
  static Color get neutral300 => palette.neutral300;
  static Color get neutral400 => palette.neutral400;
  static Color get neutral500 => palette.neutral500;
  static Color get neutral600 => palette.neutral600;
  static Color get neutral700 => palette.neutral700;
  static Color get neutral800 => palette.neutral800;
  static Color get neutral900 => palette.neutral900;

  // ── accent ramp ──────────────────────────────────────────────────────────
  static Color get accent100 => palette.accent100;
  static Color get accent200 => palette.accent200;
  static Color get accent300 => palette.accent300;
  static Color get accent400 => palette.accent400;
  static Color get accent500 => palette.accent500;
  static Color get accent600 => palette.accent600;
  static Color get accent700 => palette.accent700;
  static Color get accent800 => palette.accent800;
  static Color get accent900 => palette.accent900;

  // ── solid actions and signals ───────────────────────────────────────────
  static Color get accentFill => palette.accentFill;
  static Color get onAccent => palette.onAccent;
  static Color get highlight => palette.highlight;
  static Color get success => palette.success;
  static Color get onSuccess => palette.onSuccess;
  static Color get successSoft => palette.successSoft;
  static Color get successInk => palette.successInk;
  static Color get warning => palette.warning;
  static Color get onWarning => palette.onWarning;
  static Color get warningSoft => palette.warningSoft;
  static Color get warningInk => palette.warningInk;
  static Color get danger => palette.danger;
  static Color get onDanger => palette.onDanger;
  static Color get dangerSoft => palette.dangerSoft;
  static Color get dangerInk => palette.dangerInk;

  /// The edge a card or a field draws at rest: strong enough to find, faint
  /// enough to stay an edge.
  static Color get line => t(0.16);

  // ── spacing (density 0.70x) ──────────────────────────────────────────────
  static const space1 = 2.8;
  static const space2 = 5.6;
  static const space3 = 8.4;
  static const space4 = 11.2;
  static const space6 = 16.8;
  static const space8 = 22.4;

  // ── radii ────────────────────────────────────────────────────────────────
  static const radiusSm = Radius.circular(4);
  static const radiusMd = Radius.circular(10);
  static const radiusLg = Radius.circular(14);

  static const brSm = BorderRadius.all(radiusSm);
  static const brMd = BorderRadius.all(radiusMd);
  static const brLg = BorderRadius.all(radiusLg);

  // ── elevation ────────────────────────────────────────────────────────────
  static List<BoxShadow> get shadowMd => palette.shadowMd;
  static List<BoxShadow> get shadowLg => palette.shadowLg;

  /// The text colour at [a] opacity, re-quoted for the current palette.
  static Color t(double a) => palette.ink(a);

  /// The accent at [alpha] opacity, for outlined hover and pressed tints.
  static Color a(double alpha) => palette.tint(alpha);

  // ── type ─────────────────────────────────────────────────────────────────
  // Inter for headings over Inter for body. Where Inter is not installed the
  // platform's own UI face stands in, as `Inter, system-ui, sans-serif` does
  // on the web.
  static const fontFamily = 'Inter';
  static const fontFamilyFallback = <String>[
    'SF Pro Text',
    'Helvetica Neue',
    'Roboto',
    'Segoe UI',
  ];

  static TextStyle font({
    double size = 15,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
    double? letterSpacing,
  }) => TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: size,
    fontWeight: weight,
    color: color ?? text,
    height: height,
    letterSpacing: letterSpacing,
    // Stated rather than inherited: a Text merges onto whatever ambient style
    // it sits under, and an unset decoration would pick that up.
    decoration: TextDecoration.none,
  );

  /// The system's `h6` / `.card-kicker` treatment: tracked out, caps, and in
  /// the warm highlight so a section's name is found before its contents.
  static TextStyle kicker({Color? color, double size = 13}) => font(
    size: size,
    weight: FontWeight.w600,
    color: color ?? highlight,
    letterSpacing: size * 0.08,
  );

  /// What names a field or a row: never smaller than this.
  static TextStyle label({Color? color, double size = 14}) =>
      font(size: size, weight: FontWeight.w500, color: color ?? t(0.8));

  /// The second line under a name — a code, a date, a rate. The smallest text
  /// the app sets, and still at a strength that reads without leaning in.
  static TextStyle caption({Color? color, double size = 13, double? height}) =>
      font(size: size, color: color ?? t(0.7), height: height);

  /// A mono face for identifiers that should not reflow.
  static const monoFallback = <String>['Menlo', 'SF Mono', 'Consolas'];
}

/// Carries the current [NPalette] down the tree so that screens which read it
/// through [N] can be told when it changes.
///
/// It carries the palette rather than being consulted for it: [N.watch] is the
/// whole of its use, and what a screen reads afterwards is [N].
class NPaletteScope extends InheritedWidget {
  const NPaletteScope({super.key, required this.palette, required super.child});

  final NPalette palette;

  @override
  bool updateShouldNotify(NPaletteScope oldWidget) =>
      palette != oldWidget.palette;
}

/// Uppercases a kicker's text the way `text-transform: uppercase` does.
class Kicker extends StatelessWidget {
  const Kicker(this.label, {super.key, this.color, this.size = 13});

  final String label;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) => Text(
    label.toUpperCase(),
    style: N.kicker(color: color, size: size),
  );
}
