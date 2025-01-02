import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_service.dart';

class ChatPage extends StatefulWidget {
  final String landlordEmail;
  final String tenantEmail;

  const ChatPage({
    super.key,
    required this.landlordEmail,
    required this.tenantEmail,
  });

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
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Chat/Message',
            style: TextStyle(color: Color.fromARGB(255, 235, 238, 238)),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 12, 112, 117),
      ),
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
                          final isCurrentUser = sender ==
                              FirebaseAuth.instance.currentUser?.email;

                          return Align(
                            alignment: isCurrentUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isCurrentUser
                                    ? Colors.blue[100]
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                  bottomLeft: isCurrentUser
                                      ? Radius.circular(12)
                                      : Radius.zero,
                                  bottomRight: isCurrentUser
                                      ? Radius.zero
                                      : Radius.circular(12),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sender == widget.landlordEmail
                                        ? 'Landlord'
                                        : 'Tenant',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    text,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),

          // Message input field inside a box
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              border: Border.all(
                color: Colors.grey.shade400,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send,
                      color: Color.fromARGB(255, 12, 112, 117)),
                  onPressed: () {
                    final currentUserEmail =
                        FirebaseAuth.instance.currentUser?.email;
                    if (_messageController.text.trim().isNotEmpty &&
                        currentUserEmail != null) {
                      _chatService.sendMessage(
                        chatId: _chatId!,
                        senderEmail: currentUserEmail,
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
