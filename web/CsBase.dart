library csBase;

import 'dart:convert';


const String STORAGE_PREFIX = "cloudsheets.entities.";
const String STORAGE_SET_BASEKEY = "${STORAGE_PREFIX}.set";
const String STORAGE_SONG_BASEKEY = "${STORAGE_PREFIX}.song";


String stripForJson(String text) {
  return text.replaceAll("{", "(").replaceAll("}", ")");
}


abstract class StoreEntity {
  
  String key;
  int modTime;
  int _storeState = 0;
  
  
  StoreEntity(String key) {
    this.key = key;
  }
  
  StoreEntity.fromJson(Map m) {
    key = m["key"];
    modTime = m["modTime"];
    _storeState = m["storeState"] != null ? m["storeState"] : 0;
  }
  
  
  Map toJson() {
    Map m = {};
    m["key"] = key;
    m["modTime"] = modTime;
    m["storeState"] = _storeState;
    return m;
  }
  
      
  String get title {
    return key;
  }  
  
  @override
  String toString() {
    return key;
  }
  
  bool get newEntry {
    return _storeState == 0; 
  }
  void setNewEntry() {
    _storeState = 0;
  }
  
  bool get synced {
    return _storeState == 1; 
  }
  void setSynced() {
    _storeState = 1;
  }
  
  bool get deleted {
    return _storeState == 2; 
  }
  void setDeleted() {
    _storeState = 2;
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
