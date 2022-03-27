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

  List<String>status=['Finding','Booking','Riding','Completed'];

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
              children: [
                Text("Source:- ${data[pos]['source']}",style: GoogleFonts.workSans(fontSize: 15,fontWeight: FontWeight.normal),maxLines: 1,overflow: TextOverflow.ellipsis,),
               SizedBox(height: 10,),
                Text("Destination:- ${data[pos]['destination']}",style: GoogleFonts.workSans(fontSize: 15,fontWeight: FontWeight.normal),maxLines: 1,overflow: TextOverflow.ellipsis,),
                SizedBox(height: 10,),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 8),
                  child: StepProgressIndicator(
                    selectedSize: 60,
                    unselectedSize: 60,
                    totalSteps: 4,
                    currentStep: 1,
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
                )
              ],
            ),
          ),
        );
      },itemCount: data.length,),
    );
  }
}
