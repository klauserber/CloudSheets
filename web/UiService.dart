library uiService;

import 'dart:html';
import 'package:bootjack/bootjack.dart';
import 'package:dquery/dquery.dart';
import 'CsBase.dart';
import 'SongService.dart';
import 'SetService.dart';
import 'FsService.dart';

class OperatingMode extends Enum<int>  {
  const OperatingMode(int value) : super(value);
  
  static const OperatingMode SONG = const OperatingMode(0);
  static const OperatingMode SET = const OperatingMode(1);
  
}

class UiService {
  
  SongService _songService;
  SetService _setService;
  FsService _fsService;
 
  OperatingMode _mode;
  bool _songEditMode = false;
  
  ButtonElement _sidebarToggle;
  DivElement _sidebarContainer;
  DivElement _mainContent;
  InputElement _filesInput;
  
  
  // Song elements 
  CssStyleSheet _songStyles;
  
  UListElement _allSongsList;
  DivElement _allSongsContainer;
  
  DivElement _songView; 

  DivElement _songToolBar; 

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
  
  // Set elements
  CssStyleSheet _setStyles;
  
  UListElement _allSetsList;
  DivElement _allSetsContainer;

  DivElement _setView; 
  
  ButtonElement _setNewButton;

  DivElement _setToolBar; 
  ButtonElement _setDeleteConfirmButton;
  ButtonElement _setDeleteButton;
  ButtonElement _setSaveButton;
  ButtonElement _setCancelButton;
  ButtonElement _setBackButton;
  ButtonElement _setEditButton;
  
  InputElement _setTitleInput;
  UListElement _setContentList;
  DivElement _setContentContainer;
  HeadingElement _setTitleText;  
  UListElement _setList;
  
  
  bool _sidebarVisible = true;
  
  UiService(FsService fsService, SongService songService, SetService setService) {
    _fsService = fsService;
    _songService = songService;
    _setService = setService;
  }
  
  void initApp() {
    Transition.use();
    Collapse.use();
    Modal.use();
    
    Tab.use();
    
    window.onResize.listen((Event e) => setSizes());
    
    _mode = OperatingMode.SONG;

    
    _sidebarContainer = $("#sidebarContainer")[0];
    _sidebarToggle = $("#sidebarToggle")[0];
    _mainContent = $("#mainContent")[0];
    _filesInput = $("#filesInput")[0];
    
    
    // Song elements init
    _allSongsList = $("#allSongsList")[0];
    _allSongsContainer = $("#allSongsContainer")[0];
    
    _songView = $("#songView")[0];
    
    _songToolBar = $("#songToolBar")[0];

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
    _songTitleInput.style.display = "none";
    
    _sidebarToggle.onClick.listen((e) => toggleSidebar());
    
    _songNewButton.onClick.listen((e) => newSong());
    _songEditButton.onClick.listen((e) => editSong());
    _songDeleteConfirmButton.onClick.listen((e) => deleteSong());
    _songCancelButton.onClick.listen((e) => cancelSong());
    _songSaveButton.onClick.listen((e) => saveSong());
    
    StyleElement songStyleElem = new StyleElement();
    document.head.append(songStyleElem);
    _songStyles = songStyleElem.sheet;
    _songStyles.insertRule(".addicon { display: none }", 0);
    
    // Set elements init
    _allSetsList = $("#allSetsList")[0];
    _allSetsContainer = $("#allSongsContainer")[0];

    _setView = $("#setView")[0];
    
    _setNewButton = $("#setNewButton")[0];
    

    _setToolBar = $("#setToolBar")[0];
    _setDeleteConfirmButton = $("#setDeleteConfirmButton")[0];
    _setDeleteButton = $("#setDeleteButton")[0];
    _setSaveButton = $("#setSaveButton")[0];
    _setCancelButton = $("#setCancelButton")[0];
    _setBackButton = $("#setBackButton")[0];
    _setEditButton = $("#setEditButton")[0];

    _setBackButton.onClick.listen((e) => backSet());
    _setEditButton.onClick.listen((e) => editSet());
    _setNewButton.onClick.listen((e) => newSet());
    _setCancelButton.onClick.listen((e) => cancelSet());
    _setSaveButton.onClick.listen((e) => saveSet());
    
    _setTitleInput = $("#setTitleInput")[0];
    _setTitleText = $("#setTitleText")[0];
    _setContentList = $("#setContentList")[0];
    _setContentContainer = $("#setContentContainer")[0];

    
    StyleElement setStyleElem = new StyleElement();
    document.head.append(setStyleElem);
    _setStyles = setStyleElem.sheet;
    _setStyles.insertRule(".addicon { display: inline }", 0);
        
    
    
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
    
    refreshAllSetsList();
    
    
    resetUi();
    
    setSizes();
  }
  
