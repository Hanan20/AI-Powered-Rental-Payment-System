import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, String>> notifications = [];
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNotifications = prefs.getStringList('notifications') ?? [];
    setState(() {
      notifications = savedNotifications.map((e) {
        final parts = e.split('|');
        return {
          'title': parts[0],
          'body': parts[1],
          'data': parts[2],
          'timestamp':
              parts.length > 3 ? parts[3] : DateTime.now().toIso8601String(),
          'read': parts.length > 4 ? parts[4] : 'false',
        };
      }).toList();
    });
  }

  Future<void> markAsRead(int index) async {
    notifications[index]['read'] = 'true';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'notifications',
      notifications
          .map((n) =>
              '${n['title']}|${n['body']}|${n['data']}|${n['timestamp']}|${n['read']}')
          .toList(),
    );
    setState(() {});
  }

  List<Map<String, String>> getFilteredNotifications() {
    if (selectedFilter == 'Unread') {
      return notifications.where((n) => n['read'] == 'false').toList();
    }
    return notifications;
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = getFilteredNotifications();

    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: const Text(
          'Notifications',
          style: TextStyle(color: Color.fromARGB(255, 235, 238, 238)),
        )),
        backgroundColor: Color.fromARGB(255, 12, 112, 117),
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
                final isRead = notification['read'] == 'true';
                final timestamp = DateTime.parse(notification['timestamp']!);

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
                      markAsRead(index);
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
                              Text('Additional Data: ${notification['data']}'),
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
