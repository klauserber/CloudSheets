library uiService;

import 'dart:html';
import 'package:bootjack/bootjack.dart';
import 'package:dquery/dquery.dart';
import 'SongService.dart';
import 'FsService.dart';

class UiService {
  
  SongService _songService;
  FsService _fsService;
  
  ButtonElement _sidebarToggle;
  DivElement _sidebarContainer;
  DivElement _mainContent;
  InputElement _filesInput;
  
  ButtonElement _songEditButton;
  ButtonElement _songNewButton;
  ButtonElement _songDeleteConfirmButton;
  ButtonElement _songDeleteButton;
  ButtonElement _songSaveButton;
  ButtonElement _songCancelButton;
  
  HeadingElement _songTitle;
  InputElement _songTitleInput;
  PreElement _songBodyText;
  TextAreaElement _songBodyInput;
  //TextAreaElement _songBodyText;
  
  bool _sidebarVisible = true;
  
  UiService(FsService fsService, SongService songService) {
    _fsService = fsService;
    _songService = songService;
    
  }
  
  void initApp() {
    Transition.use();
    Collapse.use();
    Modal.use();
    
    Tab.use();
    
    _sidebarContainer = $("#sidebarContainer")[0];
    _sidebarToggle = $("#sidebarToggle")[0];
    _mainContent = $("#mainContent")[0];
    _filesInput = $("#filesInput")[0];
    
    _songEditButton = $("#songEditButton")[0];
    _songNewButton = $("#songNewButton")[0];
    _songDeleteConfirmButton = $("#songDeleteConfirmButton")[0];
    _songDeleteButton = $("#songDeleteButton")[0];
    _songSaveButton = $("#songSaveButton")[0];
    _songCancelButton = $("#songCancelButton")[0];
    
    _songTitle = $("#songTitle")[0];
    _songTitleInput = $("#songTitleInput")[0];
    _songBodyInput = $("#songBodyInput")[0];
    _songBodyText = $("#songBodyText")[0];
    
    _songSaveButton.disabled = true;
    _songCancelButton.disabled = true;
    
    _songBodyInput.style.display = "none";
    //_songBodyInput.onKeyUp.listen((e) => bodyInputAutoGrow());
    _songTitleInput.style.display = "none";
    
    _sidebarToggle.onClick.listen((e) => toggleSidebar());
    
    _songNewButton.onClick.listen((e) => newSong());
    _songEditButton.onClick.listen((e) => editSong());
    _songDeleteConfirmButton.onClick.listen((e) => deleteSong());
    _songCancelButton.onClick.listen((e) => cancelSong());
    _songSaveButton.onClick.listen((e) => saveSong());
    
    
    
    $("#importButton").click((QueryEvent ev) {
      _filesInput.style.display = "inline";
      $("#alertUploadSuccess").hide();
    });
    
    _filesInput.onChange.listen((e) => _fsService.uploadFiles(_filesInput.files, () {
      print("files uploaded");
      _filesInput.style.display = "none";
      $("#alertUploadSuccess").show();
      refreshAllSongsList();
    }));  
    
    
    
    refreshAllSongsList();
    resetUi();
  }
  
  void bodyInputAutoGrow() {
    TextAreaElement el = _songBodyInput;
    
    if (el.scrollHeight > el.clientHeight) {
      el.style.height = "${el.scrollHeight}px";
    }  
  }

  void toggleSidebar() {
    sidebarVisible = !sidebarVisible;
  }
  
  void set sidebarVisible(bool val) {
    _sidebarVisible = val;
    _sidebarContainer.style.display = _sidebarVisible ? "block" : "none";
    _mainContent.style.width = _sidebarVisible ? "50%" : "100%";
  }
  
  bool get sidebarVisible {
    return _sidebarVisible;
  }
  
  void refreshAllSongsList() {
    UListElement allSongsList = $("#allSongsList")[0];
    allSongsList.children.clear();
    _songService.getAllSongs((List<Song> songs) {
      songs.forEach((Song s) {
        LIElement elem = new LIElement();
        elem.classes.add("list-group-item");
        elem.text = s.title; 
        elem.onClick.listen((MouseEvent ev) {
          loadSong(s);
          _songService.activeSong = s;
          sidebarVisible = false;
        });
        allSongsList.children.add(elem);
      });
    });
  }
  
  void loadSong(Song s) {
    _songTitle.text = s.title;
    s.readText((String text) {
      _songBodyText.text = text;
      _songEditButton.disabled = false;
      _songDeleteButton.disabled = false;
    });
  }
  
  void editSong() {
    Song s = _songService.activeSong;
    
    _songTitleInput.value = s.title;
    s.readText((String text) {
      _songBodyInput.value = text;  
    });

    _songTitle.style.display = "none";
    _songBodyText.style.display = "none";
    _songTitleInput.style.display = "block";
    _songBodyInput.style.display = "block";
    
    _sidebarToggle.disabled = true;
    _songEditButton.disabled = true;
    _songNewButton.disabled = true;
    
    _songCancelButton.disabled = false;
    _songSaveButton.disabled = false;
    
    
  }
  
  void resetUi() {
    _songTitle.style.display = "block";
    _songBodyText.style.display = "block";
    _songTitleInput.style.display = "none";
    _songBodyInput.style.display = "none";
   
    _sidebarToggle.disabled = false;
    
    _songNewButton.disabled = false;
    _songEditButton.disabled = true;
    _songDeleteButton.disabled = true;
    
    _songCancelButton.disabled = true;
    _songSaveButton.disabled = true;
    
    _songTitle.text = "";
    _songBodyText.text = "";
    
    _songService.activeSong = null;
    
    sidebarVisible = true;
  }
  
  void newSong() {
    _songTitle.style.display = "none";
    _songBodyText.style.display = "none";
    _songTitleInput.style.display = "block";
    _songBodyInput.style.display = "block";
    
    _sidebarToggle.disabled = true;
    _songEditButton.disabled = true;
    _songNewButton.disabled = true;
    
    _songCancelButton.disabled = false;
    _songSaveButton.disabled = false;
    
    sidebarVisible = false;
    _songTitleInput.value = "";
    _songBodyInput.value = "";
    
  }
  
  void deleteSong() {
    Song s = _songService.activeSong;
    
    s.delete(() {
      refreshAllSongsList();
    });
    
    resetUi();
  }
  
  void cancelSong() {
    _songTitle.style.display = "block";
    _songBodyText.style.display = "block";
    _songTitleInput.style.display = "none";
    _songBodyInput.style.display = "none";
   
    _sidebarToggle.disabled = false;
    _songEditButton.disabled = false;
    _songNewButton.disabled = false;
    
    _songCancelButton.disabled = true;
    _songSaveButton.disabled = true;
    
    loadSong(_songService.activeSong);
  }
  
  void saveSong() {
    Song s = _songService.activeSong;
    List<String> data = [];
       
    _fsService.saveSongAsText(_songTitleInput.value, _songBodyInput.value, (FileEntry entry) {
      Song s = new Song(_fsService, entry);
      _songService.activeSong = s;
      _songTitle.text = _songTitleInput.value;
      _songBodyText.text = _songBodyInput.value;
      
      refreshAllSongsList();
      
      _songTitle.style.display = "block";
      _songBodyText.style.display = "block";
      _songTitleInput.style.display = "none";
      _songBodyInput.style.display = "none";
     
      _sidebarToggle.disabled = false;
      _songEditButton.disabled = false;
      _songNewButton.disabled = false;
      
      _songCancelButton.disabled = true;
      _songSaveButton.disabled = true;
    
      
    });
    
  }
  
}
