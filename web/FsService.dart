library fsService;

import 'dart:html';

const int FS_SIZE = 1024 * 1024 * 5;



class FsService {
  FileSystem fsys;
  Function readyFunc;
  DirectoryEntry allSongsDir;
  
  FsService(Function ready) {
    print("init FsService.");
    readyFunc = ready;
    window.navigator.persistentStorage.requestQuota(FS_SIZE, quotaCallback, fileErrorHandler);
    
  }
  
  void fileErrorHandler(FileError e) {
    window.alert(e.name + ", " + e.message);
  }
  
  void quotaCallback(int size) {
    print("Quota: $size");
    window.requestFileSystem(size, persistent: true)
      .then(onRequestFileSystem, onError: fileErrorHandler);
    
  }
  
  void onRequestFileSystem(FileSystem fs) {
    fsys = fs;
    fsys.root.createDirectory("cloudsheets").then(
      (DirectoryEntry dir) {
         dir.createDirectory("songs")
          .then((dir) {
            allSongsDir = dir;
            print("songs dir: " + dir.toUrl());
            readyFunc();
          });
      },
      onError: fileErrorHandler
    );
  }
  
  void uploadFiles(List<File> files, Function ready) {
    
    for(File file in files) {
      allSongsDir.createFile(file.name).then((FileEntry entry) {
        entry.createWriter().then((FileWriter writer) {
          writer.write(file);
        }, onError: fileErrorHandler);
      }, onError: fileErrorHandler);
      
      ready();   
    }
    
  }  
  
  void readAllSongs(Function ready(List<FileEntry> fileEntries)) {
    
    List<FileEntry> entryList = [];
    
    allSongsDir.createReader().readEntries()
      .then((List<Entry> entries) {
        entries.forEach((Entry e) {
          entryList.add(e); 
        });
        ready(entryList);
    },
    onError: fileErrorHandler);
  }
  
  void readTextForEntry(FileEntry e, Function ready(String text)) {
    String result = ""; 
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
  
  
}