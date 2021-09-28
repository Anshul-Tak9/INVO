import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photo_view/photo_view.dart';
class Profilepicview extends StatefulWidget {
  @override
  String user;

  Profilepicview(String s){
    user=s;
  }
  _ProfilepicviewState createState() => _ProfilepicviewState(user);
}

class _ProfilepicviewState extends State<Profilepicview> {
  @override
  String userUID;
  _ProfilepicviewState(String s){
    userUID=s;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white12,
      appBar: AppBar(
        backgroundColor: Colors.white12,
        leading: IconButton(icon : Icon(Icons.arrow_back),color: Colors.white,onPressed: (){Navigator.pop(context);},),
      ),
      body:
      Center(
        child : Container(
          color: Colors.black,
          child :StreamBuilder(
            stream: Firestore.instance.collection('users').document(userUID).snapshots(),
            builder: (context,snapshots) {
              if (!snapshots.hasData) {
                return CircularProgressIndicator();
              }
              else {
                return PhotoView(
                  imageProvider: NetworkImage(snapshots.data['ProfilePicURL'],
                  ),
                );
            }
            }
          ),
        )

      ),
    );
  }
}
