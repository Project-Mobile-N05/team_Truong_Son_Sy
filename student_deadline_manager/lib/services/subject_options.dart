import '../controllers/task_controller.dart';
import 'subject_service.dart';

Future<List<SubjectOption>> loadSubjectOptions(String userId) async {
  final danhSach = await SubjectService().layDanhSach();
  return [for (final mon in danhSach) SubjectOption(mon.id, mon.name)];
}
