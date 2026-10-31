
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/subject.dart';

class SubjectService {
  // Lấy collection môn học theo tài khoản đăng nhập
  CollectionReference<Map<String, dynamic>> get collection {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw StateError('Vui lòng đăng nhập để quản lý môn học');
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('mon_hoc');
  }

  // Đọc danh sách môn học
  Future<List<MonHoc>> layDanhSach() async {
    final snapshot = await collection.get();

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

  // Thêm môn học
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
