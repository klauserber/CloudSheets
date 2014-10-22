library fsService;

import 'dart:html';

const int FS_SIZE = 1024 * 1024 * 5;



class FsService {
  FileSystem _fsys;
  Function _readyFunc;
  DirectoryEntry _allSongsDir;
  DirectoryEntry _setsDir;
  
  FsService(Function ready) {
    print("init FsService.");
    _readyFunc = ready;
    window.navigator.persistentStorage.requestQuota(FS_SIZE, quotaCallback, fileErrorHandler);
    
  }
  
  void fileErrorHandler(FileError e) {
    window.alert(e.name + ", " + e.message);
    print(e.name + ", " + e.message);
  }
  
  void quotaCallback(int size) {
    print("Quota: $size");
    window.requestFileSystem(size, persistent: true)
      .then(onRequestFileSystem, onError: fileErrorHandler);
    
  }
  
  void onRequestFileSystem(FileSystem fs) {
    _fsys = fs;
    _fsys.root.createDirectory("cloudsheets").then(
      (DirectoryEntry dir) {
         dir.createDirectory("songs")
          .then((songsdir) {
            _allSongsDir = songsdir;
            print("songs dir: " + songsdir.toUrl());
            dir.createDirectory("sets")
             .then((setsdir) {
               _setsDir = setsdir;
               print("sets dir: " + setsdir.toUrl());
               _readyFunc();
             });
          });
      },
      onError: fileErrorHandler
    );
  }
  
  void uploadFiles(List<File> files, Function ready) {
    
    int counter = 0;
    for(File file in files) {
      _allSongsDir.createFile(file.name).then((FileEntry entry) {
        entry.createWriter().then((FileWriter writer) {
          writer.onWriteEnd.listen((ProgressEvent ev) {
            counter++;
            if(counter == files.length) {
              ready();            
            }
          });
          writer.write(file);
        }, onError: fileErrorHandler);
      }, onError: fileErrorHandler);
    }
    
  } 
  
  void saveSongAsText(String name, String data, Function ready(FileEntry entry)) {
    print(data);
    _allSongsDir.getFile(name).then((FileEntry entry) {
      deleteFile(entry, (e) {
        saveFileAsText(_allSongsDir, name, data, (entry) {
          ready(entry);
        });        
      });
    }, onError: (e) {
      saveFileAsText(_allSongsDir, name, data, (entry) {
        ready(entry);
      });
    });
    
  }
  
  void saveSet(String name, String data, Function ready(FileEntry entry)) {
    print(data);
    _setsDir.getFile(name).then((FileEntry entry) {
      deleteFile(entry, (e) {
        saveFileAsText(_setsDir, name, data, (entry) {
          ready(entry);
        });        
      });
    }, onError: (e) {
      saveFileAsText(_setsDir, name, data, (entry) {
        ready(entry);
      });
    });
    
  }
  
  void saveFileAsText(DirectoryEntry dir, String name, String data, Function ready(FileEntry entry)) {
    dir.createFile(name).then((FileEntry entry) {
      entry.createWriter().then((FileWriter writer) {
        writer.onWriteEnd.listen((ProgressEvent ev) {
          ready(entry);
        });
        
        Blob bl = new Blob([data], "text/plain");
        writer.write(bl);
        
      }, onError: fileErrorHandler);
    }, onError: fileErrorHandler);
  }
  
  void readAllSongs(Function ready(List<FileEntry> fileEntries)) {
    
    readDir(_allSongsDir, (List<FileEntry> fileEntries) {
      ready(fileEntries);
    });
  }
  
  void readSets(Function ready(List<FileEntry> fileEntries)) {

    readDir(_setsDir, (List<FileEntry> fileEntries) {
      ready(fileEntries);
    });
    
  }
  
  void getSongFileEntry(String name, Function ready(FileEntry entry)) {
    if(name.isNotEmpty) {
      _allSongsDir.getFile(name).then((FileEntry entry) {
        ready(entry);
      },
      onError: fileErrorHandler);
    }
    
  }
  void getSetFileEntry(String name, Function ready(FileEntry entry)) {
    _setsDir.getFile(name).then((FileEntry entry) {
      ready(entry);
    },
    onError: fileErrorHandler);
    
  }
  
  void readDir(DirectoryEntry dir, Function ready(List<FileEntry> fileEntries)) {
    List<FileEntry> entryList = [];
    
    dir.createReader().readEntries()
      .then((List<Entry> entries) {
        entries.forEach((Entry e) {
          entryList.add(e); 
        });
        ready(entryList);
    },
    onError: fileErrorHandler);
  }
  
  
  void readTextForEntry(FileEntry e, Function ready(String text)) {
    e.file().then((File file) {
      FileReader reader = new FileReader();
      reader.onLoadEnd.listen((e) {
           ready(reader.result);  
         }, onError: fileErrorHandler);
         
         reader.readAsText(file);
       },
       onError: fileErrorHandler
     );        
  }
  
  void deleteFile(FileEntry e, Function ready(e)) {
    e.remove().then((e) {
      ready(e);
    });  
  }
  
  
}