part of '../subject_screen.dart';

extension _SubjectEditDialog on _SubjectScreenState {
  // Sửa môn học
  Future<MonHoc?> _suaMonHoc(MonHoc monHoc) async {
    if (_dangTai || _dangLuu) return null;

    final formKey = GlobalKey<FormState>();

    String tenMon = monHoc.tenMonHoc;
    String giangVien = monHoc.giangVien;
    String tinChi = monHoc.soTinChi.toString();

    final monDaSua = await showDialog<MonHoc>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Chỉnh sửa môn học',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF24263A),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Đóng',
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Text(
                    'Cập nhật thông tin môn học của bạn.',
                    style: TextStyle(color: Color(0xFF7A7E91), fontSize: 12),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDEBFF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.menu_book_outlined,
                          color: _primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${monHoc.maMonHoc} · ${monHoc.soTinChi} tín chỉ',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: _primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                monHoc.tenMonHoc,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF27293C),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _editTextField(
                          label: 'Mã môn học',
                          initialValue: monHoc.maMonHoc,
                          readOnly: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: _editTextField(
                          label: 'Số tín chỉ',
                          initialValue: tinChi,
                          keyboardType: TextInputType.number,
                          onChanged: (value) => tinChi = value,
                          validator: (value) {
                            final credits = int.tryParse(value?.trim() ?? '');
                            if (credits == null || credits <= 0) {
                              return 'Số tín chỉ không hợp lệ';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _editTextField(
                    label: 'Tên môn học',
                    initialValue: tenMon,
                    onChanged: (value) => tenMon = value,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Vui lòng nhập tên môn học'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _editTextField(
                    label: 'Giảng viên',
                    initialValue: giangVien,
                    onChanged: (value) => giangVien = value,
                  ),
                  const SizedBox(height: 18),
                  const Divider(height: 1, color: Color(0xFFE8E9F0)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _primary,
                            backgroundColor: const Color(0xFFEDEBFF),
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Hủy'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Lưu thay đổi'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (monDaSua == null || !mounted) return null;

    try {
      await _controller.suaMonHoc(monDaSua);
      if (!mounted) return null;
      _thongBao('Sửa môn học thành công');
      return monDaSua;
    } catch (e) {
      if (!mounted) return null;
      _thongBao('Lỗi sửa môn học: $e');
      return null;
    }
  }

  Widget _editTextField({
    required String label,
    required String initialValue,
    bool readOnly = false,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
    FormFieldValidator<String>? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF45485C),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: initialValue,
          readOnly: readOnly,
          keyboardType: keyboardType,
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: readOnly ? const Color(0xFFF2F3F8) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 13,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: Color(0xFFE4E6F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: _primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }
}
