import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../konstants/loaders.dart';

class ShowNormalUserMap extends StatefulWidget {
  const ShowNormalUserMap({Key key}) : super(key: key);

  @override
  _ShowNormalUserMapState createState() => _ShowNormalUserMapState();
}

class _ShowNormalUserMapState extends State<ShowNormalUserMap> {

  final storage = FlutterSecureStorage();
  String _dataFromFlutter = "Android can ping you";
  MethodChannel platform = MethodChannel('Sample/test');

  bool load=true;
  @override
  void initState() {
    // TODO: implement initState
    print('page' + "Userpage");

    super.initState();
    getLocation();
  }
  void getLocation() async {
    var pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5,size: Size.fromHeight(12)),
        'images/pin.png');

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
      var id = data.substring(34);
      print(idx.toString() + " ID from SHOWMAP printing DART " + id);
      print("from SHOWMAP printing DART" + data);
    } on PlatformException catch (e) {
      data = "Android is not responding please check the code";
      print("from SHOWMAP printing DART" + data);
    }

    setState(() {
      load=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

/*
  @override
  Widget build(BuildContext context) {
    return load?spinkit:SizedBox(
      height: MediaQuery
          .of(context)
          .size
          .height,
      width: MediaQuery
          .of(context)
          .size
          .width,

      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                  location.latitude ?? 0.0, location.longitude ?? 0.0),
              zoom: 16.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              controller.setMapStyle(Utils.mapStyles);
              _controller = controller;
            },
            markers: _markers,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 8),
              child: Material(
                elevation: 15,
                borderRadius: BorderRadius.all(Radius.circular(20)),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    gradient: LinearGradient(
                        colors: [
                          Color(0x99000000),
                          Color(0xFF000000)
                        ]
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  height: 200,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text('Group Bookings',
                          style: GoogleFonts.workSans(
                              color: Colors.white, fontSize: 18),),
                      ),
                      SizedBox(height: 5,),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10),
                            child: Text('Number of Cabs',
                              style: GoogleFonts.workSans(color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300),),
                          ),
                          SizedBox(height: 5,),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10),
                              child: NumberPicker(
                                haptics: true,
                                value: noc,
                                maxValue: 11,
                                minValue: 2,
                                axis: Axis.horizontal,
                                itemWidth: 50,
                                selectedTextStyle: GoogleFonts.workSans(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w300),
                                textStyle: GoogleFonts.workSans(
                                    color: Color(0x99FFFFFF),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w300),
                                onChanged: (int val) {
                                  setState(() {
                                    noc = val;
                                  });
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10),
                            child: Text('Same', style: GoogleFonts.workSans(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w300),),
                          ),
                          Spacer(),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8),
                            child: ToggleSwitch(
                              totalSwitches: 2,
                              initialLabelIndex: 0,
                              labels: [
                                'Origin',
                                'End'
                              ],
                              minHeight: 30,
                              onToggle: (index) {
                                if (index == 0) {
                                  originSame = true;
                                } else {
                                  originSame = false;
                                }
                              },
                              inactiveBgColor: Colors.white,
                              activeBgColor: [
                                Colors.orange
                              ],
                              customTextStyles: [
                                GoogleFonts.workSans(color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300),
                                GoogleFonts.workSans(color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400),
                              ],
                            ),
                          )
                        ],
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
                      SizedBox(height: 5,),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SliderButton(
                            action: () {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      BookingForm(cabsCount: noc,
                                        originSame: originSame,)));
                            },
                            icon: Center(
                              child: Icon(
                                Icons.local_taxi,
                                color: Colors.black,
                              ),
                            ),
                            label: Text(
                              "Slide to Book",
                              style: GoogleFonts.workSans(color: Colors.white,
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
    );
  }
*/
}
