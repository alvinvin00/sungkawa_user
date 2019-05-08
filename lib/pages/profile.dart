import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  final String currentUserId;

  Profile({this.currentUserId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String username = '', email = '', userid = '';
  SharedPreferences prefs;
  FirebaseUser currentUser;
  bool isLoading;
  TextEditingController usernameController;
  TextEditingController emailController;

  var userRef;
  final FocusNode focusNodeUsername = new FocusNode();
  final FocusNode focusNodeEmail = new FocusNode();
  final formkey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readLocal();
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    userid = prefs.getString('userId') ?? '';
    username = prefs.getString('nama') ?? '';
    email = prefs.getString('email') ?? '';
    print('username $username');
    usernameController = new TextEditingController(text: username);
    emailController = new TextEditingController(text: email);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: 6.0, left: 14.0, right: 14.0),
        child: Form(
          key: formkey,
          child: Column(
            children: <Widget>[
              Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  defaultColumnWidth: IntrinsicColumnWidth(),
                  columnWidths: {
                    2: FlexColumnWidth(1.0)
                  },
                  children: [
                    TableRow(children: [
                      Text(
                        'Nama : ',
                        style: TextStyle(fontSize: 20.0),
                      ),
                      TextField(
                        decoration:
                        InputDecoration(hintText: 'Usename harus diisi'),
                        controller: usernameController,
                        onChanged: (value) => username = value,
                        focusNode: focusNodeUsername,
                      ),
                    ]),
                    TableRow(children: [
                      Text(
                        'Email :',
                        style: TextStyle(fontSize: 20.0),
                      ),
                      TextField(
                        controller: emailController,
                        onChanged: (value) => email = value,
                        focusNode: focusNodeEmail,
                        enabled: false,
                      ),
                    ])
                  ]),
              SizedBox(
                height: 50.0,
              ),
              CupertinoButton(
                onPressed: handleUpdateData,
                child: Text(
                  'Update Profil',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w300),
                ),
                color: Colors.blue[700],
              )
            ],
          ),
        ),
      ),
    );
  }

  void handleUpdateData() {
    focusNodeUsername.unfocus();
    focusNodeEmail.unfocus();
    setState(() {
      isLoading = true;
    });

    Firestore.instance
        .collection('users')
        .document(userid)
        .updateData({'nama': username, 'email': email}).then((data) async {
      await prefs.setString('nama', username);
      await prefs.setString('email', email);

      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: "Update success");
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: err.toString());
    });
  }
}
