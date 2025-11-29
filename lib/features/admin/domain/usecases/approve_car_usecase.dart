import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/admin_repository.dart';

@lazySingleton
class ApproveCarUseCase {
  final AdminRepository repository;

  ApproveCarUseCase(this.repository);

  Future<Either<Failure, void>> call(String carId) {
    return repository.approveCar(carId);
  }
}
