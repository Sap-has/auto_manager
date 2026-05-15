import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/vehicle.dart';
import '../models/loan_config.dart';

class DatabaseService {
  static Database? _db;

  static final _vehicleStreamController = StreamController<List<Vehicle>>.broadcast();

  static Future<void> initialize() async {
    final path = join(await getDatabasesPath(), 'auto_manager.db');
    _db = await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    _notifyVehicles();
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE vehicles(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        year INTEGER NOT NULL,
        make TEXT NOT NULL,
        model TEXT NOT NULL,
        trim TEXT NOT NULL,
        price REAL,
        engineSize REAL,
        engineConfig TEXT,
        cylinders INTEGER,
        horsepower INTEGER,
        hpRpm INTEGER,
        torque INTEGER,
        torqueRpm INTEGER,
        engineType TEXT,
        motorHp REAL,
        motorTorque REAL,
        towCapacity INTEGER,
        bedSize TEXT,
        payloadCapacity REAL,
        mpgCity REAL,
        mpgHwy REAL,
        mpgCombined REAL,
        gasTankSize REAL,
        numDoors INTEGER,
        numSeats INTEGER,
        drivetrain TEXT,
        vehicleType TEXT,
        zeroToSixty REAL,
        enginePlacement TEXT,
        transmission TEXT,
        notNecessary TEXT DEFAULT ''
      )
    ''');
    await db.execute('''
      CREATE TABLE loan_configs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        vehicleId INTEGER,
        vehicleName TEXT,
        vehiclePrice REAL NOT NULL,
        loanTermMonths INTEGER NOT NULL,
        annualInterestRate REAL NOT NULL,
        downPayment REAL NOT NULL,
        salesTaxRate REAL NOT NULL,
        otherFees REAL NOT NULL
      )
    ''');
  }

  static Future<void> _notifyVehicles() async {
    final vehicles = await getVehicles();
    _vehicleStreamController.add(vehicles);
  }

  static Stream<List<Vehicle>> getVehiclesStream() async* {
    yield await getVehicles();
    yield* _vehicleStreamController.stream;
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 4) {
    await db.execute('ALTER TABLE vehicles ADD COLUMN hpRpmMax INTEGER');
    await db.execute('ALTER TABLE vehicles ADD COLUMN torqueRpmMax INTEGER');
  }
}

  // Vehicles
  static Future<int> insertVehicle(Vehicle vehicle) async {
    final map = Map<String, dynamic>.from(vehicle.toMap())..remove('id');
    _notifyVehicles();
    return await _db!.insert('vehicles', map);
  }

  static Future<void> updateVehicle(Vehicle vehicle) async {
  await _db!.update(
    'vehicles',
    vehicle.toMap()..remove('id'),
    where: 'id = ?',
    whereArgs: [vehicle.id],
  );
  _notifyVehicles();
}

  static Future<List<Vehicle>> getVehicles() async {
    final maps = await _db!.query('vehicles', orderBy: 'year DESC, make ASC');
    return maps.map((e) => Vehicle.fromMap(e)).toList();
  }

  static Future<Vehicle?> getVehicle(int id) async {
    final maps = await _db!.query('vehicles', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Vehicle.fromMap(maps.first);
  }

  static Future<void> deleteVehicle(int id) async {
    await _db!.delete('vehicles', where: 'id = ?', whereArgs: [id]);
    _notifyVehicles();
  }

  // Loan Configs
  static Future<int> insertLoanConfig(LoanConfig config) async {
    final map = Map<String, dynamic>.from(config.toMap())..remove('id');
    return await _db!.insert('loan_configs', map);
  }

  static Future<void> updateLoanConfig(LoanConfig config) async {
    await _db!.update(
      'loan_configs',
      config.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [config.id],
    );
  }

  static Future<List<LoanConfig>> getLoanConfigs() async {
    final maps = await _db!.query('loan_configs', orderBy: 'name ASC');
    return maps.map((e) => LoanConfig.fromMap(e)).toList();
  }

  static Future<void> deleteLoanConfig(int id) async {
    await _db!.delete('loan_configs', where: 'id = ?', whereArgs: [id]);
  }
}