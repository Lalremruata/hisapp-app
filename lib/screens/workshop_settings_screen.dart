import 'package:flutter/widgets.dart';

import '../state/billing_model.dart';
import '../state/theme_store.dart';
import '../theme/components.dart';
import '../theme/nocturne.dart';
import '../theme/phosphor.dart';
import '../widgets/backup_section.dart';

/// The workshop's own details, in plain language. Set once; they appear on
/// every invoice it prints.
class WorkshopSettingsScreen extends StatefulWidget {
  const WorkshopSettingsScreen({super.key});

  @override
  State<WorkshopSettingsScreen> createState() => _WorkshopSettingsScreenState();
}

class _WorkshopSettingsScreenState extends State<WorkshopSettingsScreen> {
  late final BillingModel _model = BillingScope.read(context);
  late final _name = TextEditingController(text: _model.settings.name);
  late final _gstin = TextEditingController(text: _model.settings.gstin);
  late final _address = TextEditingController(text: _model.settings.address);
  late final _phone = TextEditingController(text: _model.settings.phone);
  late final _prefix = TextEditingController(
    text: _model.settings.invoicePrefix,
  );

  late final _upi = TextEditingController(text: _model.settings.upiId);
  late final _accountName = TextEditingController(
    text: _model.settings.accountName,
  );
  late final _bankName = TextEditingController(text: _model.settings.bankName);
  late final _accountNo = TextEditingController(
    text: _model.settings.accountNo,
  );
  late final _ifsc = TextEditingController(text: _model.settings.ifsc);
  late final _bankBranch = TextEditingController(
    text: _model.settings.bankBranch,
  );
  late final _branchCode = TextEditingController(
    text: _model.settings.branchCode,
  );
  late final _micr = TextEditingController(text: _model.settings.micr);

  late WorkshopSettings _draft = _model.settings;

  @override
  void initState() {
    super.initState();
    // The GSTIN hint tracks what has been typed, not what has been saved.
    _gstin.addListener(_onGstinChanged);
    _upi.addListener(_onUpiChanged);
  }

  void _onGstinChanged() =>
      setState(() => _draft = _draft.copyWith(gstin: _gstin.text));

  void _onUpiChanged() =>
      setState(() => _draft = _draft.copyWith(upiId: _upi.text));

  List<TextEditingController> get _bankControllers => [
    _upi,
    _accountName,
    _bankName,
    _accountNo,
    _ifsc,
    _bankBranch,
    _branchCode,
    _micr,
  ];

