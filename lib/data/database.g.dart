// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $BillsTable extends Bills with TableInfo<$BillsTable, BillRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BillsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _invoiceNoMeta = const VerificationMeta(
    'invoiceNo',
  );
  @override
  late final GeneratedColumn<String> invoiceNo = GeneratedColumn<String>(
    'invoice_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentMeta = const VerificationMeta(
    'payment',
  );
  @override
  late final GeneratedColumn<String> payment = GeneratedColumn<String>(
    'payment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratesIncludeGstMeta = const VerificationMeta(
    'ratesIncludeGst',
  );
  @override
  late final GeneratedColumn<bool> ratesIncludeGst = GeneratedColumn<bool>(
    'rates_include_gst',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("rates_include_gst" IN (0, 1))',
    ),
  );
  static const VerificationMeta _registrationMeta = const VerificationMeta(
    'registration',
  );
  @override
  late final GeneratedColumn<String> registration = GeneratedColumn<String>(
    'registration',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _makeModelMeta = const VerificationMeta(
    'makeModel',
  );
  @override
  late final GeneratedColumn<String> makeModel = GeneratedColumn<String>(
    'make_model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _odometerMeta = const VerificationMeta(
    'odometer',
  );
  @override
  late final GeneratedColumn<String> odometer = GeneratedColumn<String>(
    'odometer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _customerNameMeta = const VerificationMeta(
    'customerName',
  );
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
    'customer_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _customerPhoneMeta = const VerificationMeta(
    'customerPhone',
  );
  @override
  late final GeneratedColumn<String> customerPhone = GeneratedColumn<String>(
    'customer_phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    invoiceNo,
    date,
    status,
    payment,
    ratesIncludeGst,
    registration,
    makeModel,
    odometer,
    customerName,
    customerPhone,
    seq,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bills';
  @override
  VerificationContext validateIntegrity(
    Insertable<BillRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('invoice_no')) {
      context.handle(
        _invoiceNoMeta,
        invoiceNo.isAcceptableOrUnknown(data['invoice_no']!, _invoiceNoMeta),
      );
    } else if (isInserting) {
      context.missing(_invoiceNoMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('payment')) {
      context.handle(
        _paymentMeta,
        payment.isAcceptableOrUnknown(data['payment']!, _paymentMeta),
      );
    }
    if (data.containsKey('rates_include_gst')) {
      context.handle(
        _ratesIncludeGstMeta,
        ratesIncludeGst.isAcceptableOrUnknown(
          data['rates_include_gst']!,
          _ratesIncludeGstMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ratesIncludeGstMeta);
    }
    if (data.containsKey('registration')) {
      context.handle(
        _registrationMeta,
        registration.isAcceptableOrUnknown(
          data['registration']!,
          _registrationMeta,
        ),
      );
    }
    if (data.containsKey('make_model')) {
      context.handle(
        _makeModelMeta,
        makeModel.isAcceptableOrUnknown(data['make_model']!, _makeModelMeta),
      );
    }
    if (data.containsKey('odometer')) {
      context.handle(
        _odometerMeta,
        odometer.isAcceptableOrUnknown(data['odometer']!, _odometerMeta),
      );
    }
    if (data.containsKey('customer_name')) {
      context.handle(
        _customerNameMeta,
        customerName.isAcceptableOrUnknown(
          data['customer_name']!,
          _customerNameMeta,
        ),
      );
    }
    if (data.containsKey('customer_phone')) {
      context.handle(
        _customerPhoneMeta,
        customerPhone.isAcceptableOrUnknown(
          data['customer_phone']!,
          _customerPhoneMeta,
        ),
      );
    }
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BillRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BillRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      invoiceNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_no'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      payment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment'],
      ),
      ratesIncludeGst: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}rates_include_gst'],
      )!,
      registration: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}registration'],
      )!,
      makeModel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}make_model'],
      )!,
      odometer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}odometer'],
      )!,
      customerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_name'],
      )!,
      customerPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_phone'],
      )!,
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
    );
  }

  @override
  $BillsTable createAlias(String alias) {
    return $BillsTable(attachedDatabase, alias);
  }
}

class BillRow extends DataClass implements Insertable<BillRow> {
  final String id;
  final String invoiceNo;
  final DateTime date;
  final String status;
  final String? payment;
  final bool ratesIncludeGst;
  final String registration;
  final String makeModel;
  final String odometer;
  final String customerName;
  final String customerPhone;

  /// The order bills were raised in. Kept when a bill is saved again, so a
  /// correction does not move it to the end of the list.
  final int seq;
  const BillRow({
    required this.id,
    required this.invoiceNo,
    required this.date,
    required this.status,
    this.payment,
    required this.ratesIncludeGst,
    required this.registration,
    required this.makeModel,
    required this.odometer,
    required this.customerName,
    required this.customerPhone,
    required this.seq,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['invoice_no'] = Variable<String>(invoiceNo);
    map['date'] = Variable<DateTime>(date);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || payment != null) {
      map['payment'] = Variable<String>(payment);
    }
    map['rates_include_gst'] = Variable<bool>(ratesIncludeGst);
    map['registration'] = Variable<String>(registration);
    map['make_model'] = Variable<String>(makeModel);
    map['odometer'] = Variable<String>(odometer);
    map['customer_name'] = Variable<String>(customerName);
    map['customer_phone'] = Variable<String>(customerPhone);
    map['seq'] = Variable<int>(seq);
    return map;
  }

  BillsCompanion toCompanion(bool nullToAbsent) {
    return BillsCompanion(
      id: Value(id),
      invoiceNo: Value(invoiceNo),
      date: Value(date),
      status: Value(status),
      payment: payment == null && nullToAbsent
          ? const Value.absent()
          : Value(payment),
      ratesIncludeGst: Value(ratesIncludeGst),
      registration: Value(registration),
      makeModel: Value(makeModel),
      odometer: Value(odometer),
      customerName: Value(customerName),
      customerPhone: Value(customerPhone),
      seq: Value(seq),
    );
  }

  factory BillRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BillRow(
      id: serializer.fromJson<String>(json['id']),
      invoiceNo: serializer.fromJson<String>(json['invoiceNo']),
      date: serializer.fromJson<DateTime>(json['date']),
      status: serializer.fromJson<String>(json['status']),
      payment: serializer.fromJson<String?>(json['payment']),
      ratesIncludeGst: serializer.fromJson<bool>(json['ratesIncludeGst']),
      registration: serializer.fromJson<String>(json['registration']),
      makeModel: serializer.fromJson<String>(json['makeModel']),
      odometer: serializer.fromJson<String>(json['odometer']),
      customerName: serializer.fromJson<String>(json['customerName']),
      customerPhone: serializer.fromJson<String>(json['customerPhone']),
      seq: serializer.fromJson<int>(json['seq']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'invoiceNo': serializer.toJson<String>(invoiceNo),
      'date': serializer.toJson<DateTime>(date),
      'status': serializer.toJson<String>(status),
      'payment': serializer.toJson<String?>(payment),
      'ratesIncludeGst': serializer.toJson<bool>(ratesIncludeGst),
      'registration': serializer.toJson<String>(registration),
      'makeModel': serializer.toJson<String>(makeModel),
      'odometer': serializer.toJson<String>(odometer),
      'customerName': serializer.toJson<String>(customerName),
      'customerPhone': serializer.toJson<String>(customerPhone),
      'seq': serializer.toJson<int>(seq),
    };
  }

