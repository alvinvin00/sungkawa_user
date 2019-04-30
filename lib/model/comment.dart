import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  String username;
  String comment;
  String email;
  String uid;
  FieldValue timestamp;

  Comment({this.username, this.email,this.comment, this.uid, this.timestamp});

  Map toMap(Comment comment){
    var data = Map<String, dynamic>();
    data['username'] = comment.username;
    data['email'] = comment.email;
    data['userid'] = comment.uid;
    data['comment'] = comment.comment;
    data['timestamp']= comment.timestamp;

    return data;
  }

  Comment.fromMap(Map<String , dynamic> mapData){
    this.username = mapData['username'];
    this.email = mapData['email'];
    this.uid = mapData['userid'];
    this.comment = mapData['comment'];
    this.timestamp = mapData['timestamp'];
  }

}