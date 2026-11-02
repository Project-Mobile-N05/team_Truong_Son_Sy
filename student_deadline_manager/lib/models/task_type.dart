enum TaskType {
  assignment('Bài tập'),
  exam('Thi'),
  project('Đồ án'),
  classSession('Buổi học'),
  other('Khác');

  final String label;
  const TaskType(this.label);

  static TaskType? fromName(String? name) {
    for (final t in TaskType.values) {
      if (t.name == name) return t;
    }
    return null;
  }
}