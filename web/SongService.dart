library songService;

import 'dart:html';
import 'FsService.dart';

class Song {
  String _text;
  
  FileEntry _entry;
  FsService _fsService;
  
  Song(FsService fsService, FileEntry entry) {
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

class SongService {
  
  FsService _fsService;
  Song activeSong;
  
  SongService(FsService fsService) {
    this._fsService = fsService;
  }
  
  void getAllSongs(Function ready(List<Song> songs)) {
    _fsService.readAllSongs((List<FileEntry> entries) {
      List<Song> result = [];
      entries.forEach((FileEntry e) {
        Song s = new Song(_fsService, e);
        result.add(s);
      });
      result.sort((Song s1, Song s2) {
        return s1.title.compareTo(s2.title);
      });
      ready(result);
    });
  }
  
  
}