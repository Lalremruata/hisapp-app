import 'package:flutter/widgets.dart';

import '../state/billing_model.dart';
import '../theme/nocturne.dart';

/// A bill's lines in a scrolling list that follows every add: the line the
/// item landed on — new at the end of its group, or one it merged into — is
/// brought into view and lit for a moment, so the shopkeeper sees it went on
/// even with the keyboard taking half the screen.
///
/// Each line marks itself with [AddedLineMark]. A bill is a handful of lines,
/// so they are all built at once: the one to scroll to always exists.
class AddedLineScroller extends StatefulWidget {
  const AddedLineScroller({
    super.key,
    required this.children,
    required this.empty,
    this.padding = EdgeInsets.zero,
  });

  final List<Widget> children;

  /// Shown instead when there are no lines.
  final Widget empty;

  final EdgeInsetsGeometry padding;

  @override
  State<AddedLineScroller> createState() => _AddedLineScrollerState();
}

class _AddedLineScrollerState extends State<AddedLineScroller>
    with SingleTickerProviderStateMixin {
  final _target = GlobalKey();

  /// Runs from 0, fully lit, to 1, gone. It starts finished, so nothing is
  /// lit when the screen first opens.
  late final _flash = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
    value: 1,
  );

  int? _seenSerial;
  int? _targetIndex;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final model = BillingScope.of(context);
    final serial = model.addSerial;
    _targetIndex = model.lastAddedIndex;
    if (_seenSerial != null && serial != _seenSerial) {
      _flash.forward(from: 0);
      WidgetsBinding.instance.addPostFrameCallback((_) => _reveal());
    }
    _seenSerial = serial;
  }

  /// Scrolls only as far as it takes: down if the line is below the view, up
  /// if it is above it, not at all if it is already showing.
  Future<void> _reveal() async {
    const duration = Duration(milliseconds: 250);
    const curve = Curves.easeOutCubic;
    for (final policy in [
      ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      ScrollPositionAlignmentPolicy.keepVisibleAtStart,
    ]) {
      final line = _target.currentContext;
      if (!mounted || line == null || !line.mounted) return;
      await Scrollable.ensureVisible(
        line,
        alignmentPolicy: policy,
        duration: duration,
        curve: curve,
      );
    }
  }

  @override
  void dispose() {
    _flash.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AddedLineScope(
      index: _targetIndex,
      targetKey: _target,
      flash: _flash,
      child: widget.children.isEmpty
          ? widget.empty
          : SingleChildScrollView(
              padding: widget.padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: widget.children,
              ),
            ),
    );
  }
}

class _AddedLineScope extends InheritedWidget {
  const _AddedLineScope({
    required this.index,
    required this.targetKey,
    required this.flash,
    required super.child,
  });

  final int? index;
  final GlobalKey targetKey;
  final Animation<double> flash;

  @override
  bool updateShouldNotify(_AddedLineScope oldWidget) =>
      index != oldWidget.index || flash != oldWidget.flash;
}

/// One line of an [AddedLineScroller], identified by its place on the bill.
class AddedLineMark extends StatelessWidget {
  const AddedLineMark({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_AddedLineScope>();
    if (scope == null || scope.index != index) return child;

    return KeyedSubtree(
      key: scope.targetKey,
      child: AnimatedBuilder(
        animation: scope.flash,
        builder: (context, child) => ColoredBox(
          color: N.a(0.18 * (1 - scope.flash.value)),
          child: child,
        ),
        child: child,
      ),
    );
  }
}
