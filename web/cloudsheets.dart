import 'dart:html';
import 'package:bootjack/bootjack.dart';
import 'package:dquery/dquery.dart';
import 'FsService.dart';
import 'SongService.dart';
import 'SetService.dart';
import 'UiService.dart';
import 'CsTransfer.dart';


FsService fsService;
SongService songService;
SetService setService;
UiService uiService;
CsTransfer csTransfer;

void main() {
  
  fsService = new FsService(() {
    print("fs initialized");
    songService = new SongService(fsService);
    setService = new SetService(fsService);
    
    csTransfer = new CsTransfer(songService, fsService, setService);
    uiService = new UiService(fsService, songService, setService, csTransfer);
    
  });
  
  
  
}


