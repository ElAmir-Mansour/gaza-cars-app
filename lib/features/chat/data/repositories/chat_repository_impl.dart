import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';
import '../models/message_model.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final FirebaseAuth auth;

  ChatRepositoryImpl({required this.remoteDataSource, required this.auth});

  @override
  Stream<List<ChatEntity>> getChats(String userId) {
    return remoteDataSource.getChats(userId);
  }

  @override
  Stream<List<MessageEntity>> getMessages(String chatId) {
    return remoteDataSource.getMessages(chatId);
  }

  @override
  Future<Either<Failure, void>> sendMessage(String chatId, MessageEntity message) async {
    try {
      final messageModel = MessageModel(
        id: message.id,
        senderId: message.senderId,
        text: message.text,
        timestamp: message.timestamp,
        isRead: message.isRead,
      );
      await remoteDataSource.sendMessage(chatId, messageModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, String>> createChat(String otherUserId, String carId, String carName) async {
    try {
      final currentUserId = auth.currentUser?.uid;
      if (currentUserId == null) {
        return const Left(ServerFailure('User not authenticated'));
      }
      final chatId = await remoteDataSource.createChat(currentUserId, otherUserId, carId, carName);
      return Right(chatId);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
