# Auto Manager

A Flutter desktop/mobile app for managing vehicles and calculating auto loans.

## Features

### Vehicles
- Add vehicles with 25+ spec fields: engine, MPG, drivetrain, dimensions, towing, etc.
- Missing field indicators — orange warnings show unfilled optional fields
- Mark any field as "Not Necessary" to dismiss its missing indicator
- Search by any text field; filter by vehicle type and drivetrain
- Side-by-side comparison of 2+ vehicles with winner highlighting

### Loan Calculator
- Input: vehicle price, down payment, interest rate, loan term, sales tax, fees
- Shows every formula used, then re-runs it with your numbers
- Full amortization schedule by month or by year
- Line chart: balance, cumulative interest, and cumulative payments over time
- Pie chart: principal vs. interest breakdown
- Save and reload any loan configuration

### Saved Loans
- View all saved loan configurations
- Compare 2+ loans side by side with best-value highlighting
- Reopen any saved loan in the calculator to edit

## Project Structure

```
lib/
  main.dart                         # Entry point
  models/
    vehicle.dart                    # Vehicle data model
    loan_config.dart                # Loan model + amortization logic
  services/
    database_service.dart           # SQLite (sqflite) CRUD
  screens/
    home_screen.dart                # Navigation rail shell
    vehicle_list_screen.dart        # Vehicle list, search, filter, select
    vehicle_form_screen.dart        # Add / edit vehicle
    vehicle_detail_screen.dart      # Full vehicle view + N/A controls
    vehicle_compare_screen.dart     # Side-by-side vehicle comparison
    loan_calculator_screen.dart     # Loan calculator + charts
    saved_loans_screen.dart         # Saved loan list
    loan_compare_screen.dart        # Side-by-side loan comparison
```

## Setup

```bash
flutter pub get
flutter run
```

Database is auto-migrated from v1 (original schema) to v2 (full schema) on first launch.