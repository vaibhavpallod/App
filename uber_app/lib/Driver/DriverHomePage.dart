import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:slider_button/slider_button.dart';
import 'package:uber_hacktag_group_booking/Driver/Requests.dart';
import 'package:uber_hacktag_group_booking/Utils/Functions.dart';
import 'package:uber_hacktag_group_booking/konstants/loaders.dart';

import '../Enter/login.dart';
import '../Utils.dart';
import '../konstants/Constansts.dart';

class DriverHomePage extends StatefulWidget {
  @override
  _DriverHomePageState createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
// bengaluru loc
// 12.970279,77.594972

  Completer<GoogleMapController> _controller = Completer();
  Location currentLocation = Location();
  Set<Marker> _markers = {}, _currentMarker;
  bool load = true;
  BitmapDescriptor sourceIcon, driverIcon = null;
  BitmapDescriptor destinationIcon;
  PolylinePoints polylinePoints;
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  LocationData location;
  String status = 'Finding';
  String finalCode;

  var storage = FlutterSecureStorage();
  BitmapDescriptor mapMarker;
  bool _switchValue = true;
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  List<Map<dynamic, dynamic>> listOFRequests;
  List<String> listOFKeys;
  LatLng DEST_LOCATION, SOURCE_LOCATION;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listOFRequests = List();
    listOFKeys = List();
    print('page' + "Drivepage");
    // setSourceAndDestinationIcons();
    getDriverLocation();
    // serCustomMarker();
  }

  getRequests() {
    final database = FirebaseDatabase.instance;
    Map<dynamic, dynamic> tempMap = Map();
    double dist;
    databaseReference
        .child('requestPool')
        .get()
        .then((value) => {
              print("Requests" + value.value.toString()),
              tempMap.addAll(value.value),
              tempMap.keys.forEach((element) {
                listOFKeys.add(element);
              }),

              tempMap.values.forEach((element) {
                print(element.toString());

                double destinationLatitude = element['sourceLatitude'];
                double destinationLongitude = element['sourceLongitude'];
                // double driverLat = element['driverLatitude'];
                // double driverLng = element['driverLongitude'];
                double distanceInMeters = Geolocator.distanceBetween(
                    location.latitude, location.longitude, destinationLatitude, destinationLongitude);
                // element['distance'] = distanceInMeters;
                // var dist = (distanceInMeters / 1000);
                var currentTime = DateTime.now().millisecondsSinceEpoch;
                // 1648732500000
                currentTime = 1648733280000;

                print("print: " +
                    (currentTime)
                        .toString()); // Validation for requests based on TIme, distance & Status
                print("print: " +
                    (distanceInMeters)
                        .toString()); // Validation for requests based on TIme, distance & Status


                // ***validation of time

                // ***currentTime >= element['scheduleTime'] &&

                if (element['status'] == "Finding" &&
                    distanceInMeters <= 10000) {
                  print('request added');
                  setState(() {
                    listOFRequests.add(element as Map);
                  });
                } else if (distanceInMeters > 10000) {
                  print('distance is more for ' + element['passengerName']);
                }
              }),
              print("print " + listOFRequests.toString()),
              tempMap.forEach((key, value) {
                if (!listOFRequests.contains(value)) {
                  print("print" + key);
                  listOFKeys.remove(key);
                }
              })

              // value.fo
            })
        .whenComplete(() => {
              listOFRequests.forEach((element) {
                print("Requests Map: " + element.toString());
              }),
              serCustomMarker(),
            });
  }

  Future<void> getLatLongfromRequestPool(String status) async {
    String uid = FirebaseAuth.instance.currentUser.uid;
    DatabaseReference driverRef = FirebaseDatabase.instance.ref().child('drivers').child(uid);
    DataSnapshot ds = await driverRef.child('activeRide').get();
    Map map = ds.value;
    print(map);
    var res = await http
        .get(Uri.parse("https://uber-hacktag76.herokuapp.com/getLoc/"), headers: {"id": map['id']});
    print("https://uber-hacktag76.herokuapp.com/getLoc/");
    print(map['id']);
    print(res.body);
    Map<String, dynamic> responseMap = json.decode(res.body)['location'];
    print(responseMap);
    // if()
    if (status == 'Booked') {
      DEST_LOCATION = LatLng(responseMap['sourceLatitude'], responseMap['sourceLongitude']);
      SOURCE_LOCATION = LatLng(responseMap['driverLatitude'], responseMap['driverLongitude']);
    } else {
      SOURCE_LOCATION = LatLng(responseMap['sourceLatitude'], responseMap['sourceLongitude']);
      DEST_LOCATION =
          LatLng(responseMap['destinationLatitude'], responseMap['destinationLongitude']);
    }
    print(SOURCE_LOCATION);
    print(DEST_LOCATION);
    // SOURCE_LOCATION = LatLng(_originLatitude, _originLongitude);
    // DEST_LOCATION = LatLng(_destLatitude, _destLongitude);

// Calculating to check that
// southwest coordinate <= northeast coordinate
//     if (SOURCE_LOCATION.latitude <= DEST_LOCATION.latitude) {
//       _southwestCoordinates = SOURCE_LOCATION;
//       _northeastCoordinates = DEST_LOCATION;
//     } else {
//       _southwestCoordinates = DEST_LOCATION;
//       _northeastCoordinates = SOURCE_LOCATION;
//     }
//     print(_southwestCoordinates);
//     print(_northeastCoordinates);
    setSourceAndDestinationIcons();
    _createPolylines(SOURCE_LOCATION.latitude, SOURCE_LOCATION.longitude, DEST_LOCATION.latitude,
        DEST_LOCATION.longitude);
  }

  _createPolylines(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    polylinePoints = PolylinePoints();
    polylineCoordinates = [];
    // Generating the list of coordinates to be used for
    // drawing the polylines
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      API_KEY, // Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.driving,
    );
    print("Trackroute:" +
        result.status +
        " " +
        result.points.toString() +
        " " +
        result.errorMessage.toString());
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    // Defining an ID
    PolylineId id = PolylineId('poly');

    // Initializing Polyline
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.black,
      points: polylineCoordinates,
      width: 5,
      jointType: JointType.mitered,
      endCap: Cap.squareCap,
      startCap: Cap.buttCap,
    );

    // Adding the polyline to the map
    setState(() {
      polylines[id] = polyline;
      load = false;
    });
    // print("Trackroute: ");
    // print(polylines);
  }

  changeStatus(String status) async {
    String uid = FirebaseAuth.instance.currentUser.uid;
    DatabaseReference driverRef = FirebaseDatabase.instance.ref().child('drivers').child(uid);
    DataSnapshot ds = await driverRef.child('activeRide').get();
    Map request = ds.value;
    String requestKey = request['id'];
    print(requestKey);
    print(request);
    Map<String, dynamic> temprequest = {'status': status};

    DatabaseReference allUserreference =
        FirebaseDatabase.instance.ref().child('allusers').child(request['uid']).child('rides');
    if (status == 'Riding') {
      int timeAdd = ((Geolocator.distanceBetween(
                      request['sourceLatitude'],
                      request['sourceLongitude'],
                      request['destinationLatitude'],
                      request['destinationLongitude']) /
                  1000) *
              1.5)
          .ceil();
      temprequest['eta'] = DateTime.now().add(Duration(minutes: timeAdd)).millisecondsSinceEpoch;
    }
    setState(() {
      load = true;
    });
    databaseReference
        .child('requestPool')
        .child(requestKey)
        .update(temprequest)
        .whenComplete(() => {
              allUserreference
                  .child(request['gloabalRequestID'])
                  .child(requestKey)
                  .update(temprequest)
                  .whenComplete(() => {
                        storage.write(key: 'status', value: status).whenComplete(() async {
                          if (status == 'Riding') {
                            await driverRef.child('activeRide').update(temprequest);
                          } else {
                            await driverRef.child('activeRide').remove();
                            await storage.delete(key: 'status');
                          }
                          await getDriverLocation();
                          _showMessege('Accepted');
                          setState(() {
                            load = false;
                          });
                        })
                      }),
            });
  }

  setSourceAndDestinationIcons() async {
    if (status == 'Booked') {
      sourceIcon = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(devicePixelRatio: 2.5), "images/marker_rider.png");
    } else {
      sourceIcon = driverIcon;
      // await BitmapDescriptor.fromAssetImage(
      //     ImageConfiguration(devicePixelRatio: 2.5,size: Size(100,100)), "images/marker_driver.png");

    }
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), "images/marker_dest.png");

    setMapPins();
  }

  void setMapPins() {
    _markers = {};
    setState(() {
      if (status == 'Booked') {
        _markers.add(
            Marker(markerId: MarkerId("sourcePin"), position: DEST_LOCATION, icon: sourceIcon));
        _markers.add(Marker(
            markerId: MarkerId("destPin"), position: SOURCE_LOCATION, icon: destinationIcon));
      } else {
        _markers.add(
            Marker(markerId: MarkerId("sourcePin"), position: SOURCE_LOCATION, icon: sourceIcon));
        _markers.add(
            Marker(markerId: MarkerId("destPin"), position: DEST_LOCATION, icon: destinationIcon));
      }
      // destination pin
    });
  }

  getDriverLocation() async {
    location = await currentLocation.getLocation();
    // 12.970279,77.594972
    // location.latitude=12.970279;
    // location.longitude = 77.594972;
    if (driverIcon == null)
      driverIcon = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(devicePixelRatio: 2.5), "images/marker_driver.png");
    String uid = FirebaseAuth.instance.currentUser.uid;
    DatabaseReference driverRef = FirebaseDatabase.instance.ref().child('drivers').child(uid);
    DatabaseReference dr = driverRef.child('activeRide');
    DataSnapshot ds = await dr.get();

    bool statusPresent = ds.exists;
    print('statusPresent'+statusPresent.toString());
    if (!statusPresent)
      await getRequests();
    else {
      Map map = ds.value;
      status = map['status'];
      print(status);
      await getLatLongfromRequestPool(status);
      print('hello');
      setState(() {
        load = false;
      });
    }
    // setState(() {
    //   load = false;
    // });
    currentLocation.onLocationChanged.listen((LocationData loc) {
      // _currentMarker = {};

      location = loc;
      //12.970279, 77.594972
      _markers.add(Marker(
          icon: driverIcon,
          markerId: MarkerId('Home'),
          position: LatLng(location.latitude ?? 0.0, location.longitude ?? 0.0)));
      print(loc.latitude.toString() + "," + loc.longitude.toString());
      // print();
      // if (mounted)
      //   setState(() {
      //     load = false;
      //   });
    });
  }

  Future<bool> checkOTP() async {
    String uid = FirebaseAuth.instance.currentUser.uid;
    DatabaseReference driverRef = FirebaseDatabase.instance.ref().child('drivers').child(uid);
    DataSnapshot ds = await driverRef.child('activeRide').get();
    Map map = ds.value;
    print(map['otp']);
    return map['otp'] == int.parse(finalCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _appBar(AppBar().preferredSize.height),
      body: load
          ? spinkit
          : Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      controller.setMapStyle(Utils.mapStyles);
                      _controller.complete(controller);
                    },
                    polylines: status == 'Booked' || status == 'Riding'
                        ? Set<Polyline>.of(polylines.values)
                        : {},
                    zoomControlsEnabled: false,
                    initialCameraPosition: status == 'Finding'
                        ? CameraPosition(
                            target: LatLng(location.latitude ?? 0.0, location.longitude ?? 0.0),
                            zoom: 12.0,
                          )
                        : CameraPosition(
                            target: LatLng(
                                SOURCE_LOCATION.latitude ?? 0.0, SOURCE_LOCATION.longitude ?? 0.0),
                            zoom: 14.0,
                            bearing: 30),
                    markers: _markers,
                  ),
                  status == 'Finding'
                      ? Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
                            child: CarouselSlider.builder(
                              options: CarouselOptions(
                                  height: 350,
                                  enlargeCenterPage: true,
                                  // height: 100.0,
                                  initialPage: 0,
                                  viewportFraction: 0.8,
                                  autoPlay: false,
                                  enableInfiniteScroll: false),
                              itemCount: listOFRequests.length,
                              itemBuilder: (context, itemIndex, realIndex) {
                                print('itemIndex' + itemIndex.toString());
                                return _requestCardUI(itemIndex);
                              },
                            ),
                          ),
                        )
                      : status != 'Riding'
                          ? Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                child: Material(
                                  elevation: 15,
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey, width: 1),
                                      gradient: LinearGradient(
                                          colors: [Color(0x99000000), Color(0xFF000000)]),
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                    ),
                                    height: 180,
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          child: Center(
                                            child: Text(
                                              'Enter OTP',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.workSans(
                                                  color: Colors.white, fontSize: 18),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Container(
                                          child: OtpTextField(
                                            textStyle: GoogleFonts.workSans(
                                                fontSize: 15, color: Colors.white),
                                            numberOfFields: 4,
                                            borderColor: Colors.grey,
                                            focusedBorderColor: Colors.grey,
                                            cursorColor: Colors.white,
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
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: SliderButton(
                                              action: () async {
                                                if (finalCode == null || finalCode.length < 4) {
                                                  Fluttertoast.showToast(msg: 'Enter correct OTP');
                                                } else {
                                                  setState(() {
                                                    load = true;
                                                  });
                                                  bool otpCorrect = await checkOTP();
                                                  if (otpCorrect) {
                                                    await changeStatus('Riding');
                                                  } else {
                                                    _showMessege('Please enter correct OTP');
                                                    setState(() {
                                                      load = false;
                                                    });
                                                  }
                                                }
                                              },
                                              icon: Center(
                                                child: Icon(
                                                  Icons.local_taxi,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              label: Text(
                                                "Slide to Start",
                                                style: GoogleFonts.workSans(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                child: Material(
                                  color: Colors.black,
                                  elevation: 15,
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SliderButton(
                                      action: () async {
                                        await changeStatus('Completed');
                                      },
                                      icon: Center(
                                        child: Icon(
                                          Icons.local_taxi,
                                          color: Colors.black,
                                        ),
                                      ),
                                      label: Text(
                                        "Slide to Complete",
                                        style: GoogleFonts.workSans(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                ],
              ),
            ),
    );
  }

  _requestCardUI(int itemIndex) {
    Map<dynamic, dynamic> tempMap = listOFRequests[itemIndex];
    _goToTheLake(listOFRequests[(itemIndex - 1) % listOFRequests.length]);
    return Container(
      height: 350,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tempMap['passengerName'],
                    style: GoogleFonts.workSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
                Column(
                  children: [
                    Text(tempMap['cost'].toString() + " ₹",
                        style: GoogleFonts.workSans(fontSize: 15, fontWeight: FontWeight.bold)),
                    Text(tempMap['distance'].toString() + " KM",
                        style: GoogleFonts.workSans(fontSize: 15, fontWeight: FontWeight.bold))
                  ],
                )
              ],
            ),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  "images/pickdrop.png",
                  height: 150,
                  width: 30,
                  fit: BoxFit.fitHeight,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(5.0, 0.0, 20.0, 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Pickup Point",
                          style: GoogleFonts.workSans(
                              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                      TextField(
                        style: GoogleFonts.workSans(
                            fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black87),
                        enabled: false,
                        decoration: InputDecoration(
                          hintText: tempMap['source'],
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          // focusedBorder: UnderlineInputBorder(
                          //   borderSide: BorderSide(color: Colors.green),
                          // ),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Text("Dropping Point",
                          style: GoogleFonts.workSans(
                              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                      TextField(
                        enabled: false,
                        style: GoogleFonts.workSans(
                            fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: tempMap['destination'],
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          // focusedBorder: UnderlineInputBorder(
                          //   borderSide: BorderSide(color: Colors.green),
                          // ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                RoundedButton(
                  color: Colors.white,
                  textColor: Colors.black,
                  text: "Decline",
                  press: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => Requests(
                                location: location,
                              )),
                    );
                  },
                ),
                RoundedButton(
                  text: "Accept",
                  color: Colors.black,
                  textColor: Colors.white,
                  press: () {
                    _acceptRequest(tempMap, itemIndex);
                  },
                )
              ],
            ),
          ),
        ],
      ),
      // ),
    );
  }

  _appBar(height) => PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, height + 80),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 60.0,
              left: 20.0,
              right: 20.0,
              child: AppBar(
                backgroundColor: Colors.white,
                leading: InkWell(
                  child: Icon(
                    Icons.menu,
                    color: Colors.black,
                    size: 26,
                  ),
                  onTap: () async {
                    await storage.deleteAll();
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (BuildContext context) => Login()),
                        (route) => false);
                  },
                ),
                primary: false,
                centerTitle: true,
                title: Text(
                  "Driver",
                  style: GoogleFonts.workSans(color: Colors.black),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.all(Radius.circular(10.0)),
                ),
                actions: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: FlutterSwitch(
                        height: 30.0,
                        width: 45.0,
                        // padding: 4.0,
                        toggleSize: 20.0,
                        borderRadius: 20.0,
                        activeColor: Colors.black87,
                        value: _switchValue,
                        onToggle: (value) {
                          setState(() {
                            _switchValue = value;
                          });
                        },
                      ),
                    ),
                    // IconButton(
                    //   icon: Icon(Icons.exit_to_app),
                    //   color: Colors.black,
                    //   onPressed: () async {
                    //     await storage.deleteAll();
                    //     Navigator.pushAndRemoveUntil(
                    //         context,
                    //         MaterialPageRoute(builder: (BuildContext context) => Login()),
                    //         (route) => false);
                    //   },
                    // ),
                  ),
                ],
              ),
            )
          ],
        ),
      );

  Future<void> serCustomMarker() async {
    mapMarker = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5, size: Size.fromHeight(12)),
        'images/markerIcon.png');
    int index = 0;
    listOFRequests.forEach((element) {
      _markers.add(Marker(
          icon: mapMarker,
          markerId: MarkerId(listOFKeys[index]),
          position: LatLng(element['sourceLatitude'], element['sourceLongitude']),
          infoWindow: InfoWindow(
            title: 'Hiii Uber',
          )));
    });
    setState(() {
      load = false;
    });
  }

  int generateOTP() {
    var rng = new Random();
    var rand = rng.nextInt(9000) + 1000;
    return (rand.toInt());
  }

  Future<void> _acceptRequest(Map<dynamic, dynamic> request, int index) async {
    Map<dynamic, dynamic> temprequest = request;

    DatabaseReference allUserreference =
        FirebaseDatabase.instance.ref().child('allusers').child(request['uid']).child('rides');
    String uid = FirebaseAuth.instance.currentUser.uid;
    DatabaseReference driverRef = FirebaseDatabase.instance.ref().child('drivers').child(uid);

    String requestKey = listOFKeys[index];
    temprequest['status'] = 'Booked';
    temprequest['driverLatitude'] = location.latitude;
    temprequest['driverLongitude'] = location.longitude;
    int otp = generateOTP();
    temprequest['otp'] = otp;
    var email = request['passengerEmail'];
    Branch_Functions branch_functions = new Branch_Functions();
    BranchResponse response = await branch_functions.generateDeepLink(temprequest['uid'],
        request['passengerEmail'], temprequest['cost'].toString(), requestKey);
    print('branchresponse' + response.result.toString() + "set driver loc " + location.latitude.toString());
    String link = response.result;
    setState(() {
      load = true;
    });

    int timeAdd = ((Geolocator.distanceBetween(location.latitude, location.longitude, temprequest['sourceLatitude'],
                    temprequest['sourceLongitude']) /
                1000) *
            1.5)
        .ceil();
    temprequest['eta'] = DateTime.now().add(Duration(minutes: timeAdd)).millisecondsSinceEpoch;
    databaseReference.child('requestPool').child(requestKey).set(temprequest).whenComplete(() => {
          allUserreference
              .child(temprequest['gloabalRequestID'])
              .child(requestKey)
              .set(temprequest)
              .whenComplete(() => {
                    temprequest['id'] = requestKey,
                    driverRef.child('activeRide').set(temprequest).whenComplete(() async {
                      var res = await http.get(Uri.parse(
                          "https://us-central1-uber-hacktag-group-booking.cloudfunctions.net/sendMail?dest=$email&uid=$requestKey&otp=$link"));
                      print(res.body);
                      await getDriverLocation();
                      setState(() {
                        load = false;
                      });
                    })
                  }),
        });
  }

  _showMessege(String msg) {
    Fluttertoast.showToast(msg: msg);
  }

  Future<void> _goToTheLake(Map<dynamic, dynamic> tempMap) async {
    CameraPosition _kLake = CameraPosition(
        // bearing: 192.8334901395799,
        target: LatLng(tempMap['sourceLatitude'], tempMap['sourceLongitude']),
        // tilt: 59.440717697143555,
        zoom: 12);
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}
