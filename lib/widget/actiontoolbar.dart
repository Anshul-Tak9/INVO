import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:myapp/my_flutter_app_icons.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:myapp/SearchResult/SearchResults.dart';
class Actionbutton extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => ActionbuttonState();

}
class ActionbuttonState extends State<Actionbutton>{
  static const double ActionWidthSize=60.0;
  static const double ActionIconSize=35.0;
  static const double ProfileImageSize=50.0;
  static const double PlusIconSize=20.0;
  int count=0;
  bool isfavourite;
  void heartbutton(){
    setState(() {
      if(isfavourite){
        count--;
        isfavourite=false;
      }
      else{
        count++;
        isfavourite=true;
      }
    });
  }
  Widget build(BuildContext context) {
    return Container(
      width: ActionWidthSize,height: ActionWidthSize,margin: EdgeInsets.fromLTRB(0,10,0,10),
      child : Column(
        children: <Widget>[
          IconButton(
            icon : isfavourite? Icon(MyFlutterApp.heart) : Icon(MyFlutterApp.heart_empty),
            color: Colors.red,
            iconSize: ActionIconSize,
            onPressed: heartbutton,
          ),
        ],
      )
    );

  }

}
class CommentButton extends StatefulWidget{
  String userID;
  int i;
  String type;
  Timestamp timestamp;
  CommentButton(String id,int u,String te){
    userID=id;
    i=u;
    type=te;
  }
  @override
  State<StatefulWidget> createState() => CommentButtonState(userID,i,type,this.timestamp);

}
class CommentButtonState extends State<CommentButton> {
  static const double ActionWidthSize = 60.0;
  static const double ActionIconSize = 35.0;
  static const double ProfileImageSize = 50.0;
  static const double PlusIconSize = 20.0;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _controller=TextEditingController();
  final Timestamp timestamp;
  double count=0.0;
  String userID;
  int i;
  String type;
  String comment;
  bool isloading=false;
  CommentButtonState(String id,int u,String te, this.timestamp){
    userID=id;
    i=u;
    type=te;
  }
  @override
  Widget build(BuildContext context) {
   return Scaffold(
     backgroundColor: Colors.black,
     appBar: AppBar(
       backgroundColor: Colors.white12,
       leading: IconButton(icon: Icon(Icons.arrow_back,color: Colors.white,),onPressed: (){Navigator.pop(context,true);},),
       title: Text('Comments'),
     ),
     body: isloading?LinearProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.red),backgroundColor: Colors.white,):Column(
       children: <Widget>[
         Expanded(
           child: StreamBuilder(
             stream: Firestore.instance.collection('users').document(userID).collection(type).document('${i}').collection('comment').orderBy('Time',descending: true).snapshots(),
             builder: (context,snapshots){
               if(!snapshots.hasData){
                 return Center(child: CircularProgressIndicator(),);
               }
               else{
                 //print(snapshots.data.documents.length);
                 return ListView.builder(
                   shrinkWrap: true,
                    itemCount: snapshots.data.documents.length
                    ,itemBuilder: (BuildContext context,int i){
                        return Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 25,
                              backgroundImage: NetworkImage('${snapshots.data.documents[i]['imageURL']}'),
                            ),
                            title: Text(snapshots.data.documents[i]['username']+": "+snapshots.data.documents[i]['comment'],style: TextStyle(color: Colors.white,letterSpacing: 1),),
                            subtitle: Text('${timeago.format(snapshots.data.documents[i]['Time'].toDate())}',style: TextStyle(color: Colors.white,letterSpacing: 1),),
                          ),
                        );
                 });
               }
             }
           ),
         ),
         Divider(),
         Form(
           key: _formKey,
           child: ListTile(
             title: TextFormField(
                       // ignore: missing_return
                     validator: (input){
                       if(input.isEmpty){
                         return 'please provide a comment';
                       }
                     },
                     onSaved: (input)=>comment=input,
                      style: TextStyle(color: Colors.white),
                     decoration: InputDecoration(
                       fillColor: Colors.white,
                       focusColor: Colors.white,
                       labelText: 'Add a Comment',
                       labelStyle: TextStyle(color: Colors.white),
                       enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                       focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                     ),
                   ),
             trailing: IconButton(icon:Icon(Icons.forward,color: Colors.white,),onPressed: (){publish(userID,i,type,timestamp);},),
           ),
         ),
       ],
     ),

   );
  }
  Future<void> publish(String userID,int i,String type,Timestamp timestamp) async{
    FirebaseUser user;
    print('k');
    final _formState=_formKey.currentState;
    if(_formState.validate()) {
      _formState.save();
      String imageURL;
      String username;
      print('u');
      setState(() {
        isloading=true;
      });
      await FirebaseAuth.instance.currentUser().then((value) => user=value);
      await Firestore.instance.collection('users').document(user.uid).get().then((
          value) {
        imageURL = value.data['ProfilePicURL'];
        username = value.data['Username'];
        timestamp=value.data['timestamp'];
      });
      String link;
      String videoURL;
      FirebaseUser user1=await FirebaseAuth.instance.currentUser();
      await Firestore.instance.collection('users').document(userID).collection(type).document('${i}').get().then((value) {link= value.data['ImageURL'];videoURL=value.data['VideoURL'];});
      final docref=await Firestore.instance.collection('users').document(userID).collection('Notification').add({'UID':user1.uid,'type':'commented on your photo','Image':i,'VideoURL':videoURL,'ImageURL':link,'Time':FieldValue.serverTimestamp()});
      await Firestore.instance.collection('users').document(userID).collection(type).document('${i}').collection(
          'comment').add(
          {'imageURL': imageURL, 'comment': comment, 'username': username,'UID':user1.uid,'NotID':docref.documentID,'Time':FieldValue.serverTimestamp()});
    }
    setState(() {
      isloading=false;
    });
    print('task done');
  }
}
class ActionToolbar extends StatefulWidget{
  String userID;
  int i;
  String type;

