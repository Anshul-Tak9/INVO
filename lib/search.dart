import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/SearchResult/SearchResults.dart';
import 'searchservice.dart';
import 'SearchResult/SearchResults.dart';

class Search extends StatefulWidget {
  @override
  FirebaseUser user;
  Search(FirebaseUser u){
    user=u;
  }
  _SearchState createState() => _SearchState(user);
}

class _SearchState extends State<Search> {
  @override
  FirebaseUser user;
  _SearchState(FirebaseUser u){
    user=u;
  }
  var queryResultState = [];
  var tempSearchState = [];
  void initateSearch(String value) {
    if (value.length == 0) {
      setState(() {
        queryResultState = [];
        tempSearchState = [];
      });
    }
    var Capitailizedvalue =
        value.substring(0, 1).toUpperCase() + value.substring(1);
    if (queryResultState.length == 0 && value.length == 1) {
      SearchService().searchByName(value).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.documents.length; i++) {
          queryResultState.add(docs.documents[i].data);
        }
      });
    } else {
      tempSearchState = [];
      queryResultState.forEach((element) {
        if (element['Name'].startsWith(value)) {
          setState(() {
            tempSearchState.add(element);
          });
        }
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body:  Container(
        margin: EdgeInsets.only(top: 30),
        child: Column(
          children: <Widget>[
            TextField(
              onChanged: (val) {
                initateSearch(val);
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 25.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                hintText: 'Search',
                labelText: 'Search',
                hintStyle: TextStyle(color: Colors.grey),
                labelStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
              ),
            ),
            SizedBox(height: 10),
            ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(left: 10,top: 10),
              children: tempSearchState.map((e){
                 return   GestureDetector(
                          onTap: (){Navigator.push(context, new MaterialPageRoute(builder: (context)=>SearchResults(user.uid.toString(),e['UID'])));},
                          child:Text(e['Name'],style: TextStyle(color: Colors.grey,fontSize: 18)),
                 );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
