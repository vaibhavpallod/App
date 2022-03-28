import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Utils.dart';
import '../konstants/Constansts.dart';
import '../konstants/loaders.dart';

class StatusIndividualScreen extends StatefulWidget {
  Map data;
  String id;

  StatusIndividualScreen({this.data, this.id});

  @override
  State<StatusIndividualScreen> createState() => _StatusIndividualScreenState();
}

class _StatusIndividualScreenState extends State<StatusIndividualScreen> {
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
  bool load = true;
  LatLng _northeastCoordinates;
  LatLng _southwestCoordinates;
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
    // TODO: implement initState
    super.initState();
    print(widget.id);
    getLatLongfromRequestPool();
  }

  Future<void> getLatLongfromRequestPool() async {
    var res = await http.get(
        Uri.parse("https://uber-hacktag76.herokuapp.com/getLoc/"),
        headers: {"id": widget.id});
    print("Trackroute: " + res.body + '\n' + res.statusCode.toString());
    Map<String, dynamic> responseMap = json.decode(res.body);

    SOURCE_LOCATION = LatLng(widget.data['driverLatitude'], widget.data['driverLongitude']);
    if(widget.data['status']=='Booked') {
      DEST_LOCATION = LatLng(widget.data['sourceLatitude'], widget.data['sourceLongitude']);
    }else{
      DEST_LOCATION = LatLng(widget.data['destinationLatitude'], widget.data['destinationLatitude']);
    }

    // SOURCE_LOCATION = LatLng(_originLatitude, _originLongitude);
    // DEST_LOCATION = LatLng(_destLatitude, _destLongitude);

// Calculating to check that
// southwest coordinate <= northeast coordinate
    if (SOURCE_LOCATION.latitude <= DEST_LOCATION.latitude) {
      _southwestCoordinates = SOURCE_LOCATION;
      _northeastCoordinates = DEST_LOCATION;
    } else {
      _southwestCoordinates = DEST_LOCATION;
      _northeastCoordinates = SOURCE_LOCATION;
    }
    setSourceAndDestinationIcons();
    _createPolylines(SOURCE_LOCATION.latitude, SOURCE_LOCATION.longitude,
        DEST_LOCATION.latitude, DEST_LOCATION.longitude);
  }

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), "images/sourcePin.png");
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), "images/destPin.png");
    setMapPins();
  }

  void setMapPins() {
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId("sourcePin"),
          position: SOURCE_LOCATION,
          icon: sourceIcon));
      // destination pin
      _markers.add(Marker(
          markerId: MarkerId("destPin"),
          position: DEST_LOCATION,
          icon: destinationIcon));
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          'Status',
          style: GoogleFonts.workSans(color: Colors.white),
        ),
      ),
      body: load
          ? spinkit
          : GoogleMap(
              minMaxZoomPreference: MinMaxZoomPreference(14, 17),
              markers: _markers,
              polylines: Set<Polyline>.of(polylines.values),
              initialCameraPosition: CameraPosition(
                  target: LatLng(SOURCE_LOCATION.latitude ?? 0.0,
                      SOURCE_LOCATION.longitude ?? 0.0),
                  zoom: 20.0,
                  bearing: 30),
              onMapCreated: (GoogleMapController controller) {
                controller.setMapStyle(Utils.mapStyles);
                _controller = controller;
                _controller.animateCamera(
                  CameraUpdate.newLatLngBounds(
                    LatLngBounds(
                      northeast: LatLng(
                        _northeastCoordinates.latitude,
                        _northeastCoordinates.longitude,
                      ),
                      southwest: LatLng(
                        _southwestCoordinates.latitude,
                        _southwestCoordinates.longitude,
                      ),
                    ),
                    100.0, // padding
                  ),
                );
              },
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              // ...
            ),
    );
  }
}
