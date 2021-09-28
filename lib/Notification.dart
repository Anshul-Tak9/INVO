import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/SearchResult/SearchResults.dart';
import 'package:myapp/widget/ImageView.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:myapp/widget/Videoshow.dart';
class Notifications extends StatefulWidget {
  static FirebaseUser user;
  Notifications(FirebaseUser use){
    user=use;
  }
  @override
  _NotificationsState createState() => _NotificationsState(user);
}
class _NotificationsState extends State<Notifications> {
  static FirebaseUser user;
  _NotificationsState(FirebaseUser use){
    user=use;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 10,
        leading: Container(),
        backgroundColor: Colors.white,
        title: Text('Notification',style: TextStyle(color: Colors.black),),
      ),

      body: StreamBuilder(
          stream: Firestore.instance.collection('users').document('${user.uid}').collection('Notification').orderBy('Time',descending: true).snapshots(),
          builder: (context,snapshots) {
            if (!snapshots.hasData) {
              return CircularProgressIndicator();
            }
            else {
              return ListView.builder(itemCount: snapshots.data.documents.length,
                  itemBuilder: (BuildContext context, int index) {
                    String uid = snapshots.data.documents[index]['UID'];
                    String type = snapshots.data.documents[index]['type'];
                    String fileurl = snapshots.data.documents[index]['ImageURL'];
                    String VideoURL = snapshots.data.documents[index]['VideoURL'];
                    int ind=snapshots.data.documents[index]['Image'];
                    bool k=snapshots.data.documents[index]['Image']==null?false:true;
                    print(snapshots.data.documents.length);
                    return StreamBuilder(
                        stream: Firestore.instance.collection('users').document(uid).snapshots(),
                      builder: (context,snapshots){
                        if (!snapshots.hasData) {
                          return CircularProgressIndicator();
                        }
                        else{
                          return k==false? Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: (){Navigator.push(context,new MaterialPageRoute(builder: (context)=>SearchResults(user.uid,uid)));},
                                child: ListTile(
                                  contentPadding: EdgeInsets.only(left: 10,top: 20),
                                  leading: CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage(
                                        '${snapshots.data['ProfilePicURL']}'),
                                  ),
                                  title: Text(snapshots.data['Username'],style: TextStyle(color: Colors.black,letterSpacing: 1.0,fontSize: 17,fontWeight: FontWeight.bold),),
                                  subtitle: Text(snapshots.data['Name']+" "+type,style: TextStyle(color: Colors.black,letterSpacing: 1.0)),
                                ),
                              ),
                              Divider(color: Colors.white,),
                            ],
                          ):
                          Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: (){Navigator.push(context,new MaterialPageRoute(builder: (context)=>VideoShow(user.uid,VideoURL,ind,'Videos',fileurl)));},
                                child: ListTile(
                                  contentPadding: EdgeInsets.only(left: 10,top: 20),
                                  leading: CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage(
                                        '${snapshots.data['ProfilePicURL']}'),
                                  ),
                                  title: Text(snapshots.data['Username'],style: TextStyle(color: Colors.black,letterSpacing: 1.0,fontSize: 17,fontWeight: FontWeight.bold),),
                                  subtitle: Text(snapshots.data['Name']+" "+type,style: TextStyle(color: Colors.black,letterSpacing: 1.0)),
                                  trailing: Container(
                                    height: 60,width: 60,margin: EdgeInsets.only(right: 20),
                                    child: CachedNetworkImage(
                                       imageUrl: fileurl,
                                       placeholder: (context,url)=>Shimmer.fromColors(child: Container(height: 50,width: 50), baseColor: Colors.white, highlightColor: Colors.white),
                                       errorWidget: (context,url,error)=>new Icon(Icons.error,color: Colors.white,),
                                    ),
                                  ),
                                ),
                              ),
                              Divider(color: Colors.white,),
                            ],
                          );
                        }
                      }
                    );
                  });
            }
          }
      ),
          //child: ListView.builder(itemCount: ,itemBuilder: null)),
    );
  }
}