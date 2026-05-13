import 'package:flutter/material.dart';
import 'vehicle_list_screen.dart';
import 'loan_calculator_screen.dart';
import 'saved_loans_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _destinations = [
    NavigationRailDestination(
      icon: Icon(Icons.directions_car_outlined),
      selectedIcon: Icon(Icons.directions_car),
      label: Text('Vehicles'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.calculate_outlined),
      selectedIcon: Icon(Icons.calculate),
      label: Text('Calculator'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.savings_outlined),
      selectedIcon: Icon(Icons.savings),
      label: Text('Saved Loans'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            labelType: NavigationRailLabelType.all,
            destinations: _destinations,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Icon(Icons.car_repair,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 4),
                  Text('Auto\nManager',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      )),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: const [
                VehicleListScreen(),
                LoanCalculatorScreen(),
                SavedLoansScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}