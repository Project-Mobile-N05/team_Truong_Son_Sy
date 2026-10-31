import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

/// Lỗi truy cập Firestore của Task. [message] là câu tiếng Việt.
class TaskRepositoryException implements Exception {
  final String message;
  const TaskRepositoryException(this.message);
  @override
  String toString() => 'TaskRepositoryException: $message';
}

/// ORM của Task: Object ([Task]) <-> Document (collection `tasks`).
///
/// Viết riêng cho phần Task để lọc theo `userId` và không phụ thuộc vào
/// repository dùng chung của module khác.
class TaskRepository {
  final CollectionReference<Map<String, dynamic>> _col;

  /// [firestore]: truyền FakeFirebaseFirestore khi unit test.
  TaskRepository({FirebaseFirestore? firestore})
      : _col = (firestore ?? FirebaseFirestore.instance).collection('tasks');

  Future<R> _guard<R>(Future<R> Function() action, String what) async {
    try {
      return await action();
    } on FirebaseException catch (e) {
      throw TaskRepositoryException('$what thất bại: ${e.code}');
    } catch (e) {
      throw TaskRepositoryException('$what thất bại: $e');
    }
  }

  /// Thêm Document mới, trả về id.
  Future<String> add(Task task) => _guard(() async {
        final ref = await _col.add(task.toMap());
        return ref.id;
      }, 'Thêm');
      
  /// Ghi đè Document theo id.
  Future<void> update(String id, Task task) =>
      _guard(() => _col.doc(id).set(task.toMap()), 'Cập nhật');

  Future<void> delete(String id) =>
      _guard(() => _col.doc(id).delete(), 'Xóa');

  Future<Task?> getById(String id) => _guard(() async {
        final doc = await _col.doc(id).get();
        final map = doc.data();
        return map == null ? null : Task.fromMap(doc.id, map);
      }, 'Đọc');

  /// Tất cả Task của một user, sắp xếp theo thời hạn.
  ///
  /// Nếu composite index chưa được triển khai, truy vấn có orderBy sẽ trả về
  /// failed-precondition. Tạm đọc theo user rồi sắp xếp ở client để màn hình
  /// vẫn dùng được; sau khi triển khai index, đường truy vấn nhanh được dùng lại.
  Future<List<Task>> getByUser(String userId) async {
    try {
      final snap = await _col
          .where('userId', isEqualTo: userId)
          .orderBy('taskDatetime')
          .get();
      return snap.docs.map((d) => Task.fromMap(d.id, d.data())).toList();
    } on FirebaseException catch (e) {
      if (e.code != 'failed-precondition') {
        throw TaskRepositoryException('Đọc danh sách thất bại: ${e.code}');
      }

      return _guard(() async {
        final snap = await _col.where('userId', isEqualTo: userId).get();
        final tasks = snap.docs.map((d) => Task.fromMap(d.id, d.data())).toList()
          ..sort((a, b) => a.taskDatetime.compareTo(b.taskDatetime));
        return tasks;
      }, 'Đọc danh sách');
    } catch (e) {
      throw TaskRepositoryException('Đọc danh sách thất bại: $e');
    }
  }

  /// Tự cập nhật khi dữ liệu đổi (dùng với StreamBuilder nếu cần).
  Stream<List<Task>> watchByUser(String userId) => _col
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((s) => s.docs.map((d) => Task.fromMap(d.id, d.data())).toList());
}
