import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_deadline_manager/models/account_data.dart';
import 'package:student_deadline_manager/services/auth_service.dart';
import 'package:student_deadline_manager/services/firestore_repository.dart';
import 'package:student_deadline_manager/models/student_code_data.dart';

Matcher authError(String message) =>
    throwsA(isA<AuthException>().having((e) => e.message, 'message', message));

void main() {
  group('validateEmail', () {
    test('rỗng hoặc chỉ có khoảng trắng', () {
      expect(AuthService.validateEmail(null), 'Vui lòng nhập email');
      expect(AuthService.validateEmail(''), 'Vui lòng nhập email');
      expect(AuthService.validateEmail('   '), 'Vui lòng nhập email');
    });

    test('sai định dạng', () {
      expect(AuthService.validateEmail('abc'), 'Email không đúng định dạng');
      expect(AuthService.validateEmail('a@b'), 'Email không đúng định dạng');
      expect(AuthService.validateEmail('a b@c.com'),
          'Email không đúng định dạng');
    });

    test('hợp lệ (có thể có khoảng trắng hai đầu)', () {
      expect(AuthService.validateEmail('a@st.phenikaa-uni.edu.vn'), isNull);
      expect(AuthService.validateEmail('  a@b.com  '), isNull);
    });
  });

  group('validatePassword', () {
    test('rỗng', () {
      expect(AuthService.validatePassword(null), 'Vui lòng nhập mật khẩu');
      expect(AuthService.validatePassword(''), 'Vui lòng nhập mật khẩu');
    });

    test('dưới 6 ký tự', () {
      expect(AuthService.validatePassword('12345'),
          'Mật khẩu tối thiểu 6 ký tự');
    });

    test('từ 6 ký tự trở lên là hợp lệ', () {
      expect(AuthService.validatePassword('123456'), isNull);
    });
  });

  group('validateRequired', () {
    test('rỗng thì báo thiếu theo nhãn', () {
      expect(AuthService.validateRequired('', 'họ tên'),
          'Vui lòng nhập họ tên');
      expect(AuthService.validateRequired('  ', 'họ tên'),
          'Vui lòng nhập họ tên');
    });

    test('có nội dung thì hợp lệ', () {
      expect(AuthService.validateRequired('A', 'họ tên'), isNull);
    });
  });

  group('AuthService với Firebase giả', () {
    late FakeFirebaseFirestore fs;
    late MockFirebaseAuth auth;
    late AuthService service;

    setUp(() {
      fs = FakeFirebaseFirestore();
      auth = MockFirebaseAuth(); // chưa đăng nhập
      service = AuthService(
        auth: auth,
        users: FirestoreRepository<AccountData>('users', AccountData.fromMap,
            firestore: fs),
        codes: FirestoreRepository<StudentCodeData>(
            'student_codes', StudentCodeData.fromMap,
            firestore: fs),
      );
    });

    Future<int> countUsers() async => (await fs.collection('users').get()).size;

    test('register thiếu mã sinh viên: báo lỗi, không tạo hồ sơ', () async {
      await expectLater(
        service.register(
            studentCode: '',
            fullName: 'A',
            email: 'a@b.com',
            password: '123456'),
        authError('Vui lòng nhập mã sinh viên'),
      );
      expect(await countUsers(), 0);
      expect(AuthService.busy.value, isFalse);
    });

    test('register email sai định dạng: báo lỗi', () async {
      await expectLater(
        service.register(
            studentCode: '1', fullName: 'A', email: 'abc', password: '123456'),
        authError('Email không đúng định dạng'),
      );
      expect(await countUsers(), 0);
    });

    test('register mật khẩu quá ngắn: báo lỗi', () async {
      await expectLater(
        service.register(
            studentCode: '1',
            fullName: 'A',
            email: 'a@b.com',
            password: '123'),
        authError('Mật khẩu tối thiểu 6 ký tự'),
      );
      expect(await countUsers(), 0);
    });

    test('register trùng mã sinh viên: báo lỗi, không tạo thêm hồ sơ', () async {
      await service.register(
          studentCode: '241077', fullName: 'A', email: 'a@b.com', password: '123456');
      await expectLater(
        service.register(
            studentCode: '241077', fullName: 'B', email: 'b@b.com', password: '123456'),
        authError('Mã sinh viên đã được đăng ký'),
      );
      expect(await countUsers(), 1);
    });
    
    test('register hợp lệ: tạo đúng một hồ sơ, bỏ khoảng trắng thừa', () async {
      final acc = await service.register(
        studentCode: ' 241077 ',
        fullName: ' Nguyễn Văn A ',
        email: ' a@st.phenikaa-uni.edu.vn ',
        password: '123456',
      );
      expect(acc.studentCode, '241077');
      expect(acc.fullName, 'Nguyễn Văn A');
      expect(acc.email, 'a@st.phenikaa-uni.edu.vn');
      expect(acc.id, isNotNull);

      final snap = await fs.collection('users').get();
      expect(snap.size, 1);
      expect(snap.docs.first.id, acc.id);
      expect(snap.docs.first.data()['studentCode'], '241077');
      expect(AuthService.busy.value, isFalse); // cờ busy luôn được tắt
    });

    test('login để trống email hoặc mật khẩu: báo lỗi', () async {
      await expectLater(
          service.login('', '123456'), authError('Vui lòng nhập email'));
      await expectLater(service.login('a@b.com', ''),
          authError('Vui lòng nhập mật khẩu'));
    });

    test('login email sai định dạng: báo lỗi', () async {
      await expectLater(
          service.login('abc', '123456'), authError('Email không đúng định dạng'));
    });

    test('chưa đăng nhập: currentUid null, getProfile báo lỗi', () async {
      expect(service.currentUid, isNull);
      await expectLater(service.getProfile(), authError('Bạn chưa đăng nhập'));
    });

    test('updateProfile với họ tên rỗng: báo lỗi', () async {
      await expectLater(
          service.updateProfile('  '), authError('Vui lòng nhập họ tên'));
    });

    test('changePassword khi chưa đăng nhập: báo lỗi', () async {
      await expectLater(service.changePassword('cu', 'moi123'),
          authError('Bạn chưa đăng nhập'));
    });
  });
}
