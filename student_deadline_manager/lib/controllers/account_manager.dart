import '../models/account_data.dart';
import 'base_manager.dart';

class AccountManager extends BaseManager<AccountData> {
  AccountManager([AccountData? initial])
      : super(initial ??
            AccountData(studentCode: '', fullName: 'Khách', email: ''));

  String get studentCode => data.studentCode;
  String get fullName => data.fullName;
  String get email => data.email;

  void setAccountInfo(String studentCode, String fullName, String email) {
    setData(AccountData(
      id: data.id,
      studentCode: studentCode,
      fullName: fullName,
      email: email,
      avatarUrl: data.avatarUrl,
      createdAt: data.createdAt,
    ));
  }

  @override
  String describe() => "Tài khoản: $fullName ($email) - MSSV $studentCode";

  String getAccountInfo() => describe();
}
