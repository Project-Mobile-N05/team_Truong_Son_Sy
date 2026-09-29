import 'package:flutter/material.dart';
import 'reminder_manager.dart';

class ReminderScreen extends StatelessWidget {
  ReminderScreen({super.key});

  final ReminderManager reminderManager = ReminderManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý nhắc nhở', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(8)
              ),
              child: const Row(
                children: [
                  Icon(Icons.notifications_active, color: Colors.deepPurple),
                  SizedBox(width: 10),
                  Text('1 nhắc nhở đang bật', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Nhắc nhở của bạn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.assignment, color: Colors.blue),
                title: Text(reminderManager.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Hạn: ${reminderManager.dueDate}\nTrạng thái: ${reminderManager.status}'),
                isThreeLine: true,
                trailing: Switch(
                  value: true,
                  onChanged: (bool value) {},
                  activeColor: Colors.deepPurple,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}