  editSet() {
  }
  
  backSet() {
  }
  
  
  void setSizes() {
    
    int h = window.innerHeight;
    _setContentContainer.style.height = "${h - 130}px";
    _allSongsContainer.style.height = "${h - 140}px";
    _allSetsList.style.height = "${h - 215}px";
    _songBodyText.style.height = "${h - 130}px";
    _songBodyInput.style.height = "${h - 130}px";
    
  }

  
  void switchToSongMode() {
    _mode = OperatingMode.SONG;
    updateUiState();    
  }
  
  void switchToSetMode() {
    _mode = OperatingMode.SET;
    updateUiState();
   }
  
  void toggleSidebar() {
    sidebarVisible = !sidebarVisible;
  }
  
  void set sidebarVisible(bool val) {
    if(val) window.scrollTo(0, 0);
    _sidebarVisible = val;
    _sidebarContainer.style.display = _sidebarVisible ? "block" : "none";
    _mainContent.style.width = _sidebarVisible ? "50%" : "100%";
  }
  
  bool get sidebarVisible {
    return _sidebarVisible;
  }
  
  /* ------------ */
  /* Song methods */  
  /* ------------ */
  
  void refreshAllSongsList() {
    UListElement allSongsList = $("#allSongsList")[0];
    allSongsList.children.clear();
    _songService.getAllSongs((List<Song> songs) {
      songs.forEach((Song s) {
        LIElement elem = createSongElement(s);
        allSongsList.children.add(elem);
      });
    });
  }

  LIElement createSongElement(Song s) {
    LIElement elem = new LIElement();
    elem.classes.add("list-group-item");
    
    SpanElement textSpan = new SpanElement();
    textSpan.text = s.title;
    elem.children.add(textSpan);
    
    SpanElement addSpan = new SpanElement();
    addSpan.classes.add("toright");
    addSpan.classes.add("addicon");
    addSpan.classes.add("glyphicon");
    addSpan.classes.add("glyphicon-arrow-right");
    elem.children.add(addSpan);
    
    
    elem.onClick.listen((MouseEvent ev) {
      switch (_mode) {
        case OperatingMode.SONG:
          loadSong(s);
          break;
        case OperatingMode.SET:
          addSongToSetList(s);
          break;
      }
    });
    return elem;
  }
  
  
  void loadSong(Song s) {
    _songTitle.text = s.title;
    s.readText((String text) {
      _songBodyText.text = text;
      _songService.activeSong = s;
      sidebarVisible = false;
      updateUiState();
      window.scrollTo(0, 0);
    });
  }
  
 void editSong() {
    Song s = _songService.activeSong;
    
    _songTitleInput.value = s.title;
    s.readText((String text) {
      _songBodyInput.value = text;  
      _songEditMode = true;
      updateUiState();    
      sidebarVisible = false;
    });

    
  }
  
  void resetUi() {
    _songTitle.text = "";
    _songBodyText.text = "";
    
    _songService.activeSong = null;
    _setService.activeSet = null;
    
    sidebarVisible = true;
    
    _songEditMode = false;
    
    switchToSongMode();    
  }
  
