import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/car_entity.dart';
import '../../domain/repositories/car_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../datasources/car_remote_data_source.dart';

@LazySingleton(as: CarRepository)
class CarRepositoryImpl implements CarRepository {
  final CarRemoteDataSource remoteDataSource;

  CarRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<CarEntity>>> getCars({
    List<Object>? startAfterValues,
    double? minPrice,
    double? maxPrice,
    String? condition,
    String? location,
    String? query,
    String? transmission,
    String? fuelType,
    String? make,
    int? year,
  }) async {
    try {
      final cars = await remoteDataSource.getCars(
        startAfterValues: startAfterValues,
        minPrice: minPrice,
        maxPrice: maxPrice,
        condition: condition,
        location: location,
        query: query,
        transmission: transmission,
        fuelType: fuelType,
        make: make,
        year: year,
      );
      return Right(cars);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CarEntity>> getCarById(String id) async {
    try {
      final car = await remoteDataSource.getCarById(id);
      return Right(car);
    } on Failure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, void>> addCar(CarEntity car) async {
    try {
      await remoteDataSource.addCar(car);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, void>> updateCar(CarEntity car) async {
    try {
      await remoteDataSource.updateCar(car);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, void>> deleteCar(String id) async {
    try {
      await remoteDataSource.deleteCar(id);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    }
  }
  @override
  Future<Either<Failure, List<String>>> uploadCarImages(List<File> images) async {
    try {
      final imageUrls = await remoteDataSource.uploadCarImages(images);
      return Right(imageUrls);
    } on Failure catch (e) {
      return Left(e);
    }
  }
  @override
  Future<Either<Failure, void>> toggleFavorite(String carId, String userId) async {
    try {
      await remoteDataSource.toggleFavorite(carId, userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<CarEntity>>> getFavorites(String userId) async {
    try {
      final result = await remoteDataSource.getFavorites(userId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
