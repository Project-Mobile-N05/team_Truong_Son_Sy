import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';
import '../widgets/home_tile.dart';
import '../widgets/screen_header.dart';

const Color _ink = Color(0xFF1F1B2D);
const Color _muted = Color(0xFF5F5A70);

/// Một ô danh mục / một dịch vụ nhanh. `key` trùng với AppTab.key
/// trong main_navigation.dart. Muốn thêm ô: thêm 1 dòng vào danh sách dưới.
class _Category {
  final String key;
  final String title;
  final IconData icon;
  final Color color;
  final List<Color> gradient;
  const _Category(this.key, this.title, this.icon, this.color, this.gradient);
}

const _topTiles = [
  _Category('subject', 'Môn học', Icons.menu_book, Color(0xFFFFE0E0),
      [Color(0xFFFF8A8A), Color(0xFFF2384F)]),
  _Category('task', 'Deadline', Icons.assignment, Color(0xFFEFDFFB),
      [Color(0xFFC98BFF), Color(0xFF8E2DE2)]),
];

const _bottomTiles = [
  _Category('reminder', 'Nhắc\nnhở', Icons.notifications_active,
      Color(0xFFDFF5FD), [Color(0xFF8FD8FF), Color(0xFF1BA1F0)]),
  _Category('stats', 'Thống kê', Icons.bar_chart, Color(0xFFFAF0D6),
      [Color(0xFFFFB347), Color(0xFFF26B0F)]),
  _Category('calendar', 'Lịch\ndeadline', Icons.calendar_month,
      Color(0xFFEAF9D0), [Color(0xFF9EE08A), Color(0xFF1EA85A)]),
];

/// (khóa, nhãn, biểu tượng) của thẻ dịch vụ cuộn ngang.
const _services = [
  ('subject', 'Thêm môn học', Icons.library_add_outlined),
  ('task', 'Thêm deadline', Icons.add_task),
  ('reminder', 'Nhắc nhở', Icons.notifications_none),
  ('done', 'Hoàn thành', Icons.check_circle_outline),
  ('account', 'Tài khoản', Icons.person_outline),
];

/// Trang chủ. [onOpen] nhận khóa chức năng cần mở.
/// Dữ liệu deadline lấy từ TaskService (module của Sỹ).
class HomeScreen extends StatefulWidget {
  final void Function(String key) onOpen;
  const HomeScreen({super.key, required this.onOpen});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> _tasks = [];
  String? _error;
  String _studentCode = '';

