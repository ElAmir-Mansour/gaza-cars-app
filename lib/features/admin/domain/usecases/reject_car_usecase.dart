import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/admin_repository.dart';

@lazySingleton
class RejectCarUseCase {
  final AdminRepository repository;

  RejectCarUseCase(this.repository);

  Future<Either<Failure, void>> call(String carId, String reason) {
    return repository.rejectCar(carId, reason);
  }
}
