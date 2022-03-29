import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uber_hacktag_group_booking/konstants/loaders.dart';
import 'package:uber_hacktag_group_booking/pages/MainHomePage.dart';
import 'package:uuid/uuid.dart';
import '../Enter/place_service.dart';
import '../address_search.dart';
import 'package:geocoder/geocoder.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show utf8;

class BookingForm extends StatefulWidget {
  int cabsCount;
  bool originSame;

  BookingForm({this.cabsCount, this.originSame});

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  // List<String> selectedCab = [];
  int cnt = 0;
  List<TextEditingController> _locationController = [];
  List<TextEditingController> _nameController = [];
  List<TextEditingController> _emailController = [];
  List<TextEditingController> _phoneController = [];
  TextEditingController _lController = TextEditingController();
  TextEditingController _timeC = TextEditingController();
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  List<bool> nameEmpty = [];
  List<bool> emailEmpty = [];
  List<bool> phoneEmpty = [];
  List<bool> locEmpty = [];
  List<Coordinates> crds = [];
  DateTime scheduleTime;
  bool lEmpty = false;
  bool timeEmpty = false;
  Coordinates cr;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DatabaseReference requestPool =
      FirebaseDatabase.instance.ref().child('requestPool');
  List<int> cost1;
  double cost;
  bool load = false;

  @override
  void initState() {
    // TODO: implement initState
    for (int i = 0; i < widget.cabsCount; i++) {
      nameEmpty.add(false);
      emailEmpty.add(false);
      phoneEmpty.add(false);
      locEmpty.add(false);
      _locationController.add(TextEditingController());
      _nameController.add(TextEditingController());
      _emailController.add(TextEditingController());
      _phoneController.add(TextEditingController());
      // selectedCab.add("Auto");
    }
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _nameController.forEach((element) {
      element.dispose();
    });
    _emailController.forEach((element) {
      element.dispose();
    });
    _phoneController.forEach((element) {
      element.dispose();
    });
    _locationController.forEach((element) {
      element.dispose();
    });
    _lController.dispose();
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    var res = 12742 * asin(sqrt(a));
    print("hello");
    print(res);
    return res;
  }

  determineCost() async {
    setState(() {
      load = true;
    });
    cost1 = [];
    cost = 0;
    var src =
        await Geocoder.local.findAddressesFromQuery(_lController.text.trim());
    Coordinates c = src.first.coordinates;
    cr = c;
    for (int i = 0; i < widget.cabsCount; i++) {
      var src1 = await Geocoder.local
          .findAddressesFromQuery(_locationController[i].text.trim());
      Coordinates coordinates = await src1.first.coordinates;
      int res = (calculateDistance(c.latitude, c.longitude,
                  coordinates.latitude, coordinates.longitude) *
              20)
          .ceil();
      cost1.add(res);
      crds.add(coordinates);
      cost = cost + res;
    }
    setState(() {
      load = false;
    });
  }

