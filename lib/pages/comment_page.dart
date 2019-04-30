import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sung_user/model/user.dart';
import 'package:sung_user/model/comment.dart';
import 'package:sung_user/main.dart';

class CommentScreen extends StatefulWidget {
  final String commentId;
  final String username;
  final String email;

  const CommentScreen({this.commentId, this.username, this.email});

  @override
  _CommentScreenState createState() => new _CommentScreenState(
      commentId: this.commentId, username: this.username, email: this.email);
}

class _CommentScreenState extends State<CommentScreen> {
  final String commentId;
  final String username;
  final String email;

  final TextEditingController _commentController = new TextEditingController();

  _CommentScreenState({this.commentId, this.username, this.email});

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          "Ucapan Belasungkawa",
          style: new TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.blue,
      ),
      body: buildPage(),
    );
  }

  Widget buildPage() {
    return new Column(
      children: [
        new Expanded(
          child: buildComments(),
        ),
        new Divider(),
        new ListTile(
          title: new TextFormField(
            controller: _commentController,
            decoration:
                new InputDecoration(hintText: 'Tulis Ucapan Belasungkawa...'),
            onFieldSubmitted: addComment,
          ),
          trailing: new OutlineButton(
            onPressed: () {
              addComment(_commentController.text);
            },
            borderSide: BorderSide.none,
            child: new Text("Post"),
          ),
        ),
      ],
    );
  }

  Widget buildComments() {
    return new FutureBuilder<List<Comment>>(
        future: getComments(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return new Container(
                alignment: FractionalOffset.center,
                child: new CircularProgressIndicator());

          return new ListView(
            children: snapshot.data,
          );
        });
  }

  Future<List<Comment>> getComments() async {
    List<Comment> comments = [];

    QuerySnapshot data = await Firestore.instance
        .collection("messages")
        .document(commentId)
        .collection("comments")
        .getDocuments();
    data.documents.forEach((DocumentSnapshot doc) {
      comments.add(new Comment.fromDocument(doc));
    });

    return comments;
  }

  addComment(String comment) {
    _commentController.clear();
    Firestore.instance
        .collection("messages")
        .document(commentId)
        .collection("comments")
        .add({
      'username': currentCommentModel.nama,
      "email": currentCommentModel.email,
      "userid": currentCommentModel.uid,
      "comment": comment,
      'timestamp': new DateTime.now().toUtc()
    });

    //adds to postOwner's activity feed
//    Firestore.instance
//        .collection("insta_a_feed")
//        .document(username)
//        .collection("items")
//        .add({
//      "username": currentUserModel.username,
//      "userId": currentUserModel.id,
//      "type": "comment",
//      "userProfileImg": currentUserModel.photoUrl,
//      "commentData": comment,
//      "timestamp": new DateTime.now().toString(),
//      "postId": commentId,
//      "mediaUrl": email,
//    });
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String comment;
  final String timestamp;
  final String email;

  Comment({this.username, this.userId, this.comment, this.timestamp, this.email});

  factory Comment.fromDocument(DocumentSnapshot document) {
    return new Comment(
      username: document['username'],
      email: document['email'],
      userId: document['userid'],
      comment: document["comment"],
      timestamp: document["timestamp"],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new ListTile(
          title: new Text(username),
          subtitle: new Text(comment),
//          leading: new CircleAvatar(
//            backgroundImage: new NetworkImage(avatarUrl),
//          ),
        ),
        new Divider(),
      ],
    );
  }
}
