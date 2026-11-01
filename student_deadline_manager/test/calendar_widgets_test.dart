import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_deadline_manager/models/task.dart';
import 'package:student_deadline_manager/models/task_status.dart';
import 'package:student_deadline_manager/widgets/month_calendar.dart';
import 'package:student_deadline_manager/widgets/task_card.dart';

/// Kiểm thử giao diện (widget test) cho lịch tháng và thẻ deadline.
/// Không cần Firebase và không cần thư viện test nào thêm.
Widget wrap(Widget child) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

MonthCalendar calendar({
  required DateTime month,
  DateTime? selected,
  ValueChanged<DateTime>? onSelect,
  VoidCallback? onPrev,
  VoidCallback? onNext,
}) =>
    MonthCalendar(
      month: month,
      selected: selected ?? DateTime(month.year, month.month, 1),
      onSelect: onSelect ?? (_) {},
      onPrev: onPrev ?? () {},
      onNext: onNext ?? () {},
    );

void main() {
  group('MonthCalendar', () {
    testWidgets('hiển thị tiêu đề tháng, các thứ và đủ 31 ngày',
        (tester) async {
      await tester.pumpWidget(wrap(calendar(month: DateTime(2026, 10))));

      expect(find.text('Tháng 10, 2026'), findsOneWidget);
      for (final w in ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN']) {
        expect(find.text(w), findsOneWidget);
      }
      expect(find.text('1'), findsOneWidget);
      expect(find.text('31'), findsOneWidget);
      expect(find.text('32'), findsNothing);
    });

    testWidgets('tháng 2 năm thường có 28 ngày', (tester) async {
      await tester.pumpWidget(wrap(calendar(month: DateTime(2026, 2))));
      expect(find.text('28'), findsOneWidget);
      expect(find.text('29'), findsNothing);
    });

    testWidgets('tháng 2 năm nhuận có 29 ngày', (tester) async {
      await tester.pumpWidget(wrap(calendar(month: DateTime(2028, 2))));
      expect(find.text('29'), findsOneWidget);
    });

    testWidgets('chạm vào một ngày thì gọi onSelect với đúng ngày',
        (tester) async {
      DateTime? picked;
      await tester.pumpWidget(wrap(calendar(
        month: DateTime(2026, 10),
        onSelect: (d) => picked = d,
      )));

      await tester.tap(find.text('15'));
      await tester.pump();

      expect(picked, DateTime(2026, 10, 15));
    });

    testWidgets('nút tháng trước và tháng sau gọi đúng hàm', (tester) async {
      var prev = 0;
      var next = 0;
      await tester.pumpWidget(wrap(calendar(
        month: DateTime(2026, 10),
        onPrev: () => prev++,
        onNext: () => next++,
      )));

      await tester.tap(find.byTooltip('Tháng trước'));
      await tester.tap(find.byTooltip('Tháng sau'));
      await tester.tap(find.byTooltip('Tháng sau'));

      expect(prev, 1);
      expect(next, 2);
    });
  });

  group('TaskCard', () {
    Task makeTask({
      String title = 'Nộp báo cáo',
      DateTime? at,
      TaskStatus status = TaskStatus.pending,
    }) =>
        Task(
          id: 't1',
          userId: 'u1',
          title: title,
          taskDatetime: at ?? DateTime(2099, 1, 1, 9, 5),
          status: status,
        );

    testWidgets('hiển thị tiêu đề, môn học, trạng thái và giờ', (tester) async {
      await tester.pumpWidget(wrap(TaskCard(
        task: makeTask(),
        subjectName: 'Lập trình Flutter',
        onComplete: () {},
      )));

      expect(find.text('Nộp báo cáo'), findsOneWidget);
      expect(find.text('Lập trình Flutter · Chưa làm · 09:05'), findsOneWidget);
      expect(find.text('Xong'), findsOneWidget);
    });

    testWidgets('chưa có môn học thì hiện "Chưa có môn học"', (tester) async {
      await tester.pumpWidget(wrap(TaskCard(task: makeTask())));
      expect(find.text('Chưa có môn học · Chưa làm · 09:05'), findsOneWidget);
    });

    testWidgets('bấm "Xong" gọi onComplete', (tester) async {
      var done = 0;
      await tester.pumpWidget(wrap(TaskCard(
        task: makeTask(),
        onComplete: () => done++,
      )));

      await tester.tap(find.text('Xong'));
      await tester.pump();

      expect(done, 1);
    });

    testWidgets('chạm vào thẻ gọi onTap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(wrap(TaskCard(
        task: makeTask(),
        onTap: () => taps++,
      )));

      await tester.tap(find.text('Nộp báo cáo'));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('deadline đã hoàn thành: không có nút "Xong", có dấu tick',
        (tester) async {
      await tester.pumpWidget(wrap(TaskCard(
        task: makeTask(
          at: DateTime(2020, 1, 1, 9, 5),
          status: TaskStatus.completed,
        ),
        onComplete: () {},
      )));

      expect(find.text('Xong'), findsNothing);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.textContaining('Hoàn thành'), findsOneWidget);
    });

    testWidgets('deadline quá hạn hiện trạng thái "Quá hạn"', (tester) async {
      await tester.pumpWidget(wrap(TaskCard(
        task: makeTask(at: DateTime(2020, 1, 1, 9, 5)),
        onComplete: () {},
      )));

      expect(find.textContaining('Quá hạn'), findsOneWidget);
      expect(find.text('Xong'), findsOneWidget);
    });

    testWidgets('không truyền onComplete thì không hiện nút "Xong"',
        (tester) async {
      await tester.pumpWidget(wrap(TaskCard(task: makeTask())));
      expect(find.text('Xong'), findsNothing);
    });
  });

  group('Hàm định dạng', () {
    test('formatDate, formatDayMonth, formatTime thêm số 0 phía trước', () {
      final d = DateTime(2026, 1, 5, 7, 3);
      expect(formatDate(d), '05/01/2026');
      expect(formatDayMonth(d), '05/01');
      expect(formatTime(d), '07:03');
    });
  });
}