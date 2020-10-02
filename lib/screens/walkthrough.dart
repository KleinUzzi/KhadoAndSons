import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:granth_flutter/screens/home_screen.dart';
import 'package:granth_flutter/utils/common.dart';
import 'package:granth_flutter/utils/constants.dart';
import 'package:granth_flutter/utils/resources/colors.dart';
import 'package:granth_flutter/utils/resources/images.dart';
import 'package:granth_flutter/utils/resources/size.dart';
import 'package:granth_flutter/utils/widgets.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:flutter_svg/svg.dart';

import '../app_localizations.dart';

class OnBoardingScreen extends StatefulWidget {
  static var tag = "/OnBoarding";

  @override
  OnBoardingScreenState createState() => OnBoardingScreenState();
}

class OnBoardingScreenState extends State<OnBoardingScreen> {
  int currentIndexPage = 0;
  PageController _controller = new PageController();

  @override
  void initState() {
    super.initState();
    currentIndexPage = 0;
    setBool(IS_ONBOARDING_LAUNCHED, true);
  }

  VoidCallback onPrev() {
    setState(() {
      if (currentIndexPage >= 1) {
        currentIndexPage = currentIndexPage - 1;
        _controller.jumpToPage(currentIndexPage);
      }
    });
  }

  VoidCallback onNext() {
    setState(() {
      if (currentIndexPage < 2) {
        currentIndexPage = currentIndexPage + 1;
        _controller.jumpToPage(currentIndexPage);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    changeStatusColor(Colors.transparent);
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Stack(
          alignment: Alignment.topRight,
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              PageView(
                controller: _controller,
                children: <Widget>[
                  WalkThrough(title: 'Select a Book',subTitle:"Lorem Ipsum is simply dummy text of the printing and typesetting industry.simply duumy text ", walkImg: icon_walk1),
                  WalkThrough(title: 'Purchase Online',subTitle:"Lorem Ipsum is simply dummy text of the printing and typesetting industry.simply duumy text ", walkImg: icon_walk2),
                  WalkThrough(title: 'Enjoy Your Book',subTitle:"Lorem Ipsum is simply dummy text of the printing and typesetting industry.simply duumy text ", walkImg: icon_walk3),
                  WalkThrough(title: 'Welcome to Granth',subTitle:"Lorem Ipsum is simply dummy text of the printing and typesetting industry.simply duumy text ", walkImg: icon_walk4, isLast: true,),
                ],
                onPageChanged: (value) {
                  setState(() => currentIndexPage = value);
                },
              ),
              Padding(
                padding: const EdgeInsets.all(spacing_standard_new),
                child: DotsIndicator(
                    dotsCount: 4,
                    position: currentIndexPage,
                    decorator: DotsDecorator(
                        color: Colors.grey.withOpacity(0.5),
                        activeColor: Theme.of(context).primaryColor,
                        activeSize: Size.square(spacing_standard),
                        size: Size.square(6.0),
                        spacing: EdgeInsets.all(spacing_control))),
              )
            ],
          ),
        ),
      ],
    ));
  }
}

class WalkThrough extends StatelessWidget {
  final String title;
  final String subTitle;
  final bool isLast;
  final String walkImg;

  WalkThrough({Key key, this.title,this.subTitle, this.isLast = false, this.walkImg})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Stack(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(
                    top: width * 0.15, left: width * 0.1, right: width * 0.1),
                height: h * 0.5,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    SvgPicture.asset(walkImg,
                        width: width * 0.6, height: width * 0.6)
                  ],
                ),
              ),
              SizedBox(
                height: width * 0.1,
              ),
              text(context,title,
                  textColor: Theme.of(context).textTheme.title.color,
                  fontSize: ts_extra_normal,
                  fontFamily: font_bold),
              Padding(
                padding: const EdgeInsets.only(left: 28.0, right: 28.0),
                child: text(context,subTitle,
                    fontSize: ts_normal,
                    maxLine: 3,
                    isCentered: true),
              )
            ],
          ),
        ),
        isLast
            ? Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onTap: () {
                    launchScreenWithNewTask(context, HomeScreen.tag);
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 16, right: 16, bottom: 50),
                    alignment: Alignment.center,
                    height: width / 8,
                    child: text(context,keyString(context,"lbl_get_started"),
                        textColor: white,
                        isCentered: true,
                        fontSize: ts_normal,
                        fontFamily: font_medium),
                    decoration:
                        boxDecoration(context,bgColor:Theme.of(context).primaryColor, radius: 30),
                  ),
                ),
              )
            : Container()
      ],
    );
  }
}

