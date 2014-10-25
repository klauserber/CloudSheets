import 'dart:html';
import 'package:bootjack/bootjack.dart';
import 'package:dquery/dquery.dart';
import 'FsService.dart';
import 'SongService.dart';
import 'SetService.dart';
import 'UiService.dart';
import 'CsExporter.dart';


FsService fsService;
SongService songService;
SetService setService;
UiService uiService;
CsExporter csExporter;

void main() {
  
  fsService = new FsService(() {
    print("fs initialized");
    songService = new SongService(fsService);
    setService = new SetService(fsService);
    
    csExporter = new CsExporter(songService, fsService, setService);
    uiService = new UiService(fsService, songService, setService, csExporter);
    
    uiService.initApp();
  });
  
  
  
}


