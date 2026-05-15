import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/database_service.dart';
import 'vehicle_form_screen.dart';

class VehicleDetailScreen extends StatefulWidget {
  final Vehicle vehicle;
  const VehicleDetailScreen({super.key, required this.vehicle});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  late Vehicle _vehicle;

  @override
  void initState() {
    super.initState();
    _vehicle = widget.vehicle;
  }

  Future<void> _reload() async {
    final v = await DatabaseService.getVehicle(_vehicle.id!);
    if (v != null) setState(() => _vehicle = v);
  }

  Future<void> _toggleNotNecessary(String field) async {
    final nn = Map<String, bool>.from(_vehicle.notNecessary);
    if (nn[field] == true) {
      nn.remove(field);
    } else {
      nn[field] = true;
    }
    final updated = _vehicle.copyWith(notNecessary: nn);
    await DatabaseService.updateVehicle(updated);
    setState(() => _vehicle = updated);
  }

  @override
  Widget build(BuildContext context) {
    final missing = _vehicle.missingFieldCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(_vehicle.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => VehicleFormScreen(vehicle: _vehicle)),
              );
              _reload();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (missing > 0)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$missing field${missing == 1 ? '' : 's'} missing. '
                      'Tap the "N/A" button next to a field to mark it as not necessary.',
                      style: const TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          _section('Basic Info', context),
          _row('Year', _vehicle.year.toString(), null),
          _row('Make', _vehicle.make, null),
          _row('Model', _vehicle.model, null),
          _row('Trim', _vehicle.trim, null),
          _fieldRow('price', 'Price (MSRP)', _vehicle.price != null ? '\$${_vehicle.price!.toStringAsFixed(0)}' : null),

          _section('Vehicle Info', context),
          _fieldRow('vehicleType', 'Vehicle Type', _vehicle.vehicleType),
          _fieldRow('drivetrain', 'Drivetrain', _vehicle.drivetrain),
          _fieldRow('numDoors', 'Doors', _vehicle.numDoors?.toString()),
          _fieldRow('numSeats', 'Seats', _vehicle.numSeats?.toString()),

          _section('Engine', context),
          _fieldRow('engineType', 'Engine Type', _vehicle.engineType),
          _fieldRow('engineConfig', 'Config', _vehicle.engineConfig),
          _fieldRow('enginePlacement', 'Placement', _vehicle.enginePlacement),
          _fieldRow('engineSize', 'Engine Size', _vehicle.engineSize != null ? '${_vehicle.engineSize}L' : null),
          _fieldRow('cylinders', 'Cylinders', _vehicle.cylinders?.toString()),
          _fieldRow('horsepower', 'Horsepower', _vehicle.horsepower != null ? '${_vehicle.horsepower} hp' : null),
          _fieldRow('hpRpm', 'HP @ RPM', _formatRpm(_vehicle.hpRpm, _vehicle.hpRpmMax)),
          _fieldRow('torque', 'Torque', _vehicle.torque != null ? '${_vehicle.torque} lb-ft' : null),
          _fieldRow('torqueRpm', 'Torque @ RPM', _formatRpm(_vehicle.torqueRpm, _vehicle.torqueRpmMax)),

          _section('Electric Motor', context),
          _fieldRow('motorHp', 'Motor HP', _vehicle.motorHp != null ? '${_vehicle.motorHp} hp' : null),
          _fieldRow('motorTorque', 'Motor Torque', _vehicle.motorTorque != null ? '${_vehicle.motorTorque} lb-ft' : null),
          
          _section('Performance & Fuel', context),
          _fieldRow('zeroToSixty', '0-60 mph', _vehicle.zeroToSixty != null ? '${_vehicle.zeroToSixty}s' : null),
          _fieldRow('mpgCity', 'MPG City', _vehicle.mpgCity?.toString()),
          _fieldRow('mpgHwy', 'MPG Highway', _vehicle.mpgHwy?.toString()),
          _fieldRow('mpgCombined', 'MPG Combined', _vehicle.mpgCombined?.toString()),
          _fieldRow('gasTankSize', 'Gas Tank', _vehicle.gasTankSize != null ? '${_vehicle.gasTankSize} gal' : null),

          _section('Truck / Towing', context),
          _fieldRow('towCapacity', 'Tow Capacity', _vehicle.towCapacity != null ? '${_vehicle.towCapacity} lbs' : null),
          _fieldRow('payloadCapacity', 'Payload Capacity', _vehicle.payloadCapacity != null ? '${_vehicle.payloadCapacity} lbs' : null),
          _fieldRow('bedSize', 'Bed Size', _vehicle.bedSize),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _section(String title, BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Text(title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                )),
      );

  Widget _row(String label, String? value, String? _) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 160, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value ?? '—')),
        ],
      ),
    );
  }

  Widget _fieldRow(String field, String label, String? value) {
    final isNN = _vehicle.notNecessary[field] == true;
    final isMissing = _vehicle.isFieldMissing(field);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(label,
                style: TextStyle(color: isMissing ? Colors.orange : Colors.grey)),
          ),
          Expanded(
            child: Text(
              isNN ? 'N/A' : (value ?? '—'),
              style: TextStyle(
                color: isNN
                    ? Colors.grey
                    : isMissing
                        ? Colors.orange
                        : null,
                fontStyle: isNN ? FontStyle.italic : null,
              ),
            ),
          ),
          if (isMissing || isNN)
            TextButton(
              onPressed: () => _toggleNotNecessary(field),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(isNN ? 'Undo N/A' : 'Mark N/A',
                  style: const TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }
  
  String? _formatRpm(int? min, int? max) {
    if (min == null && max == null) return '—';
    if (min != null && max != null) return '$min - $max rpm';
    return '${min ?? max} rpm';
  }
}