import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:myapp/recorded_video.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:dio/dio.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
class Music extends StatefulWidget {
  @override
  _MusicState createState() => _MusicState();
}
class _MusicState extends State<Music> {
  @override
  bool isPlaying=false;
  String _HindiSongsfile;
  bool isLoading =false;
  static AudioPlayer audioplayer=new AudioPlayer();
  static AudioCache audioCache=new AudioCache(fixedPlayer: audioplayer);
  StorageReference str=FirebaseStorage.instance.ref();
  bool isDownloading=false;
  bool downloaded=false;
  String audioPath;
  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
  String music;
  void initState(){
    print('k');
    gettingimages();
  }
  void dispose(){
    audioplayer.stop();
    print('dispose');
    super.dispose();
  }
  Future<void> gettingimages() async{
    setState(() {
      isLoading=true;
    });
    await Firestore.instance.collection('Music').document('Hindi_Songs').get().then((value) => _HindiSongsfile=value.data['ImageURL']);
    setState(() {
      isLoading=false;
    });
    print('s');
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black12,
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () {Navigator.pop(context);}),
        title: Text('Music',style:TextStyle(color:Colors.white,)),
      ),
      body:  StreamBuilder(
        stream: Firestore.instance.collection('Music').snapshots(),
        builder: (BuildContext ctx,snapshot){
          if(!snapshot.hasData){
            return CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.red),);
          }
          else{
            return GridView.builder(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),itemCount: snapshot.data.documents.length,itemBuilder: (BuildContext ctx,int i){
              return GestureDetector(
                onTap: (){Navigator.push(context,new MaterialPageRoute(builder:(context)=>SongsList(snapshot.data.documents[i]['SongName']))).then((value) => music=value);},
                child: Container(
                  margin:EdgeInsets.only(top: 10),
                  child: Column(
                    children: <Widget>[
                      isLoading?Card(color: Colors.white,):Container(height: 170,width: 170,child:Image.network(snapshot.data.documents[i]['ImageURL'],fit: BoxFit.fill,),/* CachedNetworkImage(
                        imageUrl: snapshot.data.documents[i]['ImageURL'],
                        placeholder: (context,url)=>Shimmer.fromColors(child: Container(height: 150,width: 150), baseColor: Colors.white, highlightColor: Colors.white),
                        errorWidget: (context,url,error)=>new Icon(Icons.error),
                        fit: BoxFit.cover,
                      ),),*/),
                      Expanded(child: Container(margin:EdgeInsets.only(top: 10),height: 40,alignment: Alignment.center,child: Text(snapshot.data.documents[i]['Name'],style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,letterSpacing: 1.0),),)),
                    ],
                  ),
                ),
              );
            });
          }
        },
      )/*GridView(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
    padding: EdgeInsets.all(3),children: <Widget>[
      GestureDetector(
        onTap: (){Navigator.push(context,new MaterialPageRoute(builder:(context)=>SongsList('Hindi_Songs'))).then((value) => music=value);},
        child: Column(
          children: <Widget>[
                isLoading?Card(color: Colors.white,):Container(height: 150,width: 150,child: CachedNetworkImage(
                  imageUrl: _HindiSongsfile,
                  placeholder: (context,url)=>Shimmer.fromColors(child: Container(height: 50,width: 50), baseColor: Colors.white, highlightColor: Colors.white),
                  errorWidget: (context,url,error)=>new Icon(Icons.error),
                  fit: BoxFit.cover,
                ),),
                Container(height: 40,alignment: Alignment.center,child: Text('Hindi Songs',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,letterSpacing: 1.0),),),
          ],
        ),
      ),
          GestureDetector(
            onTap: (){Navigator.push(context,new MaterialPageRoute(builder:(context)=>SongsList('Hindi_Songs'))).then((value) => music=value);},
            child: Column(
              children: <Widget>[
                isLoading?Card(color: Colors.white,):Container(height: 150,width: 150,child: CachedNetworkImage(
                  imageUrl: _HindiSongsfile,
                  placeholder: (context,url)=>Shimmer.fromColors(child: Container(height: 50,width: 50), baseColor: Colors.white, highlightColor: Colors.white),
                  errorWidget: (context,url,error)=>new Icon(Icons.error),
                  fit: BoxFit.cover,
                ),),
                Container(height: 40,alignment: Alignment.center,child: Text('Hindi Songs',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,letterSpacing: 1.0),),),
              ],
            ),
          )
    ],),*//* ListView(
        children: <Widget>[
          ListTile(
            leading: isPlaying==false?IconButton(icon: Icon(Icons.play_circle_filled,color: Colors.white,),onPressed: (){
              setState(() {
                audioCache.play('Music/Alone.mp3');
                isPlaying=true;
              });},):
            IconButton(icon: Icon(Icons.pause,color: Colors.white,),onPressed: (){;setState(() {
              audioplayer.pause();
              isPlaying=false;
            });}),
            title: Text('Alone',style: TextStyle(color: Colors.white),),
            trailing: GestureDetector(
              onTap: (){Navigator.pop(context,'Music/Alone.mp3');},
              child:Container(
                height: 30,
                width: 60,
                color: Colors.red,
                child: Center(child: Text('Use',style: TextStyle(color: Colors.white),)),
              )
            ),
          ),
          ListTile(
            leading: isPlaying==false?IconButton(icon: Icon(Icons.play_circle_filled,color: Colors.white,),onPressed: (){
              setState(() {
                audioCache.play('Music/Ignite.mp3');
                isPlaying=true;
              });},):
            IconButton(icon: Icon(Icons.pause,color: Colors.white,),onPressed: (){;setState(() {
              audioplayer.pause();
              isPlaying=false;
            });}),
            title: Text('Ignite',style: TextStyle(color: Colors.white),),
            trailing: GestureDetector(
                onTap: (){Navigator.pop(context,'Music/Ignite.mp3');},
                child:Container(
                  height: 30,
                  width: 60,
                  color: Colors.red,
                  child: Center(child: Text('Use',style: TextStyle(color: Colors.white),)),
                )
            ),
          ),
          ListTile(
            leading: isPlaying==false?IconButton(icon: Icon(Icons.play_circle_filled,color: Colors.white,),onPressed: (){
              setState(() {
                audioCache.play('Music/Suit_Suit.mp3');
                isPlaying=true;
              });},):
            IconButton(icon: Icon(Icons.pause,color: Colors.white,),onPressed: (){;setState(() {
              audioplayer.pause();
              isPlaying=false;
            });}),
            title: Text('Suit Suit',style: TextStyle(color: Colors.white),),
            trailing: GestureDetector(
                onTap: (){Navigator.pop(context,'Music/Suit_Suit.mp3');},
                child:Container(
                  height: 30,
                  width: 60,
                  color: Colors.red,
                  child: Center(child: Text('Use',style: TextStyle(color: Colors.white),)),
                )
            ),
          ),
        ],
        /*child: ListTile(
          leading: isPlaying==false?IconButton(icon: Icon(Icons.play_circle_filled,color: Colors.white,),onPressed: (){
            setState(() {
              audioCache.play('Music/Alone.mp3');
              isPlaying=true;
            });},):
          IconButton(icon: Icon(Icons.pause,color: Colors.white,),onPressed: (){;setState(() {
            audioplayer.pause();
            isPlaying=false;
          });}),
          title: Text('Music name',style: TextStyle(color: Colors.white),),
        ),*/
      ),*/
    );
  }
}
class SongsList extends StatefulWidget {
  @override
  String path;
  SongsList(String s){
    path=s;
  }
  _SongsListState createState() => _SongsListState(path);
}