  BillRow copyWith({
    String? id,
    String? invoiceNo,
    DateTime? date,
    String? status,
    Value<String?> payment = const Value.absent(),
    bool? ratesIncludeGst,
    String? registration,
    String? makeModel,
    String? odometer,
    String? customerName,
    String? customerPhone,
    int? seq,
  }) => BillRow(
    id: id ?? this.id,
    invoiceNo: invoiceNo ?? this.invoiceNo,
    date: date ?? this.date,
    status: status ?? this.status,
    payment: payment.present ? payment.value : this.payment,
    ratesIncludeGst: ratesIncludeGst ?? this.ratesIncludeGst,
    registration: registration ?? this.registration,
    makeModel: makeModel ?? this.makeModel,
    odometer: odometer ?? this.odometer,
    customerName: customerName ?? this.customerName,
    customerPhone: customerPhone ?? this.customerPhone,
    seq: seq ?? this.seq,
  );
  BillRow copyWithCompanion(BillsCompanion data) {
    return BillRow(
      id: data.id.present ? data.id.value : this.id,
      invoiceNo: data.invoiceNo.present ? data.invoiceNo.value : this.invoiceNo,
      date: data.date.present ? data.date.value : this.date,
      status: data.status.present ? data.status.value : this.status,
      payment: data.payment.present ? data.payment.value : this.payment,
      ratesIncludeGst: data.ratesIncludeGst.present
          ? data.ratesIncludeGst.value
          : this.ratesIncludeGst,
      registration: data.registration.present
          ? data.registration.value
          : this.registration,
      makeModel: data.makeModel.present ? data.makeModel.value : this.makeModel,
      odometer: data.odometer.present ? data.odometer.value : this.odometer,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      customerPhone: data.customerPhone.present
          ? data.customerPhone.value
          : this.customerPhone,
      seq: data.seq.present ? data.seq.value : this.seq,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BillRow(')
          ..write('id: $id, ')
          ..write('invoiceNo: $invoiceNo, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('payment: $payment, ')
          ..write('ratesIncludeGst: $ratesIncludeGst, ')
          ..write('registration: $registration, ')
          ..write('makeModel: $makeModel, ')
          ..write('odometer: $odometer, ')
          ..write('customerName: $customerName, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('seq: $seq')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    invoiceNo,
    date,
    status,
    payment,
    ratesIncludeGst,
    registration,
    makeModel,
    odometer,
    customerName,
    customerPhone,
    seq,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BillRow &&
          other.id == this.id &&
          other.invoiceNo == this.invoiceNo &&
          other.date == this.date &&
          other.status == this.status &&
          other.payment == this.payment &&
          other.ratesIncludeGst == this.ratesIncludeGst &&
          other.registration == this.registration &&
          other.makeModel == this.makeModel &&
          other.odometer == this.odometer &&
          other.customerName == this.customerName &&
          other.customerPhone == this.customerPhone &&
          other.seq == this.seq);
}

class BillsCompanion extends UpdateCompanion<BillRow> {
  final Value<String> id;
  final Value<String> invoiceNo;
  final Value<DateTime> date;
  final Value<String> status;
  final Value<String?> payment;
  final Value<bool> ratesIncludeGst;
  final Value<String> registration;
  final Value<String> makeModel;
  final Value<String> odometer;
  final Value<String> customerName;
  final Value<String> customerPhone;
  final Value<int> seq;
  final Value<int> rowid;
  const BillsCompanion({
    this.id = const Value.absent(),
    this.invoiceNo = const Value.absent(),
    this.date = const Value.absent(),
    this.status = const Value.absent(),
    this.payment = const Value.absent(),
    this.ratesIncludeGst = const Value.absent(),
    this.registration = const Value.absent(),
    this.makeModel = const Value.absent(),
    this.odometer = const Value.absent(),
    this.customerName = const Value.absent(),
    this.customerPhone = const Value.absent(),
    this.seq = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BillsCompanion.insert({
    required String id,
    required String invoiceNo,
    required DateTime date,
    required String status,
    this.payment = const Value.absent(),
    required bool ratesIncludeGst,
    this.registration = const Value.absent(),
    this.makeModel = const Value.absent(),
    this.odometer = const Value.absent(),
    this.customerName = const Value.absent(),
    this.customerPhone = const Value.absent(),
    required int seq,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       invoiceNo = Value(invoiceNo),
       date = Value(date),
       status = Value(status),
       ratesIncludeGst = Value(ratesIncludeGst),
       seq = Value(seq);
  static Insertable<BillRow> custom({
    Expression<String>? id,
    Expression<String>? invoiceNo,
    Expression<DateTime>? date,
    Expression<String>? status,
    Expression<String>? payment,
    Expression<bool>? ratesIncludeGst,
    Expression<String>? registration,
    Expression<String>? makeModel,
    Expression<String>? odometer,
    Expression<String>? customerName,
    Expression<String>? customerPhone,
    Expression<int>? seq,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceNo != null) 'invoice_no': invoiceNo,
      if (date != null) 'date': date,
      if (status != null) 'status': status,
      if (payment != null) 'payment': payment,
      if (ratesIncludeGst != null) 'rates_include_gst': ratesIncludeGst,
      if (registration != null) 'registration': registration,
      if (makeModel != null) 'make_model': makeModel,
      if (odometer != null) 'odometer': odometer,
      if (customerName != null) 'customer_name': customerName,
      if (customerPhone != null) 'customer_phone': customerPhone,
      if (seq != null) 'seq': seq,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BillsCompanion copyWith({
    Value<String>? id,
    Value<String>? invoiceNo,
    Value<DateTime>? date,
    Value<String>? status,
    Value<String?>? payment,
    Value<bool>? ratesIncludeGst,
    Value<String>? registration,
    Value<String>? makeModel,
    Value<String>? odometer,
    Value<String>? customerName,
    Value<String>? customerPhone,
    Value<int>? seq,
    Value<int>? rowid,
  }) {
    return BillsCompanion(
      id: id ?? this.id,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      date: date ?? this.date,
      status: status ?? this.status,
      payment: payment ?? this.payment,
      ratesIncludeGst: ratesIncludeGst ?? this.ratesIncludeGst,
      registration: registration ?? this.registration,
      makeModel: makeModel ?? this.makeModel,
      odometer: odometer ?? this.odometer,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      seq: seq ?? this.seq,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (invoiceNo.present) {
      map['invoice_no'] = Variable<String>(invoiceNo.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (payment.present) {
      map['payment'] = Variable<String>(payment.value);
    }
    if (ratesIncludeGst.present) {
      map['rates_include_gst'] = Variable<bool>(ratesIncludeGst.value);
    }
    if (registration.present) {
      map['registration'] = Variable<String>(registration.value);
    }
    if (makeModel.present) {
      map['make_model'] = Variable<String>(makeModel.value);
    }
    if (odometer.present) {
      map['odometer'] = Variable<String>(odometer.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (customerPhone.present) {
      map['customer_phone'] = Variable<String>(customerPhone.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BillsCompanion(')
          ..write('id: $id, ')
          ..write('invoiceNo: $invoiceNo, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('payment: $payment, ')
          ..write('ratesIncludeGst: $ratesIncludeGst, ')
          ..write('registration: $registration, ')
          ..write('makeModel: $makeModel, ')
          ..write('odometer: $odometer, ')
          ..write('customerName: $customerName, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('seq: $seq, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BillLinesTable extends BillLines
    with TableInfo<$BillLinesTable, BillLineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BillLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _billIdMeta = const VerificationMeta('billId');
  @override
  late final GeneratedColumn<String> billId = GeneratedColumn<String>(
    'bill_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES bills (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateMeta = const VerificationMeta('rate');
  @override
  late final GeneratedColumn<double> rate = GeneratedColumn<double>(
    'rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gstMeta = const VerificationMeta('gst');
  @override
  late final GeneratedColumn<int> gst = GeneratedColumn<int>(
    'gst',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<int> qty = GeneratedColumn<int>(
    'qty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    billId,
    position,
    name,
    rate,
    gst,
    kind,
    code,
    qty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bill_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<BillLineRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('bill_id')) {
      context.handle(
        _billIdMeta,
        billId.isAcceptableOrUnknown(data['bill_id']!, _billIdMeta),
      );
    } else if (isInserting) {
      context.missing(_billIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('rate')) {
      context.handle(
        _rateMeta,
        rate.isAcceptableOrUnknown(data['rate']!, _rateMeta),
      );
    } else if (isInserting) {
      context.missing(_rateMeta);
    }
    if (data.containsKey('gst')) {
      context.handle(
        _gstMeta,
        gst.isAcceptableOrUnknown(data['gst']!, _gstMeta),
      );
    } else if (isInserting) {
      context.missing(_gstMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('qty')) {
      context.handle(
        _qtyMeta,
        qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta),
      );
    } else if (isInserting) {
      context.missing(_qtyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {billId, position};
  @override
  BillLineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BillLineRow(
      billId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bill_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      rate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rate'],
      )!,
      gst: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gst'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      qty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}qty'],
      )!,
    );
  }

  @override
  $BillLinesTable createAlias(String alias) {
    return $BillLinesTable(attachedDatabase, alias);
  }
}

class BillLineRow extends DataClass implements Insertable<BillLineRow> {
  final String billId;
  final int position;
  final String name;
  final double rate;
  final int gst;
  final String kind;
  final String code;
  final int qty;
  const BillLineRow({
    required this.billId,
    required this.position,
    required this.name,
    required this.rate,
    required this.gst,
    required this.kind,
    required this.code,
    required this.qty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['bill_id'] = Variable<String>(billId);
    map['position'] = Variable<int>(position);
    map['name'] = Variable<String>(name);
    map['rate'] = Variable<double>(rate);
    map['gst'] = Variable<int>(gst);
    map['kind'] = Variable<String>(kind);
    map['code'] = Variable<String>(code);
    map['qty'] = Variable<int>(qty);
    return map;
  }

  BillLinesCompanion toCompanion(bool nullToAbsent) {
    return BillLinesCompanion(
      billId: Value(billId),
      position: Value(position),
      name: Value(name),
      rate: Value(rate),
      gst: Value(gst),
      kind: Value(kind),
      code: Value(code),
      qty: Value(qty),
    );
  }

  factory BillLineRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BillLineRow(
      billId: serializer.fromJson<String>(json['billId']),
      position: serializer.fromJson<int>(json['position']),
      name: serializer.fromJson<String>(json['name']),
      rate: serializer.fromJson<double>(json['rate']),
      gst: serializer.fromJson<int>(json['gst']),
      kind: serializer.fromJson<String>(json['kind']),
      code: serializer.fromJson<String>(json['code']),
      qty: serializer.fromJson<int>(json['qty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'billId': serializer.toJson<String>(billId),
      'position': serializer.toJson<int>(position),
      'name': serializer.toJson<String>(name),
      'rate': serializer.toJson<double>(rate),
      'gst': serializer.toJson<int>(gst),
      'kind': serializer.toJson<String>(kind),
      'code': serializer.toJson<String>(code),
      'qty': serializer.toJson<int>(qty),
    };
  }

  BillLineRow copyWith({
    String? billId,
    int? position,
    String? name,
    double? rate,
    int? gst,
    String? kind,
    String? code,
    int? qty,
  }) => BillLineRow(
    billId: billId ?? this.billId,
    position: position ?? this.position,
    name: name ?? this.name,
    rate: rate ?? this.rate,
    gst: gst ?? this.gst,
    kind: kind ?? this.kind,
    code: code ?? this.code,
    qty: qty ?? this.qty,
  );
  BillLineRow copyWithCompanion(BillLinesCompanion data) {
    return BillLineRow(
      billId: data.billId.present ? data.billId.value : this.billId,
      position: data.position.present ? data.position.value : this.position,
      name: data.name.present ? data.name.value : this.name,
      rate: data.rate.present ? data.rate.value : this.rate,
      gst: data.gst.present ? data.gst.value : this.gst,
      kind: data.kind.present ? data.kind.value : this.kind,
      code: data.code.present ? data.code.value : this.code,
      qty: data.qty.present ? data.qty.value : this.qty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BillLineRow(')
          ..write('billId: $billId, ')
          ..write('position: $position, ')
          ..write('name: $name, ')
          ..write('rate: $rate, ')
          ..write('gst: $gst, ')
          ..write('kind: $kind, ')
          ..write('code: $code, ')
          ..write('qty: $qty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(billId, position, name, rate, gst, kind, code, qty);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BillLineRow &&
          other.billId == this.billId &&
          other.position == this.position &&
          other.name == this.name &&
          other.rate == this.rate &&
          other.gst == this.gst &&
          other.kind == this.kind &&
          other.code == this.code &&
          other.qty == this.qty);
}

class BillLinesCompanion extends UpdateCompanion<BillLineRow> {
  final Value<String> billId;
  final Value<int> position;
  final Value<String> name;
  final Value<double> rate;
  final Value<int> gst;
  final Value<String> kind;
  final Value<String> code;
  final Value<int> qty;
  final Value<int> rowid;
  const BillLinesCompanion({
    this.billId = const Value.absent(),
    this.position = const Value.absent(),
    this.name = const Value.absent(),
    this.rate = const Value.absent(),
    this.gst = const Value.absent(),
    this.kind = const Value.absent(),
    this.code = const Value.absent(),
    this.qty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BillLinesCompanion.insert({
    required String billId,
    required int position,
    required String name,
    required double rate,
    required int gst,
    required String kind,
    this.code = const Value.absent(),
    required int qty,
    this.rowid = const Value.absent(),
  }) : billId = Value(billId),
       position = Value(position),
       name = Value(name),
       rate = Value(rate),
       gst = Value(gst),
       kind = Value(kind),
       qty = Value(qty);
  static Insertable<BillLineRow> custom({
    Expression<String>? billId,
    Expression<int>? position,
    Expression<String>? name,
    Expression<double>? rate,
    Expression<int>? gst,
    Expression<String>? kind,
    Expression<String>? code,
    Expression<int>? qty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (billId != null) 'bill_id': billId,
      if (position != null) 'position': position,
      if (name != null) 'name': name,
      if (rate != null) 'rate': rate,
      if (gst != null) 'gst': gst,
      if (kind != null) 'kind': kind,
      if (code != null) 'code': code,
      if (qty != null) 'qty': qty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BillLinesCompanion copyWith({
    Value<String>? billId,
    Value<int>? position,
    Value<String>? name,
    Value<double>? rate,
    Value<int>? gst,
    Value<String>? kind,
    Value<String>? code,
    Value<int>? qty,
    Value<int>? rowid,
  }) {
    return BillLinesCompanion(
      billId: billId ?? this.billId,
      position: position ?? this.position,
      name: name ?? this.name,
      rate: rate ?? this.rate,
      gst: gst ?? this.gst,
      kind: kind ?? this.kind,
      code: code ?? this.code,
      qty: qty ?? this.qty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (billId.present) {
      map['bill_id'] = Variable<String>(billId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rate.present) {
      map['rate'] = Variable<double>(rate.value);
    }
    if (gst.present) {
      map['gst'] = Variable<int>(gst.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (qty.present) {
      map['qty'] = Variable<int>(qty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BillLinesCompanion(')
          ..write('billId: $billId, ')
          ..write('position: $position, ')
          ..write('name: $name, ')
          ..write('rate: $rate, ')
          ..write('gst: $gst, ')
          ..write('kind: $kind, ')
          ..write('code: $code, ')
          ..write('qty: $qty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomItemsTable extends CustomItems
    with TableInfo<$CustomItemsTable, CustomItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateMeta = const VerificationMeta('rate');
  @override
  late final GeneratedColumn<double> rate = GeneratedColumn<double>(
    'rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gstMeta = const VerificationMeta('gst');
  @override
  late final GeneratedColumn<int> gst = GeneratedColumn<int>(
    'gst',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _stockMeta = const VerificationMeta('stock');
  @override
  late final GeneratedColumn<int> stock = GeneratedColumn<int>(
    'stock',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    name,
    rate,
    gst,
    kind,
    code,
    stock,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('rate')) {
      context.handle(
        _rateMeta,
        rate.isAcceptableOrUnknown(data['rate']!, _rateMeta),
      );
    } else if (isInserting) {
      context.missing(_rateMeta);
    }
    if (data.containsKey('gst')) {
      context.handle(
        _gstMeta,
        gst.isAcceptableOrUnknown(data['gst']!, _gstMeta),
      );
    } else if (isInserting) {
      context.missing(_gstMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('stock')) {
      context.handle(
        _stockMeta,
        stock.isAcceptableOrUnknown(data['stock']!, _stockMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {position};
  @override
  CustomItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomItemRow(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      rate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rate'],
      )!,
      gst: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gst'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      stock: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stock'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $CustomItemsTable createAlias(String alias) {
    return $CustomItemsTable(attachedDatabase, alias);
  }
}

class CustomItemRow extends DataClass implements Insertable<CustomItemRow> {
  final String name;
  final double rate;
  final int gst;
  final String kind;
  final String code;
  final int? stock;
  final int position;
  const CustomItemRow({
    required this.name,
    required this.rate,
    required this.gst,
    required this.kind,
    required this.code,
    this.stock,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['rate'] = Variable<double>(rate);
    map['gst'] = Variable<int>(gst);
    map['kind'] = Variable<String>(kind);
    map['code'] = Variable<String>(code);
    if (!nullToAbsent || stock != null) {
      map['stock'] = Variable<int>(stock);
    }
    map['position'] = Variable<int>(position);
    return map;
  }

  CustomItemsCompanion toCompanion(bool nullToAbsent) {
    return CustomItemsCompanion(
      name: Value(name),
      rate: Value(rate),
      gst: Value(gst),
      kind: Value(kind),
      code: Value(code),
      stock: stock == null && nullToAbsent
          ? const Value.absent()
          : Value(stock),
      position: Value(position),
    );
  }

  factory CustomItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomItemRow(
      name: serializer.fromJson<String>(json['name']),
      rate: serializer.fromJson<double>(json['rate']),
      gst: serializer.fromJson<int>(json['gst']),
      kind: serializer.fromJson<String>(json['kind']),
      code: serializer.fromJson<String>(json['code']),
      stock: serializer.fromJson<int?>(json['stock']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'rate': serializer.toJson<double>(rate),
      'gst': serializer.toJson<int>(gst),
      'kind': serializer.toJson<String>(kind),
      'code': serializer.toJson<String>(code),
      'stock': serializer.toJson<int?>(stock),
      'position': serializer.toJson<int>(position),
    };
  }

  CustomItemRow copyWith({
    String? name,
    double? rate,
    int? gst,
    String? kind,
    String? code,
    Value<int?> stock = const Value.absent(),
    int? position,
  }) => CustomItemRow(
    name: name ?? this.name,
    rate: rate ?? this.rate,
    gst: gst ?? this.gst,
    kind: kind ?? this.kind,
    code: code ?? this.code,
    stock: stock.present ? stock.value : this.stock,
    position: position ?? this.position,
  );
  CustomItemRow copyWithCompanion(CustomItemsCompanion data) {
    return CustomItemRow(
      name: data.name.present ? data.name.value : this.name,
      rate: data.rate.present ? data.rate.value : this.rate,
      gst: data.gst.present ? data.gst.value : this.gst,
      kind: data.kind.present ? data.kind.value : this.kind,
      code: data.code.present ? data.code.value : this.code,
      stock: data.stock.present ? data.stock.value : this.stock,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomItemRow(')
          ..write('name: $name, ')
          ..write('rate: $rate, ')
          ..write('gst: $gst, ')
          ..write('kind: $kind, ')
          ..write('code: $code, ')
          ..write('stock: $stock, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, rate, gst, kind, code, stock, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomItemRow &&
          other.name == this.name &&
          other.rate == this.rate &&
          other.gst == this.gst &&
          other.kind == this.kind &&
          other.code == this.code &&
          other.stock == this.stock &&
          other.position == this.position);
}

class CustomItemsCompanion extends UpdateCompanion<CustomItemRow> {
  final Value<String> name;
  final Value<double> rate;
  final Value<int> gst;
  final Value<String> kind;
  final Value<String> code;
  final Value<int?> stock;
  final Value<int> position;
  const CustomItemsCompanion({
    this.name = const Value.absent(),
    this.rate = const Value.absent(),
    this.gst = const Value.absent(),
    this.kind = const Value.absent(),
    this.code = const Value.absent(),
    this.stock = const Value.absent(),
    this.position = const Value.absent(),
  });
  CustomItemsCompanion.insert({
    required String name,
    required double rate,
    required int gst,
    required String kind,
    this.code = const Value.absent(),
    this.stock = const Value.absent(),
    this.position = const Value.absent(),
  }) : name = Value(name),
       rate = Value(rate),
       gst = Value(gst),
       kind = Value(kind);
  static Insertable<CustomItemRow> custom({
    Expression<String>? name,
    Expression<double>? rate,
    Expression<int>? gst,
    Expression<String>? kind,
    Expression<String>? code,
    Expression<int>? stock,
    Expression<int>? position,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (rate != null) 'rate': rate,
      if (gst != null) 'gst': gst,
      if (kind != null) 'kind': kind,
      if (code != null) 'code': code,
      if (stock != null) 'stock': stock,
      if (position != null) 'position': position,
    });
  }

  CustomItemsCompanion copyWith({
    Value<String>? name,
    Value<double>? rate,
    Value<int>? gst,
    Value<String>? kind,
    Value<String>? code,
    Value<int?>? stock,
    Value<int>? position,
  }) {
    return CustomItemsCompanion(
      name: name ?? this.name,
      rate: rate ?? this.rate,
      gst: gst ?? this.gst,
      kind: kind ?? this.kind,
      code: code ?? this.code,
      stock: stock ?? this.stock,
      position: position ?? this.position,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rate.present) {
      map['rate'] = Variable<double>(rate.value);
    }
    if (gst.present) {
      map['gst'] = Variable<int>(gst.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (stock.present) {
      map['stock'] = Variable<int>(stock.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomItemsCompanion(')
          ..write('name: $name, ')
          ..write('rate: $rate, ')
          ..write('gst: $gst, ')
          ..write('kind: $kind, ')
          ..write('code: $code, ')
          ..write('stock: $stock, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }
}

class $ItemOverridesTable extends ItemOverrides
    with TableInfo<$ItemOverridesTable, ItemOverrideRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemOverridesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateMeta = const VerificationMeta('rate');
  @override
  late final GeneratedColumn<double> rate = GeneratedColumn<double>(
    'rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gstMeta = const VerificationMeta('gst');
  @override
  late final GeneratedColumn<int> gst = GeneratedColumn<int>(
    'gst',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _stockMeta = const VerificationMeta('stock');
  @override
  late final GeneratedColumn<int> stock = GeneratedColumn<int>(
    'stock',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seedNameMeta = const VerificationMeta(
    'seedName',
  );
  @override
  late final GeneratedColumn<String> seedName = GeneratedColumn<String>(
    'seed_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    name,
    rate,
    gst,
    kind,
    code,
    stock,
    seedName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_overrides';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItemOverrideRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('rate')) {
      context.handle(
        _rateMeta,
        rate.isAcceptableOrUnknown(data['rate']!, _rateMeta),
      );
    } else if (isInserting) {
      context.missing(_rateMeta);
    }
    if (data.containsKey('gst')) {
      context.handle(
        _gstMeta,
        gst.isAcceptableOrUnknown(data['gst']!, _gstMeta),
      );
    } else if (isInserting) {
      context.missing(_gstMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('stock')) {
      context.handle(
        _stockMeta,
        stock.isAcceptableOrUnknown(data['stock']!, _stockMeta),
      );
    }
    if (data.containsKey('seed_name')) {
      context.handle(
        _seedNameMeta,
        seedName.isAcceptableOrUnknown(data['seed_name']!, _seedNameMeta),
      );
    } else if (isInserting) {
      context.missing(_seedNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seedName};
  @override
  ItemOverrideRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemOverrideRow(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      rate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rate'],
      )!,
      gst: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gst'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      stock: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stock'],
      ),
      seedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}seed_name'],
      )!,
    );
  }

  @override
  $ItemOverridesTable createAlias(String alias) {
    return $ItemOverridesTable(attachedDatabase, alias);
  }
}

class ItemOverrideRow extends DataClass implements Insertable<ItemOverrideRow> {
  final String name;
  final double rate;
  final int gst;
  final String kind;
  final String code;
  final int? stock;
  final String seedName;
  const ItemOverrideRow({
    required this.name,
    required this.rate,
    required this.gst,
    required this.kind,
    required this.code,
    this.stock,
    required this.seedName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['rate'] = Variable<double>(rate);
    map['gst'] = Variable<int>(gst);
    map['kind'] = Variable<String>(kind);
    map['code'] = Variable<String>(code);
    if (!nullToAbsent || stock != null) {
      map['stock'] = Variable<int>(stock);
    }
    map['seed_name'] = Variable<String>(seedName);
    return map;
  }

  ItemOverridesCompanion toCompanion(bool nullToAbsent) {
    return ItemOverridesCompanion(
      name: Value(name),
      rate: Value(rate),
      gst: Value(gst),
      kind: Value(kind),
      code: Value(code),
      stock: stock == null && nullToAbsent
          ? const Value.absent()
          : Value(stock),
      seedName: Value(seedName),
    );
  }

  factory ItemOverrideRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemOverrideRow(
      name: serializer.fromJson<String>(json['name']),
      rate: serializer.fromJson<double>(json['rate']),
      gst: serializer.fromJson<int>(json['gst']),
      kind: serializer.fromJson<String>(json['kind']),
      code: serializer.fromJson<String>(json['code']),
      stock: serializer.fromJson<int?>(json['stock']),
      seedName: serializer.fromJson<String>(json['seedName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'rate': serializer.toJson<double>(rate),
      'gst': serializer.toJson<int>(gst),
      'kind': serializer.toJson<String>(kind),
      'code': serializer.toJson<String>(code),
      'stock': serializer.toJson<int?>(stock),
      'seedName': serializer.toJson<String>(seedName),
    };
  }

  ItemOverrideRow copyWith({
    String? name,
    double? rate,
    int? gst,
    String? kind,
    String? code,
    Value<int?> stock = const Value.absent(),
    String? seedName,
  }) => ItemOverrideRow(
    name: name ?? this.name,
    rate: rate ?? this.rate,
    gst: gst ?? this.gst,
    kind: kind ?? this.kind,
    code: code ?? this.code,
    stock: stock.present ? stock.value : this.stock,
    seedName: seedName ?? this.seedName,
  );
  ItemOverrideRow copyWithCompanion(ItemOverridesCompanion data) {
    return ItemOverrideRow(
      name: data.name.present ? data.name.value : this.name,
      rate: data.rate.present ? data.rate.value : this.rate,
      gst: data.gst.present ? data.gst.value : this.gst,
      kind: data.kind.present ? data.kind.value : this.kind,
      code: data.code.present ? data.code.value : this.code,
      stock: data.stock.present ? data.stock.value : this.stock,
      seedName: data.seedName.present ? data.seedName.value : this.seedName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemOverrideRow(')
          ..write('name: $name, ')
          ..write('rate: $rate, ')
          ..write('gst: $gst, ')
          ..write('kind: $kind, ')
          ..write('code: $code, ')
          ..write('stock: $stock, ')
          ..write('seedName: $seedName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, rate, gst, kind, code, stock, seedName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemOverrideRow &&
          other.name == this.name &&
          other.rate == this.rate &&
          other.gst == this.gst &&
          other.kind == this.kind &&
          other.code == this.code &&
          other.stock == this.stock &&
          other.seedName == this.seedName);
}

class ItemOverridesCompanion extends UpdateCompanion<ItemOverrideRow> {
  final Value<String> name;
  final Value<double> rate;
  final Value<int> gst;
  final Value<String> kind;
  final Value<String> code;
  final Value<int?> stock;
  final Value<String> seedName;
  final Value<int> rowid;
  const ItemOverridesCompanion({
    this.name = const Value.absent(),
    this.rate = const Value.absent(),
    this.gst = const Value.absent(),
    this.kind = const Value.absent(),
    this.code = const Value.absent(),
    this.stock = const Value.absent(),
    this.seedName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemOverridesCompanion.insert({
    required String name,
    required double rate,
    required int gst,
    required String kind,
    this.code = const Value.absent(),
    this.stock = const Value.absent(),
    required String seedName,
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       rate = Value(rate),
       gst = Value(gst),
       kind = Value(kind),
       seedName = Value(seedName);
  static Insertable<ItemOverrideRow> custom({
    Expression<String>? name,
    Expression<double>? rate,
    Expression<int>? gst,
    Expression<String>? kind,
    Expression<String>? code,
    Expression<int>? stock,
    Expression<String>? seedName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (rate != null) 'rate': rate,
      if (gst != null) 'gst': gst,
      if (kind != null) 'kind': kind,
      if (code != null) 'code': code,
      if (stock != null) 'stock': stock,
      if (seedName != null) 'seed_name': seedName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemOverridesCompanion copyWith({
    Value<String>? name,
    Value<double>? rate,
    Value<int>? gst,
    Value<String>? kind,
    Value<String>? code,
    Value<int?>? stock,
    Value<String>? seedName,
    Value<int>? rowid,
  }) {
    return ItemOverridesCompanion(
      name: name ?? this.name,
      rate: rate ?? this.rate,
      gst: gst ?? this.gst,
      kind: kind ?? this.kind,
      code: code ?? this.code,
      stock: stock ?? this.stock,
      seedName: seedName ?? this.seedName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rate.present) {
      map['rate'] = Variable<double>(rate.value);
    }
    if (gst.present) {
      map['gst'] = Variable<int>(gst.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (stock.present) {
      map['stock'] = Variable<int>(stock.value);
    }
    if (seedName.present) {
      map['seed_name'] = Variable<String>(seedName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemOverridesCompanion(')
          ..write('name: $name, ')
          ..write('rate: $rate, ')
          ..write('gst: $gst, ')
          ..write('kind: $kind, ')
          ..write('code: $code, ')
          ..write('stock: $stock, ')
          ..write('seedName: $seedName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HiddenItemsTable extends HiddenItems
    with TableInfo<$HiddenItemsTable, HiddenItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HiddenItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seedNameMeta = const VerificationMeta(
    'seedName',
  );
  @override
  late final GeneratedColumn<String> seedName = GeneratedColumn<String>(
    'seed_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [seedName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hidden_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<HiddenItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('seed_name')) {
      context.handle(
        _seedNameMeta,
        seedName.isAcceptableOrUnknown(data['seed_name']!, _seedNameMeta),
      );
    } else if (isInserting) {
      context.missing(_seedNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seedName};
  @override
  HiddenItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HiddenItemRow(
      seedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}seed_name'],
      )!,
    );
  }

  @override
  $HiddenItemsTable createAlias(String alias) {
    return $HiddenItemsTable(attachedDatabase, alias);
  }
}

class HiddenItemRow extends DataClass implements Insertable<HiddenItemRow> {
  final String seedName;
  const HiddenItemRow({required this.seedName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['seed_name'] = Variable<String>(seedName);
    return map;
  }

  HiddenItemsCompanion toCompanion(bool nullToAbsent) {
    return HiddenItemsCompanion(seedName: Value(seedName));
  }

  factory HiddenItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HiddenItemRow(
      seedName: serializer.fromJson<String>(json['seedName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'seedName': serializer.toJson<String>(seedName)};
  }

  HiddenItemRow copyWith({String? seedName}) =>
      HiddenItemRow(seedName: seedName ?? this.seedName);
  HiddenItemRow copyWithCompanion(HiddenItemsCompanion data) {
    return HiddenItemRow(
      seedName: data.seedName.present ? data.seedName.value : this.seedName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HiddenItemRow(')
          ..write('seedName: $seedName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => seedName.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HiddenItemRow && other.seedName == this.seedName);
}

class HiddenItemsCompanion extends UpdateCompanion<HiddenItemRow> {
  final Value<String> seedName;
  final Value<int> rowid;
  const HiddenItemsCompanion({
    this.seedName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HiddenItemsCompanion.insert({
    required String seedName,
    this.rowid = const Value.absent(),
  }) : seedName = Value(seedName);
  static Insertable<HiddenItemRow> custom({
    Expression<String>? seedName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (seedName != null) 'seed_name': seedName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HiddenItemsCompanion copyWith({Value<String>? seedName, Value<int>? rowid}) {
    return HiddenItemsCompanion(
      seedName: seedName ?? this.seedName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seedName.present) {
      map['seed_name'] = Variable<String>(seedName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HiddenItemsCompanion(')
          ..write('seedName: $seedName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MetaTable extends Meta with TableInfo<$MetaTable, MetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  MetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetaRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $MetaTable createAlias(String alias) {
    return $MetaTable(attachedDatabase, alias);
  }
}

class MetaRow extends DataClass implements Insertable<MetaRow> {
  final String key;
  final String value;
  const MetaRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  MetaCompanion toCompanion(bool nullToAbsent) {
    return MetaCompanion(key: Value(key), value: Value(value));
  }

  factory MetaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetaRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  MetaRow copyWith({String? key, String? value}) =>
      MetaRow(key: key ?? this.key, value: value ?? this.value);
  MetaRow copyWithCompanion(MetaCompanion data) {
    return MetaRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetaRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetaRow && other.key == this.key && other.value == this.value);
}

class MetaCompanion extends UpdateCompanion<MetaRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const MetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<MetaRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return MetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BillsTable bills = $BillsTable(this);
  late final $BillLinesTable billLines = $BillLinesTable(this);
  late final $CustomItemsTable customItems = $CustomItemsTable(this);
  late final $ItemOverridesTable itemOverrides = $ItemOverridesTable(this);
  late final $HiddenItemsTable hiddenItems = $HiddenItemsTable(this);
  late final $MetaTable meta = $MetaTable(this);
  late final Index billsInvoiceNo = Index(
    'bills_invoice_no',
    'CREATE INDEX bills_invoice_no ON bills (invoice_no)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    bills,
    billLines,
    customItems,
    itemOverrides,
    hiddenItems,
    meta,
    billsInvoiceNo,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'bills',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('bill_lines', kind: UpdateKind.delete)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$BillsTableCreateCompanionBuilder =
    BillsCompanion Function({
      required String id,
      required String invoiceNo,
      required DateTime date,
      required String status,
      Value<String?> payment,
      required bool ratesIncludeGst,
      Value<String> registration,
      Value<String> makeModel,
      Value<String> odometer,
      Value<String> customerName,
      Value<String> customerPhone,
      required int seq,
      Value<int> rowid,
    });
typedef $$BillsTableUpdateCompanionBuilder =
    BillsCompanion Function({
      Value<String> id,
      Value<String> invoiceNo,
      Value<DateTime> date,
      Value<String> status,
      Value<String?> payment,
      Value<bool> ratesIncludeGst,
      Value<String> registration,
      Value<String> makeModel,
      Value<String> odometer,
      Value<String> customerName,
      Value<String> customerPhone,
      Value<int> seq,
      Value<int> rowid,
    });

final class $$BillsTableReferences
    extends BaseReferences<_$AppDatabase, $BillsTable, BillRow> {
  $$BillsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BillLinesTable, List<BillLineRow>>
  _billLinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.billLines,
    aliasName: $_aliasNameGenerator(db.bills.id, db.billLines.billId),
  );

  $$BillLinesTableProcessedTableManager get billLinesRefs {
    final manager = $$BillLinesTableTableManager(
      $_db,
      $_db.billLines,
    ).filter((f) => f.billId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_billLinesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BillsTableFilterComposer extends Composer<_$AppDatabase, $BillsTable> {
  $$BillsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceNo => $composableBuilder(
    column: $table.invoiceNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payment => $composableBuilder(
    column: $table.payment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get ratesIncludeGst => $composableBuilder(
    column: $table.ratesIncludeGst,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get registration => $composableBuilder(
    column: $table.registration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get makeModel => $composableBuilder(
    column: $table.makeModel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get odometer => $composableBuilder(
    column: $table.odometer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerPhone => $composableBuilder(
    column: $table.customerPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> billLinesRefs(
    Expression<bool> Function($$BillLinesTableFilterComposer f) f,
  ) {
    final $$BillLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.billLines,
      getReferencedColumn: (t) => t.billId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillLinesTableFilterComposer(
            $db: $db,
            $table: $db.billLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BillsTableOrderingComposer
    extends Composer<_$AppDatabase, $BillsTable> {
  $$BillsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceNo => $composableBuilder(
    column: $table.invoiceNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payment => $composableBuilder(
    column: $table.payment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get ratesIncludeGst => $composableBuilder(
    column: $table.ratesIncludeGst,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get registration => $composableBuilder(
    column: $table.registration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get makeModel => $composableBuilder(
    column: $table.makeModel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get odometer => $composableBuilder(
    column: $table.odometer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerPhone => $composableBuilder(
    column: $table.customerPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BillsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BillsTable> {
  $$BillsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get invoiceNo =>
      $composableBuilder(column: $table.invoiceNo, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get payment =>
      $composableBuilder(column: $table.payment, builder: (column) => column);

  GeneratedColumn<bool> get ratesIncludeGst => $composableBuilder(
    column: $table.ratesIncludeGst,
    builder: (column) => column,
  );

  GeneratedColumn<String> get registration => $composableBuilder(
    column: $table.registration,
    builder: (column) => column,
  );

  GeneratedColumn<String> get makeModel =>
      $composableBuilder(column: $table.makeModel, builder: (column) => column);

  GeneratedColumn<String> get odometer =>
      $composableBuilder(column: $table.odometer, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerPhone => $composableBuilder(
    column: $table.customerPhone,
    builder: (column) => column,
  );

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  Expression<T> billLinesRefs<T extends Object>(
    Expression<T> Function($$BillLinesTableAnnotationComposer a) f,
  ) {
    final $$BillLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.billLines,
      getReferencedColumn: (t) => t.billId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.billLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BillsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BillsTable,
          BillRow,
          $$BillsTableFilterComposer,
          $$BillsTableOrderingComposer,
          $$BillsTableAnnotationComposer,
          $$BillsTableCreateCompanionBuilder,
          $$BillsTableUpdateCompanionBuilder,
          (BillRow, $$BillsTableReferences),
          BillRow,
          PrefetchHooks Function({bool billLinesRefs})
        > {
  $$BillsTableTableManager(_$AppDatabase db, $BillsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BillsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BillsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BillsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> invoiceNo = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> payment = const Value.absent(),
                Value<bool> ratesIncludeGst = const Value.absent(),
                Value<String> registration = const Value.absent(),
                Value<String> makeModel = const Value.absent(),
                Value<String> odometer = const Value.absent(),
                Value<String> customerName = const Value.absent(),
                Value<String> customerPhone = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BillsCompanion(
                id: id,
                invoiceNo: invoiceNo,
                date: date,
                status: status,
                payment: payment,
                ratesIncludeGst: ratesIncludeGst,
                registration: registration,
                makeModel: makeModel,
                odometer: odometer,
                customerName: customerName,
                customerPhone: customerPhone,
                seq: seq,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String invoiceNo,
                required DateTime date,
                required String status,
                Value<String?> payment = const Value.absent(),
                required bool ratesIncludeGst,
                Value<String> registration = const Value.absent(),
                Value<String> makeModel = const Value.absent(),
                Value<String> odometer = const Value.absent(),
                Value<String> customerName = const Value.absent(),
                Value<String> customerPhone = const Value.absent(),
                required int seq,
                Value<int> rowid = const Value.absent(),
              }) => BillsCompanion.insert(
                id: id,
                invoiceNo: invoiceNo,
                date: date,
                status: status,
                payment: payment,
                ratesIncludeGst: ratesIncludeGst,
                registration: registration,
                makeModel: makeModel,
                odometer: odometer,
                customerName: customerName,
                customerPhone: customerPhone,
                seq: seq,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$BillsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({billLinesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (billLinesRefs) db.billLines],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (billLinesRefs)
                    await $_getPrefetchedData<
                      BillRow,
                      $BillsTable,
                      BillLineRow
                    >(
                      currentTable: table,
                      referencedTable: $$BillsTableReferences
                          ._billLinesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$BillsTableReferences(db, table, p0).billLinesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.billId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$BillsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BillsTable,
      BillRow,
      $$BillsTableFilterComposer,
      $$BillsTableOrderingComposer,
      $$BillsTableAnnotationComposer,
      $$BillsTableCreateCompanionBuilder,
      $$BillsTableUpdateCompanionBuilder,
      (BillRow, $$BillsTableReferences),
      BillRow,
      PrefetchHooks Function({bool billLinesRefs})
    >;
typedef $$BillLinesTableCreateCompanionBuilder =
    BillLinesCompanion Function({
      required String billId,
      required int position,
      required String name,
      required double rate,
      required int gst,
      required String kind,
      Value<String> code,
      required int qty,
      Value<int> rowid,
    });
typedef $$BillLinesTableUpdateCompanionBuilder =
    BillLinesCompanion Function({
      Value<String> billId,
      Value<int> position,
      Value<String> name,
      Value<double> rate,
      Value<int> gst,
      Value<String> kind,
      Value<String> code,
      Value<int> qty,
      Value<int> rowid,
    });

final class $$BillLinesTableReferences
    extends BaseReferences<_$AppDatabase, $BillLinesTable, BillLineRow> {
  $$BillLinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BillsTable _billIdTable(_$AppDatabase db) => db.bills.createAlias(
    $_aliasNameGenerator(db.billLines.billId, db.bills.id),
  );

  $$BillsTableProcessedTableManager get billId {
    final $_column = $_itemColumn<String>('bill_id')!;

    final manager = $$BillsTableTableManager(
      $_db,
      $_db.bills,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_billIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BillLinesTableFilterComposer
    extends Composer<_$AppDatabase, $BillLinesTable> {
  $$BillLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gst => $composableBuilder(
    column: $table.gst,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnFilters(column),
  );

  $$BillsTableFilterComposer get billId {
    final $$BillsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.billId,
      referencedTable: $db.bills,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillsTableFilterComposer(
            $db: $db,
            $table: $db.bills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BillLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $BillLinesTable> {
  $$BillLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gst => $composableBuilder(
    column: $table.gst,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnOrderings(column),
  );

  $$BillsTableOrderingComposer get billId {
    final $$BillsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.billId,
      referencedTable: $db.bills,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillsTableOrderingComposer(
            $db: $db,
            $table: $db.bills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BillLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BillLinesTable> {
  $$BillLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get rate =>
      $composableBuilder(column: $table.rate, builder: (column) => column);

  GeneratedColumn<int> get gst =>
      $composableBuilder(column: $table.gst, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<int> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);

  $$BillsTableAnnotationComposer get billId {
    final $$BillsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.billId,
      referencedTable: $db.bills,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillsTableAnnotationComposer(
            $db: $db,
            $table: $db.bills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BillLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BillLinesTable,
          BillLineRow,
          $$BillLinesTableFilterComposer,
          $$BillLinesTableOrderingComposer,
          $$BillLinesTableAnnotationComposer,
          $$BillLinesTableCreateCompanionBuilder,
          $$BillLinesTableUpdateCompanionBuilder,
          (BillLineRow, $$BillLinesTableReferences),
          BillLineRow,
          PrefetchHooks Function({bool billId})
        > {
  $$BillLinesTableTableManager(_$AppDatabase db, $BillLinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BillLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BillLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BillLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> billId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> rate = const Value.absent(),
                Value<int> gst = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<int> qty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BillLinesCompanion(
                billId: billId,
                position: position,
                name: name,
                rate: rate,
                gst: gst,
                kind: kind,
                code: code,
                qty: qty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String billId,
                required int position,
                required String name,
                required double rate,
                required int gst,
                required String kind,
                Value<String> code = const Value.absent(),
                required int qty,
                Value<int> rowid = const Value.absent(),
              }) => BillLinesCompanion.insert(
                billId: billId,
                position: position,
                name: name,
                rate: rate,
                gst: gst,
                kind: kind,
                code: code,
                qty: qty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BillLinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({billId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (billId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.billId,
                                referencedTable: $$BillLinesTableReferences
                                    ._billIdTable(db),
                                referencedColumn: $$BillLinesTableReferences
                                    ._billIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BillLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BillLinesTable,
      BillLineRow,
      $$BillLinesTableFilterComposer,
      $$BillLinesTableOrderingComposer,
      $$BillLinesTableAnnotationComposer,
      $$BillLinesTableCreateCompanionBuilder,
      $$BillLinesTableUpdateCompanionBuilder,
      (BillLineRow, $$BillLinesTableReferences),
      BillLineRow,
      PrefetchHooks Function({bool billId})
    >;
typedef $$CustomItemsTableCreateCompanionBuilder =
    CustomItemsCompanion Function({
      required String name,
      required double rate,
      required int gst,
      required String kind,
      Value<String> code,
      Value<int?> stock,
      Value<int> position,
    });
typedef $$CustomItemsTableUpdateCompanionBuilder =
    CustomItemsCompanion Function({
      Value<String> name,
      Value<double> rate,
      Value<int> gst,
      Value<String> kind,
      Value<String> code,
      Value<int?> stock,
      Value<int> position,
    });

class $$CustomItemsTableFilterComposer
    extends Composer<_$AppDatabase, $CustomItemsTable> {
  $$CustomItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gst => $composableBuilder(
    column: $table.gst,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomItemsTable> {
  $$CustomItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gst => $composableBuilder(
    column: $table.gst,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomItemsTable> {
  $$CustomItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get rate =>
      $composableBuilder(column: $table.rate, builder: (column) => column);

  GeneratedColumn<int> get gst =>
      $composableBuilder(column: $table.gst, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<int> get stock =>
      $composableBuilder(column: $table.stock, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$CustomItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomItemsTable,
          CustomItemRow,
          $$CustomItemsTableFilterComposer,
          $$CustomItemsTableOrderingComposer,
          $$CustomItemsTableAnnotationComposer,
          $$CustomItemsTableCreateCompanionBuilder,
          $$CustomItemsTableUpdateCompanionBuilder,
          (
            CustomItemRow,
            BaseReferences<_$AppDatabase, $CustomItemsTable, CustomItemRow>,
          ),
          CustomItemRow,
          PrefetchHooks Function()
        > {
  $$CustomItemsTableTableManager(_$AppDatabase db, $CustomItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> name = const Value.absent(),
                Value<double> rate = const Value.absent(),
                Value<int> gst = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<int?> stock = const Value.absent(),
                Value<int> position = const Value.absent(),
              }) => CustomItemsCompanion(
                name: name,
                rate: rate,
                gst: gst,
                kind: kind,
                code: code,
                stock: stock,
                position: position,
              ),
          createCompanionCallback:
              ({
                required String name,
                required double rate,
                required int gst,
                required String kind,
                Value<String> code = const Value.absent(),
                Value<int?> stock = const Value.absent(),
                Value<int> position = const Value.absent(),
              }) => CustomItemsCompanion.insert(
                name: name,
                rate: rate,
                gst: gst,
                kind: kind,
                code: code,
                stock: stock,
                position: position,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomItemsTable,
      CustomItemRow,
      $$CustomItemsTableFilterComposer,
      $$CustomItemsTableOrderingComposer,
      $$CustomItemsTableAnnotationComposer,
      $$CustomItemsTableCreateCompanionBuilder,
      $$CustomItemsTableUpdateCompanionBuilder,
      (
        CustomItemRow,
        BaseReferences<_$AppDatabase, $CustomItemsTable, CustomItemRow>,
      ),
      CustomItemRow,
      PrefetchHooks Function()
    >;
typedef $$ItemOverridesTableCreateCompanionBuilder =
    ItemOverridesCompanion Function({
      required String name,
      required double rate,
      required int gst,
      required String kind,
      Value<String> code,
      Value<int?> stock,
      required String seedName,
      Value<int> rowid,
    });
typedef $$ItemOverridesTableUpdateCompanionBuilder =
    ItemOverridesCompanion Function({
      Value<String> name,
      Value<double> rate,
      Value<int> gst,
      Value<String> kind,
      Value<String> code,
      Value<int?> stock,
      Value<String> seedName,
      Value<int> rowid,
    });

class $$ItemOverridesTableFilterComposer
    extends Composer<_$AppDatabase, $ItemOverridesTable> {
  $$ItemOverridesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gst => $composableBuilder(
    column: $table.gst,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seedName => $composableBuilder(
    column: $table.seedName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ItemOverridesTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemOverridesTable> {
  $$ItemOverridesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gst => $composableBuilder(
    column: $table.gst,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seedName => $composableBuilder(
    column: $table.seedName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ItemOverridesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemOverridesTable> {
  $$ItemOverridesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get rate =>
      $composableBuilder(column: $table.rate, builder: (column) => column);

  GeneratedColumn<int> get gst =>
      $composableBuilder(column: $table.gst, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<int> get stock =>
      $composableBuilder(column: $table.stock, builder: (column) => column);

  GeneratedColumn<String> get seedName =>
      $composableBuilder(column: $table.seedName, builder: (column) => column);
}

class $$ItemOverridesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemOverridesTable,
          ItemOverrideRow,
          $$ItemOverridesTableFilterComposer,
          $$ItemOverridesTableOrderingComposer,
          $$ItemOverridesTableAnnotationComposer,
          $$ItemOverridesTableCreateCompanionBuilder,
          $$ItemOverridesTableUpdateCompanionBuilder,
          (
            ItemOverrideRow,
            BaseReferences<_$AppDatabase, $ItemOverridesTable, ItemOverrideRow>,
          ),
          ItemOverrideRow,
          PrefetchHooks Function()
        > {
  $$ItemOverridesTableTableManager(_$AppDatabase db, $ItemOverridesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemOverridesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemOverridesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemOverridesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> name = const Value.absent(),
                Value<double> rate = const Value.absent(),
                Value<int> gst = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<int?> stock = const Value.absent(),
                Value<String> seedName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemOverridesCompanion(
                name: name,
                rate: rate,
                gst: gst,
                kind: kind,
                code: code,
                stock: stock,
                seedName: seedName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String name,
                required double rate,
                required int gst,
                required String kind,
                Value<String> code = const Value.absent(),
                Value<int?> stock = const Value.absent(),
                required String seedName,
                Value<int> rowid = const Value.absent(),
              }) => ItemOverridesCompanion.insert(
                name: name,
                rate: rate,
                gst: gst,
                kind: kind,
                code: code,
                stock: stock,
                seedName: seedName,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ItemOverridesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemOverridesTable,
      ItemOverrideRow,
      $$ItemOverridesTableFilterComposer,
      $$ItemOverridesTableOrderingComposer,
      $$ItemOverridesTableAnnotationComposer,
      $$ItemOverridesTableCreateCompanionBuilder,
      $$ItemOverridesTableUpdateCompanionBuilder,
      (
        ItemOverrideRow,
        BaseReferences<_$AppDatabase, $ItemOverridesTable, ItemOverrideRow>,
      ),
      ItemOverrideRow,
      PrefetchHooks Function()
    >;
typedef $$HiddenItemsTableCreateCompanionBuilder =
    HiddenItemsCompanion Function({required String seedName, Value<int> rowid});
typedef $$HiddenItemsTableUpdateCompanionBuilder =
    HiddenItemsCompanion Function({Value<String> seedName, Value<int> rowid});

class $$HiddenItemsTableFilterComposer
    extends Composer<_$AppDatabase, $HiddenItemsTable> {
  $$HiddenItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get seedName => $composableBuilder(
    column: $table.seedName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HiddenItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $HiddenItemsTable> {
  $$HiddenItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get seedName => $composableBuilder(
    column: $table.seedName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HiddenItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HiddenItemsTable> {
  $$HiddenItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get seedName =>
      $composableBuilder(column: $table.seedName, builder: (column) => column);
}

class $$HiddenItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HiddenItemsTable,
          HiddenItemRow,
          $$HiddenItemsTableFilterComposer,
          $$HiddenItemsTableOrderingComposer,
          $$HiddenItemsTableAnnotationComposer,
          $$HiddenItemsTableCreateCompanionBuilder,
          $$HiddenItemsTableUpdateCompanionBuilder,
          (
            HiddenItemRow,
            BaseReferences<_$AppDatabase, $HiddenItemsTable, HiddenItemRow>,
          ),
          HiddenItemRow,
          PrefetchHooks Function()
        > {
  $$HiddenItemsTableTableManager(_$AppDatabase db, $HiddenItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HiddenItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HiddenItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HiddenItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> seedName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HiddenItemsCompanion(seedName: seedName, rowid: rowid),
          createCompanionCallback:
              ({
                required String seedName,
                Value<int> rowid = const Value.absent(),
              }) =>
                  HiddenItemsCompanion.insert(seedName: seedName, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HiddenItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HiddenItemsTable,
      HiddenItemRow,
      $$HiddenItemsTableFilterComposer,
      $$HiddenItemsTableOrderingComposer,
      $$HiddenItemsTableAnnotationComposer,
      $$HiddenItemsTableCreateCompanionBuilder,
      $$HiddenItemsTableUpdateCompanionBuilder,
      (
        HiddenItemRow,
        BaseReferences<_$AppDatabase, $HiddenItemsTable, HiddenItemRow>,
      ),
      HiddenItemRow,
      PrefetchHooks Function()
    >;
typedef $$MetaTableCreateCompanionBuilder =
    MetaCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$MetaTableUpdateCompanionBuilder =
    MetaCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$MetaTableFilterComposer extends Composer<_$AppDatabase, $MetaTable> {
  $$MetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MetaTableOrderingComposer extends Composer<_$AppDatabase, $MetaTable> {
  $$MetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $MetaTable> {
  $$MetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$MetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MetaTable,
          MetaRow,
          $$MetaTableFilterComposer,
          $$MetaTableOrderingComposer,
          $$MetaTableAnnotationComposer,
          $$MetaTableCreateCompanionBuilder,
          $$MetaTableUpdateCompanionBuilder,
          (MetaRow, BaseReferences<_$AppDatabase, $MetaTable, MetaRow>),
          MetaRow,
          PrefetchHooks Function()
        > {
  $$MetaTableTableManager(_$AppDatabase db, $MetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => MetaCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MetaTable,
      MetaRow,
      $$MetaTableFilterComposer,
      $$MetaTableOrderingComposer,
      $$MetaTableAnnotationComposer,
      $$MetaTableCreateCompanionBuilder,
      $$MetaTableUpdateCompanionBuilder,
      (MetaRow, BaseReferences<_$AppDatabase, $MetaTable, MetaRow>),
      MetaRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BillsTableTableManager get bills =>
      $$BillsTableTableManager(_db, _db.bills);
  $$BillLinesTableTableManager get billLines =>
      $$BillLinesTableTableManager(_db, _db.billLines);
  $$CustomItemsTableTableManager get customItems =>
      $$CustomItemsTableTableManager(_db, _db.customItems);
  $$ItemOverridesTableTableManager get itemOverrides =>
      $$ItemOverridesTableTableManager(_db, _db.itemOverrides);
  $$HiddenItemsTableTableManager get hiddenItems =>
      $$HiddenItemsTableTableManager(_db, _db.hiddenItems);
  $$MetaTableTableManager get meta => $$MetaTableTableManager(_db, _db.meta);
}
