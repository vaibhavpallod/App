import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import 'StatusIndividualScreen.dart';

class ShowStatus extends StatefulWidget {
  Map<dynamic,dynamic>m;
  ShowStatus({this.m});

  @override
  State<ShowStatus> createState() => _ShowStatusState();
}

class _ShowStatusState extends State<ShowStatus> {



  List<String>notKey=['dateTime','destination','dateTime','destinationLatitude','destinationLongitude','numberOfCabs','source','sourceLatitude','sourceLongitude'];
  List<Map>data;
  List<String>id;
  List<String>status=['Finding','Booked','Riding','Completed'];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }


  getData(){
    data=[];
    id=[];
    widget.m.keys.forEach((element){
      if(!notKey.contains(element)){
        id.add(element);
        data.add(widget.m[element]);
      }
    });
    for(int i=0;i<4;i++) {
      if(status.indexOf(data[0]['status']) <= i){
        print(status.indexOf(data[0]['status']));
        print(i);
      }
    }
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Source:- ${data[pos]['source']}",style: GoogleFonts.workSans(fontSize: 15,fontWeight: FontWeight.normal),maxLines: 1,overflow: TextOverflow.ellipsis,),
               SizedBox(height: 10,),
                Text("Destination:- ${data[pos]['destination']}",style: GoogleFonts.workSans(fontSize: 15,fontWeight: FontWeight.normal),maxLines: 1,overflow: TextOverflow.ellipsis,),
                SizedBox(height: 10,),
                Row(
                  children: [
                    Text("Status:- ${data[pos]['status']}",style: GoogleFonts.workSans(fontSize: 15,fontWeight: FontWeight.normal),maxLines: 1,overflow: TextOverflow.ellipsis,),
                    Spacer(),
                    status.indexOf(data[pos]['status'])>=1?GestureDetector(child: Text('Track',style: GoogleFonts.workSans(fontSize: 15,fontWeight: FontWeight.normal,color: Colors.blue),),onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>StatusIndividualScreen(data: data[pos],id: id[pos],)));
                    },):Container(),
                    SizedBox(width: 10,)
                  ],
                ),
                SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 8),
                  child: StepProgressIndicator(
                    selectedSize: 60,
                    unselectedSize: 60,
                    totalSteps: 4,
                    currentStep: status.indexOf(data[pos]['status'])+1,
                    size: 36,
                    selectedColor: Colors.black,
                    unselectedColor: Colors.grey[200],
                    customStep: (index, color, _) => Container(
                      color: color,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            status.indexOf(data[pos]['status'])>=index?Icons.check:Icons.remove,
                            color: status.indexOf(data[pos]['status'])>=index?Colors.white:Colors.black,
                          ),
                          SizedBox(height: 5,),
                          Text(status[index],style: status.indexOf(data[pos]['status'])>=index?GoogleFonts.workSans(color: Colors.white):GoogleFonts.workSans(color: Colors.black),)
                        ],
                      ),
                    )
                  ),
                ),
              ],
            ),
          ),
        );
      },itemCount: data.length,),
    );
  }
}
