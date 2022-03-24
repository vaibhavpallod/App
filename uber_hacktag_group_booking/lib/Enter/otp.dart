import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uber_hacktag_group_booking/Enter/signup.dart';
import 'package:uber_hacktag_group_booking/pages/MainHomePage.dart';

import '../konstants/loaders.dart';

class OTPScreen extends StatefulWidget {
  String verificationId;
  FirebaseAuth auth;
  String phonenumber;

  OTPScreen({this.verificationId, this.auth, this.phonenumber});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  bool load = false;
  String finalCode;
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  final storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: load
          ? Container(child: spinkit)
          : SafeArea(
              child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(50.0)),
                          color: Colors.black),
                      padding: const EdgeInsets.all(15.0),
                      child: Image.asset(
                        "images/uberlogo.jpg",
                        fit: BoxFit.fitWidth,
                        width: 80,
                        height: 80,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Please enter the OTP',
                      style: GoogleFonts.workSans(fontSize: 15),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      child: OtpTextField(
                        textStyle: GoogleFonts.workSans(fontSize: 15),
                        numberOfFields: 6,
                        borderColor: Colors.grey,
                        focusedBorderColor: Colors.grey,
                        cursorColor: Colors.black,
                        showFieldAsBox: true,
                        fieldWidth: MediaQuery.of(context).size.width / 10,
                        borderWidth: 2.0,
                        //runs when a code is typed in
                        onSubmit: (String code) {
                          //handle validation or checks here if necessary
                          print(code);
                          setState(() {
                            finalCode = code;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          PhoneAuthCredential credential = PhoneAuthProvider.credential(
              verificationId: widget.verificationId, smsCode: finalCode);
          UserCredential userCredential =
              await widget.auth.signInWithCredential(credential);

          _findUserAlreadyLoggedInorNot(userCredential);

          // Navigator.pushAndRemoveUntil(
          //     context,
          //     MaterialPageRoute(
          //         builder: (BuildContext context) => SignUp()),
          //     (route) => false);
        },
        backgroundColor: Colors.black,
        child: Icon(
          Icons.navigate_next,
          color: Colors.white,
        ),
      ),
    );
  }

  void _findUserAlreadyLoggedInorNot(UserCredential userCredential) {
    // Map<String,dynamic> map = value.value,
    Map<dynamic, dynamic> map;
    databaseReference.child('allusers').get().then((value) => {
              map = value.value,
              if (map.containsKey(userCredential.user.uid))
                {
                  setState(() {
                    load = true;
                  }),
                  storage
                      .write(key: 'loginstate', value: 'true')
                      .whenComplete(() => {
                            setState(() {
                              load = false;
                            }),
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        MainHomePage()),
                                (route) => false),
                          }),
                }
              else
                {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => SignUp(
                                mob_number: widget.phonenumber,
                                auth: widget.auth,
                              )),
                      (route) => false),
                  // databaseReference.child('allusers').set(value),
                },
              print("OTP: " + map.toString()),
            } // print("OTP: "+ value.value.toString()),
        );
  }
}