class _SongsListState extends State<SongsList> {
  @override
  bool isLoading=false;
  String s;
  bool isPlaying=false;
  String time;
  String _HindiSongsfile;
  static AudioPlayer audioplayer=new AudioPlayer();
  StorageReference str=FirebaseStorage.instance.ref();
  bool isDownloading=false;
  bool downloaded=false;
  String audioPath;
  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
  final FlutterFFprobe _flutterFFprobe = new FlutterFFprobe();
  String music;
  _SongsListState(String s1){
    s=s1;
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(s),
        backgroundColor: Colors.black12,
      ),
      body: isDownloading?Center(child: CircularProgressIndicator(),):StreamBuilder(
        stream: Firestore.instance.collection('Music').document(s).collection(s).orderBy('Name',descending: false).snapshots(),
        builder: (context,snapshots){
          if(!snapshots.hasData){
            return Center(child: CircularProgressIndicator(),);
          }
          else{
            return ListView.builder(itemCount: snapshots.data.documents.length,
                itemBuilder: (BuildContext context, int i){
                  return GestureDetector(
                    onTap: (){audiodownload(snapshots.data.documents[i]['URL']);},
                    child: ListTile(
                      title: Text(snapshots.data.documents[i]['Name'],style: TextStyle(color: Colors.white),),
                      trailing: GestureDetector(
                          onTap: (){use(snapshots.data.documents[i]['URL'],snapshots.data.documents[i]['Name']);},
                          child:Container(
                            height: 30,
                            width: 60,
                            color: Colors.red,
                            child: Center(child: Text('Use',style: TextStyle(color: Colors.white),)),
                          )
                      ),
                    ),
                  );
                } );
          }
        },
      ),
    );
  }
  Future<void> use(String s,String name) async{
    audioPath='';
    setState(() {
      isDownloading=true;
    });
    final Directory extDir = await getApplicationDocumentsDirectory();
    audioPath='${extDir.path}/audio/song.mp3';
    print(s);
    // final taskId=await FlutterDownloader.enqueue(url: s, savedDir: extDir.path,showNotification: true,openFileFromNotification: true);
    //await FlutterDownloader.open(taskId: taskId);
    Dio dio=Dio();
    await dio.download(s, audioPath).then((value) => print(value.data));
    await _flutterFFprobe.getMediaInformation('${audioPath}').then((value) => time='${value['duration']/1000}');
    Navigator.pushReplacement(context, new MaterialPageRoute(builder:(BuildContext context)=>RecordVideo(audioPath,name,s,time)));
  }
  /*Widget playbuttonpressed(String s){
    return isDownloading==false?downloaded?isPlaying?IconButton(icon:Icon(Icons.pause,color: Colors.white),onPressed:(){audioplayer.pause();setState(() {
      isPlaying=false;
    });} ,):IconButton(icon:Icon(Icons.play_circle_filled,color: Colors.white),onPressed: (){audioplayer.resume();setState(() {
      isPlaying=true;
    });},):IconButton(icon:Icon(Icons.play_circle_filled,color: Colors.white),onPressed: (){print('s');audiodownload(s);},):IconButton(icon:Icon(Icons.file_download,color: Colors.white,),);
  }*/
  Future<void> audiodownload(String s) async{
    audioPath='';
    setState(() {
      isDownloading=true;
    });
    final Directory extDir = await getApplicationDocumentsDirectory();
    audioPath='${extDir.path}/audio/song.mp3';
    print(s);
    // final taskId=await FlutterDownloader.enqueue(url: s, savedDir: extDir.path,showNotification: true,openFileFromNotification: true);
    //await FlutterDownloader.open(taskId: taskId);
    Dio dio=Dio();
    await dio.download(s, audioPath).then((value) => print(value.data));
    await _flutterFFprobe.getMediaInformation('${audioPath}').then((value) => time='${value['duration']/1000}');
    /*try  {
     // await _flutterFFmpeg.execute("-i ${s} ${audioPath}").then((rc) => print("FFmpeg process exited with rc $rc"+"-"+'music stored done'));
     // await dio.download(s, audioPath).then((value) => print(value.data));
      WidgetsFlutterBinding.ensureInitialized();
      await FlutterDownloader.initialize(
          debug: true // optional: set false to disable printing logs to console
      );
     final taskId=await FlutterDownloader.enqueue(url: s, savedDir: audioPath);
      FlutterDownloader.open(taskId: taskId);
      print('done');
      setState(() {
        isDownloading=false;
        downloaded=true;
      });
    } on Exception catch (e) {
      // TODO
      print(e);
    }*/
    print('l');
    setState(() {
      isDownloading=false;
      downloaded=true;
      isPlaying=false;
    });
    //audioplayer.play(audioPath,isLocal: true);
    print('o');
    Navigator.push(context,new MaterialPageRoute(builder:(context)=>iconchanger(audioPath,time)));
  }
  Future<void> slide() async{
    //audioplayer.play(audioPath,isLocal: true);
    return showDialog(context: context,builder: (_)=>new AlertDialog(content: isPlaying==false?IconButton(icon: Icon(Icons.play_circle_filled),onPressed: (){isPLay();audioplayer.play(audioPath,isLocal: true);print(isPlaying);}):IconButton(icon:Icon(Icons.pause_circle_filled),onPressed: (){isPLay();audioplayer.stop();audioplayer.dispose();},),
      actions: <Widget>[
        GestureDetector(onTap:(){Navigator.pop(context);audioplayer.dispose();},child: Text('Ok',style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),)),
      ],));
  }
  void isPLay(){
    setState(() {
      isPlaying=true;
    });
    print(isPlaying);
  }
  Future<void> slider() async{
    return showDialog(context: context,builder: (_)=>new AlertDialog(
      content: isDownloading?Center(child:CircularProgressIndicator()):isPlaying?IconButton(icon: Icon(Icons.play_circle_filled),onPressed: (){setState(() {
        isPlaying=true;
      });audioplayer.resume();}):IconButton(icon:Icon(Icons.pause_circle_filled),onPressed: (){setState(() {
        isPlaying=false;
      });audioplayer.pause();},),
      actions: <Widget>[
        isDownloading?GestureDetector(onTap:(){audioplayer.dispose();Navigator.pop(context);},child: Text('Ok')):Container(),
      ],
    ));
  }
}
class iconchanger extends StatefulWidget {
  @override
  String s,l;
  iconchanger(String k,String h){
    s=k;
    l=h;
  }
  _iconchangerState createState() => _iconchangerState(s,l);
}

