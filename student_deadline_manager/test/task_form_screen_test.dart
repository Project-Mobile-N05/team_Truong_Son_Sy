import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_deadline_manager/controllers/task_controller.dart';
import 'package:student_deadline_manager/models/task.dart';
import 'package:student_deadline_manager/models/task_status.dart';
import 'package:student_deadline_manager/screens/task_form_screen.dart';
import 'package:student_deadline_manager/services/task_repository.dart';
import 'package:student_deadline_manager/services/task_service.dart';

void main() {
  testWidgets('sửa deadline đã hoàn thành mặc định bỏ trạng thái hoàn thành', (
    tester,
  ) async {
    final controller = TaskController(
      service: TaskService(
        repository: TaskRepository(firestore: FakeFirebaseFirestore()),
      ),
      currentUid: () => 'u1',
    );
    final task = Task(
      id: 't1',
      userId: 'u1',
      title: 'Bài tập',
      taskDatetime: DateTime(2027, 1, 1, 9),
      status: TaskStatus.completed,
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: TaskFormScreen(controller: controller, task: task),
      ),
    );

    final statusField = tester.widget<DropdownButtonFormField<TaskStatus>>(
      find.byType(DropdownButtonFormField<TaskStatus>),
    );
    expect(statusField.initialValue, TaskStatus.pending);
  });
}
