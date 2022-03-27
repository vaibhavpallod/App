import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:slider_button/slider_button.dart';
import 'package:uber_hacktag_group_booking/Driver/Requests.dart';
import 'package:uber_hacktag_group_booking/Enter/login.dart';
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
    currentLocation.onLocationChanged.listen((LocationData loc) {
      // _currentMarker = {};

      _markers.add(Marker(
          markerId: MarkerId('Home'),
          position: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0)));
      print(loc.latitude);
      print(loc.longitude);
      if(mounted)
      setState(() {
        load = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Padding(
          // --> Custom Back Button
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            mini: true,
            onPressed: () async => {
              await storage.deleteAll(),
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => Login(),
                  ),
                  (route) => false)
            },
            child: Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
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
                      target: LatLng(
                          location.latitude ?? 0.0, location.longitude ?? 0.0),
                      zoom: 12.0,
                    ),
                    onMapCreated: _onMapCreated,
                    markers: _markers,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: Material(
                        // color: Colors.white,
                        elevation: 15,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1),
                            gradient: LinearGradient(
                                colors: [Color(0x99000000), Color(0xFF000000)]),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          height: 120,
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  'Requests',
                                  style: GoogleFonts.workSans(
                                      color: Colors.white, fontSize: 18),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              // Expanded(
                              //   child: Container(
                              //     decoration: BoxDecoration(
                              //       gradient: LinearGradient(
                              //         begin: Alignment.topCenter,
                              //         end: Alignment.bottomCenter,
                              //         stops: [
                              //           0,0.5,1
                              //         ],
                              //         colors: [
                              //           Colors.redAccent.shade100,
                              //           Colors.redAccent,
                              //           Colors.redAccent.shade100,
                              //         ]
                              //       )
                              //     ),
                              //   ),
                              // )
                              SizedBox(
                                height: 5,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SliderButton(
                                    action: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  Requests(
                                                      location: location)));
                                    },
                                    icon: Center(
                                      child: Icon(
                                        Icons.local_taxi,
                                        color: Colors.black,
                                      ),
                                    ),
                                    label: Text(
                                      "Slide to Get Requests",
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
                ],
              ),
            ),
    );
  }

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
