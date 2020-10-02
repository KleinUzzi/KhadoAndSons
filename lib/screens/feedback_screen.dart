import 'package:flutter/material.dart';
import 'package:granth_flutter/models/response/base_response.dart';
import 'package:granth_flutter/network/rest_apis.dart';
import 'package:granth_flutter/utils/common.dart';
import 'package:granth_flutter/utils/constants.dart';
import 'package:granth_flutter/utils/resources/colors.dart';
import 'package:granth_flutter/utils/resources/size.dart';
import 'package:granth_flutter/utils/widgets.dart';
import 'package:nb_utils/nb_utils.dart';

import '../app_localizations.dart';

class FeedbackScreen extends StatefulWidget {
  static String tag = '/FeedbackScreen';

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>
    with AfterLayoutMixin<FeedbackScreen> {
  bool passwordVisible = false;
  bool isRemember = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  bool _autoValidate = false;
  String email;
  String message;
  String name;
  bool isLoading = false;
  FocusNode nameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode messagesFocus = FocusNode();
  showLoading(bool show) {
    setState(() {
      isLoading = show;
    });
  }

  feedBack(context) async {
    if(isLoading){
      return;
    }
    var email = await getString(USER_EMAIL);
    isNetworkAvailable().then((bool) {
      if (bool) {
        showLoading(true);
        var request = {'email': email, 'name': name, 'comment': message};
        addFeedback(request).then((result) {
          BaseResponse response = BaseResponse.fromJson(result);
          toast(response.message.toString());
          showLoading(false);

          if (response.status) {
            finish(context);
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
  void initState() {
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    var mail = await getString(USER_EMAIL);
    var username = await getString(USERNAME);
    setState(() {
      email = mail;
      name = username;
      emailController.text = mail;
      nameController.text = username;
    });
  }

  @override
  Widget build(BuildContext context) {
    var form=  Form(
      key: _formKey,
      autovalidate: _autoValidate,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: nameController,
            cursorColor: Theme.of(context).textTheme.title.color,
            validator: (value) {
              return value.isEmpty ? keyString(context,"error_name_required") : null;
            },
            onSaved: (String value) {
              name = value;
            },
            focusNode: nameFocus,
            onFieldSubmitted:  (arg) {
              FocusScope.of(context).requestFocus(emailFocus);
            },
            textInputAction: TextInputAction.next,

            decoration: InputDecoration(
              labelText: keyString(context,"hint_name"),
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
              contentPadding: EdgeInsets.only(bottom: 2.0, top: spacing_control),
            ),
            style: TextStyle(
                fontSize: ts_normal,
                color: Theme.of(context).textTheme.title.color,
                fontFamily: font_regular),
          ),
          SizedBox(
            height: 25,
          ),
          TextFormField(
            controller: emailController,
            cursorColor: Theme.of(context).textTheme.title.color,
            maxLines: 1,
            keyboardType: TextInputType.emailAddress,
            validator: (value){
              return validateEMail(context,value);
            },
            onSaved: (String value) {
              email = value;
            },
            focusNode: emailFocus,
            onFieldSubmitted:  (arg) {
              FocusScope.of(context).requestFocus(messagesFocus);
            },
            textInputAction: TextInputAction.next,

            decoration: InputDecoration(
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
              contentPadding: EdgeInsets.only(bottom: 2.0, top: spacing_control),
              labelText: keyString(context,"hint_email"),
            ),
            style: TextStyle(
                fontSize: ts_normal,
                color: Theme.of(context).textTheme.title.color,
                fontFamily: font_regular),
          ),
          SizedBox(
            height: 25,
          ),
          TextFormField(
            cursorColor: Theme.of(context).textTheme.title.color,
            maxLines: 1,
            keyboardType: TextInputType.multiline,
            validator: (value) {
              return value.isEmpty ? keyString(context,"error_name_required") : null;
            },
            onSaved: (String value) {
              message = value;
            },
            textInputAction: TextInputAction.next,
            focusNode: messagesFocus,
            decoration: InputDecoration(

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
              contentPadding: EdgeInsets.only(bottom: 2.0, top: spacing_control),
              labelText: keyString(context,"hint_message"),
            ),
            style: TextStyle(
                fontSize: ts_normal,
                color: Theme.of(context).textTheme.title.color,
                fontFamily: font_regular),
          ),
        ],
      ),
    ).paddingOnly(left: 25, right: 25);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
        centerTitle: true,
        iconTheme: Theme.of(context).iconTheme,
        title: headingText(context,keyString(context,"lbl_feedback")),
      ),
      body: SingleChildScrollView(
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
                  textContent: keyString(context,"lbl_submit"),
                  onPressed: () {
                    final form = _formKey.currentState;
                    if (form.validate()) {
                      form.save();
                      feedBack(context);
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
    );
  }
}
