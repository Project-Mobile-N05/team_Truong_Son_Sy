import 'package:flutter_test/flutter_test.dart';
import 'package:student_deadline_manager/models/subject.dart';

void main() {
  test('Subject reads the simplified fields', () {
    final subject = Subject.fromMap('cs101', 'owner-1', {
      'userId': 'owner-1',
      'name': 'Lập trình',
      'color': 'blue',
      'icon': 'computer',
      'teacher': 'An',
      'credits': 3,
    });

    expect(subject.id, 'cs101');
    expect(subject.userId, 'owner-1');
    expect(subject.name, 'Lập trình');
    expect(subject.color, 'blue');
    expect(subject.icon, 'computer');
    expect(subject.teacher, 'An');
    expect(subject.credits, 3);
  });

  test('Subject remains compatible with existing Firestore documents', () {
    final subject = Subject.fromMap('old-1', 'owner-2', {
      'tenMonHoc': 'Toán rời rạc',
      'giangVien': 'Bình',
      'soTinChi': 4,
    });

    expect(subject.userId, 'owner-2');
    expect(subject.name, 'Toán rời rạc');
    expect(subject.teacher, 'Bình');
    expect(subject.credits, 4);
    expect(subject.color, 'violet');
    expect(subject.icon, 'book');
  });

  test('Subject writes the new field names', () {
    final subject = Subject(
      id: 'cs102',
      userId: 'owner-3',
      name: 'Cơ sở dữ liệu',
      color: 'teal',
      icon: 'computer',
    );

    expect(subject.toMap(), containsPair('name', 'Cơ sở dữ liệu'));
    expect(subject.toMap(), containsPair('userId', 'owner-3'));
    expect(subject.toMap(), containsPair('color', 'teal'));
    expect(subject.toMap(), containsPair('icon', 'computer'));
    expect(subject.toMap(), isNot(contains('tenMonHoc')));
  });
}