  getFile() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: ['csv', 'xlsx'],
    );
    File file = File(result.files.single.path);
    var encryptedBase64EncodedString=await file.readAsString(encoding:utf8);
    print(encryptedBase64EncodedString);
    // final input = file.openRead();
    // final fields = await input.transform(Utf8Decoder()).transform(new CsvToListConverter()).toList();
    // print(fields);
    // var request = http.MultipartRequest("POST", Uri.parse("https://csv-upload7676.herokuapp.com/upload"));
    // Map<String,String>header={
    //   "Content-Type":"multipart/form-data"
    // };
    // print(file.path);
    // request.files.add(await http.MultipartFile.fromPath("file",file.path));
    // request.headers.addAll(header);
    // var response =await request.send();
    // print('hell');
    // http.Response res=await http.Response.fromStream(response);
    // print(res.body);
    var uri = Uri.parse('https://csv-upload7676.herokuapp.com/upload');
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', file.path));
    var response = await request.send();
    // Utf8Decoder(
    print(response.headers);
    http.Response res=await http.Response.fromStream(response);
    print(res.statusCode);
    print(res.body);

    Uint8List u=latin1.encode(res.body);
    if (response.statusCode == 200) {
      setState(() {
        _nameController[0].text=res.body;
      });
      print('Uploaded!');
    };

  }

  addAllRidesToRequestPool() async {
    User user = await FirebaseAuth.instance.currentUser;
    var uuid = const Uuid();
    var randId1 = uuid.v1();
    DatabaseReference userRequest = FirebaseDatabase.instance
        .ref()
        .child('allusers')
        .child(user.uid)
        .child('rides')
        .child(randId1);
    for (int i = 0; i < widget.cabsCount; i++) {
      Map<String, dynamic> ride;
      var randId = uuid.v1();
      double dist = Geolocator.distanceBetween(
              cr.latitude, cr.longitude, crds[i].latitude, crds[i].longitude) /
          1000;
      scheduleTime =
          scheduleTime.subtract(Duration(minutes: (dist * 1.5).ceil()));
      print(scheduleTime);
      if (widget.originSame) {
        ride = {
          'passengerName': _nameController[i].text.trim(),
          'passengerEmail': _emailController[i].text.trim(),
          'passengerPhone': _phoneController[i].text.trim(),
          'source': _lController.text.trim(),
          'destination': _locationController[i].text.trim(),
          // 'type':selectedCab[i],
          'cost': cost1[i],
          'sourceLatitude': cr.latitude,
          'sourceLongitude': cr.longitude,
          'destinationLatitude': crds[i].latitude,
          'destinationLongitude': crds[i].longitude,
          'status': 'Finding',
          'uid': user.uid,
          'distance': dist.toStringAsPrecision(3),
          'scheduleTime': scheduleTime.millisecondsSinceEpoch,
          'gloabalRequestID': randId1
        };
      } else {
        ride = {
          'passengerName': _nameController[i].text.trim(),
          'passengerEmail': _emailController[i].text.trim(),
          'passengerPhone': _phoneController[i].text.trim(),
          'destination': _lController.text.trim(),
          'source': _locationController[i].text.trim(),
          // 'type':selectedCab[i],
          'cost': cost1[i],
          'sourceLatitude': crds[i].latitude,
          'sourceLongitude': crds[i].longitude,
          'destinationLatitude': cr.latitude,
          'destinationLongitude': cr.longitude,
          'status': 'Finding',
          'uid': user.uid,
          'distance': dist.toStringAsPrecision(2),
          'scheduleTime': scheduleTime.millisecondsSinceEpoch,
          'gloabalRequestID': randId1
        };
      }
      await requestPool.child(randId).set(ride).whenComplete(() => cnt++);
      await userRequest.child(randId).set(ride);
    }
    Map<String, dynamic> map;
    if (widget.originSame) {
      map = {
        'source': _lController.text.trim(),
        'sourceLatitude': cr.latitude,
        'sourceLongitude': cr.longitude,
        'dateTime': DateTime.now().millisecondsSinceEpoch,
        'numberOfCabs': widget.cabsCount
      };
    } else {
      map = {
        'destination': _lController.text.trim(),
        'destinationLatitude': cr.latitude,
        'destinationLongitude': cr.longitude,
        'dateTime': DateTime.now().millisecondsSinceEpoch,
        'numberOfCabs': widget.cabsCount
      };
    }
    await userRequest.update(map);
    if (cnt == widget.cabsCount) {
      Fluttertoast.showToast(msg: 'Cabs confirmed');
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => MainHomePage()),
          (route) => false);
    } else {
      Fluttertoast.showToast(msg: 'Please try again');
    }
  }

  Future<void> confirmationDialog(BuildContext context) async {
    await determineCost();
    return await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return load
                ? spinkit
                : Dialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    child: Container(
                        height: 150.0,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 30, left: 8, right: 8),
                                  child: Text(
                                    'The cost for the group booking will be \u{20B9} ${cost.round()}',
                                    style: GoogleFonts.workSans(
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              Spacer(),
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                                bottomLeft:
                                                    Radius.circular(5.0)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Center(
                                              child: Text(
                                                'CANCEL',
                                                style: GoogleFonts.workSans(
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        // onTap: () async {
                                        //   setState(() {
                                        //     load1 = true;
                                        //   });
                                        //   http.Response res= await AddClassService.addClass(orgId: admin.orgID,std: selectedStd);
                                        //   print(res.body);
                                        //   print(res.statusCode);
                                        //   if(res.statusCode==200){
                                        //     Fluttertoast.showToast(msg: "Class added successfully");
                                        //     Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context)=>AdminDashboard()), (route) => false);
                                        //   }else{
                                        //     Fluttertoast.showToast(msg: "Please try again");
                                        //     Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context)=>AdminDashboard()), (route) => false);
                                        //   }
                                        //
                                        // },
                                        onTap: () async {
                                          setState(() {
                                            load = true;
                                          });
                                          await addAllRidesToRequestPool();
                                          setState(() {
                                            load = true;
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.only(
                                                bottomRight:
                                                    Radius.circular(5.0)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Center(
                                              child: Text(
                                                'CONFIRM',
                                                style: GoogleFonts.workSans(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )),
                  );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Passenger Details',
          style: GoogleFonts.workSans(color: Colors.white, fontSize: 18),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.black,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              child: Icon(
                Icons.upload_file,
                color: Colors.white,
              ),
              onTap: () async {
                await getFile();
              },
            ),
          ),
          Center(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
                onTap: () async {
                  bool a = false;
                  for (int i = 0; i < widget.cabsCount; i++) {
                    if (_nameController[i].text == null ||
                        _nameController[i].text.trim().isEmpty) {
                      setState(() {
                        nameEmpty[i] = true;
                      });
                      a = true;
                    } else {
                      setState(() {
                        nameEmpty[i] = false;
                      });
                    }
                    if (_emailController[i].text == null ||
                        _emailController[i].text.trim().isEmpty) {
                      setState(() {
                        emailEmpty[i] = true;
                      });
                      a = true;
                    } else {
                      setState(() {
                        emailEmpty[i] = false;
                      });
                    }
                    if (_phoneController[i].text == null ||
                        _phoneController[i].text.trim().isEmpty) {
                      setState(() {
                        phoneEmpty[i] = true;
                      });
                      a = true;
                    } else {
                      setState(() {
                        phoneEmpty[i] = false;
                      });
                    }
                    if (_locationController[i].text == null ||
                        _locationController[i].text.trim().isEmpty) {
                      setState(() {
                        locEmpty[i] = true;
                      });
                      a = true;
                    } else {
                      setState(() {
                        locEmpty[i] = false;
                      });
                    }
                  }
                  if (_lController.text == null ||
                      _lController.text.trim().isEmpty) {
                    setState(() {
                      lEmpty = true;
                    });
                    a = true;
                  } else {
                    setState(() {
                      lEmpty = false;
                    });
                  }
                  if (_timeC.text == null || _timeC.text.trim().isEmpty) {
                    setState(() {
                      timeEmpty = true;
                    });
                    a = true;
                  } else {
                    setState(() {
                      timeEmpty = false;
                    });
                  }
                  if (a == false) {
                    await confirmationDialog(context);
                  }
                },
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                )),
          ))
        ],
      ),
      body: load
          ? spinkit
          : ListView(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int pos) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Cab ${pos + 1} primary passenger',
                                style: GoogleFonts.workSans(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              child: TextField(
                                controller: _nameController[pos],
                                style: GoogleFonts.workSans(
                                    color: Colors.black, fontSize: 14),
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Name",
                                    errorText: nameEmpty[pos]
                                        ? 'Please provide name'
                                        : null,
                                    focusColor: Colors.black,
                                    labelStyle:
                                        GoogleFonts.workSans(fontSize: 14),
                                    errorStyle: GoogleFonts.workSans(
                                        fontSize: 10, color: Colors.red)),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              child: TextField(
                                controller: _emailController[pos],
                                style: GoogleFonts.workSans(
                                    color: Colors.black, fontSize: 14),
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Email",
                                    errorText: emailEmpty[pos]
                                        ? 'Please provide email'
                                        : null,
                                    focusColor: Colors.black,
                                    labelStyle:
                                        GoogleFonts.workSans(fontSize: 14),
                                    errorStyle: GoogleFonts.workSans(
                                        fontSize: 10, color: Colors.red)),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              child: TextField(
                                controller: _phoneController[pos],
                                style: GoogleFonts.workSans(
                                    color: Colors.black, fontSize: 14),
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    errorText: phoneEmpty[pos]
                                        ? 'Please provide phone'
                                        : null,
                                    labelText: "Phone",
                                    focusColor: Colors.black,
                                    labelStyle:
                                        GoogleFonts.workSans(fontSize: 14),
                                    errorStyle: GoogleFonts.workSans(
                                        fontSize: 10, color: Colors.red)),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            // Padding(
                            //   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            //   child: Container(
                            //     child: DropdownButtonFormField(
                            //       value: selectedCab[pos],
                            //       onChanged: (val) {
                            //         setState(() {
                            //           selectedCab[pos] = val;
                            //         });
                            //       },
                            //       decoration: InputDecoration(
                            //         labelText: "Type",
                            //         labelStyle: GoogleFonts.workSans(fontSize: 14),
                            //       ),
                            //       style: GoogleFonts.workSans(
                            //           color: Colors.black, fontSize: 14),
                            //       items: [
                            //         DropdownMenuItem(
                            //           child: Text(
                            //             'Auto',
                            //             style: GoogleFonts.workSans(fontSize: 14),
                            //           ),
                            //           value: 'Auto',
                            //         ),
                            //         DropdownMenuItem(
                            //           child: Text(
                            //             'Go',
                            //             style: GoogleFonts.workSans(fontSize: 14),
                            //           ),
                            //           value: 'Go',
                            //         ),
                            //         DropdownMenuItem(
                            //           child: Text(
                            //             'Sedan',
                            //             style: GoogleFonts.workSans(fontSize: 14),
                            //           ),
                            //           value: 'Sedan',
                            //         ),
                            //         DropdownMenuItem(
                            //           child: Text(
                            //             'Premier',
                            //             style: GoogleFonts.workSans(fontSize: 14),
                            //           ),
                            //           value: 'Premier',
                            //         ),
                            //         DropdownMenuItem(
                            //           child: Text(
                            //             'XL',
                            //             style: GoogleFonts.workSans(fontSize: 14),
                            //           ),
                            //           value: 'XL',
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              child: TextField(
                                readOnly: true,
                                controller: _locationController[pos],
                                onTap: () async {
                                  // generate a new token here
                                  final sessionToken = Uuid().v4();
                                  final Suggestion result = await showSearch(
                                    context: context,
                                    delegate: AddressSearch(sessionToken),
                                  );
                                  // This will change the text displayed in the TextField
                                  if (result != null) {
                                    final placeDetails = await PlaceApiProvider(
                                            sessionToken)
                                        .getPlaceDetailFromId(result.placeId);
                                    setState(() {
                                      _locationController[pos].text =
                                          result.description;
                                    });
                                  }
                                },
                                style: GoogleFonts.workSans(
                                    color: Colors.black, fontSize: 14),
                                decoration: InputDecoration(
                                  errorText: locEmpty[pos]
                                      ? 'Please provide location'
                                      : null,
                                  errorStyle: GoogleFonts.workSans(
                                      fontSize: 10, color: Colors.red),
                                  border: OutlineInputBorder(),
                                  labelText: widget.originSame
                                      ? 'Destination Location'
                                      : 'Origin Location',
                                  focusColor: Colors.black,
                                  labelStyle:
                                      GoogleFonts.workSans(fontSize: 14),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  itemCount: widget.cabsCount,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: TextField(
                    readOnly: true,
                    controller: _lController,
                    onTap: () async {
                      // generate a new token here
                      final sessionToken = Uuid().v4();
                      final Suggestion result = await showSearch(
                        context: context,
                        delegate: AddressSearch(sessionToken),
                      );
                      // This will change the text displayed in the TextField
                      if (result != null) {
                        final placeDetails =
                            await PlaceApiProvider(sessionToken)
                                .getPlaceDetailFromId(result.placeId);
                        setState(() {
                          _lController.text = result.description;
                        });
                      }
                    },
                    style:
                        GoogleFonts.workSans(color: Colors.black, fontSize: 14),
                    decoration: InputDecoration(
                      errorStyle:
                          GoogleFonts.workSans(fontSize: 10, color: Colors.red),
                      errorText: lEmpty ? 'Please provide location' : null,
                      border: OutlineInputBorder(),
                      labelText: !widget.originSame
                          ? 'Destination Location'
                          : 'Origin Location',
                      focusColor: Colors.black,
                      labelStyle: GoogleFonts.workSans(fontSize: 14),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 18),
                  child: TextField(
                    controller: _timeC,
                    onTap: () {
                      DatePicker.showDateTimePicker(context,
                          minTime: DateTime.now(),
                          currentTime: DateTime.now(), onChanged: (date) {
                        setState(() {
                          _timeC.text =
                              DateFormat.yMMMMd('en_US').add_jm().format(date);
                          scheduleTime = date;
                        });
                      });
                    },
                    readOnly: true,
                    style:
                        GoogleFonts.workSans(color: Colors.black, fontSize: 14),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        errorText: timeEmpty ? 'Please provide time' : null,
                        labelText: "Scheduled Time",
                        focusColor: Colors.black,
                        labelStyle: GoogleFonts.workSans(fontSize: 14),
                        errorStyle: GoogleFonts.workSans(
                            fontSize: 10, color: Colors.red)),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
    );
  }
}
