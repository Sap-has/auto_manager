import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/database_service.dart';
import 'vehicle_detail_screen.dart';
import 'vehicle_form_screen.dart';
import 'vehicle_compare_screen.dart';

class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  List<Vehicle> _all = [];
  List<Vehicle> _filtered = [];
  final Set<int> _selected = {};
  bool _selectMode = false;
  String _search = '';
  String? _filterType;
  String? _filterDrivetrain;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await DatabaseService.getVehicles();
    setState(() {
      _all = data;
      _applyFilter();
    });
  }

  void _applyFilter() {
    _filtered = _all.where((v) {
      final q = _search.toLowerCase();
      final matchSearch = q.isEmpty ||
          v.title.toLowerCase().contains(q) ||
          (v.vehicleType?.toLowerCase().contains(q) ?? false) ||
          (v.drivetrain?.toLowerCase().contains(q) ?? false) ||
          (v.engineType?.toLowerCase().contains(q) ?? false);
      final matchType = _filterType == null || v.vehicleType == _filterType;
      final matchDrive = _filterDrivetrain == null || v.drivetrain == _filterDrivetrain;
      return matchSearch && matchType && matchDrive;
    }).toList();
  }

  void _toggleSelect(int id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
      if (_selected.isEmpty) _selectMode = false;
    });
  }

  Future<void> _delete(Vehicle v) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: Text('Remove ${v.title}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseService.deleteVehicle(v.id!);
      _load();
    }
  }

  void _openCompare() {
    final vehicles = _all.where((v) => _selected.contains(v.id)).toList();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VehicleCompareScreen(vehicles: vehicles)),
    );
  }

  List<String> get _allTypes =>
      _all.map((v) => v.vehicleType).whereType<String>().toSet().toList()..sort();

  List<String> get _allDrivetrains =>
      _all.map((v) => v.drivetrain).whereType<String>().toSet().toList()..sort();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vehicles'),
        actions: [
          if (_selectMode && _selected.length >= 2)
            TextButton.icon(
              icon: const Icon(Icons.compare_arrows),
              label: Text('Compare (${_selected.length})'),
              onPressed: _openCompare,
            ),
          if (_selectMode)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() {
                _selectMode = false;
                _selected.clear();
              }),
            )
          else
            IconButton(
              icon: const Icon(Icons.checklist),
              tooltip: 'Select to Compare',
              onPressed: () => setState(() => _selectMode = true),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(child: Text('No vehicles found.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) => _buildTile(_filtered[i]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Vehicle'),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VehicleFormScreen()),
          );
          _load();
        },
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search vehicles...',
              prefixIcon: Icon(Icons.search),
              isDense: true,
            ),
            onChanged: (v) => setState(() {
              _search = v;
              _applyFilter();
            }),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filterType,
                  decoration: const InputDecoration(labelText: 'Type', isDense: true),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Types')),
                    ..._allTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))),
                  ],
                  onChanged: (v) => setState(() {
                    _filterType = v;
                    _applyFilter();
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filterDrivetrain,
                  decoration: const InputDecoration(labelText: 'Drivetrain', isDense: true),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All')),
                    ..._allDrivetrains.map((d) => DropdownMenuItem(value: d, child: Text(d))),
                  ],
                  onChanged: (v) => setState(() {
                    _filterDrivetrain = v;
                    _applyFilter();
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTile(Vehicle v) {
    final missing = v.missingFieldCount;
    final isSelected = _selected.contains(v.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: ListTile(
        leading: _selectMode
            ? Checkbox(
                value: isSelected,
                onChanged: (_) => _toggleSelect(v.id!),
              )
            : CircleAvatar(
                backgroundColor: missing > 0
                    ? Colors.orange.withOpacity(0.2)
                    : Colors.green.withOpacity(0.2),
                child: Icon(
                  missing > 0 ? Icons.warning_amber : Icons.check_circle,
                  color: missing > 0 ? Colors.orange : Colors.green,
                  size: 20,
                ),
              ),
        title: Text(v.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (v.vehicleType != null || v.drivetrain != null)
              Text('${v.vehicleType ?? ''}${v.drivetrain != null ? ' · ${v.drivetrain}' : ''}'),
            if (missing > 0)
              Text(
                '$missing field${missing == 1 ? '' : 's'} missing',
                style: const TextStyle(color: Colors.orange, fontSize: 12),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (v.price != null)
              Text(
                '\$${v.price!.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            IconButton(
              icon: const Icon(Icons.edit, size: 18),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => VehicleFormScreen(vehicle: v)),
                );
                _load();
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 18),
              onPressed: () => _delete(v),
            ),
          ],
        ),
        onTap: () async {
          if (_selectMode) {
            _toggleSelect(v.id!);
          } else {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => VehicleDetailScreen(vehicle: v)),
            );
            _load();
          }
        },
      ),
    );
  }
}