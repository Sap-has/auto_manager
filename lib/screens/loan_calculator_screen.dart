import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/vehicle.dart';
import '../models/loan_config.dart';
import '../services/database_service.dart';

class LoanCalculatorScreen extends StatefulWidget {
  final Vehicle? preloadVehicle;
  final LoanConfig? existingConfig;
  const LoanCalculatorScreen({super.key, this.preloadVehicle, this.existingConfig});

  @override
  State<LoanCalculatorScreen> createState() => _LoanCalculatorScreenState();
}

class _LoanCalculatorScreenState extends State<LoanCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _downCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _taxCtrl = TextEditingController();
  final _feesCtrl = TextEditingController();

  int _termMonths = 60;
  Vehicle? _selectedVehicle;
  LoanConfig? _result;
  bool _showByYear = true;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
    final ec = widget.existingConfig;
    if (ec != null) {
      _nameCtrl.text = ec.name;
      _priceCtrl.text = ec.vehiclePrice.toString();
      _downCtrl.text = ec.downPayment.toString();
      _rateCtrl.text = ec.annualInterestRate.toString();
      _taxCtrl.text = ec.salesTaxRate.toString();
      _feesCtrl.text = ec.otherFees.toString();
      _termMonths = ec.loanTermMonths;
    } else if (widget.preloadVehicle != null) {
      final v = widget.preloadVehicle!;
      _priceCtrl.text = v.price?.toString() ?? '';
      _nameCtrl.text = v.title;
    }
  }

  Future<void> _loadVehicles() async {
    final data = await DatabaseService.getVehicles();
    if (widget.preloadVehicle != null) {
      setState(() {
        _selectedVehicle = data.firstWhere(
          (v) => v.id == widget.preloadVehicle!.id,
          orElse: () => widget.preloadVehicle!,
        );
      });
    }
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    final config = LoanConfig(
      name: _nameCtrl.text.isEmpty ? 'Loan' : _nameCtrl.text,
      vehicleId: _selectedVehicle?.id,
      vehicleName: _selectedVehicle?.title,
      vehiclePrice: double.parse(_priceCtrl.text),
      loanTermMonths: _termMonths,
      annualInterestRate: double.parse(_rateCtrl.text),
      downPayment: double.parse(_downCtrl.text.isEmpty ? '0' : _downCtrl.text),
      salesTaxRate: double.parse(_taxCtrl.text.isEmpty ? '0' : _taxCtrl.text),
      otherFees: double.parse(_feesCtrl.text.isEmpty ? '0' : _feesCtrl.text),
    );
    setState(() => _result = config);
  }

  Future<void> _save() async {
    if (_result == null) return;
    if (widget.existingConfig?.id != null) {
      await DatabaseService.updateLoanConfig(_result!.copyWith(id: widget.existingConfig!.id));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Loan updated')));
    } else {
      await DatabaseService.insertLoanConfig(_result!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Loan saved')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Calculator'),
        actions: [
          if (_result != null)
            TextButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save'),
              onPressed: _save,
            ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 320,
            child: Card(
              margin: const EdgeInsets.all(12),
              child: _buildForm(),
            ),
          ),
          if (_result != null)
            Expanded(child: _buildResults(_result!)),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Loan Details', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          StreamBuilder<List<Vehicle>>(
            stream: DatabaseService.getVehiclesStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LinearProgressIndicator();

              final vehicles = snapshot.data!;

              return DropdownButtonFormField<Vehicle>(
                isExpanded: true,
                initialValue: _selectedVehicle == null
                    ? null 
                    : vehicles.firstWhere(
                        (v) => v.id == _selectedVehicle!.id, 
                        orElse: () => _selectedVehicle!,
                      ),
                decoration: const InputDecoration(labelText: 'Vehicle (optional)', filled: true),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Custom / None')),
                  ...vehicles.map((v) => DropdownMenuItem(
                        value: v,
                        child: Text(
                          v.title, 
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      )),
                ],
                onChanged: (v) {
                  setState(() {
                    _selectedVehicle = v;
                    if (v?.price != null) _priceCtrl.text = v!.price!.toString();
                    if (v != null) _nameCtrl.text = v.title;
                  });
                },
              );
            },
          ),
          const SizedBox(height: 12),
          _tf(_nameCtrl, 'Config Name', required: false),
          _tf(_priceCtrl, 'Vehicle Price (\$)', required: true),
          _tf(_downCtrl, 'Down Payment (\$)', required: false),
          _tf(_rateCtrl, 'Annual Interest Rate (%)', required: true),
          _tf(_taxCtrl, 'Sales Tax Rate (%)', required: false),
          _tf(_feesCtrl, 'Title, Registration & Fees (\$)', required: false),
          const SizedBox(height: 12),
          Text('Loan Term: $_termMonths months'),
          Slider(
            value: _termMonths.toDouble(),
            min: 12,
            max: 96,
            divisions: 7,
            label: '$_termMonths mo',
            onChanged: (v) => setState(() => _termMonths = v.round()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [24, 36, 48, 60].map((t) => TextButton(
              onPressed: () => setState(() => _termMonths = t),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                backgroundColor: _termMonths == t
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
              ),
              child: Text('${t}mo'),
            )).toList(),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _calculate, child: const Text('Calculate')),
        ],
      ),
    );
  }

  Widget _tf(TextEditingController c, String label, {required bool required}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label, filled: true),
        validator: required
            ? (v) => (v == null || v.isEmpty) ? 'Required' : null
            : null,
      ),
    );
  }

  Widget _buildResults(LoanConfig c) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _summaryCard(c),
          const SizedBox(height: 12),
          _formulas(c),
          const SizedBox(height: 12),
          _amortizationTable(c),
          const SizedBox(height: 12),
          _charts(c),
        ],
      ),
    );
  }

  Widget _summaryCard(LoanConfig c) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Summary', style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            _kv('Monthly Payment', '\$${c.correctMonthlyPayment.toStringAsFixed(2)}', highlight: true),
            _kv('Loan Amount', '\$${c.loanAmount.toStringAsFixed(2)}'),
            _kv('Total of ${c.loanTermMonths} Payments', '\$${c.totalOfPayments.toStringAsFixed(2)}'),
            _kv('Total Loan Interest', '\$${c.totalInterest.toStringAsFixed(2)}'),
            const Divider(),
            _kv('Vehicle Price', '\$${c.vehiclePrice.toStringAsFixed(2)}'),
            _kv('Sales Tax (${c.salesTaxRate}%)', '\$${c.salesTaxAmount.toStringAsFixed(2)}'),
            _kv('Other Fees', '\$${c.otherFees.toStringAsFixed(2)}'),
            _kv('Down Payment', '\$${c.downPayment.toStringAsFixed(2)}'),
            _kv('Upfront Payment', '\$${c.upfrontPayment.toStringAsFixed(2)}', highlight: true),
            const Divider(),
            _kv('Total Cost', '\$${c.totalCost.toStringAsFixed(2)}', highlight: true),
          ],
        ),
      ),
    );
  }

  Widget _formulas(LoanConfig c) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How It\'s Calculated', style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            _formula(
              'Loan Amount',
              'Loan Amount = Vehicle Price + Sales Tax + Fees − Down Payment',
              'Loan Amount = \$${c.vehiclePrice.toStringAsFixed(2)} + \$${c.salesTaxAmount.toStringAsFixed(2)} + \$${c.otherFees.toStringAsFixed(2)} − \$${c.downPayment.toStringAsFixed(2)} = \$${c.loanAmount.toStringAsFixed(2)}',
            ),
            _formula(
              'Monthly Payment',
              'M = P × [r(1+r)^n] / [(1+r)^n − 1]  where r = annual rate / 12, n = months',
              'M = \$${c.loanAmount.toStringAsFixed(2)} × [${(c.monthlyRate * 100).toStringAsFixed(4)}% × (1 + ${(c.monthlyRate * 100).toStringAsFixed(4)}%)^${c.loanTermMonths}] / [(1 + ${(c.monthlyRate * 100).toStringAsFixed(4)}%)^${c.loanTermMonths} − 1] = \$${c.correctMonthlyPayment.toStringAsFixed(2)}',
            ),
            _formula(
              'Total of Payments',
              'Total = Monthly Payment × Number of Months',
              'Total = \$${c.correctMonthlyPayment.toStringAsFixed(2)} × ${c.loanTermMonths} = \$${c.totalOfPayments.toStringAsFixed(2)}',
            ),
            _formula(
              'Total Interest',
              'Interest = Total of Payments − Loan Amount',
              'Interest = \$${c.totalOfPayments.toStringAsFixed(2)} − \$${c.loanAmount.toStringAsFixed(2)} = \$${c.totalInterest.toStringAsFixed(2)}',
            ),
            _formula(
              'Total Cost',
              'Total Cost = Total of Payments + Down Payment + Fees + Sales Tax',
              'Total Cost = \$${c.totalOfPayments.toStringAsFixed(2)} + \$${c.downPayment.toStringAsFixed(2)} + \$${c.otherFees.toStringAsFixed(2)} + \$${c.salesTaxAmount.toStringAsFixed(2)} = \$${c.totalCost.toStringAsFixed(2)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _formula(String title, String formula, String withNums) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(formula, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(withNums, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _amortizationTable(LoanConfig c) {
    final rows = c.amortizationSchedule;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Amortization Schedule', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                SegmentedButton<bool>(
                  selected: {_showByYear},
                  segments: const [
                    ButtonSegment(value: true, label: Text('By Year')),
                    ButtonSegment(value: false, label: Text('By Month')),
                  ],
                  onSelectionChanged: (s) => setState(() => _showByYear = s.first),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _showByYear ? _yearTable(rows) : _monthTable(rows),
            ),
          ],
        ),
      ),
    );
  }

  Widget _yearTable(List<AmortizationRow> rows) {
    final years = <int, _YearRow>{};
    for (final r in rows) {
      years.putIfAbsent(r.year, () => _YearRow(r.year));
      years[r.year]!.add(r);
    }
    final sorted = years.values.toList()..sort((a, b) => a.year.compareTo(b.year));

    return DataTable(
      columns: const [
        DataColumn(label: Text('Year')),
        DataColumn(label: Text('Interest'), numeric: true),
        DataColumn(label: Text('Principal'), numeric: true),
        DataColumn(label: Text('Ending Balance'), numeric: true),
      ],
      rows: sorted.map((y) => DataRow(cells: [
        DataCell(Text('Year ${y.year}')),
        DataCell(Text('\$${y.interest.toStringAsFixed(2)}')),
        DataCell(Text('\$${y.principal.toStringAsFixed(2)}')),
        DataCell(Text('\$${y.endBalance.toStringAsFixed(2)}')),
      ])).toList(),
    );
  }

  Widget _monthTable(List<AmortizationRow> rows) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Month')),
        DataColumn(label: Text('Payment'), numeric: true),
        DataColumn(label: Text('Interest'), numeric: true),
        DataColumn(label: Text('Principal'), numeric: true),
        DataColumn(label: Text('Balance'), numeric: true),
      ],
      rows: rows.map((r) => DataRow(cells: [
        DataCell(Text('${r.month}')),
        DataCell(Text('\$${r.payment.toStringAsFixed(2)}')),
        DataCell(Text('\$${r.interest.toStringAsFixed(2)}')),
        DataCell(Text('\$${r.principal.toStringAsFixed(2)}')),
        DataCell(Text('\$${r.endingBalance.toStringAsFixed(2)}')),
      ])).toList(),
    );
  }

  Widget _charts(LoanConfig c) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _lineChart(c)),
        const SizedBox(width: 12),
        SizedBox(width: 280, child: _pieChart(c)),
      ],
    );
  }

  Widget _lineChart(LoanConfig c) {
    final rows = c.amortizationSchedule;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Balance & Interest Over Time', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 240,
              child: _LoanLineChart(rows: rows, loanAmount: c.loanAmount),
            ),
            const SizedBox(height: 8),
            Row(children: [
              _legend(Colors.blue, 'Balance'),
              const SizedBox(width: 16),
              _legend(Colors.orange, 'Cumulative Interest'),
              const SizedBox(width: 16),
              _legend(Colors.green, 'Cumulative Payment'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _pieChart(LoanConfig c) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Cost Breakdown', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _PieChart(
                principal: c.loanAmount,
                interest: c.totalInterest,
              ),
            ),
            const SizedBox(height: 8),
            _legend(Colors.blue, 'Principal: \$${c.loanAmount.toStringAsFixed(0)}'),
            const SizedBox(height: 4),
            _legend(Colors.orange, 'Interest: \$${c.totalInterest.toStringAsFixed(0)}'),
          ],
        ),
      ),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 12)),
    ]);
  }

  Widget _kv(String k, String v, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(k, style: TextStyle(color: highlight ? null : Colors.grey))),
          Text(v, style: TextStyle(
            fontWeight: highlight ? FontWeight.bold : null,
            color: highlight ? Theme.of(context).colorScheme.primary : null,
          )),
        ],
      ),
    );
  }
}

