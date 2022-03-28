import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uber_hacktag_group_booking/Enter/login.dart';
import 'package:uber_hacktag_group_booking/pages/ShowStatus.dart';

import '../konstants/loaders.dart';

class UserProfile extends StatefulWidget {

  String name;
  UserProfile({this.name});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {


  var storage = FlutterSecureStorage();
  bool load=true;
  List<Map>l;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTrips();
  }



  void getTrips()async{
    l=[];
    User user=FirebaseAuth.instance.currentUser;
    DatabaseReference dr =FirebaseDatabase.instance.ref().child('allusers').child(user.uid).child('rides');
    DataSnapshot ds=await dr.get();
    Map map=ds.value as Map;
    List<String>ridesID=[];
    if(map==null||map.length==0) {
      setState(() {
        load=false;
      });
      return;
    }
    map.keys.forEach((element) {
      ridesID.add(element);
    });
    for(int i=0;i<ridesID.length;i++){
      DatabaseReference d= dr.child(ridesID[i]);
      DataSnapshot d1=await d.get();
      l.add(d1.value);
    }
    setState(() {
      load=false;
    });
  }


  bool showTrips=false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Text('My Trips',style: GoogleFonts.workSans(color: Colors.white),),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(child: Icon(Icons.exit_to_app,color: Colors.white,),
              onTap: ()async{
                await storage.deleteAll();
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context)=>Login()), (route) => false);
              },),
            )
          ],
        ),
        body: load?spinkit:l.isEmpty?Center(child:Text('No Travel History found',style: GoogleFonts.workSans(fontSize: 20,fontWeight: FontWeight.w500),)):ListView.builder(itemBuilder: (BuildContext context,int pos){
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>ShowStatus(m: l[pos],)));
              },
              child: Card(
                child: ListTile(
                  title: Text(l[pos].containsKey('destination')?"Destination:- ${l[pos]['destination'].toString()}":"Source:- ${l[pos]['source']}",style: GoogleFonts.workSans(),maxLines: 1,overflow: TextOverflow.ellipsis,),
                  subtitle: Row(
                    children: [
                      Text('Number of Cabs:- ${l[pos]['numberOfCabs']}',style: GoogleFonts.workSans()),
                      Spacer(),
                      Text( DateFormat.yMd().add_jm().format(DateTime.fromMillisecondsSinceEpoch(l[pos]['dateTime'])),style: GoogleFonts.workSans()),
                    ],
                  ),
                ),
              ),
            ),
          );
        },itemCount: l.length,),
      ),
    );
  }
}
