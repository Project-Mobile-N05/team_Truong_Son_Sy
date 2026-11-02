import 'base_entity.dart';

class StudentCodeData extends BaseEntity {
  final String uid;
  const StudentCodeData({super.id, required this.uid});

  factory StudentCodeData.fromMap(String id, Map<String, dynamic> m) =>
      StudentCodeData(id: id, uid: (m['uid'] as String?) ?? '');

  @override
  Map<String, Object> toMap() => {'uid': uid};
}