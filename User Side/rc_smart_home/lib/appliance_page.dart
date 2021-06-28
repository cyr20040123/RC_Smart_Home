import 'dart:async';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rc_smart_home/firebase_signin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;
import 'package:path_provider/path_provider.dart';

class ApplianceCard extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: AppliancePage(),
    );
  }
  //new SingleChildScrollView()
}

class AppliancePage extends StatefulWidget {
  @override
  createState() => new AppliancePageState();
}

class AppliancePageState extends State<AppliancePage> {
  //final _suggestions = [];
  List<Map<String, dynamic>> appliance_list = [];

  // For firebase listening:
  Map<String, dynamic> appliance_status = {};
  DatabaseReference _applianceStatusRef;
  DatabaseReference _userRequestApplianceRef;
  StreamSubscription<Event> _applianceStatusSubscription;

  DatabaseError _error;

  @override
  void initState() {
    super.initState();
    // Demonstrates configuring to the database using a file
    _applianceStatusRef = FirebaseDatabase.instance.reference().child('communication/'+auth.userdata['uid']+'/appliances');
    _userRequestApplianceRef = FirebaseDatabase.instance.reference().child('communication/'+auth.userdata['uid']+'/user-requests/appliances');
    _applianceStatusRef.keepSynced(true);
    _applianceStatusSubscription = _applianceStatusRef.onValue.listen((Event event) {
      setState(() {
        _error = null;
        print("[DEBUG] "+event.snapshot.value.toString());
        Map<String, dynamic> tMap = {};
        if(event.snapshot.value == null){
          appliance_status = {};
        } else {
          for (var key in event.snapshot.value.keys){
            tMap[key.toString()] = event.snapshot.value[key].toString();
          }
          appliance_status = tMap;
        }
        updateApplianceStatus();
      });
    }, onError: (Object o) {
      final DatabaseError error = o;
      setState(() {
        _error = error;
        appliance_status = {};
      });
    });
  }

  int requestTime = new DateTime.now().millisecondsSinceEpoch~/1000;

  listenStatusChanges({bool immediate=true}){
    if(immediate==false && new DateTime.now().millisecondsSinceEpoch~/1000-requestTime<=3){
      _applianceStatusSubscription.pause();
      print("[RC DEBUG] PAUSED LISTENING APPLIANCE STATUS.");
    } else {
      _applianceStatusSubscription.resume();
      _applianceStatusRef.once().then((DataSnapshot snapshot) {
        Map<String, dynamic> tMap = {};
        for (var key in snapshot.value.keys){
          tMap[key.toString()] = snapshot.value[key].toString();
        }
        setState(() {
          appliance_status = snapshot.value == null ? {} : tMap;
          updateApplianceStatus();
        });
      });
      print("[RC DEBUG] RESUME LISTENING APPLIANCE STATUS.");
    }
  }

  @override
  void dispose() {
    super.dispose();
    try{
      _applianceStatusSubscription.cancel();
    } on Exception catch (e){
      print("[RC Warn] "+e.toString());
    }
  }

  updateApplianceStatus(){
    /*if(_applianceStatusSubscription==null){
      print("[RC DEBUG] Pass update status.");
      return;
    }*/
    int i;
    Map<String, dynamic> ele;
    String aid;
    for (i=0; i<appliance_list.length; i++){
      ele = appliance_list[i];
      aid = ele['id'].toString();
      appliance_list[i]['status']=false;
      if(appliance_status.containsKey(aid)){
        if(appliance_status[aid]=='on'){
          appliance_list[i]['status']=true;
        }
      }
    }
    saveList();
    print("[RC Info] Appliance status updated.");
  }

  controlAppliance(){
    _applianceStatusSubscription.pause();
    print("[RC DEBUG] PAUSED LISTENING APPLIANCE STATUS.");
    Map<String, dynamic> data = {};
    for (Map<String, dynamic> i in appliance_list){
      data[i['id'].toString()] = i['status'] ? 'on':'off';
    }
    print("[RC DEBUG] UPLOAD REQUEST: "+data.toString());
    _userRequestApplianceRef.update(data);
    requestTime = new DateTime.now().millisecondsSinceEpoch~/1000;
    new Future.delayed(const Duration(seconds: 4), () => listenStatusChanges(immediate:false));
  }

  final TextStyle _biggerFont = new TextStyle(
    fontSize: 20,
    color: Colors.blueGrey,
  );

