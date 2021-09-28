import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:myapp/HomePage.dart';
import 'package:path_provider/path_provider.dart';
import 'search.dart';
import 'main.dart';
import 'Notification.dart';
import 'package:myapp/widget/mepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mime/mime.dart';
import 'package:spincircle_bottom_bar/spincircle_bottom_bar.dart';
import 'package:spincircle_bottom_bar/modals.dart';
import 'package:photofilters/photofilters.dart';
import 'package:image/image.dart' as imageLib;
import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thumbnails/thumbnails.dart';
import 'package:permission_handler/permission_handler.dart';
import 'recorded_video.dart';
class Home extends StatefulWidget {
  @override
  static FirebaseUser user;
  Home(FirebaseUser use){
    user=use;
  }

  _HomeState createState() => _HomeState(user);
}

class _HomeState extends State<Home> {
  @override
  static FirebaseUser user;
  File _file;
  File _imagefile;
  imageLib.Image _image;
  String fileName;
  Filter _filter;
  List<Filter> filters = presetFiltersList;
  File _imgs;
  bool isVideo = false;
  VideoPlayerController _controller;
  VoidCallback listener;
  PermissionStatus _permissionStatus=PermissionStatus.undetermined;
  Permission _permission;
  bool isLoading=false;

  _HomeState(FirebaseUser use){
    user=use;
  }
  int currenttab=0;
  final List<Widget> screens=[
    Homepage(),
    Search(user),
    Notifications(user),
    mepage(user),
  ];
  void deactivate() {
    if (_controller != null) {
      _controller.setVolume(0.0);
      _controller.removeListener(listener);
    }
    super.deactivate();
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    listener = () {
      setState(() {});
    };
  }
  Widget currentScreen = Homepage();
  final PageStorageBucket bucket=PageStorageBucket();
  Widget build(BuildContext context) {
    return Scaffold(
      body: SpinCircleBottomBarHolder(
        bottomNavigationBar: SCBottomBarDetails(
          bnbHeight: 70,
          circleColors: [Colors.white, Colors.orange, Colors.redAccent],
          iconTheme: IconThemeData(color: Colors.black45),
          activeIconTheme: IconThemeData(color: Colors.orange),
          backgroundColor: Colors.white,
          titleStyle: TextStyle(color: Colors.black45,fontSize: 12),
          activeTitleStyle: TextStyle(color: Colors.black,fontSize: 12,fontWeight: FontWeight.bold),
          actionButtonDetails: SCActionButtonDetails(
              color: Colors.redAccent,
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
              elevation: 10.0,),
          elevation: 10.0,
          items: [
            // Suggested count : 4
            SCBottomBarItem(icon: Icons.home, title: "Home", onPressed: () {
              setState(() {
                currentScreen=Homepage();
              });
            }),
            SCBottomBarItem(icon: Icons.search, title: "Search", onPressed: () {
              setState(() {
                currentScreen=Search(user);
              });
            }),
            SCBottomBarItem(icon: Icons.notifications, title: "Notification", onPressed: () {
              setState(() {
                currentScreen=Notifications(user);
              });
            }),
            SCBottomBarItem(icon: Icons.person, title: "Profile", onPressed: () {
              setState(() {
                currentScreen=mepage(user);
              });
            }),
          ],
          circleItems: [
            //Suggested Count:

           // SCItem(icon: Icon(Icons.camera_alt),onPressed: () {imagepickerfromcamera(context);}),
            SCItem(icon: Icon(Icons.videocam), onPressed: () { print('pressed');Navigator.push(context,new MaterialPageRoute(builder: (context)=>RecordVideo('','','','')));}),
           // SCItem(icon: Icon(Icons.photo_library), onPressed: () {imagepickerfromgallery(context);}),
            SCItem(icon: Icon(Icons.video_library), onPressed: () {videopickerfromgallery(context);}),
            SCItem(icon: Icon(Icons.music_note), onPressed: () { takingmusic();}),
          ],
        ),
        child: PageStorage(
          child : currentScreen,
          bucket: bucket,
        ),


      ),
     /* body : PageStorage(
          child : currentScreen,
          bucket: bucket,
        ),
        floatingActionButton: FloatingActionButton(

        heroTag: null,
          child: Icon(Icons.add),
          backgroundColor: Colors.redAccent,
          onPressed: uploadfile,
          ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Container(
          height: 60,
          padding: EdgeInsetsDirectional.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              MaterialButton(
                minWidth: 60,
                onPressed: (){
                  setState(() {
                    currenttab=0;
                    currentScreen=BackGroundvideo(user);
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.home,color: currenttab==0?Colors.blue:Colors.grey),
                    Text('Home',style: TextStyle(color: currenttab==0?Colors.blue:Colors.grey),)
                  ],
                ),
              ),
              MaterialButton(
                minWidth: 60,
                onPressed: (){
                  setState(() {
                    currenttab=1;
                    currentScreen=Search();
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.search,color: currenttab==1?Colors.blue:Colors.grey),
                    Text('Search',style: TextStyle(color: currenttab==1?Colors.blue:Colors.grey)),
                  ],
                ),
              ),
              MaterialButton(
                minWidth: 60,
                onPressed: (){
                  setState(() {
                    currenttab=2;
                    currentScreen=Music();
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.music_note,color: currenttab==2?Colors.blue:Colors.grey,),
                    Text('Music',style: TextStyle(color: currenttab==2?Colors.blue:Colors.grey),)
                  ],
                ),
              ),
              MaterialButton(
                minWidth: 60,
                onPressed: (){
                  setState(() {
                    currenttab=3;
                    currentScreen=mepage(user);
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.person,color: currenttab==3?Colors.blue:Colors.grey,),
                    Text('Profile',style: TextStyle(color: currenttab==3?Colors.blue:Colors.grey),)
                  ],
                ),
              ),
            ],
          ),
        ),

      ),*/
    );
  }
 /* _onImageButtonPressed(ImageSource source,String filetype) async {
    var imgs;
    if(!isVideo){
      imgs = await MultiMediaPicker.pickImages(source: source, singleImage: true);
      setState(() {
        print('imgs');
        _imgs = imgs;
        _file=_imgs;
      });
      print('next');
      print('get');
      int count;
      String _fileURL;
      await Firestore.instance.collection('users').document('${user.uid}').get().then((value){
        if(value.data.length>0){
          setState(() {
            count=value.data['videocount'];
            count++;
            print(count);
            Firestore.instance.collection('users').document('${user.uid}').updateData({'videocount':count});
          });
        }
      });
      StorageReference st=FirebaseStorage.instance.ref().child('${user.uid}/files/${count}');
      StorageUploadTask uploadTask = st.putFile(_file);
      await uploadTask.onComplete;
      print('file uploaded');
      await st.getDownloadURL().then((fileURL) {
        setState(() {
          _fileURL = fileURL;
        });
      });
      await Firestore.instance.collection('users').document('${user.uid}').collection('Videos').document('${count}').setData({'Likes':0,'VideoURL' :_fileURL,'fileType':filetype});
      print('URL uploaded in videos');
    }
      if (isVideo) {
        await MultiMediaPicker.pickVideo(source: source).then((File file) {
          if (file != null && mounted) {
            setState(() {
              _file=file;
              _controller = VideoPlayerController.file(file)
                ..addListener(listener)
                ..setVolume(1.0);
            });
          }
        });
        print('get');
        int count;
        String _fileURL;
        await Firestore.instance.collection('users').document('${user.uid}').get().then((value){
          if(value.data.length>0){
            setState(() {
              count=value.data['videocount'];
              count++;
              print(count);
              Firestore.instance.collection('users').document('${user.uid}').updateData({'videocount':count});
            });
          }
        });
        StorageReference st=FirebaseStorage.instance.ref().child('${user.uid}/files/${count}');
        StorageUploadTask uploadTask = st.putFile(_file);
        await uploadTask.onComplete;
        print('file uploaded');
        await st.getDownloadURL().then((fileURL) {
          setState(() {
            _fileURL = fileURL;
          });
        });
        await Firestore.instance.collection('users').document('${user.uid}').collection('Videos').document('${count}').setData({'Likes':0,'VideoURL' :_fileURL,'fileType':filetype});
        print('URL uploaded in videos');
      }

  }*/
 /* Future<void> uploadfile() async{
    _file =await FilePicker.getFile();
    int count=0;
    String _fileURL;
    String _mimestr;
    String _path;
    await Firestore.instance.collection('users').document('${user.uid}').get().then((value){
      if(value.data.length>0){
        setState(() {
          count=value.data['videocount'];
          count++;
          print(count);
          Firestore.instance.collection('users').document('${user.uid}').updateData({'videocount':count});
        });
      }
    });

    StorageReference st=FirebaseStorage.instance.ref().child('${user.uid}/files/${count}');
    StorageUploadTask uploadTask = st.putFile(_file);
    await uploadTask.onComplete;
    print('file uploaded');
    await st.getPath().then((value){
      setState(() {
        _path=value;
      });
    });
    await st.getDownloadURL().then((fileURL) {
      setState(() {
        _fileURL = fileURL;
      });
    });
    _mimestr=lookupMimeType(_path);
    var filetype=_mimestr.split('/');

  }
  Future getImage() async {
    var imageFile = await MultiMediaPicker.pickImages(source: ImageSource.camera,singleImage: true);
    setState(() {
      _imagefile=imageFile[0];
    });
    fileName = basename(imageFile[0].path);
    var image = imageLib.decodeImage(imageFile[0].readAsBytesSync());
    setState(() {
      _image = image;
    });
  }*/
 Future<void> filepick(String type) async{
   if(type=='Image') {
     _file = await FilePicker.getFile(type: FileType.image);
     int count;
     String _fileURL;
     await Firestore.instance.collection('users').document('${user.uid}').get().then((value){
       if(value.data.length>0){
         setState(() {
           count=value.data['imagecount'];
           count++;
           print(count);
           Firestore.instance.collection('users').document('${user.uid}').updateData({'imagecount':count});
         });
       }
     });
     StorageReference  st = FirebaseStorage.instance.ref().child('${user.uid}/files/Images/${count}');
     StorageUploadTask uploadTask = st.putFile(_file);
     await uploadTask.onComplete;
     print('file uploaded');
     await st.getDownloadURL().then((fileURL) {
       setState(() {
         _fileURL = fileURL;
       });
     });
     await Firestore.instance.collection('users').document('${user.uid}')
         .collection('Images').document("${count}")
         .setData({'Likes': 0, 'ImageURL': _fileURL, 'fileType': 'Image'});
     print('URL uploaded in images');
   }
   else{
     _file = await FilePicker.getFile(type: FileType.video);
     int count;
     String _fileURL;
     await Firestore.instance.collection('users').document('${user.uid}').get().then((value){
       if(value.data.length>0){
         setState(() {
           count=value.data['videocount'];
           count++;
           print(count);
           Firestore.instance.collection('users').document('${user.uid}').updateData({'videocount':count});
         });
       }
     });
     StorageReference st = FirebaseStorage.instance.ref().child('${user.uid}/files/Videos/${count}/V');
     StorageUploadTask uploadTask = st.putFile(_file);
     await uploadTask.onComplete;
     await st.getDownloadURL().then((fileURL) {
       setState(() {
         _fileURL = fileURL;
       });
     });
     String pathfolder;
     String videopath;
     await FirebaseStorage.instance.ref().child('${user.uid}/files/Videos/${count}/Thumbnail').getPath().then((value) {
       pathfolder=value;
     });
     await FirebaseStorage.instance.ref().child('${user.uid}/files/Video/${count}/V').getPath().then((value) {
       videopath=value;
     });
     print(pathfolder+" "+videopath);
     String thumb=await Thumbnails.getThumbnail(videoFile: _fileURL,thumbnailFolder: pathfolder,imageType: ThumbFormat.JPEG);
     print(thumb);
     String s;
     await Firestore.instance.collection('users').document('${user.uid}').collection('Videos').document('${count}').setData({'Likes':0,'VideoURL' :_fileURL,'fileType':'Video','Thumbnail':thumb});
     print('URL uploaded in videos');
   }
 }
 Future<void> imagepick(ImageSource source,BuildContext context) async{
    print('get');
    int count;
    String _fileURL;
      await Firestore.instance.collection('users').document('${user.uid}').get().then((value){
        if(value.data.length>0){
          setState(() {
            count=value.data['imagecount'];
            count++;
            print(count);
            Firestore.instance.collection('users').document('${user.uid}').updateData({'imagecount':count});
          });
        }
      });
    requestPermission(_permission);
    print('image');
    await ImagePicker.pickImage(source: source).then((value) {
      setState(() {
        _file = value;
      });
    });
      StorageReference  st = FirebaseStorage.instance.ref().child('${user.uid}/files/Images/${count}');
      StorageUploadTask uploadTask = st.putFile(_file);
       await uploadTask.onComplete;
    print('file uploaded');
    await st.getDownloadURL().then((fileURL) {
      setState(() {
        _fileURL = fileURL;
      });
    });
      await Firestore.instance.collection('users').document('${user.uid}')
          .collection('Images').document("${count}")
          .setData({'Likes': 0, 'ImageURL': _fileURL, 'fileType': 'Image'});
    print('URL uploaded in images');
  }
  Future<void> Videopick(ImageSource source,BuildContext context) async{
    int count;
    String _fileURL;
    await Firestore.instance.collection('users').document('${user.uid}').get().then((value){
      if(value.data.length>0){
        setState(() {
          count=value.data['videocount'];
          count++;
          print(count);
          Firestore.instance.collection('users').document('${user.uid}').updateData({'videocount':count});
        });
      }
    });
    requestPermission(_permission);
    await ImagePicker.pickVideo(source: source,maxDuration: const Duration(seconds: 20)).then((value) {
      setState(() {
        _file = value;
      });
    });
    StorageReference st = FirebaseStorage.instance.ref().child('${user.uid}/files/Videos/${count}/V');
    StorageUploadTask uploadTask = st.putFile(_file);
    await uploadTask.onComplete;
    await st.getDownloadURL().then((fileURL) {
      setState(() {
        _fileURL = fileURL;
      });
    });
    String pathfolder;
    String videopath;
    await FirebaseStorage.instance.ref().child('${user.uid}/files/Videos/${count}/Thumbnail').getPath().then((value) {
      pathfolder=value;
    });
    await FirebaseStorage.instance.ref().child('${user.uid}/files/Video/${count}/V').getPath().then((value) {
      videopath=value;
    });
    print(pathfolder+" "+videopath);
    String thumb=await Thumbnails.getThumbnail(videoFile: _fileURL,thumbnailFolder: pathfolder,imageType: ThumbFormat.JPEG);
    print(thumb);
    String s;
    await Firestore.instance.collection('users').document('${user.uid}').collection('Videos').document('${count}').setData({'Likes':0,'VideoURL' :_fileURL,'fileType':'Video','Thumbnail':thumb});
    print('URL uploaded in videos');
  }
  Future<void> imagepickerfromcamera(BuildContext context) async{
    await ImagePicker.pickImage(source: ImageSource.camera).then((value) {
      setState(() {
        _file = value;
        Navigator.push(context,
            new MaterialPageRoute(builder: (context) => Imagedesc(_file,user)));
      });
    });
  }
  Future<void> imagepickerfromgallery(BuildContext context) async{
   _file=await FilePicker.getFile(type: FileType.image);
   Navigator.push(context,
       new MaterialPageRoute(builder: (context) => Imagedesc(_file,user)));
  }
  Future<void> videopickerfromcamera(BuildContext context) async{
    await ImagePicker.pickVideo(source: ImageSource.camera).then((value) {
      setState(() {
        _file = value;
        Navigator.push(context,
            new MaterialPageRoute(builder: (context) => Videodesc(_file,user)));
      });
    });
  }
  Future<void> videopickerfromgallery(BuildContext context) async{
    _file=await FilePicker.getFile(type: FileType.video);
    Navigator.push(context,
        new MaterialPageRoute(builder: (context) => Videodesc(_file,user)));
  }
  Future<void> requestPermission(Permission permission) async {
    final status = await permission.request();
    setState(() {
      print(status);
      _permissionStatus = status;
      print(_permissionStatus);
    });
  }
  Future<void> uploadingmusic(List<File> list) async{
    setState(() {
      isLoading=true;
    });
    String url;
    print('Start');
    print(list.length);
    File element;
    for(int i=0;i<list.length;i++){
      element=list[i];
      print(element.path);
      String s=path.basename(element.path);
      String name=path.basenameWithoutExtension(element.path);
      StorageReference st = FirebaseStorage.instance.ref().child('Music/Hindi_Dailogue/Songs/${name}');
      print('l');
      StorageUploadTask uploadTask = st.putFile(element);
      await uploadTask.onComplete;
      print('Uploaded Task');
      StorageReference str = FirebaseStorage.instance.ref().child('Music/Hindi_Dailogue/Songs/${name}');
      await str.getDownloadURL().then((fileURL) {
        setState(() {
          url=fileURL;
        });
      });
      await Firestore.instance.collection('Music').document('Hindi_Dailogue').collection('Hindi_Dailogue  ').document().setData({'Name':name,'URL':url});
    }
    /*list.forEach((element) async {
      StorageReference st = FirebaseStorage.instance.ref().child('Music/Hindi_Songs/Songs/');
      StorageUploadTask uploadTask = st.putFile(element);
      await uploadTask.onComplete;
      print('Uploaded Task');
      String s=path.basename(element.path);
      String name=path.basenameWithoutExtension(element.path);
      StorageReference str = FirebaseStorage.instance.ref().child('Music/Hindi_Songs/Songs/${s}');
      await str.getDownloadURL().then((fileURL) {
        setState(() {
          url=fileURL;
        });
      });
      await Firestore.instance.collection('Music').document('Hindi_Songs').collection('Hindi_Songs').document().setData({'Name':name,'URL':url});
    });*/
    print('done');
    setState(() {
      isLoading=false;
    });
  }
  Future<void> takingmusic() async{
   List<File> file=await FilePicker.getMultiFile(type: FileType.audio);
   uploadingmusic(file);
  }
}
class Imagedesc extends StatefulWidget {
  @override
  File _image;
  FirebaseUser _user;
  Imagedesc(File image,FirebaseUser b){
    _image=image;
    _user=b;
  }
  _ImagedescState createState() => _ImagedescState(_image,_user);
}

