import 'SongService.dart';
import 'SetService.dart';
import 'UiService.dart';
import 'CsTransfer.dart';
import 'CloudProviderDrive.dart';


CloudProviderDrive cloudProviderDrive;

SongService songService;
SetService setService;
UiService uiService;
CsTransfer csTransfer;

void main() {
  cloudProviderDrive = new CloudProviderDrive();
  
  songService = new SongService();
  setService = new SetService();
  
  csTransfer = new CsTransfer(songService, setService);
  uiService = new UiService(songService, setService, csTransfer, cloudProviderDrive);
}


