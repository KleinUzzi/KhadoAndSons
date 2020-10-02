import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:granth_flutter/models/response/book_detail.dart';
import 'package:granth_flutter/models/response/book_list.dart';
import 'package:granth_flutter/models/response/cart_response.dart';
import 'package:granth_flutter/models/response/downloaded_book.dart';
import 'package:granth_flutter/models/response/notification_payload.dart';
import 'package:granth_flutter/models/response/wishlist_response.dart';
import 'package:granth_flutter/network/common_api_calls.dart';
import 'package:granth_flutter/screens/book_description_screen.dart';
import 'package:granth_flutter/screens/pdf_screen.dart';
import 'package:granth_flutter/utils/constants.dart';
import 'package:granth_flutter/utils/epub_kitty.dart';
import 'package:granth_flutter/utils/resources/colors.dart';
import 'package:granth_flutter/utils/resources/images.dart';
import 'package:granth_flutter/utils/resources/size.dart';
import 'package:granth_flutter/utils/widgets.dart';
import 'package:html/parser.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:rating_bar/rating_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../app_localizations.dart';
import 'package:flutter_svg/svg.dart';

String parseHtmlString(String htmlString) {
  return parse(htmlString.validate()).body.text;
}
void launchScreenWithNewTask(context, String tag) {
  Navigator.pushNamedAndRemoveUntil(context, tag, (r) => false);
}

void launchScreen(context, String tag, {Object arguments}) {
  if (arguments == null) {
    Navigator.pushNamed(context, tag);
  } else {
    Navigator.pushNamed(context, tag, arguments: arguments);
  }
}

getPrimaryColor(context) {
  return Theme.of(context).primaryColor;
}

String capitalize(String s) {
  return s.substring(0, 1).toUpperCase() + s.substring(1).toLowerCase();
}

Color hexStringToHexInt(String hex) {
  hex = hex.replaceFirst('#', '');
  hex = hex.length == 6 ? 'ff' + hex : hex;
  int val = int.parse(hex, radix: 16);
  return Color(val);
}

String getThemeColor(String themeName) {
  return '#ffffff';
}

enum ConfirmAction { CANCEL, ACCEPT }

Future<ConfirmAction> showConfirmDialog(context) async {
  return showDialog<ConfirmAction>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Scaffold(
        backgroundColor: transparent,
        body: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width - 40,
                decoration: boxDecoration(context,
                    bgColor: Theme.of(context).cardTheme.color, showShadow: false, radius: spacing_middle),
                child: Column(
                  children: <Widget>[
                    text(context,keyString(context, "lbl_rateBook"),
                            fontSize: 24,
                            fontFamily: font_bold,
                            textColor: Theme.of(context).textTheme.title.color)
                        .paddingAll(spacing_middle),
                    Divider(
                      thickness: 0.5,
                    ),
                    RatingBar(
                      onRatingChanged: (v) {},
                      initialRating: 0.0,
                      emptyIcon: Icon(Icons.star).icon,
                      filledIcon: Icon(Icons.star).icon,
                      filledColor: Colors.yellow,
                      emptyColor: Colors.grey.withOpacity(0.5),
                      size: 40,
                    ).paddingAll(spacing_large),
                    TextFormField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 5,
                      style: TextStyle(
                          fontFamily: font_regular,
                          fontSize: ts_normal,
                          color: Theme.of(context).textTheme.title.color),
                      decoration: new InputDecoration(
                        hintText: 'Describe your experience',
                        border: InputBorder.none,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                        ),
                        filled: false,
                      ),
                    ).paddingOnly(left: spacing_large, right: spacing_large),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: MaterialButton(
                            textColor: Theme.of(context).textTheme.title.color,
                            child: text(context,keyString(context, "aRate_lbl_Cancel"),
                                fontSize: ts_normal, textColor: Theme.of(context).textTheme.title.color),
                            shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(5.0),
                              side: BorderSide(color: colorPrimary),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(ConfirmAction.CANCEL);
                            },
                          ).paddingOnly(right: spacing_standard),
                        ),
                        Expanded(
                          child: MaterialButton(
                            color: Theme.of(context).textTheme.title.color,
                            textColor: Colors.white,
                            child: text(context,keyString(context, "lbl_post"),
                                fontSize: ts_normal, textColor: white),
                            shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(5.0),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(ConfirmAction.ACCEPT);
                            },
                          ).paddingOnly(left: spacing_standard),
                        )
                      ],
                    ).paddingAll(spacing_large)
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

changeStatusColor(Color color) async {
  try {
    await FlutterStatusbarcolor.setStatusBarColor(color, animate: true);
    FlutterStatusbarcolor.setStatusBarWhiteForeground(
        useWhiteForeground(color));
  } on Exception catch (e) {
    print(e);
  }
}

