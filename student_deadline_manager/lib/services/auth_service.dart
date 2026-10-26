import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/account_data.dart';
import 'firestore_repository.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => message;
}

class AuthService {
  static final ValueNotifier<bool> busy = ValueNotifier<bool>(false);

  final FirebaseAuth _auth;
  final FirestoreRepository<AccountData> _users;

  AuthService({FirebaseAuth? auth, FirestoreRepository<AccountData>? users})
      : _auth = auth ?? FirebaseAuth.instance,
        _users = users ??
            FirestoreRepository<AccountData>('users', AccountData.fromMap);

  static final RegExp _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? validateEmail(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Vui lòng nhập email';
    if (!_emailRe.hasMatch(s)) return 'Email không đúng định dạng';
    return null;
  }

  static String? validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (v.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
    return null;
  }

  static String? validateRequired(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? 'Vui lòng nhập $label' : null;

  String? get currentUid => _auth.currentUser?.uid;

  Future<AccountData> login(String email, String password) async {
    final err = validateEmail(email) ??
        (password.isEmpty ? 'Vui lòng nhập mật khẩu' : null);
    if (err != null) throw AuthException(err);

    busy.value = true;
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);
      try {
        final profile = await _users.getById(cred.user!.uid);
        if (profile == null) {
          await _auth.signOut();
          throw const AuthException('Không tìm thấy hồ sơ tài khoản');
        }
        return profile;
      } on RepositoryException catch (e) {
        await _auth.signOut();
        throw AuthException(e.message);
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(_message(e.code));
    } finally {
      busy.value = false;
    }
  }

  Future<AccountData> register({
    required String studentCode,
    required String fullName,
    required String email,
    required String password,
  }) async {
    final err = validateRequired(studentCode, 'mã sinh viên') ??
        validateRequired(fullName, 'họ tên') ??
        validateEmail(email) ??
        validatePassword(password);
    if (err != null) throw AuthException(err);

    busy.value = true;
    try {
      UserCredential cred;
      try {
        cred = await _auth.createUserWithEmailAndPassword(
            email: email.trim(), password: password);
      } on FirebaseAuthException catch (e) {
        throw AuthException(_message(e.code));
      }

      final user = cred.user!;
      final profile = AccountData(
        id: user.uid,
        studentCode: studentCode.trim(),
        fullName: fullName.trim(),
        email: email.trim(),
      );
      try {
        await _users.update(user.uid, profile); // set theo id = uid
        return profile;
      } on RepositoryException catch (e) {
        try {
          await user.delete();
        } catch (_) {}
        throw AuthException('Không lưu được hồ sơ: ${e.message}');
      }
    } finally {
      busy.value = false;
    }
  }

  Future<void> logout() => _auth.signOut();

  Future<AccountData> getProfile() async {
    final uid = currentUid;
    if (uid == null) throw const AuthException('Bạn chưa đăng nhập');
    try {
      final p = await _users.getById(uid);
      if (p == null) throw const AuthException('Không tìm thấy hồ sơ tài khoản');
      return p;
    } on RepositoryException catch (e) {
      throw AuthException(e.message);
    }
  }

  Future<AccountData> updateProfile(String fullName) async {
    final err = validateRequired(fullName, 'họ tên');
    if (err != null) throw AuthException(err);
    final current = await getProfile();
    final updated = current.copyWith(fullName: fullName.trim());
    try {
      await _users.update(current.id!, updated);
      return updated;
    } on RepositoryException catch (e) {
      throw AuthException(e.message);
    }
  }

  Future<void> changePassword(String current, String next) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw const AuthException('Bạn chưa đăng nhập');
    }
    if (current.isEmpty) {
      throw const AuthException('Vui lòng nhập mật khẩu hiện tại');
    }
    final err = validatePassword(next);
    if (err != null) throw AuthException(err);
    try {
      await user.reauthenticateWithCredential(
          EmailAuthProvider.credential(email: user.email!, password: current));
      await user.updatePassword(next);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_message(e.code));
    }
  }

  String _message(String code) {
    switch (code) {
      case 'invalid-email':
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Thông tin đăng nhập không chính xác';
      case 'email-already-in-use':
        return 'Email đã được sử dụng';
      case 'weak-password':
        return 'Mật khẩu quá yếu';
      case 'configuration-not-found':
      case 'operation-not-allowed':
        return 'Chưa bật đăng nhập Email/Password trên Firebase';
      case 'requires-recent-login':
        return 'Vui lòng đăng nhập lại rồi thử lại';
      case 'user-disabled':
        return 'Tài khoản đã bị khóa';
      case 'too-many-requests':
        return 'Thử quá nhiều lần, vui lòng đợi rồi thử lại';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng';
      default:
        return 'Có lỗi xảy ra ($code)';
    }
  }
}