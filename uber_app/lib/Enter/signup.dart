import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uber_hacktag_group_booking/Driver/DriverHomePage.dart';
import 'package:uber_hacktag_group_booking/Enter/login.dart';
import 'package:uuid/uuid.dart';

import '../konstants/ResponsiveWidget.dart';
import '../konstants/functions.dart';
import '../konstants/loaders.dart';
import '../pages/MainHomePage.dart';

class SignUp extends StatefulWidget {
  String mob_number;
  FirebaseAuth auth;

  SignUp({this.mob_number, this.auth});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  String mail, name;
  bool load = false;
  bool _obscureText = true;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // CollectionReference alluserscol =
  //     FirebaseFirestore.instance.collection('allusers');
  // CollectionReference driversCol =
  //     FirebaseFirestore.instance.collection('driver');
  // CollectionReference userscol = FirebaseFirestore.instance.collection('users');
  DatabaseReference allUsersDatabaseReference =
      FirebaseDatabase.instance.ref().child('allusers');
  DatabaseReference driversDatabaseReference =
      FirebaseDatabase.instance.ref().child('drivers');
  DatabaseReference usersDatabaseReference =
      FirebaseDatabase.instance.ref().child('users');

  TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  final _dropdownFormKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();

  double _height;
  double _width;
  double _pixelRatio;
  bool pict = false;
  bool _large;
  bool _medium;
  double lat;
  double long;
  String pictRegID;
  String city;
  String _currentSelectedCustomerType;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  OutlineInputBorder border = const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey, width: 3.0));

  String smsCode = null;

  void toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void initState() {
    super.initState();
    phoneController.text = widget.mob_number;
  }

  getUserLocation() async {
    //call this async method from whereever you need

    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled don't continue
        // accessing the position and request users of the
        // App to enable the location services.
        await openLocationSetting();
      }

      permission = await Geolocator.checkPermission();
      // print(permission);
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          // Permissions are denied forever, handle appropriately.
          return Future.error(
              'Location permissions are permanently denied, we cannot request permissions.');
        }

        if (permission == LocationPermission.denied) {
          // Permissions are denied, next time you could try
          // requesting permissions again (this is also where
          // Android's shouldShowRequestPermissionRationale
          // returned true. According to Android guidelines
          // your App should show an explanatory UI now.
          return Future.error('Location permissions are denied');
        }
      }
      // print('1');
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      // print('1');
      // final coordinates =
      //     new Coordinates(position.latitude,position.longitude);//Coordinates(position.latitude, position.longitude);
      // print(position.latitude);
      var addresses = await placemarkFromCoordinates(
          position.latitude,
          position
              .longitude); //Geocoder.local.findAddressesFromCoordinates(coordinates);
      // print(position.latitude);
      // print(addresses);
      var first = addresses.first;
      // addresses.first.administrativeArea
      // print(
      //     ' ${first.locality}, ${first.administrativeArea},${first.subLocality}, ${first.subAdministrativeArea},${first.street}, ${first.name},${first.thoroughfare}, ${first.subThoroughfare}');
      setState(() {
        city = addresses.first.locality;
        cityController.text = city;
      });
    } on PlatformException catch (e) {
      print(e.details);
      print(e.message);
      print(e.code);
      if (e.code == 'PERMISSION_DENIED') {}
      if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {}
    } catch (e) {
      print(e.toString());
    }
  }

  Future<bool> createUser() async {
    try {
      print("SIGNUP: Creating user and storing it in firestore");
      // UserCredential userCredential = await FirebaseAuth.instance
      //     .createUserWithEmailAndPassword(email: mail, password: password);
      // var result = await _auth.signInWithCredential(credential);
      String uid = widget
          .auth.currentUser.uid; //result.user.uid; //userCredential.user.uid;
      Map<String, dynamic> user;
      var uuid = const Uuid();
      var randId = uuid.v1();
      // var uuidStr = uuid.toString().substring(0,8);
      name = nameController.text;
      mail = emailController.text;
      if (_currentSelectedCustomerType == "Driver") {
        user = {
          'id': randId.substring(0, 8),
          'email': mail,
          'name': name,
          'phone': widget.mob_number,
          'city': city,
          'uid': uid,
        };
      } else {
        user = {
          'id': randId.substring(0, 8),
          'email': mail,
          'name': name,
          'phone': widget.mob_number,
          'city': city,
          'uid': uid,
        };
      }
      print(user);
      allUsersDatabaseReference
          .child(uid)
          .set(user)
          .then((value) => {
                print("_currentSelectedCustomerType" +
                    _currentSelectedCustomerType.toString()),
                if (_currentSelectedCustomerType == "Driver")
                  {driversDatabaseReference.child(uid).set(user)}
                else
                  {usersDatabaseReference.child(uid).set(user)}
              })
          .whenComplete(() async => {
                await storage.write(key: 'loginstate', value: 'true'),
                await storage.write(key: 'userType', value: 'user'),
        await storage.write(key: 'name', value: name),

        setState(() {
                  load = false;
                }),
                // await FlutterSecureStorage
                Fluttertoast.showToast(msg: 'Signed Up Successfully'),
                if (_currentSelectedCustomerType == "Driver")
                  {
                    await storage.write(key: 'userType', value: 'Driver'),
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                DriverHomePage()),
                        (route) => false),
                  }
                else
                  {
                    await storage.write(key: 'userType', value: 'User'),
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => MainHomePage()),
                        (route) => false),
                  },

                await storage.write(
                    key: 'customerType', value: _currentSelectedCustomerType),
              })
          .catchError((onError) {
        print("SIGNUP: " + onError.toString());
        setState(() {
          load = false;
        });
        Fluttertoast.showToast(msg: onError.toString());
      });
      // alluserscol
      //     .doc(uid)
      //     .set(user)
      //     .then((value) => {
      //           if (_currentSelectedCustomerType == "driver")
      //             {driversCol.doc(uid).set(user)}
      //           else
      //             {userscol.doc(uid).set(user)}
      //         })
      //     .whenComplete(() async => {
      //           setState(() {
      //             load = false;
      //           }),
      //           Fluttertoast.showToast(msg: 'Signed Up Successfully'),
      //           Navigator.pushAndRemoveUntil(
      //               context,
      //               MaterialPageRoute(
      //                   builder: (BuildContext context) => MainHomePage()),
      //               (route) => false),
      //           await storage.write(
      //               key: 'customerType', value: _currentSelectedCustomerType),
      //         })
      //     .catchError((onError) {
      //   print("SIGNUP: " + onError.toString());
      //   // showMessage(onError.toString());
      //   setState(() {
      //     load = false;
      //   });
      //   Fluttertoast.showToast(msg: onError.toString());
      // }); //.whenComplete(() => {});
    } catch (e) {
      // setState(() {
      //   load = false;
      // });
      // if (e.toString().toLowerCase().contains('weak_password')) {
      //   Fluttertoast.showToast(msg: 'The password provided is too weak.');
      // } else if (e.toString().toLowerCase().contains('email_already_in_use')) {
      //   setState(() {
      //     load = false;
      //   });
      //   Fluttertoast.showToast(
      //       msg: 'The account already exists for that email.');
      // } else {
      setState(() {
        load = false;
      });
      print('SIGNUP: error ' + e.toString());
      Fluttertoast.showToast(msg: 'Try again in sometime' + e.toString());
      // }
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _large = ResponsiveWidget.isScreenLarge(_width, _pixelRatio);
    _medium = ResponsiveWidget.isScreenMedium(_width, _pixelRatio);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: load == true
          ? spinkit
          : SafeArea(
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  children: [
                    CustomPaint(
                      painter: BackgroundSignUp(),
                      child: Stack(
                        children: <Widget>[
                          _getBackImage(),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 35, vertical: 20),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Container(
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          _getHeader(),
                                          _getTextFields(),
                                          _getSignIn(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          _getBackBtn(),
                        ],
                      ),
                    ),
                  ],
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

  _getBackImage() {
    return ClipPath(
      clipper: _CustomClipper(),
      child: Container(
          // decoration: BoxDecoration(
          //     image: DecorationImage(
          //   fit: BoxFit.fitWidth,
          //   alignment: Alignment.topCenter,
          //   image: AssetImage("images/signup.jpeg"),
          // )),
          ),
    );
  }

  _getBackBtn() {
    return Positioned(
      top: 35,
      left: 25,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => Login()));
        },
        child: Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
        ),
      ),
    );
  }