Future<bool> isNetworkAvailable() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    return true;
  } else if (connectivityResult == ConnectivityResult.wifi) {
    return true;
  }
  return false;
}

Text headerText(BuildContext context,var text) {
  return Text(
    text,
    maxLines: 2,
    style:
        TextStyle(fontFamily: font_bold, fontSize: 28, color: Theme.of(context).textTheme.title.color),
  );
}

String validateEMail(context, String value) {
  if (value.isEmpty) {
    return keyString(context, "error_email_required");
  }
  return value.validateEmail()
      ? null
      : keyString(context, "error_invalid_email");
}

String validatePassword(context, String value) {
  return value.isEmpty ? keyString(context, "error_pwd_requires") : null;
}

Future<List<CartItem>> cartItems() async {
  var data = await getString(CART_DATA);
  if (data == null) {
    return List();
  }
  CartResponse response = CartResponse.fromJson(jsonDecode(data));
  return response.data;
}
Future<BookListResponse> libraryItems() async {
  var data = await getString(LIBRARY_DATA);
  if (data == null) {
    return BookListResponse();
  }
  BookListResponse response = BookListResponse.fromJson(jsonDecode(data));
  return response;
}
Future<List<WishListItem>> wishListItems() async {
  var data = await getString(WISH_LIST_DATA);
  if (data == null) {
    return List();
  }
  WishListResponse response = WishListResponse.fromJson(jsonDecode(data));
  return response.data;
}

Future<int> existInCart(bookId) async {
  var cartId = -1;
  List<CartItem> list = await cartItems();
  list.forEach((cartItem) {
    if (cartItem.book_id == bookId) {
      cartId = cartItem.cart_mapping_id;
    }
  });
  return cartId;
}

getPercentageRate(num amount, num percentage) {
  return (amount * percentage) / 100;
}

discountedPrice(num amount, num percentage) {
  return amount - getPercentageRate(amount, percentage);
}

num tryParse(var input) {
  return _isNumeric(input)?int.tryParse(input.toString().trim()) ?? double.tryParse(input.toString().trim()):null;
}
bool _isNumeric(var str) {
  return str == null? false:double.tryParse(str.toString()) != null;
}
Future<ConfirmAction> showAlertDialog(context, message,
    {title = 'Confirmation'}) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
// return object of type Dialog
      return Theme(
        data: ThemeData(
          canvasColor: Theme.of(context).scaffoldBackgroundColor
        ),
        child: AlertDialog(
          title:  headingText(context,title),
          content:  text(context,message,fontSize: ts_medium),
          backgroundColor:Theme.of(context).scaffoldBackgroundColor ,
          actions: <Widget>[
// usually buttons at the bottom of the dialog
            new FlatButton(
              child:  text(context,"Cancel",fontFamily: font_medium,textColor: Theme.of(context).primaryColor),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.CANCEL);
              },
            ),
            new FlatButton(
              child:  text(context,"OK",fontFamily: font_medium,textColor: Theme.of(context).primaryColor),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.ACCEPT);
              },
            )
          ],
        ),
      );
    },
  );
}

Future<String> get localPath async {
  Directory directory;
  if (Platform.isAndroid) {
    directory = await getExternalStorageDirectory();
  } else if (Platform.isIOS) {
    directory = await getApplicationDocumentsDirectory();
  } else {
    throw "Unsupported platform";
  }
  print(directory.path);
  return directory.absolute.path;
}

Future<String> requestDownload(
    {BuildContext context, DownloadedBook downloadTask, bool isSample}) async {
  String path = await localPath;
  var url = downloadTask.mDownloadTask.url;
  var fileName = getFileName(url, isSample, downloadTask.bookId);
  final savedDir = Directory(path);
  bool hasExisted = await savedDir.exists();
  if (!hasExisted) {
    savedDir.create();
  }
  return await FlutterDownloader.enqueue(
    url: url,
    fileName: fileName,
    savedDir: path,
    showNotification: true,
    openFileFromNotification: false,
  );
}

void cancelDownload(taskId) async {
  await FlutterDownloader.cancel(taskId: taskId);
}

void pauseDownload(taskId) async {
  await FlutterDownloader.pause(taskId: taskId);
}

Future<String> resumeDownload(taskId) async {
  return await FlutterDownloader.resume(taskId: taskId);
}

Future<String> retryDownload(taskId) async {
  return await FlutterDownloader.retry(taskId: taskId);
}

Future<Null> delete(taskId) async {
  return await FlutterDownloader.remove(
      taskId: taskId, shouldDeleteContent: true);
}

Future<String> _findLocalPath(BuildContext context, bool isSample) async {
  final directory = Theme.of(context).platform == TargetPlatform.android
      ? await getExternalStorageDirectory()
      : await getApplicationDocumentsDirectory();
  return directory.path;
}

