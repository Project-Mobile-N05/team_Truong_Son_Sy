import 'package:flutter/material.dart';
import '../controllers/reminder_controller.dart';
import '../models/reminder_data.dart';
import '../widgets/pastel_tile.dart';
import '../widgets/screen_header.dart';

/// Màn hình Nhắc nhở: đếm bật/tắt, danh sách nhắc nhở, công tắc bật/tắt, xóa.
/// Nhắc nhở được tạo tự động khi thêm deadline (xem ReminderService.schedule).
class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final ReminderController _c = ReminderController();

  @override
  void initState() {
    super.initState();
    _c.load();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _toggle(ReminderData r, bool enabled) async {
    final err = await _c.setEnabled(r, enabled);
    if (err != null && mounted) _toast(err);
  }

  Future<void> _remove(ReminderData r) async {
    final err = await _c.remove(r);
    if (mounted) _toast(err ?? 'Đã xóa nhắc nhở');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _c,
          builder: (context, _) => RefreshIndicator(
            onRefresh: _c.load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                const ScreenHeader('Nhắc nhở'),
                if (_c.loading) const LinearProgressIndicator(),
                if (_c.error != null) _errorBox(_c.error!),
                Row(
                  children: [
                    Expanded(
                      child: PastelTile(
                        title: '${_c.enabledCount}',
                        subtitle: 'Đang bật',
                        color: const Color(0xFFEAF9D6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PastelTile(
                        title: '${_c.disabledCount}',
                        subtitle: 'Đã tắt',
                        color: const Color(0xFFFFF1D6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Nhắc nhở của bạn',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                if (_c.items.isEmpty && !_c.loading)
                  const SoftCard(
                    child: Text(
                      'Chưa có nhắc nhở. Nhắc nhở được tạo tự động khi bạn thêm deadline.',
                      style: TextStyle(fontSize: 14, color: Color(0xFF5F5A70)),
                    ),
                  ),
                for (final r in _c.items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _reminderCard(r),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _reminderCard(ReminderData r) {
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(14, 8, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.message,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text('Nhắc lúc ${_formatTime(r.scheduledAt)} · ${r.status.label}',
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF5F5A70))),
              ],
            ),
          ),
          Switch(
            value: r.isEnabled,
            onChanged: r.canToggle ? (v) => _toggle(r, v) : null,
          ),
          IconButton(
            tooltip: 'Xóa nhắc nhở',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _remove(r),
          ),
        ],
      ),
    );
  }

  Widget _errorBox(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
          TextButton(onPressed: _c.load, child: const Text('Thử lại')),
        ],
      ),
    );
  }

  /// dd/MM HH:mm
  String _formatTime(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)} ${two(d.hour)}:${two(d.minute)}';
  }
}