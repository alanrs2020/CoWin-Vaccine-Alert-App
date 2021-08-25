import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cowinapp/district.dart';
import 'package:cowinapp/pincode.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'alerts.dart';
import 'globals.dart' as global;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}




Future _showNotification() async {


  FlutterLocalNotificationsPlugin flip = new FlutterLocalNotificationsPlugin();

  var android = new AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings settings = InitializationSettings(
    android: android,
  );


  flip.initialize(settings);
  var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      '1233',
      'Vaccine Alert',
      'your channel description',
      importance: Importance.max,
      priority: Priority.high
  );

// initialise channel platform for both Android and iOS device.
  var platformChannelSpecifics = new NotificationDetails(android: androidPlatformChannelSpecifics);

  await flip.show(0, 'Vaccine Alert',
      'Find your nearby vaccine centers !',
      platformChannelSpecifics, payload: 'Default_Sound',
  );
}
class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  const MyApp({Key key}) : super(key: key);

  //final FirebaseApp app;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CoWin Alert App',
      theme: ThemeData(
       primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Home'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);



  final String title;
 // final FirebaseApp app;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String messageTitle = "Empty";
  String notificationAlert = "alert";
  DatabaseReference _messagesRef;
  bool isUserFound = false;
  var noTextError = false;
  final _controller = new TextEditingController();
  final FirebaseDatabase database = FirebaseDatabase();
  FirebaseMessaging _firebaseMessaging;

  @override
  void initState()  {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        //print(DateTime.now());

      });
    });

    saveToken();
    _messagesRef = database.reference().child('tokens');

    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true,badge: true,sound: false);
    FirebaseMessaging.onMessage.listen((message) async {
      await _showNotification();


         //print("1 ${message.data['notification']['title']}");
        //print("2 ${message.notification}");
        //print("3 ${message.contentAvailable}");
       // print("4 ${message.category}");

    });
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true,badge: true);
  }

  void saveToken()async{
    String userId = await haveUser();
    if(userId != null) {
      setState(() {
        FirebaseMessaging.instance.getToken().then((message) async {
          //await _showNotification();
          print(message);
          _messagesRef.child(userId).set(message);
        });
        isUserFound = true;
      });
    }else{

    }

  }
  Future<String> haveUser() async{
    final path = await _localPath;

    if(path != null){
      print(path);
      File file = File('$path/.name.txt');
      try{
        if(file.existsSync()){
          String name = file.readAsStringSync();
          global.UserId = name;
          print(name);
          return name;
        }
        else{
         // global.username = "bytes " + Random().nextInt(10000).toString();
        }
      }catch(e){

      }
    }else{
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,style:TextStyle(color:Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: isUserFound ? Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage("images/bg.jpg"), fit: BoxFit.cover),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  height:40,
                  width:150,
                  color: Colors.red,
                  child: Center(
                    child: TextButton(
                      child: Text("Alerts !",style: TextStyle(color: Colors.white)),
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (_) => alerts()));
                      },
                    ),
                  )
              ),
              Text((DateTime.now().hour).toString()+":"+DateTime.now()
                  .minute.toString()+":"+DateTime.now().second.toString(),
                  style: TextStyle(fontSize: 80,color: Colors.black87)),
              Container(height:50),
              Text(DateTime.now().day.toString()+"-"+DateTime.now().month.toString()
                  +"-"+DateTime.now().year.toString(),
                  style: TextStyle(fontSize: 20,color: Colors.black38)),
              Container(
                  height:40,
                  width:150,
                  color: Colors.black54,
                  child: Center(
                    child: TextButton(
                      child: Text("Search By Pincode",style: TextStyle(color: Colors.white)),
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (_) => pincode()));
                      },
                    ),
                  )
              ),
              Container(height: 50),
              /*Container(
                  height:40,
                  width:150,
                  color: Colors.amberAccent,
                  child: Center(
                    child: TextButton(
                      child: Text("Generate OTP",style: TextStyle(color: Colors.black87)),
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (_) => generateotp()));
                        //GenerateOtp();
                      },
                    ),
                  )
              ),*/
              Container(
                  height:40,
                  width:150,
                  color: Colors.black87,
                  child: Center(
                    child: TextButton(
                      child: Text("Search By District",style: TextStyle(color: Colors.white)),
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (_) => district()));
                       // GenerateOtp();
                      },
                    ),
                  )
              ),

            ],
          ),
        ),
      ): Container(

        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage("images/bg.jpg"), fit: BoxFit.cover),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              style: TextStyle(fontSize:20),
              maxLength: 10,
              controller: _controller,
              decoration: InputDecoration(
                  hintText: "Enter your name",
                  border: OutlineInputBorder()
              ),

            ),
            Container(

                height:40,
                width:90,
                color: Colors.deepPurple,
                child: Center(
                  child: TextButton(
                    child: Text("Submit",style: TextStyle(color: Colors.white),),
                    onPressed: ()async{

                      if(_controller.text != ""){
                        SaveName(_controller.text);

                      }else{
                        setState(() {
                          noTextError = true;
                        });
                      }
                    },
                  ),
                )
            ),

            noTextError ?
            Text("Enter the your name",style:TextStyle(color: Colors.red)):
            Text(" ")
          ],
        ),
      )
    );
  }
  SaveName(String name) async{
    try {
      final path = await _localPath;
      File file = File('$path/.name.txt');
      setState(() {
        String _name = name + Random().nextInt(100000).toString();
        var bytes = utf8.encode(_name);
        var _data = sha256.convert(bytes);
        saveToken();
       // _messagesRef.child(_data).set(message);
        file.writeAsString(_data.toString());
        global.UserId = _data.toString();
      });
      Fluttertoast.showToast(msg: "Successfully Saved");
    }catch(e){

    }
  }

  Future<String> get _localPath async {
    const platform = const MethodChannel('native_java');
    String path;
    await platform.invokeMethod("Save").then((value) async{
      if(value != null){
        path = value;
        print(path);
      }else{
        return null;
      }
    });
    final Directory _appDocDirFolder = Directory(path+"/username");

    if (await _appDocDirFolder
        .exists()) { //if folder already exists return path
      return _appDocDirFolder.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory _appDocDirNewFolder = await _appDocDirFolder.create(
          recursive: true);
      return _appDocDirNewFolder.path;
    }
  }
}
