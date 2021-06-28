import 'dart:async';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:flutter_widget_gallery/gallery/gallery.dart';
//import 'package:photo_view/photo_view.dart';
//import 'package:photo_view/photo_view_gallery.dart';
import 'package:rc_smart_home/firebase_signin.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_auth/firebase_auth.dart';


class MonitorCard extends StatefulWidget{


  @override
  State<StatefulWidget> createState() => MonitorState();

}

class MonitorState extends State<MonitorCard>{

  DatabaseReference _monitorTimeRef;
  DatabaseReference _monitorRequestRef;
  StreamSubscription<Event> _monitorTimeSubscription;
  DatabaseError _error;
  String lastMonitorTime = "N/A";

  refreshRequest() {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(
        'Please wait for capturing...',
        style: const TextStyle(color: Color.fromARGB(255, 0, 155, 0)),
      ),
    ));
    _monitorRequestRef = FirebaseDatabase.instance.reference().child('communication/'+auth.userdata['uid']+'/user-requests/');
    _monitorRequestRef.update({"monitor":true});
    new Future.delayed(const Duration(seconds: 10), () => getNewImage());
  }

  @override
  void initState() {
    super.initState();
    String newTime = "";
    _monitorTimeRef = FirebaseDatabase.instance.reference().child('communication/'+auth.userdata['uid']+'/home-responds/capturing');
    _monitorTimeRef.keepSynced(true);
    _monitorTimeSubscription = _monitorTimeRef.onValue.listen((Event event) {
      //settate(() {});
      _error = null;
      print("[RC Info] New monitor: "+event.snapshot.value.toString());
      if(event.snapshot.value != null){
        newTime = event.snapshot.value.toString();
      }
      if(newTime != lastMonitorTime) {
        lastMonitorTime = newTime;
        getNewImage();
      }
    }, onError: (Object o) {
      final DatabaseError error = o;
      _error = error;
      print("[RC ERR] @ updating monitor time: "+error.toString());
    });
  }


  String appDir;
  //List<Map<String, dynamic>> galleryItems = [{"image":'monitor_images/no_image.jpg', "id":"timestamp"}];
  FirebaseApp app;
  FirebaseStorage storage;
  String latest_filename = "img.jpg";
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  File latestImgFile;
  Image latestImg = new Image(image: new AssetImage('monitor_images/no_image.jpg'), fit: BoxFit.fitWidth,);

  storageInit() async{
    appDir = (await getApplicationDocumentsDirectory()).path;
    app = FirebaseApp.instance;
    /*app = await FirebaseApp.configure(
      name: 'rc-smart-home',
      options: FirebaseOptions(
        googleAppID: "1:851963554987:android:97363d7066d19101",
        gcmSenderID: '851963554987',
        apiKey: 'AIzaSyBpNXYSJdyoHjBWjuhcOvka7V07jtvg9wg',
        projectID: 'rc-smart-home',
      ),
    );*/
    storage = FirebaseStorage(app: app, storageBucket: 'gs://rc-smart-home.appspot.com');
    //storage = FirebaseStorage.instance;
    //XXX??
  }

  saveToFile() async{
    final StorageReference ref = storage.ref().child(auth.userdata['uid']).child('monitor_image').child("img.jpg");
    latestImgFile = File('${appDir}/'+"monitor.jpg");
    if (latestImgFile.existsSync()) {
      await latestImgFile.delete();
    }
    await latestImgFile.create();
    assert(await latestImgFile.readAsString() == "");
    final StorageFileDownloadTask task = ref.writeToFile(latestImgFile);
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(
        'Image saved to monitor.jpg!',
        style: const TextStyle(color: Color.fromARGB(255, 0, 155, 0)),
      ),
    ));
  }

  getNewImage() async {
    if (storage == null) return;
    final StorageReference ref = storage.ref()
        .child(auth.userdata['uid'])
        .child('monitor_image')
        .child("img.jpg");
    String url = "";
    try {
      url = await ref.getDownloadURL();
    } on Exception catch (e) {
      print("[RC ERR] Download image error: " + e.toString());
      return;
    }
    //final String uuid = Uuid().v1();
    final http.Response downloadData = await http.get(url);
    //final Directory systemTempDir = Directory.systemTemp;

    // assert(tempFileContents == kTestString);
    // assert(byteCount == kTestString.length);

    //final String fileContents = downloadData.body;
    //final String name = await ref.getName();
    //final String bucket = await ref.getBucket();
    //final String path = await ref.getPath();
    try {
      if (context != null) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(
            'Download image success!',
            style: const TextStyle(color: Color.fromARGB(255, 0, 155, 0)),
          ),
        ));
      }
    } on Exception catch (e) {
      print("[RC ERR] " + e.toString());
    }
    try {
      setState(() {
        latestImg = Image.network(
          url,
          fit: BoxFit.fitWidth,
        );
        //latestImg = Image.file(latestImgFile, fit: BoxFit.fitWidth,);
        print("[RC Info] Refresh monitor image.");
      });
    } on Exception catch (e){
      print("[RC ERR] "+e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.display1;
    storageInit();
    // TODO: implement build
    return new Card(
      color: Colors.white,
      child: new Center(
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Padding(
                padding: new EdgeInsets.all(30.0),
                child: new Column(
                  children: <Widget>[
                    latestImg,
                    new Text(
                      "Updated @ "+lastMonitorTime.toString(),
                      style: new TextStyle(
                        color: textStyle.color,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              new Padding(
                padding: new EdgeInsets.all(20.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    new RaisedButton(
                      onPressed: () {refreshRequest();},
                      color: Colors.blueGrey[50],
                      child: new Column(
                        children: <Widget>[
                          new Padding(
                            padding: new EdgeInsets.fromLTRB(0,0,0,10),
                          ),
                          new Icon(
                            Icons.refresh,
                            color: Colors.blue,
                            size: 40,
                          ),
                          new Text(
                            "Refresh",
                          ),
                          new Padding(
                            padding: new EdgeInsets.fromLTRB(0,0,0,10),
                          ),
                        ],
                      ),
                    ),
                    new RaisedButton(
                      onPressed: () {saveToFile();},
                      color: Colors.blueGrey[50],
                      child: new Column(
                        children: <Widget>[
                          new Padding(
                            padding: new EdgeInsets.fromLTRB(0,0,0,10),
                          ),
                          new Icon(
                            Icons.save_alt,
                            color: Colors.blue,
                            size: 40,
                          ),
                          new Text(
                            "Save",
                          ),
                          new Padding(
                            padding: new EdgeInsets.fromLTRB(0,0,0,10),
                          ),
                        ],
                      ),
                    ),
                    /*
                  new RaisedButton(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        barrierDismissible: true, // user must tap button!
                        builder: (BuildContext context) {
                          return SimpleDialog(
                            title: Text("Monitor Gallery"),
                            children: <Widget>[
                              PhotoViewGallery.builder(
                                scrollPhysics: const BouncingScrollPhysics(),
                                builder: (BuildContext context, int index) {
                                  return PhotoViewGalleryPageOptions(
                                    imageProvider: AssetImage(galleryItems[index]['image']),
                                    initialScale: PhotoViewComputedScale.contained * 0.8,
                                    heroTag: galleryItems[index]['id'],
                                  );
                                },
                                itemCount: galleryItems.length,
                                //loadingChild: widget.loadingChild,
                                //backgroundDecoration: widget.backgroundDecoration,
                                //pageController: widget.pageController,
                                //onPageChanged: onPageChanged,
                              )
                            ],
                          );
                        },
                      );
                    },
                    color: Colors.blueGrey[50],
                    child: new Column(
                      children: <Widget>[
                        new Padding(
                          padding: new EdgeInsets.fromLTRB(0,0,0,10),
                        ),
                        new Icon(
                          Icons.photo_library,
                          color: Colors.blue,
                          size: 40,
                        ),
                        new Text(
                          "Gallery",
                        ),
                        new Padding(
                          padding: new EdgeInsets.fromLTRB(0,0,0,10),
                        ),
                      ],
                    ),
                  ),
                  */
                  ],
                ),
              ),
            ],
          )
      ),
    );
  }

}