library csBase;

import 'dart:html';
import 'FsService.dart';

class FileEntity {
  
  FileEntry _entry;
  FsService _fsService;
  
  FileEntity(FsService fsService, FileEntry entry) {
    _entry = entry;
    _fsService = fsService;
  }
  
  String get title {
    return _entry.name;
  }
  
  void readText(Function ready(String text)) {
    _fsService.readTextForEntry(_entry, (String text) {
      ready(text);
    });
  }
  
  void delete(Function ready()) {
    _fsService.deleteFile(_entry, (e) {
      ready();
    });
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