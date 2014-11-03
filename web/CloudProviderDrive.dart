library cloudProviderDrive;

import 'dart:html';
import 'dart:async';

import 'package:googleapis/common/common.dart' as common;
import 'package:googleapis_auth/auth_browser.dart' as auth;
import 'package:googleapis/drive/v2.dart' as drive;

import 'SongService.dart';
import 'CsBase.dart';


const String MIME_TYPE_FOLDER = "application/vnd.google-apps.folder";


class CloudProviderDrive {
  
  bool active = false;
  
  drive.DriveApi _driveApi;
  auth.BrowserOAuth2Flow _flow;
  
  drive.ParentReference _rootDir;
  
  drive.ParentReference _baseDir;
  drive.ParentReference _songsDir;
  drive.ParentReference _setsDir;
  
  auth.AccessToken _token;
  
  
  StreamController<String> _statusStreamController = new StreamController();
  
  // Obtain the client ID email from the Google Developers Console by creating
  // new OAuth credentials of application type "Web application".
  //
  // This example uses the implicit oauth2 flow. You need to configure the
  // "JAVASCRIPT ORIGINS" setting to point to the URIs where your webapp will
  // be accessed.
  
  // http://localhost:8080
  final identifier = new auth.ClientId("921848755413-aaeqsfqmhtf5prgu2jpdfa7sbb44fpha.apps.googleusercontent.com", null);
  
  // This is the list of scopes this application will use.
  // You need to enable the Drive API in the Google Developers Console.
  final scopes = [drive.DriveApi.DriveScope];

  void init() {
    _statusStreamController.add("initialising ...");        
    auth.createImplicitBrowserFlow(identifier, scopes).then((auth.BrowserOAuth2Flow flow) {
      _flow = flow;
      _flow.clientViaUserConsent(forceUserConsent: false).then((auth.AutoRefreshingAuthClient client) {
        _initDriveApi(client);
      }).catchError((_) {
        active = false;
        _statusStreamController.add("not authorized");        
      }).whenComplete(() {
        print("complete");
      });      
      
    });
    
  }
    
  void authorize() {
    if(_flow != null) {
      _flow.clientViaUserConsent(forceUserConsent: true).then((auth.AutoRefreshingAuthClient client) {
        _initDriveApi(client);
      }).catchError((error) {
        active = false;
        if (error is auth.UserConsentException) {
          _statusStreamController.add("not granted");
        } else {
          _statusStreamController.add("unknown error");
        }
      });
    }
    else {
      active = false;
      _statusStreamController.add("not possible");
    }
  }
  
  void _initDriveApi(auth.AutoRefreshingAuthClient client) {
    _driveApi = new drive.DriveApi(client);
    active = true;
    
    _token = client.credentials.accessToken;
    
    _driveApi.about.get().then((drive.About about) {
      _rootDir = new drive.ParentReference();
      _rootDir.id = about.rootFolderId;
      
      _initStructure().then((_) => _statusStreamController.add("authorized"));
    });
    
    
    
  }
  
  
  
  Stream<String> get onStatus {
    return _statusStreamController.stream;
  }
  
  Future syncSongs(List<Song> songs) {
    return _syncDir(_songsDir, songs);
  }
  

  Future _syncDir(drive.ParentReference driveDir, List<StoreEntity> entities) {
    Completer completer = new Completer();
    _statusStreamController.add("syncing ...");
    
    _searchDriveFiles(driveDir).then((Map<String, drive.File> driveFiles) {
      int taskCount = 0;
      Set<String> workList = new Set.from(driveFiles.keys);
      
      Map<String, StoreEntity> localEntities = {};
      entities.forEach((it) => localEntities[it.key] = it);
      
      workList.addAll(localEntities.keys);
      int counter = workList.length; 
      Function taskEnded = () {
        if(--counter == 0) {
          _statusStreamController.add("authorized");          
          completer.complete();
        }
      };
      workList.forEach((it) {
        drive.File drv = driveFiles[it];
        StoreEntity local = localEntities[it]; 
        
        if(drv != null && local != null) {
          taskCount++;
          local.readMeta().then((meta) {
            if(drv.modifiedDate.isAfter(meta.modTime)) {
              _copyDriveToLocal(drv, local).whenComplete(() => taskEnded());
            }
            else {
              _copyLocalToDrive(drv, local).whenComplete(() => taskEnded());
            }
          });
        }
        
      });
      
    });
    
    return completer.future;
  }
  
  Future _copyLocalToDrive(drive.File drv, StoreEntity local) {
    Completer cp = new Completer();
    
    print("local -> drv: " + drv.title);
    
    local.readText((text) {
      Stream<List<int>> stream = new Stream.fromFuture(new Future(() => text.codeUnits));
      common.Media media = new common.Media(stream, text.length);
      _driveApi.files.update(drv, drv.id, uploadMedia: media);
      cp.complete();
    });
    
    return cp.future;
  }
  
  
  Future _copyDriveToLocal(drive.File drv, StoreEntity local) {
    Completer cp = new Completer();
    
    print("drv -> local: " + drv.title);
    var headers = { "Authorization" : _token.type + " " + _token.data };
    
    HttpRequest.request(drv.downloadUrl, requestHeaders: headers).then((request) {
      local.store(request.responseText, () { cp.complete(); });
    });
    
    return cp.future;
    
  }
  
  
  Future<Map<String, drive.File>> _searchDriveFiles(drive.ParentReference dir) {
    String query = "'${dir.id}' in parents and trashed = false";
    Map<String, drive.File> docs = {};
    Future next(String token) {
      // The API call returns only a subset of the results. It is possible
      // to query through the whole result set via "paging".
      return _driveApi.files.list(q: query, pageToken: token).then((results) {
        results.items.forEach((it) => docs[it.title] = it);
        // If we would like to have more documents, we iterate.
        if (results.nextPageToken != null) {
          return next(results.nextPageToken);
        }
        return docs;
      });
    }
    return next(null);    
  }
  
  
  
  
  Future _initStructure() {
    Completer completer = new Completer();
    
    _initSubDir(_rootDir, "_cloudsheets").then((drive.ParentReference parent) {
      _baseDir = parent;
      _initSubDir(_baseDir, "songs").then((drive.ParentReference parent) {
        _songsDir = parent;
        _initSubDir(_baseDir, "sets").then((drive.ParentReference parent) {
          _setsDir = parent;
          completer.complete();
        }); 
      }); 
    });
    
    return completer.future;
    
  }  
    

  Future<drive.ParentReference> _initSubDir(drive.ParentReference parent, String dirTitle) {
    
    Completer completer = new Completer();
    

    String query = "title = '${dirTitle}' and mimeType = '$MIME_TYPE_FOLDER' and '${parent.id}' in parents and trashed = false";
    
    _driveApi.files.list(q: query, maxResults: 1).then((drive.FileList fileList) {
      if(fileList.items.length > 0) {
        drive.ParentReference par = new drive.ParentReference();
        par.id = fileList.items[0].id;
        completer.complete(par);
      }
      else {
        drive.File dirFile = new drive.File();
        
        dirFile.title = dirTitle;
        dirFile.mimeType = MIME_TYPE_FOLDER;
        dirFile.parents = [parent];
        _driveApi.files.insert(dirFile).then((drive.File fld) {
          drive.ParentReference par = new drive.ParentReference();
          par.id = fld.id;
          completer.complete(par);
        });
      }
    });
    
    return completer.future;    
    
  }
}

class SyncJob {
    
}
