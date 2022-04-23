import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:pie_chart/pie_chart.dart';
import 'StatusIndividualScreen.dart';

class ShowStatus extends StatefulWidget {
  Map<dynamic, dynamic> m;

  ShowStatus({this.m});

  @override
  State<ShowStatus> createState() => _ShowStatusState();
}

class _ShowStatusState extends State<ShowStatus> {
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
  List<Map> data;
  List<String> id;
  List<String> status = ['Finding', 'Booked', 'Riding', 'Completed'];
  Map<String, double> dataMap = {'Finding': 0, 'Booked': 0, 'Riding': 0, 'Completed': 0};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  final gradientList = <List<Color>>[
    [
      Colors.blue.shade50,
      Colors.blue.shade300,
    ],
    [
      Colors.blue.shade300,
      Colors.blue.shade500,
    ],
    [
      Colors.blue.shade500,
      Colors.blue.shade700,
    ],
    [Colors.blue.shade700, Colors.blue.shade900]
  ];

  getData() {
    data = [];
    id = [];
    widget.m.keys.forEach((element) {
      if (!notKey.contains(element)) {
        id.add(element);
        data.add(widget.m[element]);
        dataMap[widget.m[element]['status']] = dataMap[widget.m[element]['status']] + 1;
      }
    });
    for (int i = 0; i < 4; i++) {
      if (status.indexOf(data[0]['status']) <= i) {
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
        title: Text(
          'My Trips',
          style: GoogleFonts.workSans(color: Colors.white),
        ),
      ),
      body: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Brief Stats",
                      style: GoogleFonts.workSans(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 20,
                  ),
                  PieChart(
                    dataMap: dataMap,
                    animationDuration: Duration(milliseconds: 800),
                    chartLegendSpacing: 32,
                    chartRadius: MediaQuery.of(context).size.width / 2,
                    colorList: [
                      Colors.blue.shade100,
                      Colors.blue.shade400,
                      Colors.blue.shade700,
                      Colors.blue.shade900
                    ],
                    initialAngleInDegree: 0,
                    chartType: ChartType.ring,
                    ringStrokeWidth: 32,
                    legendOptions: LegendOptions(
                      showLegendsInRow: true,
                      legendPosition: LegendPosition.bottom,
                      showLegends: true,
                      legendShape: BoxShape.circle,
                      legendTextStyle: GoogleFonts.workSans(
                        fontWeight: FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                    chartValuesOptions: ChartValuesOptions(
                      showChartValues: true,
                      chartValueStyle: GoogleFonts.workSans(
                          fontSize: 20, fontWeight: FontWeight.normal, color: Colors.black),
                      chartValueBackgroundColor: Colors.white,
                      showChartValuesInPercentage: false,
                      decimalPlaces: 0,
                    ),
                    // gradientList: ---To add gradient colors---
                    // emptyColorGradient: ---Empty Color gradient---
                  )
                ],
              ),
            ),
          ),
          ListView.builder(
            itemBuilder: (BuildContext context, int pos) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Passenger Name:- ${data[pos]['passengerName']}",
                        style: GoogleFonts.workSans(fontSize: 16, fontWeight: FontWeight.w400),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Source:- ${data[pos]['source']}",
                        style: GoogleFonts.workSans(fontSize: 15, fontWeight: FontWeight.normal),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Destination:- ${data[pos]['destination']}",
                        style: GoogleFonts.workSans(fontSize: 15, fontWeight: FontWeight.normal),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      status.indexOf(data[pos]['status']) == 1 ||
                              status.indexOf(data[pos]['status']) == 2
                          ? status.indexOf(data[pos]['status']) == 1
                              ? Text(
                                  "ETA for Partner:- ${DateFormat.yMMMMd().add_jm().format(DateTime.fromMillisecondsSinceEpoch(data[pos]['eta']).add(Duration(hours: 19,minutes: 30)))}",
                                  style: GoogleFonts.workSans(
                                      fontSize: 15, fontWeight: FontWeight.normal),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : Text(
                                  "ETA for Rider:- ${DateFormat.yMMMMd().add_jm().format(DateTime.fromMillisecondsSinceEpoch(data[pos]['eta']).add(Duration(hours: 19,minutes: 30)))}",
                                  style: GoogleFonts.workSans(
                                      fontSize: 15, fontWeight: FontWeight.normal),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                          : Container(),
                      status.indexOf(data[pos]['status']) == 1 ||
                              status.indexOf(data[pos]['status']) == 2
                          ? SizedBox(
                              height: 10,
                            )
                          : Container(),
                      Row(
                        children: [
                          Text(
                            "Status:- ${data[pos]['status']}",
                            style:
                                GoogleFonts.workSans(fontSize: 15, fontWeight: FontWeight.normal),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Spacer(),
                          status.indexOf(data[pos]['status']) >= 1
                              ? GestureDetector(
                                  child: Text(
                                    'Track',
                                    style: GoogleFonts.workSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.blue),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                StatusIndividualScreen(
                                                  data: data[pos],
                                                  id: id[pos],
                                                )));
                                  },
                                )
                              : Container(),
                          SizedBox(
                            width: 10,
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: StepProgressIndicator(
                            selectedSize: 60,
                            unselectedSize: 60,
                            totalSteps: 4,
                            currentStep: status.indexOf(data[pos]['status']) + 1,
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
                                        status.indexOf(data[pos]['status']) == index
                                            ? (Icons.person)
                                            : status.indexOf(data[pos]['status']) > index
                                                ? Icons.check
                                                : Icons.remove,
                                        color: status.indexOf(data[pos]['status']) == index
                                            ? (Colors.green)
                                            : status.indexOf(data[pos]['status']) > index
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        status[index],
                                        style: status.indexOf(data[pos]['status']) == index
                                            ? GoogleFonts.workSans(
                                                color: Colors.green, fontWeight: FontWeight.bold)
                                            : status.indexOf(data[pos]['status']) >= index
                                                ? GoogleFonts.workSans(color: Colors.white)
                                                : GoogleFonts.workSans(color: Colors.black),
                                      )
                                    ],
                                  ),
                                )),
                      ),
                    ],
                  ),
                ),
              );
            },
            itemCount: data.length,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
          ),
        ],
      ),
    );
  }
}
