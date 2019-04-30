//import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sung_user/pages/profil.dart';
import 'dart:async';

//class Login extends StatelessWidget {
//
//  final FirebaseAuth _auth = FirebaseAuth.instance;
//  final GoogleSignIn googleSignIn = GoogleSignIn();
//  bool isLoading;
//
////  Future<FirebaseUser> _handleSignIn(context)  async {
////    var datauser = FirebaseDatabase.instance.reference().child('users');
////
////    final GoogleSignInAccount googleUser = await googleSignIn.signIn();
////    final GoogleSignInAuthentication gSA = await googleUser.authentication;
////    final AuthCredential credential = GoogleAuthProvider.getCredential(
////      idToken: gSA.idToken,
////      accessToken: gSA.accessToken,
////    );
////    final FirebaseUser user = await _auth.signInWithCredential(credential);
////    print("Signed In " + user.displayName);
////
////    try {
////      print('Mencoba Login......................................');
////      datauser.push().set(({
////        'UserId': user.uid,
////        'nama': user.displayName,
////        'Email': user.email
////      })).whenComplete((){
////        print('Login berhasil.........................................');
////        Navigator.push(context ,MaterialPageRoute(builder: (context)=>Profil()));
////      });
////    }catch(e){
////      print('error $e');
////      isLoading = false;
////    }
////
////    return user;
////  }
//
//  @override
//  Widget build(BuildContext context) {
//    return new Scaffold(
//      body: new Padding(
//        padding: const EdgeInsets.all(20.0),
//        child: new Column(
//          mainAxisAlignment: MainAxisAlignment.center,
//          crossAxisAlignment: CrossAxisAlignment.stretch,
//          children: <Widget>[
//            new Text('Sungkawa', style: TextStyle(fontSize: 40.0),
//              textAlign: TextAlign.center,),
//            CupertinoButton(
//                child: Text(
//                  "Sign In with Google",
//                  style: new TextStyle(color: Colors.white),
//                ),
//                color: Colors.blue,
//                onPressed: () {
//                  _handleSignIn(context);
////                  Navigator.pop(context,MaterialPageRoute(builder: ));
////                      .then((FirebaseUser user) => print(user))
////                      .catchError((e) => print('Error: $e'))
////                      .whenComplete(() {
////                    Navigator.push(
////                        context,
////                        MaterialPageRoute(builder: (context) => Profil()));
////                  });
//                }),
//
//            new Padding(padding: const EdgeInsets.all(10.0)),
//          ],
//        ),
//      ),
//    );
//  }
//}

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences prefs;
  bool isLoading = false;
  bool isLoggedin = false;
  FirebaseUser currentUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isSignedIn();
  }

  void isSignedIn() async {
    this.setState(() {
      isLoading = true;
    });
    prefs = await SharedPreferences.getInstance();

    isLoggedin = await googleSignIn.isSignedIn();
    if (isLoggedin) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Profil()));
    }
    this.setState(() {
      isLoading = false;
    });
  }

  Future<Null> handleSignIn() async {
    prefs = await SharedPreferences.getInstance();
    this.setState(() {
      isLoading = true;
    });
    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    FirebaseUser firebaseUser =
        await firebaseAuth.signInWithCredential(credential);
    if (firebaseUser != null) {
      final QuerySnapshot result = await Firestore.instance
          .collection('users')
          .where('id', isEqualTo: firebaseUser.uid)
          .getDocuments();
      final List<DocumentSnapshot> documents = result.documents;

      if (documents.length == 0) {
        Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .setData({
          'nama': firebaseUser.displayName,
          'email': firebaseUser.email,
          'userId': firebaseUser.uid
        });
        currentUser = firebaseUser;

        await prefs.setString('userId', currentUser.uid);
        await prefs.setString('nama', currentUser.displayName);
        await prefs.setString('email', currentUser.email);
      } else {
        await prefs.setString('userId', currentUser.uid);
        await prefs.setString('nama', currentUser.displayName);
        await prefs.setString('email', currentUser.email);
      }
      SnackBar(
        content: Text('Login berhasil'),
        duration: Duration(seconds: 2),
      );
      this.setState(() {
        isLoading = false;
      });
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Profil(currentUserId: firebaseUser.uid)));
    } else {
      SnackBar(
        content: Text('Login gagal'),
        duration: Duration(seconds: 2),
      );
      this.setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: new Padding(
        padding: const EdgeInsets.all(20.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Text(
              'Sungkawa',
              style: TextStyle(fontSize: 40.0),
              textAlign: TextAlign.center,
            ),
            CupertinoButton(
                child: Text(
                  "Sign In with Google",
                  style: new TextStyle(color: Colors.white),
                ),
                color: Colors.blue,
                onPressed: () {
                  handleSignIn();
                }),
            new Padding(padding: const EdgeInsets.all(10.0)),
          ],
        ),
      ),
    );
  }
}
