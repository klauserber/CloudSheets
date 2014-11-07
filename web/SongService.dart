library songService;

import 'dart:html';
import 'dart:convert';
import 'CsBase.dart';

const String STORAGE_SONG_BASEKEY = "${STORAGE_PREFIX}.song";

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

class SongService {
  
  Song activeSong;
  
  SongService() {
  }
  
  List<Song> getAllSongs() {
    List<Song> result = [];
    window.localStorage.keys.where((key) => key.startsWith(STORAGE_SONG_BASEKEY)).forEach((key) {
      result.add(new Song.fromJson(JSON.decoder.convert(window.localStorage[key])));
    });
    
    result.sort((s1, s2) => s1.title.compareTo(s2.title));
    
    return result;
  }
  
  Song findSong(String key) {
    String js = window.localStorage[STORAGE_SONG_BASEKEY + "." + key];
    return js != null ? new Song.fromJson(JSON.decoder.convert(js)) : null;
  }
  
  
  void deleteSong(String key) {
    window.localStorage.remove(STORAGE_SONG_BASEKEY + "." + key);
  }
  
  void saveSong(Song s) {
    s.modTime = new DateTime.now().millisecondsSinceEpoch;
    String text = JSON.encoder.convert(s);
    
    window.localStorage[STORAGE_SONG_BASEKEY + "." + s.key] = text;
  }
  
}