  static const double ActionWidthSize=60.0;
  static const double ActionIconSize=35.0;
  static const double ProfileImageSize=50.0;
  static const double PlusIconSize=20.0;

  ActionToolbar(String id,int u,String te){
    userID=id;
    i=u;
    type=te;
  }

  @override
  _ActionToolbarState createState() => _ActionToolbarState(userID,i,type);
}

class _ActionToolbarState extends State<ActionToolbar> {
  String userID;
  int i;
  String type;
  bool isfavourite;
  bool isloading=false;
  int count=0;
  bool profilepicloading=false;
  FirebaseUser user22;
  static const double ActionWidthSize=60.0;
  static const double ActionIconSize=35.0;
  static const double ProfileImageSize=50.0;
  static const double PlusIconSize=20.0;
  _ActionToolbarState(String id,int u,String te){
    userID=id;
    i=u;
    type=te;
  }
  void initState(){
    hu();
  }
  Future<void> hu() async{
    setState(() {
      profilepicloading=true;
    });
    user22=await FirebaseAuth.instance.currentUser();
    setState(() {
      profilepicloading=false;
    });
  }
  Widget build(BuildContext context){
    return Container(
      width:100,
      child : SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          //crossAxisAlignment: CrossAxisAlignment.start,
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          children : <Widget>[
            profilepic(user22),
            Like(),
            Container(
              margin: EdgeInsets.only(top :15.0),
              child :Column(
                children :[
                IconButton(icon:Icon(MyFlutterApp.chat_bubble,color: Colors.white,size: ActionToolbar.ActionIconSize,),onPressed: (){Navigator.push(context, new MaterialPageRoute(builder: (context)=>CommentButton(userID,i,type)));},),
                Padding(
                  padding :EdgeInsets.only(top: 2.0),
                  child : StreamBuilder(
                    stream: Firestore.instance.collection('users').document(userID).collection(type).document('${i}').collection('comment').snapshots(),
                    builder: (ctx,snapshots){
                      if(!snapshots.hasData){
                        return CircularProgressIndicator();
                      }
                      else{
                        return Text('${snapshots.data.documents.length}',style: TextStyle(fontSize: 14.0,fontWeight: FontWeight.bold,color: Colors.white));
                      }
                    },
                  ),
                )
              ],),
            ),
            share(context),
           // social_action(title : 'Share',icon :MyFlutterApp.reply),
           // musicicon(),
          ],
          ),
      ),
    );
  }

  Widget share(BuildContext context){
    return Container(
      margin: EdgeInsets.only(top :15.0),
      child :Column(children :[
        IconButton(icon:Icon(Icons.share,color: Colors.white,size: ActionToolbar.ActionIconSize,), onPressed: () {
          sharelink(context);
        },),
        Padding(
          padding :EdgeInsets.only(top: 2.0),
          child :Text('Share',style: TextStyle(fontSize: 14.0,fontWeight: FontWeight.bold,color: Colors.white)),
        )
      ],),
    );
  }

  Future<void> sharelink(BuildContext context) async{
    String link;
    await Firestore.instance.collection('users').document(userID).collection(type).document('${i}').get().then((value) =>link= value.data['ImageURL']);
    await FlutterShare.share(title: 'Share',text: 'INVO' ,linkUrl:link);
  }

  Widget social_action({String title, IconData icon}){
    return Container(
    margin: EdgeInsets.only(top :10.0),
      child :Column(children :[
        Icon(icon,color: Colors.white,size: ActionToolbar.ActionIconSize,),
        Padding(
          padding :EdgeInsets.only(top: 2.0),
          child :Text(title,style: TextStyle(fontSize: 14.0,fontWeight: FontWeight.bold,color: Colors.white)),
        )
      ],),
    );
  }
  void check() async{
    await Firestore.instance.collection('users').document(userID).collection(type).document('${i}').collection('Likes').where('UID',isEqualTo: userID).getDocuments();
    isloading=false;
  }
  Widget Like(){
    return Container(
        margin: EdgeInsets.fromLTRB(0,10,0,0),
        child : Column(
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('users').document(userID).collection(type).document('$i').collection('Likes').where('UID',isEqualTo: user22.uid).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                if (snapshot.hasError) return new Text('${snapshot.error}');
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  default:
                    if(snapshot.data.documents.length==0){
                      isfavourite=false;
                    }
                    else{
                      isfavourite=true;
                    }
                    return isloading?Center(child: CircularProgressIndicator(),):IconButton(
                      icon : isfavourite? Icon(MyFlutterApp.heart) : Icon(MyFlutterApp.heart_empty),
                      color: Colors.red,
                      iconSize: ActionIconSize,
                      onPressed: heartbutton,
                    );
                }
              }
            ),
            StreamBuilder(
              stream: Firestore.instance.collection('users').document(userID).collection(type).document('${i}').collection('Likes').snapshots(),
              builder: (ctx,snapshots){
                if(!snapshots.hasData){
                  return CircularProgressIndicator();
                }
                else{
                  count=snapshots.data.documents.length;
                  return Padding(
                      padding :EdgeInsets.only(top: 2.0),
                      child: Text('${snapshots.data.documents.length}',style: TextStyle(fontSize: 14.0,fontWeight: FontWeight.bold,color: Colors.white))
                  );
                }
              },
            ),
          ],
        )
    );
  }
  void heartbutton() async{
      if(isfavourite){
        setState((){
          count--;
          isfavourite=false;
          isloading=true;
        });
        String id;
        FirebaseUser user=await FirebaseAuth.instance.currentUser();
        print(user.uid);
        await Firestore.instance.collection('users').document(userID).collection(type).document('${i}').collection('Likes').document(user.uid).get().then((value) => id=value.data['NotID']);
        await Firestore.instance.collection('users').document(userID).collection('Notification').document(id).delete();
        await Firestore.instance.collection('users').document(userID).collection(type).document('${i}').collection('Likes').document(user.uid).delete();
        print('done');
        setState(() {
          isloading=false;
        });
      }
      else{
        setState((){
          count++;
          isfavourite=true;
          isloading=true;
        });
        String link;String videoURL;
        FirebaseUser user=await FirebaseAuth.instance.currentUser();
        await Firestore.instance.collection('users').document(userID).collection(type).document('${i}').get().then((value) {link= value.data['ImageURL'];videoURL=value.data['VideoURL'];});
        final docref=await Firestore.instance.collection('users').document(userID).collection('Notification').add({'UID':user.uid,'type':'like your photo','Image':i,'VideoURL':videoURL,'ImageURL':link,'Time':FieldValue.serverTimestamp()});
        await Firestore.instance.collection('users').document(userID).collection(type).document('${i}').collection('Likes').document(user.uid).setData({'UID':user.uid,'NotID':docref.documentID});
        print('done');
        setState(() {
          isloading=false;
        });
      }
  }
  Widget FollowAction(){
    return Container(
        width: ActionToolbar.ActionWidthSize,height: ActionToolbar.ActionWidthSize,
        child: Stack(children : [getProfilepic(),getPlusIcon()]),
    );
  }
  Widget profilepic(FirebaseUser user){
    return profilepicloading?Center(child: CircularProgressIndicator(),):StreamBuilder(
      stream: Firestore.instance.collection('users').document(userID).snapshots(),
      builder: (context,snapshot){
        if(!snapshot.hasData){
          return CircularProgressIndicator();
        }
        else{
          return GestureDetector(
            onTap: (){  Navigator.push(context, new MaterialPageRoute(
                builder: (context) => SearchResults(user.uid,userID)));},
            child: Container(
              margin: EdgeInsets.only(bottom: 10,right: 5),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.blue,
                child: CircleAvatar(radius:25,backgroundImage: NetworkImage(snapshot.data['ProfilePicURL']),),
              ),
            ),
          );
        }
      },
    );
  }
  Widget getProfilepic(){
    return Positioned(
      left : (ActionToolbar.ActionWidthSize/2)-(ActionToolbar.ProfileImageSize/2),
      child : Container(
        height: ActionToolbar.ProfileImageSize,width: ActionToolbar.ProfileImageSize,
        padding: EdgeInsets.all(1.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ActionToolbar.ProfileImageSize/2),
        ),
        child : CachedNetworkImage(
          imageUrl :"https://www.gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50",
          placeholder : (context,url) =>new CircularProgressIndicator(),
          errorWidget :(context,url,error) =>new Icon(Icons.error,color : Colors.black),
        ),
      ),
    );
  }

  Widget getPlusIcon(){
    return Positioned(
      left : (ActionToolbar.ActionWidthSize/2)-(ActionToolbar.PlusIconSize/2),
      bottom :0,
      child :Container(
        width : ActionToolbar.PlusIconSize,height: ActionToolbar.PlusIconSize,
        color:Colors.red,
          child :Icon(
            Icons.add,color: Colors.white,size: 20.0,
          )
        ),
    );
  }

  Widget musicicon(){
    return Container(
      width: ActionToolbar.ActionWidthSize,
      height: ActionToolbar.ActionWidthSize,
      child : Column(
        children :[
          Container(
            padding: EdgeInsets.all(11.0),
            height: ActionToolbar.ProfileImageSize,width: ActionToolbar.ProfileImageSize,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.black,Colors.black12]),
              borderRadius: BorderRadius.circular(ActionToolbar.ProfileImageSize/2),
            ),
            child : CachedNetworkImage(
              imageUrl :"https://www.gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50",
              placeholder : (context,url) =>new CircularProgressIndicator(),
              errorWidget :(context,url,error) =>new Icon(Icons.error,color : Colors.black),
            ),
          ),
        ],
      )
    );
  }
}