class _ImagedescState extends State<Imagedesc> {
  @override
  File _image;
  String _imaged;
  FirebaseUser user;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  _ImagedescState(File image,FirebaseUser b){
    _image=image;
    user=b;
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back),onPressed: (){Navigator.pop(context,true);},),
        title: Text('Imagedesc'),
      ),
      body: Column(
        children: <Widget>[
          Form(
            key: _formKey,
            child: TextFormField(
              onSaved:(input)=>_imaged=input ,
              maxLength: 50,
              maxLines: 10,
            decoration: InputDecoration(
              hintText: 'Add a Description',
              contentPadding: EdgeInsets.only(left: 25.0),
              fillColor: Colors.grey[300],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
        ),
          ),
          Expanded(
            child: Image.file(_image),
          ),
          Container(
            child:RaisedButton(
              onPressed: (){_uploadimage(context);},
              child: Text('Upload'),
            ),
          ),
      ]
      ),
    );
  }
  Future<void> _uploadimage(BuildContext context) async {
    int count;
    String _fileURL;
    await Firestore.instance.collection('users').document('${user.uid}')
        .get()
        .then((value) {
      if (value.data.length > 0) {
        setState(() {
          count = value.data['imagecount'];
          int post=value.data['Post'];
          count++;
          print(count);
          Firestore.instance.collection('users')
              .document('${user.uid}')
              .updateData({'imagecount': count,'Post':post});
        });
      }
    });
    StorageReference st = FirebaseStorage.instance.ref().child(
        '${user.uid}/files/Images/${count}');
    StorageUploadTask uploadTask = st.putFile(_image);
    await uploadTask.onComplete;
    print('file uploaded');
    await st.getDownloadURL().then((fileURL) {
      setState(() {
        _fileURL = fileURL;
      });
    });
    final _formState = _formKey.currentState;
    if (_formState.validate()) {
      _formState.save();
      try {
        await Firestore.instance.collection(' users').document('${user.uid}')
            .collection('Images').document("${count}")
            .setData({
          'Likes': 0,
          'ImageURL': _fileURL,
          'fileType': 'Image',
          'ImageDescription': _imaged
        });
        Navigator.pop(context);
        print('URL uploaded in images');
        }
       catch (e) {
        print(e.message);
      }
    }

    Navigator.pop(context);
    print('URL uploaded in images');
  }
}
class Videodesc extends StatefulWidget {
  @override
  File _video;
  FirebaseUser user;
  Videodesc(File f,FirebaseUser u){
    _video=f;
    user=u;
  }
  _VideodescState createState() => _VideodescState(_video,user);
}

