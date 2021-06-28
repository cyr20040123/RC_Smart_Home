import 'dart:async';
import 'dart:ui' as ui;

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:rc_smart_home/firebase_signin.dart';

class OverviewCard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OverviewState();
}

class _OverviewState extends State<OverviewCard>{
  String _temperature;
  String _time;
  String _humidity;

  DatabaseReference _temperatureRef;
  DatabaseReference _timeRef;
  DatabaseReference _humidityRef;

  StreamSubscription<Event> _temperatureSubscription;
  StreamSubscription<Event> _timeSubscription;
  StreamSubscription<Event> _humiditySubscription;
  //bool _anchorToBottom = false;

  //String _kTestKey = 'Hello';
  //String _kTestValue = 'world!';
  DatabaseError _error;


  //String temperature, humidity;
  //bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Demonstrates configuring to the database using a file
    _temperatureRef = FirebaseDatabase.instance.reference().child('communication/'+auth.userdata['uid']+'/temperature');
    _humidityRef = FirebaseDatabase.instance.reference().child('communication/'+auth.userdata['uid']+'/humidity');
    _timeRef = FirebaseDatabase.instance.reference().child('communication/'+auth.userdata['uid']+'/time');
    _temperatureRef.keepSynced(true);
    _humidityRef.keepSynced(true);
    _timeRef.keepSynced(true);
    _temperatureSubscription = _temperatureRef.onValue.listen((Event event) {
      setState(() {
        _error = null;
        _temperature = event.snapshot.value.toString() ?? 'N/A';
      });
    }, onError: (Object o) {
      final DatabaseError error = o;
      setState(() {
        _error = error;
      });
    });

    _humiditySubscription = _humidityRef.onValue.listen((Event event) {
      setState(() {
        _error = null;
        _humidity = event.snapshot.value.toString() ?? 'N/A';
      });
    }, onError: (Object o) {
      final DatabaseError error = o;
      setState(() {
        _error = error;
      });
    });

    _timeSubscription = _timeRef.onValue.listen((Event event) {
      setState(() {
        _error = null;
        _time = event.snapshot.value ?? 'N/A';
      });
    }, onError: (Object o) {
      final DatabaseError error = o;
      setState(() {
        _error = error;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _temperatureSubscription.cancel();
    _humiditySubscription.cancel();
    _timeSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.display1;
    return new Card(
      color: tempColor(_temperature)[50],
      child: new Center(
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Column(
              children: <Widget>[
                new Padding(
                  padding: new EdgeInsets.fromLTRB(
                      10.0, 30.0, 10.0, 0.0),
                    child: new Text(
                        "Temperature @ Home",
                        textAlign: TextAlign.left,
                        style: new TextStyle(
                          color: textStyle.color,
                          fontSize: 25,
                        )
                    )
                ),
                new Padding(
                  padding: new EdgeInsets.fromLTRB(
                      0.0, 10.0, 0.0, 0.0),
                  child: new ShadowText(
                    _error == null ? _temperature.toString()+"℃" : "Err",
                    //textAlign: TextAlign.center,
                    style: new TextStyle(
                      color: tempColor(_temperature),
                      fontSize: 120,
                    ),
                  ),
                ),
                new Text(
                  "Last update @ " + (_error == null ? _time.toString() : "Err"),
                  style: new TextStyle(
                    color: textStyle.color,
                    fontSize: 14,
                  ),
                ),
                new Padding(
                  padding: new EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 20.0),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Column(
                        children: <Widget>[
                          new ShadowText(
                            (_error == null ? _humidity.toString()+"%" : "Err"),
                            style: new TextStyle(
                              fontSize: 60,
                              color: Colors.grey[800],
                            )
                          ),
                          new Text(
                              "Humidity",
                              style: new TextStyle(
                                fontSize: 25,
                                color: textStyle.color,
                              )
                          ),
                        ],
                      ),
                      new Padding(padding: new EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 0.0)),
                      new Column(
                        children: <Widget>[
                          new Icon(tempFace(_temperature.toString(), _humidity.toString()), size: 70.0, color: Colors.grey[800]),
                          new Text(
                              "Overall",
                              style: new TextStyle(
                                fontSize: 25,
                                color: textStyle.color,
                              )
                          ),
                        ],
                      ),
                    ]
                  )
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}

IconData tempFace(String temp, String humi) {
  if (temp==null || humi==null) return Icons.sentiment_neutral;
  int score = 6, humidity;
  try{
    humidity=int.parse(humi);
  } on Exception{
    print("[RC ERR] Error in humidity processing: "+humi.toString());
    humidity=66;
  }
  if(tempColor(temp)==Colors.amber || tempColor(temp)==Colors.blue) score-=2;
  if(tempColor(temp)==Colors.deepOrange || tempColor(temp)==Colors.indigo) score-=4;
  if(humidity<45 && humidity>=30) score-=0;
  if(humidity<=75 && humidity>65) score-=0;
  if(humidity<30 || humidity>75) score-=1;
  switch(score){
    case 2:
      return Icons.sentiment_dissatisfied;
      break;
    case 3:
      return Icons.sentiment_neutral;
      break;
    case 4:
      return Icons.sentiment_satisfied;
      break;
    case 5:
    case 6:
      return Icons.sentiment_very_satisfied;
      break;
    default:
      return Icons.sentiment_very_dissatisfied;
  }
}

tempColor(String temp) {
  if (temp==null) return Colors.grey;
  int t;
  try{
    t=int.parse(temp);
  } on Exception{
    return Colors.grey;
  }
  if(t>32) return Colors.deepOrange;
  if(t>27) return Colors.amber;
  if(t>22) return Colors.lime;
  if(t>15) return Colors.teal;
  if(t>8) return Colors.blue;
  return Colors.indigo;
}

class ShadowText extends StatelessWidget {
  ShadowText(this.data, { this.style }) : assert(data != null);

  final String data;
  final TextStyle style;

  Widget build(BuildContext context) {
    return new ClipRect(
      child: new Stack(
        children: [
          new Positioned(
            top: 2.0,
            left: 2.0,
            child: new Text(
              data,
              style: style.copyWith(color: Colors.black.withOpacity(0.5)),
            ),
          ),
          new BackdropFilter(
            filter: new ui.ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
            child: new Text(data, style: style),
          ),
        ],
      ),
    );
  }
}