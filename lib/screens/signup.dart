import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:granth_flutter/models/response/register_response.dart';
import 'package:granth_flutter/network/rest_apis.dart';
import 'package:granth_flutter/utils/common.dart';
import 'package:granth_flutter/utils/constants.dart';
import 'package:granth_flutter/utils/resources/size.dart';
import 'package:granth_flutter/utils/widgets.dart';
import 'package:nb_utils/nb_utils.dart';

import '../app_localizations.dart';

class SignUp extends StatefulWidget {
  static var tag = "/SignUp";

  @override
  SignUpState createState() => SignUpState();
}

class SignUpState extends State<SignUp> {
  bool passwordVisible = false;
  bool isRemember = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _controller = new TextEditingController();
  bool _autoValidate = false;
  String email;
  String password;
  String contact;
  String name;
  String username;
  bool isLoading = false;
  FocusNode passFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode nameFocus = FocusNode();
  FocusNode userNameFocus = FocusNode();
  FocusNode confirmPassFocus = FocusNode();
  FocusNode contactFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    passwordVisible = true;
  }

  showLoading(bool show) {
    setState(() {
      isLoading = show;
    });
  }

  void signUp(BuildContext context) async {
    var request = {
/*
      'contact_number': contact,
*/
      'email': email,
      'name': name,
      'password': password,
      'username': username,
    };
    isNetworkAvailable().then((bool) {
      if (bool) {
        showLoading(true);
        register(request).then((result) {
          showLoading(false);
          RegisterResponse baseResponse = RegisterResponse.fromJson(result);
          if (baseResponse.status) {
            toast(baseResponse.message);
            finish(context);
          } else {
            toast(baseResponse.message);
          }
        }).catchError((error) {
          toast(error.toString());
          showLoading(false);
        });
      } else {
        toast(keyString(context, "error_network_no_internet"));
        showLoading(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    changeStatusColor(Theme.of(context).scaffoldBackgroundColor);
    var form = Form(
      key: _formKey,
      autovalidate: _autoValidate,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            cursorColor: Theme.of(context).primaryColor,
            validator: (value) {
              return value.isEmpty
                  ? keyString(context, "error_name_required")
                  : null;
            },
            onSaved: (String value) {
              name = value;
            },
            focusNode: nameFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (arg) {
              FocusScope.of(context).requestFocus(userNameFocus);
            },
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).textTheme.title.color),
              ),
              labelText: keyString(context, "hint_name"),
              labelStyle: TextStyle(
                  fontSize: ts_normal,
                  color: Theme.of(context).textTheme.title.color),
              contentPadding: new EdgeInsets.only(bottom: 2.0),
            ),
            style: TextStyle(
                fontSize: ts_normal,
                color: Theme.of(context).textTheme.title.color,
                fontFamily: font_regular),
          ),
          SizedBox(
            height: 20,
          ),
          TextFormField(
            cursorColor: Theme.of(context).primaryColor,
            maxLines: 1,
            validator: (value) {
              return value.isEmpty
                  ? keyString(context, "error_uname_required")
                  : null;
            },
            focusNode: userNameFocus,
            onSaved: (String value) {
              username = value;
            },
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (arg) {
              FocusScope.of(context).requestFocus(emailFocus);
            },
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).textTheme.title.color),
              ),
              labelText: keyString(context, "hint_username"),
              labelStyle: TextStyle(
                  fontSize: ts_normal,
                  color: Theme.of(context).textTheme.title.color),
              contentPadding: new EdgeInsets.only(bottom: 2.0),
            ),
            style: TextStyle(
                fontSize: ts_normal,
                color: Theme.of(context).textTheme.title.color,
                fontFamily: font_regular),
          ),
          SizedBox(
            height: 20,
          ),
          TextFormField(
            cursorColor: Theme.of(context).primaryColor,
            maxLines: 1,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              return validateEMail(context, value);
            },
            onSaved: (String value) {
              email = value;
            },
            textInputAction: TextInputAction.next,
            focusNode: emailFocus,
            onFieldSubmitted: (arg) {
              FocusScope.of(context).requestFocus(contactFocus);
            },
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).textTheme.title.color),
              ),
              labelText: keyString(context, "hint_email"),
              labelStyle: TextStyle(
                  fontSize: ts_normal,
                  color: Theme.of(context).textTheme.title.color),
              contentPadding: new EdgeInsets.only(bottom: 2.0),
            ),
            style: TextStyle(
                fontSize: ts_normal,
                color: Theme.of(context).textTheme.title.color,
                fontFamily: font_regular),
          ),
          SizedBox(
            height: 20,
          ),
          TextFormField(
            cursorColor: Theme.of(context).primaryColor,
            maxLines: 1,
            maxLength: 12,
            keyboardType: TextInputType.phone,
            validator: (value) {
              return value.isEmpty ? keyString(context, "error_mobile") : null;
            },
            focusNode: contactFocus,
            onSaved: (String value) {
              contact = value;
            },
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (arg) {
              FocusScope.of(context).requestFocus(passFocus);
            },
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).textTheme.title.color),
              ),
              labelText: keyString(context, "hint_contact_no"),
              counterText: "",
              labelStyle: TextStyle(
                  fontSize: ts_normal,
                  color: Theme.of(context).textTheme.title.color),
              contentPadding: new EdgeInsets.only(bottom: 2.0),
            ),
            style: TextStyle(
                fontSize: ts_normal,
                color: Theme.of(context).textTheme.title.color,
                fontFamily: font_regular),
          ),
          SizedBox(
            height: 20,
          ),
          TextFormField(
              controller: _controller,
              obscureText: passwordVisible,
              cursorColor: Theme.of(context).primaryColor,
              style: TextStyle(
                  fontSize: ts_normal,
                  color: Theme.of(context).textTheme.title.color,
                  fontFamily: font_regular),
              validator: (value) {
                return validatePassword(context, value);
              },
              focusNode: passFocus,
              onSaved: (String value) {
                password = value;
              },
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (arg) {
                FocusScope.of(context).requestFocus(confirmPassFocus);
              },
              decoration: new InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).textTheme.title.color),
                ),
                labelText: keyString(context, "hint_password"),
                labelStyle: TextStyle(
                    fontSize: ts_normal,
                    color: Theme.of(context).textTheme.title.color),
                contentPadding: new EdgeInsets.only(bottom: 2.0),
                suffixIcon: new GestureDetector(
                  onTap: () {
                    setState(() {
                      passwordVisible = !passwordVisible;
                    });
                  },
                  child: new Icon(
                      passwordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Theme.of(context).iconTheme.color),
                ),
              )),
          SizedBox(
            height: 20,
          ),
          TextFormField(
              obscureText: passwordVisible,
              cursorColor: Theme.of(context).primaryColor,
              style: TextStyle(
                  fontSize: ts_normal,
                  color: Theme.of(context).textTheme.title.color,
                  fontFamily: font_regular),
              focusNode: confirmPassFocus,
              validator: (value) {
                if (value.isEmpty) {
                  return keyString(context, "error_confirm_password_required");
                }
                return _controller.text == value
                    ? null
                    : keyString(context, "error_password_not_match");
              },
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (arg) {
                FocusScope.of(context).requestFocus(passFocus);
              },
              decoration: new InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).textTheme.title.color),
                ),
                labelText: keyString(context, "hint_confirm_password"),
                labelStyle: TextStyle(
                    fontSize: ts_normal,
                    color: Theme.of(context).textTheme.title.color),
                contentPadding:
                    EdgeInsets.only(bottom: 2.0, top: spacing_control),
                suffixIcon: new GestureDetector(
                  onTap: () {
                    setState(() {
                      passwordVisible = !passwordVisible;
                    });
                  },
                  child: new Icon(
                    passwordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
              )),
        ],
      ),
    ).paddingOnly(left: 20, right: 20);
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Container(
                child: Column(
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
                    headerText(context, keyString(context, "lbl_sign_up"))
                        .paddingOnly(
                            left: 20,
                            top: spacing_standard_new,
                            bottom: spacing_standard_new),
                    Padding(
                      padding:
                          EdgeInsets.only(top: spacing_control, bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          form,
                          SizedBox(
                            height: 50,
                          ),
                          AppButton(
                              textContent: keyString(context, "lbl_sign_up"),
                              onPressed: () {
                                final form = _formKey.currentState;
                                if (form.validate()) {
                                  form.save();
                                  signUp(context);
                                } else {
                                  setState(() => _autoValidate = true);
                                }
                              }).paddingOnly(left: 20, right: 20),
                          SizedBox(
                            height: 16,
                          ),
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
