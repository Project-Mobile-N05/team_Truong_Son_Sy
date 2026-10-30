import 'project_entity.dart';

class MonHoc extends ProjectEntity<String> {
  final String giangVien;
  final int soTinChi;
  final bool daLuuTru;

  const MonHoc({
    required String maMonHoc,
    required String tenMonHoc,
    required this.giangVien,
    required this.soTinChi,
    this.daLuuTru = false,
  }) : super(id: maMonHoc, ten: tenMonHoc);

  String get maMonHoc => id;
  String get tenMonHoc => ten;

  @override
  Map<String, Object?> toMap() => {
<<<<<<< HEAD
        'maMonHoc': maMonHoc,
        'tenMonHoc': tenMonHoc,
        'giangVien': giangVien,
        'soTinChi': soTinChi,
      };
      
=======
    'maMonHoc': maMonHoc,
    'tenMonHoc': tenMonHoc,
    'giangVien': giangVien,
    'soTinChi': soTinChi,
    'daLuuTru': daLuuTru,
  };

>>>>>>> 67a37efedb5c24d7f79cbdd7743653579c6c0aa5
  String getThongTinMonHoc() {
    return 'Môn $tenMonHoc ($maMonHoc) do giảng viên $giangVien giảng dạy, tổng $soTinChi tín chỉ.';
  }
}
