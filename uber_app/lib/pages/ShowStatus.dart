import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class ShowStatus extends StatefulWidget {
  Map<dynamic,dynamic>m;
  ShowStatus({this.m});

  @override
  State<ShowStatus> createState() => _ShowStatusState();
}

class _ShowStatusState extends State<ShowStatus> {



  List<String>notKey=['dateTime','destination','dateTime','destinationLatitude','destinationLongitude','numberOfCabs','source','sourceLatitude','sourceLongitude'];
  List<Map>data;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }


  getData()async{
    data=[];
    widget.m.keys.forEach((element){
      if(!notKey.contains(element)){
        data.add(widget.m[element]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text('My Trips',style: GoogleFonts.workSans(color: Colors.white),),
      ),
      body: ListView.builder(itemBuilder: (BuildContext context,int pos){
        return  Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text("Source:- ${data[pos]['source']}",style: GoogleFonts.workSans(fontSize: 15,fontWeight: FontWeight.normal),maxLines: 1,overflow: TextOverflow.ellipsis,),
                Text("Destination:- ${data[pos]['destination']}",style: GoogleFonts.workSans(fontSize: 15,fontWeight: FontWeight.normal),maxLines: 1,overflow: TextOverflow.ellipsis,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 8),
                  child: StepProgressIndicator(
                    totalSteps: 4,
                    currentStep: 1,
                    size: 36,
                    selectedColor: Colors.black,
                    unselectedColor: Colors.grey[200],
                    customStep: (index, color, _) => color == Colors.black
                        ? Container(
                      color: color,
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
                    )
                        : Container(
                      color: color,
                      child: Icon(
                        Icons.remove,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },itemCount: data.length,),
    );
  }
}
