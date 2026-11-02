import 'package:flutter/material.dart';

import '../models/subject.dart';
import '../models/task.dart';
import '../services/auth_service.dart';
import '../services/statistics_service.dart';
import '../services/task_service.dart';

const _primary = Color(0xFF5147BD);
const _background = Color(0xFFF7F8FC);
const _text = Color(0xFF242638);
const _muted = Color(0xFF69708A);

class StatisticsScreen extends StatefulWidget {
  final List<MonHoc> danhSachMonHoc;
  final TaskService? taskService;

  const StatisticsScreen({
    super.key,
    required this.danhSachMonHoc,
    this.taskService,
  });

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late final TaskService _taskService;
  late DateTime _startDate;
  late DateTime _endDate;
  late DateTime _appliedStartDate;
  late DateTime _appliedEndDate;
  String _selectedPreset = 'Tuần này';
  List<Task> _tasks = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _taskService = widget.taskService ?? TaskService();
    final week = _weekRange(DateTime.now());
    _startDate = _appliedStartDate = week.$1;
    _endDate = _appliedEndDate = week.$2;
    _loadTasks();
  }

  Future<void> _loadTasks({bool forceRefresh = false}) async {
    final uid = AuthService().currentUid;
    if (uid == null) {
      setState(() {
        _loading = false;
        _error = 'Bạn chưa đăng nhập';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final tasks = await _taskService.findAll(uid, forceRefresh: forceRefresh);
      if (!mounted) return;
      setState(() {
        _tasks = tasks;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Không tải được deadline: $e';
      });
    }
  }

  List<Task> get _filteredTasks {
    return StatisticsService.filterByDateRange(
      _tasks,
      startDate: _appliedStartDate,
      endDate: _appliedEndDate,
    );
  }

  void _selectPreset(String preset) {
    final now = DateTime.now();
    late final DateTime start;
    late final DateTime end;
    if (preset == 'Tuần này') {
      (start, end) = _weekRange(now);
    } else if (preset == 'Tháng này') {
      start = DateTime(now.year, now.month);
      end = DateTime(now.year, now.month + 1, 0);
    } else {
      setState(() => _selectedPreset = 'Tùy chọn');
      return;
    }
    setState(() {
      _startDate = start;
      _endDate = end;
      _selectedPreset = preset;
    });
  }

  void _applyDateRange() {
    setState(() {
      _appliedStartDate = _startDate;
      _appliedEndDate = _endDate;
    });
  }

  void _resetDateRange() {
    final week = _weekRange(DateTime.now());
    setState(() {
      _startDate = _appliedStartDate = week.$1;
      _endDate = _appliedEndDate = week.$2;
      _selectedPreset = 'Tuần này';
    });
  }

  Future<void> _pickDate({required bool isStart}) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: isStart ? 'Chọn ngày bắt đầu' : 'Chọn ngày kết thúc',
    );
    if (selected == null || !mounted) return;

    final date = _dayKey(selected);
    setState(() {
      if (isStart) {
        _startDate = date;
        if (_endDate.isBefore(date)) _endDate = date;
      } else {
        _endDate = date;
        if (_startDate.isAfter(date)) _startDate = date;
      }
      _selectedPreset = 'Tùy chọn';
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _filteredTasks;
    final completedCount = StatisticsService.completedCount(filteredTasks);
    final pendingCount = StatisticsService.pendingCount(filteredTasks);

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, color: _primary),
        ),
        title: const Text(
          'Thống kê',
          style: TextStyle(
            color: _text,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadTasks(forceRefresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${filteredTasks.length} deadline',
                    style: const TextStyle(
                      color: _text,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  _formatDateRange(_appliedStartDate, _appliedEndDate),
                  style: const TextStyle(color: _muted, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    count: completedCount,
                    label: 'Đã hoàn thành',
                    color: const Color(0xFFEAF7D6),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SummaryCard(
                    count: pendingCount,
                    label: 'Chưa hoàn thành',
                    color: const Color(0xFFFFF0D5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDateFilter(),
            const SizedBox(height: 12),
            _buildSubjects(filteredTasks.length),
            if (_loading) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(color: _primary),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              _ErrorBox(message: _error!, onRetry: _loadTasks),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilter() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Lọc theo ngày đến hạn',
                  style: TextStyle(
                    color: _text,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: _resetDateRange,
                style: TextButton.styleFrom(
                  foregroundColor: _muted,
                  backgroundColor: _background,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                child: const Text('Đặt lại'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _DateField(
                  label: 'Bắt đầu',
                  date: _startDate,
                  onTap: () => _pickDate(isStart: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateField(
                  label: 'Kết thúc',
                  date: _endDate,
                  onTap: () => _pickDate(isStart: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PresetButton(
                label: 'Tuần này',
                selected: _selectedPreset == 'Tuần này',
                onTap: () => _selectPreset('Tuần này'),
              ),
              _PresetButton(
                label: 'Tháng này',
                selected: _selectedPreset == 'Tháng này',
                onTap: () => _selectPreset('Tháng này'),
              ),
              _PresetButton(
                label: 'Tùy chọn',
                selected: _selectedPreset == 'Tùy chọn',
                onTap: () => _selectPreset('Tùy chọn'),
              ),
              _PresetButton(
                label: 'Áp dụng',
                selected: true,
                filled: true,
                onTap: _applyDateRange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubjects(int totalDeadlines) {
    final counts = StatisticsService.deadlineCountBySubject(_filteredTasks);
    final subjects =
        widget.danhSachMonHoc
            .where((subject) => (counts[subject.id] ?? 0) > 0)
            .toList()
          ..sort((a, b) => (counts[b.id] ?? 0).compareTo(counts[a.id] ?? 0));

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Deadline theo môn học',
            style: TextStyle(
              color: _text,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subjects.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 22),
              child: Center(
                child: Text(
                  'Chưa có deadline theo môn trong khoảng ngày này.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _muted),
                ),
              ),
            )
          else
            for (var index = 0; index < subjects.length; index++) ...[
              if (index > 0)
                const Divider(height: 12, color: Color(0xFFE5E7F0)),
              _SubjectDeadlineRow(
                subject: subjects[index],
                count: counts[subjects[index].id] ?? 0,
                total: totalDeadlines,
              ),
            ],
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _SummaryCard({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 178,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$count',
            style: const TextStyle(
              color: _text,
              fontSize: 44,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: _muted,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: _background,
          border: Border.all(color: const Color(0xFFE3E5EF)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: _muted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatDate(date),
              style: const TextStyle(
                color: _text,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final bool selected;
  final bool filled;
  final VoidCallback onTap;

  const _PresetButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final isFilled = filled;
    final background = isFilled
        ? _primary
        : selected
        ? const Color(0xFFEDEBFF)
        : _background;
    return Material(
      color: background,
      shape: StadiumBorder(
        side: isFilled
            ? BorderSide.none
            : const BorderSide(color: Color(0xFFE3E5EF)),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Text(
            label,
            style: TextStyle(
              color: isFilled
                  ? Colors.white
                  : selected
                  ? _primary
                  : _muted,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _SubjectDeadlineRow extends StatelessWidget {
  final MonHoc subject;
  final int count;
  final int total;

  const _SubjectDeadlineRow({
    required this.subject,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          subject.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _text,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Expanded(
              child: Text(
                subject.id,
                style: const TextStyle(color: _muted, fontSize: 13),
              ),
            ),
            Text(
              '$count deadline',
              style: const TextStyle(
                color: _primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: total == 0 ? 0 : (count / total).clamp(0, 1).toDouble(),
            minHeight: 10,
            backgroundColor: const Color(0xFFECEBF4),
            color: _primary,
          ),
        ),
      ],
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

BoxDecoration _panelDecoration() => BoxDecoration(
  color: Colors.white,
  border: Border.all(color: const Color(0xFFE1E4EF)),
  borderRadius: BorderRadius.circular(20),
);

DateTime _dayKey(DateTime date) => DateTime(date.year, date.month, date.day);

(DateTime, DateTime) _weekRange(DateTime date) {
  final today = _dayKey(date);
  final monday = today.subtract(
    Duration(days: today.weekday - DateTime.monday),
  );
  return (monday, monday.add(const Duration(days: 6)));
}

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

String _formatDateRange(DateTime start, DateTime end) {
  final startDate =
      '${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')}';
  final endDate =
      '${end.day.toString().padLeft(2, '0')}/${end.month.toString().padLeft(2, '0')}/${end.year}';
  if (start.year == end.year) return '$startDate–$endDate';
  return '${_formatDate(start)}–${_formatDate(end)}';
}
