import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/admin_repository.dart';

@lazySingleton
class UnbanUserUseCase {
  final AdminRepository repository;

  UnbanUserUseCase(this.repository);

  Future<Either<Failure, void>> call(String userId) {
    return repository.unbanUser(userId);
  }
}
