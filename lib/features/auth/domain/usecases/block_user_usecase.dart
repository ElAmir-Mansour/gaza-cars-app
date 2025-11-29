import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class BlockUserUseCase {
  final AuthRepository repository;

  BlockUserUseCase(this.repository);

  Future<Either<Failure, void>> call(String userId) async {
    return await repository.blockUser(userId);
  }
}
