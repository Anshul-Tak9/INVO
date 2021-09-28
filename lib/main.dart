import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/EmailAndPhone.dart';
import 'package:myapp/widget/videodecription.dart';
import 'package:myapp/widget/actiontoolbar.dart';
import 'package:myapp/widget/bottomtoolbar.dart';
import 'package:video_player/video_player.dart';
import 'package:myapp/setup/createaccount.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/Account_Page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'SplashScreen.dart';
void main() async{
  Crashlytics.instance.enableInDevMode = true;

  // Pass all uncaught errors to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
  );
  runZoned(() {
    runApp(AppPage());
  }, onError: Crashlytics.instance.recordError);

}


class AppPage extends StatefulWidget {
  @override
  _AppPageState createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'INVO',
      home: SplashScreen(),
    );
  }
}

class BackGroundvideo extends StatefulWidget {
  FirebaseUser user;
  BackGroundvideo(FirebaseUser user){
    this.user=user;
  }
  @override
  State<StatefulWidget> createState() => BackGroundvideoState(user);
}
class BackGroundvideoState extends State<BackGroundvideo> {
  VideoPlayerController _controller;
  FirebaseUser user;

  BackGroundvideoState(FirebaseUser user){
    this.user=user;
  }


  void initState() {
    super.initState();
   /* _controller=VideoPlayerController.asset("assets/videos/dittu.mp4")
    ..initialize().then((_){
      _controller.play();
      //_controller.pause();
      _controller.setLooping(true);
      setState(() {});
    });*/
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: Stack(
      children: <Widget>[
        SizedBox.expand(
          child: FittedBox(
            // If your background video doesn't look right, try changing the BoxFit property.
            // BoxFit.fill created the look I was going for.
            fit: BoxFit.fill,
            child: SizedBox(
             // width: _controller.value.size?.width ?? 0,
              //height: _controller.value.size?.height ?? 0,
              // child: VideoPlayer(_controller),
            ),
          ),
        ),
        myapp(user),
      ],
    ));
  }
}

class myapp extends StatelessWidget {
  static FirebaseUser user;


  myapp(FirebaseUser use){
    user=use;
  }

  @override
  Widget get Topsection => Container(
        height: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Following  |  ', style: TextStyle(fontSize: 17,color: Colors.white)),
            Text('For You',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0,color: Colors.white)),
          ],
        ),
      );

  Widget get middlesection {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
         // VideoDescription(user.uid),
          //ActionToolbar(),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(children: <Widget>[
        Topsection,
        middlesection,
        Container(
          height: 50,
        )
        //BottomToolbar(user),
      ]),
    );
  }
}
