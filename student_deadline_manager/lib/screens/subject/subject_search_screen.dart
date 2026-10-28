part of '../subject_screen.dart';

class _SubjectSearchScreen extends StatefulWidget {
  final List<MonHoc> danhSachMonHoc;
  final String tuKhoaBanDau;
  final bool? trangThaiBanDau;
  final int? tinChiBanDau;
  final String? giangVienBanDau;
  final Future<MonHoc?> Function(MonHoc) onEdit;

  const _SubjectSearchScreen({
    required this.danhSachMonHoc,
    required this.tuKhoaBanDau,
    required this.trangThaiBanDau,
    required this.tinChiBanDau,
    required this.giangVienBanDau,
    required this.onEdit,
  });

  @override
  State<_SubjectSearchScreen> createState() => _SubjectSearchScreenState();
}

class _SubjectSearchScreenState extends State<_SubjectSearchScreen> {
  late final TextEditingController _searchController;
  late List<MonHoc> _subjects;
  bool? _archived;
  int? _credits;
  String? _teacher;

  int get _activeFilterCount =>
      (_archived != null ? 1 : 0) +
      (_credits != null ? 1 : 0) +
      (_teacher != null ? 1 : 0);

  List<int> get _creditOptions =>
      _subjects.map((subject) => subject.soTinChi).toSet().toList()..sort();

  List<String> get _teacherOptions =>
      _subjects
          .map((subject) => subject.giangVien.trim())
          .where((teacher) => teacher.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

  List<MonHoc> get _results {
    final keyword = _searchController.text.trim().toLowerCase();
    return _subjects.where((subject) {
      final matchesKeyword =
          keyword.isEmpty ||
          subject.maMonHoc.toLowerCase().contains(keyword) ||
          subject.tenMonHoc.toLowerCase().contains(keyword) ||
          subject.giangVien.toLowerCase().contains(keyword);
      return matchesKeyword &&
          (_archived == null || subject.daLuuTru == _archived) &&
          (_credits == null || subject.soTinChi == _credits) &&
          (_teacher == null || subject.giangVien.trim() == _teacher);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.tuKhoaBanDau);
    _subjects = List<MonHoc>.of(widget.danhSachMonHoc);
    _archived = widget.trangThaiBanDau;
    _credits = widget.tinChiBanDau;
    _teacher = widget.giangVienBanDau;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _archived = null;
      _credits = null;
      _teacher = null;
    });
  }

  void _applyFilters() {
    Navigator.pop(
      context,
      _SubjectSearchFilters(
        query: _searchController.text,
        archived: _archived,
        credits: _credits,
        teacher: _teacher,
      ),
    );
  }

  Widget _statusOption(String label, bool? value) {
    final selected = _archived == value;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => setState(() => _archived = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 3),
          decoration: BoxDecoration(
            color: selected ? _primary : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? _primary : const Color(0xFFE5E7F0),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : const Color(0xFF686C81),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T?>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF686C81),
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T?>(
          initialValue: value,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF5F6FA),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: Color(0xFFE6E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: Color(0xFFE6E8F0)),
            ),
          ),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _searchResultCard(MonHoc subject) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9EAF2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 7,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDEBFF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        subject.maMonHoc,
                        style: const TextStyle(
                          color: _primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${subject.soTinChi} tín chỉ',
                      style: const TextStyle(
                        color: Color(0xFF777B8F),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  subject.tenMonHoc,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF282A3C),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'GV: ${subject.giangVien}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF777B8F),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              IconButton(
                tooltip: 'Sửa môn học',
                onPressed: () async {
                  final updated = await widget.onEdit(subject);
                  if (updated == null || !mounted) return;
                  setState(() {
                    final index = _subjects.indexWhere(
                      (item) => item.maMonHoc == updated.maMonHoc,
                    );
                    if (index >= 0) _subjects[index] = updated;
                  });
                },
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFEDEBFF),
                  foregroundColor: _primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.edit_outlined),
              ),
              const Text(
                'Sửa',
                style: TextStyle(color: _primary, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        leading: IconButton(
          tooltip: 'Quay lại',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: _primary),
        ),
        title: const Text(
          'Tìm kiếm & lọc môn học',
          style: TextStyle(
            color: Color(0xFF24263A),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Tên môn, mã môn hoặc giảng viên',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF85899D)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: Color(0xFFE7E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: Color(0xFFE7E8F0)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8E9F1)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tune, size: 18, color: _primary),
                    const SizedBox(width: 7),
                    const Expanded(
                      child: Text(
                        'Bộ lọc',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF303246),
                        ),
                      ),
                    ),
                    Text(
                      '$_activeFilterCount đang chọn',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF777B8F),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Trạng thái',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF686C81),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _statusOption('Tất cả', null),
                    const SizedBox(width: 5),
                    _statusOption('Đang theo dõi', false),
                    const SizedBox(width: 5),
                    _statusOption('Đã lưu trữ', true),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _dropdown<int>(
                        label: 'Số tín chỉ',
                        value: _credits,
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('Tất cả'),
                          ),
                          ..._creditOptions.map(
                            (credit) => DropdownMenuItem<int?>(
                              value: credit,
                              child: Text('$credit tín chỉ'),
                            ),
                          ),
                        ],
                        onChanged: (value) => setState(() => _credits = value),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _dropdown<String>(
                        label: 'Giảng viên',
                        value: _teacher,
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Tất cả'),
                          ),
                          ..._teacherOptions.map(
                            (teacher) => DropdownMenuItem<String?>(
                              value: teacher,
                              child: Text(
                                teacher,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) => setState(() => _teacher = value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _resetFilters,
                        style: TextButton.styleFrom(
                          foregroundColor: _primary,
                          backgroundColor: const Color(0xFFEDEBFF),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                        ),
                        child: const Text('Đặt lại'),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _applyFilters,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                        ),
                        child: const Text('Áp dụng bộ lọc'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_activeFilterCount > 0) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                if (_archived != null)
                  _filterChip(
                    _archived! ? 'Đã lưu trữ' : 'Đang theo dõi',
                    () => setState(() => _archived = null),
                  ),
                if (_credits != null)
                  _filterChip(
                    '$_credits tín chỉ',
                    () => setState(() => _credits = null),
                  ),
                if (_teacher != null)
                  _filterChip(_teacher!, () => setState(() => _teacher = null)),
              ],
            ),
          ],
          const SizedBox(height: 17),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Kết quả tìm kiếm',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF292B3E),
                  ),
                ),
              ),
              Text(
                '${results.length} môn học',
                style: const TextStyle(
                  color: _primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (results.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Text(
                'Không tìm thấy môn học phù hợp.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF777B8F)),
              ),
            )
          else
            ...results.map(_searchResultCard),
          if (results.isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 5),
              child: Text(
                'Đã hiển thị tất cả môn học phù hợp',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Color(0xFF898DA0)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, VoidCallback onRemove) {
    return Chip(
      label: Text(label, style: const TextStyle(color: _primary, fontSize: 11)),
      deleteIcon: const Icon(Icons.close, size: 15, color: _primary),
      onDeleted: onRemove,
      backgroundColor: const Color(0xFFEDEBFF),
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}
