import 'dart:io';

import 'package:favbpini/model/vrp.dart';
import 'package:flutter/foundation.dart';
import 'package:moor/moor.dart';
import 'package:moor_ffi/moor_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class FoundVrpRecords extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// The first part of the VRP identifier
  TextColumn get firstPart => text()();

  /// The second part of the VRP identifier
  TextColumn get secondPart => text()();

  /// The type of the VRP, where value 0=ONE_LINE_CLASSIC, 1=ONE_LINE_OLD, 2=ONE_LINE_VIP, 3=TWO_LINE_BIKE, 4=TWO_LINE_OTHER.
  IntColumn get type => integer().withDefault(const Constant(0))();

  /// The latitude of the location at which the VRP was scanned.
  RealColumn get latitude => real()();

  /// The longitude of the location at which the VRP was scanned.
  RealColumn get longitude => real()();

  /// The address of the location at which the VRP was scanned.
  TextColumn get address => text()();

  /// The note the user added to the VRP.
  TextColumn get note => text()();

  /// The date the VRP was scanned.
  DateTimeColumn get date => dateTime().nullable()();

  /// The path to the file containing the image from in which the VRP was recognized.
  TextColumn get sourceImagePath => text()();

  /// The path to the audio file containing the audio note.
  TextColumn get audioNotePath => text()();

  // The vertical coordinate of the top left corner of the rectangle containing the VRP in the source image.
  IntColumn get top => integer()();

  // The horizontal coordinate of the top left corner of the rectangle containing the VRP in the source image.
  IntColumn get left => integer()();

  // The width of the rectangle containing the VRP in the source image.
  IntColumn get width => integer()();

  // The height of the rectangle containing the VRP in the source image.
  IntColumn get height => integer()();
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return VmDatabase(file);
  });
}

@UseMoor(tables: [FoundVrpRecords])
class Database extends _$Database {
  Database() : super(_openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(onCreate: (Migrator m) {
        return m.createAll();
      }, onUpgrade: (Migrator m, int from, int to) async {
        if (to == 6) {
          await m.addColumn(foundVrpRecords, foundVrpRecords.type);
        } else {
          if (from == 3) {
            await m.addColumn(foundVrpRecords, foundVrpRecords.note);
          } else if (from == 4) {
            await m.addColumn(foundVrpRecords, foundVrpRecords.audioNotePath);
          }
        }
      });

  Future addVrpRecord(FoundVrpRecordsCompanion entry) {
    return into(foundVrpRecords).insert(entry);
  }

  Future updateEntry(FoundVrpRecord entry) {
    return update(foundVrpRecords).replace(entry);
  }

  Future deleteEntry(FoundVrpRecord entry) {
    return delete(foundVrpRecords).delete(entry);
  }

  Stream<List<FoundVrpRecord>> watchAllRecords({VRPType type, @required bool sortByNewest}) {
    if (type != null) {
      return (select(foundVrpRecords)
            ..where((t) => t.type.equals(type.index))
            ..orderBy(
                [(t) => OrderingTerm(expression: t.date, mode: sortByNewest ? OrderingMode.desc : OrderingMode.asc)]))
          .watch();
    } else {
      return (select(foundVrpRecords)
            ..orderBy(
                [(t) => OrderingTerm(expression: t.date, mode: sortByNewest ? OrderingMode.desc : OrderingMode.asc)]))
          .watch();
    }
  }
}
