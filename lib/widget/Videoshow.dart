import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/widget/videodecription.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shimmer/shimmer.dart';
import 'actiontoolbar.dart';
import 'package:cached_video_player/cached_video_player.dart';
class VideoShow extends StatefulWidget {
  @override
  String userID;
  String _videourl;
  int i;
  String type;
  String imageURL;
  VideoShow(String u,String s,int uo,String t,String im){
    userID=u;
    _videourl=s;
    i=uo;
    type=t;
    imageURL=im;
  }
  _VideoShowState createState() => _VideoShowState(userID,_videourl,i,type,imageURL);
}

class _VideoShowState extends State<VideoShow> {
  @override
  String userID;
  String _videourl;
  CachedVideoPlayerController _controller;
  int i;
  String type;
  String imageURL;
  _VideoShowState(String u,String s,int uo,String t,String im){
    userID=u;
    _videourl=s;
    i=uo;
    type=t;
    imageURL=im;
  }
  void initState(){
    _controller = CachedVideoPlayerController.network(_videourl);
    _controller.initialize().then((value) {
      setState(() {
        _controller.play();
        _controller.setLooping(true);
      });
    });
  }
  void dispose(){
    _controller.dispose();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          _controller.value != null && _controller.value.initialized
              ? Container(
                height: MediaQuery.of(context).size.height,width: MediaQuery.of(context).size.width,
                child: AspectRatio(
                child: CachedVideoPlayer(_controller),
                aspectRatio: _controller.value.aspectRatio),
              )
              :  Stack(
                children: <Widget>[
                  Container(
                     height: MediaQuery.of(context).size.height-40,
                    width: MediaQuery.of(context).size.width,child: CachedNetworkImage(
                    imageUrl: imageURL,
                    placeholder: (context,url)=>Shimmer.fromColors(child: Container(height: 50,width: 50), baseColor: Colors.white, highlightColor: Colors.white),
                    errorWidget: (context,url,error)=>new Icon(Icons.error),
                    fit: BoxFit.fill,
            ),),
                  Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.red),),)
                ],
              ),
          Column(
            children: <Widget>[
              topsection(),
              middlesection(userID, i, type),
              Container(height: 15,)
            ],
          ),
        ],
      ),
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
          VideoDescription(id,i),
          ActionToolbar(id,i,type),
        ],
      ),
    );
  }
}
