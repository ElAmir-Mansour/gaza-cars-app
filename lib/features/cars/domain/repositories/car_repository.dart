import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/car_entity.dart';

abstract class CarRepository {
  Future<Either<Failure, List<CarEntity>>> getCars({
    List<Object>? startAfterValues,
    DateTime? startAfter,
    double? minPrice,
    double? maxPrice,
    String? condition,
    String? location,
    String? query,
    String? transmission,
    String? fuelType,
    String? make,
    int? year,
  });
  Future<Either<Failure, CarEntity>> getCarById(String id);
  Future<Either<Failure, void>> addCar(CarEntity car);
  Future<Either<Failure, void>> updateCar(CarEntity car);
  Future<Either<Failure, void>> deleteCar(String id);
  Future<Either<Failure, List<String>>> uploadCarImages(List<File> images);
  Future<Either<Failure, void>> toggleFavorite(String carId, String userId);
  Future<Either<Failure, List<CarEntity>>> getFavorites(String userId);
}
