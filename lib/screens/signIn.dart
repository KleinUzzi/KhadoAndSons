import 'package:device_id/device_id.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:granth_flutter/models/response/login_response.dart';
import 'package:granth_flutter/network/rest_apis.dart';
import 'package:granth_flutter/screens/forgot_password.dart';
import 'package:granth_flutter/screens/home_screen.dart';
import 'package:granth_flutter/screens/signup.dart';
import 'package:granth_flutter/utils/common.dart';
import 'package:granth_flutter/utils/constants.dart';
import 'package:granth_flutter/utils/resources/size.dart';
import 'package:granth_flutter/utils/widgets.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../app_localizations.dart';

class SignIn extends StatefulWidget {
  static var tag = "/T2SignIn";

  @override
  SignInState createState() => SignInState();
}

class SignInState extends State<SignIn> {
  bool passwordVisible = true;
  bool isRemember = false;
  bool _autoValidate = false;
  String email;
  String password;
  var userId;
  var platfrom;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String deviceId;
  FocusNode passFocus = FocusNode();
  FocusNode emailFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    passwordVisible = true;
    fetchData();
    getDeviceID();
  }

  void getDeviceID() async {
    deviceId = await DeviceId.getID;
  }

  fetchData() async {
    var remember = await getBool(REMEMBER_PASSWORD) ?? false;
    if (remember) {
      var password = await getString(PASSWORD);
      var email = await getString(EMAIL);
      setState(() {
        emailController.text = email;
        passwordController.text = password;
      });
    }
    setState(() {
      isRemember = remember;
    });
    var status = await OneSignal.shared.getPermissionSubscriptionState();
    var id = status.subscriptionStatus.userId;

    setState(() {
      userId = id;
    });
  }

  bool isLoading = false;

  showLoading(bool show) {
    setState(() {
      isLoading = show;
    });
  }

  void login(BuildContext context) async {
    var request = {
      'device_id': deviceId,
      'email': email,
      'login_from': platfrom,
      'password': password,
      'registration_id': userId
    };
    await isNetworkAvailable().then((bool) async {
      if (bool) {
        showLoading(true);
        await doLogin(request).then((result) {
          print(result);
          showLoading(false);
          LoginResponse loginResponse = LoginResponse.fromJson(result);
          if (loginResponse.status) {
            LoginData data = loginResponse.data;
            setBool(IS_LOGGED_IN, true);
            setString(TOKEN, data.apiToken);
            setString(USERNAME, data.userName);
            setString(NAME, data.name);
            setString(USER_EMAIL, data.email);
            setString(USER_PROFILE, data.image);
            setString(USER_CONTACT_NO, data.contactNumber);
            setInt(USER_ID, data.id);
            setBool(REMEMBER_PASSWORD, isRemember);
            if (isRemember) {
              setString(EMAIL, email);
              setString(PASSWORD, password);
            } else {
              setString(PASSWORD, "");
              setString(EMAIL, '');
            }
            launchScreenWithNewTask(context, HomeScreen.tag);
          } else {
            toast(loginResponse.message.toString());
          }
        }).catchError((error) {
          print(error);
          toast(error.toString());
          showLoading(false);
        });
      } else {
        toast(keyString(context, "error_network_no_internet"));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    platfrom = Theme.of(context).platform == TargetPlatform.android
        ? "android"
        : Theme.of(context).platform == TargetPlatform.iOS ? "ios" : "other";
    changeStatusColor(Theme.of(context).scaffoldBackgroundColor);
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    /*back icon*/
                    SafeArea(
                      child: Container(
                        padding: EdgeInsets.only(left: spacing_control),
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ),
                    headerText(context, keyString(context, "lbl_sign_in"))
                        .paddingOnly(
                            left: 20,
                            top: spacing_standard_new,
                            bottom: spacing_standard_new),
                    Padding(
                      padding: EdgeInsets.only(top: 20, bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          text(context, keyString(context, "hint_email"),
                                  fontSize: ts_normal)
                              .paddingOnly(left: 20, right: 20),
                          Form(
                            key: _formKey,
                            autovalidate: _autoValidate,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                TextFormField(
                                  controller: emailController,
                                  cursorColor: Theme.of(context).primaryColor,
                                  maxLines: 1,
                                  focusNode: emailFocus,
                                  textInputAction: TextInputAction.next,

                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    return validateEMail(context, value);
                                  },
                                  onSaved: (String value) {
                                    email = value;
                                  },
                                  decoration: InputDecoration(
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .textTheme
                                              .title
                                              .color),
                                    ),
                                  ),
                                  style: TextStyle(
                                      fontSize: ts_normal,
                                      color: Theme.of(context)
                                          .textTheme
                                          .title
                                          .color,
                                      fontFamily: font_regular),
                                  onFieldSubmitted: (arg) {
                                    FocusScope.of(context).requestFocus(passFocus);
                                  },
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                text(context,
                                    keyString(context, "hint_password"),
                                    fontSize: ts_normal),
                                TextFormField(
                                    controller: passwordController,
                                    obscureText: passwordVisible,
                                    focusNode: passFocus,
                                    cursorColor: Theme.of(context).primaryColor,
                                    style: TextStyle(
                                        fontSize: ts_normal,
                                        color: Theme.of(context)
                                            .textTheme
                                            .title
                                            .color,
                                        fontFamily: font_regular),
                                    validator: (value) {
                                      return validatePassword(context, value);
                                    },
                                    onSaved: (String value) {
                                      password = value;
                                    },
                                    decoration: new InputDecoration(
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .textTheme
                                                .title
                                                .color),
                                      ),
                                      suffixIcon: new GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            passwordVisible = !passwordVisible;
                                          });
                                        },
                                        child: new Icon(
                                          passwordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color:
                                              Theme.of(context).iconTheme.color,
                                        ),
                                      ),
                                    )),
                              ],
                            ),
                          ).paddingOnly(left: 20, right: 20),
                          SizedBox(
                            height: 18,
                          ),
                          Row(
                            children: <Widget>[
                              Theme(
                                data: ThemeData(
                                    unselectedWidgetColor: Theme.of(context)
                                        .textTheme
                                        .title
                                        .color),
                                child: Checkbox(
                                  focusColor: Theme.of(context).primaryColor,
                                  activeColor: Theme.of(context).primaryColor,
                                  value: isRemember,
                                  onChanged: (bool value) {
                                    setState(() {
                                      isRemember = value;
                                    });
                                  },
                                ),
                              ),
                              Text(
                                keyString(context, "hint_remember_me"),
                                style: TextStyle(
                                    fontFamily: font_regular,
                                    fontSize: ts_normal,
                                    color: Theme.of(context)
                                        .textTheme
                                        .title
                                        .color),
                              )
                            ],
                          ).paddingLeft(spacing_standard),
                          SizedBox(
                            height: 50,
                          ),
                          AppButton(
                              textContent: keyString(context, "lbl_sign_in"),
                              onPressed: () {
                                if (isLoading) {
                                  return;
                                }
                                final form = _formKey.currentState;
                                if (form.validate()) {
                                  form.save();
                                  login(context);
                                } else {
                                  setState(() => _autoValidate = true);
                                }
                              }).paddingOnly(left: 20, right: 20),
                          SizedBox(
                            height: 16,
                          ),
                          GestureDetector(
                            child: Center(
                                child: text(context,
                                    keyString(context, "lbl_dont_have_account"),
                                    textColor:
                                        Theme.of(context).textTheme.title.color,
                                    fontFamily: font_medium,
                                    fontSize: ts_normal)),
                            onTap: () {
                              launchNewScreen(context, SignUp.tag);
                            },
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          GestureDetector(
                            child: Center(
                                child: text(context,
                                    keyString(context, "lbl_forgot_password"),
                                    textColor: Theme.of(context).primaryColor,
                                    fontFamily: font_medium,
                                    fontSize: ts_normal)),
                            onTap: () {
                              launchScreen(context, ForgotPassword.tag);
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Center(child: loadingWidgetMaker().visible(isLoading))
          ],
        ));
  }
}
