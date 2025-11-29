import 'package:equatable/equatable.dart';

abstract class MessageEvent extends Equatable {
  const MessageEvent();

  @override
  List<Object?> get props => [];
}

class LoadMessages extends MessageEvent {
  final String chatId;

  const LoadMessages(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

class SendMessage extends MessageEvent {
  final String chatId;
  final String text;
  final String senderId;

  const SendMessage({
    required this.chatId,
    required this.text,
    required this.senderId,
  });

  @override
  List<Object?> get props => [chatId, text, senderId];
}
