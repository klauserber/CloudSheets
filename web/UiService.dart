library uiService;

import 'dart:html';
import 'package:bootjack/bootjack.dart';
import 'package:dquery/dquery.dart';
import 'SongService.dart';
import 'FsService.dart';

class UiService {
  
  SongService _songService;
  FsService _fsService;
  
  UiService(FsService fsService, SongService songService) {
    _fsService = fsService;
    _songService = songService;
    
  }
  
  void initApp() {
    Transition.use();
    Collapse.use();
    
    $("#sidebarToggle").click((QueryEvent ev) {
      $("#sidebarContainer").toggle();    
    });
    
    InputElement filesInput = $("#filesInput")[0];
    
    $("#importButton").click((QueryEvent ev) {
      filesInput.style.display = "inline";
      $("#alertUploadSuccess").hide();
    });
    
    filesInput.onChange.listen((e) => _fsService.uploadFiles(filesInput.files, () {
      print("files uploaded");
      filesInput.style.display = "none";
      $("#alertUploadSuccess").show();
      refreshAllSongsList();
    }));  
    
    refreshAllSongsList();
    
  }
  
  void refreshAllSongsList() {
    UListElement allSongsList = $("#allSongsList")[0];
    allSongsList.children.clear();
    _songService.getAllSongs((List<Song> songs) {
      songs.forEach((Song s) {
        LIElement elem = new LIElement();
        elem.classes.add("list-group-item");
        elem.text = s.title; 
        allSongsList.children.add(elem);
      });
    });
  }
  
}
