
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/car_entity.dart';
import '../bloc/car_bloc.dart';
import '../bloc/car_event.dart';
import '../bloc/car_state.dart';

class EditCarPage extends StatefulWidget {
  final CarEntity car;

  const EditCarPage({super.key, required this.car});

  @override
  State<EditCarPage> createState() => _EditCarPageState();
}

class _EditCarPageState extends State<EditCarPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _makeController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _priceController;
  late final TextEditingController _mileageController;
  late final TextEditingController _locationController;
  late final TextEditingController _phoneController;
  late final TextEditingController _conditionController;

  @override
  void initState() {
    super.initState();
    // Pre-fill controllers with existing car data
    _makeController = TextEditingController(text: widget.car.make);
    _modelController = TextEditingController(text: widget.car.model);
    _yearController = TextEditingController(text: widget.car.year.toString());
    _priceController = TextEditingController(text: widget.car.price.toString());
    _mileageController = TextEditingController(text: widget.car.mileage.toString());
    _locationController = TextEditingController(text: widget.car.location);
    _phoneController = TextEditingController(text: widget.car.sellerPhone);
    _conditionController = TextEditingController(text: widget.car.condition);
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _priceController.dispose();
    _mileageController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _conditionController.dispose();
    super.dispose();
  }

  void _submitUpdate(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final updatedCar = CarEntity(
        id: widget.car.id,
        sellerId: widget.car.sellerId,
        sellerPhone: _phoneController.text,
        make: _makeController.text,
        model: _modelController.text,
        year: int.parse(_yearController.text),
        price: double.parse(_priceController.text),
        mileage: int.parse(_mileageController.text),
        condition: _conditionController.text,
        location: _locationController.text,
        images: widget.car.images, // Keep existing images
        status: widget.car.status,
        createdAt: widget.car.createdAt,
      );

      context.read<CarBloc>().add(UpdateCarEvent(updatedCar));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CarBloc>(),
      child: BlocConsumer<CarBloc, CarState>(
        listener: (context, state) {
          if (state is CarOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.pop(); // Go back to My Listings
          } else if (state is CarError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Edit Car'),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _makeController,
                      decoration: const InputDecoration(labelText: 'Make'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _modelController,
                      decoration: const InputDecoration(labelText: 'Model'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _yearController,
                            decoration: const InputDecoration(labelText: 'Year'),
                            keyboardType: TextInputType.number,
                            validator: (value) => value!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(labelText: 'Price (\$)'),
                            keyboardType: TextInputType.number,
                            validator: (value) => value!.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _mileageController,
                      decoration: const InputDecoration(labelText: 'Mileage (km)'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(labelText: 'Location'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _conditionController.text,
                      decoration: const InputDecoration(labelText: 'Condition'),
                      items: ['New', 'Used', 'Damaged']
                          .map((condition) => DropdownMenuItem(
                                value: condition,
                                child: Text(condition),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _conditionController.text = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: state is CarLoading ? null : () => _submitUpdate(context),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: state is CarLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Update Car'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
