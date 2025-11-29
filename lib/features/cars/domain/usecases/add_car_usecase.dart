import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/car_entity.dart';
import '../repositories/car_repository.dart';

@lazySingleton
class AddCarUseCase implements UseCase<void, CarEntity> {
  final CarRepository repository;

  AddCarUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(CarEntity params) async {
    return await repository.addCar(params);
  }
}
