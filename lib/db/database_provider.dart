import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../providers/credential.dart';

class DatabseProvider {
  static const String DATABASE_FILE = "credentials.db";
  static const String TABLE_CREDENTIALS = "credentials";
  static const String COLUMN_ID = "id";
  static const String COLUMN_OWNER = "owner";
  static const String COLUMN_SERVICE = "service";
  static const String COLUMN_CREDENTIAL_DATA = "credential_data";
  static const String COLUMN_PRIORITY = "priority";

  DatabseProvider._();
  static final db = DatabseProvider._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await createDatabase();

    return _database;
  }

  Future<Database> createDatabase() async {
    final dbPath = await getDatabasesPath();

    return await openDatabase(
      join(dbPath, DATABASE_FILE),
      version: 1,
      onCreate: (db, version) async {
        print("Creating Database");
        await db.execute("CREATE TABLE IF NOT EXISTS $TABLE_CREDENTIALS("
            "$COLUMN_ID TEXT PRIMARY KEY,"
            "$COLUMN_OWNER TEXT NOT NULL,"
            "$COLUMN_SERVICE TEXT NOT NULL,"
            "$COLUMN_CREDENTIAL_DATA TEXT,"
            "$COLUMN_PRIORITY INTEGER NOT NULL);");
      },
    );
  }

  Future<List<Credential>> getCredentials() async {
    final db = await database;

    var credentials = await db.query(TABLE_CREDENTIALS,
        columns: [
          COLUMN_ID,
          COLUMN_OWNER,
          COLUMN_SERVICE,
          COLUMN_CREDENTIAL_DATA,
          COLUMN_PRIORITY
        ],
        orderBy: COLUMN_PRIORITY);

    List<Credential> credList = [];
    credentials.forEach((crd) => credList.add(Credential.fromMap(crd)));

    return credList;
  }

  Future<int> countCredentials() async {
    final db = await database;

    return Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT(*) FROM $TABLE_CREDENTIALS"));
  }

  Future<Credential> insertCredential(Credential crd) async {
    final db = await database;
    await db.insert(TABLE_CREDENTIALS, crd.toMap());
    return crd;
  }

  Future<int> updateCredential(String id, Credential crd) async {
    final db = await database;
    return await db.update(TABLE_CREDENTIALS, crd.toMap(),
        where: "$COLUMN_ID = ?", whereArgs: [id]);
  }

  Future<int> deleteCredential(String id) async {
    final db = await database;
    return await db
        .delete(TABLE_CREDENTIALS, where: "$COLUMN_ID = ?", whereArgs: [id]);
  }
}
