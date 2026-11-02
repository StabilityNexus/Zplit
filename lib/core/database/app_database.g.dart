// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTableTable extends UsersTable
    with TableInfo<$UsersTableTable, UsersTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _publicKeyMeta = const VerificationMeta(
    'publicKey',
  );
  @override
  late final GeneratedColumn<String> publicKey = GeneratedColumn<String>(
    'public_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cryptoAddressMeta = const VerificationMeta(
    'cryptoAddress',
  );
  @override
  late final GeneratedColumn<String> cryptoAddress = GeneratedColumn<String>(
    'crypto_address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _profilePictureMeta = const VerificationMeta(
    'profilePicture',
  );
  @override
  late final GeneratedColumn<String> profilePicture = GeneratedColumn<String>(
    'profile_picture',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultCurrencyMeta = const VerificationMeta(
    'defaultCurrency',
  );
  @override
  late final GeneratedColumn<String> defaultCurrency = GeneratedColumn<String>(
    'default_currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    publicKey,
    displayName,
    cryptoAddress,
    profilePicture,
    defaultCurrency,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<UsersTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('public_key')) {
      context.handle(
        _publicKeyMeta,
        publicKey.isAcceptableOrUnknown(data['public_key']!, _publicKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_publicKeyMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('crypto_address')) {
      context.handle(
        _cryptoAddressMeta,
        cryptoAddress.isAcceptableOrUnknown(
          data['crypto_address']!,
          _cryptoAddressMeta,
        ),
      );
    }
    if (data.containsKey('profile_picture')) {
      context.handle(
        _profilePictureMeta,
        profilePicture.isAcceptableOrUnknown(
          data['profile_picture']!,
          _profilePictureMeta,
        ),
      );
    }
    if (data.containsKey('default_currency')) {
      context.handle(
        _defaultCurrencyMeta,
        defaultCurrency.isAcceptableOrUnknown(
          data['default_currency']!,
          _defaultCurrencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultCurrencyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {publicKey};
  @override
  UsersTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UsersTableData(
      publicKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_key'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      cryptoAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}crypto_address'],
      ),
      profilePicture: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_picture'],
      ),
      defaultCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_currency'],
      )!,
    );
  }

  @override
  $UsersTableTable createAlias(String alias) {
    return $UsersTableTable(attachedDatabase, alias);
  }
}

class UsersTableData extends DataClass implements Insertable<UsersTableData> {
  final String publicKey;
  final String displayName;
  final String? cryptoAddress;
  final String? profilePicture;
  final String defaultCurrency;
  const UsersTableData({
    required this.publicKey,
    required this.displayName,
    this.cryptoAddress,
    this.profilePicture,
    required this.defaultCurrency,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['public_key'] = Variable<String>(publicKey);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || cryptoAddress != null) {
      map['crypto_address'] = Variable<String>(cryptoAddress);
    }
    if (!nullToAbsent || profilePicture != null) {
      map['profile_picture'] = Variable<String>(profilePicture);
    }
    map['default_currency'] = Variable<String>(defaultCurrency);
    return map;
  }

  UsersTableCompanion toCompanion(bool nullToAbsent) {
    return UsersTableCompanion(
      publicKey: Value(publicKey),
      displayName: Value(displayName),
      cryptoAddress: cryptoAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(cryptoAddress),
      profilePicture: profilePicture == null && nullToAbsent
          ? const Value.absent()
          : Value(profilePicture),
      defaultCurrency: Value(defaultCurrency),
    );
  }

  factory UsersTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UsersTableData(
      publicKey: serializer.fromJson<String>(json['publicKey']),
      displayName: serializer.fromJson<String>(json['displayName']),
      cryptoAddress: serializer.fromJson<String?>(json['cryptoAddress']),
      profilePicture: serializer.fromJson<String?>(json['profilePicture']),
      defaultCurrency: serializer.fromJson<String>(json['defaultCurrency']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'publicKey': serializer.toJson<String>(publicKey),
      'displayName': serializer.toJson<String>(displayName),
      'cryptoAddress': serializer.toJson<String?>(cryptoAddress),
      'profilePicture': serializer.toJson<String?>(profilePicture),
      'defaultCurrency': serializer.toJson<String>(defaultCurrency),
    };
  }

