import 'dart:io';

import 'package:moor_ffi/moor_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:moor/moor.dart';

part 'database.g.dart';

class FoundVrpRecords extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get firstPart => text()();

  TextColumn get secondPart => text()();

  RealColumn get latitude => real()();

  RealColumn get longitude => real()();

  TextColumn get address => text()();

  DateTimeColumn get date => dateTime().nullable()();

  TextColumn get sourceImagePath => text()();
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
  Database()
      : super(_openConnection());

  @override
  int get schemaVersion => 1;


}