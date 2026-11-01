import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_entity.dart';

DateTime _toDate(Object? v) {
  if (v is Timestamp) return v.toDate();
  if (v is DateTime) return v;
  return DateTime.now();
}

/// Class User trong Class Diagram. id = uid của Firebase Auth.
class AccountData extends BaseEntity {
  final String studentCode;
  final String fullName;
  final String email;
  final String school;
  final String major;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  AccountData({
    super.id,
    required this.studentCode,
    required this.fullName,
    required this.email,
    this.school = 'Đại học Phenikaa',
    this.major = 'Công nghệ Thông tin',
    this.avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Document -> Object
  factory AccountData.fromMap(String id, Map<String, dynamic> m) =>
      AccountData(
        id: id,
        studentCode: (m['studentCode'] as String?) ?? '',
        fullName: (m['fullName'] as String?) ?? '',
        email: (m['email'] as String?) ?? '',
        school: (m['school'] as String?) ?? 'Đại học Phenikaa',
        major: (m['major'] as String?) ?? 'Công nghệ Thông tin',
        avatarUrl: m['avatarUrl'] as String?,
        createdAt: _toDate(m['createdAt']),
        updatedAt: _toDate(m['updatedAt']),
      );

  AccountData copyWith({
    String? fullName,
    String? school,
    String? major,
    String? avatarUrl,
  }) =>
      AccountData(
        id: id,
        studentCode: studentCode,
        fullName: fullName ?? this.fullName,
        email: email,
        school: school ?? this.school,
        major: major ?? this.major,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );

  /// Object -> Document
  @override
  Map<String, Object> toMap() => {
        'studentCode': studentCode,
        'fullName': fullName,
        'email': email,
        'school': school,
        'major': major,
        'avatarUrl': ?avatarUrl,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
}
