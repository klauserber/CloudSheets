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

class SetService extends StoreService<SongSet> {
  
  SongSet activeSet;
  
  @override
  String get baseKey => STORAGE_SET_BASEKEY;
  
  @override
  SongSet find(String key) {
    String js = window.localStorage[baseKey + "." + key];
    return js != null ? new Song.fromJson(JSON.decoder.convert(js)) : null;
  }
  
  @override
  SongSet create(String text) {
    return new SongSet.fromJson(JSON.decoder.convert(text));
  }
  

}