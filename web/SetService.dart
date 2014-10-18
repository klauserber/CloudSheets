library setService;

import 'dart:html';
import 'CsBase.dart';
import 'FsService.dart';


class SongSet extends FileEntity {
  SongSet(FsService fsService, FileEntry entry) : super(fsService, entry);
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