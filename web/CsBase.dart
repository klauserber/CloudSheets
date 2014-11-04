library csBase;

import 'dart:html';
import 'dart:async';
import 'FsService.dart';

class StoreEntity {
  
  FileEntry _entry;
  FsService _fsService;
  String key;
  Function _baseDir; 
  StoreEntityMetaData _meta;
  
  StoreEntity(FsService fsService, FileEntry entry, String key) {
    _entry = entry;
    _fsService = fsService;
    this.key = key;
  }
  
  DirectoryEntry getBaseDir() {
    return _baseDir();
  }
  
  set baseDir(Function getBase) {
    _baseDir = getBase;
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
  
  Future<StoreEntityMetaData> readMeta() {
    Completer cp = new Completer();
    
    if(_entry != null) {
      _entry.getMetadata().then((Metadata metadata) {
        _meta = new StoreEntityMetaData(metadata.size, metadata.modificationTime);
        cp.complete(_meta);
      });
    }
    else {
      cp.completeError(new StateError("Entry not set"));
    }
    
    return cp.future;
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
  
  void storeIfNewer(String text, int time, Function ready()) {
    getBaseDir().getFile(key).then((FileEntry entry) {
      _entry = entry;
      readMeta().then((meta) {
        if(time > meta.modTime.millisecondsSinceEpoch) {
          fsService.saveFile(getBaseDir(), key, text, (FileEntry newEntry) {
            _entry = newEntry;
            print(key + ": overriden");
            ready();
          });
        } else {
          print(key + ": skipped");
          ready();
        }
      });
    },
    onError: (e) {
      fsService.saveFile(getBaseDir(), key, text, (FileEntry newEntry) {
        _entry = newEntry;
        print(key + ": new");
        ready();
      });      
    });

  }
  
  
  
  void store(String text, Function ready()) {
    getBaseDir().getFile(key).then((FileEntry entry) {
      _entry = entry;
      fsService.saveFile(getBaseDir(), key, text, (FileEntry newEntry) {
        _entry = newEntry;
        print(key + ": overriden");
        ready();
      });
    }, onError: (e) {
      fsService.saveFile(getBaseDir(), key, text, (FileEntry newEntry) {
        _entry = newEntry;
        print(key + ": new");
        ready();
      });      
    });
  }
  
  FsService get fsService {
   return _fsService; 
  }
  
  StoreEntityMetaData get meta {
    if(_meta != null) {
      return _meta;
    }
    else {
      throw new StateError("call readMeta first");
    }
  }
  
}

class StoreEntityMetaData {
  int size;
  DateTime modTime;
  
  StoreEntityMetaData(int size, DateTime modTime) {
    this.size = size;
    this.modTime = modTime;
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
