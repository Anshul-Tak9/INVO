import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class Followers extends StatefulWidget {
  String user;
  Followers(String use){
    user=use;
  }
  @override
  _FollowersState createState() => _FollowersState(user);
}

class _FollowersState extends State<Followers> {
  String userUID;
  _FollowersState(String use){
    userUID=use;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.white12,
        leading: IconButton(icon:Icon(Icons.arrow_back,),onPressed: (){Navigator.pop(context,true);},),
        title: Text('Followers',style: TextStyle(color: Colors.white),),
      ),
      body: StreamBuilder(
          stream: Firestore.instance.collection('users').document(userUID).collection('Followers').snapshots(),
          builder: (context,snapshots) {
            if (!snapshots.hasData) {
              return CircularProgressIndicator();
            }
            else {
              print(snapshots.data.documents.length);
              return ListView.builder(itemCount: snapshots.data.documents.length,
                  itemBuilder: (BuildContext context, int index) {
                    String uid = snapshots.data.documents[index]['UID'];
                    return StreamBuilder(
                        stream: Firestore.instance.collection('users').document(uid).snapshots(),
                        builder: (context,snapshots){
                          if (!snapshots.hasData) {
                            return CircularProgressIndicator();
                          }
                          else{
                            return GestureDetector(
                              onTap: (){print('pressed');},
                              child: ListTile(
                                contentPadding: EdgeInsets.only(left: 10,top: 20),
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(
                                      '${snapshots.data['ProfilePicURL']}'),
                                ),
                                title: Text(snapshots.data['Username'],style: TextStyle(color: Colors.white,letterSpacing: 1.0,fontSize: 17,fontWeight: FontWeight.bold),),
                                subtitle: Text(snapshots.data['Name'],style: TextStyle(color: Colors.white,letterSpacing: 1.0)),
                              ),
                            );
                          }
                        }
                    );
                  });
            }
          }
      )
      //child: ListView.builder(itemCount: ,itemBuilder: null)),
    );
  }

}
