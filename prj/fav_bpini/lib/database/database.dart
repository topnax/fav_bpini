import 'dart:io';

import 'package:moor/moor.dart' ;
import 'package:moor_ffi/moor_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class FoundVrpRecords extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get firstPart => text()();

  TextColumn get secondPart => text()();

  RealColumn get latitude => real()();

  RealColumn get longitude => real()();

  TextColumn get address => text()();

  TextColumn get note => text()();

  DateTimeColumn get date => dateTime().nullable()();

  TextColumn get sourceImagePath => text()();

  TextColumn get audioNotePath => text()();

  IntColumn get top => integer()();

  IntColumn get left => integer()();

  IntColumn get width => integer()();

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
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
      onCreate: (Migrator m) {
        return m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from == 3) {
          await m.addColumn(foundVrpRecords, foundVrpRecords.note);
        } else if (from == 4) {
          await m.addColumn(foundVrpRecords, foundVrpRecords.audioNotePath);
        }
      }
  );

  Future addVrpRecord(FoundVrpRecordsCompanion entry) {
    return into(foundVrpRecords).insert(entry);
  }


  /// Updates the row in the database represents this entry by writing the
  /// updated data.
  Future updateEntry(FoundVrpRecord entry) {
    return update(foundVrpRecords).replace(entry);
  }

  Future deleteEntry(FoundVrpRecord entry) {
    return delete(foundVrpRecords).delete(entry);
  }



  Stream<List<FoundVrpRecord>> watchAllRecords() => select(foundVrpRecords).watch();


}
