import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_deadline_manager/models/account_data.dart';

void main() {
  final created = DateTime(2026, 10, 1, 8);

  AccountData sample({String? avatarUrl}) => AccountData(
        id: 'u1',
        studentCode: '241077',
        fullName: 'Nguyễn Văn A',
        email: 'a@st.phenikaa-uni.edu.vn',
        avatarUrl: avatarUrl,
        createdAt: created,
        updatedAt: created,
      );

  group('AccountData.toMap (Object -> Document)', () {
    test('có đủ các trường và đổi ngày sang Timestamp', () {
      final m = sample().toMap();
      expect(m['studentCode'], '241077');
      expect(m['fullName'], 'Nguyễn Văn A');
      expect(m['email'], 'a@st.phenikaa-uni.edu.vn');
      expect(m['createdAt'], Timestamp.fromDate(created));
      expect(m['updatedAt'], Timestamp.fromDate(created));
    });

    test('không ghi id vào nội dung Document', () {
      expect(sample().toMap().containsKey('id'), isFalse);
    });

    test('không có avatarUrl khi chưa đặt, có khi đã đặt', () {
      expect(sample().toMap().containsKey('avatarUrl'), isFalse);
      expect(sample(avatarUrl: 'http://x/a.png').toMap()['avatarUrl'],
          'http://x/a.png');
    });
  });

  group('AccountData.fromMap (Document -> Object)', () {
    test('đọc đúng id và các trường', () {
      final a = AccountData.fromMap('u1', {
        'studentCode': '241077',
        'fullName': 'Nguyễn Văn A',
        'email': 'a@st.phenikaa-uni.edu.vn',
        'createdAt': Timestamp.fromDate(created),
        'updatedAt': Timestamp.fromDate(created),
      });
      expect(a.id, 'u1');
      expect(a.studentCode, '241077');
      expect(a.fullName, 'Nguyễn Văn A');
      expect(a.email, 'a@st.phenikaa-uni.edu.vn');
      expect(a.createdAt, created);
    });

    test('thiếu trường thì dùng giá trị mặc định, không báo lỗi', () {
      final a = AccountData.fromMap('u2', {});
      expect(a.id, 'u2');
      expect(a.studentCode, '');
      expect(a.fullName, '');
      expect(a.email, '');
      expect(a.avatarUrl, isNull);
    });

    test('toMap rồi fromMap giữ nguyên dữ liệu', () {
      final back = AccountData.fromMap('u1', sample().toMap());
      expect(back.studentCode, '241077');
      expect(back.fullName, 'Nguyễn Văn A');
      expect(back.email, 'a@st.phenikaa-uni.edu.vn');
      expect(back.createdAt, created);
    });
  });

  group('AccountData.copyWith', () {
    test('đổi họ tên, giữ mã sinh viên, email, ngày tạo và cập nhật updatedAt',
        () {
      final c = sample().copyWith(fullName: 'Trần Thị B');
      expect(c.fullName, 'Trần Thị B');
      expect(c.studentCode, '241077');
      expect(c.email, 'a@st.phenikaa-uni.edu.vn');
      expect(c.id, 'u1');
      expect(c.createdAt, created);
      expect(c.updatedAt.isAfter(created), isTrue);
    });
  });
}
