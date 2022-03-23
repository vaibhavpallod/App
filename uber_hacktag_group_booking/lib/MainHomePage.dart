import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_hacktag_group_booking/konstants/loaders.dart';
import 'package:location/location.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:slider_button/slider_button.dart';

class MainHomePage extends StatefulWidget {
  @override
  _MainHomePageState createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {



  GoogleMapController _controller;
  Location currentLocation = Location();
  Set<Marker> _markers={};
  int noc=2;
  bool load=true;
  LocationData location;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocation();
  }




  void getLocation() async{
     location= await currentLocation.getLocation();
    currentLocation.onLocationChanged.listen((LocationData loc){
      _markers={};
      print(loc.latitude);
      print(loc.longitude);
      setState(() {
        load=false;
        _markers.add(Marker(markerId: MarkerId('Home'),
            position: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0)
        ));
      });
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: load?spinkit:Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child:Stack(
          children: [
            GoogleMap(
              zoomControlsEnabled: false,
              initialCameraPosition:CameraPosition(
                target:LatLng(location.latitude ?? 0.0,location.longitude?? 0.0),
                zoom: 12.0,
              ),
              onMapCreated: (GoogleMapController controller){
                _controller = controller;
              },
              markers: _markers,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 8),
                child: Material(
                  elevation: 10,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0x99000000),
                          Color(0xFF000000)
                        ]
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    height: 160,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text('Group Bookings',style: GoogleFonts.workSans(color: Colors.white,fontSize: 18),),
                        ),
                        SizedBox(height: 5,),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text('Number of Cabs',style: GoogleFonts.workSans(color: Colors.white,fontSize: 14,fontWeight: FontWeight.w300),),
                            ),
                            SizedBox(height: 5,),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: NumberPicker(
                                  haptics: true,
                                  value: noc,
                                  maxValue: 11,
                                  minValue: 2,
                                  axis: Axis.horizontal,
                                  itemWidth: 50,
                                  selectedTextStyle: GoogleFonts.workSans(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w300),
                                  textStyle: GoogleFonts.workSans(color: Color(0x99FFFFFF),fontSize: 15,fontWeight: FontWeight.w300),
                                  onChanged: (int val){
                                    setState(() {
                                      noc=val;
                                    });
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 5,),
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
                        Expanded(
                            child:Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SliderButton(
                                action: (){

                                },
                                icon: Center(
                                  child: Icon(
                                    Icons.local_taxi,
                                    color: Colors.black,
                                  ),
                                ),
                                label: Text(
                                  "Slide to Book",
                                  style: GoogleFonts.workSans(color: Colors.white,fontSize: 14,fontWeight: FontWeight.w400),
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
        ) ,
      ),
    );
  }
}
