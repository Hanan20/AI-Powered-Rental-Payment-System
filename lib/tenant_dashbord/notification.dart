import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  String selectedFilter = 'All';

  /// Marks a given notification document as read in Firestore.
  Future<void> markAsRead(String notificationId) async {
    await FirebaseFirestore.instance
        .collection('Notifications')
        .doc(notificationId)
        .update({'read': true});
  }

  /// Applies the filter to a list of notifications from the snapshot.
  List<QueryDocumentSnapshot> filterNotifications(
      List<QueryDocumentSnapshot> docs) {
    if (selectedFilter == 'Unread') {
      // Return only unread notifications
      return docs.where((doc) => !(doc['read'] ?? false)).toList();
    }
    // If "All", just return everything
    return docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Notifications',
            style: TextStyle(color: Color.fromARGB(255, 235, 238, 238)),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 12, 112, 117),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All')),
              const PopupMenuItem(value: 'Unread', child: Text('Unread')),
            ],
          ),
        ],
      ),

      /// Instead of a one-time `.get()`, we use `StreamBuilder` so the UI updates live
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // Show loader while connecting
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle any errors
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          // If no data or empty, show a placeholder
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No notifications yet'));
          }

          // We have data, let's apply our filter
          final docs = filterNotifications(snapshot.data!.docs);

          if (docs.isEmpty) {
            // If user selected "Unread" but there are no unread, show no notifications
            return const Center(child: Text('No notifications yet'));
          }

          // Display the filtered list
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final notificationId = doc.id;
              final isRead = data['read'] ?? false;
              final title = data['title'] ?? '';
              final body = data['body'] ?? '';
              final timestamp = data['timestamp'] != null
                  ? (data['timestamp'] as Timestamp).toDate()
                  : DateTime.now();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 3,
                child: ListTile(
                  leading: Icon(
                    isRead ? Icons.notifications : Icons.notifications_active,
                    color: isRead ? Colors.grey : Colors.blue,
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(body),
                      const SizedBox(height: 4),
                      Text(
                        'Received: $timestamp',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey.shade400,
                    size: 18,
                  ),
                  onTap: () {
                    // Mark as read
                    markAsRead(notificationId);

                    // Show a dialog with the full details
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(title),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(body),
                            const SizedBox(height: 10),
                            Text(
                              'Received: $timestamp',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
