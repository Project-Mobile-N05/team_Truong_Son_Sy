import 'package:flutter/material.dart';

import 'subject.dart';
import 'subject_card.dart';
import 'statistics_screen.dart';

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

  final List<MonHoc> _danhSachMonHoc = [];

  void _themMonHoc() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final soTinChi =
        int.tryParse(_soTinChiController.text.trim());

    if (soTinChi == null) {
      return;
    }

    final monHoc = MonHoc(
      maMonHoc: _maMonHocController.text.trim(),
      tenMonHoc: _tenMonHocController.text.trim(),
      giangVien: _giangVienController.text.trim(),
      soTinChi: soTinChi,
    );

    setState(() {
      _danhSachMonHoc.add(monHoc);
    });

    _maMonHocController.clear();
    _tenMonHocController.clear();
    _giangVienController.clear();
    _soTinChiController.clear();
  }

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

  @override
  void dispose() {
    _maMonHocController.dispose();
    _tenMonHocController.dispose();
    _giangVienController.dispose();
    _soTinChiController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý môn học'),

        actions: [
          TextButton.icon(
            onPressed: _moThongKe,
            icon: const Icon(Icons.bar_chart),
            label: const Text('Thống kê'),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _maMonHocController,
                decoration: const InputDecoration(
                  labelText: 'Mã môn học',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập mã môn học';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _tenMonHocController,
                decoration: const InputDecoration(
                  labelText: 'Tên môn học',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên môn học';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _giangVienController,
                decoration: const InputDecoration(
                  labelText: 'Giảng viên',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _soTinChiController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Số tín chỉ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final soTinChi =
                      int.tryParse(value?.trim() ?? '');

                  if (soTinChi == null) {
                    return 'Số tín chỉ phải là số nguyên';
                  }

                  if (soTinChi <= 0) {
                    return 'Số tín chỉ phải lớn hơn 0';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _themMonHoc,
                child: const Text('Thêm môn học'),
              ),

              const SizedBox(height: 24),

              Text(
                'Danh sách môn học',
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: 12),

              if (_danhSachMonHoc.isEmpty)
                const Text(
                  'Chưa có môn học nào.',
                  textAlign: TextAlign.center,
                )
              else
                ..._danhSachMonHoc.map(
                  (monHoc) => SubjectCard(
                    monHoc: monHoc,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}