  UsersTableData copyWith({
    String? publicKey,
    String? displayName,
    Value<String?> cryptoAddress = const Value.absent(),
    Value<String?> profilePicture = const Value.absent(),
    String? defaultCurrency,
  }) => UsersTableData(
    publicKey: publicKey ?? this.publicKey,
    displayName: displayName ?? this.displayName,
    cryptoAddress: cryptoAddress.present
        ? cryptoAddress.value
        : this.cryptoAddress,
    profilePicture: profilePicture.present
        ? profilePicture.value
        : this.profilePicture,
    defaultCurrency: defaultCurrency ?? this.defaultCurrency,
  );
  UsersTableData copyWithCompanion(UsersTableCompanion data) {
    return UsersTableData(
      publicKey: data.publicKey.present ? data.publicKey.value : this.publicKey,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      cryptoAddress: data.cryptoAddress.present
          ? data.cryptoAddress.value
          : this.cryptoAddress,
      profilePicture: data.profilePicture.present
          ? data.profilePicture.value
          : this.profilePicture,
      defaultCurrency: data.defaultCurrency.present
          ? data.defaultCurrency.value
          : this.defaultCurrency,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UsersTableData(')
          ..write('publicKey: $publicKey, ')
          ..write('displayName: $displayName, ')
          ..write('cryptoAddress: $cryptoAddress, ')
          ..write('profilePicture: $profilePicture, ')
          ..write('defaultCurrency: $defaultCurrency')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    publicKey,
    displayName,
    cryptoAddress,
    profilePicture,
    defaultCurrency,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsersTableData &&
          other.publicKey == this.publicKey &&
          other.displayName == this.displayName &&
          other.cryptoAddress == this.cryptoAddress &&
          other.profilePicture == this.profilePicture &&
          other.defaultCurrency == this.defaultCurrency);
}

class UsersTableCompanion extends UpdateCompanion<UsersTableData> {
  final Value<String> publicKey;
  final Value<String> displayName;
  final Value<String?> cryptoAddress;
  final Value<String?> profilePicture;
  final Value<String> defaultCurrency;
  final Value<int> rowid;
  const UsersTableCompanion({
    this.publicKey = const Value.absent(),
    this.displayName = const Value.absent(),
    this.cryptoAddress = const Value.absent(),
    this.profilePicture = const Value.absent(),
    this.defaultCurrency = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersTableCompanion.insert({
    required String publicKey,
    required String displayName,
    this.cryptoAddress = const Value.absent(),
    this.profilePicture = const Value.absent(),
    required String defaultCurrency,
    this.rowid = const Value.absent(),
  }) : publicKey = Value(publicKey),
       displayName = Value(displayName),
       defaultCurrency = Value(defaultCurrency);
  static Insertable<UsersTableData> custom({
    Expression<String>? publicKey,
    Expression<String>? displayName,
    Expression<String>? cryptoAddress,
    Expression<String>? profilePicture,
    Expression<String>? defaultCurrency,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (publicKey != null) 'public_key': publicKey,
      if (displayName != null) 'display_name': displayName,
      if (cryptoAddress != null) 'crypto_address': cryptoAddress,
      if (profilePicture != null) 'profile_picture': profilePicture,
      if (defaultCurrency != null) 'default_currency': defaultCurrency,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersTableCompanion copyWith({
    Value<String>? publicKey,
    Value<String>? displayName,
    Value<String?>? cryptoAddress,
    Value<String?>? profilePicture,
    Value<String>? defaultCurrency,
    Value<int>? rowid,
  }) {
    return UsersTableCompanion(
      publicKey: publicKey ?? this.publicKey,
      displayName: displayName ?? this.displayName,
      cryptoAddress: cryptoAddress ?? this.cryptoAddress,
      profilePicture: profilePicture ?? this.profilePicture,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (publicKey.present) {
      map['public_key'] = Variable<String>(publicKey.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (cryptoAddress.present) {
      map['crypto_address'] = Variable<String>(cryptoAddress.value);
    }
    if (profilePicture.present) {
      map['profile_picture'] = Variable<String>(profilePicture.value);
    }
    if (defaultCurrency.present) {
      map['default_currency'] = Variable<String>(defaultCurrency.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersTableCompanion(')
          ..write('publicKey: $publicKey, ')
          ..write('displayName: $displayName, ')
          ..write('cryptoAddress: $cryptoAddress, ')
          ..write('profilePicture: $profilePicture, ')
          ..write('defaultCurrency: $defaultCurrency, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTableTable extends TransactionsTable
    with TableInfo<$TransactionsTableTable, TransactionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromUserPublicKeyMeta = const VerificationMeta(
    'fromUserPublicKey',
  );
  @override
  late final GeneratedColumn<String> fromUserPublicKey =
      GeneratedColumn<String>(
        'from_user_public_key',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES users (public_key)',
        ),
      );
  static const VerificationMeta _toUserPublicKeyMeta = const VerificationMeta(
    'toUserPublicKey',
  );
  @override
  late final GeneratedColumn<String> toUserPublicKey = GeneratedColumn<String>(
    'to_user_public_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (public_key)',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<BigInt> amount = GeneratedColumn<BigInt>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
    'tag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TransactionStatus, String>
  status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<TransactionStatus>($TransactionsTableTable.$converterstatus);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _senderSignatureMeta = const VerificationMeta(
    'senderSignature',
  );
  @override
  late final GeneratedColumn<String> senderSignature = GeneratedColumn<String>(
    'sender_signature',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receiverSignatureMeta = const VerificationMeta(
    'receiverSignature',
  );
  @override
  late final GeneratedColumn<String> receiverSignature =
      GeneratedColumn<String>(
        'receiver_signature',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fromUserPublicKey,
    toUserPublicKey,
    amount,
    description,
    tag,
    status,
    createdAt,
    senderSignature,
    receiverSignature,
    currency,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('from_user_public_key')) {
      context.handle(
        _fromUserPublicKeyMeta,
        fromUserPublicKey.isAcceptableOrUnknown(
          data['from_user_public_key']!,
          _fromUserPublicKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fromUserPublicKeyMeta);
    }
    if (data.containsKey('to_user_public_key')) {
      context.handle(
        _toUserPublicKeyMeta,
        toUserPublicKey.isAcceptableOrUnknown(
          data['to_user_public_key']!,
          _toUserPublicKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_toUserPublicKeyMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('tag')) {
      context.handle(
        _tagMeta,
        tag.isAcceptableOrUnknown(data['tag']!, _tagMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('sender_signature')) {
      context.handle(
        _senderSignatureMeta,
        senderSignature.isAcceptableOrUnknown(
          data['sender_signature']!,
          _senderSignatureMeta,
        ),
      );
    }
    if (data.containsKey('receiver_signature')) {
      context.handle(
        _receiverSignatureMeta,
        receiverSignature.isAcceptableOrUnknown(
          data['receiver_signature']!,
          _receiverSignatureMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fromUserPublicKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_user_public_key'],
      )!,
      toUserPublicKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_user_public_key'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}amount'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      tag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag'],
      ),
      status: $TransactionsTableTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      senderSignature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_signature'],
      ),
      receiverSignature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receiver_signature'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
    );
  }

  @override
  $TransactionsTableTable createAlias(String alias) {
    return $TransactionsTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TransactionStatus, String, String>
  $converterstatus = const EnumNameConverter<TransactionStatus>(
    TransactionStatus.values,
  );
}

class TransactionsTableData extends DataClass
    implements Insertable<TransactionsTableData> {
  final String id;
  final String fromUserPublicKey;
  final String toUserPublicKey;
  final BigInt amount;
  final String? description;
  final String? tag;
  final TransactionStatus status;
  final DateTime createdAt;
  final String? senderSignature;
  final String? receiverSignature;
  final String currency;
  const TransactionsTableData({
    required this.id,
    required this.fromUserPublicKey,
    required this.toUserPublicKey,
    required this.amount,
    this.description,
    this.tag,
    required this.status,
    required this.createdAt,
    this.senderSignature,
    this.receiverSignature,
    required this.currency,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['from_user_public_key'] = Variable<String>(fromUserPublicKey);
    map['to_user_public_key'] = Variable<String>(toUserPublicKey);
    map['amount'] = Variable<BigInt>(amount);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || tag != null) {
      map['tag'] = Variable<String>(tag);
    }
    {
      map['status'] = Variable<String>(
        $TransactionsTableTable.$converterstatus.toSql(status),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || senderSignature != null) {
      map['sender_signature'] = Variable<String>(senderSignature);
    }
    if (!nullToAbsent || receiverSignature != null) {
      map['receiver_signature'] = Variable<String>(receiverSignature);
    }
    map['currency'] = Variable<String>(currency);
    return map;
  }

  TransactionsTableCompanion toCompanion(bool nullToAbsent) {
    return TransactionsTableCompanion(
      id: Value(id),
      fromUserPublicKey: Value(fromUserPublicKey),
      toUserPublicKey: Value(toUserPublicKey),
      amount: Value(amount),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      tag: tag == null && nullToAbsent ? const Value.absent() : Value(tag),
      status: Value(status),
      createdAt: Value(createdAt),
      senderSignature: senderSignature == null && nullToAbsent
          ? const Value.absent()
          : Value(senderSignature),
      receiverSignature: receiverSignature == null && nullToAbsent
          ? const Value.absent()
          : Value(receiverSignature),
      currency: Value(currency),
    );
  }

  factory TransactionsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionsTableData(
      id: serializer.fromJson<String>(json['id']),
      fromUserPublicKey: serializer.fromJson<String>(json['fromUserPublicKey']),
      toUserPublicKey: serializer.fromJson<String>(json['toUserPublicKey']),
      amount: serializer.fromJson<BigInt>(json['amount']),
      description: serializer.fromJson<String?>(json['description']),
      tag: serializer.fromJson<String?>(json['tag']),
      status: $TransactionsTableTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      senderSignature: serializer.fromJson<String?>(json['senderSignature']),
      receiverSignature: serializer.fromJson<String?>(
        json['receiverSignature'],
      ),
      currency: serializer.fromJson<String>(json['currency']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fromUserPublicKey': serializer.toJson<String>(fromUserPublicKey),
      'toUserPublicKey': serializer.toJson<String>(toUserPublicKey),
      'amount': serializer.toJson<BigInt>(amount),
      'description': serializer.toJson<String?>(description),
      'tag': serializer.toJson<String?>(tag),
      'status': serializer.toJson<String>(
        $TransactionsTableTable.$converterstatus.toJson(status),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'senderSignature': serializer.toJson<String?>(senderSignature),
      'receiverSignature': serializer.toJson<String?>(receiverSignature),
      'currency': serializer.toJson<String>(currency),
    };
  }

  TransactionsTableData copyWith({
    String? id,
    String? fromUserPublicKey,
    String? toUserPublicKey,
    BigInt? amount,
    Value<String?> description = const Value.absent(),
    Value<String?> tag = const Value.absent(),
    TransactionStatus? status,
    DateTime? createdAt,
    Value<String?> senderSignature = const Value.absent(),
    Value<String?> receiverSignature = const Value.absent(),
    String? currency,
  }) => TransactionsTableData(
    id: id ?? this.id,
    fromUserPublicKey: fromUserPublicKey ?? this.fromUserPublicKey,
    toUserPublicKey: toUserPublicKey ?? this.toUserPublicKey,
    amount: amount ?? this.amount,
    description: description.present ? description.value : this.description,
    tag: tag.present ? tag.value : this.tag,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    senderSignature: senderSignature.present
        ? senderSignature.value
        : this.senderSignature,
    receiverSignature: receiverSignature.present
        ? receiverSignature.value
        : this.receiverSignature,
    currency: currency ?? this.currency,
  );
  TransactionsTableData copyWithCompanion(TransactionsTableCompanion data) {
    return TransactionsTableData(
      id: data.id.present ? data.id.value : this.id,
      fromUserPublicKey: data.fromUserPublicKey.present
          ? data.fromUserPublicKey.value
          : this.fromUserPublicKey,
      toUserPublicKey: data.toUserPublicKey.present
          ? data.toUserPublicKey.value
          : this.toUserPublicKey,
      amount: data.amount.present ? data.amount.value : this.amount,
      description: data.description.present
          ? data.description.value
          : this.description,
      tag: data.tag.present ? data.tag.value : this.tag,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      senderSignature: data.senderSignature.present
          ? data.senderSignature.value
          : this.senderSignature,
      receiverSignature: data.receiverSignature.present
          ? data.receiverSignature.value
          : this.receiverSignature,
      currency: data.currency.present ? data.currency.value : this.currency,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsTableData(')
          ..write('id: $id, ')
          ..write('fromUserPublicKey: $fromUserPublicKey, ')
          ..write('toUserPublicKey: $toUserPublicKey, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('tag: $tag, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('senderSignature: $senderSignature, ')
          ..write('receiverSignature: $receiverSignature, ')
          ..write('currency: $currency')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fromUserPublicKey,
    toUserPublicKey,
    amount,
    description,
    tag,
    status,
    createdAt,
    senderSignature,
    receiverSignature,
    currency,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionsTableData &&
          other.id == this.id &&
          other.fromUserPublicKey == this.fromUserPublicKey &&
          other.toUserPublicKey == this.toUserPublicKey &&
          other.amount == this.amount &&
          other.description == this.description &&
          other.tag == this.tag &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.senderSignature == this.senderSignature &&
          other.receiverSignature == this.receiverSignature &&
          other.currency == this.currency);
}

class TransactionsTableCompanion
    extends UpdateCompanion<TransactionsTableData> {
  final Value<String> id;
  final Value<String> fromUserPublicKey;
  final Value<String> toUserPublicKey;
  final Value<BigInt> amount;
  final Value<String?> description;
  final Value<String?> tag;
  final Value<TransactionStatus> status;
  final Value<DateTime> createdAt;
  final Value<String?> senderSignature;
  final Value<String?> receiverSignature;
  final Value<String> currency;
  final Value<int> rowid;
  const TransactionsTableCompanion({
    this.id = const Value.absent(),
    this.fromUserPublicKey = const Value.absent(),
    this.toUserPublicKey = const Value.absent(),
    this.amount = const Value.absent(),
    this.description = const Value.absent(),
    this.tag = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.senderSignature = const Value.absent(),
    this.receiverSignature = const Value.absent(),
    this.currency = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsTableCompanion.insert({
    required String id,
    required String fromUserPublicKey,
    required String toUserPublicKey,
    required BigInt amount,
    this.description = const Value.absent(),
    this.tag = const Value.absent(),
    required TransactionStatus status,
    this.createdAt = const Value.absent(),
    this.senderSignature = const Value.absent(),
    this.receiverSignature = const Value.absent(),
    required String currency,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fromUserPublicKey = Value(fromUserPublicKey),
       toUserPublicKey = Value(toUserPublicKey),
       amount = Value(amount),
       status = Value(status),
       currency = Value(currency);
  static Insertable<TransactionsTableData> custom({
    Expression<String>? id,
    Expression<String>? fromUserPublicKey,
    Expression<String>? toUserPublicKey,
    Expression<BigInt>? amount,
    Expression<String>? description,
    Expression<String>? tag,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<String>? senderSignature,
    Expression<String>? receiverSignature,
    Expression<String>? currency,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fromUserPublicKey != null) 'from_user_public_key': fromUserPublicKey,
      if (toUserPublicKey != null) 'to_user_public_key': toUserPublicKey,
      if (amount != null) 'amount': amount,
      if (description != null) 'description': description,
      if (tag != null) 'tag': tag,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (senderSignature != null) 'sender_signature': senderSignature,
      if (receiverSignature != null) 'receiver_signature': receiverSignature,
      if (currency != null) 'currency': currency,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? fromUserPublicKey,
    Value<String>? toUserPublicKey,
    Value<BigInt>? amount,
    Value<String?>? description,
    Value<String?>? tag,
    Value<TransactionStatus>? status,
    Value<DateTime>? createdAt,
    Value<String?>? senderSignature,
    Value<String?>? receiverSignature,
    Value<String>? currency,
    Value<int>? rowid,
  }) {
    return TransactionsTableCompanion(
      id: id ?? this.id,
      fromUserPublicKey: fromUserPublicKey ?? this.fromUserPublicKey,
      toUserPublicKey: toUserPublicKey ?? this.toUserPublicKey,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      tag: tag ?? this.tag,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      senderSignature: senderSignature ?? this.senderSignature,
      receiverSignature: receiverSignature ?? this.receiverSignature,
      currency: currency ?? this.currency,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fromUserPublicKey.present) {
      map['from_user_public_key'] = Variable<String>(fromUserPublicKey.value);
    }
    if (toUserPublicKey.present) {
      map['to_user_public_key'] = Variable<String>(toUserPublicKey.value);
    }
    if (amount.present) {
      map['amount'] = Variable<BigInt>(amount.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $TransactionsTableTable.$converterstatus.toSql(status.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (senderSignature.present) {
      map['sender_signature'] = Variable<String>(senderSignature.value);
    }
    if (receiverSignature.present) {
      map['receiver_signature'] = Variable<String>(receiverSignature.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsTableCompanion(')
          ..write('id: $id, ')
          ..write('fromUserPublicKey: $fromUserPublicKey, ')
          ..write('toUserPublicKey: $toUserPublicKey, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('tag: $tag, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('senderSignature: $senderSignature, ')
          ..write('receiverSignature: $receiverSignature, ')
          ..write('currency: $currency, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BalancesTableTable extends BalancesTable
    with TableInfo<$BalancesTableTable, BalancesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BalancesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userPublicKeyMeta = const VerificationMeta(
    'userPublicKey',
  );
  @override
  late final GeneratedColumn<String> userPublicKey = GeneratedColumn<String>(
    'user_public_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (public_key)',
    ),
  );
  static const VerificationMeta _netAmountMeta = const VerificationMeta(
    'netAmount',
  );
  @override
  late final GeneratedColumn<int> netAmount = GeneratedColumn<int>(
    'net_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _signedMeta = const VerificationMeta('signed');
  @override
  late final GeneratedColumn<String> signed = GeneratedColumn<String>(
    'signed',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userPublicKey,
    netAmount,
    signed,
    updatedAt,
    currency,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'balances';
  @override
  VerificationContext validateIntegrity(
    Insertable<BalancesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_public_key')) {
      context.handle(
        _userPublicKeyMeta,
        userPublicKey.isAcceptableOrUnknown(
          data['user_public_key']!,
          _userPublicKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_userPublicKeyMeta);
    }
    if (data.containsKey('net_amount')) {
      context.handle(
        _netAmountMeta,
        netAmount.isAcceptableOrUnknown(data['net_amount']!, _netAmountMeta),
      );
    } else if (isInserting) {
      context.missing(_netAmountMeta);
    }
    if (data.containsKey('signed')) {
      context.handle(
        _signedMeta,
        signed.isAcceptableOrUnknown(data['signed']!, _signedMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userPublicKey, currency};
  @override
  BalancesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BalancesTableData(
      userPublicKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_public_key'],
      )!,
      netAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}net_amount'],
      )!,
      signed: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}signed'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
    );
  }

  @override
  $BalancesTableTable createAlias(String alias) {
    return $BalancesTableTable(attachedDatabase, alias);
  }
}

class BalancesTableData extends DataClass
    implements Insertable<BalancesTableData> {
  final String userPublicKey;
  final int netAmount;
  final String? signed;
  final DateTime updatedAt;
  final String currency;
  const BalancesTableData({
    required this.userPublicKey,
    required this.netAmount,
    this.signed,
    required this.updatedAt,
    required this.currency,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_public_key'] = Variable<String>(userPublicKey);
    map['net_amount'] = Variable<int>(netAmount);
    if (!nullToAbsent || signed != null) {
      map['signed'] = Variable<String>(signed);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['currency'] = Variable<String>(currency);
    return map;
  }

  BalancesTableCompanion toCompanion(bool nullToAbsent) {
    return BalancesTableCompanion(
      userPublicKey: Value(userPublicKey),
      netAmount: Value(netAmount),
      signed: signed == null && nullToAbsent
          ? const Value.absent()
          : Value(signed),
      updatedAt: Value(updatedAt),
      currency: Value(currency),
    );
  }

  factory BalancesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BalancesTableData(
      userPublicKey: serializer.fromJson<String>(json['userPublicKey']),
      netAmount: serializer.fromJson<int>(json['netAmount']),
      signed: serializer.fromJson<String?>(json['signed']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      currency: serializer.fromJson<String>(json['currency']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userPublicKey': serializer.toJson<String>(userPublicKey),
      'netAmount': serializer.toJson<int>(netAmount),
      'signed': serializer.toJson<String?>(signed),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'currency': serializer.toJson<String>(currency),
    };
  }

  BalancesTableData copyWith({
    String? userPublicKey,
    int? netAmount,
    Value<String?> signed = const Value.absent(),
    DateTime? updatedAt,
    String? currency,
  }) => BalancesTableData(
    userPublicKey: userPublicKey ?? this.userPublicKey,
    netAmount: netAmount ?? this.netAmount,
    signed: signed.present ? signed.value : this.signed,
    updatedAt: updatedAt ?? this.updatedAt,
    currency: currency ?? this.currency,
  );
  BalancesTableData copyWithCompanion(BalancesTableCompanion data) {
    return BalancesTableData(
      userPublicKey: data.userPublicKey.present
          ? data.userPublicKey.value
          : this.userPublicKey,
      netAmount: data.netAmount.present ? data.netAmount.value : this.netAmount,
      signed: data.signed.present ? data.signed.value : this.signed,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      currency: data.currency.present ? data.currency.value : this.currency,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BalancesTableData(')
          ..write('userPublicKey: $userPublicKey, ')
          ..write('netAmount: $netAmount, ')
          ..write('signed: $signed, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('currency: $currency')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(userPublicKey, netAmount, signed, updatedAt, currency);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BalancesTableData &&
          other.userPublicKey == this.userPublicKey &&
          other.netAmount == this.netAmount &&
          other.signed == this.signed &&
          other.updatedAt == this.updatedAt &&
          other.currency == this.currency);
}

class BalancesTableCompanion extends UpdateCompanion<BalancesTableData> {
  final Value<String> userPublicKey;
  final Value<int> netAmount;
  final Value<String?> signed;
  final Value<DateTime> updatedAt;
  final Value<String> currency;
  final Value<int> rowid;
  const BalancesTableCompanion({
    this.userPublicKey = const Value.absent(),
    this.netAmount = const Value.absent(),
    this.signed = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.currency = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BalancesTableCompanion.insert({
    required String userPublicKey,
    required int netAmount,
    this.signed = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String currency,
    this.rowid = const Value.absent(),
  }) : userPublicKey = Value(userPublicKey),
       netAmount = Value(netAmount),
       currency = Value(currency);
  static Insertable<BalancesTableData> custom({
    Expression<String>? userPublicKey,
    Expression<int>? netAmount,
    Expression<String>? signed,
    Expression<DateTime>? updatedAt,
    Expression<String>? currency,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userPublicKey != null) 'user_public_key': userPublicKey,
      if (netAmount != null) 'net_amount': netAmount,
      if (signed != null) 'signed': signed,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (currency != null) 'currency': currency,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BalancesTableCompanion copyWith({
    Value<String>? userPublicKey,
    Value<int>? netAmount,
    Value<String?>? signed,
    Value<DateTime>? updatedAt,
    Value<String>? currency,
    Value<int>? rowid,
  }) {
    return BalancesTableCompanion(
      userPublicKey: userPublicKey ?? this.userPublicKey,
      netAmount: netAmount ?? this.netAmount,
      signed: signed ?? this.signed,
      updatedAt: updatedAt ?? this.updatedAt,
      currency: currency ?? this.currency,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userPublicKey.present) {
      map['user_public_key'] = Variable<String>(userPublicKey.value);
    }
    if (netAmount.present) {
      map['net_amount'] = Variable<int>(netAmount.value);
    }
    if (signed.present) {
      map['signed'] = Variable<String>(signed.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BalancesTableCompanion(')
          ..write('userPublicKey: $userPublicKey, ')
          ..write('netAmount: $netAmount, ')
          ..write('signed: $signed, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('currency: $currency, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroupsTableTable extends GroupsTable
    with TableInfo<$GroupsTableTable, GroupsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
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
  static const VerificationMeta _usersMeta = const VerificationMeta('users');
  @override
  late final GeneratedColumn<String> users = GeneratedColumn<String>(
    'users',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, users, description];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<GroupsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('users')) {
      context.handle(
        _usersMeta,
        users.isAcceptableOrUnknown(data['users']!, _usersMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GroupsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      users: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}users'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
    );
  }

  @override
  $GroupsTableTable createAlias(String alias) {
    return $GroupsTableTable(attachedDatabase, alias);
  }
}

class GroupsTableData extends DataClass implements Insertable<GroupsTableData> {
  final String id;
  final String name;
  final String users;
  final String? description;
  const GroupsTableData({
    required this.id,
    required this.name,
    required this.users,
    this.description,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['users'] = Variable<String>(users);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    return map;
  }

  GroupsTableCompanion toCompanion(bool nullToAbsent) {
    return GroupsTableCompanion(
      id: Value(id),
      name: Value(name),
      users: Value(users),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
    );
  }

  factory GroupsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      users: serializer.fromJson<String>(json['users']),
      description: serializer.fromJson<String?>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'users': serializer.toJson<String>(users),
      'description': serializer.toJson<String?>(description),
    };
  }

  GroupsTableData copyWith({
    String? id,
    String? name,
    String? users,
    Value<String?> description = const Value.absent(),
  }) => GroupsTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    users: users ?? this.users,
    description: description.present ? description.value : this.description,
  );
  GroupsTableData copyWithCompanion(GroupsTableCompanion data) {
    return GroupsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      users: data.users.present ? data.users.value : this.users,
      description: data.description.present
          ? data.description.value
          : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('users: $users, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, users, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.users == this.users &&
          other.description == this.description);
}

class GroupsTableCompanion extends UpdateCompanion<GroupsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> users;
  final Value<String?> description;
  final Value<int> rowid;
  const GroupsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.users = const Value.absent(),
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupsTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.users = const Value.absent(),
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<GroupsTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? users,
    Expression<String>? description,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (users != null) 'users': users,
      if (description != null) 'description': description,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? users,
    Value<String?>? description,
    Value<int>? rowid,
  }) {
    return GroupsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      users: users ?? this.users,
      description: description ?? this.description,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (users.present) {
      map['users'] = Variable<String>(users.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('users: $users, ')
          ..write('description: $description, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTableTable usersTable = $UsersTableTable(this);
  late final $TransactionsTableTable transactionsTable =
      $TransactionsTableTable(this);
  late final $BalancesTableTable balancesTable = $BalancesTableTable(this);
  late final $GroupsTableTable groupsTable = $GroupsTableTable(this);
  late final TransactionsDao transactionsDao = TransactionsDao(
    this as AppDatabase,
  );
  late final GroupsDao groupsDao = GroupsDao(this as AppDatabase);
  late final UsersDao usersDao = UsersDao(this as AppDatabase);
  late final BalancesDao balancesDao = BalancesDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    usersTable,
    transactionsTable,
    balancesTable,
    groupsTable,
  ];
}

typedef $$UsersTableTableCreateCompanionBuilder =
    UsersTableCompanion Function({
      required String publicKey,
      required String displayName,
      Value<String?> cryptoAddress,
      Value<String?> profilePicture,
      required String defaultCurrency,
      Value<int> rowid,
    });
typedef $$UsersTableTableUpdateCompanionBuilder =
    UsersTableCompanion Function({
      Value<String> publicKey,
      Value<String> displayName,
      Value<String?> cryptoAddress,
      Value<String?> profilePicture,
      Value<String> defaultCurrency,
      Value<int> rowid,
    });

final class $$UsersTableTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTableTable, UsersTableData> {
  $$UsersTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BalancesTableTable, List<BalancesTableData>>
  _balancesTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.balancesTable,
    aliasName: $_aliasNameGenerator(
      db.usersTable.publicKey,
      db.balancesTable.userPublicKey,
    ),
  );

  $$BalancesTableTableProcessedTableManager get balancesTableRefs {
    final manager = $$BalancesTableTableTableManager($_db, $_db.balancesTable)
        .filter(
          (f) => f.userPublicKey.publicKey.sqlEquals(
            $_itemColumn<String>('public_key')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_balancesTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UsersTableTableFilterComposer
    extends Composer<_$AppDatabase, $UsersTableTable> {
  $$UsersTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cryptoAddress => $composableBuilder(
    column: $table.cryptoAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profilePicture => $composableBuilder(
    column: $table.profilePicture,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultCurrency => $composableBuilder(
    column: $table.defaultCurrency,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> balancesTableRefs(
    Expression<bool> Function($$BalancesTableTableFilterComposer f) f,
  ) {
    final $$BalancesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.publicKey,
      referencedTable: $db.balancesTable,
      getReferencedColumn: (t) => t.userPublicKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BalancesTableTableFilterComposer(
            $db: $db,
            $table: $db.balancesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTableTable> {
  $$UsersTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cryptoAddress => $composableBuilder(
    column: $table.cryptoAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profilePicture => $composableBuilder(
    column: $table.profilePicture,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultCurrency => $composableBuilder(
    column: $table.defaultCurrency,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTableTable> {
  $$UsersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get publicKey =>
      $composableBuilder(column: $table.publicKey, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cryptoAddress => $composableBuilder(
    column: $table.cryptoAddress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get profilePicture => $composableBuilder(
    column: $table.profilePicture,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultCurrency => $composableBuilder(
    column: $table.defaultCurrency,
    builder: (column) => column,
  );

  Expression<T> balancesTableRefs<T extends Object>(
    Expression<T> Function($$BalancesTableTableAnnotationComposer a) f,
  ) {
    final $$BalancesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.publicKey,
      referencedTable: $db.balancesTable,
      getReferencedColumn: (t) => t.userPublicKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BalancesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.balancesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTableTable,
          UsersTableData,
          $$UsersTableTableFilterComposer,
          $$UsersTableTableOrderingComposer,
          $$UsersTableTableAnnotationComposer,
          $$UsersTableTableCreateCompanionBuilder,
          $$UsersTableTableUpdateCompanionBuilder,
          (UsersTableData, $$UsersTableTableReferences),
          UsersTableData,
          PrefetchHooks Function({bool balancesTableRefs})
        > {
  $$UsersTableTableTableManager(_$AppDatabase db, $UsersTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> publicKey = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> cryptoAddress = const Value.absent(),
                Value<String?> profilePicture = const Value.absent(),
                Value<String> defaultCurrency = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersTableCompanion(
                publicKey: publicKey,
                displayName: displayName,
                cryptoAddress: cryptoAddress,
                profilePicture: profilePicture,
                defaultCurrency: defaultCurrency,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String publicKey,
                required String displayName,
                Value<String?> cryptoAddress = const Value.absent(),
                Value<String?> profilePicture = const Value.absent(),
                required String defaultCurrency,
                Value<int> rowid = const Value.absent(),
              }) => UsersTableCompanion.insert(
                publicKey: publicKey,
                displayName: displayName,
                cryptoAddress: cryptoAddress,
                profilePicture: profilePicture,
                defaultCurrency: defaultCurrency,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UsersTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({balancesTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (balancesTableRefs) db.balancesTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (balancesTableRefs)
                    await $_getPrefetchedData<
                      UsersTableData,
                      $UsersTableTable,
                      BalancesTableData
                    >(
                      currentTable: table,
                      referencedTable: $$UsersTableTableReferences
                          ._balancesTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$UsersTableTableReferences(
                            db,
                            table,
                            p0,
                          ).balancesTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.userPublicKey == item.publicKey,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$UsersTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTableTable,
      UsersTableData,
      $$UsersTableTableFilterComposer,
      $$UsersTableTableOrderingComposer,
      $$UsersTableTableAnnotationComposer,
      $$UsersTableTableCreateCompanionBuilder,
      $$UsersTableTableUpdateCompanionBuilder,
      (UsersTableData, $$UsersTableTableReferences),
      UsersTableData,
      PrefetchHooks Function({bool balancesTableRefs})
    >;
typedef $$TransactionsTableTableCreateCompanionBuilder =
    TransactionsTableCompanion Function({
      required String id,
      required String fromUserPublicKey,
      required String toUserPublicKey,
      required BigInt amount,
      Value<String?> description,
      Value<String?> tag,
      required TransactionStatus status,
      Value<DateTime> createdAt,
      Value<String?> senderSignature,
      Value<String?> receiverSignature,
      required String currency,
      Value<int> rowid,
    });
typedef $$TransactionsTableTableUpdateCompanionBuilder =
    TransactionsTableCompanion Function({
      Value<String> id,
      Value<String> fromUserPublicKey,
      Value<String> toUserPublicKey,
      Value<BigInt> amount,
      Value<String?> description,
      Value<String?> tag,
      Value<TransactionStatus> status,
      Value<DateTime> createdAt,
      Value<String?> senderSignature,
      Value<String?> receiverSignature,
      Value<String> currency,
      Value<int> rowid,
    });

final class $$TransactionsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TransactionsTableTable,
          TransactionsTableData
        > {
  $$TransactionsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UsersTableTable _fromUserPublicKeyTable(_$AppDatabase db) =>
      db.usersTable.createAlias(
        $_aliasNameGenerator(
          db.transactionsTable.fromUserPublicKey,
          db.usersTable.publicKey,
        ),
      );

  $$UsersTableTableProcessedTableManager get fromUserPublicKey {
    final $_column = $_itemColumn<String>('from_user_public_key')!;

    final manager = $$UsersTableTableTableManager(
      $_db,
      $_db.usersTable,
    ).filter((f) => f.publicKey.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fromUserPublicKeyTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsersTableTable _toUserPublicKeyTable(_$AppDatabase db) =>
      db.usersTable.createAlias(
        $_aliasNameGenerator(
          db.transactionsTable.toUserPublicKey,
          db.usersTable.publicKey,
        ),
      );

  $$UsersTableTableProcessedTableManager get toUserPublicKey {
    final $_column = $_itemColumn<String>('to_user_public_key')!;

    final manager = $$UsersTableTableTableManager(
      $_db,
      $_db.usersTable,
    ).filter((f) => f.publicKey.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_toUserPublicKeyTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransactionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTableTable> {
  $$TransactionsTableTableFilterComposer({
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

  ColumnFilters<BigInt> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TransactionStatus, TransactionStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderSignature => $composableBuilder(
    column: $table.senderSignature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiverSignature => $composableBuilder(
    column: $table.receiverSignature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableTableFilterComposer get fromUserPublicKey {
    final $$UsersTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromUserPublicKey,
      referencedTable: $db.usersTable,
      getReferencedColumn: (t) => t.publicKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableTableFilterComposer(
            $db: $db,
            $table: $db.usersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableTableFilterComposer get toUserPublicKey {
    final $$UsersTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toUserPublicKey,
      referencedTable: $db.usersTable,
      getReferencedColumn: (t) => t.publicKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableTableFilterComposer(
            $db: $db,
            $table: $db.usersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTableTable> {
  $$TransactionsTableTableOrderingComposer({
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

  ColumnOrderings<BigInt> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderSignature => $composableBuilder(
    column: $table.senderSignature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiverSignature => $composableBuilder(
    column: $table.receiverSignature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableTableOrderingComposer get fromUserPublicKey {
    final $$UsersTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromUserPublicKey,
      referencedTable: $db.usersTable,
      getReferencedColumn: (t) => t.publicKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableTableOrderingComposer(
            $db: $db,
            $table: $db.usersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableTableOrderingComposer get toUserPublicKey {
    final $$UsersTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toUserPublicKey,
      referencedTable: $db.usersTable,
      getReferencedColumn: (t) => t.publicKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableTableOrderingComposer(
            $db: $db,
            $table: $db.usersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTableTable> {
  $$TransactionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<BigInt> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TransactionStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get senderSignature => $composableBuilder(
    column: $table.senderSignature,
    builder: (column) => column,
  );

  GeneratedColumn<String> get receiverSignature => $composableBuilder(
    column: $table.receiverSignature,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  $$UsersTableTableAnnotationComposer get fromUserPublicKey {
    final $$UsersTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromUserPublicKey,
      referencedTable: $db.usersTable,
      getReferencedColumn: (t) => t.publicKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableTableAnnotationComposer(
            $db: $db,
            $table: $db.usersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableTableAnnotationComposer get toUserPublicKey {
    final $$UsersTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toUserPublicKey,
      referencedTable: $db.usersTable,
      getReferencedColumn: (t) => t.publicKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableTableAnnotationComposer(
            $db: $db,
            $table: $db.usersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTableTable,
          TransactionsTableData,
          $$TransactionsTableTableFilterComposer,
          $$TransactionsTableTableOrderingComposer,
          $$TransactionsTableTableAnnotationComposer,
          $$TransactionsTableTableCreateCompanionBuilder,
          $$TransactionsTableTableUpdateCompanionBuilder,
          (TransactionsTableData, $$TransactionsTableTableReferences),
          TransactionsTableData,
          PrefetchHooks Function({bool fromUserPublicKey, bool toUserPublicKey})
        > {
  $$TransactionsTableTableTableManager(
    _$AppDatabase db,
    $TransactionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> fromUserPublicKey = const Value.absent(),
                Value<String> toUserPublicKey = const Value.absent(),
                Value<BigInt> amount = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> tag = const Value.absent(),
                Value<TransactionStatus> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> senderSignature = const Value.absent(),
                Value<String?> receiverSignature = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsTableCompanion(
                id: id,
                fromUserPublicKey: fromUserPublicKey,
                toUserPublicKey: toUserPublicKey,
                amount: amount,
                description: description,
                tag: tag,
                status: status,
                createdAt: createdAt,
                senderSignature: senderSignature,
                receiverSignature: receiverSignature,
                currency: currency,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String fromUserPublicKey,
                required String toUserPublicKey,
                required BigInt amount,
                Value<String?> description = const Value.absent(),
                Value<String?> tag = const Value.absent(),
                required TransactionStatus status,
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> senderSignature = const Value.absent(),
                Value<String?> receiverSignature = const Value.absent(),
                required String currency,
                Value<int> rowid = const Value.absent(),
              }) => TransactionsTableCompanion.insert(
                id: id,
                fromUserPublicKey: fromUserPublicKey,
                toUserPublicKey: toUserPublicKey,
                amount: amount,
                description: description,
                tag: tag,
                status: status,
                createdAt: createdAt,
                senderSignature: senderSignature,
                receiverSignature: receiverSignature,
                currency: currency,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({fromUserPublicKey = false, toUserPublicKey = false}) {
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
                        if (fromUserPublicKey) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.fromUserPublicKey,
                                    referencedTable:
                                        $$TransactionsTableTableReferences
                                            ._fromUserPublicKeyTable(db),
                                    referencedColumn:
                                        $$TransactionsTableTableReferences
                                            ._fromUserPublicKeyTable(db)
                                            .publicKey,
                                  )
                                  as T;
                        }
                        if (toUserPublicKey) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.toUserPublicKey,
                                    referencedTable:
                                        $$TransactionsTableTableReferences
                                            ._toUserPublicKeyTable(db),
                                    referencedColumn:
                                        $$TransactionsTableTableReferences
                                            ._toUserPublicKeyTable(db)
                                            .publicKey,
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

typedef $$TransactionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTableTable,
      TransactionsTableData,
      $$TransactionsTableTableFilterComposer,
      $$TransactionsTableTableOrderingComposer,
      $$TransactionsTableTableAnnotationComposer,
      $$TransactionsTableTableCreateCompanionBuilder,
      $$TransactionsTableTableUpdateCompanionBuilder,
      (TransactionsTableData, $$TransactionsTableTableReferences),
      TransactionsTableData,
      PrefetchHooks Function({bool fromUserPublicKey, bool toUserPublicKey})
    >;
typedef $$BalancesTableTableCreateCompanionBuilder =
    BalancesTableCompanion Function({
      required String userPublicKey,
      required int netAmount,
      Value<String?> signed,
      Value<DateTime> updatedAt,
      required String currency,
      Value<int> rowid,
    });
typedef $$BalancesTableTableUpdateCompanionBuilder =
    BalancesTableCompanion Function({
      Value<String> userPublicKey,
      Value<int> netAmount,
      Value<String?> signed,
      Value<DateTime> updatedAt,
      Value<String> currency,
      Value<int> rowid,
    });

final class $$BalancesTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $BalancesTableTable, BalancesTableData> {
  $$BalancesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UsersTableTable _userPublicKeyTable(_$AppDatabase db) =>
      db.usersTable.createAlias(
        $_aliasNameGenerator(
          db.balancesTable.userPublicKey,
          db.usersTable.publicKey,
        ),
      );

  $$UsersTableTableProcessedTableManager get userPublicKey {
    final $_column = $_itemColumn<String>('user_public_key')!;

    final manager = $$UsersTableTableTableManager(
      $_db,
      $_db.usersTable,
    ).filter((f) => f.publicKey.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userPublicKeyTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BalancesTableTableFilterComposer
    extends Composer<_$AppDatabase, $BalancesTableTable> {
  $$BalancesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get netAmount => $composableBuilder(
    column: $table.netAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get signed => $composableBuilder(
    column: $table.signed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableTableFilterComposer get userPublicKey {
    final $$UsersTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userPublicKey,
      referencedTable: $db.usersTable,
      getReferencedColumn: (t) => t.publicKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableTableFilterComposer(
            $db: $db,
            $table: $db.usersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BalancesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $BalancesTableTable> {
  $$BalancesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get netAmount => $composableBuilder(
    column: $table.netAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get signed => $composableBuilder(
    column: $table.signed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableTableOrderingComposer get userPublicKey {
    final $$UsersTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userPublicKey,
      referencedTable: $db.usersTable,
      getReferencedColumn: (t) => t.publicKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableTableOrderingComposer(
            $db: $db,
            $table: $db.usersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BalancesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $BalancesTableTable> {
  $$BalancesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get netAmount =>
      $composableBuilder(column: $table.netAmount, builder: (column) => column);

  GeneratedColumn<String> get signed =>
      $composableBuilder(column: $table.signed, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  $$UsersTableTableAnnotationComposer get userPublicKey {
    final $$UsersTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userPublicKey,
      referencedTable: $db.usersTable,
      getReferencedColumn: (t) => t.publicKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableTableAnnotationComposer(
            $db: $db,
            $table: $db.usersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BalancesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BalancesTableTable,
          BalancesTableData,
          $$BalancesTableTableFilterComposer,
          $$BalancesTableTableOrderingComposer,
          $$BalancesTableTableAnnotationComposer,
          $$BalancesTableTableCreateCompanionBuilder,
          $$BalancesTableTableUpdateCompanionBuilder,
          (BalancesTableData, $$BalancesTableTableReferences),
          BalancesTableData,
          PrefetchHooks Function({bool userPublicKey})
        > {
  $$BalancesTableTableTableManager(_$AppDatabase db, $BalancesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BalancesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BalancesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BalancesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userPublicKey = const Value.absent(),
                Value<int> netAmount = const Value.absent(),
                Value<String?> signed = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BalancesTableCompanion(
                userPublicKey: userPublicKey,
                netAmount: netAmount,
                signed: signed,
                updatedAt: updatedAt,
                currency: currency,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userPublicKey,
                required int netAmount,
                Value<String?> signed = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String currency,
                Value<int> rowid = const Value.absent(),
              }) => BalancesTableCompanion.insert(
                userPublicKey: userPublicKey,
                netAmount: netAmount,
                signed: signed,
                updatedAt: updatedAt,
                currency: currency,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BalancesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userPublicKey = false}) {
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
                    if (userPublicKey) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userPublicKey,
                                referencedTable: $$BalancesTableTableReferences
                                    ._userPublicKeyTable(db),
                                referencedColumn: $$BalancesTableTableReferences
                                    ._userPublicKeyTable(db)
                                    .publicKey,
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

typedef $$BalancesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BalancesTableTable,
      BalancesTableData,
      $$BalancesTableTableFilterComposer,
      $$BalancesTableTableOrderingComposer,
      $$BalancesTableTableAnnotationComposer,
      $$BalancesTableTableCreateCompanionBuilder,
      $$BalancesTableTableUpdateCompanionBuilder,
      (BalancesTableData, $$BalancesTableTableReferences),
      BalancesTableData,
      PrefetchHooks Function({bool userPublicKey})
    >;
typedef $$GroupsTableTableCreateCompanionBuilder =
    GroupsTableCompanion Function({
      Value<String> id,
      required String name,
      Value<String> users,
      Value<String?> description,
      Value<int> rowid,
    });
typedef $$GroupsTableTableUpdateCompanionBuilder =
    GroupsTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> users,
      Value<String?> description,
      Value<int> rowid,
    });

class $$GroupsTableTableFilterComposer
    extends Composer<_$AppDatabase, $GroupsTableTable> {
  $$GroupsTableTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get users => $composableBuilder(
    column: $table.users,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GroupsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupsTableTable> {
  $$GroupsTableTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get users => $composableBuilder(
    column: $table.users,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GroupsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupsTableTable> {
  $$GroupsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get users =>
      $composableBuilder(column: $table.users, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );
}

class $$GroupsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroupsTableTable,
          GroupsTableData,
          $$GroupsTableTableFilterComposer,
          $$GroupsTableTableOrderingComposer,
          $$GroupsTableTableAnnotationComposer,
          $$GroupsTableTableCreateCompanionBuilder,
          $$GroupsTableTableUpdateCompanionBuilder,
          (
            GroupsTableData,
            BaseReferences<_$AppDatabase, $GroupsTableTable, GroupsTableData>,
          ),
          GroupsTableData,
          PrefetchHooks Function()
        > {
  $$GroupsTableTableTableManager(_$AppDatabase db, $GroupsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> users = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupsTableCompanion(
                id: id,
                name: name,
                users: users,
                description: description,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String name,
                Value<String> users = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupsTableCompanion.insert(
                id: id,
                name: name,
                users: users,
                description: description,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GroupsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroupsTableTable,
      GroupsTableData,
      $$GroupsTableTableFilterComposer,
      $$GroupsTableTableOrderingComposer,
      $$GroupsTableTableAnnotationComposer,
      $$GroupsTableTableCreateCompanionBuilder,
      $$GroupsTableTableUpdateCompanionBuilder,
      (
        GroupsTableData,
        BaseReferences<_$AppDatabase, $GroupsTableTable, GroupsTableData>,
      ),
      GroupsTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableTableManager get usersTable =>
      $$UsersTableTableTableManager(_db, _db.usersTable);
  $$TransactionsTableTableTableManager get transactionsTable =>
      $$TransactionsTableTableTableManager(_db, _db.transactionsTable);
  $$BalancesTableTableTableManager get balancesTable =>
      $$BalancesTableTableTableManager(_db, _db.balancesTable);
  $$GroupsTableTableTableManager get groupsTable =>
      $$GroupsTableTableTableManager(_db, _db.groupsTable);
}
