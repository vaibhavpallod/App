import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// class FitnessAppTheme {
const kDarkPrimaryColor = Color(0xFF212121);

const kSpacingUnit = 10;
final kTitleTextStyle = TextStyle(
  fontSize: ScreenUtil().setSp(kSpacingUnit.w * 1.7),
  fontWeight: FontWeight.w600,
);

final kCaptionTextStyle = TextStyle(
  fontSize: ScreenUtil().setSp(kSpacingUnit.w * 1.3),
  fontWeight: FontWeight.w100,
);

final kButtonTextStyle = TextStyle(
  fontSize: ScreenUtil().setSp(kSpacingUnit.w * 1.5),
  fontWeight: FontWeight.w400,
  color: kDarkPrimaryColor,
);

const defaultDuration = Duration(milliseconds: 250);

// Get the proportionate height as per screen size

const Color homeBackground = Color(0xFFF2F3F8);

const kPrimaryColor = Color(0xff3e60c1);
const kPrimaryLightColor = Colors.lightBlueAccent; //Color(0xFF82CAFF);
const kPrimaryGradientColor = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFFFA53E), Color(0xFFFF7643)],
);

const dummyPlaceHolder = "images/placeholder.jpg";
const String fontName = 'Roboto';

const int currentIndex = 3;
const API_KEY = "AIzaSyAvyfarjvVHlKhaOJtZzGzHUtTN55Mouzo";


class RoundedButton extends StatelessWidget {
  final String text;
  final Function press;
  final Color color, textColor;

  const RoundedButton({
    Key key,
    this.text,
    this.press,
    this.color = Colors.lightBlueAccent,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          border: Border.all(color: Colors.grey.shade800)),
      height: 50,
      margin: EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: FlatButton(
          // padding: EdgeInsets.symmetric(vertical: 20, horizontal:20),
          color: color,
          onPressed: press,
          child: Text(
            text,
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }

}
// }
