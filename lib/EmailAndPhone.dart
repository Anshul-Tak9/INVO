import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/Account_Page.dart';
import 'package:myapp/PhoneAuth.dart';
import 'PhoneAuth.dart';
import 'Account_Page.dart';
class EmailAndPhoneAuth extends StatefulWidget {
  @override
  _EmailAndPhoneAuthState createState() => _EmailAndPhoneAuthState();
}

class _EmailAndPhoneAuthState extends State<EmailAndPhoneAuth> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF73AEF5),
                  Color(0xFF61A4F1),
                  Color(0xFF478DE0),
                  Color(0xFF398AE5),
                  // Color(0xFF1565C0),
                ],
                stops: [0.1, 0.4, 0.7, 0.9],
              ),
            ),
          ),
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: <Widget>[
            Container(
                padding: EdgeInsets.all(15.0),
                width: double.infinity,
                child: RaisedButton(
                    elevation: 5.0,
                    onPressed: (){Navigator.push(context,
                        new MaterialPageRoute(builder: (context) => homepage()));},
                    padding: EdgeInsets.all(15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    color: Colors.white,
                    child: Text(
                      'Email',
                      style: TextStyle(
                          color: Color(0xFF478DE0),
                          letterSpacing: 1.5,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'OpenSans'),
                    ))),
            Container(
                padding: EdgeInsets.all(15.0),
                width: double.infinity,
                child: RaisedButton(
                    elevation: 5.0,
                    onPressed: (){Navigator.push(context,
                        new MaterialPageRoute(builder: (context) => PhoneAuthentication()));},
                    padding: EdgeInsets.all(15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    color: Colors.white,
                    child: Text(
                      'Phone',
                      style: TextStyle(
                          color: Color(0xFF478DE0),
                          letterSpacing: 1.5,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'OpenSans'),
                    ))),
          ],
        ),
      ),
        ],
      ),
    );
  }
}
