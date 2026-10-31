import 'project_entity.dart';

/// Môn học thuộc tài khoản Firebase hiện tại.
///
/// `teacher` và `credits` được giữ để tương thích với dữ liệu/chức năng cũ;
/// các trường chính dùng tên đơn giản như trong schema mới.
class Subject extends ProjectEntity<String> {
  final String userId;
  final String color;
  final String icon;
  final String teacher;
  final int credits;

  const Subject({
    required super.id,
    required this.userId,
    required String name,
    this.color = 'violet',
    this.icon = 'book',
    this.teacher = '',
    this.credits = 0,
  }) : super(ten: name);

  String get name => ten;

  factory Subject.fromMap(
    String id,
    String ownerId,
    Map<String, dynamic> data,
  ) => Subject(
    id: id,
    userId: (data['userId'] as String?) ?? ownerId,
    name: (data['name'] as String?) ?? (data['tenMonHoc'] as String?) ?? '',
    color: (data['color'] as String?) ?? 'violet',
    icon: (data['icon'] as String?) ?? 'book',
    teacher:
        (data['teacher'] as String?) ?? (data['giangVien'] as String?) ?? '',
    credits: ((data['credits'] ?? data['soTinChi']) as num?)?.toInt() ?? 0,
  );

  @override
  Map<String, Object?> toMap() => {
    'userId': userId,
    'name': name,
    'color': color,
    'icon': icon,
    'teacher': teacher,
    'credits': credits,
  };

  String getThongTinMonHoc() => 'Môn $name ($id).';
}

/// Compatibility alias while the remaining modules migrate from Vietnamese
/// type naming to `Subject`.
typedef MonHoc = Subject;
