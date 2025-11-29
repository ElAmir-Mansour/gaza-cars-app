import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../bloc/message_bloc.dart';
import '../bloc/message_event.dart';
import '../bloc/message_state.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';

class ChatPage extends StatefulWidget {
  final String chatId;
  final String? title;
  final String? otherUserId;

  const ChatPage({super.key, required this.chatId, this.title, this.otherUserId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    String? userId;
    if (authState is AuthAuthenticated) {
      userId = authState.user.uid;
    }

    if (userId == null) {
      return Scaffold(
        body: Center(child: Text(AppLocalizations.of(context)!.loginToChat)),
      );
    }

    return BlocProvider(
      create: (context) => sl<MessageBloc>()..add(LoadMessages(widget.chatId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title ?? AppLocalizations.of(context)!.chat),
          actions: [
            if (widget.otherUserId != null)
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'block') {
                    _showBlockDialog(context, widget.otherUserId!);
                  } else if (value == 'report') {
                     // TODO: Implement report user
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'block',
                    child: Row(
                      children: [
                        Icon(Icons.block, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Block User', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<MessageBloc, MessageState>(
                builder: (context, state) {
                  if (state is MessageLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is MessageLoaded) {
                    if (state.messages.isEmpty) {
                      return Center(child: Text(AppLocalizations.of(context)!.noMessagesSayHi));
                    }
                    return ListView.builder(
                      reverse: false, // Usually chat is reverse, but Firestore order is asc. We can reverse list or builder.
                      // If we want latest at bottom, we keep order asc and scroll to bottom, OR order desc and reverse: true.
                      // Our query is asc. So item 0 is oldest.
                      // ListView should start from bottom?
                      // Better: Query desc, reverse: true.
                      // But our query is asc.
                      // Let's just use standard list and scroll to bottom on load?
                      // Or better: reverse the list in UI and reverse: true.
                      
                      // Let's keep it simple: standard list.
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final message = state.messages[index];
                        final isMe = message.senderId == userId;
                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blue : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.text,
                                  style: TextStyle(color: isMe ? Colors.white : Colors.black),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('HH:mm').format(message.timestamp),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isMe ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state is MessageError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.typeMessage,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Builder(
                    builder: (context) {
                      return IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          final text = _textController.text.trim();
                          if (text.isNotEmpty) {
                            context.read<MessageBloc>().add(SendMessage(
                              chatId: widget.chatId,
                              text: text,
                              senderId: userId!,
                            ));
                            _textController.clear();
                          }
                        },
                      );
                    }
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showBlockDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User?'),
        content: const Text('You will no longer receive messages from this user.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ChatBloc>().add(BlockUserEvent(userId));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User blocked')),
              );
            },
            child: const Text('Block', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
