# Hisap

A GST billing app for an automobile workshop. Parts and labour go on one bill
against the vehicle they were fitted to, and the app prints an A4 tax invoice
with the CGST/SGST split, the amount in words, your bank details and a UPI QR
code the customer can scan to pay.

It is built tablet-first for the counter, with a phone layout for the floor, and
works fully offline: everything is kept in a SQLite database on the device.

Built with Flutter. It runs on Android, iOS, macOS, Windows, Linux and the web.

## Features

**Billing**
- Add parts (HSN) and labour (SAC 998714) from a rate card. Search by name, or
  add a new item on the spot if it isn't on the card.
- Three layouts for the same bill:
  - **Tablet, Search**: an icon rail and a type-to-add search box.
  - **Tablet, Keypad**: big buttons for common jobs and a number pad. No
    keyboard needed.
  - **Phone**: one-thumb billing with the charge button always in reach.
- Vehicle and customer on every bill: registration, make/model, odometer,
  name and phone.
- Rates can include GST (tax is backed out) or exclude it (tax is added on),
  set per workshop.
- Hold a bill while the job is still going, and date a bill back to the day the
  work was done.
- Take payment by Cash, UPI or Card, or leave it on account (Due).

**Tax invoice**
- A4 layout with the GSTIN, place of supply (worked out from the GSTIN), and
  HSN/SAC, taxable value, CGST, SGST and total for each line.
- Parts and labour listed under separate headings.
- **Bank details** block (account name, bank, A/c no., branch, IFSC, branch
  code, MICR). Fields you leave blank don't print.
- **UPI QR code** made for each invoice, with the bill total and invoice number
  already filled in. Any UPI app (GPay, PhonePe, Paytm, BHIM) can scan it.
- Print, or share/save as a real vector PDF (a few KB, text you can select).
  Long bills carry on to more pages.

**Records**
- Bills screen: every saved bill, what's still owed, and what's settled. Reopen,
  correct or print any of them again.
- Rate card editor: reprice, hide or restore parts and jobs.
- **Backup & restore** to a single JSON file (bills, rate card and workshop
  details). Restoring can merge with what's on the device or replace it, and
  can be undone.
- **CSV export** for the accountant, with the figures a GST return is filled from.

**Display**
- Day and Night themes, or match the device, and three text sizes (Normal,
  Large, Extra large).

## Getting started

### Requirements
- Flutter 3.32 or newer (Dart SDK ^3.8.1)
- For Android: Android SDK with NDK `27.0.12077973`
- For iOS/macOS: Xcode

### Run

```sh
flutter pub get
flutter run                 # choose a device when asked
flutter run -d macos        # or pick one: macos, chrome, windows, linux, <emulator-id>
```

### First-time setup in the app
Open **Settings** and fill in the workshop details. They print on every invoice:

1. Workshop name, GSTIN, address, phone, and what invoice numbers start with
   (default `INV/26-27/`).
2. **Bank & UPI**: your UPI ID (e.g. `workshop@upi`) and bank account
   details.
3. Whether your rates include GST.
4. Tap **Save details**.

## Development

### Tests

```sh
flutter analyze
flutter test
```

The tests cover GST pricing and rounding, the invoice data and PDF (including
the UPI link and page count), backup/restore, the SQLite stores, and widget
tests of the screens at tablet and phone sizes.

### Database code generation
The SQLite schema is defined with [drift](https://drift.simonbinder.eu/) in
`lib/data/database.dart`. After you change it, regenerate `database.g.dart`:

```sh
dart run build_runner build --delete-conflicting-outputs
```

Workshop settings are saved as one JSON record in the `meta` table, so adding a
settings field doesn't need a schema change. Older records still load, with the
new field left at its default.

### App icon
See [`tool/app_icon/README.md`](tool/app_icon/README.md) for how to change the
icon and export it for every platform.

## Project structure

```
lib/
├── main.dart               App entry: opens the database, loads settings
├── data/                   Drift schema, and migration from older builds'
│                           SharedPreferences data
├── models/                 Bills, rate card, vehicle, money, pricing, invoice,
│                           UPI link
├── state/                  BillingModel (the shared bill), SQLite stores,
│                           backup, theme
├── screens/                Billing layouts (phone and two tablet layouts),
│                           bills, rate card, settings, A4 invoice
├── services/               Invoice PDF builder, CSV export, sharing/saving files
├── widgets/                Shared pieces: vehicle panel, dialogs, date picker,
│                           backup section
└── theme/                  "Nocturne" design system: tokens, components, icons
test/                       Unit and widget tests
tool/app_icon/              Icon renderer and exporter
assets/fonts/               Inter, bundled (also has the ₹ sign for the PDF)
```

## Key dependencies

| Package | Used for |
|---|---|
| `drift`, `drift_flutter` | SQLite database |
| `pdf`, `printing` | Building the invoice PDF, and printing/sharing it |
| `barcode` | Drawing the UPI QR code on screen (the PDF uses the same library) |
| `file_picker`, `share_plus` | Backup import/export and CSV sharing |
| `shared_preferences` | Reading data from older builds, once, to move it to SQLite |
