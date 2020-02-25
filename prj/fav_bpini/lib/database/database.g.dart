// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class FoundVrpRecord extends DataClass implements Insertable<FoundVrpRecord> {
  final int id;
  final String firstPart;
  final String secondPart;
  final double latitude;
  final double longitude;
  final String address;
  final String note;
  final DateTime date;
  final String sourceImagePath;
  final String audioNotePath;
  final int top;
  final int left;
  final int width;
  final int height;
  FoundVrpRecord(
      {@required this.id,
      @required this.firstPart,
      @required this.secondPart,
      @required this.latitude,
      @required this.longitude,
      @required this.address,
      @required this.note,
      this.date,
      @required this.sourceImagePath,
      @required this.audioNotePath,
      @required this.top,
      @required this.left,
      @required this.width,
      @required this.height});
  factory FoundVrpRecord.fromData(
      Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    final doubleType = db.typeSystem.forDartType<double>();
    final dateTimeType = db.typeSystem.forDartType<DateTime>();
    return FoundVrpRecord(
      id: intType.mapFromDatabaseResponse(data['${effectivePrefix}id']),
      firstPart: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}first_part']),
      secondPart: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}second_part']),
      latitude: doubleType
          .mapFromDatabaseResponse(data['${effectivePrefix}latitude']),
      longitude: doubleType
          .mapFromDatabaseResponse(data['${effectivePrefix}longitude']),
      address:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}address']),
      note: stringType.mapFromDatabaseResponse(data['${effectivePrefix}note']),
      date:
          dateTimeType.mapFromDatabaseResponse(data['${effectivePrefix}date']),
      sourceImagePath: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}source_image_path']),
      audioNotePath: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}audio_note_path']),
      top: intType.mapFromDatabaseResponse(data['${effectivePrefix}top']),
      left: intType.mapFromDatabaseResponse(data['${effectivePrefix}left']),
      width: intType.mapFromDatabaseResponse(data['${effectivePrefix}width']),
      height: intType.mapFromDatabaseResponse(data['${effectivePrefix}height']),
    );
  }
  factory FoundVrpRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return FoundVrpRecord(
      id: serializer.fromJson<int>(json['id']),
      firstPart: serializer.fromJson<String>(json['firstPart']),
      secondPart: serializer.fromJson<String>(json['secondPart']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      address: serializer.fromJson<String>(json['address']),
      note: serializer.fromJson<String>(json['note']),
      date: serializer.fromJson<DateTime>(json['date']),
      sourceImagePath: serializer.fromJson<String>(json['sourceImagePath']),
      audioNotePath: serializer.fromJson<String>(json['audioNotePath']),
      top: serializer.fromJson<int>(json['top']),
      left: serializer.fromJson<int>(json['left']),
      width: serializer.fromJson<int>(json['width']),
      height: serializer.fromJson<int>(json['height']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'firstPart': serializer.toJson<String>(firstPart),
      'secondPart': serializer.toJson<String>(secondPart),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'address': serializer.toJson<String>(address),
      'note': serializer.toJson<String>(note),
      'date': serializer.toJson<DateTime>(date),
      'sourceImagePath': serializer.toJson<String>(sourceImagePath),
      'audioNotePath': serializer.toJson<String>(audioNotePath),
      'top': serializer.toJson<int>(top),
      'left': serializer.toJson<int>(left),
      'width': serializer.toJson<int>(width),
      'height': serializer.toJson<int>(height),
    };
  }

  @override
  FoundVrpRecordsCompanion createCompanion(bool nullToAbsent) {
    return FoundVrpRecordsCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      firstPart: firstPart == null && nullToAbsent
          ? const Value.absent()
          : Value(firstPart),
      secondPart: secondPart == null && nullToAbsent
          ? const Value.absent()
          : Value(secondPart),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      date: date == null && nullToAbsent ? const Value.absent() : Value(date),
      sourceImagePath: sourceImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceImagePath),
      audioNotePath: audioNotePath == null && nullToAbsent
          ? const Value.absent()
          : Value(audioNotePath),
      top: top == null && nullToAbsent ? const Value.absent() : Value(top),
      left: left == null && nullToAbsent ? const Value.absent() : Value(left),
      width:
          width == null && nullToAbsent ? const Value.absent() : Value(width),
      height:
          height == null && nullToAbsent ? const Value.absent() : Value(height),
    );
  }

  FoundVrpRecord copyWith(
          {int id,
          String firstPart,
          String secondPart,
          double latitude,
          double longitude,
          String address,
          String note,
          DateTime date,
          String sourceImagePath,
          String audioNotePath,
          int top,
          int left,
          int width,
          int height}) =>
      FoundVrpRecord(
        id: id ?? this.id,
        firstPart: firstPart ?? this.firstPart,
        secondPart: secondPart ?? this.secondPart,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        address: address ?? this.address,
        note: note ?? this.note,
        date: date ?? this.date,
        sourceImagePath: sourceImagePath ?? this.sourceImagePath,
        audioNotePath: audioNotePath ?? this.audioNotePath,
        top: top ?? this.top,
        left: left ?? this.left,
        width: width ?? this.width,
        height: height ?? this.height,
      );
  @override
  String toString() {
    return (StringBuffer('FoundVrpRecord(')
          ..write('id: $id, ')
          ..write('firstPart: $firstPart, ')
          ..write('secondPart: $secondPart, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('address: $address, ')
          ..write('note: $note, ')
          ..write('date: $date, ')
          ..write('sourceImagePath: $sourceImagePath, ')
          ..write('audioNotePath: $audioNotePath, ')
          ..write('top: $top, ')
          ..write('left: $left, ')
          ..write('width: $width, ')
          ..write('height: $height')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      id.hashCode,
      $mrjc(
          firstPart.hashCode,
          $mrjc(
              secondPart.hashCode,
              $mrjc(
                  latitude.hashCode,
                  $mrjc(
                      longitude.hashCode,
                      $mrjc(
                          address.hashCode,
                          $mrjc(
                              note.hashCode,
                              $mrjc(
                                  date.hashCode,
                                  $mrjc(
                                      sourceImagePath.hashCode,
                                      $mrjc(
                                          audioNotePath.hashCode,
                                          $mrjc(
                                              top.hashCode,
                                              $mrjc(
                                                  left.hashCode,
                                                  $mrjc(
                                                      width.hashCode,
                                                      height
                                                          .hashCode))))))))))))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is FoundVrpRecord &&
          other.id == this.id &&
          other.firstPart == this.firstPart &&
          other.secondPart == this.secondPart &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.address == this.address &&
          other.note == this.note &&
          other.date == this.date &&
          other.sourceImagePath == this.sourceImagePath &&
          other.audioNotePath == this.audioNotePath &&
          other.top == this.top &&
          other.left == this.left &&
          other.width == this.width &&
          other.height == this.height);
}

class FoundVrpRecordsCompanion extends UpdateCompanion<FoundVrpRecord> {
  final Value<int> id;
  final Value<String> firstPart;
  final Value<String> secondPart;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String> address;
  final Value<String> note;
  final Value<DateTime> date;
  final Value<String> sourceImagePath;
  final Value<String> audioNotePath;
  final Value<int> top;
  final Value<int> left;
  final Value<int> width;
  final Value<int> height;
  const FoundVrpRecordsCompanion({
    this.id = const Value.absent(),
    this.firstPart = const Value.absent(),
    this.secondPart = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.address = const Value.absent(),
    this.note = const Value.absent(),
    this.date = const Value.absent(),
    this.sourceImagePath = const Value.absent(),
    this.audioNotePath = const Value.absent(),
    this.top = const Value.absent(),
    this.left = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
  });
  FoundVrpRecordsCompanion.insert({
    this.id = const Value.absent(),
    @required String firstPart,
    @required String secondPart,
    @required double latitude,
    @required double longitude,
    @required String address,
    @required String note,
    this.date = const Value.absent(),
    @required String sourceImagePath,
    @required String audioNotePath,
    @required int top,
    @required int left,
    @required int width,
    @required int height,
  })  : firstPart = Value(firstPart),
        secondPart = Value(secondPart),
        latitude = Value(latitude),
        longitude = Value(longitude),
        address = Value(address),
        note = Value(note),
        sourceImagePath = Value(sourceImagePath),
        audioNotePath = Value(audioNotePath),
        top = Value(top),
        left = Value(left),
        width = Value(width),
        height = Value(height);
  FoundVrpRecordsCompanion copyWith(
      {Value<int> id,
      Value<String> firstPart,
      Value<String> secondPart,
      Value<double> latitude,
      Value<double> longitude,
      Value<String> address,
      Value<String> note,
      Value<DateTime> date,
      Value<String> sourceImagePath,
      Value<String> audioNotePath,
      Value<int> top,
      Value<int> left,
      Value<int> width,
      Value<int> height}) {
    return FoundVrpRecordsCompanion(
      id: id ?? this.id,
      firstPart: firstPart ?? this.firstPart,
      secondPart: secondPart ?? this.secondPart,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      note: note ?? this.note,
      date: date ?? this.date,
      sourceImagePath: sourceImagePath ?? this.sourceImagePath,
      audioNotePath: audioNotePath ?? this.audioNotePath,
      top: top ?? this.top,
      left: left ?? this.left,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}

class $FoundVrpRecordsTable extends FoundVrpRecords
    with TableInfo<$FoundVrpRecordsTable, FoundVrpRecord> {
  final GeneratedDatabase _db;
  final String _alias;
  $FoundVrpRecordsTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  GeneratedIntColumn _id;
  @override
  GeneratedIntColumn get id => _id ??= _constructId();
  GeneratedIntColumn _constructId() {
    return GeneratedIntColumn('id', $tableName, false,
        hasAutoIncrement: true, declaredAsPrimaryKey: true);
  }

  final VerificationMeta _firstPartMeta = const VerificationMeta('firstPart');
  GeneratedTextColumn _firstPart;
  @override
  GeneratedTextColumn get firstPart => _firstPart ??= _constructFirstPart();
  GeneratedTextColumn _constructFirstPart() {
    return GeneratedTextColumn(
      'first_part',
      $tableName,
      false,
    );
  }

  final VerificationMeta _secondPartMeta = const VerificationMeta('secondPart');
  GeneratedTextColumn _secondPart;
  @override
  GeneratedTextColumn get secondPart => _secondPart ??= _constructSecondPart();
  GeneratedTextColumn _constructSecondPart() {
    return GeneratedTextColumn(
      'second_part',
      $tableName,
      false,
    );
  }

  final VerificationMeta _latitudeMeta = const VerificationMeta('latitude');
  GeneratedRealColumn _latitude;
  @override
  GeneratedRealColumn get latitude => _latitude ??= _constructLatitude();
  GeneratedRealColumn _constructLatitude() {
    return GeneratedRealColumn(
      'latitude',
      $tableName,
      false,
    );
  }

  final VerificationMeta _longitudeMeta = const VerificationMeta('longitude');
  GeneratedRealColumn _longitude;
  @override
  GeneratedRealColumn get longitude => _longitude ??= _constructLongitude();
  GeneratedRealColumn _constructLongitude() {
    return GeneratedRealColumn(
      'longitude',
      $tableName,
      false,
    );
  }

  final VerificationMeta _addressMeta = const VerificationMeta('address');
  GeneratedTextColumn _address;
  @override
  GeneratedTextColumn get address => _address ??= _constructAddress();
  GeneratedTextColumn _constructAddress() {
    return GeneratedTextColumn(
      'address',
      $tableName,
      false,
    );
  }

  final VerificationMeta _noteMeta = const VerificationMeta('note');
  GeneratedTextColumn _note;
  @override
  GeneratedTextColumn get note => _note ??= _constructNote();
  GeneratedTextColumn _constructNote() {
    return GeneratedTextColumn(
      'note',
      $tableName,
      false,
    );
  }

  final VerificationMeta _dateMeta = const VerificationMeta('date');
  GeneratedDateTimeColumn _date;
  @override
  GeneratedDateTimeColumn get date => _date ??= _constructDate();
  GeneratedDateTimeColumn _constructDate() {
    return GeneratedDateTimeColumn(
      'date',
      $tableName,
      true,
    );
  }

  final VerificationMeta _sourceImagePathMeta =
      const VerificationMeta('sourceImagePath');
  GeneratedTextColumn _sourceImagePath;
  @override
  GeneratedTextColumn get sourceImagePath =>
      _sourceImagePath ??= _constructSourceImagePath();
  GeneratedTextColumn _constructSourceImagePath() {
    return GeneratedTextColumn(
      'source_image_path',
      $tableName,
      false,
    );
  }

  final VerificationMeta _audioNotePathMeta =
      const VerificationMeta('audioNotePath');
  GeneratedTextColumn _audioNotePath;
  @override
  GeneratedTextColumn get audioNotePath =>
      _audioNotePath ??= _constructAudioNotePath();
  GeneratedTextColumn _constructAudioNotePath() {
    return GeneratedTextColumn(
      'audio_note_path',
      $tableName,
      false,
    );
  }

  final VerificationMeta _topMeta = const VerificationMeta('top');
  GeneratedIntColumn _top;
  @override
  GeneratedIntColumn get top => _top ??= _constructTop();
  GeneratedIntColumn _constructTop() {
    return GeneratedIntColumn(
      'top',
      $tableName,
      false,
    );
  }

  final VerificationMeta _leftMeta = const VerificationMeta('left');
  GeneratedIntColumn _left;
  @override
  GeneratedIntColumn get left => _left ??= _constructLeft();
  GeneratedIntColumn _constructLeft() {
    return GeneratedIntColumn(
      'left',
      $tableName,
      false,
    );
  }

  final VerificationMeta _widthMeta = const VerificationMeta('width');
  GeneratedIntColumn _width;
  @override
  GeneratedIntColumn get width => _width ??= _constructWidth();
  GeneratedIntColumn _constructWidth() {
    return GeneratedIntColumn(
      'width',
      $tableName,
      false,
    );
  }

  final VerificationMeta _heightMeta = const VerificationMeta('height');
  GeneratedIntColumn _height;
  @override
  GeneratedIntColumn get height => _height ??= _constructHeight();
  GeneratedIntColumn _constructHeight() {
    return GeneratedIntColumn(
      'height',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [
        id,
        firstPart,
        secondPart,
        latitude,
        longitude,
        address,
        note,
        date,
        sourceImagePath,
        audioNotePath,
        top,
        left,
        width,
        height
      ];
  @override
  $FoundVrpRecordsTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'found_vrp_records';
  @override
  final String actualTableName = 'found_vrp_records';
  @override
  VerificationContext validateIntegrity(FoundVrpRecordsCompanion d,
      {bool isInserting = false}) {
    final context = VerificationContext();
    if (d.id.present) {
      context.handle(_idMeta, id.isAcceptableValue(d.id.value, _idMeta));
    }
    if (d.firstPart.present) {
      context.handle(_firstPartMeta,
          firstPart.isAcceptableValue(d.firstPart.value, _firstPartMeta));
    } else if (isInserting) {
      context.missing(_firstPartMeta);
    }
    if (d.secondPart.present) {
      context.handle(_secondPartMeta,
          secondPart.isAcceptableValue(d.secondPart.value, _secondPartMeta));
    } else if (isInserting) {
      context.missing(_secondPartMeta);
    }
    if (d.latitude.present) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableValue(d.latitude.value, _latitudeMeta));
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (d.longitude.present) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableValue(d.longitude.value, _longitudeMeta));
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (d.address.present) {
      context.handle(_addressMeta,
          address.isAcceptableValue(d.address.value, _addressMeta));
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (d.note.present) {
      context.handle(
          _noteMeta, note.isAcceptableValue(d.note.value, _noteMeta));
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (d.date.present) {
      context.handle(
          _dateMeta, date.isAcceptableValue(d.date.value, _dateMeta));
    }
    if (d.sourceImagePath.present) {
      context.handle(
          _sourceImagePathMeta,
          sourceImagePath.isAcceptableValue(
              d.sourceImagePath.value, _sourceImagePathMeta));
    } else if (isInserting) {
      context.missing(_sourceImagePathMeta);
    }
    if (d.audioNotePath.present) {
      context.handle(
          _audioNotePathMeta,
          audioNotePath.isAcceptableValue(
              d.audioNotePath.value, _audioNotePathMeta));
    } else if (isInserting) {
      context.missing(_audioNotePathMeta);
    }
    if (d.top.present) {
      context.handle(_topMeta, top.isAcceptableValue(d.top.value, _topMeta));
    } else if (isInserting) {
      context.missing(_topMeta);
    }
    if (d.left.present) {
      context.handle(
          _leftMeta, left.isAcceptableValue(d.left.value, _leftMeta));
    } else if (isInserting) {
      context.missing(_leftMeta);
    }
    if (d.width.present) {
      context.handle(
          _widthMeta, width.isAcceptableValue(d.width.value, _widthMeta));
    } else if (isInserting) {
      context.missing(_widthMeta);
    }
    if (d.height.present) {
      context.handle(
          _heightMeta, height.isAcceptableValue(d.height.value, _heightMeta));
    } else if (isInserting) {
      context.missing(_heightMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FoundVrpRecord map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return FoundVrpRecord.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  Map<String, Variable> entityToSql(FoundVrpRecordsCompanion d) {
    final map = <String, Variable>{};
    if (d.id.present) {
      map['id'] = Variable<int, IntType>(d.id.value);
    }
    if (d.firstPart.present) {
      map['first_part'] = Variable<String, StringType>(d.firstPart.value);
    }
    if (d.secondPart.present) {
      map['second_part'] = Variable<String, StringType>(d.secondPart.value);
    }
    if (d.latitude.present) {
      map['latitude'] = Variable<double, RealType>(d.latitude.value);
    }
    if (d.longitude.present) {
      map['longitude'] = Variable<double, RealType>(d.longitude.value);
    }
    if (d.address.present) {
      map['address'] = Variable<String, StringType>(d.address.value);
    }
    if (d.note.present) {
      map['note'] = Variable<String, StringType>(d.note.value);
    }
    if (d.date.present) {
      map['date'] = Variable<DateTime, DateTimeType>(d.date.value);
    }
    if (d.sourceImagePath.present) {
      map['source_image_path'] =
          Variable<String, StringType>(d.sourceImagePath.value);
    }
    if (d.audioNotePath.present) {
      map['audio_note_path'] =
          Variable<String, StringType>(d.audioNotePath.value);
    }
    if (d.top.present) {
      map['top'] = Variable<int, IntType>(d.top.value);
    }
    if (d.left.present) {
      map['left'] = Variable<int, IntType>(d.left.value);
    }
    if (d.width.present) {
      map['width'] = Variable<int, IntType>(d.width.value);
    }
    if (d.height.present) {
      map['height'] = Variable<int, IntType>(d.height.value);
    }
    return map;
  }

  @override
  $FoundVrpRecordsTable createAlias(String alias) {
    return $FoundVrpRecordsTable(_db, alias);
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  $FoundVrpRecordsTable _foundVrpRecords;
  $FoundVrpRecordsTable get foundVrpRecords =>
      _foundVrpRecords ??= $FoundVrpRecordsTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [foundVrpRecords];
}
