import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'urls_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE urls_app(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        original_url TEXT,
        shortened_url TEXT
      )
    ''');
  }

  Future<int> insertUrl(String originalUrl, String shortenedUrl) async {
    Database db = await database;
    return await db.insert(
      'urls_app',
      {
        'original_url': originalUrl,
        'shortened_url': shortenedUrl,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getUrls() async {
    Database db = await database;
    return await db.query('urls_app');
  }

  Future<Response> deleteUrl(int id) async {
    Database db = await database;

    try {
      int result = await db.delete(
        'urls_app',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (result > 0) {
        return Response(ResponseDbEnum.success);
      } else {
        return Response(ResponseDbEnum.warning);
      }
    } catch (e) {
      return Response(ResponseDbEnum.error);
    }
  }

  Future<bool> checkUrlExists(String originalUrl) async {
    final db = await database;
    final result = await db.query(
      'urls_app',
      where: 'original_url = ?',
      whereArgs: [originalUrl],
    );
    return result.isNotEmpty;
  }

  Future<void> printAllUrls() async {
    Database db = await database;
    List<Map<String, dynamic>> urls = await db.query('urls_app');

    if (urls.isEmpty) {
      print("No data in the database.");
    } else {
      for (var url in urls) {
        print(
            'ID: ${url['id']}, Original URL: ${url['original_url']}, Shortened URL: ${url['shortened_url']}');
      }
    }
  }
}

class Response {
  Response(this.responseStatus);
  ResponseDbEnum? responseStatus;
}

enum ResponseDbEnum { error, success, warning }
