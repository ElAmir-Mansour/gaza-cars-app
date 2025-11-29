import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Stream<List<ChatModel>> getChats(String userId);
  Stream<List<MessageModel>> getMessages(String chatId);
  Future<void> sendMessage(String chatId, MessageModel message);
  Future<String> createChat(String currentUserId, String otherUserId, String carId, String carName);
}

@LazySingleton(as: ChatRemoteDataSource)
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore firestore;

  ChatRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<List<ChatModel>> getChats(String userId) {
    return firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChatModel.fromSnapshot(doc)).toList();
    });
  }

  @override
  Stream<List<MessageModel>> getMessages(String chatId) {
    return firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => MessageModel.fromSnapshot(doc)).toList();
    });
  }

  @override
  Future<void> sendMessage(String chatId, MessageModel message) async {
    try {
      final chatRef = firestore.collection('chats').doc(chatId);
      final messagesRef = chatRef.collection('messages');

      await firestore.runTransaction((transaction) async {
        // Add message
        transaction.set(messagesRef.doc(), message.toJson());

        // Update chat last message
        transaction.update(chatRef, {
          'lastMessage': message.text,
          'lastMessageTime': Timestamp.fromDate(message.timestamp),
        });
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> createChat(String currentUserId, String otherUserId, String carId, String carName) async {
    try {
      // Deterministic ID: sort user IDs to ensure consistency
      final ids = [currentUserId, otherUserId]..sort();
      final chatId = '${ids[0]}_${ids[1]}_$carId';

      final chatRef = firestore.collection('chats').doc(chatId);
      final chatDoc = await chatRef.get();

      if (!chatDoc.exists) {
        await chatRef.set({
          'participants': [currentUserId, otherUserId],
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'carId': carId,
          'carName': carName,
        });
      }

      return chatId;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
