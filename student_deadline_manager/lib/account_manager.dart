import 'base_manager.dart';

/// Dữ liệu tài khoản (kế thừa BaseEntity).
class AccountData extends BaseEntity {
  final String username;
  final String email;
  final String role;

  const AccountData({
    required this.username,
    required this.email,
    required this.role,
  });

  @override
  Map<String, Object> toMap() => {
        'username': username,
        'email': email,
        'role': role,
      };
}

/// CÂU 2: AccountManager extends BaseManager<AccountData>
class AccountManager extends BaseManager<AccountData> {
  AccountManager()
      : super(const AccountData(
          username: "sinhvien_phenikaa",
          email: "241077xx@st.phenikaa-uni.edu.vn",
          role: "Sinh viên",
        ));

  String get username => data.username;
  String get email => data.email;
  String get role => data.role;

  void setAccountInfo(String username, String email, String role) {
    setData(AccountData(username: username, email: email, role: role));
  }

  @override
  String describe() => "Tài khoản: $username ($email) - $role";

  String getAccountInfo() => describe();
}