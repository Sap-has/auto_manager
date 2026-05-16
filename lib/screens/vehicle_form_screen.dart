import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/database_service.dart';

class VehicleFormScreen extends StatefulWidget {
  final Vehicle? vehicle;
  const VehicleFormScreen({super.key, this.vehicle});

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, TextEditingController> _ctrl;
  late Map<String, bool> _notNecessary;

  static const _drivetrains = ['FWD', 'RWD', 'AWD', '4WD'];
  static const _engineTypes = ['Standard', 'Turbo', 'Hybrid', 'Plug-in Hybrid', 'Electric'];
  static const _engineConfigs = ['Inline', 'V', 'Flat', 'Rotary', 'Electric Motor'];
  static const _enginePlacements = ['Front', 'Mid', 'Rear'];
  static const _vehicleTypes = [
    'Sedan', 'Coupe', 'Hatchback', 'Wagon', 'Convertible',
    'Subcompact SUV', 'Compact SUV', 'Midsize SUV', 'Full Size SUV',
    'Compact Truck', 'Midsize Truck', 'Full Size Truck', 'Heavy Duty Truck',
    'Minivan', 'Van', 'Sports Car', 'Muscle Car', 'Supercar', 'Other',
  ];
  static const _transmissions = ['Automatic', 'Manual', 'CVT', 'Dual-Clutch'];

  String? _drivetrain;
  String? _engineType;
  String? _engineConfig;
  String? _enginePlacement;
  String? _vehicleType;
  String? _transmission;
  bool _isNew = true;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    _notNecessary = Map.from(v?.notNecessary ?? {});
    _drivetrain = v?.drivetrain;
    _engineType = v?.engineType;
    _engineConfig = v?.engineConfig;
    _enginePlacement = v?.enginePlacement;
    _vehicleType = v?.vehicleType;
    _transmission = v?.transmission;
    _isNew = v?.isNew ?? true;

