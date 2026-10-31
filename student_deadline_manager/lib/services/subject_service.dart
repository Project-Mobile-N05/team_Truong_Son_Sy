import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/subject.dart';

class SubjectService {
  String get _ownerId {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Vui lòng đăng nhập để quản lý môn học');
    }
    return user.uid;
  }

  // Lấy collection môn học theo tài khoản đăng nhập
  CollectionReference<Map<String, dynamic>> get collection {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_ownerId)
        .collection('mon_hoc');
  }

  // Đọc danh sách môn học
  Future<List<MonHoc>> layDanhSach() async {
    final ownerId = _ownerId;
    final snapshot = await collection.get();
    return snapshot.docs
        .map((doc) => MonHoc.fromMap(doc.id, ownerId, doc.data()))
        .toList();
  }

  // Thêm môn học
  Future<void> themMonHoc(MonHoc monHoc) async {
    await collection.doc(monHoc.id).set(monHoc.toMap());
  }

  // Sửa thông tin môn học
  Future<void> suaMonHoc(MonHoc monHoc) async {
    await collection.doc(monHoc.id).update(monHoc.toMap());
  }

  // Xóa môn học
  Future<void> xoaMonHoc(String id) async {
    await collection.doc(id).delete();
  }
}