  /// Deadline chưa xong trong 7 ngày tới, và deadline của hôm nay.
  List<Task> get _upcoming => TaskService.upcoming(_tasks);
  List<Task> get _today => TaskService.tasksOfDay(_tasks, DateTime.now());

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Tải mã sinh viên và danh sách deadline (cũng dùng cho kéo để làm mới).
  Future<void> _load() async {
    final uid = AuthService().currentUid;
    if (uid == null) return;
    try {
      final p = await AuthService().getProfile();
      _studentCode = p.studentCode;
    } catch (_) {
      // Không có hồ sơ thì hiện mặc định, không cần báo lỗi ở Trang chủ.
    }
    try {
      final tasks = await TaskService().findAll(uid);
      if (mounted) setState(() { _tasks = tasks; _error = null; });
    } on TaskException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = 'Có lỗi xảy ra: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(17, 16, 17, 16),
            children: [
              _header(),
              const SizedBox(height: 20),
              _tileRow(_topTiles, fontSize: 22, gap: 10),
              const SizedBox(height: 10),
              _tileRow(_bottomTiles, fontSize: 20, gap: 9),
              const SizedBox(height: 18),
              _servicesCard(),
              _divider(),
              _weekBanner(),
              _divider(),
              _heading('Deadline sắp tới'),
              const SizedBox(height: 12),
              ..._taskCards(_upcoming.take(3).toList(),
                  empty: 'Chưa có deadline nào sắp đến'),
              const SizedBox(height: 20),
              _heading('Việc hôm nay'),
              const SizedBox(height: 12),
              ..._taskCards(_today, empty: 'Hôm nay chưa có việc nào cần làm'),
            ],
          ),
        ),
      ),
    );
  }

  // ---- Các khối của màn hình ----

  Widget _header() {
    const dots = [
      Color(0xFFE3242B),
      Color(0xFFF5B000),
      Color(0xFF2FB34A),
      Color(0xFF9B4DB0),
      Color(0xFF0AA5E0),
    ];
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('deadline',
                style: TextStyle(
                    fontSize: 27, fontWeight: FontWeight.w300, height: 1)),
            const SizedBox(height: 4),
            Row(children: [for (final c in dots) _dot(c)]),
          ],
        ),
        const SizedBox(width: 12),
        _badge('★SV', Colors.black),
        _badge(_studentCode.isEmpty ? 'CNTT' : _studentCode,
            const Color(0xFF4A5B80)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F5E6),
            border: Border.all(color: const Color(0xFF3DAA5C)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text('${_upcoming.length} việc',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0B5A2B))),
        ),
      ],
    );
  }

  Widget _tileRow(List<_Category> items, {double fontSize = 22, double gap = 10}) {
    final children = <Widget>[];
    for (final c in items) {
      if (children.isNotEmpty) children.add(SizedBox(width: gap));
      children.add(Expanded(
        child: HomeTile(
          title: c.title,
          color: c.color,
          gradient: c.gradient,
          icon: c.icon,
          fontSize: fontSize,
          onTap: () => widget.onOpen(c.key),
        ),
      ));
    }
    return Row(children: children);
  }

  Widget _servicesCard() {
    return SoftCard(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (final (key, label, icon) in _services) _service(key, label, icon),
        ]),
      ),
    );
  }

  Widget _weekBanner() {
    final n = _upcoming.length;
    final text = _error ??
        (n == 0
            ? 'Chưa có deadline nào trong tuần này'
            : 'Bạn có $n deadline trong tuần này');
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(children: [
        Icon(_error == null ? Icons.event_note : Icons.error_outline,
            color: _error == null ? _ink : Colors.red),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w800, color: _ink)),
        ),
        TextButton(
          onPressed: () => widget.onOpen('calendar'),
          child: const Text('Xem',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        ),
      ]),
    );
  }

  /// Danh sách thẻ deadline, hoặc một thẻ báo trống nếu không có.
  List<Widget> _taskCards(List<Task> tasks, {required String empty}) {
    if (tasks.isEmpty) {
      return [
        SoftCard(
          child: Text(empty,
              style: const TextStyle(fontSize: 14, color: _muted)),
        ),
      ];
    }
    return [
      for (final t in tasks)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _taskCard(t),
        ),
    ];
  }

  Widget _taskCard(Task t) {
    final status = t.displayStatus();
    return GestureDetector(
      onTap: () => widget.onOpen('calendar'),
      child: SoftCard(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Container(
            width: 50,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF0E6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.assignment, color: Colors.deepPurple),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800, color: _ink)),
                const SizedBox(height: 4),
                Text('Hạn ${_formatTime(t.taskDatetime)} · ${status.label}',
                    style: TextStyle(
                        fontSize: 14,
                        color: t.isOverdue() ? Colors.red : _muted)),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  // ---- Các mảnh nhỏ dùng lại ----

  Widget _service(String key, String label, IconData icon) {
    return InkWell(
      onTap: () => widget.onOpen(key),
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 78,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.deepPurple, size: 26),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: _ink)),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
        height: 21,
        color: color,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        alignment: Alignment.center,
        child: Text(text,
            style: const TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
      );

  Widget _dot(Color c) => Container(
        width: 8,
        height: 8,
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );

  Widget _divider() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Divider(height: 1),
      );

  Widget _heading(String t) => Text(t,
      style: const TextStyle(
          fontSize: 21, fontWeight: FontWeight.w800, color: _ink));

  /// dd/MM HH:mm
  String _formatTime(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)} ${two(d.hour)}:${two(d.minute)}';
  }
}