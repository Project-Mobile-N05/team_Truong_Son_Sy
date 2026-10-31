import 'package:flutter/material.dart';
import '../controllers/task_controller.dart';
import '../models/task.dart';
import '../services/subject_options.dart';
import '../widgets/month_calendar.dart';
import '../widgets/task_card.dart';
import 'task_form_screen.dart';

/// Màn hình Lịch (tab "Lịch"): lịch tháng, danh sách deadline của ngày đang
/// chọn, nút "Xong" để hoàn thành và nút "+ Thêm deadline".
///
/// Luồng theo sơ đồ Sequence: mở tab -> findAll -> nhóm theo ngày -> chọn ngày
/// -> isOverdue từng deadline -> (chạm deadline -> mở chi tiết/sửa).
class CalendarScreen extends StatefulWidget {
  /// Chỉ truyền khi test; bình thường để null.
  final TaskController? controller;
  const CalendarScreen({super.key, this.controller});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final TaskController _c;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _c = widget.controller ?? TaskController(subjectLoader: loadSubjectOptions);
    _c.load();
  }

  @override
  void dispose() {
    if (_ownsController) _c.dispose();
    super.dispose();
  }

  Future<void> _openForm({Task? task}) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(
          controller: _c,
          task: task,
          initialDate: _c.selectedDay,
        ),
      ),
    );
  }

  Future<void> _complete(Task task) async {
    final err = await _c.complete(task);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(err ?? 'Đã hoàn thành "${task.title}"')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Thêm deadline'),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _c,
          builder: (context, _) {
            final tasks = _c.selectedTasks;
            return RefreshIndicator(
              onRefresh: () => _c.load(forceRefresh: true),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lịch',
                            style: TextStyle(
                                fontSize: 32, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 16),
                          if (_c.loading) const LinearProgressIndicator(),
                          if (_c.error != null)
                            _ErrorBox(message: _c.error!, onRetry: _c.load),
                          MonthCalendar(
                            month: _c.visibleMonth,
                            selected: _c.selectedDay,
                            markedDays: _c.markedDays,
                            overdueDays: _c.overdueDays,
                            onSelect: _c.selectDay,
                            onPrev: () => _c.changeMonth(-1),
                            onNext: () => _c.changeMonth(1),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Deadline ngày ${formatDayMonth(_c.selectedDay)}',
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 12),
                          if (tasks.isEmpty && !_c.loading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(child: Text('Không có deadline')),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (tasks.isEmpty)
                    const SliverToBoxAdapter(child: SizedBox(height: 96))
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                      sliver: SliverList.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TaskCard(
                              task: task,
                              subjectName: _c.subjectName(task.subjectId),
                              onTap: () => _openForm(task: task),
                              onComplete: () => _complete(task),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBox({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
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
          TextButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}
