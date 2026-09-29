import 'package:flutter/material.dart';

import 'subject.dart';

class SubjectCard extends StatelessWidget {
  final MonHoc monHoc;

  const SubjectCard({
    super.key,
    required this.monHoc,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              monHoc.tenMonHoc,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text('Mã môn: ${monHoc.maMonHoc}'),
            Text('Giảng viên: ${monHoc.giangVien}'),
            Text('Số tín chỉ: ${monHoc.soTinChi}'),
          ],
        ),
      ),
    );
  }
}