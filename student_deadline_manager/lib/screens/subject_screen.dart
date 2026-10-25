import 'package:flutter/material.dart';

import '../models/subject.dart';
import '../services/subject_service.dart';
import '../controllers/subject_controller.dart';
import 'statistics_screen.dart';

const _primary = Color(0xFF5147BD);
const _background = Color(0xFFF7F8FC);

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

  bool get _dangTai => _controller.isLoading;
  bool get _dangLuu => _controller.isSaving;
  bool _moForm = true;

  List<MonHoc> get _danhSachMonHoc => _controller.danhSachMonHoc;

  List<MonHoc> get _ketQuaTimKiem =>
      _controller.timKiem(_timKiemController.text);

  @override
  void initState() {
    super.initState();
    _controller.addListener(_capNhatGiaoDien);
    _layDanhSach();
  }

  void _capNhatGiaoDien() {
    if (mounted) setState(() {});
  }

  void _thongBao(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  // Đọc dữ liệu từ Firebase qua Controller
  Future<void> _layDanhSach() async {
    try {
      await _controller.layDanhSach();
    } catch (e) {
      if (!mounted) return;
      _thongBao('Lỗi tải môn học: $e');
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

  // Sửa môn học
  Future<void> _suaMonHoc(MonHoc monHoc) async {
    if (_dangTai || _dangLuu) return;

    final formKey = GlobalKey<FormState>();

    String tenMon = monHoc.tenMonHoc;
    String giangVien = monHoc.giangVien;
    String tinChi = monHoc.soTinChi.toString();

    final monDaSua = await showDialog<MonHoc>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sửa môn học'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Mã môn: ${monHoc.maMonHoc}'),

                TextFormField(
                  initialValue: tenMon,
                  decoration: const InputDecoration(
                    labelText: 'Tên môn học',
                  ),
                  onChanged: (value) => tenMon = value,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên môn học';
                    }
                    return null;
                  },
                ),

                TextFormField(
                  initialValue: giangVien,
                  decoration: const InputDecoration(
                    labelText: 'Giảng viên',
                  ),
                  onChanged: (value) => giangVien = value,
                ),

                TextFormField(
                  initialValue: tinChi,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Số tín chỉ',
                  ),
                  onChanged: (value) => tinChi = value,
                  validator: (value) {
                    final so = int.tryParse(value?.trim() ?? '');

                    if (so == null || so <= 0) {
                      return 'Số tín chỉ phải là số nguyên dương';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;

              Navigator.pop(
                dialogContext,
                MonHoc(
                  maMonHoc: monHoc.maMonHoc,
                  tenMonHoc: tenMon.trim(),
                  giangVien: giangVien.trim(),
                  soTinChi: int.parse(tinChi.trim()),
                ),
              );
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    if (monDaSua == null || !mounted) return;

    try {
      await _controller.suaMonHoc(monDaSua);
      if (!mounted) return;
      _thongBao('Sửa môn học thành công');
    } catch (e) {
      if (!mounted) return;
      _thongBao('Lỗi sửa môn học: $e');
    }
  }

  // Xóa môn học
  Future<void> _xoaMonHoc(MonHoc monHoc) async {
    if (_dangTai || _dangLuu) return;

    final xacNhan = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa môn học'),
        content: Text(
          'Bạn có chắc muốn xóa ${monHoc.tenMonHoc}?',
        ),
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
        builder: (context) => StatisticsScreen(
          danhSachMonHoc: _danhSachMonHoc,
        ),
      ),
    );
  }

  // Ô nhập liệu theo Figma
  InputDecoration _oNhap(String nhan) {
    return InputDecoration(
      labelText: nhan,
      filled: true,
      fillColor: _background,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  // Card môn học
  Widget _theMonHoc(MonHoc monHoc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFEDEDF5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EEFF),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.menu_book_outlined,
                  size: 18,
                  color: _primary,
                ),
                Text(
                  monHoc.maMonHoc,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9,
                    color: _primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  monHoc.tenMonHoc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'GV: ${monHoc.giangVien}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '${monHoc.soTinChi} tín chỉ',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          Column(
            children: [
              IconButton(
                tooltip: 'Sửa môn học',
                onPressed: _dangLuu
                    ? null
                    : () => _suaMonHoc(monHoc),
                icon: const Icon(
                  Icons.edit_outlined,
                  color: _primary,
                  size: 20,
                ),
              ),

              IconButton(
                tooltip: 'Xóa môn học',
                onPressed: _dangLuu
                    ? null
                    : () => _xoaMonHoc(monHoc),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Form thêm môn học
  Widget _formThemMon() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEDEDF5),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Thêm môn học',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() => _moForm = !_moForm);
                  },
                  icon: Icon(
                    _moForm ? Icons.close : Icons.add,
                  ),
                ),
              ],
            ),

            if (_moForm) ...[
              const Text(
                'Nhập thông tin môn học mới',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _maMonHocController,
                      decoration: _oNhap('Mã môn'),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Nhập mã môn';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: TextFormField(
                      controller: _soTinChiController,
                      keyboardType: TextInputType.number,
                      decoration: _oNhap('Số tín chỉ'),
                      validator: (value) {
                        final n = int.tryParse(
                          value?.trim() ?? '',
                        );

                        if (n == null || n <= 0) {
                          return 'Tín chỉ không hợp lệ';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: _tenMonHocController,
                decoration: _oNhap('Tên môn học'),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Nhập tên môn học';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: _giangVienController,
                decoration: _oNhap('Giảng viên'),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _dangLuu
                          ? null
                          : () {
                              _formKey.currentState?.reset();
                              _maMonHocController.clear();
                              _tenMonHocController.clear();
                              _giangVienController.clear();
                              _soTinChiController.clear();
                            },
                      child: const Text('Hủy'),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: (_dangLuu || _dangTai)
                          ? null
                          : _themMonHoc,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(
                        Icons.save_outlined,
                        size: 18,
                      ),
                      label: Text(
                        _dangLuu
                            ? 'Đang lưu...'
                            : 'Lưu môn học',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_capNhatGiaoDien);
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
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: _dangTai ? null : _moThongKe,
            child: const Text(
              'Thống kê →',
              style: TextStyle(color: _primary),
            ),
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _layDanhSach,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            16, 8, 16, 24,
          ),
          children: [
            // Thanh tìm kiếm
            TextField(
              controller: _timKiemController,
              onChanged: (value) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText:
                    'Tìm theo mã, tên hoặc giảng viên',
                hintStyle: const TextStyle(fontSize: 12),
                prefixIcon: const Icon(Icons.search),

                suffixIcon:
                    _timKiemController.text.isEmpty
                        ? const Icon(Icons.tune)
                        : IconButton(
                            onPressed: () {
                              _timKiemController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close),
                          ),

                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFEDEDF5),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Tiêu đề học kỳ
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Học kỳ 1 • 2026',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                Text(
                  '${_ketQuaTimKiem.length} môn',
                  style: const TextStyle(
                    fontSize: 12,
                    color: _primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Danh sách môn học
            if (_dangTai)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_ketQuaTimKiem.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Không có môn học phù hợp.',
                  textAlign: TextAlign.center,
                ),
              )
            else
              ..._ketQuaTimKiem.map(_theMonHoc),

            const SizedBox(height: 10),

            // Form thêm môn học
            _formThemMon(),
          ],
        ),
      ),
    );
  }
}
