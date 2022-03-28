import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:uber_hacktag_group_booking/Driver/Requests.dart';
import 'package:uber_hacktag_group_booking/konstants/loaders.dart';

class DriverHomePage extends StatefulWidget {
  @override
  _DriverHomePageState createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  GoogleMapController _controller;
  Location currentLocation = Location();
  Set<Marker> _markers = {}, _currentMarker;
  int noc = 2;
  bool load = true;
  LocationData location;
  bool originSame = true;
  bool whichSame = true;
  var storage = FlutterSecureStorage();
  BitmapDescriptor mapMarker;
  bool _switchValue = true;

  @override
  void initState() {
    // TODO: implement initState

    print('page' + "Drivepage");
    super.initState();
    serCustomMarker();
    getLocation();
  }

  void _onMapCreated(GoogleMapController controller) {
    // 18.602464, 73.781616
    // 18.590014, 73.747523

    // 18.636867, 73.768552
  }

  void getLocation() async {
    location = await currentLocation.getLocation();
    setState(() {
      load = false;
    });
    currentLocation.onLocationChanged.listen((LocationData loc) {
      // _currentMarker = {};

      // _markers.add(Marker(
      //     markerId: MarkerId('Home'),
      //     position: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0)));
      print(loc.latitude.toString() + "," + loc.longitude.toString());
      // print();
      if (mounted)
        setState(() {
          load = false;
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _appBar(AppBar().preferredSize.height),
      // AppBar(
      //   leading: Padding(
      //     // --> Custom Back Button
      //     padding: const EdgeInsets.all(8.0),
      //     child: FloatingActionButton(
      //       backgroundColor: Colors.white,
      //       mini: true,
      //       onPressed: () async => {
      //         await storage.deleteAll(),
      //         Navigator.pushAndRemoveUntil(
      //             context,
      //             MaterialPageRoute(
      //               builder: (BuildContext context) => Login(),
      //             ),
      //             (route) => false)
      //       },
      //       child: Icon(Icons.arrow_back, color: Colors.black),
      //     ),
      //   ),
      //   backgroundColor: Colors.transparent,
      //   shadowColor: Colors.transparent,
      // ),
      body: load
          ? spinkit
          : Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  GoogleMap(
                    zoomControlsEnabled: false,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(location.latitude ?? 0.0, location.longitude ?? 0.0),
                      zoom: 12.0,
                    ),
                    onMapCreated: _onMapCreated,
                    markers: _markers,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                      child: _requestCardUI(),
                      // Material(
                      //   // color: Colors.white,
                      //   elevation: 15,
                      //   borderRadius: BorderRadius.all(Radius.circular(10)),
                      //   child: Container(
                      //     decoration: BoxDecoration(
                      //       border: Border.all(color: Colors.grey, width: 1),
                      //       gradient:
                      //           LinearGradient(colors: [Color(0x99000000), Color(0xFF000000)]),
                      //       borderRadius: BorderRadius.all(Radius.circular(20)),
                      //     ),
                      //     height: 120,
                      //     width: MediaQuery.of(context).size.width,
                      //     child: Column(
                      //       children: [
                      //         Padding(
                      //           padding: const EdgeInsets.all(12.0),
                      //           child: Text(
                      //             'Requests',
                      //             style: GoogleFonts.workSans(color: Colors.white, fontSize: 18),
                      //           ),
                      //         ),
                      //         SizedBox(
                      //           height: 5,
                      //         ),
                      //         // Expanded(
                      //         //   child: Container(
                      //         //     decoration: BoxDecoration(
                      //         //       gradient: LinearGradient(
                      //         //         begin: Alignment.topCenter,
                      //         //         end: Alignment.bottomCenter,
                      //         //         stops: [
                      //         //           0,0.5,1
                      //         //         ],
                      //         //         colors: [
                      //         //           Colors.redAccent.shade100,
                      //         //           Colors.redAccent,
                      //         //           Colors.redAccent.shade100,
                      //         //         ]
                      //         //       )
                      //         //     ),
                      //         //   ),
                      //         // )
                      //         SizedBox(
                      //           height: 5,
                      //         ),
                      //         Expanded(
                      //           child: Padding(
                      //             padding: const EdgeInsets.all(8.0),
                      //             child: SliderButton(
                      //               action: () {
                      //                 Navigator.push(
                      //                     context,
                      //                     MaterialPageRoute(
                      //                         builder: (BuildContext context) =>
                      //                             Requests(location: location)));
                      //               },
                      //               icon: Center(
                      //                 child: Icon(
                      //                   Icons.local_taxi,
                      //                   color: Colors.black,
                      //                 ),
                      //               ),
                      //               label: Text(
                      //                 "Slide to Get Requests",
                      //                 style: GoogleFonts.workSans(
                      //                     color: Colors.white,
                      //                     fontSize: 14,
                      //                     fontWeight: FontWeight.w400),
                      //               ),
                      //             ),
                      //           ),
                      //         )
                      //       ],
                      //     ),
                      //   ),
                      // ),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  _requestCardUI() {
    return Container(
      height: 350,
      decoration: BoxDecoration(
        // color: Colors.grey.shade200,
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
                Text("Vaibhav Pallod", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Column(
                  children: [
                    Text("105 ₹", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    Text("16 KM", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))
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
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold
                        ),
                        decoration: InputDecoration(
                          hintText: 'Nayantara Hills, Nashik, Maharashtra',
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
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold
                        ),
                        decoration: InputDecoration(

                          hintText: 'New CBS bus stop, Thakkar Bazar,Nashik',
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => Requests(
                                location: location,
                              )),
                    );
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

    setState(() {
      _markers.add(Marker(
          icon: mapMarker,
          markerId: MarkerId('id-1'),
          position: LatLng(18.602464, 73.781616),
          infoWindow: InfoWindow(
            title: 'Rahatani',
          )));
      _markers.add(Marker(
          icon: mapMarker,
          markerId: MarkerId('id-2'),
          position: LatLng(18.590014, 73.747523),
          infoWindow: InfoWindow(
            title: 'Rahatani',
          )));

      _markers.add(Marker(
          icon: mapMarker,
          markerId: MarkerId('id-3'),
          position: LatLng(18.644837, 73.769367),
          infoWindow: InfoWindow(
            title: 'Nigdi',
          )));

      _markers.add(Marker(
          icon: mapMarker,
          markerId: MarkerId('id-4'),
          position: LatLng(18.638168, 73.791211),
          infoWindow: InfoWindow(
            title: 'Rahatani',
          )));

      _markers.add(Marker(
          icon: mapMarker,
          markerId: MarkerId('id-5'),
          position: LatLng(18.636867, 73.768552),
          infoWindow: InfoWindow(
            title: 'Railway Station',
          )));
      // 18.644837, 73.769367
    });
  }
}

class RoundedButton extends StatelessWidget {
  final String text;
  final Function press;
  final Color color, textColor;

  const RoundedButton({
    Key key,
    this.text,
    this.press,
    this.color = Colors.lightBlueAccent,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          border: Border.all(color: Colors.grey.shade800)),
      height: 50,
      margin: EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: FlatButton(
          // padding: EdgeInsets.symmetric(vertical: 20, horizontal:20),
          color: color,
          onPressed: press,
          child: Text(
            text,
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }
}
