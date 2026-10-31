part of '../subject_screen.dart';

extension _SubjectForm on _SubjectScreenState {
  // Form thêm môn học
  Widget _formThemMon() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEDF5)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.add, color: _primary, size: 26),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Thêm môn học',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2B2C3A),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _chuyenTrangThaiForm,
                  icon: Icon(
                    _moForm ? Icons.close : Icons.add,
                    color: const Color(0xFF6E6F7E),
                  ),
                ),
              ],
            ),

            if (_moForm) ...[
              const SizedBox(height: 8),
              const Text(
                'Nhập thông tin môn học mới',
                style: TextStyle(fontSize: 12, color: Color(0xFF7A7E8F)),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _idController,
                      decoration: _oNhap('Mã môn *'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nhập mã môn';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _creditsController,
                      keyboardType: TextInputType.number,
                      decoration: _oNhap('Tín chỉ *'),
                      validator: (value) {
                        final n = int.tryParse(value?.trim() ?? '');
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
                controller: _nameController,
                decoration: _oNhap('Tên môn học *'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nhập tên môn học';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: _teacherController,
                decoration: _oNhap('Giảng viên'),
              ),

              const SizedBox(height: 16),
              SubjectAppearancePicker(
                colorKey: _colorKey,
                iconKey: _iconKey,
                onColorChanged: _chonMauMonHoc,
                onIconChanged: _chonIconMonHoc,
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _dangLuu
                          ? null
                          : () {
                              _formKey.currentState?.reset();
                              _idController.clear();
                              _nameController.clear();
                              _teacherController.clear();
                              _creditsController.clear();
                              _datLaiBieuTuongMonHoc();
                            },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF5F637C),
                        side: const BorderSide(color: Color(0xFFE2E5F1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: (_dangLuu || _dangTai) ? null : _themMonHoc,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.save_outlined, size: 18),
                      label: Text(_dangLuu ? 'Đang lưu...' : 'Lưu môn học'),
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
}
