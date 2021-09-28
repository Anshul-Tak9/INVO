import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/Account_Page.dart';
import 'package:firebase_storage/firebase_storage.dart';
class signuppage extends StatefulWidget {
  @override
  _signuppageState createState() => _signuppageState();
}
class _signuppageState extends State<signuppage> {
  @override
  String _email,_password,_Name,_Username;
  final db=Firestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'),
      ),
      body: Form(
        key :_formKey,
        child: Column(
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          TextFormField(
            // ignore: missing_return
            validator: (input){
              if(input.isEmpty){
                return 'please provide an Name';
              }
            },
            onSaved: (input)=>_Name=input,
            decoration: InputDecoration(
              labelText: 'Name',
            ),
          ),
          SizedBox(
            height: 20,
          ),
          TextFormField(
            // ignore: missing_return
            validator: (input){
              if(input.isEmpty){
                return 'please provide an Username';
              }
            },
            onSaved: (input)=>_Username=input,
            decoration: InputDecoration(
              labelText: 'Username',
            ),
          ),
          SizedBox(
            height: 20,
          ),
          TextFormField(
            // ignore: missing_return
            validator: (input){
              if(input.isEmpty){
                return 'please provide an email';
              }
            },
            onSaved: (input)=>_email=input,
            decoration: InputDecoration(
              labelText: 'Email',
            ),
          ),
          SizedBox(
              height: 20,
          ),
          TextFormField(
            obscureText: true,
            // ignore: missing_return
            validator: (input){
              if(input.length<6){
                return 'Your password needs to be atleast 6 characters';
              }
            },
            onSaved: (input)=>_password=input,
            decoration: InputDecoration(
              labelText: 'Password',
            ),
          ),
          SizedBox(
            height: 20,
          ),
          RaisedButton(
            child: Text('SIGN UP'),
            onPressed: SignUp,
          )
        ],
      ),
      ),
    );
  }
  Future<void> SignUp() async{
    final _formState=_formKey.currentState;
    if(_formState.validate()){
      _formState.save();
      try{
        AuthResult auth =await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email, password: _password);
      //  auth.user.uid
        await db.collection("users").document(auth.user.uid).setData({'Name' :_Name,'Username' : _Username,'UID':auth.user.uid.toString(),'Followers':0,'Followings':0,'InstagramId':'Anonymous ','YouTubeId' : 'Anonymous ','bio':'Anonymous','videocount' :0,'imagecount':0,'Post':0,'searchKey':_Name.substring(0,1).toUpperCase(),'ProfilePicURL' : 'https://firebasestorage.googleapis.com/v0/b/invoke-d540d.appspot.com/o/Unknown_User%2FUnkown_user.jpg?alt=media&token=2fcd4f8b-1ef3-44c2-a4ec-3c49f9ded43d'});
        Navigator.pop(context,true);
      }
      catch(e){
        print(e.message);
      }

    }
  }
}