import 'package:flutter/foundation.dart';

import '../models/project_entity.dart';
import '../models/subject.dart';
import '../services/subject_service.dart';

class SubjectController extends ChangeNotifier {
  final SubjectService _service;

  final ProjectCollection<MonHoc> _khoMonHoc = ProjectCollection<MonHoc>();

  SubjectController(this._service);

  bool isLoading = false;
  bool isSaving = false;

  List<MonHoc> get danhSachMonHoc => _khoMonHoc.items;

  // Tìm kiếm môn học
  List<MonHoc> timKiem(String tuKhoa) {
    final keyword = tuKhoa.trim().toLowerCase();

    if (keyword.isEmpty) return danhSachMonHoc;

    return danhSachMonHoc.where((mon) {
      return mon.maMonHoc.toLowerCase().contains(keyword) ||
          mon.tenMonHoc.toLowerCase().contains(keyword) ||
          mon.giangVien.toLowerCase().contains(keyword);
    }).toList();
  }

  // Đọc danh sách từ Firebase
  Future<void> layDanhSach() async {
    if (isLoading || isSaving) return;

    isLoading = true;
    notifyListeners();

    try {
      final danhSach = await _service.layDanhSach();

      for (final mon in List<MonHoc>.from(_khoMonHoc.items)) {
        _khoMonHoc.removeById(mon.maMonHoc);
      }

      for (final mon in danhSach) {
        _khoMonHoc.add(mon);
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Thêm môn học
  Future<void> themMonHoc(MonHoc monHoc) async {
    if (isSaving || isLoading) {
      throw StateError('Đang xử lý dữ liệu');
    }

    if (_khoMonHoc.findById(monHoc.maMonHoc) != null) {
      throw StateError('Mã môn học đã tồn tại');
    }

    isSaving = true;
    notifyListeners();

    try {
      await _service.themMonHoc(monHoc);
      _khoMonHoc.add(monHoc);
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  // Sửa môn học
  Future<void> suaMonHoc(MonHoc monHoc) async {
    if (isSaving || isLoading) {
      throw StateError('Đang xử lý dữ liệu');
    }

    isSaving = true;
    notifyListeners();

    try {
      await _service.suaMonHoc(monHoc);

      _khoMonHoc.removeById(monHoc.maMonHoc);
      _khoMonHoc.add(monHoc);
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  // Xóa môn học
  Future<void> xoaMonHoc(String maMonHoc) async {
    if (isSaving || isLoading) {
      throw StateError('Đang xử lý dữ liệu');
    }

    isSaving = true;
    notifyListeners();

    try {
      await _service.xoaMonHoc(maMonHoc);
      _khoMonHoc.removeById(maMonHoc);
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
