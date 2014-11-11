library songService;

import 'dart:html';
import 'dart:convert';
import 'CsBase.dart';


class Song extends StoreEntity {
  int pos = -1;
  String text;
  
  Song(String key) : super(key);
  
  Song.fromJson(Map m) : super.fromJson(m) {
    text = m["text"];
  }
  
  @override
  Map toJson() {
    Map m = super.toJson();
    m["text"] = text;
    return m;
  }
  
  
}

class SongService extends StoreService<Song> {
  
  Song activeSong;
    
  @override
  String get baseKey => STORAGE_SONG_BASEKEY;

  
  @override
  Song find(String key) {
    String js = window.localStorage[STORAGE_SONG_BASEKEY + "." + key];
    return js != null ? new Song.fromJson(JSON.decoder.convert(js)) : null;
  }


  @override
  Song create(String text) {
    return new Song.fromJson(JSON.decoder.convert(text));
  }
}