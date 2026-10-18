# team_Truong_Son_Sy
# Ứng dụng Nhắc việc & Quản lý Deadline cho Sinh viên

## Thông tin thành viên
- **Thành viên:** Sỹ
- **Phân công:** Quản lý công việc/deadline, Giao diện Lịch (CalendarTaskScreen), Tổng quát hóa dữ liệu bằng Generics.

## Tính năng & Cấu trúc lập trình (Tuần này)
1. **Tổng quát hóa dữ liệu (Generics & Object Class):**
   - Xây dựng lớp abstract `BaseEntity<ID>` làm nền tảng cho mọi model trong dự án.
   - Ghi đè phương thức `toString()` và `operator ==` từ lớp gốc `Object`.
   - Tạo lớp `GenericManager<T extends BaseEntity>` xử lý CRUD và quản lý danh sách tổng quát.
   - Sử dụng kiểu `Type` (tương đương `Class` class) để truy xuất thông tin metadata của lớp ở runtime (`runtimeType`).
2. **Nâng cấp lớp Task:**
   - Lớp `Task` kế thừa (`extends`) từ `BaseEntity<String>`.
3. **Cập nhật giao diện CalendarTaskScreen:**
   - Hiển thị danh sách Task lấy từ `GenericManager<Task>`.
   - Hiển thị thông tin Runtime Class của danh sách quản lý.