  saveList() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int l = appliance_list.length;
    //Map newMap;
    prefs.setInt("appliance_list_length", l);
    for(int i=0;i<l;i++){
      //newMap={};
      prefs.setString("appliance_"+i.toString(), convert.json.encode(appliance_list[i]));
    }
    print("[RC DEBUG] LIST SAVED TO PREFS.");
  }

  loadList() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int l;
    String str;
    l = await prefs.getInt("appliance_list_length");
    List<Map<String, dynamic>> a_list = [];
    for (int i=0;i<l;i++){
      str = prefs.getString("appliance_"+i.toString());
      a_list.add(convert.json.decode(str));
    }
    if(a_list.toString() != appliance_list.toString()){
      if (!mounted) {
        return;
      }
      try{
        setState(() {
          appliance_list = a_list;
          updateApplianceStatus();
          print("[RC DEBUG] LIST LOADED FROM PREFS: "+appliance_list.toString()+appliance_status.toString());
        });
      } on Exception catch (e){
        print("[RC ERR] "+e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(body: _buildApplianceList());
  }

  Widget _buildApplianceList() {
    loadList();
    return new ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        if (i.isOdd) return new Divider();
        final index = i ~/ 2;
        if (index==appliance_list.length) return new FlatButton(
          onPressed: () => addNewAppliance(),
          color: Colors.teal,
          child: new Padding(
            padding: new EdgeInsets.all(10.0),
            child: new Text(
              '+ Add New Appliance',
              style: new TextStyle(fontSize: 20, color: Colors.white,),
            ),
          )
        );
        if (index>appliance_list.length) return null;
        return _buildRow(index);
      },
    );
  }

  Widget _buildRow(int appliance_index) {
    //final alreadySaved = _saved.contains(pair);
    //final Map<String, dynamic> appliance = appliance_list[appliance_index];
    //print("[RC DEBUG] "+appliance_index.toString());
    //print("[RC DEBUG] "+appliance.toString());
    return new ListTile(
      title: new Text(
        appliance_list[appliance_index]['name'].toString()+" (#"+appliance_list[appliance_index]['id'].toString()+")",
        style: _biggerFont,
      ),
      trailing: new CupertinoSwitch(
        value: appliance_list[appliance_index]['status'],
        activeColor: Colors.cyan,
        onChanged: (bool value) {
          setState(() {
            appliance_list[appliance_index]['status'] = value;
            appliance_status[appliance_list[appliance_index]['id'].toString()] = appliance_list[appliance_index]['status']?'on':'off';
            controlAppliance();
          });
        },
      ),
      onTap: () {
        //appliance_list[appliance_index]['status'] = !appliance_list[appliance_index]['status'];
        //controlAppliance();
        /*
        setState(() {
          appliance_list[appliance_index]['status'] = !appliance_list[appliance_index]['status'];
          appliance_status[appliance_list[appliance_index]['id']] = appliance_list[appliance_index]['status']?'on':'off';
          controlAppliance();
        },);
        */
      },
      onLongPress: (){
        showDialog<void>(
          context: context,
          barrierDismissible: true, // user must tap button!
          builder: (BuildContext context) {
            return SimpleDialog(
              title: Text('Remove the appliance from list?'),
              children: <Widget>[
                new Padding(
                  padding: new EdgeInsets.fromLTRB(24.0, 5.0, 24.0, 5.0),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      new FlatButton(
                        color: Colors.blueGrey[50],
                        child: Text("Cancel", style: new TextStyle(fontSize: 18, color: Colors.blueGrey[600])),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      new FlatButton(
                        color: Colors.red[50],
                        child: Text("Remove", style: new TextStyle(fontSize: 18, color: Colors.red[600]),),
                        onPressed: () {
                          setState((){
                            appliance_list.removeAt(appliance_index);

                          });
                          saveList();
                          print("[RC Info] Item removed:"+appliance_index.toString());
                          //this.build(context);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  addNewAppliance() {
    var textTips = new TextStyle(fontSize: 22.0, color: Colors.black);
    var hintTips = new TextStyle(fontSize: 20.0, color: Colors.black26);
    var _idController = new TextEditingController();
    var _nameController = new TextEditingController();
    showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('New Appliance:'),
          children: <Widget>[
            new Padding(
              padding: new EdgeInsets.fromLTRB(24.0, 5.0, 24.0, 5.0),
              child: new TextField(
                style: hintTips,
                keyboardType: TextInputType.number,
                controller: _idController,
                decoration: new InputDecoration(hintText: "ID on RaspberryPi"),
                obscureText: false,
              ),
            ),
            new Padding(
              padding: new EdgeInsets.fromLTRB(24.0, 5.0, 24.0, 5.0),
              child: new TextField(
                style: hintTips,
                //keyboardType: TextInputType.number,
                controller: _nameController,
                decoration: new InputDecoration(hintText: "Appliance Name"),
                obscureText: false,
              ),
            ),
            new Padding(
              padding: new EdgeInsets.fromLTRB(24.0, 5.0, 24.0, 5.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  new FlatButton(
                    child: Text("Cancel", style: new TextStyle(fontSize: 18)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  new FlatButton(
                    child: Text("Add", style: new TextStyle(fontSize: 18),),
                    onPressed: () {
                      setState((){
                        appliance_list.add({'id':int.parse(_idController.text), 'name':_nameController.text, 'status':false});
                      });
                      saveList();
                      print("[RC Info] New item added:"+appliance_list[appliance_list.length-1].toString());
                      //this.build(context);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
  /*
  localPath() async {
    try {
      var tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;

      var appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;

      print('临时目录: ' + tempPath);
      print('文档目录: ' + appDocPath);
    }
    catch(err) {
      print(err);
    }
  }
  */
  /*
  localFile(path) async {
    return new File('$path/counter.json');
  }
  */
  /*
  writeJSON(obj) async {
    try {
      final file = await localFile(await localPath());
      return file.writeAsString(obj.toString());
    }
    catch (err) {
      print(err);
    }
  }
  */
}