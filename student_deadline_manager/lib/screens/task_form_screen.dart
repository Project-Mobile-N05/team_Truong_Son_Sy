import 'package:flutter/material.dart';
import '../controllers/task_controller.dart';
import '../models/task.dart';
import '../models/task_status.dart';
import '../models/task_type.dart';
import '../services/task_service.dart';
import '../widgets/task_card.dart';

/// Màn hình thêm / sửa / xóa deadline.
/// [task] = null là thêm mới, có giá trị là sửa (có thêm ô Trạng thái và nút Xóa).
///
/// Luồng theo sơ đồ Sequence:
/// - Thêm: kiểm tra form -> create -> báo thành công, quay về.
/// - Sửa: hiển thị form điền sẵn -> update.
/// - Xóa: hộp thoại xác nhận -> remove.
class TaskFormScreen extends StatefulWidget {
  final TaskController controller;
  final Task? task;

  /// Ngày mặc định khi thêm mới (ngày đang chọn trên Lịch).
  final DateTime? initialDate;

  const TaskFormScreen({
    super.key,
    required this.controller,
    this.task,
    this.initialDate,
  });

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _room;
  late final TextEditingController _notes;

  String? _subjectId;
  TaskType? _type;
  late TaskStatus _status;
  late DateTime _date;
  late TimeOfDay _time;
  bool _saving = false;
  String? _dateError;

  bool get _isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _title = TextEditingController(text: t?.title ?? '');
    _room = TextEditingController(text: t?.room ?? '');
    _notes = TextEditingController(text: t?.notes ?? '');
    _subjectId = t?.subjectId;
    _type = t?.type;
    _status =
        (t == null ||
            t.status == TaskStatus.overdue ||
            t.status == TaskStatus.completed)
        ? TaskStatus.pending
        : t.status;
    final base = t?.taskDatetime ?? widget.initialDate ?? DateTime.now();
    _date = DateTime(base.year, base.month, base.day);
    // Mặc định 23:59 để thêm deadline cho hôm nay không bị báo "quá khứ".
    _time = t != null
        ? TimeOfDay(hour: t.taskDatetime.hour, minute: t.taskDatetime.minute)
        : const TimeOfDay(hour: 23, minute: 59);
  }

  @override
  void dispose() {
    _title.dispose();
    _room.dispose();
    _notes.dispose();
    super.dispose();
  }

  DateTime _combined() =>
      DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    final formOk = _formKey.currentState!.validate();
    final dateErr =
        TaskService.validateDateTime(_combined(), allowPast: _isEdit);
    setState(() => _dateError = dateErr);
    if (!formOk || dateErr != null) return;

    setState(() => _saving = true);
    final err = await widget.controller.save(
      existing: widget.task,
      dto: TaskDto(
        title: _title.text,
        subjectId: _subjectId,
        type: _type,
        taskDatetime: _combined(),
        room: _room.text,
        notes: _notes.text,
        status: _isEdit ? _status : null,
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);

    final messenger = ScaffoldMessenger.of(context);
    if (err != null) {
      messenger.showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    messenger.showSnackBar(SnackBar(
      content: Text(_isEdit ? 'Đã cập nhật deadline' : 'Đã thêm deadline'),
    ));
    Navigator.of(context).pop(true);
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa deadline?'),
        content: Text('Bạn chắc chắn muốn xóa "${widget.task!.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Xóa')),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _saving = true);
    final err = await widget.controller.remove(widget.task!);
    if (!mounted) return;
    setState(() => _saving = false);

    final messenger = ScaffoldMessenger.of(context);
    if (err != null) {
      messenger.showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    messenger.showSnackBar(const SnackBar(content: Text('Đã xóa deadline')));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final subjects = widget.controller.subjects;
    // Tránh lỗi dropdown khi môn học đã bị xóa hoặc chưa tải được.
    final subjectValue =
        subjects.any((s) => s.id == _subjectId) ? _subjectId : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Sửa deadline' : 'Thêm deadline'),
        actions: [
          if (_isEdit)
            IconButton(
              tooltip: 'Xóa',
              icon: const Icon(Icons.delete_outline),
              onPressed: _saving ? null : _delete,
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _title,
                textInputAction: TextInputAction.next,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề *',
                  border: OutlineInputBorder(),
                ),
                validator: TaskService.validateTitle,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                initialValue: subjectValue,
                decoration: InputDecoration(
                  labelText: 'Môn học',
                  border: const OutlineInputBorder(),
                  helperText:
                      subjects.isEmpty ? 'Chưa có môn học nào' : null,
                ),
                items: [
                  const DropdownMenuItem<String?>(
                      value: null, child: Text('Không chọn')),
                  for (final s in subjects)
                    DropdownMenuItem<String?>(value: s.id, child: Text(s.name)),
                ],
                onChanged: (v) => setState(() => _subjectId = v),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskType?>(
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: 'Loại',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<TaskType?>(
                      value: null, child: Text('Không chọn')),
                  for (final t in TaskType.values)
                    DropdownMenuItem<TaskType?>(value: t, child: Text(t.label)),
                ],
                onChanged: (v) => setState(() => _type = v),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: Text(formatDate(_date)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.access_time),
                      label: Text(
                          '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}'),
                    ),
                  ),
                ],
              ),
              if (_dateError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 12),
                  child: Text(_dateError!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12)),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _room,
                decoration: const InputDecoration(
                  labelText: 'Phòng / địa điểm',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notes,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_isEdit) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<TaskStatus>(
                  initialValue: _status,
                  decoration: const InputDecoration(
                    labelText: 'Trạng thái',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final s in const [
                      TaskStatus.pending,
                      TaskStatus.inProgress,
                      TaskStatus.completed,
                    ])
                      DropdownMenuItem(value: s, child: Text(s.label)),
                  ],
                  onChanged: (v) => setState(() => _status = v ?? _status),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Lưu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
