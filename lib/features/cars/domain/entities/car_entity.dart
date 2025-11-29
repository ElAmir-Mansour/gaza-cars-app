import 'package:equatable/equatable.dart';

class CarEntity extends Equatable {
  final String id;
  final String sellerId;
  final String sellerPhone; // Added for contact seller feature
  final String make;
  final String model;
  final int year;
  final double price;
  final int mileage;
  final String condition; // 'new', 'used', 'damaged'
  final String location;
  final String description; // Added description field
  final List<String> images;
  final String status; // 'active', 'sold', 'pending'
  final DateTime createdAt;

  const CarEntity({
    required this.id,
    required this.sellerId,
    this.sellerPhone = '', // Optional, defaults to empty
    required this.make,
    required this.model,
    required this.year,
    required this.price,
    required this.mileage,
    required this.condition,
    required this.location,
    this.description = '', // Optional, defaults to empty
    required this.images,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object> get props => [
        id,
        sellerId,
        sellerPhone,
        make,
        model,
        year,
        price,
        mileage,
        condition,
        location,
        description,
        images,
        status,
        createdAt,
      ];
}
