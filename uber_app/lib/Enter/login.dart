import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import '../konstants/loaders.dart';
import 'otp.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

// String _currentSelectedCustomerType;

// double _height;
// double _width;
// double _pixelRatio;
// bool pict = false;
// bool _large;
// bool _medium;
// bool _obscureText = true;
// double lat;
// double long;
// String pictRegID;
// String city;
// signInWithGoogle() async {
class _LoginState extends State<Login> {
  //   setState(() {
  //     load = true;
  //   });
  //   // Trigger the authentication flow
  //   try {
  //     final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
  //
  //     // Obtain the auth details from the request
  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser.authentication;
  //
  //     // Create a new credential
  //     final AuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );
  //     // Once signed in, return the UserCredential
  //     UserCredential userCredential =
  //         await FirebaseAuth.instance.signInWithCredential(credential);
  //     String uid = userCredential.user.uid;
  //     DocumentSnapshot ds = await users.doc(uid).get();
  //     if (ds.exists) {
  //       Map<String, dynamic> map = ds.data();
  //       // (ds.data())
  //       if (map.containsKey('city')) {
  //         setState(() {
  //           load = false;
  //         });
  //         Navigator.pushAndRemoveUntil(
  //             context,
  //             MaterialPageRoute(
  //                 builder: (BuildContext context) => MainHomePage()),
  //             (route) => false);
  //       } else {
  //         setState(() {
  //           load = false;
  //         });
  //         Navigator.pushAndRemoveUntil(
  //             context,
  //             MaterialPageRoute(
  //                 builder: (BuildContext context) => googlesignindialog()),
  //             (route) => false);
  //       }
  //     } else {
  //       // users
  //       //     .add({
  //       //   'email': mail, // John Doe
  //       //   'name': name, //// 42
  //       // })
  //       //     .then((value) => print("User Added"))
  //       //     .catchError((error) => print("Failed to add user: $error"));
  //       User user1 = userCredential.user;
  //       Map<String, dynamic> user;
  //       if (user1.phoneNumber != null && user1.phoneNumber.isNotEmpty) {
  //         user = {
  //           'email': user1.email,
  //           'name': user1.displayName,
  //           'phone': user1.phoneNumber
  //         };
  //       } else {
  //         user = {
  //           'email': user1.email,
  //           'name': user1.displayName,
  //         };
  //       }
  //       users.doc(uid).set(user).then((value) {
  //         Fluttertoast.showToast(msg: 'Signed Up Successfully');
  //         setState(() {
  //           load = false;
  //         });
  //         Navigator.pushAndRemoveUntil(
  //             context,
  //             MaterialPageRoute(
  //                 builder: (BuildContext context) => googlesignindialog()),
  //             (route) => false);
  //       }).catchError((onError) {
  //         Fluttertoast.showToast(msg: onError.toString());
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       load = false;
  //     });
  //     Fluttertoast.showToast(msg: 'Something went wrong');
  //     print(e.toString());
  //   }
  String phoneNumber;
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  final storage = const FlutterSecureStorage();
  String countryCode = "+91";
  double _height, _width, _pixelRatio;
  bool pict = false;
  bool load = false;

  FirebaseAuth auth;

  TextEditingController phoneController = TextEditingController();

  // }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // FirebaseAuth mAuth = FirebaseAuth.;