class _YearRow {
  final int year;
  double interest = 0;
  double principal = 0;
  double endBalance = 0;
  _YearRow(this.year);
  void add(AmortizationRow r) {
    interest += r.interest;
    principal += r.principal;
    endBalance = r.endingBalance;
  }
}

class _LoanLineChart extends StatelessWidget {
  final List<AmortizationRow> rows;
  final double loanAmount;
  const _LoanLineChart({required this.rows, required this.loanAmount});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(rows: rows, loanAmount: loanAmount),
      child: const SizedBox.expand(),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<AmortizationRow> rows;
  final double loanAmount;

  _LineChartPainter({required this.rows, required this.loanAmount});

  @override
  void paint(Canvas canvas, Size size) {
    if (rows.isEmpty) return;

    final pad = const EdgeInsets.fromLTRB(56, 8, 8, 32);
    final w = size.width - pad.left - pad.right;
    final h = size.height - pad.top - pad.bottom;

    double cumInterest = 0;
    double cumPayment = 0;
    final maxY = loanAmount * 1.05;

    double xOf(int i) => pad.left + (i / (rows.length - 1)) * w;
    double yOf(double v) => pad.top + h - (v / maxY) * h;

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = pad.top + (i / 4) * h;
      canvas.drawLine(Offset(pad.left, y), Offset(pad.left + w, y), gridPaint);
      final label = '\$${((maxY * (1 - i / 4)) / 1000).toStringAsFixed(0)}k';
      final tp = TextPainter(
        text: TextSpan(text: label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - 6));
    }

