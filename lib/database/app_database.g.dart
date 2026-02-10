// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SleepEntriesTable extends SleepEntries
    with TableInfo<$SleepEntriesTable, SleepEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SleepEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wakeDateMeta = const VerificationMeta(
    'wakeDate',
  );
  @override
  late final GeneratedColumn<String> wakeDate = GeneratedColumn<String>(
    'wake_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bedtimeTsMeta = const VerificationMeta(
    'bedtimeTs',
  );
  @override
  late final GeneratedColumn<DateTime> bedtimeTs = GeneratedColumn<DateTime>(
    'bedtime_ts',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wakeTsMeta = const VerificationMeta('wakeTs');
  @override
  late final GeneratedColumn<DateTime> wakeTs = GeneratedColumn<DateTime>(
    'wake_ts',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    false,
    check: () => ComparableExpr(
      durationMinutes,
    ).isBetween(const Constant(1), const Constant(1440)),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qualityMeta = const VerificationMeta(
    'quality',
  );
  @override
  late final GeneratedColumn<int> quality = GeneratedColumn<int>(
    'quality',
    aliasedName,
    false,
    check: () =>
        ComparableExpr(quality).isBetween(const Constant(1), const Constant(5)),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    wakeDate,
    bedtimeTs,
    wakeTs,
    durationMinutes,
    quality,
    note,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sleep_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SleepEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('wake_date')) {
      context.handle(
        _wakeDateMeta,
        wakeDate.isAcceptableOrUnknown(data['wake_date']!, _wakeDateMeta),
      );
    } else if (isInserting) {
      context.missing(_wakeDateMeta);
    }
    if (data.containsKey('bedtime_ts')) {
      context.handle(
        _bedtimeTsMeta,
        bedtimeTs.isAcceptableOrUnknown(data['bedtime_ts']!, _bedtimeTsMeta),
      );
    } else if (isInserting) {
      context.missing(_bedtimeTsMeta);
    }
    if (data.containsKey('wake_ts')) {
      context.handle(
        _wakeTsMeta,
        wakeTs.isAcceptableOrUnknown(data['wake_ts']!, _wakeTsMeta),
      );
    } else if (isInserting) {
      context.missing(_wakeTsMeta);
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationMinutesMeta);
    }
    if (data.containsKey('quality')) {
      context.handle(
        _qualityMeta,
        quality.isAcceptableOrUnknown(data['quality']!, _qualityMeta),
      );
    } else if (isInserting) {
      context.missing(_qualityMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SleepEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SleepEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      wakeDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wake_date'],
      )!,
      bedtimeTs: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}bedtime_ts'],
      )!,
      wakeTs: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}wake_ts'],
      )!,
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      )!,
      quality: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quality'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SleepEntriesTable createAlias(String alias) {
    return $SleepEntriesTable(attachedDatabase, alias);
  }
}

