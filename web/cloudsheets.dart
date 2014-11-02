import 'FsService.dart';
import 'SongService.dart';
import 'SetService.dart';
import 'UiService.dart';
import 'CsTransfer.dart';
import 'CloudProviderDrive.dart';


CloudProviderDrive cloudProviderDrive;

FsService fsService;
SongService songService;
SetService setService;
UiService uiService;
CsTransfer csTransfer;

void main() {
  
  fsService = new FsService(() {
    print("fs initialized");
    
    cloudProviderDrive = new CloudProviderDrive();
    
    songService = new SongService(fsService);
    setService = new SetService(fsService);
    
    csTransfer = new CsTransfer(songService, fsService, setService);
    uiService = new UiService(fsService, songService, setService, csTransfer, cloudProviderDrive);
    
  });
  
  
  
}


