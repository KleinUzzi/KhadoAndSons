import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:granth_flutter/models/response/base_response.dart';
import 'package:granth_flutter/network/rest_apis.dart';
import 'package:granth_flutter/screens/signIn.dart';
import 'package:granth_flutter/utils/common.dart';
import 'package:granth_flutter/utils/constants.dart';
import 'package:granth_flutter/utils/resources/colors.dart';
import 'package:granth_flutter/utils/resources/size.dart';
import 'package:granth_flutter/utils/widgets.dart';
import 'package:nb_utils/nb_utils.dart';

import '../app_localizations.dart';

class UpdatePassword extends StatefulWidget {
  static var tag = "/UpdatePassword";
  var email="";
  UpdatePassword({this.email});
  @override
  UpdatePasswordState createState() => UpdatePasswordState();
}

class UpdatePasswordState extends State<UpdatePassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  String newPassword;
  bool passwordVisible = true;
  TextEditingController _controller = new TextEditingController();


  @override
  void initState() {
    super.initState();
  }


  bool isLoading = false;

  showLoading(bool show) {
    setState(() {
      isLoading = show;
    });
  }

  void forgotPassword(BuildContext context) async {
    isNetworkAvailable().then((bool) {
      if (bool) {
        var request = {
          "email": widget.email,
          "password":newPassword
        };
        showLoading(true);
        updatePassword(request).then((result) {
          showLoading(false);
          BaseResponse response = BaseResponse.fromJson(result);
          if (response.status) {
           launchScreenWithNewTask(context, SignIn.tag);
          } else {
            toast(response.message);
          }
        }).catchError((error) {
          showLoading(false);
          toast(error.toString());
        });
      } else {
        toast(keyString(context,"error_network_no_internet"));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        height: 50,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ),
                    headerText(context,keyString(context,"lbl_change_password")).paddingOnly(
                        left: 20,
                        top: spacing_standard_new,
                        bottom: spacing_standard_new),
                    Padding(
                      padding: EdgeInsets.only(top: 20, bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[

                          Form(
                            key: _formKey,
                            autovalidate: _autoValidate,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                TextFormField(
                                    controller: _controller,
                                    obscureText: passwordVisible,
                                    cursorColor: Theme.of(context).textTheme.title.color,
                                    style: TextStyle(
                                        fontSize: ts_normal,
                                        color: Theme.of(context).textTheme.title.color,
                                        fontFamily: font_regular),
                                    validator: (value){
                                      return validatePassword(context,value);
                                    },
                                    onSaved: (String value) {
                                      newPassword = value;
                                    },
                                    decoration: new InputDecoration(
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Theme.of(context).textTheme.title.color),
                                      ),
                                      labelText: keyString(context,"hint_enter_your_new_password"),
                                      labelStyle: TextStyle(fontSize: ts_normal),
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
                                        return keyString(context,"error_confirm_password_required");
                                      }
                                      return _controller.text == value
                                          ? null
                                          : keyString(context,"error_password_not_match");
                                    },
                                    decoration: new InputDecoration(
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Theme.of(context).textTheme.title.color),
                                      ),
                                      labelText: keyString(context,"hint_confirm_your_new_password"),
                                      labelStyle: TextStyle(fontSize: ts_normal),
                                      contentPadding: EdgeInsets.only(
                                          bottom: 2.0, top: spacing_control),
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
                          ).paddingOnly(left: 20, right: 20),

                          SizedBox(
                            height: 50,
                          ),
                          AppButton(
                              textContent: keyString(context,"text_send_request"),
                              onPressed: () {
                                if (isLoading) {
                                  return;
                                }
                                final form = _formKey.currentState;
                                if (form.validate()) {
                                  form.save();
                                  forgotPassword(context);
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
