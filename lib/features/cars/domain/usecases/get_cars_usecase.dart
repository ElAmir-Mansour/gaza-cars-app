import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/car_entity.dart';
import '../repositories/car_repository.dart';

@lazySingleton
class GetCarsUseCase implements UseCase<List<CarEntity>, GetCarsParams> {
  final CarRepository repository;

  GetCarsUseCase(this.repository);

  @override
  Future<Either<Failure, List<CarEntity>>> call(GetCarsParams params) async {
    return await repository.getCars(
      startAfterValues: params.startAfterValues,
      minPrice: params.minPrice,
      maxPrice: params.maxPrice,
      condition: params.condition,
      location: params.location,
      query: params.query,
      transmission: params.transmission,
      fuelType: params.fuelType,
      make: params.make,
      year: params.year,
    );
  }
}

class GetCarsParams extends Equatable {
  final List<Object>? startAfterValues; // Added this field
  final double? minPrice;
  final double? maxPrice;
  final String? condition;
  final String? location;
  final String? query;
  final String? transmission;
  final String? fuelType;
  final String? make;
  final int? year;
  
  const GetCarsParams({
    this.startAfterValues, // Added this to constructor
    this.minPrice,
    this.maxPrice,
    this.condition,
    this.location,
    this.query,
    this.transmission,
    this.fuelType,
    this.make,
    this.year,
  });

  @override
  List<Object?> get props => [
        startAfterValues,
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
