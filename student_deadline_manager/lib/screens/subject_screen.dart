import 'dart:async';

import 'package:flutter/material.dart';

import '../models/subject.dart';
import '../models/task_status.dart';
import '../services/auth_service.dart';
import '../services/subject_service.dart';
import '../services/task_service.dart';
import '../controllers/subject_controller.dart';
import 'statistics_screen.dart';
import 'subject/widgets/subject_card.dart';

part 'subject/subject_search_screen.dart';
part 'subject/subject_edit_dialog.dart';
part 'subject/subject_form.dart';

const _primary = Color(0xFF5147BD);
const _background = Color(0xFFF7F8FC);

class _SubjectSearchFilters {
  final String query;
  final int? credits;
  final String? teacher;

  const _SubjectSearchFilters({
    required this.query,
    required this.credits,
    required this.teacher,
  });
}

class SubjectScreen extends StatefulWidget {
  const SubjectScreen({super.key});

  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  final _formKey = GlobalKey<FormState>();

  final _maMonHocController = TextEditingController();
  final _tenMonHocController = TextEditingController();
  final _giangVienController = TextEditingController();
  final _soTinChiController = TextEditingController();
  final _timKiemController = TextEditingController();

  final SubjectController _controller = SubjectController(SubjectService());
  final TaskService _taskService = TaskService();

  bool get _dangTai => _controller.isLoading;
  bool get _dangLuu => _controller.isSaving;
  bool _moForm = true;
  bool _dangTaiDeadline = true;
  int? _locTinChi;
  String? _locGiangVien;
  Map<String, int> _soDeadlineTheoMon = {};

  List<MonHoc> get _danhSachMonHoc => _controller.danhSachMonHoc;

