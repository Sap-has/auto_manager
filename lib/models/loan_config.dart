class LoanConfig {
  final int? id;
  final String name;
  final int? vehicleId;
  final String? vehicleName;
  final double vehiclePrice;
  final int loanTermMonths;
  final double annualInterestRate;
  final double downPayment;
  final double salesTaxRate;
  final double otherFees;

  LoanConfig({
    this.id,
    required this.name,
    this.vehicleId,
    this.vehicleName,
    required this.vehiclePrice,
    required this.loanTermMonths,
    required this.annualInterestRate,
    required this.downPayment,
    required this.salesTaxRate,
    required this.otherFees,
  });

  double get salesTaxAmount => vehiclePrice * (salesTaxRate / 100);
  double get totalVehicleCost => vehiclePrice + salesTaxAmount + otherFees;
  double get loanAmount => totalVehicleCost - downPayment;
  double get monthlyRate => annualInterestRate / 100 / 12;

  double get _monthlyPaymentCorrect {
    if (monthlyRate == 0) return loanAmount / loanTermMonths;
    final r = monthlyRate;
    final n = loanTermMonths.toDouble();
    final factor = r * _pow(1 + r, n) / (_pow(1 + r, n) - 1);
    return loanAmount * factor;
  }

  static double _pow(double base, double exp) {
    double result = 1.0;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }

  double get monthlyPayment => _monthlyPaymentCorrect;
  double get correctMonthlyPayment => _monthlyPaymentCorrect;
  double get totalOfPayments => correctMonthlyPayment * loanTermMonths;
  double get totalInterest => totalOfPayments - loanAmount;
  double get totalCost => totalOfPayments + downPayment + otherFees + salesTaxAmount;
  double get upfrontPayment => downPayment + otherFees + salesTaxAmount;

  List<AmortizationRow> get amortizationSchedule {
    final rows = <AmortizationRow>[];
    double balance = loanAmount;
    final payment = correctMonthlyPayment;
    for (int month = 1; month <= loanTermMonths; month++) {
      final interestPayment = balance * monthlyRate;
      final principalPayment = payment - interestPayment;
      balance -= principalPayment;
      rows.add(AmortizationRow(
        month: month,
        payment: payment,
        interest: interestPayment,
        principal: principalPayment,
        endingBalance: balance < 0 ? 0 : balance,
      ));
    }
    return rows;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'vehicleId': vehicleId,
      'vehicleName': vehicleName,
      'vehiclePrice': vehiclePrice,
      'loanTermMonths': loanTermMonths,
      'annualInterestRate': annualInterestRate,
      'downPayment': downPayment,
      'salesTaxRate': salesTaxRate,
      'otherFees': otherFees,
    };
  }

  factory LoanConfig.fromMap(Map<String, dynamic> map) {
    return LoanConfig(
      id: map['id'],
      name: map['name'],
      vehicleId: map['vehicleId'],
      vehicleName: map['vehicleName'],
      vehiclePrice: map['vehiclePrice'],
      loanTermMonths: map['loanTermMonths'],
      annualInterestRate: map['annualInterestRate'],
      downPayment: map['downPayment'],
      salesTaxRate: map['salesTaxRate'],
      otherFees: map['otherFees'],
    );
  }

  LoanConfig copyWith({
    int? id,
    String? name,
    int? vehicleId,
    String? vehicleName,
    double? vehiclePrice,
    int? loanTermMonths,
    double? annualInterestRate,
    double? downPayment,
    double? salesTaxRate,
    double? otherFees,
  }) {
    return LoanConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleName: vehicleName ?? this.vehicleName,
      vehiclePrice: vehiclePrice ?? this.vehiclePrice,
      loanTermMonths: loanTermMonths ?? this.loanTermMonths,
      annualInterestRate: annualInterestRate ?? this.annualInterestRate,
      downPayment: downPayment ?? this.downPayment,
      salesTaxRate: salesTaxRate ?? this.salesTaxRate,
      otherFees: otherFees ?? this.otherFees,
    );
  }
}

class AmortizationRow {
  final int month;
  final double payment;
  final double interest;
  final double principal;
  final double endingBalance;

  AmortizationRow({
    required this.month,
    required this.payment,
    required this.interest,
    required this.principal,
    required this.endingBalance,
  });

  int get year => ((month - 1) ~/ 12) + 1;
}