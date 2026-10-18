# Quản Lý Bài Tập - Generics & Kế thừa

## Mô tả
Tổng quát hóa các đối tượng trong project bằng Generics và kế thừa (`extends`), sử dụng `Object` và `Class` (`Type`) của Dart.

## Cấu trúc

| File | Nội dung |
|------|----------|
| `base_manager.dart` | `BaseEntity` và `BaseManager<T extends BaseEntity>` (lớp Generics dùng chung) |
| `account_manager.dart` | `AccountData`, `AccountManager extends BaseManager<AccountData>` |
| `reminder_manager.dart` | `ReminderData`, `ReminderManager extends BaseManager<ReminderData>` |

## Đối tượng Generics
- `BaseEntity`: lớp cha của mọi dữ liệu, có `toMap()` trả về `Map<String, Object>`.
- `BaseManager<T>`: quản lý dữ liệu kiểu `T`, gồm `data`, `setData()`, `describe()`, `getInfo()`.

## Kế thừa và tổng quát hóa
- `AccountManager` và `ReminderManager` kế thừa `BaseManager` với kiểu dữ liệu riêng.
- **Object class:** `Map<String, Object>` trong `toMap()`, hàm `typeNameOf(Object obj)`.
- **Class class (`Type`):** `dataType` (kiểu `T`), `className` (`runtimeType`), `isDataOfType<R>()`.
- Giữ nguyên các getter và hàm cũ (`username`, `title`, `setAccountInfo`, `setReminder`...) nên các màn hình không cần sửa.

## Ví dụ

```dart
final acc = AccountManager();
final rem = ReminderManager();

print(acc.getInfo());                    // [AccountManager<AccountData>] Tài khoản: ...
print(acc.dataType);                     // AccountData
print(acc.isDataOfType<AccountData>());  // true
print(BaseManager.typeNameOf(rem));      // ReminderManager

final List<BaseManager> all = [acc, rem];
for (final m in all) {
  print(m.getInfo());
}
```

## Mở rộng
Thêm đối tượng mới: tạo `XxxData extends BaseEntity` và `XxxManager extends BaseManager<XxxData>`.