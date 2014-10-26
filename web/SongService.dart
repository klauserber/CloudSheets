library songService;

import 'dart:html';
import 'FsService.dart';
import 'CsBase.dart';

class Song extends StoreEntity {
  int pos = -1;
  
  Song(FsService fsService, FileEntry entry, String key) : super(fsService, entry, key);
  
  @override
  DirectoryEntry getBaseDir() {
    return fsService.allSongsDir;
  }
  
}

class SongService {
  
  FsService _fsService;
  Song activeSong;
  
  SongService(FsService fsService) {
    this._fsService = fsService;
  }
  
  void getAllSongs(Function ready(List<Song> songs)) {
    _fsService.readAllSongs((List<FileEntry> entries) {
      List<Song> result = [];
      int i = 0;
      entries.forEach((FileEntry e) {
        Song s = new Song(_fsService, e, e.name);
        s.pos = i++;
        result.add(s);
      });
      result.sort((Song s1, Song s2) {
        return s1.title.compareTo(s2.title);
      });
      for(int i=0; i < result.length; i++) {
        result[i].pos = i;
      }
      ready(result);
    });
  }
  
  
}