import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<Map<String, dynamic>> notifications = [
    {
      'icon': Icons.notifications,
      'title': 'Irrigation Reminder',
      'description': 'Time to irrigate your maize fields.',
      'timestamp': '2025-03-10 08:30 AM',
      'isRead': false,
    },
    {
      'icon': Icons.warning,
      'title': 'Fertilization Alert',
      'description': 'Don’t forget to fertilize your crops today.',
      'timestamp': '2025-03-09 02:15 PM',
      'isRead': true,
    },
    {
      'icon': Icons.update,
      'title': 'Weather Update',
      'description': 'Rain expected this weekend.',
      'timestamp': '2025-03-08 11:00 AM',
      'isRead': false,
    },
  ];

  void _markAsRead(int index) {
    setState(() {
      notifications[index]['isRead'] = true;
    });
  }

  void _clearAllNotifications() {
    setState(() {
      notifications.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearAllNotifications,
            tooltip: 'Clear All Notifications',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            notifications.isEmpty
                ? Center(
                  child: Text(
                    'No new notifications',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                )
                : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: Icon(
                          notification['icon'],
                          color:
                              notification['isRead']
                                  ? Colors.grey
                                  : Colors.green,
                        ),
                        title: Text(
                          notification['title'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                notification['isRead']
                                    ? Colors.grey
                                    : Colors.black,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notification['description']),
                            Text(
                              notification['timestamp'],
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.check_circle),
                          color:
                              notification['isRead']
                                  ? Colors.green
                                  : Colors.grey,
                          onPressed: () => _markAsRead(index),
                        ),
                        onTap: () {
                          // Action when tapped (e.g., view task or details)
                          _markAsRead(index);
                        },
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
