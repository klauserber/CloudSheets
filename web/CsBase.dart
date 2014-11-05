library csBase;


const String STORAGE_PREFIX = "cloudsheets.entities.";

abstract class StoreEntity {
  
  String key;
  int modTime;
  
  
  StoreEntity(String key) {
    this.key = key;
  }
  
  StoreEntity.fromJson(Map m) {
    key = m["key"];
    modTime = m["modTime"];
  }
  
  Map toJson() {
    Map m = {};
    m['key'] = key;
    m['modtime'] = modTime;
    return m;
  }
  
      
  String get title {
    return key;
  }  
  
  @override
  String toString() {
    return key;
  }
  
}

/**
 * Emulation of Java Enum class.
 *
 * Example:
 *
 * class Meter<int> extends Enum<int> {
 *
 *  const Meter(int val) : super (val);
 *
 *  static const Meter HIGH = const Meter(100);
 *  static const Meter MIDDLE = const Meter(50);
 *  static const Meter LOW = const Meter(10);
 * }
 *
 * and usage:
 *
 * assert (Meter.HIGH, 100);
 * assert (Meter.HIGH is Meter);
 */
abstract class Enum<T> {

  final T _value;

  const Enum(this._value);

  T get value => _value;
}
