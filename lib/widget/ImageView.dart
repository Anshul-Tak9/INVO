import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/widget/videodecription.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'actiontoolbar.dart';
import 'package:photo_view/photo_view.dart';
class ImageView extends StatefulWidget {
  FirebaseUser user;
  String _imageurl;
  int i;
  String type;
  ImageView(FirebaseUser u,String s,int uo,String t){
    user=u;
    _imageurl=s;
    i=uo;
    type=t;
  }
  @override
  _ImageViewState createState() => _ImageViewState(user,_imageurl,i,type);
}

class _ImageViewState extends State<ImageView> {
  FirebaseUser user;
  String _imageurl;
  int i;
  String type;
  _ImageViewState(FirebaseUser u,String s,int uo,String t){
    user=u;
    _imageurl=s;
    i=uo;
    type=t;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          PhotoView(
                imageProvider: NetworkImage(
                    _imageurl,
            ),
          ),
          ImageProperties(user,i,type),
        ],
      ),
    );
  }
}
class ImageProperties extends StatefulWidget {
  FirebaseUser user;
  int i;
  String type;
  ImageProperties(FirebaseUser u,int uo,String t){
    user=u;
    i=uo;
    type=t;
  }
  @override
  _ImagePropertiesState createState() => _ImagePropertiesState(user,i,type);
}

class _ImagePropertiesState extends State<ImageProperties> {
  FirebaseUser user;
  int i;
  String type;
  _ImagePropertiesState(FirebaseUser u,int uo,String t){
    user=u;
    i=uo;
    type=t;
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        topsection(),
        middlesection(user.uid,i,type),
        Container(height: 15,)
      ],
    );
  }
  Widget topsection(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 20,left: 10),
          height: 40,
            child: IconButton(icon:Icon(Icons.arrow_back,color: Colors.white,),onPressed: (){Navigator.pop(context,true);}),
          ),
      ],
    );
  }
  Widget middlesection(String id,int i,String type){
   return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          VideoDescription(user.uid,i),
          ActionToolbar(id,i,type),
        ],
      ),
    );
  }
}

