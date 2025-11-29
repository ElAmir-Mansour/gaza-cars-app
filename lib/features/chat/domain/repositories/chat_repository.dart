import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat_entity.dart';
import '../entities/message_entity.dart';

abstract class ChatRepository {
  Stream<List<ChatEntity>> getChats(String userId);
  Stream<List<MessageEntity>> getMessages(String chatId);
  Future<Either<Failure, void>> sendMessage(String chatId, MessageEntity message);
  Future<Either<Failure, String>> createChat(String otherUserId, String carId, String carName);
}
