import 'money.dart';

/// The vehicle a bill is raised against, and whoever is paying for it.
///
/// A workshop invoice is against a vehicle, not just a customer — the
/// registration and the odometer reading are what the owner, and any warranty
/// claim, will look for.
class VehicleDetails {
  const VehicleDetails({
    this.registration = '',
    this.makeModel = '',
    this.odometer = '',
    this.customerName = '',
    this.customerPhone = '',
  });

  final String registration;
  final String makeModel;

  /// Kept as typed. A reading is a number the mechanic copies off the dash,
  /// and refusing what they typed because of a stray letter helps nobody.
  final String odometer;

  final String customerName;
  final String customerPhone;

  VehicleDetails copyWith({
    String? registration,
    String? makeModel,
    String? odometer,
    String? customerName,
    String? customerPhone,
  }) => VehicleDetails(
    registration: registration ?? this.registration,
    makeModel: makeModel ?? this.makeModel,
    odometer: odometer ?? this.odometer,
    customerName: customerName ?? this.customerName,
    customerPhone: customerPhone ?? this.customerPhone,
  );

  Map<String, Object?> toJson() => {
    'registration': registration,
    'makeModel': makeModel,
    'odometer': odometer,
    'customerName': customerName,
    'customerPhone': customerPhone,
  };

  static VehicleDetails fromJson(Object? json) {
    if (json is! Map) return const VehicleDetails();
    String read(String key) => json[key] is String ? json[key] as String : '';
    return VehicleDetails(
      registration: read('registration'),
      makeModel: read('makeModel'),
      odometer: read('odometer'),
      customerName: read('customerName'),
      customerPhone: read('customerPhone'),
    );
  }

  bool get hasVehicle =>
      registration.trim().isNotEmpty || makeModel.trim().isNotEmpty;

  /// An Indian registration is a state code, an RTO code that may itself carry
  /// a letter (DL 3C), a series and up to four digits — MH 12 AB 1234.
  /// Spacing and case are the shop's business.
  static final _registrationPattern = RegExp(
    r'^[A-Z]{2}\s?\d{1,2}[A-Z]?\s?[A-Z]{0,3}\s?\d{1,4}$',
  );

  /// Advisory only. It drives a hint next to the field, never a block: an
  /// out-of-state or BH-series plate the pattern has not met must still be
  /// billable.
  bool get registrationLooksValid =>
      _registrationPattern.hasMatch(registration.trim().toUpperCase());

  /// The odometer with thousands separators and its unit, or blank when it was
  /// left empty.
  String get odometerLabel {
    final digits = odometer.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    final value = int.tryParse(digits);
    if (value == null) return odometer.trim();
    return '${groupIndian(value, decimals: 0)} km';
  }

  /// One line for a header chip or a phone summary row.
  String get summary {
    final parts = [
      if (registration.trim().isNotEmpty) registration.trim().toUpperCase(),
      if (makeModel.trim().isNotEmpty) makeModel.trim(),
    ];
    return parts.isEmpty ? 'No vehicle yet' : parts.join(' · ');
  }
}