/*
  _getBottomRow(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Already a user Sign in here',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              fontFamily: 'MontserratMed',
            ),
          ),
        ),
        const Text(
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
*/

  _getSignIn() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        const Text(
          'Sign up',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w500,
            fontFamily: 'MontserratSemi',
          ),
        ),
        InkWell(
          onTap: () async {
            setState(() {
              load = true;
            });
            // FirebaseService service = new FirebaseService();
            if (_formKey.currentState.validate()) {
              await createUser();
            } else {
              setState(() {
                load = false;
              });
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade800,
              radius: 25,
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    );
  }

  // var _currencies = ["Producer", "Consumer"];

  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(child: Text("User"), value: "User"),
      const DropdownMenuItem(child: Text("Driver"), value: "Driver"),
      // DropdownMenuItem(child: Text("Brazil"),value: "Brazil"),
      // DropdownMenuItem(child: Text("England"),value: "England"),
    ];
    return menuItems;
  }

  _getTextFields() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        const SizedBox(
          height: 15,
        ),
        Material(
          borderRadius: BorderRadius.circular(10.0),
          elevation: _large ? 12 : (_medium ? 10 : 8),
          child: TextFormField(
            controller: nameController,
            validator: (val) {
              if (val.isEmpty) {
                return 'This field cannot be empty!';
              }
              return null;
            },
            onSaved: (val) => name = val,
            keyboardType: TextInputType.text,
            cursorColor: const Color(0xff000000),
            style: const TextStyle(
              fontFamily: 'MontserratMed',
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              prefixIcon:
                  const Icon(Icons.person, color: Color(0xff000000), size: 20),
              hintText: "Name",
              hintStyle: const TextStyle(
                fontFamily: 'MontserratMed',
                color: Colors.blueGrey,
                fontWeight: FontWeight.bold,
              ),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none),
            ),
            onChanged: (val) {
              // setState(()=> {
              //   name = val;
              // });
            },
          ),
        ),
        SizedBox(height: _height / 30.0),
        Material(
          borderRadius: BorderRadius.circular(10.0),
          elevation: _large ? 12 : (_medium ? 10 : 8),
          child: TextFormField(
            validator: (val) {
              if (val.isEmpty) {
                return 'This field cannot be empty!';
              } else if (!validateEmail(val)) {
                return 'Enter a valid email!';
              }
              return null;
            },
            onSaved: (val) => mail = val,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            cursorColor: const Color(0xff000000),
            style: const TextStyle(
              fontFamily: 'MontserratMed',
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintStyle: const TextStyle(
                fontFamily: 'MontserratMed',
                color: Colors.blueGrey,
                fontWeight: FontWeight.bold,
              ),
              prefixIcon:
                  const Icon(Icons.email, color: Color(0xff000000), size: 20),
              hintText: "Email",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none),
            ),
            onChanged: (val) {
              // setState(() {
              //   email = val;
              // });
            },
          ),
        ),
        SizedBox(height: _height / 30.0),
        Material(
          borderRadius: BorderRadius.circular(10.0),
          elevation: _large ? 12 : (_medium ? 10 : 8),
          child: TextFormField(
            enabled: false,
            readOnly: true,
            // validator: (val) {
            //   if (val.isEmpty) {
            //     return 'This field cannot be empty!';
            //   } else if (val.trim().length < 10) {
            //     return 'Enter a valid phone number!';
            //   }
            //   return null;
            // },
            // onSaved: (val) => phoneNumber = val,
            controller: phoneController,
            keyboardType: TextInputType.phone,
            cursorColor: const Color(0xff000000),
            decoration: InputDecoration(
              hintStyle: const TextStyle(
                fontFamily: 'MontserratMed',
                color: Colors.blueGrey,
                fontWeight: FontWeight.bold,
              ),
              prefixIcon:
                  const Icon(Icons.phone, color: Color(0xff000000), size: 20),
              hintText: "Phone Number",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none),
            ),

            // onChanged: (val) {
            //   // setState(() {
            //   //   print('SIGNUP: onchanged'+ val);
            //   widget.mob_number = val;
            //   // });
            // },

            style: const TextStyle(
              fontFamily: 'MontserratMed',
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: _height / 30.0),
        Material(
          borderRadius: BorderRadius.circular(10.0),
          elevation: _large ? 12 : (_medium ? 10 : 8),
          child: DropdownButtonFormField(
            key: _dropdownFormKey,
            validator: (value) =>
                value == null ? "Please select your Customer type" : null,
            hint: const Text(
              'Customer Type',
              style: TextStyle(
                fontFamily: 'MontserratMed',
                color: Colors.blueGrey,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: const TextStyle(
              fontFamily: 'MontserratMed',
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              // focusColor: white,

              hintStyle: const TextStyle(
                fontFamily: 'MontserratMed',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              prefixIcon: const Icon(Icons.people_rounded,
                  color: Color(0xff000000), size: 20),
              hintText: "Customer Type",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none),
            ),
            dropdownColor: Colors.white,
            value: _currentSelectedCustomerType,
            onChanged: (newValue) {
              setState(() {
                _currentSelectedCustomerType = newValue;
              });
            },
            items: dropdownItems,
          ),
        ),
        SizedBox(height: _height / 30.0),
        Material(
          borderRadius: BorderRadius.circular(10.0),
          elevation: _large ? 12 : (_medium ? 10 : 8),
          child: TextFormField(
            validator: (val) {
              if (val.isEmpty) {
                return 'This field cannot be empty!';
              }
              return null;
            },
            onSaved: (val) => city = val,
            controller: cityController,
            keyboardType: TextInputType.phone,
            cursorColor: const Color(0xff000000),
            decoration: InputDecoration(
              hintStyle: const TextStyle(
                fontFamily: 'MontserratMed',
                color: Colors.blueGrey,
                fontWeight: FontWeight.bold,
              ),
              prefixIcon: const Icon(Icons.location_city,
                  color: Color(0xff000000), size: 20),
              hintText: "City",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none),
            ),
            readOnly: true,
            style: const TextStyle(
              fontFamily: 'MontserratMed',
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            onTap: () async {
              await getUserLocation();
            },
          ),
        ),
      ],
    );
  }

  _getHeader() {
    return Container(
      margin: const EdgeInsets.only(top: 50),
      alignment: Alignment.bottomLeft,
      child: const Text(
        'Create\nAccount',
        style: TextStyle(
          color: Colors.white,
          fontSize: 40,
          fontFamily: 'MontserratMed',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /* Future<void> phoneSignIn(String phoneNumber) async {
    // await _auth.phone
    print("SIGNUP: " + '+91 ' + phoneNumber.toString());
    await _auth.verifyPhoneNumber(
        phoneNumber: '+91' + phoneNumber,
        verificationCompleted: _onVerificationCompleted,
        verificationFailed: _onVerificationFailed,
        codeSent: _onCodeSent,
        codeAutoRetrievalTimeout: _onCodeTimeout);
  }

  _onVerificationCompleted(PhoneAuthCredential authCredential) async {
    print("SIGNUP: verification completed ${authCredential.smsCode}");
    User user = FirebaseAuth.instance.currentUser;
    setState(() {
      this.otpCode.text = authCredential.smsCode;
    });
    if (authCredential.smsCode != null) {
      try {
        UserCredential credential =
            await user.linkWithCredential(authCredential);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'provider-already-linked') {
          await _auth.signInWithCredential(authCredential);
        }
      }
      setState(() {
        load = false;
      });
      showMessage("Login Successful");
      // Navigator.pushNamedAndRemoveUntil(
      //     context, HomePage(), (route) => false);
    }
  }

  _onVerificationFailed(FirebaseAuthException exception) {
    if (exception.code == 'invalid-phone-number') {
      print("SIGNUP: +91" + phoneNumber);
      showMessage("The phone number entered is invalid!");
    }
  }

  _onCodeSent(String verificationId, int forceResendingToken) async {
    print("SIGNUP:" + "code sent " + verificationId);
    this.verificationId = verificationId;
    print(forceResendingToken);
  }

  _onCodeTimeout(String timeout) {
    return null;
  }

  _verifyOTP(String verificationId, String smsCode) async {
    print("SIGNUP: verify" + smsCode);
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);
    var result;

    try {
      await createUser(credential);
    } catch (e) {
      load = false;
      print("SIGNUP: verify" + "failure message: " + e.toString());

      showMessage("Invalid Credentials or Error white creating user database");

      return false;
    }
    print("SIGNUP: verify" + "success");
    // if(await createUser()){
    //   setState(() {
    //     load = false;
    //   });
    //
    // }else{
    //   showMessage("Error white creating user database");
    // }

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => MainHomePage()),
        (route) => false);
  }
*/
  void showMessage(String errorMessage) {
    showDialog(
        context: context,
        builder: (BuildContext builderContext) {
          return AlertDialog(
            title: Text("Error"),
            content: Text(
              errorMessage,
              style: TextStyle(color: Colors.black),
            ),
            actions: [
              TextButton(
                child: Text(
                  "Ok",
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () async {
                  Navigator.of(builderContext).pop();
                },
              )
            ],
          );
        }).then((value) {
      // setState(() {
      //   load = false;
      // });
    });
  }
}

class BackgroundSignIn extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var sw = size.width;
    var sh = size.height;
    var paint = Paint();

    Path mainBackground = Path();
    mainBackground.addRect(Rect.fromLTRB(0, 0, sw, sh));
    paint.color = Colors.grey.shade100;
    canvas.drawPath(mainBackground, paint);

    // Path blueWave = Path();
    // blueWave.lineTo(sw, 0);
    // blueWave.lineTo(sw, sh * 0.5);
    // blueWave.quadraticBezierTo(sw * 0.5, sh * 0.45, sw * 0.2, 0);
    // blueWave.close();
    // paint.color = Colors.lightBlue.shade300;
    // canvas.drawPath(blueWave, paint);

    // Path greyWave = Path();
    // greyWave.lineTo(sw, 0);
    // greyWave.lineTo(sw, sh * 0.1);
    // greyWave.cubicTo(
    //     sw * 0.95, sh * 0.15, sw * 0.65, sh * 0.15, sw * 0.6, sh * 0.38);
    // greyWave.cubicTo(sw * 0.52, sh * 0.52, sw * 0.05, sh * 0.45, 0, sh * 0.4);
    // greyWave.close();
    // paint.color = Colors.grey.shade800;
    // canvas.drawPath(greyWave, paint);

    Path yellowWave = Path();
    yellowWave.lineTo(sw * 0.7, 0);
    yellowWave.cubicTo(
        sw * 0.6, sh * 0.05, sw * 0.27, sh * 0.01, sw * 0.18, sh * 0.12);
    yellowWave.quadraticBezierTo(sw * 0.12, sh * 0.2, 0, sh * 0.2);
    yellowWave.close();
    paint.color = const Color(0xff000000);
    canvas.drawPath(yellowWave, paint);

    Path yellowWaveBottom = Path();
    yellowWaveBottom.moveTo(sw * 0.3, sh);
    yellowWaveBottom.cubicTo(
        sw * 0.4, sh * 0.95, sw * 0.73, sh * 0.99, sw * 0.82, sh * 0.88);
    yellowWaveBottom.quadraticBezierTo(sw * 0.88, sh * 0.8, sw, sh * 0.8);
    yellowWaveBottom.lineTo(sw, sh);
    yellowWaveBottom.close();
    paint.color = const Color(0xff000000);
    canvas.drawPath(yellowWaveBottom, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}

class BackgroundSignUp extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var sw = size.width;
    var sh = size.height;
    var paint = Paint();

    Path mainBackground = Path();
    mainBackground.addRect(Rect.fromLTRB(0, 0, sw, sh));
    paint.color = const Color(0xff000000);
    canvas.drawPath(mainBackground, paint);

    Path blueWave = Path();
    blueWave.lineTo(sw, 0);
    blueWave.lineTo(sw, sh * 0.65);
    blueWave.cubicTo(sw * 0.8, sh * 0.8, sw * 0.55, sh * 0.8, sw * 0.45, sh);
    blueWave.lineTo(0, sh);
    blueWave.close();
    paint.color = const Color(0x33ffffff);
    // paint.color = Colors.orange;
    canvas.drawPath(blueWave, paint);

    Path greyWave = Path();
    greyWave.lineTo(sw, 0);
    greyWave.lineTo(sw, sh * 0.3);
    greyWave.cubicTo(sw * 0.65, sh * 0.45, sw * 0.25, sh * 0.35, 0, sh * 0.5);
    greyWave.close();
    // paint.color = Colors.grey.shade800;
    paint.color = const Color(0xff000000);
    canvas.drawPath(greyWave, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}

class _CustomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final double heightDelta = size.height / 2.2;
    var sw = size.width;
    var sh = size.height;
    var paint = Paint();
    Path greyWave = Path();
    greyWave.lineTo(sw, 0);
    greyWave.lineTo(sw, sh * 0.3);
    greyWave.cubicTo(sw * 0.65, sh * 0.45, sw * 0.25, sh * 0.35, 0, sh * 0.5);
    greyWave.close();
    paint.color = Colors.grey.shade800;
    // canvas.drawImage( Image(image: AssetImage("images/signup.jpeg")), offset, paint);
    // canvas.drawPath(greyWave, paint);
    return greyWave;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
