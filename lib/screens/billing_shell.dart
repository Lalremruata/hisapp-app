import 'package:flutter/widgets.dart';

import '../state/theme_store.dart';
import '../theme/nocturne.dart';
import 'bills_screen.dart';
import 'invoice_a4.dart';
import 'phone_billing.dart';
import 'rate_card_screen.dart';
import 'workshop_settings_screen.dart';
import 'tablet_keypad_billing.dart';
import 'tablet_rail_billing.dart';

/// Picks the layout the screen has room for, and routes to the invoice and the
/// store settings.
///
/// The design offers two tablet billing layouts rather than one. Which one the
/// counter uses is a setting, chosen once, rather than a switch on the billing
/// screen competing with the bill for attention.
class BillingShell extends StatefulWidget {
  const BillingShell({super.key});

  /// Below this the phone layout takes over. A 1194pt tablet is comfortably
  /// above it; a 390pt phone is well below.
  static const tabletBreakpoint = 900.0;

  @override
  State<BillingShell> createState() => _BillingShellState();
}

class _BillingShellState extends State<BillingShell> {
  void _openSettings() {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => const WorkshopSettingsScreen(),
        transitionsBuilder: _slideUp,
      ),
    );
  }

  void _openBills() {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => BillsScreen(onPrint: _openInvoice),
        transitionsBuilder: _slideUp,
      ),
    );
  }

  void _openRateCard() {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => const RateCardScreen(),
        transitionsBuilder: _slideUp,
      ),
    );
  }

  void _openInvoice() {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => const InvoiceA4Screen(),
        transitionsBuilder: _slideUp,
      ),
    );
  }

  static Widget _slideUp(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondary,
    Widget child,
  ) => FadeTransition(
    opacity: animation,
    child: SlideTransition(
      position: Tween(
        begin: const Offset(0, 0.02),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    ),
  );

  @override
  Widget build(BuildContext context) {
    N.watch(context);
    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width >= BillingShell.tabletBreakpoint;

    return ColoredBox(
      color: N.bg,
      child: SafeArea(bottom: false, child: isTablet ? _tablet() : _phone()),
    );
  }

  Widget _tablet() => switch (ThemeScope.of(context).tabletLayout) {
    TabletLayout.search => TabletRailBilling(
      onOpenSettings: _openSettings,
      onOpenRateCard: _openRateCard,
      onOpenBills: _openBills,
      onOpenInvoice: _openInvoice,
    ),
    TabletLayout.keypad => TabletKeypadBilling(
      onOpenSettings: _openSettings,
      onOpenRateCard: _openRateCard,
      onOpenBills: _openBills,
      onOpenInvoice: _openInvoice,
    ),
  };

  Widget _phone() => PhoneBilling(
    onOpenSettings: _openSettings,
    onOpenRateCard: _openRateCard,
    onOpenBills: _openBills,
    onOpenInvoice: _openInvoice,
  );
}
