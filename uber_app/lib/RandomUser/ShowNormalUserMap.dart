import 'dart:async';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

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
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};

  MethodChannel platform = MethodChannel('Sample/test');
  Map<dynamic, dynamic> responseMap;
  Map<PolylineId, Polyline> polylines = {};
  LatLng DEST_LOCATION, SOURCE_LOCATION, DRIVER_LOCATION;
  String id = "";
  bool load = true;
  List<LatLng> polylineCoordinates = [];
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child('requestPool');

  List<String> notKey = [
    'dateTime',
    'destination',
    'dateTime',
    'destinationLatitude',
    'destinationLongitude',
    'numberOfCabs',
    'source',
    'sourceLatitude',
    'sourceLongitude'
  ];
  Map data;
  List<String> ids;
  List<String> status = ['Finding', 'Booked', 'Riding', 'Completed'];

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
    setLisner();
    // addMarker(location, pinLocationIcon);
  }

  setLisner() {
    databaseReference.child(id).onChildChanged.listen((event) {
      print("from SHOWMAP printing DART " +
          event.snapshot.key +
          " " +
          event.snapshot.value.toString());

      if (event.snapshot.key == 'status') {
        setState(() {
          load = true;
          polylines = {};
          polylineCoordinates=[];
        });
        responseMap['status'] = event.snapshot.value.toString();
        if (responseMap['status'] == 'Riding') {
          setSourceAndDestinationIcons();

          _createPolylines(SOURCE_LOCATION.latitude, SOURCE_LOCATION.longitude,
              DEST_LOCATION.latitude, DEST_LOCATION.longitude);
        } else if (responseMap['status'] == 'Booked') {
          setSourceAndDestinationIcons();
          _createPolylines(SOURCE_LOCATION.latitude, SOURCE_LOCATION.longitude,
              DRIVER_LOCATION.latitude, DRIVER_LOCATION.longitude);
        }
      }
    });
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
      // id="a0926880-aea1-11ec-984c-4545ffd26017";
    } on PlatformException catch (e) {
      data = "Android is not responding please check the code";
      print("from SHOWMAP printing DART" + data);
    }
    await getLatLongfromRequestPool();
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
              DEST_LOCATION =
                  LatLng(responseMap["destinationLatitude"], responseMap["destinationLongitude"]),
               setSourceAndDestinationIcons(),
      if(responseMap['status']=='Booked'){
        _createPolylines(DRIVER_LOCATION.latitude, DRIVER_LOCATION.longitude,
            SOURCE_LOCATION.latitude, SOURCE_LOCATION.longitude),
      }else{
        _createPolylines(SOURCE_LOCATION.latitude, SOURCE_LOCATION.longitude,
            DEST_LOCATION.latitude, DEST_LOCATION.longitude),
      }
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
    PolylinePoints polylinePoints=new PolylinePoints();

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
    PolylineId id = PolylineId('poly' + Random().nextInt(1000).toString());

    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.black,
      points: polylineCoordinates,
      width: 4,
      // jointType: JointType.mitered,
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
    polylines.clear();
    setState(() {
      polylines[id] = polyline;
      load = false;
    });
    // print("Trackroute: ");
    // print(polylines);
  }

  @override
  Widget build(BuildContext context) {
    if(load==true) {
      polylines = {};
    }

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
                        height: 150,
                        width: MediaQuery.of(context).size.width,
                        child: _showTripDetails(),
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
  }

  void setSourceAndDestinationIcons() async {
    // sourceIcon = await BitmapDescriptor.fromAssetImage(
    //     ImageConfiguration(devicePixelRatio: 2.5), "images/marker_u.png");
    // destinationIcon = await BitmapDescriptor.fromAssetImage(
    //     ImageConfiguration(devicePixelRatio: 2.5), "images/marker_dest.png");
    // driverIcon = await BitmapDescriptor.fromAssetImage(
    //     ImageConfiguration(devicePixelRatio: 2.5), "images/marker_d.png");
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), "images/marker_rider.png");
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), "images/marker_dest.png");
    driverIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), "images/marker_driver.png");
    setMapPins();
  }

  void setMapPins() {
    _markers = {};
    setState(() {
      if(responseMap['status']=='Booked'){
        _markers.add(
            Marker(markerId: MarkerId("sourcePin"), position: DRIVER_LOCATION, icon: driverIcon));
        _markers.add(
            Marker(markerId: MarkerId("destPin"), position: SOURCE_LOCATION, icon: sourceIcon));
      }else{
        _markers.add(
            Marker(markerId: MarkerId("sourcePin"), position: SOURCE_LOCATION, icon: sourceIcon));
        _markers.add(
            Marker(markerId: MarkerId("destPin"), position: DEST_LOCATION, icon: destinationIcon));
      }

      // destination pin
    });
  }

  _showTripDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Container(
          //   child: OtpTextField(
          //     readOnly: true,
          //     textStyle: GoogleFonts.workSans(fontSize: 15, color: Colors.white),
          //     numberOfFields: 4,
          //     borderColor: Colors.grey,
          //     focusedBorderColor: Colors.grey,
          //     cursorColor: Colors.white,
          //     showFieldAsBox: true,
          //     fieldWidth: MediaQuery.of(context).size.width / 12,
          //     borderWidth: 1.0,
          //
          //   ),
          // ),

          responseMap['status'] == "Booked"
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Text(
                        "OTP",
                        style: GoogleFonts.workSans(
                            fontSize: 20, color: Colors.white),
                      ),
                    ),
                    Container(
                      child: Text(
                        responseMap['otp'].toString(),
                        style: GoogleFonts.workSans(
                            fontSize: 20, color: Colors.white),
                      ),
                    ),
                    // Container(
                    //   height: 50,
                    //   child: ListView.builder(
                    //     itemBuilder: (BuildContext context, int pos) {
                    //       return Padding(
                    //         padding: const EdgeInsets.all(8.0),
                    //         child: Container(
                    //           height: 40,
                    //           width: 40,
                    //           decoration: BoxDecoration(
                    //               borderRadius: BorderRadius.circular(10.0),
                    //               border: Border.all(color: Colors.grey)),
                    //           child: Center(
                    //               child: Text(
                    //             responseMap['otp'].toString().characters.elementAt(pos),
                    //             style: GoogleFonts.workSans(
                    //                 fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
                    //           )),
                    //         ),
                    //       );
                    //     },
                    //     scrollDirection: Axis.horizontal,
                    //     // physics: NeverScrollableScrollPhysics(),
                    //     shrinkWrap: true,
                    //     itemCount: 4,
                    //   ),
                    // ),
                  ],
                )
              : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Text(
                  "Amount to be paid",
                  style: GoogleFonts.workSans(fontSize: 17, color: Colors.white),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  responseMap['cost'].toString() + " ₹",
                  style: GoogleFonts.workSans(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.white),
                ),
              ),
            ],
          ),
          StepProgressIndicator(
            selectedSize: 60,
            unselectedSize: 60,
            totalSteps: 4,
            currentStep: 1,
            size: 36,
            selectedColor: Colors.black,
            unselectedColor: Colors.grey[200],
            customStep: (index, color, _) => Container(
              color: status.indexOf(responseMap['status']) >= index ? Colors.black : Colors.black,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    status.indexOf(responseMap['status']) >= index ? Icons.check : Icons.remove,
                    color: status.indexOf(responseMap['status']) >= index
                        ? Colors.white
                        : Colors.white,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    status[index],
                    style: status.indexOf(responseMap['status']) >= index
                        ? GoogleFonts.workSans(color: Colors.white)
                        : GoogleFonts.workSans(color: Colors.white),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
