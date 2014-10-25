library csBase;

import 'dart:html';
import 'FsService.dart';

class StoreEntity {
  
  FileEntry _entry;
  FsService _fsService;
  String key;
  
  StoreEntity(FsService fsService, FileEntry entry, String key) {
    _entry = entry;
    _fsService = fsService;
    this.key = key;
  }
  
  String get title {
    int pos = key.lastIndexOf(".");
    String title = pos > -1 ? key.substring(0, pos) : key;
    if(_entry == null) title += " (NF)";
    return title;
  }
      
  void readText(Function ready(String text)) {
    if(_entry != null) {
      _fsService.readTextForEntry(_entry, (String text) {
        ready(text);
      });
    }
    else {
      ready("NOT FOUND");
    }
  }
  void readMeta(Function ready(int size, DateTime modTime)) {
    if(_entry != null) {
      _entry.getMetadata().then((Metadata meta) {
        ready(meta.size, meta.modificationTime);
      });
    }
    else {
      throw new StateError("Entry not set");
    }
  }
  
  void delete(Function ready()) {
    if(_entry != null) {
      _fsService.deleteFile(_entry, (e) {
        ready();
      });
    }
    else {
      ready();
    }
  }
  
  FsService get fsService {
   return _fsService; 
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
