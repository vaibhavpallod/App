import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

// import 'firebase_data';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uber_hacktag_group_booking/Driver/DriverHomePage.dart';
import 'package:uber_hacktag_group_booking/Driver/Requests.dart';
import 'package:uber_hacktag_group_booking/RandomUser/ShowNormalUserMap.dart';
import 'package:uber_hacktag_group_booking/pages/MainHomePage.dart';

import 'Enter/login.dart';
import 'RandomUser/MyUserApp.dart';
import 'konstants/loaders.dart';
import 'konstants/size_config.dart';

void main() {
  print('main man');
  runApp(MyApp());
}

void anotherMain() {
  print('another main man');
  runApp(MyUserApp());
}

class MyApp extends StatelessWidget {
  // const MyApp({Key? key}) : super(key: key);
  MyApp({Key key}) : super(key: key);

  // FirebaseDatabase database = FirebaseDatabase.instance;
  // FirebaseApp secondaryApp = Firebase.app('SecondaryApp');

  // ye line comment ki mene 25 26

  // FirebaseDatabase database = FirebaseDatabase.instanceFor(app: secondaryApp);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: App(),
    );
  }
}

class App extends StatefulWidget {
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // Create the initialization Future outside of `build`:
  final storage = FlutterSecureStorage();

  Future initialise(BuildContext context) async {
    print('initializing');
    await Firebase.initializeApp();
    FlutterBranchSdk.validateSDKIntegration();

    // CollectionReference userCol =
    //     FirebaseFirestore.instance.collection('allusers');
    DatabaseReference allUsersDatabaseReference = FirebaseDatabase.instance.ref().child('allusers');

    StreamSubscription<Map> streamSubscriptionDeepLink =
        FlutterBranchSdk.initSession().listen((data) {
      Map tempmap = data;
      print(
          'STREAM from MAIN inside listen ' + data.containsKey('+clicked_branch_link').toString());
      if (data.containsKey('+clicked_branch_link') && data['+clicked_branch_link'] == true) {
        if (data.containsKey('is_first_session')) {
          print('from main is_first_session ' + data['is_first_session']);
        }
        String idstring = tempmap.containsKey('rideID') ? data['rideID'].toString() : "null";
        String bookieUID = data['bookieUID'].toString();
        print(" STREAM from MAIN printing DART ID " + data['rideID']);
        print(data.toString());
        BranchUniversalObject buo = BranchUniversalObject(
            canonicalIdentifier: 'flutter/branch/UBER_APP',
            title: 'Flutter Branch UBER',
            contentDescription: 'Flutter Branch Description',
            keywords: ['Plugin', 'Branch', 'Flutter'],
            publiclyIndex: true,
            locallyIndex: true,
            contentMetadata: BranchContentMetaData()
              ..addCustomMetadata('rideID', data['rideID'])
              ..addCustomMetadata('bookieUID', data['bookieUID'])
              ..addCustomMetadata('bookieEmail', data['bookieEmail']));
        FlutterBranchSdk.registerView(buo: buo);

        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ShowNormalUserMap(idstring, bookieUID)));
      }
      print(" STREAM from MAIN printing out");
    }, onError: (error) {
      PlatformException platformException = error as PlatformException;
      print(
          'STREAM from MAIN printing DART InitSession error: ${platformException.code} - ${platformException.message}');
    }, onDone: () {
      print('from MAIN printing DART');
    }, cancelOnError: false);
    // await streamSubscriptionDeepLink.cancel();
    if (FirebaseAuth.instance.currentUser != null) {
      print('MAIN: current user id' + FirebaseAuth.instance.currentUser.uid);
      // DocumentSnapshot ds =
      //     await userCol.doc(FirebaseAuth.instance.currentUser.uid).get();

      String userLoginStatus;
      bool isKeyPresent = await storage.containsKey(key: 'loginstate');
      if (isKeyPresent) {
        userLoginStatus = await storage.read(key: 'loginstate');
      } else {
        return Login();
      }
      print("MAIN STATUS: " + userLoginStatus);
      if (userLoginStatus.isEmpty || userLoginStatus == 'false') {
        return Login();
      }
      // Map<String, dynamic> mapp = ds.data();
      if (userLoginStatus == "true") {
        print('dash');
        await Future<dynamic>.delayed(const Duration(milliseconds: 1000));

        String type = await storage.read(key: 'userType');

        if (type == "User") {
          return MainHomePage();
        } else {
          // change this to driverHomepage afterwords
          return DriverHomePage();
          return Requests();
        }
      }
    } else {
      return Login();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    print('from main dispose called');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uber ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      home: Scaffold(
        body: Center(
          child: FutureBuilder(
            // Initialize FlutterFire:
            future: initialise(context),
            builder: (context, snapshot) {
              // Check for errors
              SizeConfig().init(context);

              // print('abcMain${snapshot.data}');
              if (snapshot.hasError) {
                return Text("Something Went Wrong", textDirection: TextDirection.ltr);
              }

              // Once complete, show your application
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data != null)
                  print('dataaa');
                else
                  print('nulllllll');

                // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context)=>snapshot.data), (route) => false);
                return snapshot.data;
              }

              // Otherwise, show something whilst waiting for initialization to complete
              return spinkit;
            },
          ),
        ),
      ),
    );
  }
}

/*
class MyHomePage extends StatefulWidget {
  // const MyHomePage({Key? key, required this.title}) : super(key: key);
  const MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return MaterialApp(
        debugShowCheckedModeBanner:false,
      home: Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}
*/
