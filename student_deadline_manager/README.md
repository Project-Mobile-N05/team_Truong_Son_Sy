# Student Deadline Manager – áp dụng Generics (Dart/Flutter)

Đây là bản cập nhật bài tập **Generics** trên nhánh của thành viên phụ trách **Quản lý môn học** và **Thống kê**. Không thay đổi giao diện hay tự thêm module của thành viên khác.

## Câu 1 – Đối tượng Generic chung

Trong `lib/project_entity.dart` có:

```dart
abstract class ProjectEntity<TId extends Object> {
  final TId id;
  final String ten;

  const ProjectEntity({required this.id, required this.ten});

  Type get classType => runtimeType;

  Map<String, Object?> toMap();
}
```

- `TId`: kiểu mã định danh có thể là `String`, `int`,... tùy từng đối tượng.
- `extends Object`: không cho phép mã định danh thuộc kiểu nullable.
- `runtimeType`: thuộc tính kế thừa từ `Object`, trả về đối tượng kiểu `Type`.
- `Map<String, Object?>`: định dạng dữ liệu tổng quát cho các thuộc tính của model.

## Câu 2 – Cho các đối tượng kế thừa class chung

Trong `lib/subject.dart`:

```dart
class MonHoc extends ProjectEntity<String> {
  // maMonHoc (String) được chuyển cho id của lớp cha.
  // tenMonHoc (String) được chuyển cho ten của lớp cha.
}
```

Đã giữ lại API cũ (`maMonHoc`, `tenMonHoc`, `giangVien`, `soTinChi`, `getThongTinMonHoc`) để các màn hình khác không bị ảnh hưởng.

Trong `lib/project_entity.dart`, `ProjectCollection<T>` là một danh sách Generic dùng lại cho nhiều model. `lib/subject_screen.dart` sử dụng thật `ProjectCollection<MonHoc>` để lưu các môn học trên màn hình.

```dart
final ProjectCollection<MonHoc> kho = ProjectCollection<MonHoc>();
const mon = MonHoc(
  maMonHoc: 'CS305',
  tenMonHoc: 'Phát triển ứng dụng di động',
  giangVien: 'Giảng viên A',
  soTinChi: 3,
);
kho.add(mon);

final Object doiTuong = mon;     // Object class
final Type lop = doiTuong.runtimeType; // Type class (MonHoc)
print(lop);
print(kho.findById('CS305')?.tenMonHoc);
print(mon.toMap());
```

**Lưu ý về thuật ngữ:** Dart có `Object` và `Type` trong `dart:core`; không có một public core class tên `Class` dùng như trong Java. `class` là từ khóa khai báo lớp.

Hiện ZIP chỉ chứa **một model nghiệp vụ `MonHoc`**. Khi các thành viên bổ sung model của mình, họ có thể cho chúng `extends ProjectEntity<String>` hoặc `ProjectEntity<int>` để áp dụng chung mà không cần chỉnh sửa file của người khác.

## Chạy thử

Từ thư mục `student_deadline_manager`:

```bash
flutter pub get
flutter analyze
flutter run
```

Lưu ý: Phần lưu môn học hiện tại vẫn chỉ trong bộ nhớ ứng dụng; **chưa tích hợp MongoDB**. Bản cập nhật này chỉ triển khai yêu cầu Generics.
