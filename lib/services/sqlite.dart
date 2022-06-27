import "dart:io" as io;
import "package:path/path.dart";
import 'package:pizarro_app/models/gps_data.dart';
import 'package:pizarro_app/models/track.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class SqliteDB {
  static final SqliteDB _instance = new SqliteDB.internal();

  static const String columnIdType = "INTEGER PRIMARY KEY AUTOINCREMENT";
  static const String dateTimeType = "DATETIME";
  static const String integerType = "INTEGER";
  static const String doubleType = "DOUBLE";

  factory SqliteDB() => _instance;
  static Database? _db;

  SqliteDB.internal();

  Future<Database?> get db async {
    try {
      if (_db != null) {
        return _db;
      }
      _db = await initDb();
      return _db;
    } catch (e) {
      print(e);
    }
  }

  /// Initialize DB
  initDb() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    print(documentDirectory);
    String path = join(documentDirectory.path, "webike.db");
    var taskDb =
        await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE ${TrackFields.trackTable} (${TrackFields.columnId} $columnIdType, ${TrackFields.columnTrackCreated} $dateTimeType)');
      await db.execute(
        'CREATE TABLE ${GpsDataFields.gpsDataTable} (${GpsDataFields.columnId} $columnIdType, ${GpsDataFields.columnTrackId} $integerType, ${GpsDataFields.columnLatitude} $doubleType, ${GpsDataFields.columnLongitude} $doubleType, ${GpsDataFields.columnAltitude} $doubleType, ${GpsDataFields.columnSpeed} $doubleType, ${GpsDataFields.columnSpeedAccuracy} $doubleType, ${GpsDataFields.columnHeading} $doubleType, ${GpsDataFields.columnAccuracy} $doubleType, ${GpsDataFields.columnTimestamp} $dateTimeType)',
      );
    }, onUpgrade: (db, oldVersion, newVersion) async {
      await db.execute('DROP TABLE IF EXISTS gps_master');
      await db.execute('DROP TABLE IF EXISTS gps_detail');
      await db.execute(
          'CREATE TABLE ${TrackFields.trackTable} (${TrackFields.columnId} $columnIdType, ${TrackFields.columnTrackCreated} $dateTimeType)');
      await db.execute(
        'CREATE TABLE ${GpsDataFields.gpsDataTable} (${GpsDataFields.columnId} $columnIdType, ${GpsDataFields.columnTrackId} $integerType, ${GpsDataFields.columnLatitude} $doubleType, ${GpsDataFields.columnLongitude} $doubleType, ${GpsDataFields.columnAltitude} $doubleType, ${GpsDataFields.columnSpeed} $doubleType, ${GpsDataFields.columnSpeedAccuracy} $doubleType, ${GpsDataFields.columnHeading} $doubleType, ${GpsDataFields.columnAccuracy} $doubleType, ${GpsDataFields.columnTimestamp} $dateTimeType)',
      );
    });
    return taskDb;
  }

  Future addGpsData(int trackId, GpsData data) async {
    var dbClient = await db;
    await dbClient!.insert(GpsDataFields.gpsDataTable, data.toJson());
  }

  Future<List<GpsData>> getGpsData(int trackId) async {
    var dbClient = await db;
    final result = await dbClient!.query(GpsDataFields.gpsDataTable,
        where: "${GpsDataFields.columnTrackId} = ?", whereArgs: [trackId]);
    return result.map((cursor) => GpsData.fromJson(cursor)).toList();
  }

  Future<int> addTrack() async {
    var dbClient = await db;
    var dateTime = DateTime.now();
    //add gps track
    int lastInsertedId = await dbClient!.rawInsert(
        'INSERT INTO ${TrackFields.trackTable} (${TrackFields.columnTrackCreated}) VALUES (?)',
        [dateTime.toIso8601String()]);
    return lastInsertedId;
  }

  Future<List<Track>> getTracks() async {
    var dbClient = await db;
    final result = await dbClient!
        .query(TrackFields.trackTable, columns: TrackFields.values);

    return result.map((track) => Track.fromJson(track)).toList();
  }

  Future close() async {
    final db = await _instance.db;
    db!.close();
  }

  // Count number of tables in DB
  Future countTable() async {
    var dbClient = await db;
    var res = await dbClient!.rawQuery("""SELECT * FROM track;""");
    return res[0]['count'];
  }
}

class GpsDataFields {
  final List<String> values = [columnId];

  static const String gpsDataTable = "gps_data";

  static const String columnId = "_id";

  static const String columnTrackId = "track_id";

  static const String columnLatitude = "latitude";
  static const String columnLongitude = "longitude";
  static const String columnAltitude = "altitude";
  static const String columnSpeed = "speed";
  static const String columnSpeedAccuracy = "speed_accuracy";
  static const String columnHeading = "heading";
  static const String columnAccuracy = "accuracy";
  static const String columnTimestamp = "timestamp";
  static const String columnCreated = "created";
}

class TrackFields {
  static final List<String> values = [columnId, columnTrackCreated];
  static const String trackTable = "track";
  static const String columnId = "_id";
  static const String columnTrackCreated = "created";
}