  void updateUiState() {
    _sidebarToggle.disabled = _songEditMode || _mode == OperatingMode.SET;
    
    setVisible(_songToolBar, _mode == OperatingMode.SONG);
    setVisible(_setToolBar, _mode == OperatingMode.SET);
    
    _songNewButton.disabled = _songEditMode;
    _songSaveButton.disabled = !_songEditMode;
    _songCancelButton.disabled = !_songEditMode;
    _songEditButton.disabled = _songEditMode;
    
    setVisible(_songView, _mode == OperatingMode.SONG);
    setVisible(_songTitle, !_songEditMode);
    setVisible(_songBodyText, !_songEditMode);
    setVisible(_songTitleInput, _songEditMode);
    setVisible(_songBodyInput, _songEditMode);
    
    _setBackButton.disabled = _setService.activeSet != null;
    _setDeleteButton.disabled = _setService.activeSet != null;
    _setEditButton.disabled = _setService.activeSet != null;
    
    setVisible(_setView, _mode == OperatingMode.SET);
    setVisible(_setTitleText, _setService.activeSet != null);
    setVisible(_setContentList, _mode == OperatingMode.SET);
    
    _songStyles.disabled = !(_mode == OperatingMode.SONG);
    _setStyles.disabled = !(_mode == OperatingMode.SET);
    
  } 
  
  void setVisible(Element elem, bool visible) {
    elem.style.display = visible ? "block" : "none";
  }
  
  
  void newSong() {
    _songEditMode = true;
    sidebarVisible = false;
    _songTitleInput.value = "";
    _songBodyInput.value = "";
    
    updateUiState();
    
  }
  
  void deleteSong() {
    Song s = _songService.activeSong;
    
    s.delete(() {
      refreshAllSongsList();
      _songService.activeSong = null;
      _songEditMode = false;
      resetUi();
    });
    
  }
  
  void cancelSong() {
    loadSong(_songService.activeSong);
    _songEditMode = false;
    updateUiState();
  }
  
  void saveSong() {
    Song s = _songService.activeSong;
    List<String> data = [];
       
    _fsService.saveSongAsText(_songTitleInput.value + ".txt", _songBodyInput.value, (FileEntry entry) {
      Song s = new Song(_fsService, entry);
      _songService.activeSong = s;
      _songTitle.text = _songTitleInput.value;
      _songBodyText.text = _songBodyInput.value;
      
      refreshAllSongsList();
      _songEditMode = false;
      
      updateUiState();    
      
    });
    
  }
  
  /* ----------- */
  /* Set methods */  
  /* ----------- */

  void refreshAllSetsList() {
    _allSetsList.children.clear();
    _setService.getAllSets((List<SongSet> sets) {
      sets.forEach((SongSet ss) {
        LIElement elem = new LIElement();
        elem.classes.add("list-group-item");
        elem.text = ss.title; 
        elem.onClick.listen((MouseEvent ev) {
          loadSet(ss);
          _setService.activeSet = ss;
        });
        _allSetsList.children.add(elem);
      });
    });
  }
  
  void newSet() {
    _setContentList.children.clear;
    switchToSetMode();    
  }
  
  void addSongToSetList(Song s) {
    
    LIElement elem = new LIElement();
    elem.classes.add("list-group-item");
    elem.dataset["key"] = s.key;
    SpanElement titleSpan = new SpanElement();
    titleSpan.text = s.title;
    elem.children.add(titleSpan);
    
    SpanElement deleteSpan = new SpanElement();
    deleteSpan.classes.add("toright");
    deleteSpan.classes.add("glyphicon");
    deleteSpan.classes.add("glyphicon-trash");
    deleteSpan.onClick.listen((e) {
      _setContentList.children.remove(elem);
    });
    
    elem.children.add(deleteSpan);
    
    _setContentList.children.add(elem);
    elem.scrollIntoView(); 
  }
  
  void saveSet() {
    String data = "";
    
    _setContentList.children.forEach((LIElement elem) {
      data += '${elem.dataset["key"]}\n';
    });
    
    _fsService.saveSet(_setTitleInput.value + ".txt", data, (FileEntry entry) {
      SongSet ss = new SongSet(_fsService, entry);
      _setService.activeSet = ss;
      refreshAllSetsList();
      switchToSongMode();
    });
    
  }
  
  void loadSet(SongSet ss) {
    
  }
  
  void cancelSet() {
   switchToSongMode(); 
   _setContentList.children.clear();
    
  }
  
}

