import 'package:hisap_app_2_0/models/catalog.dart';
import 'package:hisap_app_2_0/models/vehicle.dart';
import 'package:hisap_app_2_0/state/billing_model.dart';

extension DemoBill on BillingModel {
  /// Puts on the counter the job these tests are written against: a Bolero in
  /// for an oil change and wheel balancing — seven pieces on four lines. The
  /// app itself opens on a blank bill.
  ///
  /// Priced with GST added on top, whatever the app's default: the figures
  /// the tests check (₹2,974 and the rest) are worked out that way. A test
  /// about inclusive rates switches to them itself.
  BillingModel withDemoBill() {
    updateSettings(settings.copyWith(ratesIncludeGst: false));
    addToCart(seedCatalog[0]); // Engine Oil 5W-30
    addToCart(seedCatalog[1]); // Oil Filter
    addToCart(seedCatalog[10]); // Engine oil change
    addToCart(seedCatalog[11], qty: 4); // Wheel balancing, four wheels
    updateVehicle(
      const VehicleDetails(
        registration: 'MZ 01 AB 1234',
        makeModel: 'BOLERO',
        odometer: '48210',
        customerName: '',
        customerPhone: '98220 41188',
      ),
    );
    return this;
  }
}
