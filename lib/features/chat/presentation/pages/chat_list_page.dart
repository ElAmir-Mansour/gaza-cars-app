import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../features/cars/presentation/widgets/listing_shimmer.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    String? userId;
    if (authState is AuthAuthenticated) {
      userId = authState.user.uid;
    }

    if (userId == null) {
      return Scaffold(
        body: Center(child: Text(AppLocalizations.of(context)!.loginToViewChats)),
      );
    }

    return BlocProvider(
      create: (context) => sl<ChatBloc>()..add(LoadChats(userId!)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.messages),
        ),
        body: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            if (state is ChatLoading) {
              return const ListingShimmer();
            } else if (state is ChatLoaded) {
              if (state.chats.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.chat_bubble_outline,
                  title: AppLocalizations.of(context)!.noMessagesYet,
                  subtitle: 'Start a conversation with a seller!',
                );
              }
              return ListView.builder(
                itemCount: state.chats.length,
                itemBuilder: (context, index) {
                  final chat = state.chats[index];
                  // In a real app, we'd fetch the other user's name/avatar here or store it in the chat doc.
                  // For now, we use the car name or "Chat".
                  
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(chat.carName ?? AppLocalizations.of(context)!.chat),
                    subtitle: Text(
                      chat.lastMessage.isNotEmpty ? chat.lastMessage : AppLocalizations.of(context)!.noMessages,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      DateFormat('MMM d, HH:mm').format(chat.lastMessageTime),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                      final otherUserId = chat.participants.firstWhere((id) => id != userId, orElse: () => '');
                      context.push('/chat/${chat.id}', extra: {
                        'title': chat.carName,
                        'otherUserId': otherUserId,
                      });
                    },
                  );
                },
              );
            } else if (state is ChatError) {
              return EmptyStateWidget(
                icon: Icons.error_outline,
                title: 'Error',
                subtitle: state.message,
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
