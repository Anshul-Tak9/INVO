import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/widget/Followers.dart';
import 'package:myapp/widget/Followings.dart';
import 'package:myapp/widget/Videoshow.dart';
import 'package:myapp/widget/mepage.dart';
import 'package:myapp/widget/profilepicview.dart';
import 'package:shimmer/shimmer.dart';
class SearchResults extends StatefulWidget {
  String CurrentUserID;
  String SearchUserID;
  SearchResults(String c, String s) {
    CurrentUserID = c;
    SearchUserID = s;
  }
  @override
  _SearchResultsState createState() =>
      _SearchResultsState(CurrentUserID, SearchUserID);
}
class _SearchResultsState extends State<SearchResults> {
  String CurrentUserID;
  String SearchUserID;
  bool isfollower;
  bool isrequested;
  _SearchResultsState(String c, String s) {
    CurrentUserID = c;
    SearchUserID = s;
  }
  Future<void> checkfollower() async {
    print('k');
    String uid;
    await Firestore.instance.collection('users').document(CurrentUserID)
        .get()
        .then((value) {
      uid = value.data['UID'];
    });
    int followingcount;
    int followerscount;
    var following = await Firestore.instance.collection('users').document(SearchUserID).collection('Followings');
    await Firestore.instance.collection('users').document(SearchUserID).collection('Followers').getDocuments().then((value) =>followerscount=value.documents.length );
    await following.getDocuments().then((value) => followingcount =value.documents.length);
    if (followingcount == 0) {
      setState(() {
        isfollower = false;
      });
    }
    else {
      var result = await Firestore.instance.collection('users').document(
          SearchUserID).collection('Followings')
          .where('UID', isEqualTo: uid)
          .getDocuments();
      print('$result.documents.length'+'--------');
      if (result.documents.length == 0) {
        setState(() {
          isfollower = false;
        });
      }
      else {
        setState(() {
          isfollower = true;
        });
      }
    }
    if (followerscount == 0) {
      setState(() {
        isrequested = false;
      });
    }
    else {
      var result = await Firestore.instance.collection('users').document(
          SearchUserID).collection('Followers')
          .where('UID', isEqualTo: uid)
          .getDocuments();
      if (result.documents.length == 0) {
        setState(() {
          isrequested = false;
        });
      }
      else{
        setState(() {
          isrequested = true;
        });
      }
    }
    print(isrequested);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 10,
        leading: IconButton(icon: Icon(Icons.arrow_back,color: Colors.black,),onPressed: (){Navigator.pop(context,true);},),
        title: StreamBuilder(
            stream: Firestore.instance
                .collection('users')
                .document(SearchUserID)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Text("Loading...");
              } else {
                return Text(snapshot.data['Username'],
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.bold));
              }
            }),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 30),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // FollowAction(),
                StreamBuilder(
                    stream: Firestore.instance
                        .collection('users')
                        .document(SearchUserID)
                        .snapshots(),
                    builder: (context, snapshots) {
                      if (!snapshots.hasData) {
                        return CircularProgressIndicator();
                      } else {
                        return GestureDetector(
                          onTap: () {if(check()){Navigator.push(context, new MaterialPageRoute(
                              builder: (context) => Profilepicview(SearchUserID)));}},
                          child: CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.blue,
                            child: CircleAvatar(
                              radius: 52,
                              backgroundImage: NetworkImage(
                                  '${snapshots.data['ProfilePicURL']}'),
                            ),
                          ),
                        );
                      }
                    }),
                post(),
                followingss(),
                followers(),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              padding: EdgeInsets.only(left: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  StreamBuilder(
                      stream: Firestore.instance
                          .collection('users')
                          .document(SearchUserID)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Text("Loading...");
                        } else {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('${snapshot.data['Name']}',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 17)),
                              Text('${snapshot.data['bio']}',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 17)),
                            ],
                          );
                        }
                      }),
                ],
              ),
            ),
            Container(height: 30,),
            Divider(color: Colors.black,),
            following(),
          ],
        ),
      ),
    );
  }
  Widget data( String title,double d){
    return Column(
      children: [
        Text('$d',style: TextStyle(color: Colors.white,fontSize: 20),),
        Text(title,style : TextStyle(color: Colors.white,fontSize: 15)),
      ],
    );
  }
  Widget following(){
    checkfollower();
    if(isfollower==null||isrequested==null){
      return Center(child:CircularProgressIndicator());
    }
    else {
      return isfollower ? FollowBack() : Follow();
    }
  }
  Widget FollowBack() {
    if (isrequested == null) {
      return Center(child: CircularProgressIndicator(),);
    }
    else {
      return isrequested==false ?
      Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 20),
            child: RaisedButton(
              elevation: 5.0,
              onPressed: () {
                setState(() {
                  isrequested = true;
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Colors.blue,
              child: Text(
                'Follow Back',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'OpenSans'
                ),
              ),),
          ),
          accoutprivate(),
        ],
      ) : fullpage();
    }
  }
  Widget fullpage(){
    return  StreamBuilder(
        stream : Firestore.instance.collection('users').document(SearchUserID).collection('Videos').snapshots(),
        builder: (context,snapshots){
          // print('loading...');

          if(!snapshots.hasData){
            return Text('Nothing yet,Please wait...');
          }
          else{
            // print(snapshots.data.documents.length.toString());
            return GridView.builder(shrinkWrap:true,gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                padding: EdgeInsets.all(3),
                itemCount: int.parse(snapshots.data.documents.length.toString()),
                itemBuilder: (context,i) {
                  print('loading...');
                  return GestureDetector(
                    onTap: (){Navigator.push(context, new MaterialPageRoute(builder: (context)=>VideoShow(CurrentUserID,'${snapshots.data.documents[i]['VideoURL']}',i+1,'Videos','${snapshots.data.documents[i]['ImageURL']}')));},
                    child: Card(
                      elevation: 5,
                        shadowColor: Colors.black,
                        color : Colors.white12,
                        child : CachedNetworkImage(
                          imageUrl: '${snapshots.data.documents[i]['ImageURL']}',
                          placeholder: (context,url)=>Shimmer.fromColors(child: Container(height: 50,width: 50), baseColor: Colors.white, highlightColor: Colors.white),
                          errorWidget: (context,url,error)=>new Icon(Icons.error),
                          fit: BoxFit.cover,
                        ),
                    ),
                  );
                }
            );
          }
        }
    );/*DefaultTabController(
      length: 2,
      child : Column(
        children: <Widget>[
          TabBar(
            tabs: [
              Tab(icon : Icon(Icons.grid_on,color: Colors.white,)),
              Tab(icon : Icon(Icons.tag_faces,color : Colors.white)),
            ],
          ),
          SizedBox(
            height: 1000,
            child: TabBarView(
              children: <Widget>[
                StreamBuilder(
                    stream : Firestore.instance.collection('users').document(SearchUserID).collection('Images').snapshots(),
                    builder: (context,snapshots){
                      // print('loading...');

                      if(!snapshots.hasData){
                        return Text('Nothing yet,Please wait...');
                      }
                      else{
                        // print(snapshots.data.documents.length.toString());
                        return GridView.builder(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                            padding: EdgeInsets.all(3),
                            itemCount: int.parse(snapshots.data.documents.length.toString()),
                            itemBuilder: (context,i) {
                              print('loading...');
                              return GestureDetector(
                                onTap: (){},
                                child: Card(
                                    color : Colors.white12,
                                    child: CachedNetworkImage(
                                      imageUrl: '${snapshots.data.documents[i]['ImageURL']}',
                                      placeholder: (context,url)=>Shimmer.fromColors(child: Container(height: 50,width: 50), baseColor: Colors.white, highlightColor: Colors.white),
                                      errorWidget: (context,url,error)=>new Icon(Icons.error),
                                      fit: BoxFit.cover,
                                    )
                                ),
                              );
                            }
                        );
                      }
                    }
                ),

              ],
            ),
          ),
        ],
      ),
    );*/
  }
  Widget Follow() {
    print('g');
    if (isrequested == null) {
      return Center(child: CircularProgressIndicator(),);
    }
    else {
      return isrequested ? Container(
        margin: EdgeInsets.only(top: 20),
        child: RaisedButton(
          onPressed: () {},
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: Colors.white12,
          child: Text(
            'Requested',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'OpenSans'
            ),
          ),),
      )
          : Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 20),
              child: RaisedButton(
                elevation: 5.0,
                onPressed: () {
                  setState(() {
                    isrequested = true;
                  });
                  Followbutton();
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.blue,
                child: Text(
                  'Follow',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'OpenSans'
                  ),
                ),),
            ),
            accoutprivate(),
          ]
      );
    }
  }
  Widget accoutprivate(){
    return Container(
      margin: EdgeInsets.only(top: 20),
      padding:  EdgeInsets.only(top: 20,left: 10,right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.lock,color: Colors.black,),
          Expanded(
            child: Column(
              children: <Widget>[
                Text('This Account is Private',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),),
                Text('Follow this Account to see their photos and videos.',style: TextStyle(color: Colors.black),),
              ],
            ),
          )
        ],
      ),
    );
  }
  Widget followers(){
    return StreamBuilder(
        stream: Firestore.instance.collection('users').document(SearchUserID).collection('Followers').snapshots(),
        builder :(context,snapshots){
          if(!snapshots.hasData){
            return CircularProgressIndicator();
          }
          else{
            return GestureDetector(
              onTap: (){if(check()){Navigator.push(context, new MaterialPageRoute(builder: (context)=>Followers(SearchUserID)));}},
              child: Column(
                children: [
                  Text(snapshots.data.documents.length.toString(),style: TextStyle(color: Colors.black,fontSize: 20),),
                  Text('Followers',style : TextStyle(color: Colors.black,fontSize: 15)),
                ],
              ),
            );
          }
        }
    );
  }
  Widget followingss(){
    return StreamBuilder(
        stream: Firestore.instance.collection('users').document(SearchUserID).collection('Followings').snapshots(),
        builder :(context,snapshots){
          if(!snapshots.hasData){
            return CircularProgressIndicator();
          }
          else{
            return GestureDetector(
              onTap: (){if (check()) {Navigator.push(context, new MaterialPageRoute(builder: (context)=>Followings(SearchUserID)));}},
              child: Column(
                children: [
                  Text(snapshots.data.documents.length.toString(),style: TextStyle(color: Colors.black,fontSize: 20),),
                  Text('Followings',style : TextStyle(color: Colors.black,fontSize: 15)),
                ],
              ),
            );
          }
        }
    );
  }
  Widget post(){
    return StreamBuilder(
        stream: Firestore.instance.collection('users').document(SearchUserID).snapshots(),
        builder :(context,snapshots){
          if(!snapshots.hasData){
            return CircularProgressIndicator();
          }
          else{
            return Column(
                children: [
                  Text(snapshots.data['Post'].toString(),style: TextStyle(color: Colors.black,fontSize: 20),),
                  Text('Post',style : TextStyle(color: Colors.black,fontSize: 15)),
                ]
            );
          }
        }
    );
  }
  Future<void> Followbutton() async{
    await Firestore.instance.collection('users').document(SearchUserID).collection('Notification').add({'UID':CurrentUserID,'type':'has requested to follow you','Time':FieldValue.serverTimestamp()});
    await Firestore.instance.collection('users').document(SearchUserID).collection('Followers').document(CurrentUserID).setData({'UID' :CurrentUserID});
    await Firestore.instance.collection('users').document(CurrentUserID).collection('Followings').document(SearchUserID).setData({'UID' :SearchUserID});
  }
  Future<void> Followbackbutton() async{
    await Firestore.instance.collection('users').document(SearchUserID).collection('Notification').add({'UID':CurrentUserID,'type':'accepted your follow request','Time':FieldValue.serverTimestamp()});
    await Firestore.instance.collection('users').document(SearchUserID).collection('Followers').document(CurrentUserID).setData({'UID' :CurrentUserID});
    await Firestore.instance.collection('users').document(CurrentUserID).collection('Followings').document(SearchUserID).setData({'UID' :SearchUserID});
  }
  bool check(){
    checkfollower();
    if(isrequested!=null&&isfollower!=null){
      if(isfollower&&isrequested){
        return true;
      }
    }
    return false;
  }
}
