import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../Driver/DriverHomePage.dart';
import '../Driver/Requests.dart';
import '../Enter/login.dart';
import '../konstants/loaders.dart';
import '../konstants/size_config.dart';
import '../pages/MainHomePage.dart';
import 'ShowNormalUserMap.dart';

class MyUserApp extends StatelessWidget {
  const MyUserApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GeneralUserApp(),
    );
  }
}

class GeneralUserApp extends StatelessWidget {
  // Create the initialization Future outside of `build`:
  Future initialise(BuildContext context) async {
    print('initializing');
    await Firebase.initializeApp();
    // CollectionReference userCol =
    //     FirebaseFirestore.instance.collection('allusers');
    DatabaseReference allUsersDatabaseReference = FirebaseDatabase.instance.ref().child('allusers');

    return ShowNormalUserMap();

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }




/*
  Future initialise(BuildContext context) async {
    print('initializing');
    await Firebase.initializeApp();
    // CollectionReference userCol =
    //     FirebaseFirestore.instance.collection('allusers');
    DatabaseReference allUsersDatabaseReference = FirebaseDatabase.instance.ref().child('allusers');

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
  }*/


}
