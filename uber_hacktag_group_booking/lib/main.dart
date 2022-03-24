import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uber_hacktag_group_booking/pages/MainHomePage.dart';

import 'Enter/OnBoarding/Intro_page.dart';
import 'Enter/googlesignindialog.dart';
import 'Enter/login.dart';
import 'konstants/loaders.dart';
import 'konstants/size_config.dart';
// import 'firebase_data';
import 'package:firebase_database/firebase_database.dart';

void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  // const MyApp({Key? key}) : super(key: key);
   MyApp({Key key}) : super(key: key);


   FirebaseDatabase database = FirebaseDatabase.instance;
   FirebaseApp secondaryApp = Firebase.app('SecondaryApp');
  // FirebaseDatabase database = FirebaseDatabase.instanceFor(app: secondaryApp);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: App(),
    );
  }
}

class App extends StatelessWidget {
  // Create the initialization Future outside of `build`:

  final storage = FlutterSecureStorage();

  Future initialise(BuildContext context) async {
    print('initializing');
    await Firebase.initializeApp();
    CollectionReference userCol =
        FirebaseFirestore.instance.collection('allusers');
    if (FirebaseAuth.instance.currentUser != null) {
      print('MAIN: current user id' + FirebaseAuth.instance.currentUser.uid);
      DocumentSnapshot ds =
          await userCol.doc(FirebaseAuth.instance.currentUser.uid).get();
      if (!ds.exists) {
        return Login();
      }
      Map<String, dynamic> mapp = ds.data();
      if (mapp.containsKey('city')) {
        print('dash');
        await Future<dynamic>.delayed(const Duration(milliseconds: 1000));
        return MainHomePage();
      } else {
        return googlesignindialog();
      }
    } else {
      return Login();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uber ',
      theme: ThemeData(
      ),
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
                return Text("Something Went Wrong",
                    textDirection: TextDirection.ltr);
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
