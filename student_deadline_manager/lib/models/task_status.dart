enum TaskStatus {
  pending('Chưa làm'),
  inProgress('Đang làm'),
  completed('Hoàn thành'),
  overdue('Quá hạn');

  final String label;
  const TaskStatus(this.label);

  static TaskStatus fromName(String? name) => TaskStatus.values.firstWhere(
        (s) => s.name == name,
        orElse: () => TaskStatus.pending,
      );
}