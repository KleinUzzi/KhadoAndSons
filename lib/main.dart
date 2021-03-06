import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:granth_flutter/app_state.dart';
import 'package:granth_flutter/screens/about_app_screen.dart';
import 'package:granth_flutter/screens/author_detail_screen.dart';
import 'package:granth_flutter/screens/author_list.dart';
import 'package:granth_flutter/screens/book_description_screen.dart';
import 'package:granth_flutter/screens/book_reviews.dart';
import 'package:granth_flutter/screens/cart_screen.dart';
import 'package:granth_flutter/screens/category_book_screen.dart';
import 'package:granth_flutter/screens/change_password_screen.dart';
import 'package:granth_flutter/screens/feedback_screen.dart';
import 'package:granth_flutter/screens/forgot_password.dart';
import 'package:granth_flutter/screens/home_screen.dart';
import 'package:granth_flutter/screens/library_screen.dart';
import 'package:granth_flutter/screens/profile_screen.dart';
import 'package:granth_flutter/screens/search_book_screen.dart';
import 'package:granth_flutter/screens/setting_screen.dart';
import 'package:granth_flutter/screens/signIn.dart';
import 'package:granth_flutter/screens/signup.dart';
import 'package:granth_flutter/screens/transaction_history_screen.dart';
import 'package:granth_flutter/screens/verify_otp.dart';
import 'package:granth_flutter/screens/walkthrough.dart';
import 'package:granth_flutter/screens/wishlist_screens.dart';
import 'package:granth_flutter/utils/constants.dart';
import 'package:granth_flutter/utils/resources/colors.dart';
import 'package:granth_flutter/utils/resources/images.dart';
import 'package:granth_flutter/utils/widgets.dart';
import 'package:nb_utils/nb_utils.dart';
import 'app_localizations.dart';
import 'app_theme.dart';
import 'utils/common.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//  FirebaseAdMob.instance.initialize(appId: Platform.isAndroid?android_appid:ios_appid);

  var pref = await getSharedPref();

  try {
    await FlutterDownloader.initialize();
  } on Exception catch (_) {
    print('never reached');
  }
  var language = pref.getString(SELECTED_LANGUAGE_CODE) ?? "en";
  bool isDarkTheme = pref.getBool(IS_DARK_THEME) ?? false;
  runApp(new MyApp(language, isDarkTheme));
}

class MyApp extends StatefulWidget {
  static String tag = '/MyApp';
  var language;
  bool isDarkTheme;

  MyApp(this.language, this.isDarkTheme);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(widget.language, isDarkMode: widget.isDarkTheme),
      child: Consumer<AppState>(builder: (context, provider, builder) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          supportedLocales: [
            Locale('en', ''),
            Locale('fr', ''),
            Locale('af', ''),
            Locale('de', ''),
            Locale('es', ''),
            Locale('id', ''),
            Locale('pt', ''),
            Locale('tr', ''),
            Locale('hi', '')
          ],
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            return Locale(Provider.of<AppState>(context).selectedLanguageCode);
          },
          locale: Provider.of<AppState>(context).locale,
          home: SplashScreen(),
          theme: AppTheme.lightTheme, // ThemeData(primarySwatch: Colors.blue),
          darkTheme:
              AppTheme.darkTheme, // ThemeData(primarySwatch: Colors.blue),
          themeMode: provider.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
          routes: <String, WidgetBuilder>{
            HomeScreen.tag: (BuildContext context) => HomeScreen(),
            SplashScreen.tag: (BuildContext context) => SplashScreen(),
            AuthorDetailScreen.tag: (BuildContext context) =>
                AuthorDetailScreen(),
            SearchScreen.tag: (BuildContext context) => SearchScreen(),
            SignUp.tag: (BuildContext context) => SignUp(),
            SignIn.tag: (BuildContext context) => SignIn(),
            ChangePasswordScreen.tag: (BuildContext context) =>
                ChangePasswordScreen(),
            AboutApp.tag: (BuildContext context) => AboutApp(),
            WishlistScreen.tag: (BuildContext context) => WishlistScreen(),
            BookDescriptionScreen.tag: (BuildContext context) =>
                BookDescriptionScreen(),
            OnBoardingScreen.tag: (BuildContext context) => OnBoardingScreen(),
            TransactionHistoryScreen.tag: (BuildContext context) =>
                TransactionHistoryScreen(),
            SettingScreen.tag: (BuildContext context) => SettingScreen(),
            CartScreen.tag: (BuildContext context) => CartScreen(),
            ProfileScreen.tag: (BuildContext context) => ProfileScreen(),
            LibraryScreen.tag: (BuildContext context) => LibraryScreen(),
            FeedbackScreen.tag: (BuildContext context) => FeedbackScreen(),
            AuthorsListScreen.tag: (BuildContext context) =>
                AuthorsListScreen(),
            BookReviews.tag: (BuildContext context) => BookReviews(),
            ForgotPassword.tag: (BuildContext context) => ForgotPassword(),
            VerifyOTPScreen.tag: (BuildContext context) => VerifyOTPScreen(),
            SettingScreen.tag: (BuildContext context) => SettingScreen(),
            CategoryBooks.tag: (BuildContext context) => CategoryBooks(),
          },
          builder: (context, child) {
            return ScrollConfiguration(
              behavior: ScrBehavior(),
              child: child,
            );
          },
        );
      }),
    );
  }
}

class ScrBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class SplashScreen extends StatefulWidget {
  static String tag = '/SplashScreen';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startTime() async {
    var _duration = Duration(seconds: 3);
    return Timer(_duration, navigationPage);
  }

  void navigationPage() async {
    bool isLaunched = await getBool(IS_ONBOARDING_LAUNCHED) ?? false;
    launchScreenWithNewTask(
        context, isLaunched ? HomeScreen.tag : OnBoardingScreen.tag);
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Image.asset(
            splash_bg,
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.fitHeight,
          ),
          Container(
            height: double.infinity,
            width: double.infinity,
            color: colorPrimary,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                app_icon,
                alignment: Alignment.center,
                height: 120,
                width: 120,
              ).cornerRadiusWithClipRRect(10),
              Text(keyString(context, "app_name"))
                  .withStyle(fontSize: 24, color: white, fontFamily: font_bold)
                  .paddingOnly(top: 16),
              // text(context,keyString(context,"lbl_welcome_to_ebook_spot"), fontSize: 16, textColor: white).paddingOnly(top: 8),
            ],
          )
        ],
      ),
    );
  }
}
