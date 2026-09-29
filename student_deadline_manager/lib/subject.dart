class MonHoc {
  final String maMonHoc;
  final String tenMonHoc;
  final String giangVien;
  final int soTinChi;

  const MonHoc({
    required this.maMonHoc,
    required this.tenMonHoc,
    required this.giangVien,
    required this.soTinChi,
  });

  String getThongTinMonHoc() {
    return 'Môn $tenMonHoc ($maMonHoc) do giảng viên $giangVien giảng dạy, tổng $soTinChi tín chỉ.';
  }
}
