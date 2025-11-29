import 'package:equatable/equatable.dart';
import '../../domain/entities/car_entity.dart';

abstract class CarState extends Equatable {
  const CarState();
  
  @override
  List<Object?> get props => [];
}

class CarInitial extends CarState {}

class CarLoading extends CarState {}

class CarLoaded extends CarState {
  final List<CarEntity> cars;
  final List<CarEntity> filteredCars;
  final bool hasReachedMax;
  final bool isFetchingMore;
  
  // Filters
  final double? minPrice;
  final double? maxPrice;
  final String? condition;
  final String? location;
  final String? query;
  final String? transmission;
  final String? fuelType;
  final String? make;
  final int? year;

  const CarLoaded({
    required this.cars,
    this.minPrice,
    this.maxPrice,
    this.condition,
    this.location,
    this.query,
    this.transmission,
    this.fuelType,
    this.make,
    this.year,
    this.hasReachedMax = false,
  });

  CarLoaded copyWith({
    List<CarEntity>? cars,
    // Removed filteredCars and isFetchingMore as per instruction
    bool? hasReachedMax,
    double? minPrice,
    double? maxPrice,
    String? condition,
    String? location,
    String? query,
    String? transmission,
    String? fuelType,
    String? make,
    int? year,
  }) {
    return CarLoaded(
      cars: cars ?? this.cars,
      // Removed filteredCars and isFetchingMore as per instruction
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      condition: condition ?? this.condition,
      location: location ?? this.location,
      query: query ?? this.query,
      transmission: transmission ?? this.transmission,
      fuelType: fuelType ?? this.fuelType,
      make: make ?? this.make,
      year: year ?? this.year,
    );
  }

  @override
  List<Object?> get props => [
    cars, 
    // Removed filteredCars and isFetchingMore as per instruction
    hasReachedMax, 
    minPrice,
    maxPrice,
    condition,
    location,
    query,
    transmission,
    fuelType,
    make,
    year,
  ];
}

class CarOperationSuccess extends CarState {
  final String message;

  const CarOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CarError extends CarState {
  final String message;

  const CarError(this.message);

  @override
  List<Object?> get props => [message];
}

class CarImagesUploaded extends CarState {
  final List<String> imageUrls;

  const CarImagesUploaded(this.imageUrls);

  @override
  List<Object?> get props => [imageUrls];
}
