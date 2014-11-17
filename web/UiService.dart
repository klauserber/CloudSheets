library uiService;

import 'dart:html';
import 'package:bootjack/bootjack.dart';
import 'package:dquery/dquery.dart';
import 'CsConst.dart';
import 'CsBase.dart';
import 'SongService.dart';
import 'SetService.dart';
import 'CsTransfer.dart';
import 'CloudProviderDrive.dart';


class OperatingMode extends Enum<int>  {
  const OperatingMode(int value) : super(value);
  
  static const OperatingMode SONG = const OperatingMode(0);
  static const OperatingMode SET = const OperatingMode(1);
  
}

class UiService {
  
  SongService _songService;
  SetService _setService;
  CsTransfer _csTransfer;
  
  bool _online;

  CloudProviderDrive _cloudProviderDrive; 
 
  OperatingMode _mode;
  bool _songEditMode = false;

  int touchStartX;

  
  ButtonElement _sidebarToggle;
  DivElement _sidebarContainer;
  DivElement _mainContent;
  
  
  Tab _allSongsTab;
  Tab _setsTab;
  Tab _manageTab;
  
  // Song elements 
  CssStyleSheet _songStyles;
  
  UListElement _allSongsList;
  DivElement _allSongsContainer;
  
  DivElement _songView; 

  DivElement _songToolBar; 

  ButtonElement _songNextButton;
  ButtonElement _songPrevButton;
  ButtonElement _songEditButton;
  ButtonElement _songNewButton;
  ButtonElement _songDeleteConfirmButton;
  ButtonElement _songDeleteButton;
  ButtonElement _songSaveButton;
  ButtonElement _songCancelButton;
  
  DivElement _songEditItems;
  InputElement _songTitleInput;
  TextAreaElement _songBodyInput;

  ButtonElement _insertCButton;
  ButtonElement _insertDButton;
  ButtonElement _insertEButton;
  ButtonElement _insertFButton;
  ButtonElement _insertGButton;
  ButtonElement _insertAButton;
  ButtonElement _insertBButton;
  
  ButtonElement _insertSpaceButton;
  
  ButtonElement _insertHashButton;
  ButtonElement _insertbButton;
  ButtonElement _insertmButton;

  DivElement _songViewItems;
  HeadingElement _songTitle;
  PreElement _songBodyText;
  
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
  
  ButtonElement _importButton;
  InputElement _filesInput;
  ButtonElement _importArchiveButton;
  InputElement _archiveInput;
  ButtonElement _exportButton;
  ButtonElement _fullscreenButton;

  ButtonElement _updateButton;
  SpanElement _versionLabel;
  
  ButtonElement _driveButton;
  ButtonElement _driveSyncButton;
  SpanElement _driveStatusLabel;
  SpanElement _driveSyncStatusLabel;
  
  AnchorElement _downloadExport;
  
  ButtonElement _deleteAllConfirmButton;
  
  DivElement _successMessage;
  Modal _successModal;
  Modal _deleteSongModal;
  
  
  bool _sidebarVisible = true;
  
  UiService(SongService songService, SetService setService, CsTransfer csTransfer, CloudProviderDrive cloudProviderDrive) {
    _songService = songService;
    _setService = setService;
    _csTransfer = csTransfer;
    
    _cloudProviderDrive = cloudProviderDrive;
    
    initAppCache();
    initApp();
 }
  
