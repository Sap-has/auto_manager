import 'package:flutter/material.dart';
import '../models/loan_config.dart';

class LoanCompareScreen extends StatelessWidget {
  final List<LoanConfig> loans;
  const LoanCompareScreen({super.key, required this.loans});

  static const _rows = [
    ('vehiclePrice', 'Vehicle Price'),
    ('downPayment', 'Down Payment'),
    ('loanAmount', 'Loan Amount'),
    ('salesTax', 'Sales Tax'),
    ('otherFees', 'Other Fees'),
    ('upfrontPayment', 'Upfront Payment'),
    ('loanTermMonths', 'Loan Term'),
    ('annualRate', 'Interest Rate'),
    ('monthlyPayment', 'Monthly Payment'),
    ('totalPayments', 'Total of Payments'),
    ('totalInterest', 'Total Interest'),
    ('totalCost', 'Total Cost'),
  ];

  String _val(LoanConfig c, String field) {
    switch (field) {
      case 'vehiclePrice': return '\$${c.vehiclePrice.toStringAsFixed(2)}';
      case 'downPayment': return '\$${c.downPayment.toStringAsFixed(2)}';
      case 'loanAmount': return '\$${c.loanAmount.toStringAsFixed(2)}';
      case 'salesTax': return '\$${c.salesTaxAmount.toStringAsFixed(2)} (${c.salesTaxRate}%)';
      case 'otherFees': return '\$${c.otherFees.toStringAsFixed(2)}';
      case 'upfrontPayment': return '\$${c.upfrontPayment.toStringAsFixed(2)}';
      case 'loanTermMonths': return '${c.loanTermMonths} months';
      case 'annualRate': return '${c.annualInterestRate}%';
      case 'monthlyPayment': return '\$${c.correctMonthlyPayment.toStringAsFixed(2)}';
      case 'totalPayments': return '\$${c.totalOfPayments.toStringAsFixed(2)}';
      case 'totalInterest': return '\$${c.totalInterest.toStringAsFixed(2)}';
      case 'totalCost': return '\$${c.totalCost.toStringAsFixed(2)}';
      default: return '—';
    }
  }

  double? _num(LoanConfig c, String field) {
    switch (field) {
      case 'vehiclePrice': return c.vehiclePrice;
      case 'downPayment': return c.downPayment;
      case 'loanAmount': return c.loanAmount;
      case 'salesTax': return c.salesTaxAmount;
      case 'otherFees': return c.otherFees;
      case 'upfrontPayment': return c.upfrontPayment;
      case 'loanTermMonths': return c.loanTermMonths.toDouble();
      case 'annualRate': return c.annualInterestRate;
      case 'monthlyPayment': return c.correctMonthlyPayment;
      case 'totalPayments': return c.totalOfPayments;
      case 'totalInterest': return c.totalInterest;
      case 'totalCost': return c.totalCost;
      default: return null;
    }
  }

  static const _lowerIsBetter = {
    'vehiclePrice', 'loanAmount', 'salesTax', 'otherFees', 'upfrontPayment',
    'loanTermMonths', 'annualRate', 'monthlyPayment', 'totalPayments',
    'totalInterest', 'totalCost',
  };

  int? _bestIndex(String field) {
    double? best;
    int? bestIdx;
    final lower = _lowerIsBetter.contains(field);
    for (int i = 0; i < loans.length; i++) {
      final v = _num(loans[i], field);
      if (v != null) {
        if (best == null || (lower ? v < best : v > best)) {
          best = v;
          bestIdx = i;
        }
      }
    }
    return bestIdx;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compare Loans')),
      body: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 24,
            columns: [
              const DataColumn(label: Text('Item')),
              ...loans.map((l) => DataColumn(
                    label: SizedBox(
                      width: 140,
                      child: Text(l.name, overflow: TextOverflow.ellipsis),
                    ),
                  )),
            ],
            rows: [
              for (final (field, label) in _rows)
                DataRow(
                  cells: [
                    DataCell(Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
                    ...loans.asMap().entries.map((entry) {
                      final i = entry.key;
                      final l = entry.value;
                      final best = _bestIndex(field);
                      final isWinner = best == i && loans.length > 1;
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
                                      .withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(4),
                                )
                              : null,
                          child: Text(_val(l, field)),
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