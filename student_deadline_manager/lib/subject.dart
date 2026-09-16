class MonHoc {
  String maMonHoc;
  String tenMonHoc;
  String giangVien;
  int soTinChi;

  MonHoc({
    required this.maMonHoc,
    required this.tenMonHoc,
    required this.giangVien,
    required this.soTinChi,
  });

  void capNhatMonHoc(
    String maMonHoc,
    String tenMonHoc,
    String giangVien,
    int soTinChi,
  ) {
    this.maMonHoc = maMonHoc;
    this.tenMonHoc = tenMonHoc;
    this.giangVien = giangVien;
    this.soTinChi = soTinChi;
  }

  String getThongTinMonHoc() {
    return '$maMonHoc - $tenMonHoc - $giangVien - $soTinChi tín chỉ';
  }
}