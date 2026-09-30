import 'package:flutter/gestures.dart' show kTouchSlop;
import 'package:flutter/widgets.dart';

import 'nocturne.dart';
import 'phosphor.dart';

/// A pressable surface that carries the system's hover and pressed tints.
///
/// Every interactive element in Nocturne is themed rather than left to the
/// platform, so all the controls below are built on this one.
class Tappable extends StatefulWidget {
  const Tappable({
    super.key,
    required this.builder,
    this.onTap,
    this.cursor = SystemMouseCursors.click,
  });

  final ValueWidgetBuilder<TappableStates> builder;
  final VoidCallback? onTap;
  final MouseCursor cursor;

  @override
  State<Tappable> createState() => _TappableState();
}

class TappableStates {
  const TappableStates({required this.hovered, required this.pressed});

  final bool hovered;
  final bool pressed;
}

class _TappableState extends State<Tappable> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return MouseRegion(
      cursor: enabled ? widget.cursor : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        child: widget.builder(
          context,
          TappableStates(
            hovered: enabled && _hovered,
            pressed: enabled && _pressed,
          ),
          null,
        ),
      ),
    );
  }
}

/// A fill darkened for hover or press — solid buttons answer a touch by
/// going deeper, which reads on either ground.
Color _deepen(Color fill, double amount) =>
    Color.lerp(fill, const Color(0xFF000000), amount)!;

enum ButtonVariant {
  /// The one main action in an area: a solid block of the accent.
  primary,

  /// Money in — take payment, mark paid. Solid green.
  success,

  /// Removes something for good. Solid red, and only ever in a confirmation.
  danger,

  /// Everything else worth a button: an accent outline.
  secondary,

  /// Accent text with no edge, for a link-like action inside a row.
  ghost,

  /// Plain text, for an action that should sit back.
  quiet,

  /// Red text with no edge: the way to delete, before the confirmation.
  dangerQuiet,
}

