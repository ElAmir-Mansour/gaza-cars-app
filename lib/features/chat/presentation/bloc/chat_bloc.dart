import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/usecases/get_chats_usecase.dart';
import '../../domain/usecases/create_chat_usecase.dart';
import '../../../auth/domain/usecases/block_user_usecase.dart';
import 'chat_event.dart';
import 'chat_state.dart';

@injectable
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetChatsUseCase getChatsUseCase;
  final CreateChatUseCase createChatUseCase;
  final BlockUserUseCase blockUserUseCase;
  StreamSubscription? _chatsSubscription;

  ChatBloc({
    required this.getChatsUseCase,
    required this.createChatUseCase,
    required this.blockUserUseCase,
  }) : super(ChatInitial()) {
    on<LoadChats>(_onLoadChats);
    on<CreateChatEvent>(_onCreateChat);
    on<BlockUserEvent>(_onBlockUser);
    on<_ChatsUpdated>(_onChatsUpdated);
    on<_ChatErrorOccurred>(_onChatErrorOccurred);
  }

  Future<void> _onLoadChats(LoadChats event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    await _chatsSubscription?.cancel();
    _chatsSubscription = getChatsUseCase(event.userId).listen(
      (chats) => add(_ChatsUpdated(chats)),
      onError: (error) => add(_ChatErrorOccurred(error.toString())),
    );
  }

  Future<void> _onCreateChat(CreateChatEvent event, Emitter<ChatState> emit) async {
    final result = await createChatUseCase(event.otherUserId, event.carId, event.carName);
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (chatId) => emit(ChatCreated(chatId)),
    );
  }

  Future<void> _onBlockUser(BlockUserEvent event, Emitter<ChatState> emit) async {
    final result = await blockUserUseCase(event.userId);
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (_) => null, // Success, maybe emit a state or just let the UI handle it via snackbar if we had a specific state
    );
    // Ideally we should reload chats or filter them, but for now we just block.
    // The UI should probably navigate back or show a message.
  }

  void _onChatsUpdated(_ChatsUpdated event, Emitter<ChatState> emit) {
    emit(ChatLoaded(event.chats));
  }

  void _onChatErrorOccurred(_ChatErrorOccurred event, Emitter<ChatState> emit) {
    emit(ChatError(event.message));
  }

  @override
  Future<void> close() {
    _chatsSubscription?.cancel();
    return super.close();
  }
}

// Internal events for Stream updates
class _ChatsUpdated extends ChatEvent {
  final List<ChatEntity> chats;
  const _ChatsUpdated(this.chats);
  
  @override
  List<Object?> get props => [chats];
}

class _ChatErrorOccurred extends ChatEvent {
  final String message;
  const _ChatErrorOccurred(this.message);

  @override
  List<Object?> get props => [message];
}
