import 'dart:html';
import 'package:bootjack/bootjack.dart';
import 'package:dquery/dquery.dart';
import 'FsService.dart';
import 'SongService.dart';
import 'UiService.dart';


FsService fsService;
SongService songService;
UiService uiService;

void main() {
  
  fsService = new FsService(() {
    print("fs initialized");
    songService = new SongService(fsService);
    uiService = new UiService(fsService, songService);
    
    uiService.initApp();
  });
  
  
  
}