String getFileName(String path, bool isSample, String bookId) {
  var name = path.split("/");
  String fileNameNew = path;
  if (name.length > 0) {
    fileNameNew = name[name.length - 1];
  }
  fileNameNew = fileNameNew.replaceAll("%", "");
  return isSample
      ? bookId + "_sample_" + fileNameNew
      : bookId + "_purchased_" + fileNameNew;
}

readFile(context, String filePath, String name) async{
  String path = await localPath;
  filePath=path + "/" +filePath;
  print(filePath);
  filePath=filePath.replaceAll("null/", "");
  if (filePath.contains(".pdf")) {
    Navigator.push(context,MaterialPageRoute(builder: (context) => PDFScreen(filePath, name)));
  } else if (filePath.contains(".epub")) {
    if(Platform.isAndroid) {
      EpubKitty.setConfig("book", '#${Theme.of(context).primaryColor.value.toRadixString(16)}', "vertical", true);
      EpubKitty.open(filePath);
    }else if(Platform.isIOS) {
      EpubKitty.open(filePath);
    }else {

    }
  } else if (filePath.contains(".mp4")) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => VideoApp(filePath)));
  }
}

void redirectUrl(url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    toast('Please check URL');
    throw 'Could not launch $url';
  }
}

Future<bool> checkPermission(context) async {
  if (Theme.of(context).platform == TargetPlatform.android) {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (permission != PermissionStatus.granted) {
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.storage]);
      if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
        return true;
      }
    } else {
      return true;
    }
  } else {
    return true;
  }
  return false;
}

Future<bool> checkRecordAudioPermission(context) async {
  if (Theme.of(context).platform == TargetPlatform.android) {
    PermissionStatus permission =
        await PermissionHandler().checkPermissionStatus(PermissionGroup.speech);
    if (permission != PermissionStatus.granted) {
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.speech]);
      if (permissions[PermissionGroup.speech] == PermissionStatus.granted) {
        return true;
      }
    } else {
      return true;
    }
  } else {
    return true;
  }
  return false;
}

Future<void> initOneSingalPlatformState(BuildContext context) async {
  var settings = {
    OSiOSSettings.autoPrompt: false,
    OSiOSSettings.promptBeforeOpeningPushUrl: true
  };

  OneSignal.shared
      .setNotificationReceivedHandler((OSNotification notification) {
    print(
        "Received notification: \n${notification.jsonRepresentation().replaceAll("\\n", "\n")}");
  });

  OneSignal.shared
      .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
    print(
        "Opened notification: \n${result.notification.jsonRepresentation().replaceAll("\\n", "\n")}");
    var data = result.notification.payload.additionalData;
    if (data != null) {
      var payload = NotificationPayload.fromJson(data);
      onReadNotification(payload.notificationId);
      if (payload.type != null && payload.type.toString().isNotEmpty) {
        if (payload.type == "book_added") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BookDescriptionScreen(
                      bookDetail: BookDetail(bookId: payload.bookId))));
        }
      }
    }
  });
  var onesignalid = await getString(ONESIGNAL_API_KEY);

  await OneSignal.shared.init(onesignalid, iOSSettings: settings);

  OneSignal.shared
      .setInFocusDisplayType(OSNotificationDisplayType.notification);
}


showTransactionDialog(context,isSuccess){
  showDialog(
    context: context,
    builder: (BuildContext context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
          decoration: boxDecoration(context,
              bgColor: Theme.of(context).cardTheme.color, showShadow: false, radius: spacing_middle),
          width: MediaQuery.of(context).size.width-40,
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              GestureDetector(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Container(
                    padding: EdgeInsets.all(16),
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.close, color: Theme.of(context).iconTheme.color)),
              ),
              text(context,isSuccess?"SUCCESSFUL":"UNSUCCESSFUL",textColor: isSuccess?Colors.green:Theme.of(context).errorColor,
                  fontFamily: font_bold,
                  fontSize: ts_large),
              SizedBox(height: 16),
              SvgPicture.asset(
                ic_pay_1,
                color: isSuccess?Colors.green:Theme.of(context).errorColor,
                width: 90,
                height: 90,
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: text(context,isSuccess?"Your payment is apporved":"Your payment is declined",textColor: Theme.of(context).textTheme.title.color,
                    fontSize: ts_extra_normal, maxLine: 2, isCentered: true,fontFamily: font_bold),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: text(context,"Plese refer transaction history for more detail",textColor: Theme.of(context).textTheme.title.color,
                    fontSize: ts_normal, maxLine: 2, isCentered: true),
              ),
              SizedBox(height: 16),
              MaterialButton(
                child: text(context,"OK", textColor: white, fontSize: ts_normal, fontFamily: font_medium),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(spacing_control))),
                elevation: 5.0,
                minWidth: 150,
                height: 40,
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  finish(context);
                },
              ),
              SizedBox(height: 16,)
            ],
          )),
    ),
  );
}