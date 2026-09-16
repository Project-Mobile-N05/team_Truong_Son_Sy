class AccountManager {
  String username = "sinhvien_phenikaa";
  String email = "241077xx@st.phenikaa-uni.edu.vn";
  String role = "Sinh viên";


  void setAccountInfo(String username, String email, String role) {
    this.username = username;
    this.email = email;
    this.role = role;
  }


  String getAccountInfo() {
    return "Tài khoản: $username ($email) - $role";
  }
}