    getLogIn();
  }

  login() async {
    auth = FirebaseAuth.instance;
    await auth.verifyPhoneNumber(
      phoneNumber: countryCode + phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          load = false;
        });
        if (e.toString().toLowerCase().contains('user_not_found')) {
          setState(() {
            load = false;
          });
          Fluttertoast.showToast(msg: 'No user found for that number');
        } else {
          setState(() {
            load = false;
          });
          print(e);
          Fluttertoast.showToast(msg: e.toString());
        }
      },
      codeSent: (String verificationId, int resendToken) {
        setState(() {
          load = false;
        });
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => OTPScreen(
                      verificationId: verificationId,
                      auth: auth,
                      phonenumber: phoneNumber,
                    )));
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // signInWithFacebook()async{
  //   try {
  //     // by default the login method has the next permissions ['email','public_profile']
  //     AccessToken accessToken = await FacebookAuth.instance.login();
  //     print(accessToken.toJson());
  //     // get the user data
  //     final userData = await FacebookAuth.instance.getUserData();
  //     print(userData);
  //   } on FacebookAuthException catch (e) {
  //     switch (e.errorCode) {
  //       case FacebookAuthErrorCode.OPERATION_IN_PROGRESS:
  //         print("You have a previous login operation in progress");
  //         break;
  //       case FacebookAuthErrorCode.CANCELLED:
  //         print("login cancelled");
  //         break;
  //       case FacebookAuthErrorCode.FAILED:
  //         print("login failed");
  //         break;
  //     }
  //   }
  // }
  Widget horizontalLine() => Container(
        width: MediaQuery.of(context).size.width / 4,
        height: 1.0,
        color: Colors.black26.withOpacity(.2),
      );

  getLogIn() async {}

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: load == true
          ? Container(child: spinkit)
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Form(
                  key: _formKey,
                  child: Center(
                    child: ListView(
                      shrinkWrap: true,
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          children: [
                            const SizedBox(height: 40.0),
                            Container(
                              height: 100,
                              width: 100,
                              decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50.0)),
                                  color: Colors.black),
                              padding: const EdgeInsets.all(15.0),
                              child: Image.asset(
                                "images/uberlogo.jpg",
                                fit: BoxFit.fitWidth,
                                width: 80,
                                height: 80,
                              ),
                            ),
                            const SizedBox(height: 30.0),
                            Row(
                              children: [
                                Container(
                                  child: CountryCodePicker(
                                    onChanged: (val) {
                                      print(val);
                                      setState(() {
                                        countryCode = val.code;
                                      });
                                    },
                                    // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                    initialSelection: 'IN',
                                    favorite: ['+91', 'IN'],
                                    // optional. Shows only country name and flag
                                    showCountryOnly: false,
                                    // optional. Shows only country name and flag when popup is closed.
                                    showOnlyCountryWhenClosed: false,
                                    showFlag: true,
                                    // optional. aligns the flag and the Text left
                                    alignLeft: false,
                                  ),
                                ),
                                Expanded(
                                  child: Material(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 8),
                                      child: TextFormField(
                                        onSaved: (val) {
                                          setState(() {
                                            phoneNumber = val.trim();
                                          });
                                        },
                                        keyboardType: TextInputType.number,
                                        style: GoogleFonts.workSans(
                                            color: Colors.black, fontSize: 14),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: "Phone Number",
                                          focusColor: Colors.black,
                                          labelStyle: GoogleFonts.workSans(
                                              fontSize: 14),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: _height / 30.0),

                            const SizedBox(
                              height: 35.0,
                            ),
                            // Material(
                            //   elevation: 5.0,
                            //   borderRadius: BorderRadius.circular(30.0),
                            //   color: const Color(0xff2e4583),
                            //   child: MaterialButton(
                            //     minWidth:
                            //         MediaQuery.of(context).size.width * 0.6,
                            //     padding:
                            //         const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                            //     onPressed: () async {
                            //       if (_formKey.currentState.validate()) {
                            //         _formKey.currentState.save();
                            //         setState(() {
                            //           load = true;
                            //         });
                            //         await login();
                            //       }
                            //     },
                            //     child: const Text(
                            //       "Login",
                            //       textAlign: TextAlign.center,
                            //       style: TextStyle(
                            //           fontFamily: 'MontserratSemi',
                            //           fontSize: 20,
                            //           color: Colors.white),
                            //     ),
                            //   ),
                            // ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: GestureDetector(
                                onTap: () async {
                                  if (_formKey.currentState.validate()) {
                                    _formKey.currentState.save();
                                    setState(() {
                                      load = true;
                                    });
                                    await login();
                                  }
                                },
                                child: Container(
                                  color: Colors.black,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Center(
                                      child: Text(
                                        'LOGIN',
                                        style: GoogleFonts.workSans(
                                            fontSize: 20, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )

//                         // Row(
//                         //   mainAxisAlignment: MainAxisAlignment.center,
//                         //   children: <Widget>[
//                         //     horizontalLine(),
//                         //     Text(" Social Login ",
//                         //         style: TextStyle(
//                         //             fontSize: 16.0, fontFamily: "Poppins-Medium")),
//                         //     horizontalLine()
//                         //   ],
//                         // ),
//                         // Padding(
//                         //   padding: const EdgeInsets.only(top: 10.0),
//                         //   child: Row(
//                         //     mainAxisAlignment: MainAxisAlignment.center,
//                         //     crossAxisAlignment: CrossAxisAlignment.center,
//                         //     children: <Widget>[
//                         //       SignInButtonBuilder(
//                         //         text: 'Google',
//                         //         mini: true,
//                         //         shape: CircleBorder(),
//                         //         icon: FontAwesomeIcons.google,
//                         //         backgroundColor: Colors.red.shade900,
//                         //         onPressed: () async {
//                         //           await signInWithGoogle();
//                         //           // try {
//                         //           //   FirebaseUser user =
//                         //           //   await auth.handleGoogleSignIn(context);
//                         //           //   validateUser(context, user);
//                         //           // }catch(e){
//                         //           //   print('GoogleError');
//                         //           //   print(e.toString());
//                         //           // }
//                         //         },
//                         //       ),
//
//
// //                           Text(
// //                             'Login with Google',
// // //                                style: GoogleFonts.openSans(),
// //                             style: TextStyle(
// //                                 color: Colors.black,
// //                                 fontWeight: FontWeight.bold),
// //                           ),
//
//                             ],
//                           ),
//                         ),
                          ],
                        ),
                        // TextFormField(
                        //   obscureText: false,
                        //   decoration: InputDecoration(
                        //       contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        //       hintText: "Email",
                        //       border:
                        //       OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
                        //   validator: (val) {
                        //     if (val.isEmpty) {
                        //       return 'This field cannot be empty!';
                        //     } else if (!validateEmail(val)) {
                        //       return 'Enter a valid email!';
                        //     }
                        //     return null;
                        //   },
                        //   onSaved: (val) => _mail = val,
                        // ),

                        // Row(
                        //   children: [
                        //     Expanded(
                        //       child: TextFormField(
                        //       obscureText: _obscureText,
                        //         decoration: InputDecoration(
                        //             contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        //             hintText: "Password",
                        //             border:
                        //             OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
                        //
                        //         validator: (val) => val.length < 6
                        //             ? 'Password must be at least 6 characters long!'
                        //             : null,
                        //         onChanged: (val) => _password = val,
                        //
                        //       ),
                        //     ),
                        //     IconButton(
                        //       icon: Icon(
                        //         _obscureText
                        //             ? Icons.visibility_off
                        //             : Icons.visibility,
                        //         color:
                        //         Colors.black,
                        //       ),
                        //       onPressed: () {
                        //         setState(() {
                        //           _obscureText = !_obscureText;
                        //         });
                        //       },
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (!regex.hasMatch(value)) ? false : true;
  }
}
