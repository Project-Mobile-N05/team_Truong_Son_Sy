import 'package:flutter_test/flutter_test.dart';
import 'package:student_deadline_manager/controllers/subject_controller.dart';
import 'package:student_deadline_manager/models/subject.dart';
import 'package:student_deadline_manager/services/subject_service.dart';

class _FakeSubjectService extends SubjectService {
  final Map<String, MonHoc> subjects = {};
  Object? failure;

  @override
  Future<List<MonHoc>> layDanhSach() async {
    _throwIfNeeded();
    return subjects.values.toList();
  }

  @override
  Future<void> themMonHoc(MonHoc subject) async {
    _throwIfNeeded();
    subjects[subject.id] = subject;
  }

  @override
  Future<void> suaMonHoc(MonHoc subject) async {
    _throwIfNeeded();
    subjects[subject.id] = subject;
  }

  @override
  Future<void> xoaMonHoc(String id) async {
    _throwIfNeeded();
    subjects.remove(id);
  }

  void _throwIfNeeded() {
    final error = failure;
    if (error != null) throw error;
  }
}

MonHoc _subject(String id, String name, {String teacher = ''}) =>
    MonHoc(id: id, userId: 'user-1', name: name, teacher: teacher);

void main() {
  late _FakeSubjectService service;
  late SubjectController controller;

  setUp(() {
    service = _FakeSubjectService();
    controller = SubjectController(service);
  });

  group('quản lý môn học', () {
    test('thêm môn học vào service và danh sách', () async {
      final subject = _subject('CS101', 'Lập trình', teacher: 'An');

      await controller.themMonHoc(subject);

      expect(controller.danhSachMonHoc, [subject]);
      expect(service.subjects['CS101'], subject);
      expect(controller.isSaving, isFalse);
    });

    test('không thêm môn học trùng mã', () async {
      await controller.themMonHoc(_subject('CS101', 'Lập trình'));

      await expectLater(
        controller.themMonHoc(_subject('CS101', 'Môn khác')),
        throwsA(isA<StateError>()),
      );

      expect(controller.danhSachMonHoc, hasLength(1));
      expect(controller.danhSachMonHoc.single.name, 'Lập trình');
    });

    test('sửa thông tin môn học trong danh sách hiện tại', () async {
      await controller.themMonHoc(_subject('CS101', 'Tên cũ'));
      final updated = _subject('CS101', 'Tên mới', teacher: 'Bình');

      await controller.suaMonHoc(updated);

      expect(controller.danhSachMonHoc, [updated]);
      expect(service.subjects['CS101']?.teacher, 'Bình');
    });

    test('xóa môn học khỏi service và danh sách', () async {
      await controller.themMonHoc(_subject('CS101', 'Lập trình'));

      await controller.xoaMonHoc('CS101');

      expect(controller.danhSachMonHoc, isEmpty);
      expect(service.subjects, isEmpty);
    });

    test('tải lại danh sách thay thế dữ liệu cũ', () async {
      await controller.themMonHoc(_subject('OLD', 'Môn cũ'));
      service.subjects
        ..clear()
        ..['NEW'] = _subject('NEW', 'Môn mới');

      await controller.layDanhSach();

      expect(controller.danhSachMonHoc.map((subject) => subject.id), ['NEW']);
      expect(controller.isLoading, isFalse);
    });

    test(
      'tìm kiếm không phân biệt hoa thường, bỏ khoảng trắng và tìm theo mã, tên, giảng viên',
      () async {
        await controller.themMonHoc(
          _subject('CS101', 'Lập trình', teacher: 'Nguyễn An'),
        );
        await controller.themMonHoc(_subject('MA102', 'Toán rời rạc'));

        expect(controller.timKiem('  cs1 '), hasLength(1));
        expect(controller.timKiem('LẬP TRÌNH').single.id, 'CS101');
        expect(controller.timKiem('nguyễn an').single.id, 'CS101');
        expect(controller.timKiem('   '), hasLength(2));
      },
    );

    test('lỗi lưu được truyền ra và trạng thái saving được dọn', () async {
      service.failure = Exception('network error');

      await expectLater(
        controller.themMonHoc(_subject('CS101', 'Lập trình')),
        throwsA(isA<Exception>()),
      );

      expect(controller.danhSachMonHoc, isEmpty);
      expect(controller.isSaving, isFalse);
    });
  });
}