    _ctrl = {
      'year': TextEditingController(text: v?.year.toString() ?? ''),
      'make': TextEditingController(text: v?.make ?? ''),
      'model': TextEditingController(text: v?.model ?? ''),
      'trim': TextEditingController(text: v?.trim ?? ''),
      'price': TextEditingController(text: v?.price?.toString() ?? ''),
      'mileage': TextEditingController(text: v?.mileage?.toString() ?? ''),
      'engineSize': TextEditingController(text: v?.engineSize?.toString() ?? ''),
      'cylinders': TextEditingController(text: v?.cylinders?.toString() ?? ''),
      'horsepower': TextEditingController(text: v?.horsepower?.toString() ?? ''),
      'hpRpm': TextEditingController(text: v?.hpRpm?.toString() ?? ''),
      'hpRpmMax': TextEditingController(text: v?.hpRpmMax?.toString() ?? ''),
      'torque': TextEditingController(text: v?.torque?.toString() ?? ''),
      'torqueRpm': TextEditingController(text: v?.torqueRpm?.toString() ?? ''),
      'torqueRpmMax': TextEditingController(text: v?.torqueRpmMax?.toString() ?? ''),
      'motorHp': TextEditingController(text: v?.motorHp?.toString() ?? ''),
      'motorTorque': TextEditingController(text: v?.motorTorque?.toString() ?? ''),
      'towCapacity': TextEditingController(text: v?.towCapacity?.toString() ?? ''),
      'bedSize': TextEditingController(text: v?.bedSize ?? ''),
      'payloadCapacity': TextEditingController(text: v?.payloadCapacity?.toString() ?? ''),
      'mpgCity': TextEditingController(text: v?.mpgCity?.toString() ?? ''),
      'mpgHwy': TextEditingController(text: v?.mpgHwy?.toString() ?? ''),
      'mpgCombined': TextEditingController(text: v?.mpgCombined?.toString() ?? ''),
      'gasTankSize': TextEditingController(text: v?.gasTankSize?.toString() ?? ''),
      'numDoors': TextEditingController(text: v?.numDoors?.toString() ?? ''),
      'numSeats': TextEditingController(text: v?.numSeats?.toString() ?? ''),
      'zeroToSixty': TextEditingController(text: v?.zeroToSixty?.toString() ?? ''),
    };
  }

  @override
  void dispose() {
    for (final c in _ctrl.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final v = Vehicle(
      id: widget.vehicle?.id,
      year: int.tryParse(_ctrl['year']!.text) ?? 2024,
      make: _ctrl['make']!.text,
      model: _ctrl['model']!.text,
      trim: _ctrl['trim']!.text,
      price: double.tryParse(_ctrl['price']!.text),
      isNew: _isNew,
      mileage: int.tryParse(_ctrl['mileage']!.text),
      engineSize: double.tryParse(_ctrl['engineSize']!.text),
      engineConfig: _engineConfig,
      cylinders: int.tryParse(_ctrl['cylinders']!.text),
      horsepower: int.tryParse(_ctrl['horsepower']!.text),
      hpRpm: int.tryParse(_ctrl['hpRpm']!.text),
      hpRpmMax: int.tryParse(_ctrl['hpRpmMax']!.text),
      torque: int.tryParse(_ctrl['torque']!.text),
      torqueRpm: int.tryParse(_ctrl['torqueRpm']!.text),
      torqueRpmMax: int.tryParse(_ctrl['torqueRpmMax']!.text),
      engineType: _engineType,
      motorHp: double.tryParse(_ctrl['motorHp']!.text),
      motorTorque: double.tryParse(_ctrl['motorTorque']!.text),
      towCapacity: int.tryParse(_ctrl['towCapacity']!.text),
      bedSize: _ctrl['bedSize']!.text.isEmpty ? null : _ctrl['bedSize']!.text,
      payloadCapacity: double.tryParse(_ctrl['payloadCapacity']!.text),
      mpgCity: double.tryParse(_ctrl['mpgCity']!.text),
      mpgHwy: double.tryParse(_ctrl['mpgHwy']!.text),
      mpgCombined: double.tryParse(_ctrl['mpgCombined']!.text),
      gasTankSize: double.tryParse(_ctrl['gasTankSize']!.text),
      numDoors: int.tryParse(_ctrl['numDoors']!.text),
      numSeats: int.tryParse(_ctrl['numSeats']!.text),
      drivetrain: _drivetrain,
      vehicleType: _vehicleType,
      zeroToSixty: double.tryParse(_ctrl['zeroToSixty']!.text),
      enginePlacement: _enginePlacement,
      transmission: _transmission,
      notNecessary: _notNecessary,
    );

    if (widget.vehicle == null) {
      await DatabaseService.insertVehicle(v);
    } else {
      await DatabaseService.updateVehicle(v);
    }

    if (mounted) Navigator.pop(context);
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        )),
      );

  Widget _field(String key, String label, {bool required = false, TextInputType? type}) {
    final isMissing = widget.vehicle != null &&
        (widget.vehicle!.isFieldMissing(key)) &&
        !(_notNecessary[key] == true);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _ctrl[key],
              keyboardType: type ?? TextInputType.text,
              decoration: InputDecoration(
                labelText: label,
                filled: true,
                enabledBorder: isMissing
                    ? OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange.shade600, width: 1.5),
                      )
                    : null,
                suffixIcon: isMissing ? const Icon(Icons.warning_amber, color: Colors.orange) : null,
              ),
              validator: required
                  ? (v) => (v == null || v.isEmpty) ? 'Required' : null
                  : null,
            ),
          ),
          if (!required) ...[
            const SizedBox(width: 8),
            Tooltip(
              message: _notNecessary[key] == true ? 'Mark as needed' : 'Mark as not necessary',
              child: IconButton(
                icon: Icon(
                  _notNecessary[key] == true ? Icons.visibility_off : Icons.not_interested,
                  size: 20,
                  color: _notNecessary[key] == true
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
                onPressed: () => setState(() {
                  if (_notNecessary[key] == true) {
                    _notNecessary.remove(key);
                  } else {
                    _notNecessary[key] = true;
                  }
                }),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _dropdown(String label, String? value, List<String> options, String fieldKey,
      void Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: value,
              decoration: InputDecoration(labelText: label, filled: true),
              items: [
                DropdownMenuItem(value: null, child: Text('Select $label')),
                ...options.map((o) => DropdownMenuItem(value: o, child: Text(o))),
              ],
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: _notNecessary[fieldKey] == true ? 'Mark as needed' : 'Mark as not necessary',
            child: IconButton(
              icon: Icon(
                _notNecessary[fieldKey] == true ? Icons.visibility_off : Icons.not_interested,
                size: 20,
                color: _notNecessary[fieldKey] == true
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
              onPressed: () => setState(() {
                if (_notNecessary[fieldKey] == true) {
                  _notNecessary.remove(fieldKey);
                } else {
                  _notNecessary[fieldKey] = true;
                }
              }),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vehicle == null ? 'Add Vehicle' : 'Edit Vehicle'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _section('Basic Info'),
            _field('year', 'Year', required: true, type: TextInputType.number),
            _field('make', 'Make', required: true),
            _field('model', 'Model', required: true),
            _field('trim', 'Trim', required: true),
            _field('price', 'Price (MSRP)', type: TextInputType.number),

            _section('Condition'),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SegmentedButton<bool>(
                selected: {_isNew},
                segments: const [
                  ButtonSegment(value: true, label: Text('New')),
                  ButtonSegment(value: false, label: Text('Used')),
                ],
                onSelectionChanged: (s) => setState(() {
                  _isNew = s.first;
                  if (_isNew) _ctrl['mileage']!.clear();
                }),
              ),
            ),
            if (!_isNew)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  controller: _ctrl['mileage'],
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Mileage',
                    filled: true,
                  ),
                ),
              ),

            _section('Vehicle Info'),
            _dropdown('Vehicle Type', _vehicleType, _vehicleTypes, 'vehicleType',
                (v) => setState(() => _vehicleType = v)),
            _dropdown('Drivetrain', _drivetrain, _drivetrains, 'drivetrain',
                (v) => setState(() => _drivetrain = v)),
            _dropdown('Transmission', _transmission, _transmissions, 'transmission',
                (v) => setState(() => _transmission = v)),
            _field('numDoors', 'Number of Doors', type: TextInputType.number),
            _field('numSeats', 'Number of Seats', type: TextInputType.number),

            _section('Engine'),
            _dropdown('Engine Type', _engineType, _engineTypes, 'engineType',
                (v) => setState(() => _engineType = v)),
            _dropdown('Engine Config', _engineConfig, _engineConfigs, 'engineConfig',
                (v) => setState(() => _engineConfig = v)),
            _dropdown('Engine Placement', _enginePlacement, _enginePlacements, 'enginePlacement',
                (v) => setState(() => _enginePlacement = v)),
            _field('engineSize', 'Engine Size (L)', type: TextInputType.number),
            _field('cylinders', 'Cylinders', type: TextInputType.number),
            _field('horsepower', 'Horsepower', type: TextInputType.number),
            _field('hpRpm', 'HP @ RPM', type: TextInputType.number),
            _field('hpRpmMax', 'HP @ RPM Max', type: TextInputType.number),
            _field('torque', 'Torque (lb-ft)', type: TextInputType.number),
            _field('torqueRpm', 'Torque @ RPM', type: TextInputType.number),
            _field('torqueRpmMax', 'Torque @ RPM Max', type: TextInputType.number),

            _section('Electric Motor'),
            _field('motorHp', 'Motor HP', type: TextInputType.number),
            _field('motorTorque', 'Motor Torque (lb-ft)', type: TextInputType.number),

            _section('Performance & Fuel'),
            _field('zeroToSixty', '0-60 mph (sec)', type: TextInputType.number),
            _field('mpgCity', 'MPG City', type: TextInputType.number),
            _field('mpgHwy', 'MPG Highway', type: TextInputType.number),
            _field('mpgCombined', 'MPG Combined', type: TextInputType.number),
            _field('gasTankSize', 'Gas Tank Size (gal)', type: TextInputType.number),

            _section('Truck / Towing'),
            _field('towCapacity', 'Tow Capacity (lbs)', type: TextInputType.number),
            _field('payloadCapacity', 'Payload Capacity (lbs)', type: TextInputType.number),
            _field('bedSize', 'Bed Size'),

            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('Save Vehicle')),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}