import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/medication.dart';
import '../models/patient.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'alertamed.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE medications (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        name     TEXT NOT NULL,
        dosage   TEXT NOT NULL,
        schedule TEXT NOT NULL,
        notes    TEXT NOT NULL DEFAULT ''
      )
    ''');
    await _createPatientTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createPatientTable(db);
    }
  }

  Future<void> _createPatientTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS patient (
        id                INTEGER PRIMARY KEY,
        name              TEXT NOT NULL,
        age               INTEGER NOT NULL,
        blood_type        TEXT,
        allergies         TEXT,
        emergency_contact TEXT,
        caregiver_name    TEXT,
        caregiver_phone   TEXT,
        notes             TEXT
      )
    ''');
  }

  // --- Medications ---

  Future<int> insertMedication(Medication medication) async {
    final db = await database;
    return db.insert('medications', medication.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Medication>> getMedications() async {
    final db = await database;
    final maps = await db.query('medications', orderBy: 'name ASC');
    return maps.map(Medication.fromMap).toList();
  }

  Future<int> deleteMedication(int id) async {
    final db = await database;
    return db.delete('medications', where: 'id = ?', whereArgs: [id]);
  }

  // --- Patient (single record, id always = 1) ---

  Future<Patient?> getPatient() async {
    final db = await database;
    final maps = await db.query('patient', where: 'id = ?', whereArgs: [1]);
    if (maps.isEmpty) return null;
    return Patient.fromMap(maps.first);
  }

  Future<void> savePatient(Patient patient) async {
    final db = await database;
    final map = patient.toMap()..['id'] = 1;
    await db.insert('patient', map,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
