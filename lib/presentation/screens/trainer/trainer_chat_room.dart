import 'package:eatmehv2/bloc/auth/auth_bloc.dart';
import 'package:eatmehv2/data/models/chat/message_model.dart';
import 'package:eatmehv2/data/repos/chat_room_repo.dart';
import 'package:eatmehv2/data/services/chat_room_service.dart';
import 'package:eatmehv2/presentation/screens/trainer/trainer_goal_detail.dart';
import 'package:eatmehv2/presentation/screens/user/profile_screen.dart';
import 'package:eatmehv2/presentation/screens/user/user_feedback_screen.dart';
import 'package:eatmehv2/presentation/widgets/trainer_chat_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TrainerChatRoom extends StatefulWidget {
  final String receiverUid;
  final String receiverName;
  final String receiverImage;

  const TrainerChatRoom({
    super.key,
    required this.receiverUid,
    required this.receiverName,
    required this.receiverImage,
  });

  @override
  State<TrainerChatRoom> createState() => _TrainerChatRoomState();
}

class _TrainerChatRoomState extends State<TrainerChatRoom> {
  final TextEditingController _controller = TextEditingController();
  final chatRepo = ChatRoomRepo(ChatRoomService());

  late String currentUserUid;
  @override
  void initState() {
    super.initState();

    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      currentUserUid = authState.user.uid;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to chat.')),
        );
      });
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state as Authenticated;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: TrainerChatAppBar(
          receiverName: widget.receiverName,
          receiverImage: widget.receiverImage,
          isTrainer: authState.user.role == 'trainer',
          onBack: () {
            Navigator.pop(context);
          },
          onProfileTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(userUid: widget.receiverUid),
              ),
            );
          },
          onFeedbackTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => UserFeedbackScreen(trainerUid: widget.receiverUid),
              ),
            );
          },
          onAgendaTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TrainerGoalDetail(traineeUid: currentUserUid),
              ),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Message list
            Expanded(
              child: StreamBuilder<List<MessageModel>>(
                stream: chatRepo.getMessages(
                  currentUserUid,
                  widget.receiverUid,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Handle errors
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  // Check if have data
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data!;

                  // Only show "Say hi" if we're connected AND truly have no messages
                  if (messages.isEmpty &&
                      snapshot.connectionState == ConnectionState.active) {
                    return const Center(child: Text("Say hi 👋"));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderUid == currentUserUid;

                      return Align(
                        key: ValueKey(message.id),
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color:
                                isMe ? Colors.blue[200] : Colors.grey.shade300,
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          child: Text(
                            message.message,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Input field
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(10),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: "Write message...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.blue),
                      onPressed: () async {
                        if (_controller.text.trim().isEmpty) return;
                        await chatRepo.sendMessage(
                          currentUserUid,
                          widget.receiverUid,
                          _controller.text.trim(),
                        );
                        _controller.clear();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
