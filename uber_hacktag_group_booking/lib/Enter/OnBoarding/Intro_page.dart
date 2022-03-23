// import 'package:app_intro_food_delivery/models/step_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../konstants/Constansts.dart';
import '../login.dart';
import '../signup.dart';
import 'StepModel.dart';

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  List<StepModel> list = StepModel.list;
  var _controller = PageController();
  var initialPage = 0;

  @override
  Widget build(BuildContext context) {
    _controller.addListener(() {
      setState(() {
        initialPage = _controller.page.round();
      });
    });

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            // image: DecorationImage(
            //   fit: BoxFit.fitHeight,
            //   image: AssetImage("images/onback.jpg"),
            //   colorFilter: new ColorFilter.mode(
            //       Colors.black.withOpacity(0.4), BlendMode.dstOut),
            // ),
          ),
          child: Column(
            children: <Widget>[
              // _appBar(),
              _body(_controller),
              _indicator(),
            ],
          ),
        ),
      ),
    );
  }

  _appBar() {
    return Container(
      // margin: EdgeInsets.only(top: 25),
      padding: EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              if (initialPage > 0)
                _controller.animateToPage(initialPage - 1,
                    duration: Duration(microseconds: 500),
                    curve: Curves.easeIn);
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withAlpha(50),
                borderRadius: const BorderRadius.all(
                  Radius.circular(15),
                ),
              ),
              child: Icon(Icons.arrow_back_ios),
            ),
          ),
        ],
      ),
    );
  }

  _body(PageController controller) {
    return Expanded(
      child: PageView.builder(
        controller: controller,
        itemCount: list.length + 1,
        itemBuilder: (context, index) {
          return index < list.length
              ? Container(
                  color: Colors.white,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: _displayImage(list[index].id),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.black87,
                        child: _displayTitle(list[index].title),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      _displayText(list[index].text),
                    ],
                  ),
                )
              : Column(
                  children: <Widget>[
                    _displayImage(5),
                    const Text(
                      'Get Started',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        fontFamily: 'MontserratMed',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Expanded(child: _displaybutton())
                    // _displaybutton(),
                  ],
                );
        },
      ),
    );
  }

  _indicator() {
    return Container(
      width: 90,
      height: 90,
      margin: EdgeInsets.symmetric(vertical: 12),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 90,
              height: 90,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.lightBlueAccent),
                value: (initialPage + 1) / (list.length + 1),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {
                if (initialPage < list.length)
                  _controller.animateToPage(initialPage + 1,
                      duration: Duration(microseconds: 500),
                      curve: Curves.easeIn);
              },
              child: Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent.shade400,
                  borderRadius: BorderRadius.all(
                    Radius.circular(100),
                  ),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  _displayText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 25.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          fontFamily: 'MontserratSemi',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  _displayTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30,
          color: CupertinoColors.white,
          fontFamily: 'MontserratSemi',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  _displayImage(int path) {
    return Image.asset(
      "images/on0$path.jpg",
      height: MediaQuery.of(context).size.height * .5,
    );
  }

  _displaybutton() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RoundedButton(
            text: "LOGIN",
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (BuildContext context) => Login()),
              );
            },
          ),
          RoundedButton(
            text: "SIGN UP",
            color: kPrimaryLightColor.shade100,
            textColor: Colors.black,
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (BuildContext context) => SignUp()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class RoundedButton extends StatelessWidget {
  final String text;
  final Function press;
  final Color color, textColor;

  const RoundedButton({
    Key key,
    this.text,
    this.press,
    this.color = Colors.lightBlueAccent,
    this.textColor = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(29),
        child: FlatButton(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
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