class SleepEntry extends DataClass implements Insertable<SleepEntry> {
  final String id;
  final String wakeDate;
  final DateTime bedtimeTs;
  final DateTime wakeTs;
  final int durationMinutes;
  final int quality;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SleepEntry({
    required this.id,
    required this.wakeDate,
    required this.bedtimeTs,
    required this.wakeTs,
    required this.durationMinutes,
    required this.quality,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['wake_date'] = Variable<String>(wakeDate);
    map['bedtime_ts'] = Variable<DateTime>(bedtimeTs);
    map['wake_ts'] = Variable<DateTime>(wakeTs);
    map['duration_minutes'] = Variable<int>(durationMinutes);
    map['quality'] = Variable<int>(quality);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SleepEntriesCompanion toCompanion(bool nullToAbsent) {
    return SleepEntriesCompanion(
      id: Value(id),
      wakeDate: Value(wakeDate),
      bedtimeTs: Value(bedtimeTs),
      wakeTs: Value(wakeTs),
      durationMinutes: Value(durationMinutes),
      quality: Value(quality),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SleepEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SleepEntry(
      id: serializer.fromJson<String>(json['id']),
      wakeDate: serializer.fromJson<String>(json['wakeDate']),
      bedtimeTs: serializer.fromJson<DateTime>(json['bedtimeTs']),
      wakeTs: serializer.fromJson<DateTime>(json['wakeTs']),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
      quality: serializer.fromJson<int>(json['quality']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'wakeDate': serializer.toJson<String>(wakeDate),
      'bedtimeTs': serializer.toJson<DateTime>(bedtimeTs),
      'wakeTs': serializer.toJson<DateTime>(wakeTs),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
      'quality': serializer.toJson<int>(quality),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SleepEntry copyWith({
    String? id,
    String? wakeDate,
    DateTime? bedtimeTs,
    DateTime? wakeTs,
    int? durationMinutes,
    int? quality,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SleepEntry(
    id: id ?? this.id,
    wakeDate: wakeDate ?? this.wakeDate,
    bedtimeTs: bedtimeTs ?? this.bedtimeTs,
    wakeTs: wakeTs ?? this.wakeTs,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    quality: quality ?? this.quality,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SleepEntry copyWithCompanion(SleepEntriesCompanion data) {
    return SleepEntry(
      id: data.id.present ? data.id.value : this.id,
      wakeDate: data.wakeDate.present ? data.wakeDate.value : this.wakeDate,
      bedtimeTs: data.bedtimeTs.present ? data.bedtimeTs.value : this.bedtimeTs,
      wakeTs: data.wakeTs.present ? data.wakeTs.value : this.wakeTs,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      quality: data.quality.present ? data.quality.value : this.quality,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SleepEntry(')
          ..write('id: $id, ')
          ..write('wakeDate: $wakeDate, ')
          ..write('bedtimeTs: $bedtimeTs, ')
          ..write('wakeTs: $wakeTs, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('quality: $quality, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    wakeDate,
    bedtimeTs,
    wakeTs,
    durationMinutes,
    quality,
    note,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SleepEntry &&
          other.id == this.id &&
          other.wakeDate == this.wakeDate &&
          other.bedtimeTs == this.bedtimeTs &&
          other.wakeTs == this.wakeTs &&
          other.durationMinutes == this.durationMinutes &&
          other.quality == this.quality &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SleepEntriesCompanion extends UpdateCompanion<SleepEntry> {
  final Value<String> id;
  final Value<String> wakeDate;
  final Value<DateTime> bedtimeTs;
  final Value<DateTime> wakeTs;
  final Value<int> durationMinutes;
  final Value<int> quality;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SleepEntriesCompanion({
    this.id = const Value.absent(),
    this.wakeDate = const Value.absent(),
    this.bedtimeTs = const Value.absent(),
    this.wakeTs = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.quality = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SleepEntriesCompanion.insert({
    required String id,
    required String wakeDate,
    required DateTime bedtimeTs,
    required DateTime wakeTs,
    required int durationMinutes,
    required int quality,
    this.note = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       wakeDate = Value(wakeDate),
       bedtimeTs = Value(bedtimeTs),
       wakeTs = Value(wakeTs),
       durationMinutes = Value(durationMinutes),
       quality = Value(quality),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SleepEntry> custom({
    Expression<String>? id,
    Expression<String>? wakeDate,
    Expression<DateTime>? bedtimeTs,
    Expression<DateTime>? wakeTs,
    Expression<int>? durationMinutes,
    Expression<int>? quality,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (wakeDate != null) 'wake_date': wakeDate,
      if (bedtimeTs != null) 'bedtime_ts': bedtimeTs,
      if (wakeTs != null) 'wake_ts': wakeTs,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (quality != null) 'quality': quality,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SleepEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? wakeDate,
    Value<DateTime>? bedtimeTs,
    Value<DateTime>? wakeTs,
    Value<int>? durationMinutes,
    Value<int>? quality,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SleepEntriesCompanion(
      id: id ?? this.id,
      wakeDate: wakeDate ?? this.wakeDate,
      bedtimeTs: bedtimeTs ?? this.bedtimeTs,
      wakeTs: wakeTs ?? this.wakeTs,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      quality: quality ?? this.quality,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (wakeDate.present) {
      map['wake_date'] = Variable<String>(wakeDate.value);
    }
    if (bedtimeTs.present) {
      map['bedtime_ts'] = Variable<DateTime>(bedtimeTs.value);
    }
    if (wakeTs.present) {
      map['wake_ts'] = Variable<DateTime>(wakeTs.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (quality.present) {
      map['quality'] = Variable<int>(quality.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SleepEntriesCompanion(')
          ..write('id: $id, ')
          ..write('wakeDate: $wakeDate, ')
          ..write('bedtimeTs: $bedtimeTs, ')
          ..write('wakeTs: $wakeTs, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('quality: $quality, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $SleepEntriesTable sleepEntries = $SleepEntriesTable(this);
  late final Index idxSleepEntriesWakeDate = Index(
    'idx_sleep_entries_wake_date',
    'CREATE INDEX idx_sleep_entries_wake_date ON sleep_entries (wake_date)',
  );
  late final Index idxSleepEntriesWakeTs = Index(
    'idx_sleep_entries_wake_ts',
    'CREATE INDEX idx_sleep_entries_wake_ts ON sleep_entries (wake_ts)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sleepEntries,
    idxSleepEntriesWakeDate,
    idxSleepEntriesWakeTs,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}
