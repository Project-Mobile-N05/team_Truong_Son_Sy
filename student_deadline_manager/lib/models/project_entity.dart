abstract class ProjectEntity<TId extends Object> {
  final TId id;
  final String ten;

  const ProjectEntity({required this.id, required this.ten});


  Type get classType => runtimeType;

  Map<String, Object?> toMap();

  @override
  String toString() => '$classType(id: $id, ten: $ten)';
}

class ProjectCollection<T extends ProjectEntity<Object>> {
  final List<T> _items = <T>[];

  List<T> get items => List<T>.unmodifiable(_items);

  void add(T entity) {
    _items.add(entity);
  }

  T? findById(Object id) {
    for (final entity in _items) {
      if (entity.id == id) return entity;
    }
    return null;
  }

  bool removeById(Object id) {
    final before = _items.length;
    _items.removeWhere((entity) => entity.id == id);
    return _items.length != before;
  }
}