import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/admin_repository.dart';

@lazySingleton
class BanUserUseCase {
  final AdminRepository repository;

  BanUserUseCase(this.repository);

  Future<Either<Failure, void>> call(String userId, String reason) {
    return repository.banUser(userId, reason);
  }
}
