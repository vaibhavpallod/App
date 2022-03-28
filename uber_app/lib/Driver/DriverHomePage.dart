import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:uber_hacktag_group_booking/Driver/Requests.dart';
import 'package:uber_hacktag_group_booking/konstants/loaders.dart';

import '../konstants/Constansts.dart';

class DriverHomePage extends StatefulWidget {
  @override
  _DriverHomePageState createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  Completer<GoogleMapController> _controller = Completer();
  Location currentLocation = Location();
  Set<Marker> _markers = {}, _currentMarker;
  bool load = true;
  LocationData location;

  var storage = FlutterSecureStorage();
  BitmapDescriptor mapMarker;
  bool _switchValue = true;
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  List<Map<dynamic, dynamic>> listOFRequests;
  List<String> listOFKeys;

  @override
  void initState() {
    // TODO: implement initState
    listOFRequests = List();
    listOFKeys = List();
    print('page' + "Drivepage");
    super.initState();
    // getRequests();
    getDriverLocation();
    // serCustomMarker();
  }

  void getRequests() {
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
                print("print: " +
                    (currentTime)
                        .toString()); // Validation for requests based on TIme, distance & Status
                print("print: " +
                    (distanceInMeters)
                        .toString()); // Validation for requests based on TIme, distance & Status
                if(element['status']=="Finding" && currentTime >= element['scheduleTime'] && distanceInMeters <=10000)
                listOFRequests.add(element as Map);
              }),
              print("print"+listOFRequests.toString()),
              tempMap.forEach((key, value) {
                if(!listOFRequests.contains(value)){
                  print("print"+key);
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

  void getDriverLocation() async {
    location = await currentLocation.getLocation();
    getRequests();
    // setState(() {
    //   load = false;
    // });
    currentLocation.onLocationChanged.listen((LocationData loc) {
      // _currentMarker = {};
      location = loc;
      // _markers.add(Marker(
      //     markerId: MarkerId('Home'),
      //     position: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0)));
      print(loc.latitude.toString() + "," + loc.longitude.toString());
      // print();
      // if (mounted)
      //   setState(() {
      //     load = false;
      //   });
    });
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
                      _controller.complete(controller);
                    },
                    zoomControlsEnabled: false,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(location.latitude ?? 0.0, location.longitude ?? 0.0),
                      zoom: 12.0,
                    ),
                    markers: _markers,
                  ),
                  Align(
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
                        ),
                        itemCount: listOFRequests.length,
                        itemBuilder: (context, itemIndex, realIndex) {
                          print('itemIndex' + itemIndex.toString());
                          return _requestCardUI(itemIndex);
                        },
                      ),
                    ),
                  )
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
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 10, 0, 0),
                child: Text(
                  "HackTag 2.0",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tempMap['passengerName'],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Column(
                  children: [
                    Text(tempMap['cost'].toString() + " ₹",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    Text(tempMap['distance'].toString() + " KM",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))
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
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                      TextField(
                        style: TextStyle(
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
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                      TextField(
                        enabled: false,
                        style: TextStyle(
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
                leading: Icon(
                  Icons.menu,
                  color: Colors.black,
                  size: 26,
                ),
                primary: false,
                centerTitle: true,
                title: Text(
                  "Driver",
                  style: TextStyle(color: Colors.black),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.all(Radius.circular(10.0)),
                ),
                actions: <Widget>[
                  Padding(
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
    // setState(() {
    //   _markers.add(Marker(
    //       icon: mapMarker,
    //       markerId: MarkerId('id-1'),
    //       position: LatLng(18.602464, 73.781616),
    //       infoWindow: InfoWindow(
    //         title: 'Rahatani',
    //       )));
    //   _markers.add(Marker(
    //       icon: mapMarker,
    //       markerId: MarkerId('id-2'),
    //       position: LatLng(18.590014, 73.747523),
    //       infoWindow: InfoWindow(
    //         title: 'Rahatani',
    //       )));
    //
    //   _markers.add(Marker(
    //       icon: mapMarker,
    //       markerId: MarkerId('id-3'),
    //       position: LatLng(18.644837, 73.769367),
    //       infoWindow: InfoWindow(
    //         title: 'Nigdi',
    //       )));
    //
    //   _markers.add(Marker(
    //       icon: mapMarker,
    //       markerId: MarkerId('id-4'),
    //       position: LatLng(18.638168, 73.791211),
    //       infoWindow: InfoWindow(
    //         title: 'Rahatani',
    //       )));
    //
    //   _markers.add(Marker(
    //       icon: mapMarker,
    //       markerId: MarkerId('id-5'),
    //       position: LatLng(18.636867, 73.768552),
    //       infoWindow: InfoWindow(
    //         title: 'Railway Station',
    //       )));
    //   // 18.644837, 73.769367
    // });
  }

  Future<void> _acceptRequest(Map<dynamic, dynamic> request, int index) async {
    Map<dynamic, dynamic> temprequest = request;

    DatabaseReference allUserreference =
        FirebaseDatabase.instance.ref().child('allusers').child(request['uid']).child('rides');

    String requestKey = listOFKeys[index];
    temprequest['status'] = 'Booked';
    temprequest['driverLatitude'] = location.latitude;
    temprequest['driverLongitude'] = location.longitude;
    var email = request['passengerEmail'];
    setState(() {
      load = true;
    });
    var res = await http.get(Uri.parse(
        "https://us-central1-uber-hacktag-group-booking.cloudfunctions.net/sendMail?dest=$email&uid=$requestKey"));
    print(res.body);
    databaseReference.child('requestPool').child(requestKey).set(temprequest).whenComplete(() => {
          allUserreference
              .child(temprequest['gloabalRequestID'])
              .child(requestKey)
              .set(temprequest)
              .whenComplete(() => {
                    setState(() {
                      load = false;
                      _showMessege("Accepted");
                    }),
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
