import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:myapp/setup/createaccount.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';
import 'Home.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class homepage extends StatefulWidget {
  @override
  _homepageState createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  @override
  final db=Firestore.instance;
  bool isLoadingg=false;
  String _email, _password;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GoogleSignIn _googleSignIn=new GoogleSignIn();
  Future<void> _signINWITHGOOGlE() async{
    try {
      GoogleSignInAccount gsia=await _googleSignIn.signIn();
      GoogleSignInAuthentication gSA=await gsia.authentication;
      AuthResult res=await FirebaseAuth.instance.signInWithCredential(GoogleAuthProvider.getCredential(idToken: (await gsia.authentication).idToken, accessToken:  (await gsia.authentication).idToken));
      await db.collection("users").document(res.user.uid).setData({'Name' :res.user.displayName,'Username' : '@'+res.user.displayName,'UID':res.user.uid.toString(),'Followers':0,'Followings':0,'InstagramId':'Anonymous ','YouTubeId' : 'Anonymous ','bio':'Anonymous','videocount' :0,'imagecount':0,'Post':0,'searchKey':res.user.displayName.substring(0,1).toUpperCase(),'ProfilePicURL' : res.user.photoUrl});
      Navigator.push(context,
          new MaterialPageRoute(builder: (context) => Home(res.user)));
    } on Exception catch (e) {
          print(e);
      // TODO
    }
  }
  Widget buildemail() {
    return Form(
     // key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Email',
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 10),
          Container(
              alignment: Alignment.center,
              child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                // ignore: missing_return
                validator: (input) {
                  if (input.isEmpty) {
                    return 'please provide an email';
                  }
                },
                //  onSaved: (input)=>_email=input,
                onSaved: (input) => _email = input,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  //border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 10),
                  prefixIcon: Icon(
                    Icons.email,
                    color: Colors.white,
                  ),
                  hintText: 'Enter Your Email',
                  hintStyle: TextStyle(color: Colors.white),
                ),
              ))
        ],
      ),
    );
  }

  Widget buildpassword() {
    return Form(
      //key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Password',
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 10),
          Container(
              alignment: Alignment.center,
              child: TextFormField(
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                // ignore: missing_return
                validator: (input) {
                  if (input.length < 6) {
                    return 'Your password needs to be atleast 6 characters';
                  }
                },
                onSaved: (input) => _email = input,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  //border: InputBorder.none,
                  //border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.only(top: 10),
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Colors.white,
                  ),
                  hintText: 'Enter Your Password',
                  hintStyle: TextStyle(color: Colors.white),
                ),
              ))
        ],
      ),
    );
  }

  Widget buildloginbutton() {
    return Container(
        padding: EdgeInsets.all(15.0),
        width: double.infinity,
        child: RaisedButton(
            elevation: 5.0,
            onPressed: SignIN,
            padding: EdgeInsets.all(15.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            color: Colors.white,
            child: Text(
              'LOGIN',
              style: TextStyle(
                  color: Color(0xFF478DE0),
                  letterSpacing: 1.5,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'OpenSans'),
            )));
  }

  Widget buildforgotpassword() {
    return Container(
      alignment: Alignment.centerRight,
      child: FlatButton(
        onPressed: () {},
        child: Text(
          'Forgot Password?',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  /* Widget buildloginbutton(){
    return Container(
        padding: EdgeInsets.all(15.0),
        width: double.infinity,
        child : RaisedButton(
            elevation: 5.0,
            onPressed: (){Navigator.push(context, new MaterialPageRoute(builder: (context)=>myapp()));},
            padding: EdgeInsets.all(15.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            color : Colors.white,
            child : Text(
              'LOGIN',style: TextStyle(color: Color(0xFF478DE0),letterSpacing: 1.5,fontSize: 18,fontWeight: FontWeight.bold,fontFamily: 'OpenSans'),
            )
        )
    );
  }*/
  Widget buildgooglelogin() {
    FirebaseUser userg;
    return Column(
      children: <Widget>[
        Text('-OR-', style: TextStyle(color: Colors.white)),
        SizedBox(height: 20),
        Text('Sign in With ', style: TextStyle(color: Colors.white)),
        SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            _signINWITHGOOGlE();
            print('logedin with google');
          },
          child: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 6,
                  ),
                ],
                image: DecorationImage(
                  image: AssetImage('assets/Images/google.png'),
                )),
          ),
        ),
      ],
    );
  }

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
          Container(
            height: double.infinity,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 120,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Sign In',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'OpenSans',
                        fontSize: 30),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Email',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 10),
                        Container(
                          alignment: Alignment.center,
                          child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            validator: (input) {
                              if (input.isEmpty) {
                                return 'please provide an email';
                              }
                              return null;
                            },
                            //  onSaved: (input)=>_email=input,
                            onSaved: (input) => _email = input,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              //border: InputBorder.none,
                              contentPadding: EdgeInsets.only(top: 10),
                              prefixIcon: Icon(
                                Icons.email,
                                color: Colors.white,
                              ),
                              hintText: 'Enter Your Email',
                              hintStyle: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          'Password',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 10),
                        Container(
                            alignment: Alignment.center,
                            child: TextFormField(
                              obscureText: true,
                              keyboardType: TextInputType.visiblePassword,
                              validator: (input) {
                                if (input.length < 6) {
                                  return 'Your password needs to be atleast 6 characters';
                                }
                                return null;
                              },
                              onSaved: (input) => _password = input,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                //border: InputBorder.none,
                                //border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.only(top: 10),
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: Colors.white,
                                ),
                                hintText: 'Enter Your Password',
                                hintStyle: TextStyle(color: Colors.white),
                              ),
                            ))
                      ],
                    ),
                  ),
                  //   buildforgotpassword(),
                      buildloginbutton(),
                        buildgooglelogin(),
                  SizedBox(
                    height: 20,
                  ),
                  buildsignup(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Future<void> SignIN() async {
    final _formState = _formKey.currentState;
    if (_formState.validate()) {
      _formState.save();
      try {
        AuthResult result = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: _email, password: _password);
        FirebaseUser user=result.user;
        Navigator.push(context,
            new MaterialPageRoute(builder: (context) => Home(user)));
      } catch (e) {

        print(e.message);
          return AlertDialog(
          title : Text(e.message),
          actions: <Widget>[
            CupertinoDialogAction(child : Text('OK')),
          ],
          elevation: 10,
        );
      }
    }
    else{

    }
  }
}

class buildsignup extends StatefulWidget {
  @override
  _buildsignupState createState() => _buildsignupState();
}

class _buildsignupState extends State<buildsignup> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => signuppage()));
      },
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "Don't have an account?",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            TextSpan(
              text: "Sign Up",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
