import 'package:flutter/material.dart';

import '../../../models/subject.dart';

const _primary = Color(0xFF5147BD);

class SubjectCard extends StatelessWidget {
  final MonHoc monHoc;
  final bool isSaving;
  final bool isLoadingDeadlines;
  final int deadlineCount;
  final Future<void> Function(MonHoc) onEdit;
  final Future<void> Function(MonHoc) onDelete;

  const SubjectCard({
    super.key,
    required this.monHoc,
    required this.isSaving,
    required this.isLoadingDeadlines,
    required this.deadlineCount,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEDF5)),
      ),
      child: Row(
          children: [
            Container(
              width: 46,
              height: 52,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEDE8FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.menu_book_outlined,
                    size: 18,
                    color: _primary,
                  ),
                  Text(
                    monHoc.maMonHoc,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: _primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    monHoc.tenMonHoc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF24263A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text(
                        'GV: ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF74778B),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          monHoc.giangVien,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF74778B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F3F7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${monHoc.soTinChi} tín chỉ',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF5E637A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (isLoadingDeadlines)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else if (deadlineCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE9E6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$deadlineCount deadline',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFE25E5A),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                _actionButton(
                  tooltip: 'Sửa môn học',
                  backgroundColor: const Color(0xFFF5F0FF),
                  onPressed: isSaving ? null : () => onEdit(monHoc),
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: _primary,
                    size: 18,
                  ),
                ),
                const SizedBox(height: 8),
                _actionButton(
                  tooltip: 'Xóa môn học',
                  backgroundColor: const Color(0xFFFDECEF),
                  onPressed: isSaving ? null : () => onDelete(monHoc),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFEA5B73),
                    size: 18,
                  ),
                ),
              ],
            ),
          ],
      ),
    );
  }

  Widget _actionButton({
    required String tooltip,
    required Color backgroundColor,
    required VoidCallback? onPressed,
    required Widget icon,
  }) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        icon: icon,
      ),
    );
  }
}
