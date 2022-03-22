import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uber_hacktag_group_booking/Enter/signup.dart';

import '../MainHomePage.dart';
import '../konstants/ResponsiveWidget.dart';
import '../konstants/loaders.dart';
import '../konstants/size_config.dart';
import 'googlesignindialog.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

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
// String _currentSelectedCustomerType;

class _LoginState extends State<Login> {
  String _mail, _password;
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  final storage = FlutterSecureStorage();

  bool ieeeMenber = false;
  double _height, _width, _pixelRatio;
  bool pict = false;
  bool _large,_medium;
  String pictRegID;
  bool load = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController collegeController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController password1Controller = TextEditingController();
  TextEditingController ieee = TextEditingController();
  TextEditingController registrationController = TextEditingController();
  final _dropdownFormKey = GlobalKey<FormState>();

  signInWithGoogle() async {
    setState(() {
      load = true;
    });
    // Trigger the authentication flow
    try {
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      // Once signed in, return the UserCredential
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      String uid = userCredential.user.uid;
      DocumentSnapshot ds = await users.doc(uid).get();
      if (ds.exists) {
        Map<String, dynamic> map = ds.data();
        // (ds.data())
        if (map.containsKey('city')) {
          setState(() {
            load = false;
          });
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => MainHomePage()),
              (route) => false);
        } else {
          setState(() {
            load = false;
          });
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => googlesignindialog()),
              (route) => false);
        }
      } else {
        // users
        //     .add({
        //   'email': mail, // John Doe
        //   'name': name, //// 42
        // })
        //     .then((value) => print("User Added"))
        //     .catchError((error) => print("Failed to add user: $error"));
        User user1 = userCredential.user;
        Map<String, dynamic> user;
        if (user1.phoneNumber != null && user1.phoneNumber.isNotEmpty) {
          user = {
            'email': user1.email,
            'name': user1.displayName,
            'phone': user1.phoneNumber
          };
        } else {
          user = {
            'email': user1.email,
            'name': user1.displayName,
          };
        }
        users.doc(uid).set(user).then((value) {
          Fluttertoast.showToast(msg: 'Signed Up Successfully');
          setState(() {
            load = false;
          });
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => googlesignindialog()),
              (route) => false);
        }).catchError((onError) {
          Fluttertoast.showToast(msg: onError.toString());
        });
      }
    } catch (e) {
      setState(() {
        load = false;
      });
      Fluttertoast.showToast(msg: 'Something went wrong');
      print(e.toString());
    }
  }

  login() async {
    try {
      print(_mail);
      print(_password);
      UserCredential authResult = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: "$_mail", password: "$_password");
      setState(() {
        load = false;
      });
      // Firestore.instance.collection('users').doc(authResult.user.uid);
      // DocumentSnapshot
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection('users')
          .doc(authResult.user.uid.toString());
      var userDetails;
      await documentReference.get().then((value) async => {
            // value.data()
            print("documentReference " + value.data().toString()),
            userDetails = value.data(),
            print("documentReference" + userDetails['customerType'].toString()),
            await storage.write(
                key: 'customerType', value: userDetails['customerType']),
          });
      Fluttertoast.showToast(msg: 'Logged in');
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => MainHomePage()),
          (route) => false);
    } catch (e) {
      setState(() {
        load = false;
      });
      if (e.toString().toLowerCase().contains('user_not_found')) {
        setState(() {
          load = false;
        });
        Fluttertoast.showToast(msg: 'No user found for that email.');
      } else if (e.toString().toLowerCase().contains('wrong-password')) {
        setState(() {
          load = false;
        });
        Fluttertoast.showToast(msg: 'Wrong password provided for that user.');
      } else {
        setState(() {
          load = false;
        });
        Fluttertoast.showToast(msg: e.toString());
      }
    }
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLogIn();
  }

  getLogIn() async {}

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _large = ResponsiveWidget.isScreenLarge(_width, _pixelRatio);
    _medium = ResponsiveWidget.isScreenMedium(_width, _pixelRatio);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: load == true
          ? Container(child: spinkit)
          : SafeArea(
              child: CustomPaint(
                size: Size.fromHeight(MediaQuery.of(context).size.height),
                painter: BackgroundSignIn(),
                child: Padding(
                  padding: const EdgeInsets.all(36.0),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: SizeConfig.screenHeight / 10, // 6
                          // child: Image.asset(
                          //   "images/login.png",
                          //   fit: BoxFit.contain,
                          // ),
                        ),
                        Column(
                          children: [
                            SizedBox(height: 40.0),
                            Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(50.0)),
                                color: Colors.black
                              ),
                              padding: EdgeInsets.all(15.0),
                              child: Image.asset(
                                "images/uberlogo.jpg",
                                fit: BoxFit.fitWidth,
                                width: 80,
                                height: 80,
                              ),
                            ),
                            SizedBox(height: 30.0),

                            Material(
                              borderRadius: BorderRadius.circular(25.0),
                              elevation: _large ? 12 : (_medium ? 10 : 8),
                              child: TextFormField(
                                onSaved: (val) {
                                  setState(() {
                                    _mail = val;
                                  });
                                },
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                cursorColor: Color(0xff3e60c1),
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.email,
                                      color: Color(0xff3e60c1), size: 20),
                                  hintText: "Email",
                                  hintStyle: TextStyle(
                                      fontFamily: 'MontserratMed',
                                      color: Colors.blueGrey),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                      borderSide: BorderSide.none),
                                ),
                                style: TextStyle(
                                    fontFamily: 'MontserratMed',
                                    color: Colors.black),
                                onChanged: (val) {
                                  // setState(() {
                                  //   email = val;
                                  // });
                                },
                              ),
                            ),
                            SizedBox(height: 25.0),

                            Material(
                              borderRadius: BorderRadius.circular(25.0),
                              elevation: _large ? 12 : (_medium ? 10 : 8),
                              child: TextFormField(
                                onSaved: (val) {
                                  setState(() {
                                    _password = val;
                                  });
                                },
                                controller: passwordController,
                                keyboardType: TextInputType.text,
                                cursorColor: Color(0xff3e60c1),
                                style: TextStyle(
                                    fontFamily: 'MontserratMed',
                                    color: Colors.black),
                                decoration: InputDecoration(
                                    hintStyle: TextStyle(
                                        fontFamily: 'MontserratMed',
                                        color: Colors.blueGrey),
                                    prefixIcon: Icon(Icons.lock,
                                        color: Color(0xff3e60c1), size: 20),
                                    hintText: "Password",
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                        borderSide: BorderSide.none),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _obscureText = !_obscureText;
                                        });
                                      },
                                      icon: _obscureText
                                          ? Icon(Icons.visibility)
                                          : Icon(Icons.visibility_off),
                                      color: Color(0xff3e60c1),
                                    )),
                                onChanged: (val) {
                                  // setState(() {
                                  //   password = val;
                                  // });
                                },
                                obscureText: _obscureText,
                              ),
                            ),
                            SizedBox(height: _height / 30.0),

                            SizedBox(
                              height: 35.0,
                            ),
                            Material(
                              elevation: 5.0,
                              borderRadius: BorderRadius.circular(30.0),
                              color: Color(0xff2e4583),
                              child: MaterialButton(
                                minWidth:
                                    MediaQuery.of(context).size.width * 0.6,
                                padding:
                                    EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                onPressed: () async {
                                  if (_formKey.currentState.validate()) {
                                    _formKey.currentState.save();
                                    setState(() {
                                      load = true;
                                    });
                                    await login();
                                  }
                                },
                                child: Text(
                                  "Login",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: 'MontserratSemi',
                                      fontSize: 20,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            _getBottomRow(context),

                            SizedBox(
                              height: 30.0,
                            ),

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

  _getBottomRow(context) {
    return Row(
      // crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => SignUp()));
            },
            child: Text(
              "Don't have an account, Sign Up",
              style: TextStyle(
                color: Colors.orange.withAlpha(500),
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontFamily: 'MontserratMed',
              ),
            ),
          ),
        ),
        Text(
          '',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }
}
