
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subject.dart';

class SubjectService {
  final collection =
      FirebaseFirestore.instance.collection('mon_hoc');

  // Đọc danh sách môn học
  Future<List<MonHoc>> layDanhSach() async {
    final snapshot = await collection.get(
      const GetOptions(source: Source.server),
    );

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return MonHoc(
        maMonHoc: doc.id,
        tenMonHoc: data['tenMonHoc'] as String,
        giangVien: data['giangVien'] as String,
        soTinChi: (data['soTinChi'] as num).toInt(),
      );
    }).toList();
  }

  // Lưu môn học
  Future<void> themMonHoc(MonHoc monHoc) async {
    await collection
        .doc(monHoc.maMonHoc)
        .set(monHoc.toMap());
  }
  // Sửa thông tin môn học
Future<void> suaMonHoc(MonHoc monHoc) async {
  await collection.doc(monHoc.maMonHoc).update({
    'tenMonHoc': monHoc.tenMonHoc,
    'giangVien': monHoc.giangVien,
    'soTinChi': monHoc.soTinChi,
  });
}

// Xóa môn học
Future<void> xoaMonHoc(String maMonHoc) async {
  await collection.doc(maMonHoc).delete();
}
}