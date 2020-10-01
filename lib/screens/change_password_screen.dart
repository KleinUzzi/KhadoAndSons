import 'package:flutter/material.dart';
import 'package:KhadoAndSons/models/response/base_response.dart';
import 'package:KhadoAndSons/utils/common.dart';
import 'package:KhadoAndSons/utils/constants.dart';
import 'package:KhadoAndSons/utils/resources/colors.dart';
import 'package:KhadoAndSons/utils/resources/size.dart';
import 'package:KhadoAndSons/utils/widgets.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:KhadoAndSons/network/rest_apis.dart';

import '../app_localizations.dart';

class ChangePasswordScreen extends StatefulWidget {
  static String tag = '/ChangePasswordScreen';

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isRemember = false;
  bool passwordVisible = true;
  TextEditingController _controller = new TextEditingController();
  bool _autoValidate = false;
  String oldPassword;
  String newPassword;
  bool isLoading = false;
  FocusNode oldPassFocus = FocusNode();
  FocusNode newPassFocus = FocusNode();
  FocusNode confirmPassFocus = FocusNode();
  showLoading(bool show) {
    setState(() {
      isLoading = show;
    });
  }

  changePassword(context) async {
    var email = await getString(USER_EMAIL);
    var request = {
      'email': email,
      'old_password': oldPassword,
      'new_password': newPassword
    };
    isNetworkAvailable().then((bool) {
      if (bool) {
        showLoading(true);
        changeUserPassword(request).then((result) {
          BaseResponse response = BaseResponse.fromJson(result);
          toast(response.message.toString());
          showLoading(false);
          if (response.status) {
            finish(context);
          }
        }).catchError((error) {
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
    var form = Form(
      key: _formKey,
      autovalidate: _autoValidate,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
              obscureText: passwordVisible,
              cursorColor: Theme.of(context).textTheme.title.color,
              style: TextStyle(
                  fontSize: ts_normal,
                  color: Theme.of(context).textTheme.title.color,
                  fontFamily: font_regular),
              validator: (value) {
                return validatePassword(context, value);
              },
              onSaved: (String value) {
                oldPassword = value;
              },
              focusNode: oldPassFocus,
              onFieldSubmitted: (arg) {
                FocusScope.of(context).requestFocus(newPassFocus);
              },
              textInputAction: TextInputAction.next,
              decoration: new InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).textTheme.title.color),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).textTheme.title.color),
                ),
                labelStyle: TextStyle(
                    fontSize: ts_normal,
                    color: Theme.of(context).textTheme.title.color),
                labelText: keyString(context, "label_enter_old_password"),
                contentPadding: new EdgeInsets.only(bottom: 2.0),
                suffixIcon: new GestureDetector(
                  onTap: () {
                    setState(() {
                      passwordVisible = !passwordVisible;
                    });
                  },
                  child: new Icon(passwordVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
                ),
              )),
          SizedBox(
            height: 25,
          ),
          TextFormField(
              controller: _controller,
              obscureText: passwordVisible,
              cursorColor: Theme.of(context).textTheme.title.color,
              style: TextStyle(
                  fontSize: ts_normal,
                  color: Theme.of(context).textTheme.title.color,
                  fontFamily: font_regular),
              validator: (value) {
                return validatePassword(context, value);
              },
              onSaved: (String value) {
                newPassword = value;
              },
              focusNode: newPassFocus,
              onFieldSubmitted: (arg) {
                FocusScope.of(context).requestFocus(confirmPassFocus);
              },
              textInputAction: TextInputAction.next,
              decoration: new InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).textTheme.title.color),
                ),
                labelStyle: TextStyle(
                    fontSize: ts_normal,
                    color: Theme.of(context).textTheme.title.color),
                labelText: keyString(context, "hint_enter_your_new_password"),
                contentPadding: new EdgeInsets.only(bottom: 2.0),
                suffixIcon: new GestureDetector(
                  onTap: () {
                    setState(() {
                      passwordVisible = !passwordVisible;
                    });
                  },
                  child: new Icon(passwordVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
                ),
              )),
          SizedBox(
            height: 25,
          ),
          TextFormField(
              obscureText: passwordVisible,
              cursorColor: Theme.of(context).textTheme.title.color,
              style: TextStyle(
                  fontSize: ts_normal,
                  color: Theme.of(context).textTheme.title.color,
                  fontFamily: font_regular),
              validator: (value) {
                if (value.isEmpty) {
                  return keyString(context, "error_confirm_password_required");
                }
                return _controller.text == value
                    ? null
                    : keyString(context, "error_password_not_match");
              },
              focusNode: confirmPassFocus,
              decoration: new InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).textTheme.title.color),
                ),
                labelStyle: TextStyle(
                    fontSize: ts_normal,
                    color: Theme.of(context).textTheme.title.color),
                labelText: keyString(context, "hint_confirm_your_new_password"),
                contentPadding:
                    EdgeInsets.only(bottom: 2.0, top: spacing_control),
                suffixIcon: new GestureDetector(
                  onTap: () {
                    setState(() {
                      passwordVisible = !passwordVisible;
                    });
                  },
                  child: new Icon(passwordVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
                ),
              )),
        ],
      ),
    ).paddingOnly(left: 25, right: 25);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
        centerTitle: true,
        iconTheme: Theme.of(context).iconTheme,
        title: headingText(context, keyString(context, "lbl_change_password")),
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(top: 25, bottom: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  form,
                  SizedBox(
                    height: 50,
                  ),
                  AppButton(
                      textContent: keyString(context, "lbl_change_password"),
                      onPressed: () {
                        final form = _formKey.currentState;
                        if (form.validate()) {
                          form.save();
                          changePassword(context);
                        } else {
                          setState(() => _autoValidate = true);
                        }
                      }).paddingOnly(left: 25, right: 25),
                  SizedBox(
                    height: 16,
                  ),
                ],
              ),
            ),
          ),
          Center(child: loadingWidgetMaker().visible(isLoading))
        ],
      ),
    );
  }
}
