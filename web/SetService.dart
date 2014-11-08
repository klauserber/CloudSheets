library setService;

import 'dart:html';
import 'dart:convert';
import 'CsBase.dart';
import 'SongService.dart';


class SongSet extends StoreEntity {
  
  List<Song> _songs = [];
  int songPos = -1;
  
  SongSet(String key) : super(key);
  
  SongSet.fromJson(Map m) : super.fromJson(m) {
    int counter = 0;
    m["songList"].forEach((key) {
      String js = window.localStorage[STORAGE_SONG_BASEKEY + "." + key];
      Song s;
      if(js != null) {
        s = new Song.fromJson(JSON.decoder.convert(js));
      }
      else {
        s = new Song(key + " (NF)");
      }
      s.pos = counter++;
      _songs.add(s);
    });
  }
  
  Map toJson() {
    Map m = super.toJson();
    
    List<String> slist = [];
    _songs.forEach((s) {
      slist.add(s.key);
    });
    
    m["songList"] = slist;
    
    return m;
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
  
  SongSet activeSet;
  
  SetService() {
  }
  
  List<SongSet> getAllSets() {
    List<SongSet> result = [];
    window.localStorage.keys.where((key) => key.startsWith(STORAGE_SET_BASEKEY)).forEach((key) {
      result.add(new SongSet.fromJson(JSON.decoder.convert(window.localStorage[key])));
    });
    
    result.sort((s1, s2) => s1.title.compareTo(s2.title));
    
    return result;
  }
  
  SongSet findSet(String key) {
    String js = window.localStorage[STORAGE_SET_BASEKEY + "." + key];
    return js != null ? new Song.fromJson(JSON.decoder.convert(js)) : null;
  }
  
  
  void deleteSet(String key) {
    window.localStorage.remove(STORAGE_SET_BASEKEY + "." + key);
  }
  
  void saveSet(SongSet ss) {
    ss.modTime = new DateTime.now().millisecondsSinceEpoch;
    String text = JSON.encoder.convert(ss);
    
    window.localStorage[STORAGE_SET_BASEKEY + "." + ss.key] = text;
  }
  
}