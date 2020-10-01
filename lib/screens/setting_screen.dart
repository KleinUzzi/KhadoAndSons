import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:KhadoAndSons/app_localizations.dart';
import 'package:KhadoAndSons/models/language_model.dart';
import 'package:KhadoAndSons/utils/admob_utils.dart';
import 'package:KhadoAndSons/utils/constants.dart';
import 'package:KhadoAndSons/utils/resources/colors.dart';
import 'package:KhadoAndSons/utils/resources/images.dart';
import 'package:KhadoAndSons/utils/resources/size.dart';
import 'package:KhadoAndSons/utils/widgets.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/svg.dart';
import 'package:firebase_admob/firebase_admob.dart';
import '../app_state.dart';

class SettingScreen extends StatefulWidget {
  static String tag = '/SettingScreen';

  @override
  SettingScreenState createState() => SettingScreenState();
}

class SettingScreenState extends State<SettingScreen> {
  var selectedLanguage = 0;
  SharedPreferences pref;
  bool isSwitched = false;
  BannerAd _bannerAd;

  @override
  void initState() {
    super.initState();
    init();
    _bannerAd = createBannerAd();
    _bannerAd
      ..load()
      ..show();
  }

  init() async {
    pref = await getSharedPref();
    selectedLanguage = pref.getInt(SELECTED_LANGUAGE_INDEX) != null
        ? pref.getInt(SELECTED_LANGUAGE_INDEX)
        : 0;
    isSwitched = pref.getBool(IS_DARK_THEME) ?? false;
    setState(() {});
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      iconTheme: Theme.of(context).iconTheme,
      centerTitle: true,
      title: headingText(context, keyString(context, "settings")),
    );
    final body = Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(width: 5),
              SvgPicture.asset(icon_miscellaneous, height: 28, width: 28),
              SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: text(context, keyString(context, 'language'),
                      fontFamily: font_medium,
                      textColor: Theme.of(context).textTheme.title.color,
                      fontSize: ts_extra_normal),
                ),
              ),
              Theme(
                data: ThemeData(canvasColor: Theme.of(context).cardTheme.color),
                child: DropdownButton(
                  value: Language.getLanguages()[selectedLanguage].name,
                  underline: SizedBox(),
                  onChanged: (newValue) {
                    setState(() {
                      for (var i = 0; i < Language.getLanguages().length; i++) {
                        if (newValue == Language.getLanguages()[i].name) {
                          selectedLanguage = i;
                        }
                      }
                      pref.setString(
                          SELECTED_LANGUAGE_CODE,
                          Language.getLanguages()[selectedLanguage]
                              .languageCode);
                      pref.setInt(SELECTED_LANGUAGE_INDEX, selectedLanguage);
                      Provider.of<AppState>(context, listen: false)
                          .changeLocale(Locale(
                              Language.getLanguages()[selectedLanguage]
                                  .languageCode,
                              ''));
                      Provider.of<AppState>(context, listen: false)
                          .changeLanguageCode(
                              Language.getLanguages()[selectedLanguage]
                                  .languageCode);
                    });
                  },
                  items: Language.getLanguages().map((language) {
                    return DropdownMenuItem(
                      child: Row(
                        children: <Widget>[
                          Image.asset(language.flag, width: 20, height: 20),
                          SizedBox(width: 10),
                          text(context, language.name,
                              textColor:
                                  Theme.of(context).textTheme.title.color,
                              fontSize: ts_normal,
                              fontFamily: font_medium),
                        ],
                      ),
                      value: language.name,
                    );
                  }).toList(),
                ),
              ),
              SizedBox(width: 5),
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(width: 5),
              SvgPicture.asset(icon_logotype, height: 28, width: 28),
              SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: text(context, keyString(context, 'night_mode'),
                      fontFamily: font_medium,
                      textColor: Theme.of(context).textTheme.title.color,
                      fontSize: ts_extra_normal),
                ),
              ),
              Switch(
                value: isSwitched,
                onChanged: (value) {
                  setState(() {
                    isSwitched = value;
                    pref.setBool(IS_DARK_THEME, isSwitched);
                    Provider.of<AppState>(context, listen: false)
                        .changeMode(isSwitched);
                    setState(() {});
                  });
                },
                activeColor: color_primary_black,
              ),
              SizedBox(width: 5),
            ],
          ),
        ],
      ),
    );
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: appBar,
      body: body,
    );
  }
}
