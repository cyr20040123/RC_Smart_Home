import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:google_sign_in/google_sign_in.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rxdart/rxdart.dart';
import 'package:firebase_storage/firebase_storage.dart';
//import 'auth.dart';

// reference for realtime database
// https://github.com/flutter/plugins/blob/master/packages/firebase_database/example/lib/main.dart

// reference for email sign in page


class AuthService{
  //final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  //final Firestore _db = Firestore.instance;

  Map<String,dynamic> userdata = {
    'uid': '',
    'email': '',
    'photoURL': '',
    'displayName': '',
    'lastSeen': ''
  };

  Observable<FirebaseUser> user;
  Observable<Map<String, dynamic>> profile;
  PublishSubject loading = PublishSubject();
  //Map<String, dynamic> userprofile =

  AuthService(){
    user = Observable(_auth.onAuthStateChanged);
    profile = user.switchMap((FirebaseUser u){
      if(u!=null){
        Map<String, dynamic> t;
        _db.reference().child('users'+u.uid).once().then((DataSnapshot snapshot) {
          t=snapshot.value;
          print("**DEBUG** RETURN Should be 1");
          profile = Observable.just(snapshot.value);
          return new Observable.just(snapshot.value);
        });
        print("**DEBUG** END Should be 2");
        return new Observable.just(t);
        //return _db.collection('users').document(u.uid).snapshots().map((snap) => snap.data);
      } else {
        return Observable.just({});
      }
    });
  }

  // CYR: The function below will be no longer used.
  /*
  Future<FirebaseUser> googleSignIn() async {
    loading.add(true);
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
    FirebaseUser user = await _auth.signInWithCredential(credential);
    /*FirebaseUser user = await _auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken
    );*/
    updateUserData(user);
    print("[RC Info] Google signed in: " + user.displayName);

    loading.add(false);
    return user;
  }
  */

  Future<FirebaseUser> emailSignIn(String Email, String PWord) async {
    print("User Sign In with email:" + Email + PWord);
    //FirebaseUser user = await _auth.signInWithEmailAndPassword(email: "test@test.com", password: "123456");
    FirebaseUser user = await _auth.signInWithEmailAndPassword(email: Email, password: PWord);
    loading.add(true);
    updateUserData(user);
    print("[RC Info] Email signed in: " + user.email);
    //print("[DEBUG] 00000000");
    //StorageReference ref = _storage.ref().child(auth.userdata['uid']).child('monitor_image').child("no_image.jpg");
    //print("[DEBUG] 11111111");
    loading.add(false);
    return user;
  }

  void updateUserData(FirebaseUser user) {
    DatabaseReference ref = _db.reference().child('users').child(user.uid);
    //DocumentReference ref = _db.collection('users').document(user.uid);

    String t = DateTime.now().toString();

    ref.update({
      //CYR MODIFY:
      'uid': user.uid,
      'email': user.email,
      'photoURL': user.photoUrl,
      'displayName': user.displayName,
      'lastSeen': t
    });

    userdata = {
      //CYR MODIFY:
      'uid': user.uid,
      'email': user.email,
      'photoURL': user.photoUrl,
      'displayName': user.displayName,
      'lastSeen': t
    };

    return;
  }

  void signOut() {
    print("[RC Info] User signed out.");
    _auth.signOut();
  }

}

final AuthService auth = AuthService();

class UserProfile extends StatefulWidget{
  @override
  UserProfileState createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile>{
  Map<String, dynamic> _profile;
  bool _loading = false;

  @override
  initState(){
    super.initState();
    auth.profile
        .listen((state)=>setState(()=> _profile = state));
    auth.loading
        .listen((state)=>setState(()=>_loading=state));
  }

  @override
  Widget build(BuildContext context){
    return Column(children:<Widget>[
      Container(
        padding: EdgeInsets.all(20),
        child: Text(_profile.toString())
      ),
      Text(_loading.toString())
    ]);
  }
}