  void initApp() {
    Transition.use();
    Collapse.use();
    Modal.use();
    
    //Tab.use();
    
    window.onResize.listen((Event e) => setSizes());
    
    _online = window.navigator.onLine;
    
    window.onOnline.listen((_) => goOnline());
    window.onOffline.listen((_) => goOffline());
    
    _mode = OperatingMode.SONG;
        
    _sidebarContainer = $("#sidebarContainer")[0];
    _sidebarToggle = $("#sidebarToggle")[0];
    _mainContent = $("#mainContent")[0];
    
    
    // Song elements init
    _allSongsList = $("#allSongsList")[0];
    _allSongsContainer = $("#allSongsContainer")[0];
    
    _songView = $("#songView")[0];
    
    _songToolBar = $("#songToolBar")[0];

    _allSongsTab = Tab.wire($("#allSongsTab")[0]);
    _setsTab = Tab.wire($("#setsTab")[0]);
    _manageTab = Tab.wire($("#manageTab")[0]);
    
    _songNextButton = $("#songNextButton")[0];
    _songPrevButton = $("#songPrevButton")[0];
    _songEditButton = $("#songEditButton")[0];
    _songNewButton = $("#songNewButton")[0];
    _songDeleteConfirmButton = $("#songDeleteConfirmButton")[0];
    _songDeleteButton = $("#songDeleteButton")[0];
    _songSaveButton = $("#songSaveButton")[0];
    _songCancelButton = $("#songCancelButton")[0];
                  
    _songEditItems = $("#songEditItems")[0];
    _songTitleInput = $("#songTitleInput")[0];
    _songBodyInput = $("#songBodyInput")[0];


    _insertCButton = $("#insertCButton")[0];
    _insertCButton.onClick.listen((e) => insert("C"));
    _insertDButton = $("#insertDButton")[0];
    _insertDButton.onClick.listen((e) => insert("D"));
    _insertEButton = $("#insertEButton")[0];
    _insertEButton.onClick.listen((e) => insert("E"));
    _insertFButton = $("#insertFButton")[0];
    _insertFButton.onClick.listen((e) => insert("F"));
    _insertGButton = $("#insertGButton")[0];
    _insertGButton.onClick.listen((e) => insert("G"));
    _insertAButton = $("#insertAButton")[0];
    _insertAButton.onClick.listen((e) => insert("A"));
    _insertBButton = $("#insertBButton")[0];
    _insertBButton.onClick.listen((e) => insert("B"));

    _insertSpaceButton = $("#insertSpaceButton")[0];
    _insertSpaceButton.onClick.listen((e) => insert("  "));
    
    
    _insertHashButton = $("#insertHashButton")[0];
    _insertHashButton.onClick.listen((e) => insert("# "));
    _insertbButton = $("#insertbButton")[0];
    _insertbButton.onClick.listen((e) => insert("b "));
    _insertmButton = $("#insertmButton")[0];
    _insertmButton.onClick.listen((e) => insert("m "));
    
    _songViewItems = $("#songViewItems")[0];
    _songTitle = $("#songTitle")[0];
    _songBodyText = $("#songBodyText")[0];
    
    _songSaveButton.disabled = true;
    _songCancelButton.disabled = true;
    
    _songEditItems.style.display = "none";
    
    _sidebarToggle.onClick.listen((e) => toggleSidebar());
    
    _songNextButton.onClick.listen((e) => nextSong());
    _songPrevButton.onClick.listen((e) => prevSong());
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
    _setDeleteConfirmButton.onClick.listen((e) => deleteSet());
    
    _setTitleInput = $("#setTitleInput")[0];
    _setTitleText = $("#setTitleText")[0];
    _setContentList = $("#setContentList")[0];
    _setContentContainer = $("#setContentContainer")[0];
    _setList = $("#setList")[0];

    
    StyleElement setStyleElem = new StyleElement();
    document.head.append(setStyleElem);
    _setStyles = setStyleElem.sheet;
    _setStyles.insertRule(".addicon { display: inline }", 0);
        
    
    _importButton = $("#importButton")[0];
    _filesInput = $("#filesInput")[0];
    _importArchiveButton = $("#importArchiveButton")[0];
    _archiveInput = $("#archiveInput")[0];
    _exportButton = $("#exportButton")[0];
    _fullscreenButton = $("#fullscreenButton")[0];
    
    _updateButton = $("#updateButton")[0];
    _versionLabel = $("#versionLabel")[0];
    
    _importButton.onClick.listen((e) {
      _filesInput.style.display = "inline";
    });
    _importArchiveButton.onClick.listen((e) {
      _archiveInput.style.display = "inline";
    });
    
    _filesInput.onChange.listen((e) => importSongs());
    _archiveInput.onChange.listen((e) => importArchive());
    
    _exportButton.onClick.listen((e) => exportData());
    _downloadExport = $("#downloadExport")[0];

    _fullscreenButton.onClick.listen((e) => document.body.requestFullscreen());
    _updateButton.onClick.listen((e) => updateApp());    
    

    _deleteAllConfirmButton = $("#deleteAllConfirmButton")[0];
    
    _deleteAllConfirmButton.onClick.listen((e) => deleteAllData());

    _successMessage = $("#successMessage")[0];

    _deleteSongModal = Modal.wire($("#deleteSongModal")[0]);
      
    _successModal = Modal.wire($("#successModal")[0]);

    _driveButton = $("#driveButton")[0];
    _driveSyncButton = $("#driveSyncButton")[0];
    _driveStatusLabel = $("#driveStatusLabel")[0];
    _driveSyncStatusLabel = $("#driveSyncStatusLabel")[0];
    _cloudProviderDrive.onStatus.listen((String status) => driveStatusChange(status));
    _cloudProviderDrive.onSyncStatus.listen((String status) => driveSyncStatusChange(status));
    _driveButton.onClick.listen((e) => _cloudProviderDrive.authorize());    
    _driveSyncButton.onClick.listen((e) => syncWithDrive());    
    
    
    
    refreshAllSongsList();
    
    refreshAllSetsList();
    
    
    resetUi();
    
    setSizes();
    
    initSwiping();
    
    if(_online) {
      goOnline();
    }
    else {
      goOffline();
    }
  }
    
