import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/widget/Editpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Home.dart';
class PhoneAuthentication extends StatefulWidget {
  @override
  _PhoneAuthenticationState createState() => _PhoneAuthenticationState();
}

class _PhoneAuthenticationState extends State<PhoneAuthentication> {
  String phoneNo;
  String smsCode;
  String verificationId;
  final db=Firestore.instance;
  @override
  Future<void> verifyPhone(BuildContext context) async{
    final PhoneCodeAutoRetrievalTimeout autoRetrieval=(String verID){
      this.verificationId=verID;
    };
    final PhoneCodeSent smsCodeSent=  (String verID,[int forceCodeResend]){
      this.verificationId=verID;
      smsCodeDailog(context);
    };
    final PhoneVerificationCompleted verifiedSuccess=(AuthCredential credential) async {
      Navigator.pop(context);
      AuthResult result= await FirebaseAuth.instance.signInWithCredential(credential);
      FirebaseUser user=result.user;
      await db.collection("users").document(user.uid).setData({'Name' :'InvoUser','Username' : '@InvoUser','UID':user.uid.toString(),'Followers':0,'Followings':0,'InstagramId':'Anonymous ','YouTubeId' : 'Anonymous ','bio':'Anonymous','videocount' :0,'imagecount':0,'Post':0,'searchKey':'I','ProfilePicURL' : 'https://firebasestorage.googleapis.com/v0/b/invoke-d540d.appspot.com/o/Unknown_User%2FUnkown_user.jpg?alt=media&token=2fcd4f8b-1ef3-44c2-a4ec-3c49f9ded43d'});
      if(user!=null){
        Navigator.push(context,
            new MaterialPageRoute(builder: (context) => Home(user)));
      }
      print('verified');
    };
    final PhoneVerificationFailed veriFailed=(AuthException exception){
      print('${exception.message}');
    };
    await FirebaseAuth.instance.verifyPhoneNumber(phoneNumber: this.phoneNo, timeout: const Duration(seconds: 20), verificationCompleted: verifiedSuccess, verificationFailed: veriFailed, codeSent: smsCodeSent, codeAutoRetrievalTimeout: autoRetrieval);
  }
  Future<bool> smsCodeDailog(BuildContext context){
    return showDialog(context: context,barrierDismissible: false,builder: (BuildContext){
      return new AlertDialog(
       title: Text('Enter OTP'),
        content: TextField(
          onChanged: (value){
            this.smsCode=value;
          },
        ),
        contentPadding: EdgeInsets.all(10),
        actions: <Widget>[
          FlatButton(
            child: Text('Confirm'),
            textColor: Colors.white,
            color: Colors.blue,
            onPressed: () async{
              AuthCredential credential =PhoneAuthProvider.getCredential(verificationId: this.verificationId, smsCode: this.smsCode);
              AuthResult result= await FirebaseAuth.instance.signInWithCredential(credential);
              FirebaseUser user=result.user;
              await db.collection("users").document(user.uid).setData({'Name' :'InvoUser','Username' : '@InvoUser','UID':user.uid.toString(),'Followers':0,'Followings':0,'InstagramId':'Anonymous ','YouTubeId' : 'Anonymous ','bio':'Anonymous','videocount' :0,'imagecount':0,'Post':0,'searchKey':'I','ProfilePicURL' : 'https://firebasestorage.googleapis.com/v0/b/invoke-d540d.appspot.com/o/Unknown_User%2FUnkown_user.jpg?alt=media&token=2fcd4f8b-1ef3-44c2-a4ec-3c49f9ded43d'});
              if(user!=null){
                Navigator.push(context,
                    new MaterialPageRoute(builder: (context) => Home(user)));
              }
              else{
                print('Error');
              }
            },

          )
        ],
      );
    });
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        title: Text('Phone Authentication'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(hintText: 'Enter a Phone No.'),
                onChanged: (value){
                  this.phoneNo=value;
                },
              ),
              SizedBox(height: 10,),
              RaisedButton(
                onPressed: (){verifyPhone(context);},
                child: Text('Verify'),
                textColor: Colors.white,
                elevation: 7.0,
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
