import 'package:flutter/material.dart';
import '../controllers/task_controller.dart';
import '../models/task.dart';
import '../models/task_status.dart';
import '../models/task_type.dart';
import '../services/task_service.dart';
import '../widgets/task_card.dart';

const _formPrimary = Color(0xFF5147BD);
const _formBackground = Color(0xFFF7F8FC);

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
    _status = (t == null || t.status == TaskStatus.overdue)
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
    if (picked != null) {
      setState(() {
        _date = picked;
        _dateError = null;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) {
      setState(() {
        _time = picked;
        _dateError = null;
      });
    }
  }

  Future<void> _save() async {
    final formOk = _formKey.currentState!.validate();
    final dateErr = TaskService.validateDateTime(
      _combined(),
      allowPast: _isEdit,
    );
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
    messenger.showSnackBar(
      SnackBar(
        content: Text(_isEdit ? 'Đã cập nhật deadline' : 'Đã thêm deadline'),
      ),
    );
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
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
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
    final subjectValue = subjects.any((s) => s.id == _subjectId)
        ? _subjectId
        : null;

    return Scaffold(
      backgroundColor: _formBackground,
      appBar: AppBar(
        backgroundColor: _formBackground,
        surfaceTintColor: Colors.transparent,
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_formPrimary, Color(0xFF8177E8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.edit_calendar_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEdit
                              ? 'Cập nhật kế hoạch'
                              : 'Sẵn sàng lên kế hoạch?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isEdit
                              ? 'Chỉnh sửa thông tin deadline của bạn'
                              : 'Thêm thông tin để không bỏ lỡ hạn nộp',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _sectionHeading('Thông tin deadline', 'Bắt đầu với tên bài tập'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _title,
              textInputAction: TextInputAction.next,
              maxLength: 100,
              decoration: _inputDecoration(
                label: 'Tên deadline *',
                hint: 'Ví dụ: Nộp bài tập Flutter',
                icon: Icons.assignment_outlined,
              ).copyWith(counterText: ''),
              validator: TaskService.validateTitle,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String?>(
              initialValue: subjectValue,
              decoration:
                  _inputDecoration(
                    label: 'Môn học',
                    icon: Icons.menu_book_outlined,
                  ).copyWith(
                    helperText: subjects.isEmpty ? 'Chưa có môn học nào' : null,
                  ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Không chọn'),
                ),
                for (final s in subjects)
                  DropdownMenuItem<String?>(value: s.id, child: Text(s.name)),
              ],
              onChanged: (v) => setState(() => _subjectId = v),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<TaskType?>(
              initialValue: _type,
              decoration: _inputDecoration(
                label: 'Loại bài tập',
                icon: Icons.category_outlined,
              ),
              items: [
                const DropdownMenuItem<TaskType?>(
                  value: null,
                  child: Text('Không chọn'),
                ),
                for (final t in TaskType.values)
                  DropdownMenuItem<TaskType?>(value: t, child: Text(t.label)),
              ],
              onChanged: (v) => setState(() => _type = v),
            ),
            const SizedBox(height: 24),
            _sectionHeading('Thời hạn', 'Chọn ngày và giờ cần hoàn thành'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _dateTimeTile(
                    icon: Icons.calendar_month_rounded,
                    label: 'NGÀY NỘP',
                    value: formatDate(_date),
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dateTimeTile(
                    icon: Icons.schedule_rounded,
                    label: 'GIỜ NỘP',
                    value:
                        '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
                    onTap: _pickTime,
                  ),
                ),
              ],
            ),
            if (_dateError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Text(
                  _dateError!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            _sectionHeading('Thông tin bổ sung', 'Không bắt buộc'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _room,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                label: 'Phòng / địa điểm',
                hint: 'Ví dụ: Phòng A203',
                icon: Icons.place_outlined,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _notes,
              maxLines: 3,
              minLines: 3,
              decoration: _inputDecoration(
                label: 'Ghi chú',
                hint: 'Thêm yêu cầu hoặc nội dung cần nhớ',
                icon: Icons.notes_rounded,
                alignIconTop: true,
              ),
            ),
            if (_isEdit) ...[
              const SizedBox(height: 14),
              DropdownButtonFormField<TaskStatus>(
                initialValue: _status,
                decoration: _inputDecoration(
                  label: 'Trạng thái',
                  icon: Icons.flag_outlined,
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
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        child: FilledButton.icon(
          onPressed: _saving ? null : _save,
          style: FilledButton.styleFrom(
            backgroundColor: _formPrimary,
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          icon: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(_isEdit ? Icons.save_rounded : Icons.add_rounded),
          label: Text(
            _saving
                ? 'Đang lưu...'
                : (_isEdit ? 'Lưu thay đổi' : 'Tạo deadline'),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeading(String title, String subtitle) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: Color(0xFF242638),
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        subtitle,
        style: const TextStyle(color: Color(0xFF69708A), fontSize: 13),
      ),
    ],
  );

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
    bool alignIconTop = false,
  }) => InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(icon, color: _formPrimary),
    prefixIconConstraints: alignIconTop
        ? const BoxConstraints(minWidth: 48, minHeight: 52)
        : null,
    alignLabelWithHint: alignIconTop,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE5E7F0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE5E7F0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: _formPrimary, width: 1.5),
    ),
  );

  Widget _dateTimeTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: _formPrimary, size: 20),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF69708A),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.7,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF242638),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
