import 'package:flutter/material.dart';
import '../controllers/reminder_manager.dart';
import '../widgets/pastel_tile.dart';
import '../widgets/screen_header.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final ReminderManager reminderManager = ReminderManager();
  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
    final on = _enabled ? 1 : 0;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            const ScreenHeader('Nhắc nhở'),
            Row(
              children: [
                Expanded(
                  child: PastelTile(
                    title: '$on',
                    subtitle: 'Đang bật',
                    color: const Color(0xFFEAF9D6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PastelTile(
                    title: '${1 - on}',
                    subtitle: 'Đã tắt',
                    color: const Color(0xFFFFF1D6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Nhắc nhở của bạn',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            SoftCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(reminderManager.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text('Hạn: ${reminderManager.dueDate}',
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF5F5A70))),
                        Text('Trạng thái: ${reminderManager.status}',
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF5F5A70))),
                      ],
                    ),
                  ),
                  Switch(
                    value: _enabled,
                    onChanged: (v) => setState(() => _enabled = v),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
