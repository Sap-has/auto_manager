import 'package:flutter/material.dart';
import '../models/loan_config.dart';
import '../services/database_service.dart';
import 'loan_calculator_screen.dart';
import 'loan_compare_screen.dart';

class SavedLoansScreen extends StatefulWidget {
  const SavedLoansScreen({super.key});

  @override
  State<SavedLoansScreen> createState() => _SavedLoansScreenState();
}

class _SavedLoansScreenState extends State<SavedLoansScreen> {
  final Set<int> _selected = {};
  bool _selectMode = false;

  Future<void> _delete(LoanConfig c) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Loan'),
        content: Text('Remove "${c.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseService.deleteLoanConfig(c.id!);
    }
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LoanConfig>>(
      stream: DatabaseService.getLoanConfigsStream(),
      builder: (context, snapshot) {
        final loans = snapshot.data ?? [];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Saved Loans'),
            actions: [
              if (_selectMode && _selected.length >= 2)
                TextButton.icon(
                  icon: const Icon(Icons.compare_arrows),
                  label: Text('Compare (${_selected.length})'),
                  onPressed: () {
                    final selected = loans.where((l) => _selected.contains(l.id)).toList();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LoanCompareScreen(loans: selected)),
                    );
                  },
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
          body: loans.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calculate_outlined, size: 48, color: Colors.grey),
                      const SizedBox(height: 8),
                      const Text('No saved loans yet.'),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoanCalculatorScreen()),
                          );
                        },
                        child: const Text('Create Loan'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: loans.length,
                  itemBuilder: (_, i) {
                    final loan = loans[i];
                    final isSelected = _selected.contains(loan.id);
                    return Card(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      child: ListTile(
                        leading: _selectMode
                            ? Checkbox(
                                value: isSelected,
                                onChanged: (_) => _toggleSelect(loan.id!),
                              )
                            : const Icon(Icons.calculate),
                        title: Text(loan.name),
                        subtitle: Text(
                          '${loan.loanTermMonths}mo · ${loan.annualInterestRate}% · '
                          '\$${loan.correctMonthlyPayment.toStringAsFixed(0)}/mo',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('\$${loan.totalCost.toStringAsFixed(0)} total'),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 18),
                              onPressed: () => _delete(loan),
                            ),
                          ],
                        ),
                        onTap: () {
                          if (_selectMode) {
                            _toggleSelect(loan.id!);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LoanCalculatorScreen(existingConfig: loan),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.add),
            label: const Text('New Loan'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoanCalculatorScreen()),
              );
            },
          ),
        );
      },
    );
  }
}