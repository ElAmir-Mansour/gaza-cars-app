import 'package:equatable/equatable.dart';

class ChatEntity extends Equatable {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String? carId;
  final String? carName; // Optional: Snapshot of car name for display
  final String? otherUserName; // Helper for UI, fetched separately or stored
  final String? otherUserImage; // Helper for UI

  const ChatEntity({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    this.carId,
    this.carName,
    this.otherUserName,
    this.otherUserImage,
  });

  @override
  List<Object?> get props => [id, participants, lastMessage, lastMessageTime, carId, carName, otherUserName, otherUserImage];
}
