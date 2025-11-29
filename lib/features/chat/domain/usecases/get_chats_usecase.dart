import 'package:injectable/injectable.dart';
import '../entities/chat_entity.dart';
import '../repositories/chat_repository.dart';

@lazySingleton
class GetChatsUseCase {
  final ChatRepository repository;

  GetChatsUseCase(this.repository);

  Stream<List<ChatEntity>> call(String userId) {
    return repository.getChats(userId);
  }
}
