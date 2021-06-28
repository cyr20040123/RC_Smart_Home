// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:rc_smart_home/appliance_page.dart';
import 'package:rc_smart_home/firebase_signin.dart';
import 'package:rc_smart_home/monitor_page.dart';
import 'package:rc_smart_home/overview_page.dart';
import 'package:rc_smart_home/signin_page.dart';
//import 'package:flutter_firebase_ui/flutter_firebase_ui.dart';
//import 'package:google_sign_in/google_sign_in.dart';
//import 'package:firebase_auth/firebase_auth.dart';

class TabbedAppBarSample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //auth.signOut();
    return new MaterialApp(
      home: new DefaultTabController(
        length: choices.length,
        child: new Scaffold(
          appBar: new AppBar(
            title: const Text('RC Smart Home'),
            bottom: new TabBar(
              isScrollable: true,
              tabs: choices.map((Choice choice) {
                return new Tab(
                  text: choice.title,
                  icon: new Icon(choice.icon),
                );
              }).toList(),
            ),
          ),
          body: new TabBarView(
            children: [
              new Padding(
                padding: const EdgeInsets.all(16.0),
                child: OverviewCard(),
              ),
              new Padding(
                padding: const EdgeInsets.all(16.0),
                child: ApplianceCard(),
              ),
              new Padding(
                padding: const EdgeInsets.all(16.0),
                child: new MonitorCard(),//new ChoiceCard(choice: choices[2]),
              ),
              new Padding(
                padding: const EdgeInsets.all(16.0),
                child: SigninPage(),
              )
            ]
            /*choices.map((Choice choice) {
              return new Padding(
                padding: const EdgeInsets.all(16.0),
                child: new ChoiceCard(choice: choice),
              );
            }).toList(),*/
          ),
        ),
      ),
    );
  }
}

class Choice {
  const Choice({ this.title, this.icon });
  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'OVERVIEW', icon: Icons.featured_play_list),
  const Choice(title: 'APPLIANCES', icon: Icons.settings_remote),
  const Choice(title: 'MONITOR', icon: Icons.linked_camera),
  const Choice(title: 'PROFILE', icon: Icons.person),
  //const Choice(title: 'TRAIN', icon: Icons.directions_railway),
  //const Choice(title: 'WALK', icon: Icons.directions_walk),
];

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({ Key key, this.choice }) : super(key: key);

  final Choice choice;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.display1;
    return new Card(
      color: Colors.white,
      child: new Center(
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Icon(choice.icon, size: 128.0, color: textStyle.color),
            new Text(choice.title, style: textStyle),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(new TabbedAppBarSample());
}