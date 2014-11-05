library csExporter;

import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'SongService.dart';
import 'SetService.dart';
import 'CsBase.dart';
import 'package:archive/archive.dart';

class CsTransfer {
  
  SongService _songService;
  SetService _setService;
  
  CsTransfer(SongService songService, SetService setService) {
    _songService = songService;
    _setService = setService;
  }
  
  String export() {
    Archive arch = new Archive();
  
    exportSets(arch);
    exportSongs(arch);

    return buildArchive(arch);
  }

  void exportSongs(Archive arch) {
    List<Song> songs = _songService.getAllSongs();
    songs.forEach((Song song) {
      String text = JSON.encoder.convert(song);
      ArchiveFile file = new ArchiveFile("/cloudsheets/songs/" + song.key, text.length, text.codeUnits);
      file.mode = 436;
      file.ownerId = 0;
      file.groupId = 0;
      file.lastModTime = song.modTime ~/ 1000;
      arch.addFile(file);
    });
  }

  String buildArchive(Archive arch) {
    //List<int> res = new ZipEncoder().encode(arch, level:Deflate.NO_COMPRESSION);
    List<int> res = new TarEncoder().encode(arch);
    Blob bl = new Blob([new String.fromCharCodes(res)], "octet/stream");
    return Url.createObjectUrlFromBlob(bl);
  }
  
  void exportSets(Archive arch) {
    
    List<SongSet> ssList = _setService.getAllSets();
    int counter = ssList.length;
    if(counter == 0) {
      return;
    }
    ssList.forEach((SongSet ss) {
      String text = JSON.encoder.convert(ss);
      
      ArchiveFile file = new ArchiveFile("/cloudsheets/sets/" + ss.key, text.length, text.codeUnits);
      file.mode = 436;
      file.ownerId = 0;
      file.groupId = 0;
      file.lastModTime = ss.modTime ~/ 1000;
      
      arch.addFile(file);
    });
    
  }
  
  
  Future importArchive(File archiveFile) {
    Completer cp = new Completer();
    
    window.localStorage.clear();
    
    FileReader reader = new FileReader();
    reader.onLoadEnd.listen((ProgressEvent e) {
      List<int> data = (reader.result as String).codeUnits;

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

        String key = _stripExtention(name);        
        
        String storageKey = (isSong ? STORAGE_SONG_BASEKEY : STORAGE_SET_BASEKEY) + "." + key;
        
        window.localStorage[storageKey] = text;
      });
      cp.complete();
      
    });
    reader.readAsText(archiveFile);
    
    return cp.future;
  }
  
  String _stripExtention(String name) {
    int pos = name.lastIndexOf(".");
    return pos > -1 ? name.substring(0, pos) : name;        
  }
  
  Future uploadFiles(Iterable<File> files) {
    
    Completer cp = new Completer();

    int counter = files.length;
    
    for(File file in files) {
      FileReader reader = new FileReader();
      reader.onLoadEnd.listen((ProgressEvent e) {
        String data = reader.result;
        bool isJson = data.startsWith("{");
        
        String key = _stripExtention(file.name);
        String text;
        if(isJson) {
          text = data;
        }
        else {
          Song s;
          s = new Song(key);
          s.text = data;
          s.modTime = file.lastModified;
          
          text = JSON.encoder.convert(s);
        }
        window.localStorage[STORAGE_SONG_BASEKEY + "." + key] = text;
        
        if(--counter == 0) cp.complete();
      });
      reader.readAsText(file);
    }
        
    return cp.future;
  } 
  
  
}





