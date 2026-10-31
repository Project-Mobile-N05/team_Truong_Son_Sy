import '../controllers/task_controller.dart';
import 'subject_service.dart';

/// Cầu nối module Môn học (Sơn) với màn Lịch và form deadline (Sỹ).
///
/// Lấy danh sách môn học của user đang đăng nhập từ [SubjectService] rồi đổi
/// sang [SubjectOption]. `Task.subjectId` lưu đúng mã môn học (`id`),
/// cũng là id của Document trong `users/{uid}/mon_hoc`.
///
/// Nếu module Môn học đổi tên lớp hay hàm thì chỉ cần sửa file này.
Future<List<SubjectOption>> loadSubjectOptions(String userId) async {
  final danhSach = await SubjectService().layDanhSach();
  return [for (final mon in danhSach) SubjectOption(mon.id, mon.name)];
}
