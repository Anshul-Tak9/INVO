import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/my_flutter_app_icons.dart';
import 'package:myapp/widget/mepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
class BottomToolbar extends StatelessWidget{
  FirebaseUser user;
  BottomToolbar(FirebaseUser u){
    user=u;
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(icon:Icon(MyFlutterApp.home),iconSize: 30,color: Colors.black,onPressed: (){},),
          IconButton(icon : Icon(MyFlutterApp.search),iconSize: 30,color: Colors.black,onPressed: (){},),
          customsreateicon,
          IconButton(icon : Icon(MyFlutterApp.message),iconSize: 30,color: Colors.black,onPressed: (){},),
          IconButton(icon : Icon(Icons.people),iconSize: 30,color: Colors.black,onPressed: (){
            Navigator.push(context,new MaterialPageRoute(builder: (context)=>mepage(user)));
          },),
          ],),
    );
  }
  Widget get customsreateicon => Container(
      width: 45,height: 27,
      child: Stack(
        children:<Widget> [
          Container(
            margin: EdgeInsets.only(left:10.0),
            width: 38,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(7.0),
            ),
          ),
         Container(
            margin: EdgeInsets.only(right:10.0),
            width: 38,
           decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(7.0),
          ),
         ),
          Center(
            child :Container(
              height : double.infinity,
              width: 38,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(7.0),
              ),
              child : IconButton(icon : Icon(Icons.add),iconSize: 20,color: Colors.white,onPressed: (){},),
            )
          )
        ],
      ),
  );

}
