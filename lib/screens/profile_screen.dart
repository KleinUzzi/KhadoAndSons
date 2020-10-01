import 'package:flutter/material.dart';
import 'package:KhadoAndSons/network/rest_apis.dart';
import 'package:KhadoAndSons/utils/common.dart';
import 'package:KhadoAndSons/utils/constants.dart';
import 'package:KhadoAndSons/utils/resources/colors.dart';
import 'package:KhadoAndSons/utils/resources/images.dart';
import 'package:KhadoAndSons/utils/resources/size.dart';
import 'package:KhadoAndSons/utils/widgets.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker_gallery_camera/image_picker_gallery_camera.dart';

import '../app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  static String tag = '/ProfileScreen';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool passwordVisible = false;
  bool isRemember = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _userNameController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _contactController = new TextEditingController();
  bool _autoValidate = false;
  var contact;
  var name;
  var userProfile;
  var userName;
  var userEmail;
  var userId;
  File imageFile;
  bool isLoading = false;
  bool loadFromFile = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    var pref = await getSharedPref();
    setState(() {
      userId = pref.getInt(USER_ID);
      userProfile = pref.getString(USER_PROFILE) ?? '';
      userName = pref.getString(USERNAME) ?? '';
      userEmail = pref.getString(USER_EMAIL) ?? '';
      name = pref.getString(NAME) ?? '';
      contact = pref.getString(USER_CONTACT_NO) ?? '';
      _nameController.text = name;
      _userNameController.text = userName;
      _emailController.text = userEmail;
      _contactController.text = contact;
    });
  }

  showLoading(bool show) {
    setState(() {
      isLoading = show;
    });
  }

  Future getImage(ImgSource source) async {
    var image = await ImagePickerGC.pickImage(
      context: context,
      source: source,
      cameraIcon: Icon(
        Icons.add,
        color: Colors.red,
      ), //cameraIcon and galleryIcon can change. If no icon provided default icon will be present
    );
    if (image != null) {
      setState(() {
        imageFile = image;
        loadFromFile = true;
      });
    }
  }

  saveProfile(context) async {
    if (isLoading) {
      return;
    }
    isNetworkAvailable().then((bool) {
      if (bool) {
        var request = {
          "id": userId,
          "username": userName,
          "name": name,
          "email": userEmail,
          "dob": "",
          "contact_number": contact
        };
        showLoading(true);
        updateUser(request, imageFile).then((result) {
          print(result);
          showLoading(false);
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
    final profilePhoto = Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              elevation: spacing_standard_new,
              margin: EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              child: loadFromFile
                  ? Image.file(
                      imageFile,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    )
                  : userProfile != null && userProfile.toString().isNotEmpty
                      ? networkImage(
                          userProfile,
                          aHeight: 100,
                          aWidth: 100,
                        )
                      : Image.asset(ic_profile, width: 100, height: 100),
            ).onTap(() {
              getImage(ImgSource.Both);
            }),
            text(context, keyString(context, "lbl_change_photo"),
                    textColor: Theme.of(context).textTheme.button.color,
                    fontFamily: font_bold,
                    fontSize: ts_medium)
                .paddingTop(spacing_standard_new)
                .onTap(() {})
          ],
        ).paddingOnly(top: 16));

    final fields = Form(
      key: _formKey,
      autovalidate: _autoValidate,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: _nameController,
            cursorColor: Theme.of(context).textTheme.title.color,
            validator: (value) {
              return value.isEmpty
                  ? keyString(context, "error_name_required")
                  : null;
            },
            onSaved: (String value) {
              name = value;
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
                  fontFamily: font_medium,
                  color: textColorSecondary),
              contentPadding: new EdgeInsets.only(bottom: 2.0),
            ),
            style: TextStyle(
                fontSize: ts_normal,
                color: Theme.of(context).textTheme.title.color,
                fontFamily: font_semi_bold),
          ),
          SizedBox(
            height: 25,
          ),
          TextFormField(
            controller: _userNameController,
            cursorColor: Theme.of(context).textTheme.title.color,
            maxLines: 1,
            validator: (value) {
              return value.isEmpty
                  ? keyString(context, "error_uname_required")
                  : null;
            },
            onSaved: (String value) {
              userName = value;
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
                  fontFamily: font_medium,
                  color: textColorSecondary),
              contentPadding: new EdgeInsets.only(bottom: 2.0),
            ),
            style: TextStyle(
                fontSize: ts_normal,
                color: Theme.of(context).textTheme.title.color,
                fontFamily: font_semi_bold),
          ),
          SizedBox(
            height: 25,
          ),
          TextFormField(
            controller: _emailController,
            cursorColor: Theme.of(context).textTheme.title.color,
            maxLines: 1,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              return validateEMail(context, value);
            },
            onSaved: (String value) {
              userEmail = value;
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
                  fontFamily: font_medium,
                  color: textColorSecondary),
              contentPadding: new EdgeInsets.only(bottom: 2.0),
            ),
            style: TextStyle(
                fontSize: ts_normal,
                color: Theme.of(context).textTheme.title.color,
                fontFamily: font_semi_bold),
          ),
          SizedBox(
            height: 25,
          ),
          TextFormField(
            controller: _contactController,
            cursorColor: Theme.of(context).textTheme.title.color,
            maxLines: 1,
            maxLength: 12,
            keyboardType: TextInputType.phone,
            validator: (value) {
              return value.isEmpty ? keyString(context, "error_mobile") : null;
            },
            onSaved: (String value) {
              contact = value;
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
              labelStyle: TextStyle(
                  fontSize: ts_normal,
                  fontFamily: font_medium,
                  color: textColorSecondary),
              contentPadding: new EdgeInsets.only(bottom: 2.0),
            ),
            style: TextStyle(
                fontSize: ts_normal,
                color: Theme.of(context).textTheme.title.color,
                fontFamily: font_semi_bold),
          ),
        ],
      ),
    ).paddingOnly(left: 18, right: 18, top: 30);

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: Theme.of(context).iconTheme,
        centerTitle: true,
        title: headingText(
          context,
          keyString(context, "guide_lbl_profile_edit"),
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                profilePhoto,
                fields,
                AppButton(
                  textContent: keyString(context, "lbl_save"),
                  onPressed: () {
                    if (isLoading) {
                      return;
                    }
                    final form = _formKey.currentState;
                    if (form.validate()) {
                      form.save();
                      saveProfile(context);
                    } else {
                      setState(() => _autoValidate = true);
                    }
                  },
                ).paddingOnly(top: 30, left: 18, right: 18, bottom: 30)
              ],
            ),
          ),
          loadingWidgetMaker().visible(isLoading)
        ],
      ),
    );
  }
}