/// `.btn` — the system's action.
///
/// Solid for the main action, outlined for the rest: whoever is at the
/// counter should find what to press next before reading a word.
class NButton extends StatelessWidget {
  const NButton(
    this.label, {
    super.key,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.height = 48,
    this.fontSize = 16,
    this.padding = 16,
    this.expand = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;

  /// The least the button stands. It grows past this when the text-size
  /// setting asks for more, rather than clipping its label.
  final double height;
  final double fontSize;
  final double padding;
  final bool expand;

  /// A [PhosphorIcons] glyph set before the label, in the label's colour.
  final String? icon;

  bool get _solid =>
      variant == ButtonVariant.primary ||
      variant == ButtonVariant.success ||
      variant == ButtonVariant.danger;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return Semantics(
      button: true,
      enabled: enabled,
      child: Tappable(
        onTap: onPressed,
        builder: (context, states, _) {
          var fill = const Color(0x00000000);
          var border = const Color(0x00000000);
          Color foreground;

          switch (variant) {
            case ButtonVariant.primary:
              fill = N.accentFill;
              foreground = N.onAccent;
            case ButtonVariant.success:
              fill = N.success;
              foreground = N.onSuccess;
            case ButtonVariant.danger:
              fill = N.danger;
              foreground = N.onDanger;
            case ButtonVariant.secondary:
              border = N.accent;
              foreground = N.accent;
            case ButtonVariant.ghost:
              foreground = N.accent;
            case ButtonVariant.quiet:
              foreground = N.t(0.8);
            case ButtonVariant.dangerQuiet:
              foreground = N.dangerInk;
          }

          if (!enabled) {
            // A disabled action is "not yet", not "broken": a flat grey
            // block or edge with its label still legible.
            if (_solid) fill = N.neutral800;
            if (variant == ButtonVariant.secondary) border = N.line;
            foreground = N.t(0.55);
          } else if (_solid) {
            if (states.pressed) {
              fill = _deepen(fill, 0.22);
            } else if (states.hovered) {
              fill = _deepen(fill, 0.1);
            }
          } else {
            final wash = variant == ButtonVariant.dangerQuiet
                ? N.dangerSoft
                : variant == ButtonVariant.quiet
                ? N.t(0.1)
                : N.a(0.12);
            if (states.pressed) {
              fill = wash;
            } else if (states.hovered) {
              fill = wash.withValues(alpha: wash.a * 0.6);
            }
          }

          final edgeless =
              variant == ButtonVariant.ghost ||
              variant == ButtonVariant.quiet ||
              variant == ButtonVariant.dangerQuiet;

          return AnimatedScale(
            scale: states.pressed ? 0.97 : 1,
            duration: const Duration(milliseconds: 90),
            child: Container(
              constraints: BoxConstraints(minHeight: height),
              width: expand ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: edgeless ? padding * 0.6 : padding,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: fill,
                borderRadius: N.brMd,
                border: Border.all(color: border, width: 1.5),
              ),
              child: Row(
                mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    PhosphorIcon(icon!, size: fontSize + 4, color: foreground),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: N.font(
                        size: fontSize,
                        weight: FontWeight.w600,
                        color: foreground,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// What a tag is saying, which decides its colours and its glyph.
enum TagTone { accent, info, success, warning, danger, neutral }

/// `.tag` — a small label on a soft fill.
///
/// The toned constructors pair each colour with a glyph, so a tag's meaning
/// never rests on its colour alone.
class NTag extends StatelessWidget {
  const NTag(this.label, {super.key, this.background, this.foreground})
    : tone = TagTone.accent,
      icon = null;

  const NTag.info(this.label, {super.key, this.icon})
    : tone = TagTone.info,
      background = null,
      foreground = null;

  const NTag.success(this.label, {super.key, this.icon = PhosphorIcons.check})
    : tone = TagTone.success,
      background = null,
      foreground = null;

  const NTag.warning(this.label, {super.key, this.icon = PhosphorIcons.clock})
    : tone = TagTone.warning,
      background = null,
      foreground = null;

  const NTag.danger(this.label, {super.key, this.icon = PhosphorIcons.x})
    : tone = TagTone.danger,
      background = null,
      foreground = null;

  const NTag.neutral(this.label, {super.key, this.icon = PhosphorIcons.pause})
    : tone = TagTone.neutral,
      background = null,
      foreground = null;

  final String label;
  final TagTone tone;
  final String? icon;

  /// Left unset these take the tone's pair. They cannot be default parameter
  /// values: a ramp step is whatever the current palette says it is, which is
  /// not known until the tag is built.
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final (fill, ink) = switch (tone) {
      TagTone.accent => (background ?? N.accent800, foreground ?? N.accent100),
      TagTone.info => (N.accent800, N.accent100),
      TagTone.success => (N.successSoft, N.successInk),
      TagTone.warning => (N.warningSoft, N.warningInk),
      TagTone.danger => (N.dangerSoft, N.dangerInk),
      TagTone.neutral => (N.neutral800, N.neutral100),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            PhosphorIcon(icon!, size: 14, color: ink),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: N.font(
                size: 13,
                weight: FontWeight.w600,
                color: ink,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// `.input` — a surface-filled field with a visible edge that takes the
/// accent on focus.
class NInput extends StatefulWidget {
  const NInput({
    super.key,
    this.controller,
    this.placeholder,
    this.onChanged,
    this.onSubmitted,
    this.height = 52,
    this.fontSize = 17,
    this.horizontalPadding = 14,
    this.letterSpacing,
    this.multiline = false,
    this.autofocus = false,
    this.selectAllOnFocus = false,
    this.keepFocusOnSubmit = false,
    this.keyboardType,
  });

  final TextEditingController? controller;
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// The least the field stands; it grows with the text-size setting.
  final double height;
  final double fontSize;
  final double horizontalPadding;
  final double? letterSpacing;
  final bool multiline;
  final bool autofocus;

  /// Selects what is already there when the field is tapped, so a value can be
  /// replaced by typing over it. This is built on a bare [EditableText], which
  /// has no double- or triple-click selection of its own, and on a tablet
  /// there is no keyboard to select with either.
  final bool selectAllOnFocus;

  /// Keeps the field focused, and the keyboard up, after Enter — for a box
  /// that takes one entry after another rather than a single answer.
  final bool keepFocusOnSubmit;

  final TextInputType? keyboardType;

  @override
  State<NInput> createState() => _NInputState();
}

class _NInputState extends State<NInput> {
  late final FocusNode _focus = FocusNode()..addListener(_onFocus);
  final _editable = GlobalKey<EditableTextState>();
  Offset? _pressedAt;
  late final TextEditingController _fallback = TextEditingController();
  bool _focused = false;
  bool _hovered = false;

  TextEditingController get _controller => widget.controller ?? _fallback;

  void _onFocus() {
    setState(() => _focused = _focus.hasFocus);
    if (_focus.hasFocus && widget.selectAllOnFocus) {
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    }
  }

  @override
  void dispose() {
    _focus
      ..removeListener(_onFocus)
      ..dispose();
    _fallback.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = N.font(
      size: widget.fontSize,
      letterSpacing: widget.letterSpacing,
    );
    final border = _focused
        ? N.accent
        : _hovered
        ? N.t(0.55)
        : N.t(0.38);

    final field = EditableText(
      key: _editable,
      controller: _controller,
      focusNode: _focus,
      style: style,
      cursorColor: N.accent,
      cursorWidth: 2.5,
      backgroundCursorColor: N.neutral700,
      selectionColor: N.a(0.3),
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      // Left to itself, Enter drops focus and with it the keyboard.
      onEditingComplete: widget.keepFocusOnSubmit ? () {} : null,
      autofocus: widget.autofocus,
      keyboardType: widget.keyboardType ?? TextInputType.text,
      maxLines: widget.multiline ? null : 1,
    );

    final alignment = widget.multiline
        ? Alignment.topLeft
        : Alignment.centerLeft;

    return MouseRegion(
      cursor: SystemMouseCursors.text,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      // A keyboard put away with the system's back or hide key leaves the
      // field focused, and a tap on the text only asks for the keyboard when
      // it moves the caret — which in an empty box it cannot. So a tap on a
      // box that already has focus asks for the keyboard itself. It listens
      // to the raw pointer because the text claims the tap for its caret.
      child: Listener(
        onPointerDown: (event) => _pressedAt = event.position,
        onPointerUp: (event) {
          final pressedAt = _pressedAt;
          _pressedAt = null;
          if (!_focus.hasFocus || pressedAt == null) return;
          if ((event.position - pressedAt).distance > kTouchSlop) return;
          _editable.currentState?.requestKeyboard();
        },
        onPointerCancel: (_) => _pressedAt = null,
        child: GestureDetector(
          // The whole box takes the tap, not just the line of text inside it.
          onTap: _focus.requestFocus,
          child: Container(
            constraints: BoxConstraints(
              minHeight: widget.multiline ? 96 : widget.height,
            ),
            alignment: alignment,
            padding: EdgeInsets.symmetric(
              horizontal: widget.horizontalPadding,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: N.surface,
              borderRadius: N.brMd,
              border: Border.all(color: border, width: _focused ? 2 : 1.5),
            ),
            // The field is the Stack's only unpositioned child, so it is what
            // gives the Stack its height — which matters in the settings list,
            // where the shop address grows and nothing above bounds it.
            child: Stack(
              alignment: alignment,
              children: [
                field,
                if (widget.placeholder != null)
                  // The placeholder tracks the controller directly so it clears
                  // on the first keystroke, whoever owns the text.
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controller,
                    builder: (context, value, _) => value.text.isEmpty
                        ? Positioned.fill(
                            child: IgnorePointer(
                              child: Align(
                                alignment: alignment,
                                child: Text(
                                  widget.placeholder!,
                                  maxLines: widget.multiline ? null : 1,
                                  overflow: widget.multiline
                                      ? null
                                      : TextOverflow.ellipsis,
                                  style: style.copyWith(color: N.t(0.55)),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// `.field` — a label above one of the controls above.
class NField extends StatelessWidget {
  const NField({
    super.key,
    required this.label,
    required this.child,
    this.hint,
  });

  final String label;
  final Widget child;
  final Widget? hint;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(label, style: N.label()),
      ),
      child,
      if (hint != null)
        Padding(padding: const EdgeInsets.only(top: 6), child: hint!),
    ],
  );
}

/// `.seg` + `.seg-opt` — a segmented choice. The chosen option is filled solid
/// and ticked, so which one is on reads from across the counter.
class NSegmented<T> extends StatelessWidget {
  const NSegmented({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.labelOf,
    this.expand = false,
    this.verticalPadding = 12,
  });

  final List<T> options;
  final T value;
  final ValueChanged<T> onChanged;
  final String Function(T)? labelOf;
  final bool expand;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: N.surface,
        borderRadius: N.brMd,
        border: Border.all(color: N.t(0.38), width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < options.length; i++)
              _buildOption(options[i], first: i == 0, flex: expand),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(T option, {required bool first, required bool flex}) {
    final selected = option == value;
    final label = labelOf?.call(option) ?? '$option';

    final child = Semantics(
      selected: selected,
      button: true,
      child: Tappable(
        onTap: () => onChanged(option),
        builder: (context, states, _) => Container(
          constraints: const BoxConstraints(minHeight: 48),
          decoration: BoxDecoration(
            color: selected
                ? N.accentFill
                : states.pressed
                ? N.a(0.14)
                : states.hovered
                ? N.a(0.07)
                : const Color(0x00000000),
            border: Border(
              left: first ? BorderSide.none : BorderSide(color: N.t(0.38)),
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: verticalPadding,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                PhosphorIcon(PhosphorIcons.check, size: 16, color: N.onAccent),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: N.font(
                    size: 15,
                    weight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? N.onAccent : N.text,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return flex ? Expanded(child: child) : child;
  }
}

/// The artboards' `.stepb` — a square button for − / + / ×.
///
/// Always drawn at rest: a tablet has no hover to reveal it with.
class StepButton extends StatelessWidget {
  const StepButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = 48,
    this.fontSize = 24,
    this.quiet = false,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback onPressed;
  final double size;
  final double fontSize;

  /// The remove button: red on a soft red fill, so it reads as "take this
  /// off" and never as another quantity key.
  final bool quiet;

  /// What a screen reader says, where the glyph alone would not.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    button: true,
    child: Tappable(
      onTap: onPressed,
      builder: (context, states, _) {
        final Color fill;
        final Color edge;
        final Color ink;
        if (quiet) {
          fill = states.pressed ? N.danger : N.dangerSoft;
          edge = const Color(0x00000000);
          ink = states.pressed ? N.onDanger : N.dangerInk;
        } else {
          fill = states.pressed
              ? N.a(0.18)
              : states.hovered
              ? N.a(0.08)
              : N.surface;
          edge = states.pressed || states.hovered ? N.accent : N.t(0.38);
          ink = states.pressed ? N.accent : N.text;
        }

        return Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: N.brMd,
            border: Border.all(color: edge, width: 1.5),
          ),
          // Where the button says what it does in words, the glyph is not
          // read out as well.
          child: ExcludeSemantics(
            excluding: semanticLabel != null,
            child: Text(
              label,
              textScaler: TextScaler.noScaling,
              style: N.font(
                size: fontSize,
                weight: FontWeight.w600,
                color: ink,
                height: 1,
              ),
            ),
          ),
        );
      },
    ),
  );
}

/// A hairline edge on one or more sides, the way the artboards use inset
/// box-shadows to draw dividers without taking up layout space.
class Edged extends StatelessWidget {
  const Edged({
    super.key,
    required this.child,
    this.bottom = false,
    this.top = false,
    this.left = false,
    this.right = false,
    this.opacity = 0.14,
  });

  final Widget child;
  final bool bottom;
  final bool top;
  final bool left;
  final bool right;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final side = BorderSide(color: N.t(opacity));
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: top ? side : BorderSide.none,
          bottom: bottom ? side : BorderSide.none,
          left: left ? side : BorderSide.none,
          right: right ? side : BorderSide.none,
        ),
      ),
      child: child,
    );
  }
}

/// The small dot that marks a live state.
class Dot extends StatelessWidget {
  const Dot({super.key, this.size = 8, this.color});

  final double size;

  /// Unset takes the accent ramp's mid step, once the palette is known.
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color ?? N.accent500,
      shape: BoxShape.circle,
    ),
  );
}

/// A square, icon-only tap target.
///
/// The label is required: an icon alone says nothing to a screen reader, and
/// every one of these in the app is the only route to what it opens. Where
/// there is room, [LabeledIconButton] says it on screen too.
class IconButtonTarget extends StatelessWidget {
  const IconButtonTarget({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.size = 48,
  });

  final String label;
  final Widget icon;
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    button: true,
    child: Tappable(
      onTap: onPressed,
      builder: (context, states, _) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: N.brMd,
          color: states.pressed
              ? N.t(0.14)
              : states.hovered
              ? N.t(0.07)
              : const Color(0x00000000),
        ),
        child: icon,
      ),
    ),
  );
}

/// An icon with its name written under it — navigation that does not ask
/// anyone to remember what a picture means.
class LabeledIconButton extends StatelessWidget {
  const LabeledIconButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.selected = false,
    this.width = 72,
    this.height = 64,
  });

  final String label;

  /// A [PhosphorIcons] glyph.
  final String icon;
  final VoidCallback? onPressed;
  final bool selected;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    button: true,
    selected: selected,
    child: Tappable(
      onTap: onPressed,
      builder: (context, states, _) {
        final ink = selected ? N.accent : N.t(0.8);
        return Container(
          width: width,
          constraints: BoxConstraints(minHeight: height),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: N.brMd,
            color: selected
                ? N.a(0.14)
                : states.pressed
                ? N.t(0.14)
                : states.hovered
                ? N.t(0.07)
                : const Color(0x00000000),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PhosphorIcon(icon, size: 24, color: ink),
              const SizedBox(height: 4),
              // Said once, by the Semantics above. Shrinks rather than cuts
              // off when the text-size setting outgrows the button.
              ExcludeSemantics(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: N.font(
                      size: 13,
                      weight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: ink,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

/// The way back from a pushed screen, written out rather than left to an
/// arrow alone.
class BackButtonN extends StatelessWidget {
  const BackButtonN({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Back',
    button: true,
    excludeSemantics: true,
    child: NButton(
      'Back',
      variant: ButtonVariant.secondary,
      icon: PhosphorIcons.arrowLeft,
      padding: 14,
      onPressed: () => Navigator.of(context).maybePop(),
    ),
  );
}

/// `.dialog` + `.dialog-backdrop` — a modal at the system's top elevation.
///
/// Built on the design system's own tokens rather than Material's dialog,
/// whose chrome and shape would fight them.
class NDialog extends StatelessWidget {
  const NDialog({
    super.key,
    required this.title,
    required this.child,
    required this.actions,
    this.leadingAction,
  });

  final String title;
  final Widget child;
  final List<Widget> actions;

  /// An action that sits away from the others, at the start of the row —
  /// where a destructive one belongs, so it is never next to the button the
  /// person is reaching for.
  final Widget? leadingAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(N.space4),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: N.surface,
            borderRadius: N.brLg,
            boxShadow: N.shadowLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: N.font(size: 22, weight: FontWeight.w600)),
              const SizedBox(height: 14),
              Flexible(child: child),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  if (leadingAction != null) leadingAction!,
                  ...actions,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Puts [builder]'s dialog over the current screen on the system's backdrop.
Future<T?> showNocturneDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: N.scrim,
    transitionDuration: const Duration(milliseconds: 160),
    pageBuilder: (context, animation, secondary) => const SizedBox.shrink(),
    transitionBuilder: (context, animation, secondary, _) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween(begin: 0.98, end: 1.0).animate(curved),
          // The dialog sizes to its content and sits centred, and the keyboard
          // pushes it up rather than covering the field being typed into.
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Builder(
                  builder: (context) {
                    // The dialog is its own route, so it needs telling too.
                    N.watch(context);
                    return builder(context);
                  },
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// The system's on/off control: green when on, with a white knob.
class NSwitch extends StatelessWidget {
  const NSwitch({super.key, required this.value, this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final track = AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      width: 56,
      height: 32,
      padding: const EdgeInsets.all(3),
      alignment: value ? Alignment.centerRight : Alignment.centerLeft,
      decoration: BoxDecoration(
        color: value ? N.success : N.neutral800,
        borderRadius: const BorderRadius.all(Radius.circular(999)),
        border: Border.all(color: value ? N.success : N.t(0.38), width: 1.5),
      ),
      child: Container(
        width: 23,
        height: 23,
        decoration: BoxDecoration(
          color: value ? N.onSuccess : N.neutral500,
          shape: BoxShape.circle,
        ),
      ),
    );

    if (onChanged == null) return track;
    return Semantics(
      toggled: value,
      child: Tappable(
        onTap: () => onChanged!(!value),
        builder: (_, _, _) => track,
      ),
    );
  }
}

/// A label-and-description row with a switch on the end — the shape the
/// settings screen and the new-item form both need.
class NSwitchRow extends StatelessWidget {
  const NSwitchRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      child: Tappable(
        onTap: () => onChanged(!value),
        builder: (context, states, _) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: N.surface,
            borderRadius: N.brLg,
            border: Border.all(
              color: states.hovered ? N.t(0.38) : N.line,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: N.font(size: 16, weight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: N.caption(size: 14)),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              NSwitch(value: value),
            ],
          ),
        ),
      ),
    );
  }
}

/// A short message across the top of the screen: what just happened, and the
/// way to take it back.
///
/// The top, not the bottom, because the bottom is where the charge button
/// lives on a phone, and a message must never sit over the main action.
///
/// One at a time — a new one replaces whatever is showing. Timed by an
/// animation rather than a timer, so it goes with the screen that showed it.
void showNToast(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 4),
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  final previous = _Toast.current;
  if (previous != null && previous.mounted) previous.remove();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _Toast(
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
      onDone: () {
        if (_Toast.current == entry) _Toast.current = null;
        if (entry.mounted) entry.remove();
      },
    ),
  );
  _Toast.current = entry;
  overlay.insert(entry);
}

class _Toast extends StatefulWidget {
  const _Toast({
    required this.message,
    required this.actionLabel,
    required this.onAction,
    required this.duration,
    required this.onDone,
  });

  static OverlayEntry? current;

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Duration duration;
  final VoidCallback onDone;

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  static const _fade = 0.06;

  late final AnimationController _life =
      AnimationController(vsync: this, duration: widget.duration)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) widget.onDone();
        })
        ..forward();

  @override
  void dispose() {
    _life.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.paddingOf(context).top;
    final ground = N.neutral100;
    final ink = N.bg;

    return Positioned(
      left: 16,
      right: 16,
      top: 12 + inset,
      child: AnimatedBuilder(
        animation: _life,
        builder: (context, child) {
          final t = _life.value;
          final opacity = t < _fade
              ? t / _fade
              : t > 1 - _fade
              ? (1 - t) / _fade
              : 1.0;
          return Opacity(opacity: opacity.clamp(0.0, 1.0), child: child);
        },
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Semantics(
              liveRegion: true,
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 10, 10, 10),
                constraints: const BoxConstraints(minHeight: 56),
                decoration: BoxDecoration(
                  color: ground,
                  borderRadius: N.brLg,
                  boxShadow: N.shadowLg,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.message,
                        style: N.font(
                          size: 16,
                          weight: FontWeight.w500,
                          color: ink,
                        ),
                      ),
                    ),
                    if (widget.actionLabel != null) ...[
                      const SizedBox(width: 12),
                      Tappable(
                        onTap: () {
                          widget.onAction?.call();
                          widget.onDone();
                        },
                        builder: (context, states, _) => Container(
                          constraints: const BoxConstraints(minHeight: 44),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: states.pressed
                                ? ink.withValues(alpha: 0.2)
                                : null,
                            borderRadius: N.brMd,
                            border: Border.all(color: ink, width: 1.5),
                          ),
                          child: Text(
                            widget.actionLabel!,
                            style: N.font(
                              size: 16,
                              weight: FontWeight.w600,
                              color: ink,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
