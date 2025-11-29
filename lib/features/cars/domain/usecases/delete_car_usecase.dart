import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/car_repository.dart';

@lazySingleton
class DeleteCarUseCase implements UseCase<void, String> {
  final CarRepository repository;

  DeleteCarUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) async {
    return await repository.deleteCar(params);
  }
}
