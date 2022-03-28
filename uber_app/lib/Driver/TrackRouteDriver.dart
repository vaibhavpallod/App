import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:uber_hacktag_group_booking/konstants/Constansts.dart';

import '../Utils.dart';
import '../konstants/loaders.dart';

class TrackRouteDriver extends StatefulWidget {
  Map<dynamic, dynamic> request;
  List<String> mofKeys;
  int index;

  TrackRouteDriver(
    this.request,
    this.mofKeys,
    this.index,
  );

  @override
  _TrackRouteDriverState createState() => _TrackRouteDriverState();
}

class _TrackRouteDriverState extends State<TrackRouteDriver> {
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
  bool load = true;

  // Completer<GoogleMapController> _controller = Completer();
  PolylinePoints polylinePoints;
  GoogleMapController _controller;

// List of coordinates to join
  List<LatLng> polylineCoordinates = [];
  double _originLatitude = 18.395842, _originLongitude = 76.575635;
  double _destLatitude = 18.382658, _destLongitude = 76.559714;
  LatLng DEST_LOCATION, SOURCE_LOCATION;
  Map<PolylineId, Polyline> polylines = {};
  String googleAPIKey = "";
  Set<Marker> _markers = {};

  @override
  void initState() {
    print('page' + "TrackRoute Page");
    getLatLongfromRequestPool();
    super.initState();
  }

  Future<void> getLatLongfromRequestPool() async {
    var res = await http.get(Uri.parse("https://uber-hacktag76.herokuapp.com/getLoc/"),
        headers: {"id": widget.mofKeys[widget.index]});
    print("Trackroute: " +  res.body+'\n'+res.statusCode.toString());
    Map<String, dynamic> responseMap  = json.decode(res.body);

    // for now it's on driver side so driver location is source
    SOURCE_LOCATION = LatLng(responseMap["location"]["driverLatitude"], responseMap["location"]["driverLongitude"]);
    // DEST_LOCATION = LatLng(responseMap["location"]["sourceLatitude"], responseMap["location"]["sourceLongitude"]);
    DEST_LOCATION = LatLng(_destLatitude,_destLongitude);

    setSourceAndDestinationIcons();
    _createPolylines(SOURCE_LOCATION.latitude, SOURCE_LOCATION.longitude, DEST_LOCATION.latitude, DEST_LOCATION.longitude);

  }

  _createPolylines(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    polylinePoints = PolylinePoints();

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
      color: Colors.red,
      points: polylineCoordinates,
      width: 4,
    );

    // Adding the polyline to the map
    setState(() {
      polylines[id] = polyline;
      load=false;
    });
    // print("Trackroute: ");
    // print(polylines);
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
              // await storage.deleteAll(),
              Navigator.pop(context),
            },
            child: Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      body: load
          ? spinkit
          : GoogleMap(
              markers: _markers,
              polylines: Set<Polyline>.of(polylines.values),
              initialCameraPosition: CameraPosition(
                target: LatLng(SOURCE_LOCATION.latitude ?? 0.0,SOURCE_LOCATION.longitude ?? 0.0),
                zoom: 14.0,
              ),
              onMapCreated: (GoogleMapController controller) {
                controller.setMapStyle(Utils.mapStyles);
                _controller = controller;
              },
              // ...
            ),
    );
  }

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), "images/marker_d.png");
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), "images/marker_u.png");
    setMapPins();
  }

  void setMapPins() {
    setState(() {
      _markers.add(
          Marker(markerId: MarkerId("sourcePin"), position: SOURCE_LOCATION, icon: sourceIcon));
      // destination pin
      _markers.add(
          Marker(markerId: MarkerId("destPin"), position: DEST_LOCATION, icon: destinationIcon));
    });
  }
}
