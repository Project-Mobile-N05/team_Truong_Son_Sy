import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_deadline_manager/models/notification_status.dart';
import 'package:student_deadline_manager/models/reminder_data.dart';

void main() {
  final at = DateTime(2026, 11, 9, 9);

  ReminderData sample({NotificationStatus status = NotificationStatus.pending}) =>
      ReminderData(
        id: 'r1',
        userId: 'u1',
        taskId: 't1',
        message: 'Sắp đến hạn: Nộp bài',
        scheduledAt: at,
        status: status,
        createdAt: at,
      );

  group('NotificationStatus.fromName', () {
    test('đọc đúng từng giá trị', () {
      for (final s in NotificationStatus.values) {
        expect(NotificationStatus.fromName(s.name), s);
      }
    });

    test('giá trị lạ hoặc null thì coi là pending', () {
      expect(NotificationStatus.fromName('abc'), NotificationStatus.pending);
      expect(NotificationStatus.fromName(null), NotificationStatus.pending);
    });
  });

  group('ReminderData.isEnabled và canToggle', () {
    test('chỉ pending là đang bật', () {
      expect(sample().isEnabled, isTrue);
      expect(sample(status: NotificationStatus.cancelled).isEnabled, isFalse);
      expect(sample(status: NotificationStatus.sent).isEnabled, isFalse);
    });

    test('bật/tắt được khi pending hoặc cancelled, không được khi đã gửi', () {
      expect(sample().canToggle, isTrue);
      expect(sample(status: NotificationStatus.cancelled).canToggle, isTrue);
      expect(sample(status: NotificationStatus.sent).canToggle, isFalse);
      expect(sample(status: NotificationStatus.failed).canToggle, isFalse);
    });
  });

  group('ReminderData.toMap / fromMap', () {
    test('toMap lưu status theo tên và thời điểm theo Timestamp', () {
      final m = sample().toMap();
      expect(m['userId'], 'u1');
      expect(m['taskId'], 't1');
      expect(m['message'], 'Sắp đến hạn: Nộp bài');
      expect(m['status'], 'pending');
      expect(m['scheduledAt'], Timestamp.fromDate(at));
    });

    test('toMap không có sentAt khi chưa gửi và không ghi id', () {
      final m = sample().toMap();
      expect(m.containsKey('sentAt'), isFalse);
      expect(m.containsKey('id'), isFalse);
    });

    test('toMap rồi fromMap giữ nguyên dữ liệu', () {
      final back = ReminderData.fromMap(
          'r1', sample(status: NotificationStatus.cancelled).toMap());
      expect(back.id, 'r1');
      expect(back.userId, 'u1');
      expect(back.taskId, 't1');
      expect(back.message, 'Sắp đến hạn: Nộp bài');
      expect(back.scheduledAt, at);
      expect(back.status, NotificationStatus.cancelled);
      expect(back.sentAt, isNull);
    });

    test('fromMap thiếu trường thì dùng giá trị mặc định', () {
      final r = ReminderData.fromMap('r2', {});
      expect(r.userId, '');
      expect(r.taskId, '');
      expect(r.message, '');
      expect(r.status, NotificationStatus.pending);
    });
  });

  group('ReminderData.copyWith', () {
    test('đổi trạng thái, giữ nguyên các trường còn lại', () {
      final c = sample().copyWith(status: NotificationStatus.cancelled);
      expect(c.status, NotificationStatus.cancelled);
      expect(c.id, 'r1');
      expect(c.taskId, 't1');
      expect(c.scheduledAt, at);
    });
  });
}