  List<MonHoc> get _ketQuaTimKiem => _controller
      .timKiem(_timKiemController.text)
      .where(
        (monHoc) =>
            (_locTinChi == null || monHoc.soTinChi == _locTinChi) &&
            (_locGiangVien == null || monHoc.giangVien == _locGiangVien),
      )
      .toList();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_capNhatGiaoDien);
    TaskService.taskChanges.addListener(_onTaskChanges);
    _layDanhSach();
  }

  void _onTaskChanges() {
    if (mounted) unawaited(_laySoDeadline());
  }

  void _capNhatGiaoDien() {
    if (mounted) setState(() {});
  }

  void _thongBao(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // Đọc dữ liệu từ Firebase qua Controller
  Future<void> _layDanhSach() async {
    try {
      await Future.wait([
        _controller.layDanhSach(),
        _laySoDeadline(),
      ]);
    } catch (e) {
      if (!mounted) return;
      _thongBao('Lỗi tải môn học: $e');
    }
  }

  Future<void> _laySoDeadline() async {
    final uid = AuthService().currentUid;
    if (uid == null) {
      if (!mounted) return;
      setState(() => _dangTaiDeadline = false);
      _thongBao('Không thể tải deadline: Bạn chưa đăng nhập');
      return;
    }

    if (mounted) {
      setState(() {
        _dangTaiDeadline = true;
        _soDeadlineTheoMon = {};
      });
    }
    try {
      final tasks = await _taskService.findAll(uid);
      final counts = <String, int>{};
      for (final task in tasks) {
        final subjectId = task.subjectId;
        if (subjectId != null && task.status != TaskStatus.completed) {
          counts.update(subjectId, (count) => count + 1, ifAbsent: () => 1);
        }
      }

      if (!mounted) return;
      setState(() {
        _soDeadlineTheoMon = counts;
        _dangTaiDeadline = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _dangTaiDeadline = false);
      _thongBao('Lỗi tải deadline: $e');
    }
  }

  // Thêm môn học
  Future<void> _themMonHoc() async {
    if (_dangTai || _dangLuu) return;
    if (!_formKey.currentState!.validate()) return;

    final monHoc = MonHoc(
      maMonHoc: _maMonHocController.text.trim(),
      tenMonHoc: _tenMonHocController.text.trim(),
      giangVien: _giangVienController.text.trim(),
      soTinChi: int.parse(_soTinChiController.text.trim()),
    );

    try {
      await _controller.themMonHoc(monHoc);
      if (!mounted) return;

      _maMonHocController.clear();
      _tenMonHocController.clear();
      _giangVienController.clear();
      _soTinChiController.clear();

      _thongBao('Thêm môn học thành công');
    } catch (e) {
      if (!mounted) return;
      _thongBao('Lỗi thêm môn học: $e');
    }
  }

  void _chuyenTrangThaiForm() {
    setState(() => _moForm = !_moForm);
  }

  Future<void> _moBoLoc() async {
    final filters = await Navigator.push<_SubjectSearchFilters>(
      context,
      MaterialPageRoute(
        builder: (_) => _SubjectSearchScreen(
          danhSachMonHoc: _danhSachMonHoc,
          tuKhoaBanDau: _timKiemController.text,
          tinChiBanDau: _locTinChi,
          giangVienBanDau: _locGiangVien,
          onEdit: _suaMonHoc,
        ),
      ),
    );
    if (filters == null || !mounted) return;
    setState(() {
      _timKiemController.text = filters.query;
      _locTinChi = filters.credits;
      _locGiangVien = filters.teacher;
    });
  }

  // Xóa môn học
  Future<void> _xoaMonHoc(MonHoc monHoc) async {
    if (_dangTai || _dangLuu) return;

    final xacNhan = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa môn học'),
        content: Text('Bạn có chắc muốn xóa ${monHoc.tenMonHoc}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (xacNhan != true || !mounted) return;

    try {
      await _controller.xoaMonHoc(monHoc.maMonHoc);
      if (!mounted) return;
      _thongBao('Xóa môn học thành công');
    } catch (e) {
      if (!mounted) return;
      _thongBao('Lỗi xóa môn học: $e');
    }
  }

  // Mở thống kê
  void _moThongKe() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatisticsScreen(danhSachMonHoc: _danhSachMonHoc),
      ),
    );
  }

  // Ô nhập liệu theo Figma
  InputDecoration _oNhap(String nhan) {
    return InputDecoration(
      labelText: nhan,
      filled: true,
      fillColor: _background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_capNhatGiaoDien);
    TaskService.taskChanges.removeListener(_onTaskChanges);
    _controller.dispose();
    _maMonHocController.dispose();
    _tenMonHocController.dispose();
    _giangVienController.dispose();
    _soTinChiController.dispose();
    _timKiemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,

      appBar: AppBar(
        backgroundColor: _background,
        title: const Text(
          'Quản lý môn học',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF202235),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: _dangTai ? null : _moThongKe,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFEDEBFF),
                foregroundColor: _primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                shape: const StadiumBorder(),
              ),
              icon: const Icon(Icons.bar_chart_rounded, size: 19),
              label: const Text(
                'Thống kê',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _layDanhSach,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            TextField(
              controller: _timKiemController,
              onChanged: (value) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Tìm theo mã, tên hoặc giảng viên',
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8388A1),
                ),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF8890A6)),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_timKiemController.text.isNotEmpty)
                      IconButton(
                        tooltip: 'Xóa tìm kiếm',
                        onPressed: () {
                          _timKiemController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close, color: Color(0xFF8890A6)),
                      ),
                    IconButton(
                      tooltip: 'Tìm kiếm và lọc môn học',
                      onPressed: _moBoLoc,
                      icon: const Icon(Icons.tune, color: Color(0xFF8890A6)),
                    ),
                  ],
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Danh sách môn học',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2130),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE8FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_ketQuaTimKiem.length} môn',
                    style: const TextStyle(
                      fontSize: 12,
                      color: _primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (_dangTai)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_ketQuaTimKiem.isEmpty)
              Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Không có môn học phù hợp.',
                  textAlign: TextAlign.center,
                ),
              )
            else
              ..._ketQuaTimKiem.map(
                (monHoc) => SubjectCard(
                  monHoc: monHoc,
                  isSaving: _dangLuu,
                  isLoadingDeadlines: _dangTaiDeadline,
                  deadlineCount: _soDeadlineTheoMon[monHoc.maMonHoc] ?? 0,
                  onEdit: (monHoc) async {
                    await _suaMonHoc(monHoc);
                  },
                  onDelete: _xoaMonHoc,
                ),
              ),

            const SizedBox(height: 12),

            _formThemMon(),
          ],
        ),
      ),
    );
  }
}
