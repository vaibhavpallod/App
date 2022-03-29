import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../Utils.dart';
import '../konstants/Constansts.dart';
import '../konstants/loaders.dart';

class ShowNormalUserMap extends StatefulWidget {
  const ShowNormalUserMap({Key key}) : super(key: key);

  @override
  _ShowNormalUserMapState createState() => _ShowNormalUserMapState();
}

class _ShowNormalUserMapState extends State<ShowNormalUserMap> {
  final storage = FlutterSecureStorage();
  BitmapDescriptor sourceIcon, destinationIcon, driverIcon;
  PolylinePoints polylinePoints;
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};

  MethodChannel platform = MethodChannel('Sample/test');
  Map<dynamic, dynamic> responseMap;
  Map<PolylineId, Polyline> polylines = {};
  LatLng DEST_LOCATION, SOURCE_LOCATION, DRIVER_LOCATION;
  String id;
  bool load = true;
  List<LatLng> polylineCoordinates = [];
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child('requestPool');

  @override
  void initState() {
    // TODO: implement initState
    print('page' + "NormalUserpage");

    super.initState();
    _getDataFromAdnroid();
    getLocation();
  }

  void getLocation() async {
    var pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5, size: Size.fromHeight(12)), 'images/pin.png');

    // addMarker(location, pinLocationIcon);
  }

  Future<void> _getDataFromAdnroid() async {
    print("calling for data");

    String data;
    try {
      final String result =
          await platform.invokeMethod('test', {"data": ""}); //sending data from flutter here
      data = result;
      var idx = data.lastIndexOf('https://uber-hack12.herokuapp.com/');
      var rideId = data.substring(34);
      print(idx.toString() + " ID from SHOWMAP printing DART " + rideId);
      print("from SHOWMAP printing DART" + data);
      id = rideId;
    } on PlatformException catch (e) {
      data = "Android is not responding please check the code";
      print("from SHOWMAP printing DART" + data);
    }
    getLatLongfromRequestPool();
    // setState(() {
    //   load=false;
    // });
  }

  Future<void> getLatLongfromRequestPool() async {
    // var res = await http
    //     .get(Uri.parse("https://uber-hacktag76.herokuapp.com/getLoc/"), headers: {"id": id});
    // print("Trackroute: " + res.body + '\n' + res.statusCode.toString());
    // responseMap = json.decode(res.body);

    databaseReference
        .child(id)
        .get()
        .then((value) => {
              responseMap = value.value,
            })
        .whenComplete(() => {
              print(responseMap.toString()),
              DRIVER_LOCATION =
                  LatLng(responseMap["driverLatitude"], responseMap["driverLongitude"]),
              SOURCE_LOCATION =
                  LatLng(responseMap["sourceLatitude"], responseMap["sourceLongitude"]),
              // DEST_LOCATION = LatLng(_destLatitude,_destLongitude);

              setSourceAndDestinationIcons(),
              _createPolylines(SOURCE_LOCATION.latitude, SOURCE_LOCATION.longitude,
                  DRIVER_LOCATION.latitude, DRIVER_LOCATION.longitude),
            });

    // for now it's on driver side so driver location is source
    // DRIVER_LOCATION = LatLng(
    //     responseMap["location"]["driverLatitude"], responseMap["location"]["driverLongitude"]);
    // SOURCE_LOCATION = LatLng(
    //     responseMap["location"]["sourceLatitude"], responseMap["location"]["sourceLongitude"]);
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

    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.black,
      points: polylineCoordinates,
      width: 4,
      jointType: JointType.mitered,
      endCap: Cap.squareCap,
      startCap: Cap.buttCap,
    );
    // Polyline polyline = Polyline(
    //   polylineId: id,
    //   color: Colors.red,
    //   points: polylineCoordinates,
    //   width: 4,
    // );

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
    return load
        ? spinkit
        : SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                GoogleMap(
                  polylines: Set<Polyline>.of(polylines.values),
                  initialCameraPosition: CameraPosition(
                    target:
                        LatLng(SOURCE_LOCATION.latitude ?? 0.0, SOURCE_LOCATION.longitude ?? 0.0),
                    zoom: 13.0,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    controller.setMapStyle(Utils.mapStyles);
                    _controller.complete(controller);
                  },
                  markers: _markers,
                ),
/*
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Material(
                      elevation: 15,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1),
                          gradient: LinearGradient(colors: [Color(0x99000000), Color(0xFF000000)]),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                        child: Text("data"),
                      ),
                    ),
                  ),
                )
*/
              ],
            ),
          );
  }

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), "images/marker_u.png");
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), "images/marker_dest.png");
    driverIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), "images/marker_d.png");
    setMapPins();
  }

  void setMapPins() {
    setState(() {
      _markers.add(
          Marker(markerId: MarkerId("sourcePin"), position: SOURCE_LOCATION, icon: sourceIcon));
      // destination pin
      _markers
          .add(Marker(markerId: MarkerId("driverPin"), position: DRIVER_LOCATION, icon: driverIcon));
    });
  }
}
