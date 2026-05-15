class Vehicle {
  final int? id;
  final int year;
  final String make;
  final String model;
  final String trim;
  final double? price;
  final double? engineSize;
  final String? engineConfig;
  final int? cylinders;
  final int? horsepower;
  final int? hpRpm;
  final int? hpRpmMax;
  final int? torque;
  final int? torqueRpm;
  final int? torqueRpmMax;
  final String? engineType;
  final double? motorHp;
  final double? motorTorque;
  final int? towCapacity;
  final String? bedSize;
  final double? payloadCapacity;
  final double? mpgCity;
  final double? mpgHwy;
  final double? mpgCombined;
  final double? gasTankSize;
  final int? numDoors;
  final int? numSeats;
  final String? drivetrain;
  final String? vehicleType;
  final double? zeroToSixty;
  final String? enginePlacement;
  final String? transmission;
  final Map<String, bool> notNecessary;

  Vehicle({
    this.id,
    required this.year,
    required this.make,
    required this.model,
    required this.trim,
    this.price,
    this.engineSize,
    this.engineConfig,
    this.cylinders,
    this.horsepower,
    this.hpRpm,
    this.hpRpmMax,
    this.torque,
    this.torqueRpm,
    this.torqueRpmMax,
    this.engineType,
    this.motorHp,
    this.motorTorque,
    this.towCapacity,
    this.bedSize,
    this.payloadCapacity,
    this.mpgCity,
    this.mpgHwy,
    this.mpgCombined,
    this.gasTankSize,
    this.numDoors,
    this.numSeats,
    this.drivetrain,
    this.vehicleType,
    this.zeroToSixty,
    this.enginePlacement,
    this.transmission,
    Map<String, bool>? notNecessary,
  }) : notNecessary = notNecessary ?? {};

  String get title => '$year $make $model $trim';

  static const List<String> optionalFields = [
    'engineSize', 'engineConfig', 'cylinders', 'horsepower', 'hpRpm', 'hpRpmMax',
    'torque', 'torqueRpm', 'torqueRpmMax', 'engineType', 'motorHp', 'motorTorque',
    'towCapacity', 'bedSize', 'payloadCapacity', 'mpgCity', 'mpgHwy',
    'mpgCombined', 'gasTankSize', 'numDoors', 'numSeats', 'drivetrain',
    'vehicleType', 'zeroToSixty', 'enginePlacement', 'price', 'transmission',
  ];

  static const Map<String, String> fieldLabels = {
    'engineSize': 'Engine Size (L)',
    'engineConfig': 'Engine Config',
    'cylinders': 'Cylinders',
    'horsepower': 'Horsepower',
    'hpRpm': 'HP @ RPM',
    'hpRpmMax' : 'HP @ RPM Max',
    'torque': 'Torque (lb-ft)',
    'torqueRpm': 'Torque @ RPM',
    'torqueRpmMax': 'Torque @ RPM Max',
    'engineType': 'Engine Type',
    'motorHp': 'Motor HP',
    'motorTorque': 'Motor Torque',
    'towCapacity': 'Tow Capacity (lbs)',
    'bedSize': 'Bed Size',
    'payloadCapacity': 'Payload Capacity (lbs)',
    'mpgCity': 'MPG City',
    'mpgHwy': 'MPG Highway',
    'mpgCombined': 'MPG Combined',
    'gasTankSize': 'Gas Tank (gal)',
    'numDoors': 'Doors',
    'numSeats': 'Seats',
    'drivetrain': 'Drivetrain',
    'vehicleType': 'Vehicle Type',
    'zeroToSixty': '0-60 (sec)',
    'enginePlacement': 'Engine Placement',
    'price': 'Price (MSRP)',
    'transmission': 'Transmission',
  };

  bool isFieldMissing(String field) {
    if (notNecessary[field] == true) return false;
    switch (field) {
      case 'price': return price == null;
      case 'engineSize': return engineSize == null;
      case 'engineConfig': return engineConfig == null;
      case 'cylinders': return cylinders == null;
      case 'horsepower': return horsepower == null;
      case 'hpRpm': return hpRpm == null;
      case 'hpRpmMax': return hpRpmMax == null;
      case 'torque': return torque == null;
      case 'torqueRpm': return torqueRpm == null;
      case 'torqueRpmMax': return torqueRpmMax == null;
      case 'engineType': return engineType == null;
      case 'motorHp': return motorHp == null;
      case 'motorTorque': return motorTorque == null;
      case 'towCapacity': return towCapacity == null;
      case 'bedSize': return bedSize == null;
      case 'payloadCapacity': return payloadCapacity == null;
      case 'mpgCity': return mpgCity == null;
      case 'mpgHwy': return mpgHwy == null;
      case 'mpgCombined': return mpgCombined == null;
      case 'gasTankSize': return gasTankSize == null;
      case 'numDoors': return numDoors == null;
      case 'numSeats': return numSeats == null;
      case 'drivetrain': return drivetrain == null;
      case 'vehicleType': return vehicleType == null;
      case 'zeroToSixty': return zeroToSixty == null;
      case 'enginePlacement': return enginePlacement == null;
      case 'transmission': return transmission == null;
      default: return false;
    }
  }

  int get missingFieldCount =>
      optionalFields.where((f) => isFieldMissing(f)).length;

  bool get isComplete => missingFieldCount == 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'year': year,
      'make': make,
      'model': model,
      'trim': trim,
      'price': price,
      'engineSize': engineSize,
      'engineConfig': engineConfig,
      'cylinders': cylinders,
      'horsepower': horsepower,
      'hpRpm': hpRpm,
      'hpRpmMax': hpRpmMax,
      'torque': torque,
      'torqueRpm': torqueRpm,
      'torqueRpmMax': torqueRpmMax,
      'engineType': engineType,
      'motorHp': motorHp,
      'motorTorque': motorTorque,
      'towCapacity': towCapacity,
      'bedSize': bedSize,
      'payloadCapacity': payloadCapacity,
      'mpgCity': mpgCity,
      'mpgHwy': mpgHwy,
      'mpgCombined': mpgCombined,
      'gasTankSize': gasTankSize,
      'numDoors': numDoors,
      'numSeats': numSeats,
      'drivetrain': drivetrain,
      'vehicleType': vehicleType,
      'zeroToSixty': zeroToSixty,
      'enginePlacement': enginePlacement,
      'transmission': transmission,
      'notNecessary': notNecessary.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .join(','),
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    final nnRaw = (map['notNecessary'] as String?) ?? '';
    final nn = <String, bool>{};
    if (nnRaw.isNotEmpty) {
      for (final k in nnRaw.split(',')) {
        nn[k] = true;
      }
    }
    return Vehicle(
      id: map['id'],
      year: map['year'],
      make: map['make'],
      model: map['model'],
      trim: map['trim'],
      price: map['price'],
      engineSize: map['engineSize'],
      engineConfig: map['engineConfig'],
      cylinders: map['cylinders'],
      horsepower: map['horsepower'],
      hpRpm: map['hpRpm'],
      hpRpmMax: map['hpRpmMax'],
      torque: map['torque'],
      torqueRpm: map['torqueRpm'],
      torqueRpmMax: map['torqueRpmMax'],
      engineType: map['engineType'],
      motorHp: map['motorHp'],
      motorTorque: map['motorTorque'],
      towCapacity: map['towCapacity'],
      bedSize: map['bedSize'],
      payloadCapacity: map['payloadCapacity'],
      mpgCity: map['mpgCity'],
      mpgHwy: map['mpgHwy'],
      mpgCombined: map['mpgCombined'],
      gasTankSize: map['gasTankSize'],
      numDoors: map['numDoors'],
      numSeats: map['numSeats'],
      drivetrain: map['drivetrain'],
      vehicleType: map['vehicleType'],
      zeroToSixty: map['zeroToSixty'],
      enginePlacement: map['enginePlacement'],
      transmission: map['transmission'],
      notNecessary: nn,
    );
  }

  Vehicle copyWith({
    int? id,
    int? year,
    String? make,
    String? model,
    String? trim,
    double? price,
    double? engineSize,
    String? engineConfig,
    int? cylinders,
    int? horsepower,
    int? hpRpm,
    int? hpRpmMax,
    int? torque,
    int? torqueRpm,
    int? torqueRpmMax,
    String? engineType,
    double? motorHp,
    double? motorTorque,
    int? towCapacity,
    String? bedSize,
    double? payloadCapacity,
    double? mpgCity,
    double? mpgHwy,
    double? mpgCombined,
    double? gasTankSize,
    int? numDoors,
    int? numSeats,
    String? drivetrain,
    String? vehicleType,
    double? zeroToSixty,
    String? enginePlacement,
    String? transmission,
    Map<String, bool>? notNecessary,
  }) {
    return Vehicle(
      id: id ?? this.id,
      year: year ?? this.year,
      make: make ?? this.make,
      model: model ?? this.model,
      trim: trim ?? this.trim,
      price: price ?? this.price,
      engineSize: engineSize ?? this.engineSize,
      engineConfig: engineConfig ?? this.engineConfig,
      cylinders: cylinders ?? this.cylinders,
      horsepower: horsepower ?? this.horsepower,
      hpRpm: hpRpm ?? this.hpRpm,
      hpRpmMax: hpRpmMax ?? this.hpRpmMax,
      torque: torque ?? this.torque,
      torqueRpm: torqueRpm ?? this.torqueRpm,
      torqueRpmMax: torqueRpmMax ?? this.torqueRpmMax,
      engineType: engineType ?? this.engineType,
      motorHp: motorHp ?? this.motorHp,
      motorTorque: motorTorque ?? this.motorTorque,
      towCapacity: towCapacity ?? this.towCapacity,
      bedSize: bedSize ?? this.bedSize,
      payloadCapacity: payloadCapacity ?? this.payloadCapacity,
      mpgCity: mpgCity ?? this.mpgCity,
      mpgHwy: mpgHwy ?? this.mpgHwy,
      mpgCombined: mpgCombined ?? this.mpgCombined,
      gasTankSize: gasTankSize ?? this.gasTankSize,
      numDoors: numDoors ?? this.numDoors,
      numSeats: numSeats ?? this.numSeats,
      drivetrain: drivetrain ?? this.drivetrain,
      vehicleType: vehicleType ?? this.vehicleType,
      zeroToSixty: zeroToSixty ?? this.zeroToSixty,
      enginePlacement: enginePlacement ?? this.enginePlacement,
      transmission: transmission ?? this.transmission,
      notNecessary: notNecessary ?? Map.from(this.notNecessary),
    );
  }
}