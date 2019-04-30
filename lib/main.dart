import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sung_user/model/comment.dart';
import 'package:sung_user/pages/about.dart';
import 'package:sung_user/pages/user_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sung_user/pages/login.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:sung_user/pages/profil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sung_user/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
}

enum Pilihan { about, signOut, profil }

final GoogleSignIn googleSignIn = GoogleSignIn();
User currentCommentModel;
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SUNGKAWA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          pageTransitionsTheme: PageTransitionsTheme(builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          })),
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

enum AuthStatus { signedIn, notSignedIn }

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  FirebaseUser currentUser;
  SharedPreferences prefs;
  bool isLoading;
  BuildContext _snackBarContext;
  AuthStatus _authStatus = AuthStatus.notSignedIn;
  var connectionStatus;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkConnectivity();
    getCurrentUser().then((userId) {
      setState(() {
        _authStatus =
            userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
      });
    });
  }

  Future<String> getCurrentUser() async {
    try {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      return user != null ? user.uid : null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Sungkawa',
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
//          PopupMenuButton(
//              onSelected: selectedAction,
//              itemBuilder: (BuildContext context) => <PopupMenuEntry<Pilihan>>[
//                    const PopupMenuItem(
//                      child: Text('Tentang Kami'),
//                      value: Pilihan.about,
//                    ),
//                    const PopupMenuItem(
//                      child: Text('SignOut'),
//                      value: Pilihan.signOut,
//                    ),
//                    const PopupMenuItem(
//                      child: Text('Profil'),
//                      value: Pilihan.profil,
//                    )
//                  ])
//          CupertinoActionSheet(
//              title: const Text('Pilihan menu'),
//              actions: <Widget>[
//                CupertinoActionSheetAction(
//                    onPressed: () {
//                      Navigator.push(context,
//                          MaterialPageRoute(builder: (context) => About()));
//                    },
//                    child: Text('Tentang Kami')),
//                CupertinoActionSheetAction(
//                    onPressed: signOut, child: Text('SignOut')),
//                CupertinoActionSheetAction(
//                  onPressed: () {
//                    Navigator.push(context,
//                        MaterialPageRoute(builder: (context) => Profil()));
//                  },
//                  child: Text('Profil'),
//                )
//              ],
//              cancelButton: CupertinoActionSheetAction(
//                  onPressed: () {
//                    Navigator.pop(context);
//                  },
//                  child: Text('Cancel')))
        ],
        backgroundColor: Colors.lightBlue,
      ),
      body: HomePage(),
    bottomNavigationBar: SwipeDetector(
            onSwipeUp: () {
              showCupertinoModalPopup(
                  context: context,
                  builder: (context) => CupertinoActionSheet(
                      title: const Text('Pilihan menu'),
                      actions: <Widget>[
                        CupertinoActionSheetAction(
                          onPressed: (){
                            handleSignIn();
                          },
                          child: Text('Profil'),
                        ),
                        CupertinoActionSheetAction(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => About()));
                            },
                            child: Text('Tentang Kami')),
                        CupertinoActionSheetAction(
                            onPressed: signOut, child: Text('SignOut')),
                      ],
                      cancelButton: CupertinoActionSheetAction(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Cancel',style: TextStyle(color: Colors.red),))));
            },
            child: BottomAppBar(
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Info Aplikasi',style: TextStyle(fontSize: 28.0),)
                ],
              ),
            ),
          ),
    );
  }

//  void selectedAction(Pilihan value) {
//    print('You choose : $value');
//    if (value == Pilihan.about) {
//      Navigator.push(context,
//          MaterialPageRoute(builder: (BuildContext context) => About()));
//    }
//    if (value == Pilihan.signOut) {
//      signOut();
//    }
//    if (value == Pilihan.profil) {
//      switch (_authStatus) {
//        case AuthStatus.notSignedIn:
//          Navigator.push(
//              context, MaterialPageRoute(builder: (context) => Login()));
//          break;
//        case AuthStatus.signedIn:
//          print('Profil dibuka');
//          Navigator.push(context,
//              MaterialPageRoute(builder: (BuildContext context) => Profil()));
//          break;
//      }
//    }
//  }

  void signOut() async {
    FirebaseAuth.instance.signOut();
    googleSignIn.signOut();
    _authStatus = AuthStatus.notSignedIn;
//    Scaffold.of(_snackBarContext).showSnackBar(SnackBar(content: Text("Signed Out"),
//    duration: Duration(seconds: 2),));
    SnackBar(
      content: Text('Signed Out'),
      duration: Duration(seconds: 2),
    );

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => DashboardScreen()));
  }

  void checkConnectivity() async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile) {
        print('Connectivity Result: $connectivityResult');
        connectionStatus = true;
      } else if (connectivityResult == ConnectivityResult.wifi) {
        print('Connectivity Result: $connectivityResult');
        connectionStatus = true;
      } else {
        print('Connectivity Result: not connected');
        connectionStatus = false;
      }
    } catch (e) {
      print('Error: $e');
    }
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
    await _auth.signInWithCredential(credential);
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
}
