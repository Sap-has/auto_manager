import 'package:flutter/material.dart';
import '../models/vehicle.dart';

class VehicleCompareScreen extends StatelessWidget {
  final List<Vehicle> vehicles;
  const VehicleCompareScreen({super.key, required this.vehicles});

  static const _rows = [
    ('price', 'Price (MSRP)'),
    ('vehicleType', 'Type'),
    ('drivetrain', 'Drivetrain'),
    ('numDoors', 'Doors'),
    ('numSeats', 'Seats'),
    ('engineType', 'Engine Type'),
    ('engineConfig', 'Config'),
    ('engineSize', 'Engine Size'),
    ('cylinders', 'Cylinders'),
    ('horsepower', 'Horsepower'),
    ('hpRpm', 'HP @ RPM'),
    ('torque', 'Torque'),
    ('torqueRpm', 'Torque @ RPM'),
    ('motorHp', 'Motor HP'),
    ('motorTorque', 'Motor Torque'),
    ('zeroToSixty', '0-60 (sec)'),
    ('mpgCity', 'MPG City'),
    ('mpgHwy', 'MPG Hwy'),
    ('mpgCombined', 'MPG Combined'),
    ('gasTankSize', 'Gas Tank (gal)'),
    ('towCapacity', 'Tow Capacity'),
    ('payloadCapacity', 'Payload'),
    ('bedSize', 'Bed Size'),
    ('enginePlacement', 'Engine Placement'),
  ];

  String _val(Vehicle v, String field) {
    switch (field) {
      case 'price': return v.price != null ? '\$${v.price!.toStringAsFixed(0)}' : '—';
      case 'vehicleType': return v.vehicleType ?? '—';
      case 'drivetrain': return v.drivetrain ?? '—';
      case 'numDoors': return v.numDoors?.toString() ?? '—';
      case 'numSeats': return v.numSeats?.toString() ?? '—';
      case 'engineType': return v.engineType ?? '—';
      case 'engineConfig': return v.engineConfig ?? '—';
      case 'engineSize': return v.engineSize != null ? '${v.engineSize}L' : '—';
      case 'cylinders': return v.cylinders?.toString() ?? '—';
      case 'horsepower': return v.horsepower != null ? '${v.horsepower} hp' : '—';
      case 'hpRpm':
        final val = v.hpRpmMax != null ? '${v.hpRpm}-${v.hpRpmMax}' : '${v.hpRpm}';
        return v.hpRpm != null ? '$val rpm' : '—';
      case 'torque': return v.torque != null ? '${v.torque} lb-ft' : '—';
      case 'torqueRpm':
        final val = v.torqueRpmMax != null ? '${v.torqueRpm}-${v.torqueRpmMax}' : '${v.torqueRpm}';
        return v.torqueRpm != null ? '$val rpm' : '—';
      case 'motorHp': return v.motorHp != null ? '${v.motorHp} hp' : '—';
      case 'motorTorque': return v.motorTorque != null ? '${v.motorTorque} lb-ft' : '—';
      case 'zeroToSixty': return v.zeroToSixty != null ? '${v.zeroToSixty}s' : '—';
      case 'mpgCity': return v.mpgCity?.toString() ?? '—';
      case 'mpgHwy': return v.mpgHwy?.toString() ?? '—';
      case 'mpgCombined': return v.mpgCombined?.toString() ?? '—';
      case 'gasTankSize': return v.gasTankSize?.toString() ?? '—';
      case 'towCapacity': return v.towCapacity != null ? '${v.towCapacity} lbs' : '—';
      case 'payloadCapacity': return v.payloadCapacity != null ? '${v.payloadCapacity} lbs' : '—';
      case 'bedSize': return v.bedSize ?? '—';
      case 'enginePlacement': return v.enginePlacement ?? '—';
      default: return '—';
    }
  }

  // Returns index of "best" vehicle for numeric fields (higher = better, except 0-60)
  int? _bestIndex(String field) {
    final numeric = <String, bool Function(double, double)>{
      'price': (a, b) => a < b,
      'horsepower': (a, b) => a > b,
      'torque': (a, b) => a > b,
      'motorHp': (a, b) => a > b,
      'motorTorque': (a, b) => a > b,
      'zeroToSixty': (a, b) => a < b,
      'mpgCity': (a, b) => a > b,
      'mpgHwy': (a, b) => a > b,
      'mpgCombined': (a, b) => a > b,
      'towCapacity': (a, b) => a > b,
      'payloadCapacity': (a, b) => a > b,
    };
    if (!numeric.containsKey(field)) return null;
    final isBetter = numeric[field]!;
    double? best;
    int? bestIdx;
    for (int i = 0; i < vehicles.length; i++) {
      final raw = _rawNum(vehicles[i], field);
      if (raw != null) {
        if (best == null || isBetter(raw, best)) {
          best = raw;
          bestIdx = i;
        }
      }
    }
    return bestIdx;
  }

  double? _rawNum(Vehicle v, String field) {
    switch (field) {
      case 'price': return v.price;
      case 'horsepower': return v.horsepower?.toDouble();
      case 'torque': return v.torque?.toDouble();
      case 'motorHp': return v.motorHp;
      case 'motorTorque': return v.motorTorque;
      case 'zeroToSixty': return v.zeroToSixty;
      case 'mpgCity': return v.mpgCity;
      case 'mpgHwy': return v.mpgHwy;
      case 'mpgCombined': return v.mpgCombined;
      case 'towCapacity': return v.towCapacity?.toDouble();
      case 'payloadCapacity': return v.payloadCapacity;
      default: return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compare Vehicles')),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 24,
            columns: [
              const DataColumn(label: Text('Spec')),
              ...vehicles.map((v) => DataColumn(
                    label: SizedBox(
                      width: 120,
                      child: Text(v.title, overflow: TextOverflow.ellipsis),
                    ),
                  )),
            ],
            rows: [
              for (final (field, label) in _rows)
                DataRow(
                  cells: [
                    DataCell(Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
                    ...vehicles.asMap().entries.map((entry) {
                      final i = entry.key;
                      final v = entry.value;
                      final best = _bestIndex(field);
                      final isWinner = best == i && vehicles.length > 1 &&
                          _rawNum(v, field) != null;
                      return DataCell(
                        Container(
                          padding: isWinner
                              ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
                              : null,
                          decoration: isWinner
                              ? BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                      .withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(4),
                                )
                              : null,
                          child: Text(_val(v, field)),
                        ),
                      );
                    }),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}