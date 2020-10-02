import 'package:flutter/material.dart';
import 'package:granth_flutter/utils/admob_utils.dart';
import 'package:granth_flutter/utils/constants.dart';
import 'package:granth_flutter/utils/resources/images.dart';
import 'package:granth_flutter/utils/widgets.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:firebase_admob/firebase_admob.dart';
import '../app_localizations.dart';

class AboutApp extends StatefulWidget {
  static String tag = '/AboutApp';

  @override
  _AboutAppState createState() => _AboutAppState();
}

class _AboutAppState extends State<AboutApp> {
  BannerAd _bannerAd;
  @override
  void initState() {
    super.initState();
    _bannerAd = createBannerAd();
    _bannerAd..load()..show();
  }
  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            app_icon,
            alignment: Alignment.center,
            height: 150,
            width: 150,
          ).cornerRadiusWithClipRRect(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[Icon(Icons.copyright).paddingOnly(right: 4), text(context,'2020 Granth',textColor: Theme.of(context).textTheme.title.color)],
          ).paddingAll(8.0),
          Text(keyString(context,"app_name"))
              .withStyle(fontSize: 16, color: Theme.of(context).textTheme.title.color, fontFamily: font_regular, textDecoration: TextDecoration.underline)
              .paddingOnly(top: 8)
              .onTap(() {
          }),
          Text('V1.0').withStyle(fontSize: 16, color: Theme.of(context).textTheme.title.color, fontFamily: font_regular).paddingOnly(top: 16),
        ],
      ),
    );
  }
}
