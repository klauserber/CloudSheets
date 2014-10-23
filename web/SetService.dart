library setService;

import 'dart:html';
import 'CsBase.dart';
import 'FsService.dart';
import 'SongService.dart';


class SongSet extends FileEntity {
  
  List<Song> _songs = [];
  int songPos = -1;
  
  SongSet(FsService fsService, FileEntry entry) : super(fsService, entry);
  
  void readSongs(Function forEachSong(Song song)) {
    readText((String text) {
      _songs.clear();
      int i = 0;
      text.split("\n").forEach((String line) {
        fsService.getSongFileEntry(line, (FileEntry entry) {
          Song s = new Song(fsService, entry);
          s.pos = i++;
          _songs.add(s);
          forEachSong(s);
        });
      });
      songPos = -1;
    });
  }
  
  List<Song> get songs {
    return _songs;
  }
  
  bool hasSongs() {
    return _songs.length > 0;
  }
  
  bool hasNext() {
    return hasSongs() && songPos < _songs.length - 1;
  }
  
  bool hasPrev() {
    return hasSongs() && songPos > 0;
  }

}

class SetService {
  
  FsService _fsService;
  SongSet activeSet;
  
  SetService(FsService fsService) {
    this._fsService = fsService;
  }
  
  void getAllSets(Function ready(List<SongSet> sets)) {
    _fsService.readSets((List<FileEntry> entries) {
      List<SongSet> result = [];
      entries.forEach((FileEntry e) {
        SongSet s = new SongSet(_fsService, e);
        result.add(s);
      });
      result.sort((SongSet s1, SongSet s2) {
        return s1.title.compareTo(s2.title);
      });
      ready(result);
    });
  }
  
  
  
}