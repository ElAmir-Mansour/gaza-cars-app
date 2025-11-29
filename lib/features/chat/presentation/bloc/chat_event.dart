import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadChats extends ChatEvent {
  final String userId;

  const LoadChats(this.userId);

  @override
  List<Object?> get props => [userId];
}

class CreateChatEvent extends ChatEvent {
  final String otherUserId;
  final String carId;
  final String carName;

  const CreateChatEvent({
    required this.otherUserId,
    required this.carId,
    required this.carName,
  });

  @override
  List<Object?> get props => [otherUserId, carId, carName];
}
class BlockUserEvent extends ChatEvent {
  final String userId;

  const BlockUserEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}