class _VideodescState extends State<Videodesc> {
  @override
  File _video;
  String _videodesc;
  FirebaseUser user;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;
  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
  bool isLoading=false;
  bool isUploading=false;
  double _count=0;
  _VideodescState(File f,FirebaseUser u){
    _video=f;
    user=u;
  }
  void initState() {
    _controller=VideoPlayerController.file(_video);
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.play();
    _controller.setLooping(true);
    super.initState();
  }
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();
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
                        onTap: (){upload(context);},
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
  Future<void> upload(BuildContext context) async{
    setState(() {
      isUploading=true;
    });
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
    await _flutterFFmpeg.execute('-i ${_video.path} -ss 00:00:01 -vframes 1 ${thumbnailpath}').then((rc) => print("FFmpeg process exited with rc $rc"+"-"+'thumbnail'));
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
    StorageUploadTask uploadTask = st.putFile(_video);
    uploadTask.events.listen((event) {setState(() {
      _count=(event.snapshot.bytesTransferred/event.snapshot.totalByteCount)/1.5;
    });});
    await uploadTask.onComplete;
    await st.getDownloadURL().then((fileURL) {
      setState(() {
        _fileURL = fileURL;
      });
    });
    StorageReference str = FirebaseStorage.instance.ref().child('${user.uid}/files/Videos/${count}/V/Thumbnail');
    StorageUploadTask uploadTask1= str.putFile(File(thumbnailpath));

    await uploadTask1.onComplete;
    await str.getDownloadURL().then((fileURL) {
      setState(() {
        thumbnailfileurl = fileURL;
      });
    });
    uploadTask.events.listen((event) {setState(() {
      _count=0.67+(event.snapshot.bytesTransferred/event.snapshot.totalByteCount)/5;
    });
    });
        await Firestore.instance.collection('users').document('${user.uid}').collection('Videos').document('${count}').setData({'Likes':0,'VideoURL' :_fileURL,'fileType':'Video','VideoDesciption':_videodesc,'ImageURL':thumbnailfileurl});
      setState(() {
        _count=1.0;
      });
        Navigator.push(context,new MaterialPageRoute(builder:(context)=>Home(user)));
        print('URL uploaded in Videos');
  }
}


