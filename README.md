# Student Deadline Manager

Ứng dụng Flutter hỗ trợ sinh viên quản lý môn học, deadline, lịch học tập và
nhắc nhở công việc.

## Tính năng

- Đăng ký, đăng nhập, đăng xuất và đổi mật khẩu bằng Firebase Authentication.
- Xem và cập nhật thông tin tài khoản.
- Thêm, sửa, xóa, tìm kiếm và lọc môn học.
- Thêm, sửa, xóa và đánh dấu hoàn thành deadline.
- Xem deadline theo ngày trên lịch tháng.
- Tự tạo nhắc nhở trước deadline 24 giờ.
- Bật/tắt, xóa và gửi lại nhắc nhở.
- Xem deadline sắp tới, deadline trong ngày và thống kê theo khoảng thời gian,
  trạng thái và môn học.
- Hiển thị thông báo trên thiết bị hoặc trình duyệt khi ứng dụng đang mở.

## Công nghệ

- Flutter và Dart
- Firebase Authentication
- Cloud Firestore
- `flutter_local_notifications` cho Android/iOS
- Web Notifications cho trình duyệt
- `flutter_test`, `fake_cloud_firestore` và `firebase_auth_mocks`

## Yêu cầu môi trường

- Flutter SDK tương thích với Dart SDK `^3.9.0`
- Một thiết bị hoặc emulator Android/iOS, hoặc trình duyệt được Flutter hỗ trợ
- Firebase project đã bật:
  - Firebase Authentication với phương thức Email/Password
  - Cloud Firestore

## Cài đặt

Từ thư mục repository:

```bash
cd student_deadline_manager
flutter pub get
```

## Cấu hình Firebase

Project đã sử dụng cấu hình được sinh bởi FlutterFire trong:

```text
student_deadline_manager/lib/firebase_options.dart
```

Các file cấu hình nền tảng nằm trong thư mục `android/`, `ios/`, `web/`,
`windows/` và các thư mục Flutter tương ứng.

Khi kết nối Firebase project khác, không sửa thủ công các giá trị cấu hình.
Hãy chạy lại FlutterFire CLI để sinh cấu hình phù hợp:

```bash
flutterfire configure
```

Firestore Security Rules của project hiện được quản lý trên Firebase Console.
Trước khi chạy với dữ liệu thật, cần bảo đảm Rules giới hạn quyền truy cập theo
người dùng đăng nhập và `userId`.

## Chạy ứng dụng

```bash
cd student_deadline_manager
flutter run
```

Chọn thiết bị cụ thể nếu cần:

```bash
flutter devices
flutter run -d <device-id>
```

## Kiểm thử và phân tích mã nguồn

Chạy toàn bộ test:

```bash
cd student_deadline_manager
flutter test
```

Chạy kiểm tra phân tích:

```bash
flutter analyze
```

Test sử dụng Firestore và Firebase Auth giả lập trong bộ nhớ, vì vậy các test
đơn vị không cần kết nối đến Firebase thật.

## Kiến trúc thư mục

```text
student_deadline_manager/
├── lib/
│   ├── models/        Model dữ liệu và chuyển đổi Map/Document
│   ├── services/      Nghiệp vụ, Firebase và lập lịch thông báo
│   ├── controllers/   Trạng thái và điều khiển màn hình
│   ├── screens/       Các màn hình chính của ứng dụng
│   ├── widgets/       Widget dùng lại
│   ├── navigation/    Điều hướng và các tab chính
│   └── main.dart      Khởi tạo Firebase và AuthGate
├── test/              Unit test và widget test
├── android/           Cấu hình Android
├── ios/               Cấu hình iOS
├── web/               Cấu hình web
├── windows/           Cấu hình Windows
├── firebase.json      Cấu hình Firebase/FlutterFire
└── pubspec.yaml       Dependency và cấu hình Flutter
```

## Luồng hoạt động chính

1. `main.dart` khởi tạo Firebase.
2. `AuthGate` theo dõi trạng thái đăng nhập.
3. Người dùng đăng nhập thành công sẽ được chuyển tới `MainNavigation`.
4. `TaskService` quản lý deadline và `SubjectService` quản lý môn học.
5. `ReminderService` tạo và cập nhật các bản ghi nhắc nhở.
6. `NotificationScheduler` quét deadline định kỳ và gửi nhắc nhở khi đến giờ.

## Giới hạn hiện tại

- Nhắc nhở được xử lý khi ứng dụng đang mở; chưa có cơ chế gửi nền hoàn chỉnh
  khi ứng dụng bị đóng hoàn toàn.
- Thời gian nhắc mặc định là 24 giờ trước deadline và chưa cho phép người dùng
  cấu hình nhiều mốc nhắc.
- Chưa có chức năng xóa toàn bộ tài khoản cùng dữ liệu liên quan.
- Nút “Hoàn thành” trong nhóm dịch vụ nhanh trên Trang chủ chưa mở chức năng
  riêng; việc đánh dấu hoàn thành hiện thực hiện trên màn hình Lịch.
- Cấu hình Security Rules không nằm trong repository, cần kiểm tra riêng trên
  Firebase Console khi triển khai.

## Đóng góp

1. Tạo branch cho thay đổi.
2. Cập nhật hoặc bổ sung test liên quan.
3. Chạy `flutter analyze` và `flutter test`.
4. Tạo pull request kèm mô tả ngắn về thay đổi.

## Giấy phép

Repository phục vụ mục đích học tập và phát triển bài tập lớn. Chưa khai báo
license phát hành công khai.
