
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:granth_flutter/models/response/base_response.dart';
import 'package:granth_flutter/network/rest_apis.dart';
import 'package:granth_flutter/screens/update_password.dart';
import 'package:granth_flutter/utils/common.dart';
import 'package:granth_flutter/utils/constants.dart';
import 'package:granth_flutter/utils/resources/colors.dart';
import 'package:granth_flutter/utils/resources/size.dart';
import 'package:granth_flutter/utils/widgets.dart';
import 'package:nb_utils/nb_utils.dart';

import '../app_localizations.dart';

class VerifyOTPScreen extends StatefulWidget {
  static var tag = "/VerifyOTP";
  var email;
  VerifyOTPScreen({this.email});

  @override
  VerifyOTPScreenState createState() => VerifyOTPScreenState();
}

class VerifyOTPScreenState extends State<VerifyOTPScreen> {

  var otp;
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

  void verifyOTP(BuildContext context) async {
    if (isLoading) {
      return;
    }
   isNetworkAvailable().then((bool) {
         if(bool){
           var request = {
             "email": widget.email,
             "code": otp
           };
           showLoading(true);
           verifyToken(request).then((result){
             showLoading(false);
             BaseResponse response = BaseResponse.fromJson(result);
             toast(response.message);
             if(response.status){
               Navigator.push(context, MaterialPageRoute(builder: (context) => UpdatePassword(email: widget.email)));
             }

           }).catchError((error) {
             toast(error.toString());
             showLoading(false);

           });
         }else{
           toast(keyString(context,"error_network_no_internet"));
         }
       });
  }
  void resendOTP(BuildContext context) async {
    if (isLoading) {
      return;
    }
    isNetworkAvailable().then((bool) {
      if(bool){
        var request = {
          "email": widget.email,
        };
        showLoading(true);
        resendOtp(request).then((result){
          showLoading(false);
          BaseResponse response = BaseResponse.fromJson(result);
          toast(response.message);

        }).catchError((error) {
          toast(error.toString());
          showLoading(false);

        });
      }else{
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
                    headerText(context,keyString(context,"lbl_verification")).paddingOnly(
                        left: 20,
                        top: spacing_standard_new,
                        bottom: spacing_standard_new),
                    text(context,keyString(context,"note_verification"),isLongText: true,fontSize: ts_normal).paddingOnly(
                        left: 20,right: 20,
                        bottom: spacing_standard_new),
                    Padding(
                      padding: EdgeInsets.only(top: 20, bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[

                          PinEntryTextField(
                            onSubmit: (String pin){
                              otp=pin;
                            },
                            fields: 4,
                            fontSize: ts_large,
                          ).paddingOnly(left: 20,right: 20),
                         
                          SizedBox(
                            height: 50,
                          ),
                          AppButton(
                              textContent: keyString(context,"lbl_verify"),
                              onPressed: () {
                                if (isLoading) {
                                  return;
                                }
                                if(otp.toString().isEmpty && otp.toString().length<4){
                                  toast(keyString(context,"error_otp"));
                                }
                               verifyOTP(context);
                              }).paddingOnly(left: 20, right: 20),
                          SizedBox(
                            height: 16,
                          ),
                          GestureDetector(
                            onTap: (){
                              resendOTP(context);
                            },
                            child: Container(

                              padding: const EdgeInsets.only(top: 10,bottom: 10,right: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  text(context,keyString(context,"msg_resend_code"),fontSize: ts_normal),
                                  text(context,keyString(context,"lbl_resend_code"),fontSize: ts_normal,fontFamily: font_bold,textColor: Theme.of(context).textTheme.title.color).paddingLeft(spacing_control),
                                ],
                              ),
                            ),
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
