import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:myapp/widget/mepage.dart';
import 'package:path/path.dart' as join;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'music.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'Home.dart';
class RecordVideo extends StatefulWidget {
  @override
  String _music;
  String _musicurl;
  String _musicname;
  String time;
  RecordVideo(String s,String n,String u,String l){
    _music=s;
    _musicurl=u;
    _musicname=n;
    time=l;
  }
  _RecordVideoState createState() => _RecordVideoState(_music,_musicname,_musicurl,time);
}
class _RecordVideoState extends State<RecordVideo> {
  @override
  CameraController _controller;
  List<CameraDescription> _cameras;
  bool isRecording=false;
  String videopath;
  String speed='1*';
  static AudioPlayer audioplayer=new AudioPlayer();
  static AudioCache audioCache=new AudioCache(fixedPlayer: audioplayer);
  File video;
  String _music;
  Future<void> _initializeControllerFuture;
  String _musicurl;
  String _musicname;
  String time;
  bool startrecording=false;
  Timer timer;
  int _counter=0;
  _RecordVideoState(String s,String n,String u,String l){
    _music=s;
    _musicurl=u;
    _musicname=n;
    time=l;
  }
  void initState() {
    _initCamera();
    super.initState();
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
          stopVideoRecording();
        }
      });
    });
  }
  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras[1], ResolutionPreset.high);
    _controller.addListener(() {if(mounted){setState(() {
    });}});
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }
  void dispose() {
    audioplayer.dispose();
    print('dispose');
    _controller.dispose();
    super.dispose();
  }
  Future<void> _onCameraSwitch() async {
    final CameraDescription cameraDescription =
    (_controller.description == _cameras[0]) ? _cameras[1] : _cameras[0];
    if (_controller != null) {
      await _controller.dispose();
    }
    _controller = CameraController(cameraDescription, ResolutionPreset.high);
    _controller.addListener(() {
      if (mounted) setState(() {});
      if (_controller.value.hasError) {
        Fluttertoast.showToast(
            msg: 'Camera error ${_controller.value.errorDescription}',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    });

    try {
      _controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }
  Widget _showCameraException(CameraException e){
    Fluttertoast.showToast(
        msg: '${e}',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
  Future<String> startVideoRecording() async {
    setState(() {
      startrecording=true;
    });
    startTime();
    print('startVideoRecording');
    if (!_controller.value.isInitialized) {
      return null;
    }
    setState(() {
      isRecording = true;
    });

    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/media';
    await Directory(dirPath).create(recursive: true);
    var u='${DateTime.now()}'.split(' ');
    String k='';
    for(int i=0;i<u.length;i++){
      k+=u[i];
    }
    final String filePath = '$dirPath/${k}.mp4';
    videopath=filePath;

    if (_controller.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return null;
    }

    try {
      await _controller.startVideoRecording(filePath);
      audioplayer.play(_music,isLocal: true);
      print('k');

    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }
  Future<void> stopVideoRecording() async {
    setState(() {
      startrecording=false;
    });
    timer.cancel();
    audioplayer.stop();
    print('stop reocrding');
    if (!_controller.value.isRecordingVideo) {
      print('u');
      return null;
    }
    setState(() {
      isRecording = false;
    });
    try {
      await _controller.stopVideoRecording();
      print('l');
    } on CameraException catch (e) {
      print(e);
      print('error');
      _showCameraException(e);
      return null;
    }
    Navigator.push(context,new MaterialPageRoute(builder: (context)=>VideoShow(videopath,_music,speed,_musicname,_musicurl)));

  }
  @override
  Widget cameraview(){
    final size = MediaQuery.of(context).size;
    if(_controller==null){
      return Center(child: CircularProgressIndicator(),);
    }
    if (!_controller.value.isInitialized) {
      return Container();
    }
    print(min(size.height/size.width,size.width/size.height));
    return ClipRect(
      child: Container(
        child: Transform.scale(
          scale: _controller.value.aspectRatio / size.aspectRatio,
          child: Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: CameraPreview(_controller),
            ),
          ),
        ),
      ),
    );
  }
  double _getImageZoom(MediaQueryData data) {
    final double logicalWidth = data.size.width;
    final double logicalHeight = data.size.aspectRatio * logicalWidth;
    final EdgeInsets padding = data.padding;
    final double maxLogicalHeight =
        data.size.height - padding.top - padding.bottom;

    return maxLogicalHeight / logicalHeight;
  }
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          cameraview(),
          Column(
            children: <Widget>[
              Container(
                height: 20,
              ),
              /*Container(
                child: Center(
                  child:FlatButton(
                    color: Colors.grey,
                    textColor: Colors.white,
                    child: Text('Speed'),
                    onPressed: (){
                      showDialog(context: context,builder: (_)=>new AlertDialog(
                        actions: <Widget>[
                          FlatButton(
                            child: Text('1/4X'),
                            onPressed: (){
                              setState(() {
                                speed='4.0*';
                              });
                              Navigator.pop(context);
                            },
                          ),
                          FlatButton(
                            child: Text('1/2X'),
                            onPressed: (){
                              setState(() {
                                speed='2.0*';
                              });
                              Navigator.pop(context);
                            },
                          ),
                          FlatButton(
                            child: Text('1X'),
                            onPressed: (){
                              setState(() {
                                speed='1.0*';
                              });
                              Navigator.pop(context);
                            },
                          ),
                          FlatButton(
                            child: Text('2X'),
                            onPressed: (){
                              setState(() {
                                speed='0.5*';
                              });
                              Navigator.pop(context);
                            },
                          ),
                          FlatButton(
                            child: Text('4X'),
                            onPressed: (){
                              setState(() {
                                speed='0.25*';
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ));
                    },
                  ),
                ),
              ),*/
              Expanded(
                child: Container(),
              ),
              startrecording?LinearProgressIndicator(
                value: _counter.toDouble()/double.parse(time),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              ):Container(),
              Divider(color: Colors.white,thickness: 1,),
              Container(
                height: 100,
                width:  MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _music==''?IconButton(icon: Icon(Icons.music_note,color: Colors.white,size: 40,),onPressed: (){Navigator.push(context,new MaterialPageRoute(builder:(context)=>Music())).then((value) => _music=value);}):IconButton(icon: Icon(Icons.music_note,color: Colors.red,size: 40,)),
                    isRecording?IconButton(icon:Icon(Icons.pause_circle_filled,color: Colors.red,size: 50,),onPressed: (){stopVideoRecording();},):IconButton(icon: Icon(Icons.play_circle_filled,color: Colors.red,size: 50,),onPressed: (){startVideoRecording();
                    },),
                    IconButton(icon: Icon(Icons.switch_camera,color: Colors.white,size: 40,),onPressed: (){_onCameraSwitch();},),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
class VideoShow extends StatefulWidget {
  @override
  String s;
  String music;
  String speed;
  String _musicname;
  String _musicurl;
  VideoShow(String k,String k1,String sp,String n,String u){
    s=k;
    music=k1;
    speed=sp;
    _musicname=n;
    _musicurl=u;
  }
  _VideoShowState createState() => _VideoShowState(s,music,speed,_musicname,_musicurl);
}

class _VideoShowState extends State<VideoShow> {
  @override
  String s;
  String music;
  String musicPath;
  bool isLoading=false;
  String speed;
  String speedPath;
  String finalvideopath;
  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
  final FlutterFFprobe _flutterFFprobe = new FlutterFFprobe();
  static AudioPlayer audioplayer=new AudioPlayer();
  static AudioCache audioCache=new AudioCache(fixedPlayer: audioplayer);
  String _musicname;
  String _musicurl;
  bool isUploading=false;
  double _count=0.0;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  _VideoShowState(String k,String k1,String sp,String n,String u){
    s=k;
    music=k1;
    speed=sp;
    _musicname=n;
    _musicurl=u;
  }
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    // Create an store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.
    print(isUploading);
    createpath();
    super.initState();
  }
    void createpath() async{
      setState(() {
        isLoading=true;
      });
      final Directory extDir = await getApplicationDocumentsDirectory();
      final String dirPath = '${extDir.path}/output';
      await Directory(dirPath).create(recursive: true);
      var u0='${DateTime.now()}'.split(' ');
      String k0='';
      for(int i=0;i<u0.length;i++) {
        k0 += u0[i];
      }
      speedPath = '$dirPath/${k0}.mp4';
      speedPath = s;
      var u='${DateTime.now()}'.split(' ');
      String k='';
      for(int i=0;i<u.length;i++) {
        k += u[i];
      }
      final String filePath = '$dirPath/${k}.mp4';
      String time;
      await _flutterFFprobe.getMediaInformation('${speedPath}').then((value) => time='${value['duration']/1000}');
      print(time+"-------"+'k');
      var u1='${DateTime.now()}'.split(' ');
      String k1='';
      for(int i=0;i<u1.length;i++) {
        k1+= u1[i];
      }
       musicPath = '$dirPath/${k1}.mp3';
      await _flutterFFmpeg.execute("-i ${music} -ss 0 -to ${time} -c copy ${musicPath}").then((rc) => print("FFmpeg process exited with rc $rc"+"-"+'music'));
      await _flutterFFmpeg.execute('-i $speedPath -c copy -an $filePath').then((rc) => print("FFmpeg process exited with rc $rc"+"-"+'video without audio'));
      var u2='${DateTime.now()}'.split(' ');
      String k2='';
      for(int i=0;i<u2.length;i++) {
        k2+= u2[i];
      }
      finalvideopath='$dirPath/${k2}.mp4';
      await _flutterFFmpeg.execute('-i ${filePath} -i ${musicPath} -codec copy -shortest ${finalvideopath}').then((rc) => print("FFmpeg process exited with rc $rc"+"-"+'final video'));
    //  await _flutterFFmpeg.execute("-i ${s} ${filePath}").then((rc) => print("FFmpeg process exited with rc $rc"));
     // print(File(filePath)==null);
      _controller = VideoPlayerController.file(File(finalvideopath));
      _controller.setLooping(true);
      _initializeVideoPlayerFuture = _controller.initialize();
      print('done');
      setState(() {
        isLoading=false;
      });
  }// <= your ByteData

//=======================
  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    print('dispose');
    super.dispose();
  }
  Widget ko(){
    return Center(
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(margin: EdgeInsets.only(left: 20,),child: Text('Please Do not go back while uploading',style: TextStyle(fontSize: 20,color: Colors.blue,fontWeight: FontWeight.bold),)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(margin: EdgeInsets.only(left: 20,top: 20,bottom: 20),child: Text('Uploading',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.blue,),)),
                Expanded(child: Container(),),
                Container(margin: EdgeInsets.only(right: 20),child: Text('${(_count*100).toStringAsFixed(2)}%',style: TextStyle(fontSize: 20,color: Colors.blue,fontWeight: FontWeight.bold))),
                SizedBox(width: 7,)
              ],
            ),
            SizedBox(height: 10,),
            Container(margin: EdgeInsets.only(left: 20,right: 20,bottom: 20),child:LinearProgressIndicator(value:_count,valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),backgroundColor: Colors.black12 ,)),
          ],
        ),
      ),
    );
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.black,
      // Use a FutureBuilder to display a loading spinner while waiting for the
      // VideoPlayerController to finish initializing.
      body: isLoading?Center(child: CircularProgressIndicator(),):isUploading?ko():Stack(
        children: <Widget>[
          FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              final size = MediaQuery.of(context).size;
              final deviceRatio = size.width / size.height;
              if (snapshot.connectionState == ConnectionState.done) {
                // If the VideoPlayerController has finished initialization, use
                // the data it provides to limit the aspect ratio of the video.
                return Transform.scale(
                  scale: _controller.value.aspectRatio / deviceRatio,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                );
              } else {
                // If the VideoPlayerController is still initializing, show a
                // loading spinner.
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
          Column(
            children: <Widget>[
              Container(
                margin:  EdgeInsets.only(top:20,),
                height: 70,
                  child:Row(
                    children: <Widget>[
                      Container(width: 10,),
                      IconButton(icon:Icon(Icons.cancel,color: Colors.white,size: 30,),onPressed: (){Navigator.pop(context);},),
                      GestureDetector(
                        onTap: (){upload();},
                        child: Container(
                          margin: EdgeInsets.only(left: 290),
                          alignment: Alignment.centerRight,
                          height: 100,
                          width: 60,
                          child: IconButton(icon:Icon(Icons.verified_user,color: Colors.white,size: 30,))//Center(child: Text('Upload',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize:14,letterSpacing: 2.0),)),
                        ),
                      ),
                    ],
                  )
              ),
              Expanded(child: Container(),),
              Container(height: 120,child: Center(child: IconButton(icon: isLoading?CircularProgressIndicator():Icon(
                _controller.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,color: Colors.red,size: 50,
              ), onPressed: () {
                // Wrap the play or pause in a call to `setState`. This ensures the
                // correct icon is shown.
                setState(() {
                  // If the video is playing, pause it.
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    // If the video is paused, play it.
                    _controller.play();
                  }
                });
              }, ),),)
            ],
          )
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
  Future<void> upload() async{
    setState(() {
      isUploading=true;
    });
    audioplayer.dispose();
    _controller.dispose();
    String thumbnailfileurl;
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/output';
    await Directory(dirPath).create(recursive: true);
    var u0='${DateTime.now()}'.split(' ');
    String k0='';
    for(int i=0;i<u0.length;i++) {
      k0 += u0[i];
    }
    String thumbnailpath='$dirPath/${k0}.png';
    await _flutterFFmpeg.execute('-i ${finalvideopath} -ss 00:00:01 -vframes 1 ${thumbnailpath}').then((rc) => print("FFmpeg process exited with rc $rc"+"-"+'thumbnail'));
    int count;
    String _fileURL;
    FirebaseUser user=await FirebaseAuth.instance.currentUser();
    await Firestore.instance.collection('users').document('${user.uid}').get().then((value){
        if(value.data.length>0){
          setState(() {
            count=value.data['videocount'];
            int post=value.data['Post'];
            count++;post++;
            print(count);
            Firestore.instance.collection('users').document('${user.uid}').updateData({'videocount':count,'Post':post});
          });
        }
      });
      StorageReference st = FirebaseStorage.instance.ref().child('${user.uid}/files/Videos/${count}/V');
      StorageUploadTask uploadTask = st.putFile(File(finalvideopath));
      uploadTask.events.listen((event) {setState(() {
  _count=(event.snapshot.bytesTransferred/event.snapshot.totalByteCount)/1.5;
});
});
      await uploadTask.onComplete;
      await st.getDownloadURL().then((fileURL) {
        setState(() {
          _fileURL = fileURL;
        });
      });
    StorageReference str = FirebaseStorage.instance.ref().child('${user.uid}/files/Videos/${count}/V/Thumbnail');
    StorageUploadTask uploadTask1= str.putFile(File(thumbnailpath));
    uploadTask.events.listen((event) {setState(() {
  _count=0.67+(event.snapshot.bytesTransferred/event.snapshot.totalByteCount)/5;
});
});
    await uploadTask1.onComplete;
    await str.getDownloadURL().then((fileURL) {
      setState(() {
        thumbnailfileurl = fileURL;
      });
    });
      await Firestore.instance.collection('users').document('${user.uid}').collection('Videos').document('${count}').setData({'Likes':0,'VideoURL' :_fileURL,'fileType':'Video','ImageURL':thumbnailfileurl,'MusicURL':_musicurl,'MusicName':_musicname});
      setState(() {
        isUploading=false;
      });
      setState(() {
        _count=1.0;
      });
    Fluttertoast.showToast(
        msg: 'Video Uploaded',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
    );
    Navigator.push(context,new MaterialPageRoute(builder:(context)=>Home(user)));
      print('URL uploaded in Videos');
  }
}