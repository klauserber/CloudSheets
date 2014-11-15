library cloudProviderDrive;

import 'dart:html';
import 'dart:async';
import 'dart:convert';

import 'package:googleapis/common/common.dart' as common;
import 'package:googleapis_auth/auth_browser.dart' as auth;
import 'package:googleapis/drive/v2.dart' as drive;

import 'SongService.dart';
import 'SetService.dart';
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
  
  SongService _songService;
  SetService _setService;
  
  
  StreamController<String> _statusStreamController = new StreamController();
  StreamController<String> _syncStatusStreamController = new StreamController();
  
  // Obtain the client ID email from the Google Developers Console by creating
  // new OAuth credentials of application type "Web application".
  //
  // This example uses the implicit oauth2 flow. You need to configure the
  // "JAVASCRIPT ORIGINS" setting to point to the URIs where your webapp will
  // be accessed.
  
  // http://localhost:8080
  //final identifier = new auth.ClientId("921848755413-aaeqsfqmhtf5prgu2jpdfa7sbb44fpha.apps.googleusercontent.com", null);

  // http://cloudsheets.isium..de
  final identifier = new auth.ClientId("921848755413-6km91tei0efakrsgss5hd98vj60o986t.apps.googleusercontent.com", null);
  
  // This is the list of scopes this application will use.
  // You need to enable the Drive API in the Google Developers Console.
  final scopes = [drive.DriveApi.DriveScope];

  
  CloudProviderDrive(this._songService, this._setService);
  
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
      
      _initStructure().then((_) => _statusStreamController.add("authorized: " + about.name));
    });
    
    
    
  }
  
  
  
  Stream<String> get onStatus {
    return _statusStreamController.stream;
  }
  
  Stream<String> get onSyncStatus {
    return _syncStatusStreamController.stream;
  }
  
  Future sync() {
    Completer cp = new Completer();
    syncSongs().whenComplete(() => syncSets().whenComplete(() => cp.complete()));
    return cp.future;
  }
  
  Future syncSongs() {
    _syncStatusStreamController.add("syncing Songs ...");
    List<Song> songs = _songService.getAll(includeDeleted: true);
    return _syncDir(_songsDir, songs, _songService);
  }
  
  Future syncSets() {
    _syncStatusStreamController.add("syncing Sets ...");
    List<SongSet> sets = _setService.getAll(includeDeleted: true);
    return _syncDir(_setsDir, sets, _setService);
  }
  

  Future _syncDir(drive.ParentReference driveDir, List<StoreEntity> entities, StoreService storeService) {
    Completer completer = new Completer();
    
    _searchDriveFiles(driveDir).then((Map<String, drive.File> driveFiles) {
      Set<String> workList = new Set.from(driveFiles.keys);
      
      Map<String, StoreEntity> localEntities = {};
      entities.forEach((it) => localEntities[it.key] = it);
      
      workList.addAll(localEntities.keys);

      _syncItems(workList, 0, driveFiles, localEntities, storeService, driveDir).then((_) {
        _syncStatusStreamController.add("ok");          
        completer.complete();        
      }).catchError((e) {
        _syncStatusStreamController.add("error!");
        completer.completeError(e);
      });
    }).catchError((e) {
      _syncStatusStreamController.add("error!");
      completer.completeError(e);
    });
    
    return completer.future;
  }
  
  Future _syncItems(Set<String> workList, int i, Map<String, drive.File> driveFiles, Map<String, StoreEntity> localEntities,
       StoreService storeService, drive.ParentReference driveDir) {
    
    Completer cp = new Completer();
    int count = workList.length; 
    
    
    if(i < count) {
      String key = workList.elementAt(i);
      _syncStatusStreamController.add("syncing '$key' (${i + 1} of $count)");

      _syncItem(key, driveFiles, localEntities, storeService, driveDir).then((key) {
        print("complete: $key");
        _syncItems(workList, i + 1, driveFiles, localEntities, storeService, driveDir).then((_) {
          print("complete: syncItems");  
          cp.complete();
        });
      }).catchError((e) => cp.completeError(e));
    }
    else {
      print("complete: worklist");          
      cp.complete();
    }
    
    
    return cp.future;
    
  }
  

  Future<String> _syncItem(String it, Map<String, drive.File> driveFiles, Map<String, StoreEntity> localEntities, 
      StoreService storeService, drive.ParentReference driveDir) {
    
    Completer<String> cp = new Completer();
    
    drive.File drv = driveFiles[it];
    StoreEntity local = localEntities[it]; 
    
    // present in drive and local
    if(drv != null && local != null) {
      DateTime localDate = new DateTime.fromMillisecondsSinceEpoch(local.modTime, isUtc: true);
      print("Timestamps ${local.key}: drv:${drv.modifiedDate} - local:${localDate}");
      
      if(local.deleted) {
        print("delete ${local.key}");
        _driveApi.files.delete(drv.id).then((_) {
          storeService.delete(local.key);
          cp.complete(local.key);
        }).catchError((e) => cp.completeError(e));
        
      }
      // File on drive is never
      else if(drv.modifiedDate.millisecondsSinceEpoch > local.modTime) {
        _copyDriveToLocal(drv, storeService).then((key) => cp.complete(key))
          .catchError((e) => cp.completeError(e));
      }
      // Local file is newer
      else if(local.modTime > drv.modifiedDate.millisecondsSinceEpoch) {
        _copyLocalToDrive(driveDir, drv, local, storeService).then((key) => cp.complete(key))
          .catchError((e) => cp.completeError(e));
      }
      // Same => nothing todo
      else {
        print("nothing todo for ${local.key}");
        cp.complete(local.key);
      }
    }
    // File exists only local
    else if(drv == null && local != null) {
      if(local.newEntry) {
        print("new entry ${local.key}");
        _copyLocalToDrive(driveDir, drv, local, storeService).then((key) { 
          cp.complete(key);
        }).catchError((e) => cp.completeError(e));
      }
      else {
        print("obsolete entry ${local.key}");
        storeService.delete(local.key);
        cp.complete(local.key);
      }
    }
    // File exists only in drive
    else if(drv != null && local == null) {
      print("new entry in drive ${it}");
      _copyDriveToLocal(drv, storeService).then((key) { 
        cp.complete(key);
      }).catchError((e) => cp.completeError(e));
    }
    return cp.future;
  }
  
  Future<String> _copyLocalToDrive(drive.ParentReference driveDir, drive.File drv, StoreEntity local, StoreService storeService) {
    Completer cp = new Completer();
    print("local -> drv: " + local.title);

    String text = JSON.encoder.convert(local);
    
    Stream<List<int>> stream = new Stream.fromFuture(new Future(() => text.codeUnits));
    common.Media media = new common.Media(stream, text.length);

    
    if(drv != null) {
      drv.modifiedDate = new DateTime.fromMillisecondsSinceEpoch(local.modTime, isUtc: true);
      _driveApi.files.update(drv, drv.id, setModifiedDate: true, uploadMedia: media).then((file) {
        local.setSynced();
        storeService.save(local, updateModTime: false);
        cp.complete(local.key);        
      }).catchError((e) => cp.completeError(e));      
    }
    else {
      drive.File newDrv = new drive.File();
      newDrv.title = local.key + ".json";
      newDrv.mimeType = "text/json";
      newDrv.modifiedDate = new DateTime.fromMillisecondsSinceEpoch(local.modTime, isUtc: true);
      newDrv.parents = [driveDir];
      _driveApi.files.insert(newDrv, uploadMedia: media).then((file) {
        local.setSynced();
        storeService.save(local, updateModTime: false);
        cp.complete(local.key);
      }).catchError((e) => cp.completeError(e));
    }
    
    return cp.future;
  }

  Future<String> _copyDriveToLocal(drive.File drv, StoreService storeService) {
    Completer cp = new Completer();
    
    print("drv -> local: " + drv.title);

    var headers = { "Authorization" : _token.type + " " + _token.data };
    
    HttpRequest.request(drv.downloadUrl, requestHeaders: headers).then((request) {
      StoreEntity local = storeService.create(request.responseText);
      local.setSynced();
      local.modTime = drv.modifiedDate.millisecondsSinceEpoch;
      storeService.save(local, updateModTime: false);
      cp.complete(local.key);
    }).catchError((e) => cp.completeError(e));
    
    return cp.future;
  }
  
  
  
  Future<Map<String, drive.File>> _searchDriveFiles(drive.ParentReference dir) {
    String query = "'${dir.id}' in parents and trashed = false";
    Map<String, drive.File> docs = {};
    Future next(String token) {
      // The API call returns only a subset of the results. It is possible
      // to query through the whole result set via "paging".
      return _driveApi.files.list(q: query, pageToken: token).then((results) {
        results.items.forEach((it) => docs[stripExtention(it.title)] = it);
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
