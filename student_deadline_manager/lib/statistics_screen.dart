import 'package:flutter/material.dart';

import 'subject.dart';

class StatisticsScreen extends StatelessWidget {
  final List<MonHoc> danhSachMonHoc;

  const StatisticsScreen({
    super.key,
    required this.danhSachMonHoc,
  });

  int get tongSoTinChi {
    return danhSachMonHoc.fold(
      0,
      (tong, monHoc) => tong + monHoc.soTinChi,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê học tập'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.menu_book,
                      size: 40,
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Tổng số môn học',
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${danhSachMonHoc.length}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.school,
                      size: 40,
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Tổng số tín chỉ',
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '$tongSoTinChi',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Danh sách môn học',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 12),

            if (danhSachMonHoc.isEmpty)
              const Text(
                'Chưa có dữ liệu để thống kê.',
              )
            else
              ...danhSachMonHoc.map(
                (monHoc) => ListTile(
                  leading: const Icon(
                    Icons.book_outlined,
                  ),
                  title: Text(
                    monHoc.tenMonHoc,
                  ),
                  subtitle: Text(
                    monHoc.maMonHoc,
                  ),
                  trailing: Text(
                    '${monHoc.soTinChi} tín chỉ',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}