  void insert(String str) {
    String val = _songBodyInput.value;
    int start = _songBodyInput.selectionStart;
    int end = _songBodyInput.selectionEnd;
    
    String newVal = val.substring(0, start);
    newVal += str;
    newVal += val.substring(end);
    
    _songBodyInput.value = newVal;
    
    _songBodyInput.setSelectionRange(start + str.length, start + str.length);
  }
  
  void driveStatusChange(String status) {
    _driveStatusLabel.text = status;
    if(status == "not authorized") {
      _driveButton.disabled = false;
    }
    else {
      _driveButton.disabled = true;      
    }
    if(status.startsWith("authorized")) {
      _driveSyncButton.disabled = false;
    }
    else {
      _driveSyncButton.disabled = true;      
    }
  }
  
  void driveSyncStatusChange(String status) {
    _driveSyncStatusLabel.text = status;
    if(status == "ok" || status == "error!") {
      _driveSyncButton.disabled = false;
    }
    else {
      _driveSyncButton.disabled = true;      
    }
  }
  
  
  void goOffline() {
    _online = false;
    _driveButton.disabled = true;
    _driveSyncButton.disabled = true;
    _driveStatusLabel.text = "offline";
  }
  
  void goOnline() {
    _online = true;
    _cloudProviderDrive.init();
    _driveButton.disabled = false;
    _driveSyncButton.disabled = false;
  }
  
  void syncWithDrive() {
    _cloudProviderDrive.sync().whenComplete(() {
      refreshAllSongsList();
      refreshAllSetsList();
      resetUi();
      print("sync ok");
    });      
  }
  
  void initAppCache() {
    ApplicationCache cache = window.applicationCache;
    
    cache.onUpdateReady.listen((e) {
      cache.swapCache();
      window.location.reload();
    });
    cache.onChecking.listen((e) {
      _versionLabel.text = "checking ... ($CS_VERSION)";    
    });
    cache.onError.listen((e) {
      _versionLabel.text = "$CS_VERSION (cached)";    
    });
    cache.onNoUpdate.listen((e) {
      _versionLabel.text = "$CS_VERSION";
    });

  }
  
  void initSwiping() {

    _songBodyText.onTouchStart.listen((TouchEvent event) {
      //event.preventDefault();

      if (event.touches.length > 0) {
        touchStartX = event.touches[0].page.x;
      }
    });

    _songBodyText.onTouchMove.listen((TouchEvent event) {

      if (touchStartX != null && event.touches.length > 0) {
        int newTouchX = event.touches[0].page.x;
        //print("start: $touchStartX, new: $newTouchX");
        
        if (newTouchX - 150 > touchStartX) {
          event.preventDefault();
          prevSong();
          touchStartX = null;
        } else if (newTouchX + 150 < touchStartX) {
          event.preventDefault();
          nextSong();
          touchStartX = null;
        }
      }
    });

    _songBodyText.onTouchEnd.listen((TouchEvent event) {
      //event.preventDefault();

      touchStartX = null;
    });    
    
    
  }
  

  void updateApp() {
    window.applicationCache.update();
  }

  
  void showSuccessModal(String message) {
    _successMessage.text = message;
    _successModal.show();
  }
  
  void deleteAllData() {
    window.localStorage.clear();
    refreshAllSongsList();
    refreshAllSetsList();
    resetUi();
    showSuccessModal("All data is gone.");
  }
  
  void exportData() {
    _downloadExport.href = _csTransfer.export();

    _downloadExport.download = "cloudsheets.tar";
    _downloadExport.text = "Download";
  }
  
  void importSongs() {
     
     Iterable songs = _filesInput.files.where((File it) => !it.name.endsWith(".tar"));
     
     _csTransfer.uploadFiles(songs).then((_) {
       print("files uploaded");
       _filesInput.style.display = "none";
       refreshAllSongsList();
       showSuccessModal("Songs successfully imported.");
     });
  }
  
  
  void importArchive() {
     
     File archive = _archiveInput.files[0];
     
     _csTransfer.importArchive(archive).then((_) {
       _archiveInput.style.display = "none";
       refreshAllSongsList();
       refreshAllSetsList();
       showSuccessModal("Archive successfully imported.");
     });
  }
  
