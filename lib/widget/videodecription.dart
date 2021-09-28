//import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VideoDescription extends StatelessWidget {
  String user;
  String Video;
  int i;
  final db = Firestore.instance;
  VideoDescription(String use,int k) {
    user = use;
    i=k;
  }
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 70,
        padding: EdgeInsets.only(left: 20,bottom: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            StreamBuilder(
                stream:
                    db.collection('users').document(user).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.none ||
                      snapshot.connectionState == ConnectionState.none) {
                    return Text("Loading...",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold));
                  }
                  if (!snapshot.hasData) {
                    return Text("Loading...",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold));
                  } else {
                    return snapshot.data['Username']==null?Center(child: CircularProgressIndicator()):Column(children: <Widget>[
                      Text(snapshot.data['Username'],
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,letterSpacing: 2.0)),
                    ]);
                  }
                }),
            //Text('${getUsername()}',style :TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 17)),


            StreamBuilder(
            stream:
            db.collection('users').document(user).collection('Videos').document('${i}').snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
            return Text("Loading...",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold));
      }
      else {
            return Row(
              children: <Widget>[
                snapshot.data['MusicName']==null?Container():Icon(
                  Icons.music_note,
                  size: 15,
                  color: Colors.white,
                ),
                Text(
                  snapshot.data['MusicName']==null?'':snapshot.data['MusicName'],
                  style: TextStyle(fontSize: 16, color: Colors.white,letterSpacing: 1.0),),
              ],
            );
      }
    }
    ),
          ],
        ),
      ),
    );
  }
}
