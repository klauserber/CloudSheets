library songService;

import 'dart:html';
import 'FsService.dart';
import 'CsBase.dart';

class Song extends FileEntity {
  int pos = -1;
  
  Song(FsService fsService, FileEntry entry) : super(fsService, entry);
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
        Song s = new Song(_fsService, e);
        s.pos = i++;
        result.add(s);
      });
      result.sort((Song s1, Song s2) {
        return s1.title.compareTo(s2.title);
      });
      ready(result);
    });
  }
  
  
}