import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:myapp/widget/Editpage.dart';
import 'package:myapp/widget/profilepicview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:myapp/Account_Page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_video_player/cached_video_player.dart';
import 'package:myapp/widget/Videoview.dart';
import 'package:video_player/video_player.dart';
import 'Followings.dart';
import 'ImageView.dart';
import 'Videoshow.dart';
import 'Followers.dart';
class mepage extends StatefulWidget {
  FirebaseUser user;
  mepage(FirebaseUser u){
    user=u;
  }
  @override
  State<StatefulWidget> createState() => mepagestate(user);
}

class mepagestate extends State<mepage>{
  @override
  static FirebaseUser user;
  mepagestate(FirebaseUser u){
    user=u;
  }
  static const double ActionWidthSize=60.0;
  static const double ActionIconSize=35.0;
  static const double ProfileImageSize=50.0;
  static const double PlusIconSize=20.0;
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(
        child : ListView(
          children: <Widget>[
            DrawerHeader(
              child : Row(
                  children:<Widget>[
                    IconButton(icon : Icon(Icons.cancel),onPressed: (){Navigator.pop(context,true);},),
                    Text('Menu',style: TextStyle(fontWeight: FontWeight.bold),)]),
            ),
            ListTile(
              title: GestureDetector(
                onTap: (){SignOut(context);},
                child: Text('LogOut'),
              ),
            ),
          ],
        )
      ),
      appBar: AppBar(
        elevation: 10,
        leading: Container(),
        title: StreamBuilder(
            stream: Firestore.instance.collection('users').document(user.uid).snapshots(),
            builder: (context,snapshot) {
              if (!snapshot.hasData) {
                return Text("Loading...");
              }
              else {
                return Text(snapshot.data['Username'],style: TextStyle(color: Colors.black,fontSize:17));
              }
            }
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.only(top : 30),
        child :ListView(
          shrinkWrap: true,
          children: <Widget>[
            Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
           crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
               // FollowAction(),
              StreamBuilder(
                stream : Firestore.instance.collection('users').document('${user.uid}').snapshots(),
                builder: (context,snapshots) {
                  if (!snapshots.hasData) {
                    return CircularProgressIndicator(backgroundColor: Colors.white);
                  }
                  else {
                    return Row(
                      children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, new MaterialPageRoute(
                                    builder: (context) => Profilepicview(user.uid)));
                              },
                              child: CircleAvatar(
                                radius: 55,
                                backgroundColor: Colors.blue,
                                child: CircleAvatar(
                                  radius: 52,
                                  backgroundImage: NetworkImage(
                                      '${snapshots.data['ProfilePicURL']}'),
                                ),
                              ),
                            ),
                      ],
                    );
                  }
                }
              ),
                post(),
               followings(),
                followers(),
            ],
        ),
          Container(
            margin :EdgeInsets.only(top:20),
            padding :EdgeInsets.only(left:20),
            child : Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                StreamBuilder(
                    stream: Firestore.instance.collection('users').document(user.uid).snapshots(),
                    builder: (context,snapshot) {
                      if (!snapshot.hasData) {
                        return Text("Loading...");
                      }
                      else {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children : <Widget>[
                          Text('${snapshot.data['Name']}',style: TextStyle(color: Colors.black,fontSize:17)),
                          Text('${snapshot.data['bio']}',style: TextStyle(color: Colors.black,fontSize:17)),
                        ],
                        );
                      }
                    }
                ),
              ],
            ),
          ),
          Container(
            margin : EdgeInsets.fromLTRB(10, 30, 10, 10),
            //padding :EdgeInsets.only(left:20),
            color: Colors.black26,
            height: 30,
            width: MediaQuery. of(context). size. width,
          //  margin: EdgeInsets.all(10.0),
            child: IconButton(icon:Icon(Icons.edit),iconSize: 15,color:Colors.black,onPressed: (){
              Navigator.push(context, new MaterialPageRoute(builder: (context)=>editpage(user)));}
         ),
          ),
            StreamBuilder(
                stream : Firestore.instance.collection('users').document('${user.uid}').collection('Videos').snapshots(),
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
                            onTap: (){Navigator.push(context, new MaterialPageRoute(builder: (context)=>VideoShow(user.uid,'${snapshots.data.documents[i]['VideoURL']}',i+1,'Videos','${snapshots.data.documents[i]['ImageURL']}')));},
                            child: Card(
                                color : Colors.white12,
                                child :  CachedNetworkImage(
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
         /* DefaultTabController(
            length: 2,
            child : Column(
              children: <Widget>[

                TabBar(
                  tabs: [
                    Tab(icon : Icon(Icons.image,color: Colors.white,)),
                    Tab(icon : Icon(Icons.video_library,color : Colors.white)),
                  ],
                ),
                SizedBox(
                  height: 1000,
                  child: TabBarView(
                      children: <Widget>[
                              StreamBuilder(
                                stream : Firestore.instance.collection('users').document('${user.uid}').collection('Images').snapshots(),
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
                                          print(i);
                                           return GestureDetector(
                                             onTap: (){Navigator.push(context, new MaterialPageRoute(builder: (context)=>ImageView(user,'${snapshots.data.documents[i]['ImageURL']}',i+1,'Images')));},
                                             child: Card(
                                               elevation: 24,
                                               shadowColor: Colors.black,
                                               borderOnForeground: true,
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
          ),*/
          /*DefaultTabController(
            length:2,
            child :Container(
              child : Column(
              children: <Widget>[
                  TabBar(
                    tabs: [
                         Tab(icon : Icon(Icons.grid_on,color: Colors.white,)),
                            Tab(icon : Icon(Icons.tag_faces,color : Colors.white)),
                   ],
              ),
                SizedBox(
                  height: 100,
                child :TabBarView(
                  children: <Widget>[
                        IconButton(icon : Icon(Icons.grid_on),color: Colors.white,),
                        IconButton(icon  :Icon(Icons.tag_faces),color:Colors.white),
                      ],
                ),
                ),
            ],
            ),
            ),
          ),*/
        ],
      ),
    ),
    );
  }
  Widget followers(){
    return StreamBuilder(
      stream: Firestore.instance.collection('users').document(user.uid).collection('Followers').snapshots(),
      builder :(context,snapshots){
        if(!snapshots.hasData){
          return CircularProgressIndicator();
        }
        else{
         return GestureDetector(
            onTap: (){Navigator.push(context, new MaterialPageRoute(builder: (context)=>Followers(user.uid)));},
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
  Widget followings(){
    return StreamBuilder(
        stream: Firestore.instance.collection('users').document(user.uid).collection('Followings').snapshots(),
        builder :(context,snapshots){
          if(!snapshots.hasData){
            return CircularProgressIndicator();
          }
          else{
            return GestureDetector(
              onTap: (){Navigator.push(context, new MaterialPageRoute(builder: (context)=>Followings(user.uid)));},
              child: Column(
                children: [
                  Text(snapshots.data.documents.length.toString(),style: TextStyle(color: Colors.black,fontSize: 20),),
                  Text('Followings',style : TextStyle(color: Colors.black,fontSize: 15),),
                ],
              ),
            );
          }
        }
    );
  }
  Widget post(){
    return StreamBuilder(
        stream: Firestore.instance.collection('users').document(user.uid).snapshots(),
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
  Widget data( String title,int d){
    return GestureDetector(
      onTap: (){},
      child: Column(
          children: [
            Text('${d}',style: TextStyle(color: Colors.white,fontSize: 20),),
            Text(title,style : TextStyle(color: Colors.white,fontSize: 15)),
          ],
      ),
    );
  }
  void SignOut(context) async{
    await FirebaseAuth.instance.signOut();
    Navigator.push(context,MaterialPageRoute(builder: (context)=>homepage()));
  }
}
class Videoshortscreen extends StatefulWidget {
  String _url;
  Videoshortscreen(String s){
    _url=s;
  }
  _VideoshortscreenState createState() => _VideoshortscreenState(_url);
}

class _VideoshortscreenState extends State<Videoshortscreen> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;
  String _url;
  _VideoshortscreenState(String s){
    _url=s;
  }
  void initState() {
    _controller = VideoPlayerController.network(_url,);
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.play();
    _controller.setLooping(true);
    super.initState();
  }
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // If the VideoPlayerController has finished initialization, use
          // the data it provides to limit the aspect ratio of the VideoPlayer.
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            // Use the VideoPlayer widget to display the video.
            child: VideoPlayer(_controller),
          );
        } else {
          // If the VideoPlayerController is still initializing, show a
          // loading spinner.
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
/*Widget FollowAction(){
    return Container(
      width: ActionWidthSize,height: ActionWidthSize,
      child: Stack(children : [getProfilepic(),getPlusIcon()]),
    );
  }
  Widget getProfilepic(){
    return Container(

    )
  }
  Widget getPlusIcon(){
    return Positioned(
      left : (ActionWidthSize/2)-(PlusIconSize/2),
      bottom :0,
      child :Container(
          width : PlusIconSize,height: PlusIconSize,
          color:Colors.red,
          child :IconButton(
           icon: Icon(Icons.add,color: Colors.white,size: 20.0,),
              onPressed: () {  },),
          ),
    );
  }*/
