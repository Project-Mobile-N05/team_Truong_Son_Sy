abstract class BaseEntity {
  const BaseEntity();

  Map<String, Object> toMap();
}

abstract class BaseManager<T extends BaseEntity> {
  T _data;

  BaseManager(T initialData) : _data = initialData;

  T get data => _data;

  void setData(T newData) {
    _data = newData;
  }

  Type get dataType => T;

  String get className => runtimeType.toString();

  bool isDataOfType<R extends Object>() => _data is R;

  String describe() {
    return _data.toMap().entries.map((e) => '${e.key}: ${e.value}').join(', ');
  }

  String getInfo() => '[$className<$dataType>] ${describe()}';

  static String typeNameOf(Object obj) => obj.runtimeType.toString();

  @override
  String toString() => getInfo();
}