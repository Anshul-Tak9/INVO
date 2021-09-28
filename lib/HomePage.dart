import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/widget/actiontoolbar.dart';
import 'package:myapp/widget/videodecription.dart';
import 'package:shimmer/shimmer.dart';
import 'Pair.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}
class _HomepageState extends State<Homepage> {
  bool isLoading=false;
  List<Pair> list=[];
  initState(){
    videolist();
  }
  Future<void> videolist() async {
    setState(() {
      isLoading=true;
    });
    print('u');
    await Firestore.instance.collection('users').getDocuments().then((QuerySnapshot docs) async {
    for(int i=0;i<docs.documents.length;i++){
      String s=docs.documents[i].documentID;
      print(s);
      await elements(s);
     }
    });
    list.sort((b,a)=>a.three.compareTo(b.three));
    print(list.length);
    setState(() {
      isLoading=false;
    });
  }
  Future<void> elements(String s) async{
    await Firestore.instance.collection('users').document(s).collection('Videos').getDocuments().then((QuerySnapshot value) async {
      for(int i=0;i<value.documents.length;i++){
        int Length;
        await Firestore.instance.collection('users').document(s).collection('Videos').document('${i+1}').collection('Likes').getDocuments().then((value) => Length=value.documents.length);
        print(i);
        print(Length);
        list.add(new Pair(s,'${i+1}',Length));
        print(s);
      }
    });
  }  
  Widget middlesection(String id,int i){
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          VideoDescription(id,i),
          ActionToolbar(id,i,'Videos'),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    print('o');
    return Scaffold(
      backgroundColor: Colors.black,
      body:isLoading?Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.red,)),):PageView.builder(scrollDirection:Axis.vertical,itemCount: list.length,itemBuilder: (BuildContext ctx,int index){
        print(list.length);
          return Container(
            child: StreamBuilder(
              stream: Firestore.instance.collection('users').document(list[index].one).collection('Videos').document(list[index].two).snapshots(),
              builder: (context, snapshot) {
                print(snapshot.hasData);
                if(!snapshot.hasData){
                  return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.red,)),);
                }
                else {
                  print(snapshot.data['Likes']);
                  print(snapshot.data['VideoURL']);
                  return Stack(
                    children: <Widget>[
                      VideoView(snapshot.data['VideoURL'],snapshot.data['ImageURL']),
                      Column(
                        children: <Widget>[
                          Expanded(child: Container(),),
                          middlesection(list[index].one, int.parse(list[index].two)),
                          Container(height: 50,),
                        ],
                      ),
                    ],
                  );
                }
              }
            ),
          );
      },
      )
    );
  }
}
class VideoView extends StatefulWidget {
  @override
  String link;
  String imageURL;

  VideoView(String s,String im){
    link=s;
    imageURL=im;
  }
  _VideoViewState createState() => _VideoViewState(link,imageURL);
}

class _VideoViewState extends State<VideoView> {
  @override
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;
  String link;
  String imageURL;
  _VideoViewState(String s,String im){
    link=s;
    imageURL=im;
  }
  void initState(){
    print('u');
    _controller=VideoPlayerController.network(link);
    _controller.play();
    _controller.setLooping(true);
    _initializeVideoPlayerFuture = _controller.initialize();
    super.initState();
  }
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();
    super.dispose();
  }
  Widget build(BuildContext context) {
    print('p');
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if(snapshot.connectionState==ConnectionState.waiting||snapshot.connectionState==ConnectionState.none){
            return Stack(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height-40,
                  width: MediaQuery.of(context).size.width,child: CachedNetworkImage(
                  imageUrl: imageURL,
                  placeholder: (context,url)=>Shimmer.fromColors(child: Container(height: 50,width: 50), baseColor: Colors.white, highlightColor: Colors.white),
                  errorWidget: (context,url,error)=>new Icon(Icons.error),
                  fit: BoxFit.fill,
                ),
                ),
                Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.red),)),
              ],
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            // If the VideoPlayerController has finished initialization, use
            // the data it provides to limit the aspect ratio of the VideoPlayer.
            final size = MediaQuery.of(context).size;
            return Container(
              height: MediaQuery.of(context).size.height-40,
              width: MediaQuery.of(context).size.width,
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            );
          }
          else {
            // If the VideoPlayerController is still initializing, show a
            // loading spinner.
            return Stack(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height-40,
                  width: MediaQuery.of(context).size.width,child: CachedNetworkImage(
                imageUrl: imageURL,
                placeholder: (context,url)=>Shimmer.fromColors(child: Container(height: 50,width: 50), baseColor: Colors.white, highlightColor: Colors.white),
          errorWidget: (context,url,error)=>new Icon(Icons.error),
                    fit: BoxFit.fill,
          ),
                ),
                Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.red),)),
              ],
            );
          }
        },
      ),
    );
  }
}


