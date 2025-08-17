import 'package:movie_watchlist/model/moviemodel.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Dbhelper {
  Dbhelper.privateconstructor();
  static final Dbhelper instance = Dbhelper.privateconstructor();
  static Database? _db;
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initdb();
    return _db!;
  }

  Future<Database> initdb() async {
    final path = join(await getDatabasesPath(), 'movies.db');
    return openDatabase(path, version: 1, onCreate: _createdb);
  }

  Future _createdb(Database db, int version) async {
    await db.execute('''
     CREATE TABLE movies(
     id INTEGER PRIMARY KEY AUTOINCREMENT,
     title TEXT NOT NULL,
     category TEXT,
     year INTEGER,
     poster TEXT,
     watched INTEGER DEFAULT 0,
     ratings REAL DEFAULT 0,
     notes TEXT
     )
     
     ''');
  }

  Future<int> insertMovie(Moviemodel movie) async {
    final db = await database;
    return await db.insert('movies', movie.toMap());
  }

  Future<List<Moviemodel>> getmovies() async {
    final db = await database;
    final result = await db.query('movies', orderBy: 'year DESC');
    return result.map((e) => Moviemodel.fromMap(e)).toList();
  }

  Future<int> updatemovie(Moviemodel movie) async {
    final db = await database;
    return await db.update(
      'movies',
      movie.toMap(),
      where: 'id=?',
      whereArgs: [movie.id],
    );
  }

  Future<int> deletemovie(int id) async {
    final db = await database;
    return await db.delete('movies', where: 'id=?', whereArgs: [id]);
  }
}
