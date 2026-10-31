import 'package:flutter_test/flutter_test.dart';
import 'package:student_deadline_manager/controllers/reminder_manager.dart';
import 'package:student_deadline_manager/models/reminder_summary.dart';

void main() {
  test('ReminderManager preserves its generic summary API', () {
    final manager = ReminderManager();

    expect(manager.dataType, ReminderSummary);
    expect(manager.title, 'Nộp Bài tập thực hành Flutter');
    expect(manager.dueDate, '16/09/2026');
    expect(manager.status, 'Đang thực hiện');

    manager.setReminder('Bài mới', '20/10/2026', 'Đã hoàn thành');

    expect(manager.getReminderInfo(), contains('Bài mới'));
    expect(manager.getReminderInfo(), contains('20/10/2026'));
    expect(manager.data.id, isNull);
  });
}
