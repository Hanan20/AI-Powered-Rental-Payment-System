import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to send a message
  Future<void> sendMessage({
    required String chatId,
    required String senderEmail,
    required String messageText,
  }) async {
    final messageRef =
        _firestore.collection('Chats').doc(chatId).collection('messages');

    await messageRef.add({
      'sender': senderEmail,
      'text': messageText,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  // Function to get chat messages in real-time
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('Chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Function to create a chat document if it doesn't exist
  Future<String> createChatIfNotExists(
      String landlordEmail, String tenantEmail) async {
    // Query for existing chat
    QuerySnapshot chatQuery = await _firestore
        .collection('Chats')
        .where('participants', arrayContains: landlordEmail)
        .get();

    for (var doc in chatQuery.docs) {
      List participants = doc['participants'];
      if (participants.contains(tenantEmail)) {
        return doc.id; // Chat already exists
      }
    }

    // If no chat exists, create a new one
    DocumentReference newChat = await _firestore.collection('Chats').add({
      'participants': [landlordEmail, tenantEmail],
      'createdAt': FieldValue.serverTimestamp(),
    });

    return newChat.id; // Return new chat ID
  }
}
