library csExporter;

import 'dart:html';
import 'SongService.dart';
import 'SetService.dart';
import 'FsService.dart';
import 'CsBase.dart';
import 'package:archive/archive.dart';

class CsTransfer {
  
  SongService _songService;
  FsService _fsService;
  SetService _setService;
  
  CsTransfer(SongService songService, FsService fsService, SetService setService) {
    _songService = songService;
    _fsService = fsService;
    _setService = setService;
  }
  
  void export(Function ready(String url)) {
    _songService.getAllSongs((List<Song> songs) {
      Archive arch = new Archive();
      int counter = songs.length;
      songs.forEach((Song song) {
        song.readMeta((int size, DateTime modTime) {
          print(modTime.toString() + ": " + modTime.millisecondsSinceEpoch.toString());
          song.readText((String text) {
            ArchiveFile file = new ArchiveFile("/cloudsheets/songs/" + song.key, size, text.codeUnits);
            file.mode = 436;
            file.ownerId = 0;
            file.groupId = 0;
            file.lastModTime = modTime.millisecondsSinceEpoch ~/ 1000;
            arch.addFile(file);
            
            if(--counter == 0) {
              exportSets(arch, () {
                //List<int> res = new ZipEncoder().encode(arch, level:Deflate.NO_COMPRESSION);
                List<int> res = new TarEncoder().encode(arch);
                _fsService.saveExportFile(res, (FileEntry entry) {
                  ready(entry.toUrl());
                });
              });
            }
          });
          
        });
      });
    });
    
    
  }
  
  void exportSets(Archive arch, Function ready()) {
    
    _setService.getAllSets((List<SongSet> ssList) {
      int counter = ssList.length;
      ssList.forEach((SongSet ss) {
        ss.readMeta((int size, DateTime modTime) {
          ss.readText((String text) {
            ArchiveFile file = new ArchiveFile("/cloudsheets/sets/" + ss.key, size, text.codeUnits);
            file.mode = 436;
            file.ownerId = 0;
            file.groupId = 0;
            file.lastModTime = modTime.millisecondsSinceEpoch ~/ 1000;
            
            
            arch.addFile(file);
            if(--counter == 0) {
              ready();
            }
          });
        });
      });
    });    
    
  }
  
  
  void importArchive(File archiveFile, Function ready()) {
    
    FileReader reader = new FileReader();
    reader.onLoadEnd.listen((ProgressEvent e) {
      List<int> data = reader.result;

      Archive arch = new TarDecoder().decodeBytes(data);
      
      int counter = arch.length;
      arch.forEach((ArchiveFile archFile) {
        List<String> path = archFile.name.split("/");
        bool isSet = path[2] == "sets";
        bool isSong = path[2] == "songs";
        String name = path[3];
        int modTime = archFile.lastModTime;
        print(name);
        
        String text = new String.fromCharCodes(archFile.content);
        
        StoreEntity ent = new StoreEntity(_fsService, null, name);
        if(isSong) {
          ent = new Song(_fsService, null, name);
        }
        else{
          ent = new SongSet(_fsService, null, name);          
        }
        
        ent.storeIfNewer(text, modTime, () {
          if(--counter == 0) ready();
        });
        
      });
      
    });
    reader.readAsArrayBuffer(archiveFile);
  }
  
}




