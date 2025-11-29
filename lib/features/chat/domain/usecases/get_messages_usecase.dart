import 'package:injectable/injectable.dart';
import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

@lazySingleton
class GetMessagesUseCase {
  final ChatRepository repository;

  GetMessagesUseCase(this.repository);

  Stream<List<MessageEntity>> call(String chatId) {
    return repository.getMessages(chatId);
  }
}