  @override
  void dispose() {
    _gstin.removeListener(_onGstinChanged);
    _upi.removeListener(_onUpiChanged);
    for (final controller in [
      _name,
      _gstin,
      _address,
      _phone,
      _prefix,
      ..._bankControllers,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  /// An import or its undo has changed the details underneath the form. Shows
  /// them, so "Save details" does not write the old ones back.
  void _onRestored() {
    if (!mounted) return;
    final settings = _model.settings;
    _name.text = settings.name;
    _gstin.text = settings.gstin;
    _address.text = settings.address;
    _phone.text = settings.phone;
    _prefix.text = settings.invoicePrefix;
    _upi.text = settings.upiId;
    _accountName.text = settings.accountName;
    _bankName.text = settings.bankName;
    _accountNo.text = settings.accountNo;
    _ifsc.text = settings.ifsc;
    _bankBranch.text = settings.bankBranch;
    _branchCode.text = settings.branchCode;
    _micr.text = settings.micr;
    setState(() => _draft = settings);
  }

  void _save() {
    _model.updateSettings(
      _draft.copyWith(
        name: _name.text,
        gstin: _gstin.text,
        address: _address.text,
        phone: _phone.text,
        invoicePrefix: _prefix.text,
        upiId: _upi.text.trim(),
        accountName: _accountName.text.trim(),
        bankName: _bankName.text.trim(),
        accountNo: _accountNo.text.trim(),
        ifsc: _ifsc.text.trim(),
        bankBranch: _bankBranch.text.trim(),
        branchCode: _branchCode.text.trim(),
        micr: _micr.text.trim(),
      ),
    );
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    N.watch(context);
    final inset = MediaQuery.paddingOf(context);

    return ColoredBox(
      color: N.bg,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 20, 12),
              child: Row(
                children: [
                  const BackButtonN(),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Settings',
                      style: N.font(size: 24, weight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 24 + inset.bottom),
                children: [
                  const _Display(),
                  const SizedBox(height: 28),
                  const Kicker('Workshop details'),
                  const SizedBox(height: 4),
                  Text(
                    'These appear on every invoice you print. '
                    'Fill once — you can change them any time.',
                    style: N.caption(size: 15, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  NField(
                    label: 'Workshop name (printed on top of the bill)',
                    child: NInput(controller: _name, height: 52, fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                  NField(
                    label: 'GST number (GSTIN)',
                    hint: _GstinHint(valid: _draft.gstinLooksValid),
                    child: NInput(
                      controller: _gstin,
                      height: 52,
                      fontSize: 17,
                      letterSpacing: 15 * 0.06,
                    ),
                  ),
                  const SizedBox(height: 16),
                  NField(
                    label: 'Workshop address',
                    child: NInput(
                      controller: _address,
                      fontSize: 17,
                      multiline: true,
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                  const SizedBox(height: 16),
                  NField(
                    label: 'Phone number on the bill',
                    child: NInput(
                      controller: _phone,
                      height: 52,
                      fontSize: 17,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(height: 16),
                  NField(
                    label: 'Invoice numbers start with',
                    child: NInput(
                      controller: _prefix,
                      height: 52,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Kicker('Bank & UPI'),
                  const SizedBox(height: 4),
                  Text(
                    'Printed at the bottom of every bill so customers can '
                    'pay you. Leave a box blank to keep it off the bill.',
                    style: N.caption(size: 15, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  NField(
                    label: 'UPI ID (for the QR code on the bill)',
                    hint: _draft.upiId.trim().isEmpty
                        ? null
                        : _UpiHint(valid: _draft.upiIdLooksValid),
                    child: NInput(
                      controller: _upi,
                      height: 52,
                      fontSize: 17,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _bankField('Account holder name', _accountName),
                  _bankField('Bank name', _bankName),
                  _bankField(
                    'Account number',
                    _accountNo,
                    keyboardType: TextInputType.number,
                  ),
                  _bankField('IFSC code', _ifsc),
                  _bankField('Branch', _bankBranch),
                  _bankField(
                    'Branch code',
                    _branchCode,
                    keyboardType: TextInputType.number,
                  ),
                  _bankField('MICR', _micr, keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  Text(
                    'Are your rates and labour charges including GST?',
                    style: N.label(),
                  ),
                  const SizedBox(height: 6),
                  NSegmented<bool>(
                    options: const [false, true],
                    value: _draft.ratesIncludeGst,
                    expand: true,
                    labelOf: (inclusive) =>
                        inclusive ? 'Rates include GST' : 'Rates exclude GST',
                    onChanged: (value) => setState(
                      () => _draft = _draft.copyWith(ratesIncludeGst: value),
                    ),
                  ),
                  const SizedBox(height: 16),
                  NSwitchRow(
                    title: 'Work without internet',
                    subtitle: 'Bills save on this device and sync later',
                    value: _draft.worksOffline,
                    onChanged: (value) => setState(
                      () => _draft = _draft.copyWith(worksOffline: value),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 4),
                  NButton(
                    'Save details',
                    icon: PhosphorIcons.check,
                    height: 60,
                    fontSize: 18,
                    expand: true,
                    onPressed: _save,
                  ),
                  const SizedBox(height: 36),
                  BackupSection(onRestored: _onRestored),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One of the bank boxes, with the gap under it.
Widget _bankField(
  String label,
  TextEditingController controller, {
  TextInputType? keyboardType,
}) => Padding(
  padding: const EdgeInsets.only(bottom: 16),
  child: NField(
    label: label,
    child: NInput(
      controller: controller,
      height: 52,
      fontSize: 17,
      keyboardType: keyboardType,
    ),
  ),
);

class _UpiHint extends StatelessWidget {
  const _UpiHint({required this.valid});

  final bool valid;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      if (valid) ...[
        PhosphorIcon(PhosphorIcons.check, size: 16, color: N.successInk),
        const SizedBox(width: 5),
      ],
      Flexible(
        child: Text(
          valid
              ? 'Customers can scan the bill to pay this ID'
              : 'A UPI ID looks like workshop@upi',
          style: N.font(
            size: 14,
            weight: FontWeight.w500,
            color: valid ? N.successInk : N.warningInk,
          ),
        ),
      ),
    ],
  );
}

class _GstinHint extends StatelessWidget {
  const _GstinHint({required this.valid});

  final bool valid;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      if (valid) ...[
        PhosphorIcon(PhosphorIcons.check, size: 16, color: N.successInk),
        const SizedBox(width: 5),
      ],
      Flexible(
        child: Text(
          valid
              ? 'Looks like a valid 15-character GSTIN'
              : 'A GSTIN is 15 characters, like 23ABCDE1234F1Z5',
          style: N.font(
            size: 14,
            weight: FontWeight.w500,
            color: valid ? N.successInk : N.warningInk,
          ),
        ),
      ),
    ],
  );
}

/// How the screen in front of the counter looks: day or night, how large the
/// text is, and — on a tablet — which billing layout it opens on.
///
/// First on the page, because it is what someone new to the app most needs
/// to reach, and apart from the details below: none of it prints on an
/// invoice, so each choice takes effect on the tap rather than waiting for
/// "Save details".
class _Display extends StatelessWidget {
  const _Display();

  @override
  Widget build(BuildContext context) {
    final theme = ThemeScope.of(context);
    final model = BillingScope.of(context);
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Kicker('Screen'),
        const SizedBox(height: 4),
        Text('Changes show straight away.', style: N.caption(size: 15)),
        const SizedBox(height: 14),
        Text('Look', style: N.label()),
        const SizedBox(height: 6),
        NSegmented<NThemeMode>(
          options: NThemeMode.values,
          value: theme.mode,
          expand: true,
          labelOf: (mode) => mode.label,
          onChanged: theme.setMode,
        ),
        const SizedBox(height: 16),
        Text('Text size', style: N.label()),
        const SizedBox(height: 6),
        NSegmented<NTextSize>(
          options: NTextSize.values,
          value: theme.textSize,
          expand: true,
          labelOf: (size) => size.label,
          onChanged: theme.setTextSize,
        ),
        const SizedBox(height: 10),
        // A sample of what the counter will read, at the size just chosen.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: N.surface,
            borderRadius: N.brMd,
            border: Border.all(color: N.line, width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Engine oil change',
                  style: N.font(size: 16, weight: FontWeight.w600),
                ),
              ),
              Text(
                model.totalLabel,
                style: N.font(size: 20, weight: FontWeight.w600),
              ),
            ],
          ),
        ),
        if (wide) ...[
          const SizedBox(height: 16),
          Text('Billing screen on this tablet', style: N.label()),
          const SizedBox(height: 6),
          NSegmented<TabletLayout>(
            options: TabletLayout.values,
            value: theme.tabletLayout,
            expand: true,
            labelOf: (layout) => layout.label,
            onChanged: theme.setTabletLayout,
          ),
          const SizedBox(height: 6),
          Text(
            theme.tabletLayout == TabletLayout.search
                ? 'Search: type a name to find a part or job.'
                : 'Keypad: tap a common job, then punch in the quantity.',
            style: N.caption(size: 14),
          ),
        ],
      ],
    );
  }
}
