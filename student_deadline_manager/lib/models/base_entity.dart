

abstract class BaseEntity {
  /// id của Document trên Firestore (null nếu chưa lưu).
  final String? id;

  const BaseEntity({this.id});

  /// Object -> Document (ORM chiều ghi).
  Map<String, Object> toMap();
}
