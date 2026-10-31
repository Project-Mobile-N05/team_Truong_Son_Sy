import 'base_entity.dart';

/// Giữ chỗ một mã sinh viên: document `student_codes/{mã}` trỏ tới uid chủ sở hữu.
class StudentCodeData extends BaseEntity {
  final String uid;
  const StudentCodeData({super.id, required this.uid});

  /// Document -> Object
  factory StudentCodeData.fromMap(String id, Map<String, dynamic> m) =>
      StudentCodeData(id: id, uid: (m['uid'] as String?) ?? '');

  /// Object -> Document
  @override
  Map<String, Object> toMap() => {'uid': uid};
}