  void nextSong() {
    SongSet ss = _setService.activeSet;
    if(ss != null && ss.hasNext()) {
      loadSong(ss.songs[ss.songPos+1]);
    }
    
  }

  void prevSong() {
    SongSet ss = _setService.activeSet;
    if(ss != null && ss.hasPrev()) {
      loadSong(ss.songs[ss.songPos-1]);
    }
  }
  
  
  
  
  void setSizes() {
    
    int h = window.innerHeight;
    
    _setContentContainer.style.height = "${h - 130}px";
    _allSongsContainer.style.height = "${h - 140}px";
    _setList.style.height = "${h - 250}px";
    
    _songBodyText.style.height = "${h - _songTitle.getBoundingClientRect().height - 100}px";
    _songBodyInput.style.height = "${h - 130}px";
    
    optimizeSetToolbar();
    
  }

  void optimizeSetToolbar() {
    if(window.innerWidth <= 480) {
      if(_setService.activeSet == null) {
        setVisible(_setEditButton, false, true);
        setVisible(_setNewButton, true, true);
      }
      else {
        setVisible(_setEditButton, true, true);
        setVisible(_setNewButton, false, true);        
      }
    }
    else {
      setVisible(_setEditButton, true, true);
      setVisible(_setNewButton, true, true);              
    }
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
    _mainContent.style.width = _sidebarVisible ? "45%" : "100%";
    setSizes();
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
    List<Song> songs = _songService.getAll();
    songs.forEach((Song s) {
      LIElement elem = createSongElement(s);
      allSongsList.children.add(elem);
    });
  }