class _iconchangerState extends State<iconchanger> {
  @override
  bool isPlaying=false;
  String audioPath,time;
  Timer timer;
  int _counter=0;
  _iconchangerState(String k,String h){
    audioPath=k;
    time=h;
  }
  void initState(){
    print(_counter);
    startTime();
    audioplayer.play(audioPath,isLocal: true);
    setState(() {
      isPlaying=true;
    });
  }
  void startTime(){
    timer=Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        print(double.parse(time)+1);
        if(_counter<double.parse(time)+1){
          _counter++;
          print(_counter);
        }
        else{
          timer.cancel();
          Navigator.pop(context);
        }
      });
    });
  }
  final AudioPlayer audioplayer=new AudioPlayer();
  Widget build(BuildContext context) {
    return AlertDialog(
      content: isPlaying==false?IconButton(icon: Icon(Icons.play_circle_filled,size: 40,),onPressed: (){setState(() {
        isPlaying=true;
      });startTime();audioplayer.resume();print(isPlaying);}):IconButton(icon:Icon(Icons.pause_circle_filled,size:40),onPressed: (){setState(() {
        isPlaying=false;
      });setState(() {
        timer.cancel();
      });audioplayer.pause();},),
      actions: <Widget>[
        Text('$_counter/$time',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
        GestureDetector(onTap:(){audioplayer.dispose();setState(() {
          timer.cancel();
        });Navigator.pop(context);},child: Text('Ok',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),)),
      ],
    );
  }
}