    final paths = [
      (Colors.blue, <Offset>[]),
      (Colors.orange, <Offset>[]),
      (Colors.green, <Offset>[]),
    ];

    for (int i = 0; i < rows.length; i++) {
      cumInterest += rows[i].interest;
      cumPayment += rows[i].payment;
      final x = xOf(i);
      paths[0].$2.add(Offset(x, yOf(rows[i].endingBalance)));
      paths[1].$2.add(Offset(x, yOf(math.min(cumInterest, maxY))));
      paths[2].$2.add(Offset(x, yOf(math.min(cumPayment, maxY))));
    }

    for (final (color, pts) in paths) {
      if (pts.isEmpty) continue;
      final paint = Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round;
      final path = Path()..moveTo(pts[0].dx, pts[0].dy);
      for (final pt in pts.skip(1)) {
        path.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(path, paint);
    }

    final axisPaint = Paint()..color = Colors.grey..strokeWidth = 1;
    canvas.drawLine(Offset(pad.left, pad.top), Offset(pad.left, pad.top + h), axisPaint);
    canvas.drawLine(Offset(pad.left, pad.top + h), Offset(pad.left + w, pad.top + h), axisPaint);

    final step = math.max(1, rows.length ~/ 6);
    for (int i = 0; i < rows.length; i += step) {
      final tp = TextPainter(
        text: TextSpan(text: '${rows[i].month}', style: const TextStyle(color: Colors.grey, fontSize: 10)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(xOf(i) - tp.width / 2, pad.top + h + 4));
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter old) => old.rows != rows;
}

class _PieChart extends StatelessWidget {
  final double principal;
  final double interest;
  const _PieChart({required this.principal, required this.interest});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PiePainter(principal: principal, interest: interest),
      child: const SizedBox.expand(),
    );
  }
}

class _PiePainter extends CustomPainter {
  final double principal;
  final double interest;

  _PiePainter({required this.principal, required this.interest});

  @override
  void paint(Canvas canvas, Size size) {
    final total = principal + interest;
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final principalAngle = (principal / total) * 2 * math.pi;

    canvas.drawArc(rect, -math.pi / 2, principalAngle, true,
        Paint()..color = Colors.blue);
    canvas.drawArc(rect, -math.pi / 2 + principalAngle, 2 * math.pi - principalAngle, true,
        Paint()..color = Colors.orange);

    canvas.drawCircle(center, radius * 0.55,
        Paint()..color = const Color(0xFF1F2937));

    final pct = '${(principal / total * 100).toStringAsFixed(0)}%';
    final tp = TextPainter(
      text: TextSpan(
        text: pct,
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_PiePainter old) => old.principal != principal;
}