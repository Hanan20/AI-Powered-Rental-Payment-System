import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // NEW IMPORT
import 'package:flutter/material.dart';
import 'chat_service.dart';

class ChatPage extends StatefulWidget {
  final String landlordEmail;
  final String tenantEmail;
  const ChatPage(
      {super.key, required this.landlordEmail, required this.tenantEmail});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  String? _chatId;

  @override
  void initState() {
    super.initState();
    setupChat();
  }

  // Setup the chat and get the chat ID
  Future<void> setupChat() async {
    String chatId = await _chatService.createChatIfNotExists(
      widget.landlordEmail,
      widget.tenantEmail,
    );
    setState(() {
      _chatId = chatId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: _chatId == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                    stream: _chatService.getMessages(_chatId!),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Error loading messages');
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final messages = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final sender = message['sender'];
                          final text = message['text'];

                          return ListTile(
                            title: Align(
                              alignment: sender == widget.landlordEmail
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: sender == widget.landlordEmail
                                      ? Colors.blue[100]
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(text),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),

          // Message input field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration:
                        const InputDecoration(hintText: 'Type your message...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final currentUserEmail =
                        FirebaseAuth.instance.currentUser?.email;
                    if (_messageController.text.trim().isNotEmpty &&
                        currentUserEmail != null) {
                      _chatService.sendMessage(
                        chatId: _chatId!,
                        senderEmail:
                            currentUserEmail, // Use current user's email
                        messageText: _messageController.text.trim(),
                      );
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
