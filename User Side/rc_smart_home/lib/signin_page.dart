import 'package:flutter/material.dart';
import 'package:rc_smart_home/firebase_signin.dart';
import 'package:flutter/services.dart';

class SigninPage extends StatelessWidget {
  var leftRightPadding = 30.0;
  var topBottomPadding = 4.0;
  var textTips = new TextStyle(fontSize: 22.0, color: Colors.black);
  var hintTips = new TextStyle(fontSize: 20.0, color: Colors.black26);
  var _userPWordController = new TextEditingController();
  var _userEmailController = new TextEditingController();

  void callSignIn(BuildContext context) async{
    try {
      await auth.emailSignIn(
          _userEmailController.text, _userPWordController.text);
    } on PlatformException catch (e){
      print("Error cought in login.");
      showDialog<void>(
        context: context,
        barrierDismissible: true, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Error in login:'),
                  Text(e.message.toString()),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.display1;
    return new Card(
      color: Colors.white,
      child: new SingleChildScrollView(
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[//CYR
            new StreamBuilder(
                stream: auth.user,
                builder:(context,snapshot){
                  if(snapshot.hasData){
                    return Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new Padding(
                          padding: new EdgeInsets.fromLTRB(
                              leftRightPadding, 50.0, leftRightPadding, 10.0),
                          child: new Icon(Icons.phonelink, size: 100.0, color: textStyle.color),
                        ),
                        new Padding(
                          padding: new EdgeInsets.fromLTRB(
                              leftRightPadding, 50.0, leftRightPadding, topBottomPadding),
                          child: new Text(auth.userdata['email'],style: new TextStyle(fontSize: 25),),
                        ),
                        new Container(
                          width: 360.0,
                          margin: new EdgeInsets.fromLTRB(10.0, 40.0, 10.0, 0.0),
                          padding: new EdgeInsets.fromLTRB(leftRightPadding,
                              topBottomPadding, leftRightPadding, topBottomPadding),
                          child: new Card(
                            color: textStyle.color,
                            elevation: 6.0,
                            child: new FlatButton(
                                onPressed: () => auth.signOut(),
                                child: new Padding(
                                  padding: new EdgeInsets.all(10.0),
                                  child: new Text(
                                    'Sign out',
                                    style:
                                    new TextStyle(color: Colors.white, fontSize: 16.0),
                                  ),
                                )),
                          ),
                        )
                      ],
                    );
                  } else {
                    return Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new Padding(
                          padding: new EdgeInsets.fromLTRB(
                              leftRightPadding, 50.0, leftRightPadding, 10.0),
                          child: new Icon(Icons.phonelink, size: 100.0, color: textStyle.color),
                        ),
                        new Padding(
                          padding: new EdgeInsets.fromLTRB(
                              leftRightPadding, 50.0, leftRightPadding, topBottomPadding),
                          child: new TextField(
                            style: hintTips,
                            controller: _userEmailController,
                            decoration: new InputDecoration(hintText: "Please input the login email."),
                            obscureText: false,
                          ),
                        ),
                        new Padding(
                          padding: new EdgeInsets.fromLTRB(
                              leftRightPadding, 30.0, leftRightPadding, topBottomPadding),
                          child: new TextField(
                            style: hintTips,
                            controller: _userPWordController,
                            decoration: new InputDecoration(hintText: "Please input your password."),
                            obscureText: true,
                          ),
                        ),
                        new Container(
                          width: 360.0,
                          margin: new EdgeInsets.fromLTRB(10.0, 40.0, 10.0, 0.0),
                          padding: new EdgeInsets.fromLTRB(leftRightPadding,
                              topBottomPadding, leftRightPadding, topBottomPadding),
                          child: new Card(
                            color: textStyle.color,
                            elevation: 6.0,
                            child: new FlatButton(
                                onPressed: () => callSignIn(context),
                                child: new Padding(
                                  padding: new EdgeInsets.all(10.0),
                                  child: new Text(
                                    'Sign in with Email',
                                    style:
                                    new TextStyle(color: Colors.white, fontSize: 16.0),
                                  ),
                                )),
                          ),
                        )
                      ],
                    );
                  }
                }),
            //
            /*
            new Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Padding(
                  padding: new EdgeInsets.fromLTRB(
                      leftRightPadding, 50.0, leftRightPadding, 10.0),
                  child: new Icon(Icons.phonelink, size: 100.0, color: textStyle.color),
                ),
                new Padding(
                  padding: new EdgeInsets.fromLTRB(
                      leftRightPadding, 50.0, leftRightPadding, topBottomPadding),
                  child: new TextField(
                    style: hintTips,
                    controller: _userEmailController,
                    decoration: new InputDecoration(hintText: "Please input the login email."),
                    obscureText: false,
                  ),
                ),
                new Padding(
                  padding: new EdgeInsets.fromLTRB(
                      leftRightPadding, 30.0, leftRightPadding, topBottomPadding),
                  child: new TextField(
                    style: hintTips,
                    controller: _userPWordController,
                    decoration: new InputDecoration(hintText: "Please input your password."),
                    obscureText: true,
                  ),
                ),
                new Container(
                  width: 360.0,
                  margin: new EdgeInsets.fromLTRB(10.0, 40.0, 10.0, 0.0),
                  padding: new EdgeInsets.fromLTRB(leftRightPadding,
                      topBottomPadding, leftRightPadding, topBottomPadding),
                  child: new Card(
                    color: textStyle.color,
                    elevation: 6.0,
                    child: StreamBuilder(
                        stream: authService.user,
                        builder:(context,snapshot){
                          if(snapshot.hasData){
                            return MaterialButton(
                                onPressed: () => authService.signOut(),
                                child: new Padding(
                                  padding: new EdgeInsets.all(10.0),
                                  child: new Text(
                                    'Sign out',
                                    style:
                                    new TextStyle(color: Colors.white, fontSize: 16.0),
                                  ),
                                )
                            );
                          } else {
                            return FlatButton(
                                onPressed: () => callSignIn(context),
                                child: new Padding(
                                  padding: new EdgeInsets.all(10.0),
                                  child: new Text(
                                    'Sign in with Email',
                                    style:
                                    new TextStyle(color: Colors.white, fontSize: 16.0),
                                  ),
                                ));
                          }
                        }
                    ),
                  ),
                )
              ],
            )
            */
          ],

        ),
      ),
    );
  }
}
