// ignore: avoid_web_libraries_in_flutter
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/widget/actiontoolbar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class editpage extends StatefulWidget {
  @override
  FirebaseUser user;
  editpage(FirebaseUser u) {
    user = u;
  }
  _editpageState createState() => _editpageState(user);
}

class _editpageState extends State<editpage> {
  @override
  static FirebaseUser user;
  File _image;
  String _imageURL;
  _editpageState(FirebaseUser us) {
    user = us;
  }
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _name, _email, _bio, _instagramid, _youtubeid, _Username;
  final db = Firestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white12,
        appBar: AppBar(
          backgroundColor: Colors.white12,
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
          title: Text(
            'Edit Profile',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.save), onPressed: onSave)
          ],
        ),
        body: Form(
            key: _formKey,
            child: ListView(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        StreamBuilder(
                            stream: Firestore.instance
                                .collection('users')
                                .document('${user.uid}')
                                .snapshots(),
                            builder: (context, snapshots) {
                              if (!snapshots.hasData) {
                                return CircularProgressIndicator(
                                    backgroundColor: Colors.white);
                              } else {
                                return CircleAvatar(
                                  radius: 55,
                                  backgroundImage: NetworkImage(
                                      '${snapshots.data['ProfilePicURL']}'),
                                );
                              }
                            }),
                        SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                            onTap: changeprofilepic,
                            child: Text(
                              'Change Profile Photo',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                  fontSize: 20),
                            )),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(10, 15, 10, 0),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        // ignore: missing_return
                        validator: (input) {
                          if (input.isEmpty) {
                            return 'Please fill an entry';
                          }
                        },
                        onSaved: (input) => _name = input,
                        decoration: InputDecoration(
                            //  border: InputBorder.none,
                            labelText: 'Name',
                            hintText: 'Name',
                            labelStyle: TextStyle(color: Colors.white),
                            hintStyle: TextStyle(color: Colors.white)),
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(10, 15, 10, 0),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        // ignore: missing_return
                        validator: (input) {
                          if (input.isEmpty) {
                            return 'Please fill an entry';
                          }
                        },
                        onSaved: (input) => _Username = input,
                        decoration: InputDecoration(
                            //  border: InputBorder.none,
                            labelText: 'Username',
                            hintText: 'Username',
                            labelStyle: TextStyle(color: Colors.white),
                            hintStyle: TextStyle(color: Colors.white)),
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(10, 15, 10, 0),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        // ignore: missing_return
                        validator: (input) {
                          if (input.isEmpty) {
                            return 'Please fill an entry';
                          }
                        },
                        onSaved: (input) => _bio = input,
                        decoration: InputDecoration(
                            //  border: InputBorder.none,
                            labelText: 'Bio',
                            hintText: 'Bio',
                            labelStyle: TextStyle(color: Colors.white),
                            hintStyle: TextStyle(color: Colors.white12)),
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(10, 15, 10, 0),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        // ignore: missing_return
                        validator: (input) {
                          if (input.isEmpty) {
                            return 'Please fill an entry';
                          }
                        },
                        onSaved: (input) => _instagramid = input,
                        decoration: InputDecoration(
                            //  border: InputBorder.none,
                            labelText: 'InstagramID',
                            hintText: 'InstagramID',
                            labelStyle: TextStyle(color: Colors.white),
                            hintStyle: TextStyle(color: Colors.white)),
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(10, 15, 10, 0),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        // ignore: missing_return
                        validator: (input) {
                          if (input.isEmpty) {
                            return 'Please fill an entry';
                          }
                        },
                        onSaved: (input) => _youtubeid = input,
                        decoration: InputDecoration(
                            //  border: InputBorder.none,
                            labelText: 'YouTubeID',
                            hintText: 'YouTubeID',
                            labelStyle: TextStyle(color: Colors.white),
                            hintStyle: TextStyle(color: Colors.white)),
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(10, 20, 10, 10),
                  child: Text(
                    'Profile Information',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white),
                  ),
                ),
                textfeild('EmailAdress'),
                textfeild('Phone'),
                textfeild('Gender'),
              ],
            )));
  }

  Future<void> onSave() async {
    final _formState = _formKey.currentState;
    if (_formState.validate()) {
      _formState.save();
      try {
        await db.collection('users').document(user.uid).updateData({
          'Name': _name,
          'bio': _bio,
          'InstagramId': _instagramid,
          'YouTubeId': _youtubeid,
          'Username': _Username,
          'searchKey':_name.substring(0,1).toUpperCase(),
        });
      } catch (e) {
        print(e.message);
      }
    }
  }

  Widget textfeild(String label) {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 15, 10, 0),
      child: Column(
        children: <Widget>[
          TextField(
            decoration: InputDecoration(
                //  border: InputBorder.none,
                labelText: label,
                hintText: label,
                labelStyle: TextStyle(color: Colors.white),
                hintStyle: TextStyle(color: Colors.white)),
            style: TextStyle(color: Colors.white),
          )
        ],
      ),
    );
  }

  Widget getalertdailog() {
    print('ko');
    return AlertDialog(
      title: Text('AlertDialog Title'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('This is a demo alert dialog.'),
            Text('Would you like to approve of this message?'),
          ],
        ),
      ),
    );
  }

  Future<void> updateprofilepic() async {
    await db
        .collection('users')
        .document(user.uid)
        .updateData({'ProfilePicURL': _imageURL});
  }

  Future<void> changeprofilepic() async {
    print('ko');
    await ImagePicker.pickImage(source: ImageSource.camera).then((image) {
      setState(() {
        _image = image;
      });
    });
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child('${user.uid}/profilepic/image');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    print('File uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        _imageURL = fileURL;
        updateprofilepic();
      });
    });
  }
}
