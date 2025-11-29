import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../cars/domain/entities/car_entity.dart';
import '../repositories/admin_repository.dart';

@lazySingleton
class GetPendingCarsUseCase {
  final AdminRepository repository;

  GetPendingCarsUseCase(this.repository);

  Future<Either<Failure, List<CarEntity>>> call() {
    return repository.getPendingCars();
  }
}
