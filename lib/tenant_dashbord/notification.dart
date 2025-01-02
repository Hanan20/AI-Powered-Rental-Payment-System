import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> notifications = [];
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    // Retrieve notifications from Firestore
    final snapshot =
        await FirebaseFirestore.instance.collection('Notifications').get();

    setState(() {
      notifications = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Include the document ID
        return data;
      }).toList();
    });
  }

  Future<void> markAsRead(String notificationId) async {
    // Update the 'read' status in Firestore
    await FirebaseFirestore.instance
        .collection('Notifications')
        .doc(notificationId)
        .update({'read': true});

    setState(() {
      notifications = notifications.map((n) {
        if (n['id'] == notificationId) {
          n['read'] = true;
        }
        return n;
      }).toList();
    });
  }

  List<Map<String, dynamic>> getFilteredNotifications() {
    if (selectedFilter == 'Unread') {
      return notifications.where((n) => n['read'] == false).toList();
    }
    return notifications;
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = getFilteredNotifications();

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
      body: filteredNotifications.isEmpty
          ? const Center(child: Text('No notifications yet'))
          : ListView.builder(
              itemCount: filteredNotifications.length,
              itemBuilder: (context, index) {
                final notification = filteredNotifications[index];
                final isRead = notification['read'] ?? false;
                final timestamp = notification['timestamp'] != null
                    ? (notification['timestamp'] as Timestamp).toDate()
                    : DateTime.now();

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      notification['title'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification['body'] ?? ''),
                        const SizedBox(height: 4),
                        Text(
                          'Received: ${timestamp.toLocal()}',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    trailing: Icon(Icons.arrow_forward_ios,
                        color: Colors.grey.shade400, size: 18),
                    onTap: () {
                      markAsRead(notification['id']);
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(notification['title'] ?? ''),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(notification['body'] ?? ''),
                              const SizedBox(height: 10),
                              Text(
                                'Received: ${timestamp.toLocal()}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade600),
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
            ),
    );
  }
}
