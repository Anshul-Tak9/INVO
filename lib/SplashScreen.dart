import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'EmailAndPhone.dart';
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  int _counter=3;
  Timer timer;
  void initState(){
    print(_counter);
    startTime();
  }
  void startTime(){
    _counter=3;
    timer=Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if(_counter>0){
          _counter--;
          print(_counter);
        }
        else{
          timer.cancel();
          Navigator.push(context,
              new MaterialPageRoute(builder: (context) => EmailAndPhoneAuth()));
        }
      });
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black26,
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 250,),
            Container(
              margin: EdgeInsets.only(left: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 170,width: 170,child: Image(image:AssetImage('assets/Images/ui.jpg'))),
                  Expanded(
                    child: Container(
                      child: Row(
                        children: <Widget>[
                          Text('I',style: TextStyle(fontSize: 80,fontWeight: FontWeight.bold,color: Colors.red),),
                          Text('N',style: TextStyle(fontSize: 80,fontWeight: FontWeight.bold,color: Colors.yellow),),
                          Text('V',style: TextStyle(fontSize: 80,fontWeight: FontWeight.bold,color: Colors.green),),
                          Text('O',style: TextStyle(fontSize: 80,fontWeight: FontWeight.bold,color: Colors.blue),),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(child: Container(),),
            Text('Indian Video Entertaining App',style: TextStyle(fontSize:20,fontWeight: FontWeight.bold,color: Colors.white,letterSpacing: 1.0),),
            SizedBox(height: 200,),
          ],
        ),
      ),
    );
  }
}
