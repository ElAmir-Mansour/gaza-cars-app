import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../bloc/car_bloc.dart';
import '../bloc/car_event.dart';
import '../bloc/car_state.dart';
import 'filter_widgets.dart';

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
  void initState() {
    super.initState();
    final state = context.read<CarBloc>().state;
    if (state is CarLoaded) {
      final loadedState = state;
      _priceRange = RangeValues(
        loadedState.minPrice ?? 0,
        loadedState.maxPrice ?? 100000,
      );
      _selectedCondition = loadedState.condition;
      _selectedLocation = loadedState.location;
      _selectedMake = loadedState.make;
      _selectedYear = loadedState.year?.toString();
      _selectedTransmission = loadedState.transmission;
      _selectedFuelType = loadedState.fuelType;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle Bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.filters,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: _resetFilters,
                child: Text(l10n.reset),
              ),
            ],
          ),
          const Divider(),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price Range
                  FilterSectionTitle(
                    title: '${l10n.priceRange}: \$${_priceRange.start.round()} - \$${_priceRange.end.round()}',
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 100000,
                    divisions: 100,
                    activeColor: colorScheme.primary,
                    inactiveColor: colorScheme.primaryContainer,
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

                  // Make
                  FilterSectionTitle(
                    title: 'Make',
                    onClear: _selectedMake != null ? () => setState(() => _selectedMake = null) : null,
                  ),
                  FilterChipGroup<String>(
                    items: const ['Toyota', 'Hyundai', 'Kia', 'Mercedes', 'BMW', 'Nissan', 'Honda', 'Volkswagen'],
                    selectedItem: _selectedMake,
                    onSelected: (value) => setState(() => _selectedMake = value),
                    labelBuilder: (item) => item,
                  ),
                  const SizedBox(height: 16),

                  // Condition
                  FilterSectionTitle(
                    title: l10n.condition,
                    onClear: _selectedCondition != null ? () => setState(() => _selectedCondition = null) : null,
                  ),
                  FilterChipGroup<String>(
                    items: const ['New', 'Used', 'Damaged'],
                    selectedItem: _selectedCondition,
                    onSelected: (value) => setState(() => _selectedCondition = value),
                    labelBuilder: (item) {
                       switch (item) {
                         case 'New': return l10n.newCondition;
                         case 'Used': return l10n.usedCondition;
                         case 'Damaged': return l10n.damagedCondition;
                         default: return item;
                       }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Transmission
                  FilterSectionTitle(
                    title: 'Transmission', // TODO: Localize
                    onClear: _selectedTransmission != null ? () => setState(() => _selectedTransmission = null) : null,
                  ),
                  FilterChipGroup<String>(
                    items: const ['Automatic', 'Manual'],
                    selectedItem: _selectedTransmission,
                    onSelected: (value) => setState(() => _selectedTransmission = value),
                    labelBuilder: (item) => item == 'Automatic' ? l10n.automatic : l10n.manual,
                  ),
                  const SizedBox(height: 16),

                  // Fuel Type
                  FilterSectionTitle(
                    title: 'Fuel Type', // TODO: Localize
                    onClear: _selectedFuelType != null ? () => setState(() => _selectedFuelType = null) : null,
                  ),
                  FilterChipGroup<String>(
                    items: const ['Petrol', 'Diesel', 'Hybrid', 'Electric'],
                    selectedItem: _selectedFuelType,
                    onSelected: (value) => setState(() => _selectedFuelType = value),
                    labelBuilder: (item) {
                      switch (item) {
                        case 'Petrol': return l10n.petrol;
                        case 'Diesel': return l10n.diesel;
                        case 'Hybrid': return l10n.hybrid;
                        case 'Electric': return l10n.electric;
                        default: return item;
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Year (Horizontal Scroll)
                  FilterSectionTitle(
                    title: 'Year', // TODO: Localize
                    onClear: _selectedYear != null ? () => setState(() => _selectedYear = null) : null,
                  ),
                  SizedBox(
                    height: 50,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 30,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final year = (DateTime.now().year - index).toString();
                        final isSelected = _selectedYear == year;
                        return ChoiceChip(
                          label: Text(year),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedYear = selected ? year : null;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Location (Dropdown for many options)
                  FilterSectionTitle(title: l10n.location),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedLocation,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    hint: Text(l10n.all),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Locations')), // TODO: Localize
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
                ],
              ),
            ),
          ),

          // Apply Button
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _applyFilters,
                child: Text(
                  'Show Results', // TODO: Localize
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _priceRange = const RangeValues(0, 100000);
      _selectedCondition = null;
      _selectedLocation = null;
      _selectedMake = null;
      _selectedYear = null;
      _selectedTransmission = null;
      _selectedFuelType = null;
    });
  }

  void _applyFilters() {
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
  }
}
