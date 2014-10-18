import 'dart:html';
import 'package:bootjack/bootjack.dart';
import 'package:dquery/dquery.dart';
import 'FsService.dart';
import 'SongService.dart';
import 'SetService.dart';
import 'UiService.dart';


FsService fsService;
SongService songService;
SetService setService;
UiService uiService;

void main() {
  
  fsService = new FsService(() {
    print("fs initialized");
    songService = new SongService(fsService);
    setService = new SetService(fsService);
    uiService = new UiService(fsService, songService, setService);
    
    uiService.initApp();
  });
  
  
  
}


