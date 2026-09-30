import 'package:flutter/widgets.dart';

import '../state/billing_model.dart';
import '../theme/components.dart';
import '../theme/nocturne.dart';
import '../theme/phosphor.dart';

/// The car on the ramp, above the bill it is being charged for: one line
/// that says whose it is and opens the full form.
///
/// A line rather than five open fields, on the tablet too — the registration
/// and the reading are still a tap away, and the bill below gets the room.
class VehicleSummaryRow extends StatelessWidget {
  const VehicleSummaryRow({super.key});

  @override
  Widget build(BuildContext context) {
    final model = BillingScope.of(context);
    final vehicle = model.vehicle;
    final odometer = vehicle.odometerLabel;
    final checkRegistration =
        vehicle.registration.trim().isNotEmpty &&
        !vehicle.registrationLooksValid;

    return Semantics(
      button: true,
      label: 'Vehicle and customer',
      child: Tappable(
        onTap: () => showVehicleDialog(context),
        builder: (context, states, _) => Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: N.panel,
            borderRadius: N.brLg,
            border: Border.all(
              color: states.hovered ? N.accent : N.line,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: vehicle.hasVehicle ? N.accent800 : N.neutral800,
                  borderRadius: N.brMd,
                ),
                child: PhosphorIcon(
                  PhosphorIcons.car,
                  size: 24,
                  color: vehicle.hasVehicle ? N.accent100 : N.t(0.75),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      vehicle.hasVehicle ? vehicle.summary : 'No vehicle yet',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: N.font(size: 17, weight: FontWeight.w600),
                    ),
                    Text(
                      [
                            if (vehicle.customerName.trim().isNotEmpty)
                              vehicle.customerName.trim(),
                            if (odometer.isNotEmpty) odometer,
                          ]
                          .join(' · ')
                          .ifEmpty('Tap to add the car and the customer'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: N.caption(size: 14),
                    ),
                  ],
                ),
              ),
              if (checkRegistration) ...[
                const SizedBox(width: 10),
                const NTag.warning('Check number', icon: PhosphorIcons.pencil),
              ],
              const SizedBox(width: 10),
              ExcludeSemantics(
                child: NButton(
                  vehicle.hasVehicle ? 'Edit' : 'Add',
                  variant: ButtonVariant.secondary,
                  icon: vehicle.hasVehicle
                      ? PhosphorIcons.pencil
                      : PhosphorIcons.plus,
                  height: 44,
                  padding: 14,
                  onPressed: () => showVehicleDialog(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}

/// The vehicle and customer, in a dialog.
Future<void> showVehicleDialog(BuildContext context) {
  final model = BillingScope.read(context);
  return showNocturneDialog<void>(
    context: context,
    builder: (context) => _VehicleDialog(model: model),
  );
}

class _VehicleDialog extends StatefulWidget {
  const _VehicleDialog({required this.model});

  final BillingModel model;

  @override
  State<_VehicleDialog> createState() => _VehicleDialogState();
}

class _VehicleDialogState extends State<_VehicleDialog> {
  late final _fields = _VehicleFields(widget.model);

  @override
  void dispose() {
    _fields.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NDialog(
      title: 'Vehicle & customer',
      actions: [
        NButton(
          'Done',
          height: 52,
          padding: 20,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NField(
            label: 'Registration no.',
            child: NInput(
              key: const ValueKey('vehicle-dialog-registration'),
              controller: _fields.registration,
              height: 52,
              fontSize: 17,
              letterSpacing: 15 * 0.04,
              placeholder: 'MZ 01 AB 1234',
              onChanged: (v) => _fields.push(registration: v),
            ),
          ),
          const SizedBox(height: N.space4),
          NField(
            label: 'Make & model',
            child: NInput(
              key: const ValueKey('vehicle-dialog-makeModel'),
              controller: _fields.makeModel,
              height: 52,
              fontSize: 17,
              placeholder: 'Bolero',
              onChanged: (v) => _fields.push(makeModel: v),
            ),
          ),
          const SizedBox(height: N.space4),
          NField(
            label: 'Odometer (km)',
            child: NInput(
              key: const ValueKey('vehicle-dialog-odometer'),
              controller: _fields.odometer,
              height: 52,
              fontSize: 17,
              placeholder: '48210',
              keyboardType: TextInputType.number,
              onChanged: (v) => _fields.push(odometer: v),
            ),
          ),
          const SizedBox(height: N.space4),
          NField(
            label: 'Customer',
            child: NInput(
              key: const ValueKey('vehicle-dialog-customerName'),
              controller: _fields.customerName,
              height: 52,
              fontSize: 17,
              placeholder: 'Name on the bill',
              onChanged: (v) => _fields.push(customerName: v),
            ),
          ),
          const SizedBox(height: N.space4),
          NField(
            label: 'Phone',
            child: NInput(
              key: const ValueKey('vehicle-dialog-customerPhone'),
              controller: _fields.customerPhone,
              height: 52,
              fontSize: 17,
              placeholder: '98220 41188',
              keyboardType: TextInputType.phone,
              onChanged: (v) => _fields.push(customerPhone: v),
            ),
          ),
        ],
      ),
    );
  }
}

/// The five controllers the dialog needs, and the one place that writes them
/// back to the bill.
class _VehicleFields {
  _VehicleFields(this.model)
    : registration = TextEditingController(text: model.vehicle.registration),
      makeModel = TextEditingController(text: model.vehicle.makeModel),
      odometer = TextEditingController(text: model.vehicle.odometer),
      customerName = TextEditingController(text: model.vehicle.customerName),
      customerPhone = TextEditingController(text: model.vehicle.customerPhone);

  final BillingModel model;
  final TextEditingController registration;
  final TextEditingController makeModel;
  final TextEditingController odometer;
  final TextEditingController customerName;
  final TextEditingController customerPhone;

  void push({
    String? registration,
    String? makeModel,
    String? odometer,
    String? customerName,
    String? customerPhone,
  }) {
    model.updateVehicle(
      model.vehicle.copyWith(
        registration: registration,
        makeModel: makeModel,
        odometer: odometer,
        customerName: customerName,
        customerPhone: customerPhone,
      ),
    );
  }

  void dispose() {
    for (final controller in [
      registration,
      makeModel,
      odometer,
      customerName,
      customerPhone,
    ]) {
      controller.dispose();
    }
  }
}