  LIElement createSongElement(Song s) {
    LIElement elem = new LIElement();
    elem.classes.add("list-group-item");
    
    SpanElement textSpan = new SpanElement();
    textSpan.text = s.title;
    elem.dataset["key"] = s.key;
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
          addSongToSetList(s, false);
          break;
      }
    });
    return elem;
  }
  
  
  void loadSong(Song s) {
    _songTitle.text = s.title;
    _songBodyText.text = s.text;
    _songService.activeSong = s;
    sidebarVisible = false;
    SongSet ss = _setService.activeSet;
    if(ss != null) {
      ss.songPos = s.pos;
      markListEntry(_setList, s.pos);
    }
    for(int i=0; i < _allSongsList.children.length; i++) {
      if(_allSongsList.children[i].dataset["key"] == s.key) {
        markListEntry(_allSongsList, i);
      }
    }
    updateUiState();
  }

  void markListEntry(Element elem, int pos) {
    List<Element> childs = elem.children;
    childs.forEach((Element e) {
      e.dataset.remove("mark");
    });
    childs[pos].dataset["mark"] = "1";
  }
  
 void editSong() {
    Song s = _songService.activeSong;
    
    _songTitleInput.value = s.title;
    _songBodyInput.value = s.text;  
    _songEditMode = true;
    updateUiState();    
    sidebarVisible = false;
  }
  
  void resetUi() {
    _songTitle.text = "";
    _songBodyText.text = "";
    
    _songService.activeSong = null;
    _setService.activeSet = null;
    
    _setTitleInput.value = "";
    _setContentList.children.clear;
    
    
    sidebarVisible = true;
    
    _songEditMode = false;
    
    switchToSongMode();    
  }
  
  void updateUiState() {
    bool actSet = _setService.activeSet != null;
    
    _sidebarToggle.disabled = _songEditMode || _mode == OperatingMode.SET;
    
    setVisible(_songToolBar, _mode == OperatingMode.SONG);
    setVisible(_setToolBar, _mode == OperatingMode.SET);
    
    _songNextButton.disabled = !(actSet && _setService.activeSet.hasNext());
    _songPrevButton.disabled = !(actSet && _setService.activeSet.hasPrev());
    
    _songNewButton.disabled = _songEditMode;
    _songSaveButton.disabled = !_songEditMode;
    _songCancelButton.disabled = !_songEditMode;
    _songEditButton.disabled = _songEditMode;
    
    setVisible(_songView, _mode == OperatingMode.SONG);
    setVisible(_songViewItems, !_songEditMode);
    setVisible(_songEditItems, _songEditMode);    
    
    _setBackButton.disabled = !actSet;
    _setDeleteButton.disabled = !actSet;
    _setEditButton.disabled = !actSet || _mode == OperatingMode.SET;
    _setNewButton.disabled = _mode == OperatingMode.SET;
    
    setVisible(_setView, _mode == OperatingMode.SET);
    setVisible(_setTitleText, actSet);
    setVisible(_setList, actSet);
    setVisible(_allSetsList, !actSet);
    
    _songStyles.disabled = !(_mode == OperatingMode.SONG);
    _setStyles.disabled = !(_mode == OperatingMode.SET);
    
    setSizes();
    
  } 
  
  void setVisible(Element elem, bool visible, [bool inline = false]) {
    String typ = inline ? "inline" : "block";
    
    elem.style.display = visible ? typ : "none";
  }
  
  
  void newSong() {
    _songEditMode = true;
    sidebarVisible = false;
    _songTitleInput.value = "";
    _songBodyInput.value = "";
    
    updateUiState();
    
  }
  
  void deleteSong() {
    _deleteSongModal.hide();
    
    Song s = _songService.activeSong;
    _songService.markDeleted(s);
    
    refreshAllSongsList();
    _songService.activeSong = null;
    _songEditMode = false;
    resetUi();
  }
  
  void cancelSong() {
    _songEditMode = false;
    updateUiState();
  }
  
  void saveSong() {
    Song s = _songService.activeSong;
    if(s == null) {
      s = new Song(null);
      _songService.activeSong = s;
    }
    
    s.key = _songTitleInput.value;
    s.text = _songBodyInput.value;
    _songService.save(s);
    
    _songService.activeSong = s;
    _songTitle.text = _songTitleInput.value;
    _songBodyText.text = _songBodyInput.value;
    
    refreshAllSongsList();
    _songEditMode = false;
    
    updateUiState();    
    
  }
  
  /* ----------- */
  /* Set methods */  
  /* ----------- */

  void refreshAllSetsList() {
    _allSetsList.children.clear();
    List<SongSet> sets = _setService.getAll();
    sets.forEach((SongSet ss) {
      LIElement elem = new LIElement();
      elem.classes.add("list-group-item");
      elem.text = ss.title; 
      elem.onClick.listen((MouseEvent ev) {
        loadSet(ss);
      });
      _allSetsList.children.add(elem);
    });
  }
  
  void newSet() {
    _setContentList.children.clear;
    _setTitleInput.value = "";
    _setService.activeSet = null;
    switchToSetMode();    
  }
  
  void addSongToSetList(Song s, bool atEnd) {
    
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
    
    elem.onClick.listen((e) {
      if(elem.dataset["mark"] == "1") {
        elem.dataset.remove("mark");
      }     
      else {
        _setContentList.children.forEach((Element e) {
          e.dataset.remove("mark");
        });
        elem.dataset["mark"] = "1";
      }
    });
    
    List<Element> childs = _setContentList.children;
    if(atEnd) {
      childs.add(elem);      
    } else {
      int idx = childs.length;
      
      for(int i = 0; i < childs.length; i++) {
        if(childs[i].dataset["mark"] == "1") {
          idx = i;
          break;
        }      
      }
      childs.insert(idx, elem);
    }
    
    elem.scrollIntoView(); 
  }
  
  void saveSet() {
    SongSet ss = new SongSet(_setTitleInput.value);
    _setContentList.children.forEach((LIElement elem) {
      String songKey = elem.dataset["key"];
      Song s = _songService.find(songKey);
      ss.songs.add(s);
    });
    _setTitleInput.value = "";
    _setContentList.children.clear;
    
    _setService.save(ss);

    _setService.activeSet = ss;
    loadSet(ss);
    refreshAllSetsList();
    switchToSongMode();
  }
  
  void loadSet(SongSet ss) {
    
    _setList.children.clear();
    _setTitleText.text = ss.title;
    _setService.activeSet = ss;
    ss.songs.forEach((Song song) {
      LIElement elem = createSongElement(song);
      _setList.children.add(elem);
    });
    
    updateUiState();
  }
  
  void cancelSet() {
   switchToSongMode(); 
   _setContentList.children.clear();
    
  }
  
  void editSet() {
    SongSet ss = _setService.activeSet;
    if(ss != null) {
      _setContentList.children.clear();
      _setTitleInput.value = ss.title;
      ss.songs.forEach((Song song) {
        addSongToSetList(song, true);
      });
      switchToSetMode();    
    }
  }
  
  void backSet() {
    _setService.activeSet = null;
    updateUiState();
  }
  
  void deleteSet() {
    SongSet ss = _setService.activeSet;
    _setService.markDeleted(ss);
    _setService.activeSet = null;
    refreshAllSetsList();
    resetUi();
    updateUiState();      
  }
  
}

