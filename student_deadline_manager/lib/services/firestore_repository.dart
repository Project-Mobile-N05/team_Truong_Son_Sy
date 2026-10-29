import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/base_entity.dart';

/// Lỗi chung của tầng dữ liệu (Câu 8a: bắt lỗi).
class RepositoryException implements Exception {
  final String message;
  const RepositoryException(this.message);
  @override
  String toString() => 'RepositoryException: $message';
}

/// ORM đơn giản: Object (BaseEntity) <-> Document (Firestore).
/// Dùng chung cho users, subjects, tasks, reminders.
class FirestoreRepository<T extends BaseEntity> {
  final CollectionReference<Map<String, dynamic>> _col;
  final T Function(String id, Map<String, dynamic> map) _fromMap;

  FirestoreRepository(
    String collection,
    this._fromMap, {
    FirebaseFirestore? firestore, // truyền FakeFirebaseFirestore khi unit test
  }) : _col = (firestore ?? FirebaseFirestore.instance).collection(collection);

  Future<R> _guard<R>(Future<R> Function() action, String what) async {
    try {
      return await action();
    } on FirebaseException catch (e) {
      throw RepositoryException('$what thất bại: ${e.code}');
    } catch (e) {
      throw RepositoryException('$what thất bại: $e');
    }
  }

  Future<String> add(T entity) => _guard(() async {
        final ref = await _col.add(entity.toMap());
        return ref.id;
      }, 'Thêm');

  Future<void> update(String id, T entity) =>
      _guard(() => _col.doc(id).set(entity.toMap()), 'Cập nhật');

  Future<void> delete(String id) =>
      _guard(() => _col.doc(id).delete(), 'Xóa');

  Future<T?> getById(String id) => _guard(() async {
        final doc = await _col.doc(id).get();
        final map = doc.data();
        return map == null ? null : _fromMap(doc.id, map);
      }, 'Đọc');

  Future<List<T>> getAll() => _guard(() async {
        final snap = await _col.get();
        return snap.docs.map((d) => _fromMap(d.id, d.data())).toList();
      }, 'Đọc danh sách');

  /// Các Document có [field] == [value] (vd: userId của người đăng nhập).
  Future<List<T>> findWhere(String field, Object value) => _guard(() async {
        final snap = await _col.where(field, isEqualTo: value).get();
        return snap.docs.map((d) => _fromMap(d.id, d.data())).toList();
      }, 'Đọc danh sách');

  /// Tự cập nhật UI khi dữ liệu đổi (dùng với StreamBuilder).
  Stream<List<T>> watchAll() => _col.snapshots().map(
      (s) => s.docs.map((d) => _fromMap(d.id, d.data())).toList());
}