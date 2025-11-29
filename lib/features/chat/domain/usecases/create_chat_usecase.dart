import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/chat_repository.dart';

@lazySingleton
class CreateChatUseCase {
  final ChatRepository repository;

  CreateChatUseCase(this.repository);

  Future<Either<Failure, String>> call(String otherUserId, String carId, String carName) {
    return repository.createChat(otherUserId, carId, carName);
  }
}
