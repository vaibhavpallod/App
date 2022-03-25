import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../Enter/place_service.dart';
import '../address_search.dart';

class BookingForm extends StatefulWidget {
  int cabsCount;
  bool originSame;
  BookingForm({this.cabsCount,this.originSame});

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm>{


  String selectedCab="Auto";
   List<TextEditingController>_controller=[];
  final homeScaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    // TODO: implement initState
    for(int i=0;i<widget.cabsCount;i++){
      _controller.add(TextEditingController());
    }
    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Passenger Details',
          style: GoogleFonts.workSans(color: Colors.black, fontSize: 18),
        ),
        leading: IconButton(icon: Icon(Icons.arrow_back,color: Colors.blue,),onPressed: (){
          Navigator.pop(context);
        },),
        backgroundColor: Colors.white,
        actions: [
          Center(child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('NEXT',style: GoogleFonts.workSans(color: Colors.blue, fontSize: 16,fontWeight: FontWeight.w400)),
          ))
        ],
      ),
      body: ListView.builder(
        itemBuilder: (BuildContext context, int pos) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Cab ${pos+1} primary passenger',style: GoogleFonts.workSans(color: Colors.black, fontSize: 16,fontWeight: FontWeight.w500),textAlign: TextAlign.start,),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: TextField(
                      style: GoogleFonts.workSans(color: Colors.black, fontSize: 14),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Name",
                        focusColor: Colors.black,
                        labelStyle: GoogleFonts.workSans( fontSize: 14),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: TextField(
                      style: GoogleFonts.workSans(color: Colors.black, fontSize: 14),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Email",
                        focusColor: Colors.black,
                        labelStyle: GoogleFonts.workSans(fontSize: 14),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: TextField(
                      style: GoogleFonts.workSans(color: Colors.black, fontSize: 14),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Phone",
                        focusColor: Colors.black,
                        labelStyle: GoogleFonts.workSans(fontSize: 14),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Container(
                      child: DropdownButtonFormField(
                        value: selectedCab,
                        onChanged: (val){
                          setState(() {
                            selectedCab=val;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: "Type",
                          labelStyle: GoogleFonts.workSans(fontSize: 14),
                        ),
                        style: GoogleFonts.workSans(color: Colors.black, fontSize: 14),
                        items: [
                          DropdownMenuItem(child: Text('Auto',style: GoogleFonts.workSans(fontSize: 14),),value: 'Auto',),
                          DropdownMenuItem(child: Text('Go',style: GoogleFonts.workSans(fontSize: 14),),value: 'Go',),
                          DropdownMenuItem(child: Text('Sedan',style: GoogleFonts.workSans(fontSize: 14),),value: 'Sedan',),
                          DropdownMenuItem(child: Text('Premier',style: GoogleFonts.workSans(fontSize: 14),),value: 'Premier',),
                          DropdownMenuItem(child: Text('XL',style: GoogleFonts.workSans(fontSize: 14),),value: 'XL',),

                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: TextField(
                      readOnly: true,
                      controller: _controller[pos],
                      onTap: () async {
                        // generate a new token here
                        final sessionToken = Uuid().v4();
                        final Suggestion result = await showSearch(
                          context: context,
                          delegate: AddressSearch(sessionToken),
                        );
                        // This will change the text displayed in the TextField
                        if (result != null) {
                          final placeDetails = await PlaceApiProvider(sessionToken)
                              .getPlaceDetailFromId(result.placeId);
                          setState(() {
                            _controller[pos].text = result.description;
                          });
                        }
                      },
                      style: GoogleFonts.workSans(color: Colors.black, fontSize: 14),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: widget.originSame?'Destination Location':'Origin Location',
                        focusColor: Colors.black,
                        labelStyle: GoogleFonts.workSans(fontSize: 14),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        itemCount: widget.cabsCount,
      ),
    );
  }
}
