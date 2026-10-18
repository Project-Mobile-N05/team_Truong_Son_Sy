import 'package:flutter/foundation.dart';

/// Câu 1: Lớp Generic cơ sở miêu tả chung cho mọi đối tượng trong dự án
abstract class BaseEntity<ID> {
  ID id;
  DateTime createdAt;

  BaseEntity({
    required this.id,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Phương thức trừu tượng chuyển đổi sang Map
  Map<String, dynamic> toMap();

  /// Sử dụng phương thức của Object class để đè định dạng chuỗi
  @override
  String toString() {
    return '$runtimeType (ID: $id, Tạo lúc: $createdAt)';
  }

  /// Sử dụng Object class để kiểm tra bằng nhau (Equals)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseEntity<ID> && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Lớp Generic Manager quản lý danh sách bất kỳ đối tượng nào kế thừa từ BaseEntity
class GenericManager<T extends BaseEntity> {
  final List<T> _items = [];

  /// Lấy danh sách đối tượng
  List<T> get items => List.unmodifiable(_items);

  /// Thêm đối tượng
  void add(T item) {
    _items.add(item);
  }

  /// Xóa đối tượng theo ID
  bool removeById(dynamic id) {
    final initialLength = _items.length;
    _items.removeWhere((element) => element.id == id);
    return _items.length < initialLength;
  }

  /// Tìm đối tượng theo ID
  T? findById(dynamic id) {
    try {
      return _items.firstWhere((element) => element.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Sử dụng 'Type' (tương đương với Class class trong Java) để lấy tên lớp đối tượng đang quản lý
  Type get entityClass => T;

  /// In thông tin tổng quát của Manager sử dụng Object class và Type
  void printManagerInfo() {
    debugPrint("--- Đang quản lý danh sách thuộc lớp (Class): $entityClass ---");
    debugPrint("Số lượng phần tử hiện tại: ${_items.length}");
  }
}