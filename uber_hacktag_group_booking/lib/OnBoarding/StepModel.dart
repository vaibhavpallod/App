class StepModel {
  final int id;
  final String text,title;

  StepModel({this.id,this.title, this.text});

  static List<StepModel> list = [
    StepModel(
      id: 1,
      title:'Easy to Book',
      text: "Book Multiple cabs with one click",
    ),
    StepModel(
      id: 2,
      title:'Track bookings',
      text:
      "All booked cabs can be tracked with single click",
    ),
    StepModel(
      id: 3,
      title:'asd',
      text: " xyz ",
    ),

    StepModel(
       id: 4,
      title:'asd',
      text: "xyz",
    ),

  ];
}