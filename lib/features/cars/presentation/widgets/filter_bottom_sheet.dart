import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../bloc/car_bloc.dart';
import '../bloc/car_event.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  RangeValues _priceRange = const RangeValues(0, 100000);
  String? _selectedCondition;
  String? _selectedLocation;
  String? _selectedMake;
  String? _selectedYear;

  String? _selectedTransmission;
  String? _selectedFuelType;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.filters,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _priceRange = const RangeValues(0, 100000);
                      _selectedCondition = null;
                      _selectedLocation = null;
                      _selectedMake = null;
                      _selectedYear = null;
                      _selectedTransmission = null;
                      _selectedFuelType = null;
                    });
                    context.read<CarBloc>().add(const ApplyFiltersEvent());
                    Navigator.pop(context);
                  },
                  child: Text(l10n.reset),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Price Range
            Text(l10n.priceRange, style: Theme.of(context).textTheme.titleMedium),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 100000,
              divisions: 100,
              labels: RangeLabels(
                '\$${_priceRange.start.round()}',
                '\$${_priceRange.end.round()}',
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _priceRange = values;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('\$${_priceRange.start.round()}'),
                Text('\$${_priceRange.end.round()}'),
              ],
            ),
            const SizedBox(height: 16),

            // Condition
            DropdownButtonFormField<String>(
              key: ValueKey(_selectedCondition),
              initialValue: _selectedCondition,
              decoration: InputDecoration(labelText: l10n.condition),
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.all)),
                DropdownMenuItem(value: 'New', child: Text(l10n.newCondition)),
                DropdownMenuItem(value: 'Used', child: Text(l10n.usedCondition)),
                DropdownMenuItem(value: 'Damaged', child: Text(l10n.damagedCondition)),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCondition = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Transmission
            DropdownButtonFormField<String>(
              key: ValueKey(_selectedTransmission),
              initialValue: _selectedTransmission,
              decoration: const InputDecoration(labelText: 'Transmission'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Any')),
                const DropdownMenuItem(value: 'Automatic', child: Text('Automatic')),
                const DropdownMenuItem(value: 'Manual', child: Text('Manual')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedTransmission = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Fuel Type
            DropdownButtonFormField<String>(
              key: ValueKey(_selectedFuelType),
              initialValue: _selectedFuelType,
              decoration: const InputDecoration(labelText: 'Fuel Type'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Any')),
                const DropdownMenuItem(value: 'Petrol', child: Text('Petrol')),
                const DropdownMenuItem(value: 'Diesel', child: Text('Diesel')),
                const DropdownMenuItem(value: 'Hybrid', child: Text('Hybrid')),
                const DropdownMenuItem(value: 'Electric', child: Text('Electric')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedFuelType = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Make
            DropdownButtonFormField<String>(
              key: ValueKey(_selectedMake),
              initialValue: _selectedMake,
              decoration: const InputDecoration(labelText: 'Make'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Any')),
                ...['Toyota', 'Hyundai', 'Kia', 'Mercedes', 'BMW', 'Nissan', 'Honda', 'Volkswagen']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e))),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedMake = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Year
            DropdownButtonFormField<String>(
              key: ValueKey(_selectedYear),
              initialValue: _selectedYear,
              decoration: const InputDecoration(labelText: 'Year'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Any')),
                ...List.generate(30, (index) => (DateTime.now().year - index).toString())
                    .map((e) => DropdownMenuItem(value: e, child: Text(e))),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedYear = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Location
            DropdownButtonFormField<String>(
              key: ValueKey(_selectedLocation),
              initialValue: _selectedLocation,
              decoration: InputDecoration(labelText: l10n.location),
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.all)),
                ...['Gaza City', 'Khan Yunis', 'Rafah', 'Deir al-Balah', 'Jabalia', 'Nuseirat', 'Beit Lahia']
                    .map((location) => DropdownMenuItem(
                          value: location,
                          child: Text(location),
                        )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedLocation = value;
                });
              },
            ),
            const SizedBox(height: 32),

            // Apply Button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  context.read<CarBloc>().add(
                        ApplyFiltersEvent(
                          minPrice: _priceRange.start,
                          maxPrice: _priceRange.end,
                          condition: _selectedCondition,
                          location: _selectedLocation,
                          transmission: _selectedTransmission,
                          fuelType: _selectedFuelType,
                          make: _selectedMake,
                          year: _selectedYear != null ? int.tryParse(_selectedYear!) : null,
                        ),
                      );
                  Navigator.pop(context);
                },
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Apply Filters'),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
