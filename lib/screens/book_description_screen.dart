import 'dart:isolate';
import 'dart:ui';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_svg/svg.dart';
import 'package:granth_flutter/models/response/author.dart';
import 'package:granth_flutter/models/response/base_response.dart';
import 'package:granth_flutter/models/response/book_description.dart';
import 'package:granth_flutter/models/response/book_detail.dart';
import 'package:granth_flutter/models/response/book_rating.dart';
import 'package:granth_flutter/models/response/downloaded_book.dart';
import 'package:granth_flutter/network/common_api_calls.dart';
import 'package:granth_flutter/network/rest_apis.dart';
import 'package:granth_flutter/screens/book_reviews.dart';
import 'package:granth_flutter/screens/signIn.dart';
import 'package:granth_flutter/utils/admob_utils.dart';
import 'package:granth_flutter/utils/common.dart';
import 'package:granth_flutter/utils/constants.dart';
import 'package:granth_flutter/utils/database_helper.dart';
import 'package:granth_flutter/utils/resources/colors.dart';
import 'package:granth_flutter/utils/resources/images.dart';
import 'package:granth_flutter/utils/resources/size.dart';
import 'package:granth_flutter/utils/resources/strings.dart';
import 'package:granth_flutter/utils/widgets.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:rating_bar/rating_bar.dart';
import 'package:share/share.dart';
import '../app_localizations.dart';
import 'author_detail_screen.dart';

class BookDescriptionScreen extends StatefulWidget {
  static String tag = '/BookDetailScreen';
  BookDetail bookDetail;

  BookDescriptionScreen({Key key, this.bookDetail}) : super(key: key);

  @override
  _BookDescriptionScreenState createState() => _BookDescriptionScreenState();
}

class _BookDescriptionScreenState extends State<BookDescriptionScreen>
    with AfterLayoutMixin<BookDescriptionScreen> {
  double rating = 0.0;
  GlobalKey btnPopupMenu = GlobalKey();
  var mIsFirstTime = true;
  final dbHelper = DatabaseHelper.instance;
  BookDescription description;
  BookDetail mBookDetail;
  AuthorDetail mAuthorDetail;
  BookRating userReviewData;
  List<BookRating> bookRating = List<BookRating>();
  TextEditingController controller = TextEditingController();
  var isExpanded = false;
  var cartCount = 0;
  var isExistInCart = false;
  int id;
  bool isUserLoggedIn = false;
  var username = '';
  ReceivePort _port = ReceivePort();
  DownloadedBook mSampleDownloadTask;
  DownloadedBook mBookDownloadTask;
  bool isLoading = false;
  bool isBookDownloading = false;
  bool isSampleDownloading = false;
  var _permissionReady;
  bool _autoValidate = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  InterstitialAd _interstitialAd;
  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    childDirected: true,
    nonPersonalizedAds: true,
  );
  BannerAd _bannerAd;

  @override
  void initState() {
    super.initState();
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
    _bannerAd = createBannerAd();
    _bannerAd
      ..load()
      ..show();
    _interstitialAd = createInterstitialAd()..load();
    _interstitialAd.show();
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    if (mIsFirstTime) {
      id = await getInt(USER_ID);
      isUserLoggedIn = await getBool(IS_LOGGED_IN) ?? false;
      username = await getString(USERNAME) ?? "";
      fetchBookDetail();
      _permissionReady = await checkPermission(context);

      if (isUserLoggedIn) {
        isExistInCart = await existInCart(widget.bookDetail.bookId) != -1;
        cartCount = await getInt(CART_COUNT) ?? 0;
        LiveStream().on(CART_COUNT_ACTION, (value) async {
          if (mounted) {
            var exist = await existInCart(widget.bookDetail.bookId);
            setState(() {
              cartCount = value;
              isExistInCart = exist != -1;
            });
          }
        });
      }
      mIsFirstTime = false;
    }
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    _bannerAd?.dispose();

    super.dispose();
  }

  showLoading(bool show) {
    setState(() {
      isLoading = show;
    });
  }

  fetchBookDetail() async {
    showLoading(true);
    if (widget.bookDetail != null) {
      isNetworkAvailable().then((bool) async {
        if (bool) {
          var request = {"book_id": widget.bookDetail.bookId, "user_id": id};
          await getBookDetail(request).then((res) {
            print(res);
            showLoading(false);
            setState(() {
              description = BookDescription.fromJson(res);
              mBookDetail = description.bookDetail[0];
              if (mBookDetail != null) {
                loadBookFromOffline();
              }
              mAuthorDetail = description.authorDetail[0];
              bookRating.clear();
              bookRating.addAll(description.bookRatingData);
              userReviewData = description.userReviewData;
              if (userReviewData != null) {
                userReviewData.userName = username;
              }
            });
          }).catchError((error) {
            print(error.toString());
            showLoading(false);
          });
        } else {
          toast(error_network_no_internet);
          finish(context);
        }
      });
    }
  }

  void loadBookFromOffline() async {
    if (mBookDetail != null) {
      DownloadedBook sampleBook;
      DownloadedBook purchaseBook;
      var sampleTask;
      var purchaseTask;
      List<DownloadedBook> list =
          await dbHelper.queryRowBook(mBookDetail.bookId.toString());
      List<DownloadTask> tasks = await FlutterDownloader.loadTasks();
      if (list != null && list.isNotEmpty) {
        list.forEach((book) {
          if (book.fileType == "sample") {
            sampleBook = book;
            sampleTask =
                tasks?.firstWhere((task) => task.taskId == book.taskId);
          }
          if (book.fileType == "purchased") {
            purchaseBook = book;
            purchaseTask =
                tasks?.firstWhere((task) => task.taskId == book.taskId);
          }
        });
      }
      if (sampleTask == null) {
        sampleTask = defaultTask(mBookDetail.fileSamplePath);
      }

      if (purchaseTask == null) {
        purchaseTask = defaultTask(mBookDetail.filePath);
      }
      if (sampleBook == null) {
        sampleBook = defaultBook(mBookDetail, "sample");
      }
      if (purchaseBook == null) {
        purchaseBook = defaultBook(mBookDetail, "purchased");
      }
      sampleBook.mDownloadTask = sampleTask;
      sampleBook.status = sampleTask.status;
      purchaseBook.mDownloadTask = purchaseTask;
      purchaseBook.status = purchaseTask.status;
      setState(() {
        mSampleDownloadTask = sampleBook;
        mBookDownloadTask = purchaseBook;
      });
    }
  }

  void showRatingDialog(BuildContext context) {
    showDialog<ConfirmAction>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Scaffold(
          backgroundColor: transparent,
          body: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width - 40,
                    decoration: boxDecoration(context,
                        bgColor: Theme.of(context).cardTheme.color,
                        showShadow: false,
                        radius: spacing_middle),
                    child: Column(
                      children: <Widget>[
                        text(context, keyString(context, "lbl_rateBook"),
                                fontSize: 24,
                                fontFamily: font_bold,
                                textColor:
                                    Theme.of(context).textTheme.title.color)
                            .paddingAll(spacing_middle),
                        Divider(
                          thickness: 0.5,
                        ),
                        RatingBar(
                          onRatingChanged: (v) {
                            setState(() {
                              rating = v;
                            });
                          },
                          initialRating: rating,
                          emptyIcon: Icon(Icons.star).icon,
                          filledIcon: Icon(Icons.star).icon,
                          filledColor: Colors.amber,
                          emptyColor: Colors.grey.withOpacity(0.5),
                          size: 40,
                        ).paddingAll(spacing_large),
                        Form(
                          key: _formKey,
                          autovalidate: _autoValidate,
                          child: TextFormField(
                            controller: controller,
                            keyboardType: TextInputType.multiline,
                            maxLines: 5,
                            validator: (value) {
                              return value.isEmpty
                                  ? keyString(context, "error_review_requires")
                                  : null;
                            },
                            style: TextStyle(
                                fontFamily: font_regular,
                                fontSize: ts_normal,
                                color: Theme.of(context).textTheme.title.color),
                            decoration: new InputDecoration(
                              hintText: keyString(context, "aRate_hint"),
                              border: InputBorder.none,
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .textTheme
                                        .title
                                        .color),
                              ),
                              labelStyle: TextStyle(
                                  fontSize: ts_normal,
                                  color:
                                      Theme.of(context).textTheme.title.color),
                              labelText: keyString(
                                  context, "hint_confirm_your_new_password"),
                              filled: false,
                            ),
                          ).paddingOnly(
                              left: spacing_large, right: spacing_large),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Expanded(
                              child: MaterialButton(
                                textColor:
                                    Theme.of(context).textTheme.title.color,
                                child: text(context,
                                    keyString(context, "aRate_lbl_Cancel"),
                                    fontSize: ts_normal,
                                    textColor: Theme.of(context)
                                        .textTheme
                                        .title
                                        .color),
                                shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(5.0),
                                  side: BorderSide(
                                      color: Theme.of(context)
                                          .textTheme
                                          .title
                                          .color),
                                ),
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(ConfirmAction.CANCEL);
                                },
                              ).paddingOnly(right: spacing_standard),
                            ),
                            Expanded(
                              child: MaterialButton(
                                color: Theme.of(context).textTheme.title.color,
                                textColor: Theme.of(context).cardTheme.color,
                                child: text(
                                    context, keyString(context, "lbl_post"),
                                    fontSize: ts_normal,
                                    textColor:
                                        Theme.of(context).cardTheme.color),
                                shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(5.0),
                                ),
                                onPressed: () {
                                  final form = _formKey.currentState;
                                  if (form.validate()) {
                                    form.save();
                                    submitReview(controller.text, rating);
                                  } else {
                                    setState(() => _autoValidate = true);
                                  }
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
          ),
        );
      },
    );
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      if (data[1] == DownloadTaskStatus.complete) {
        loadBookFromOffline();
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    print(
        'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  Future<bool> submitReview(String text, double rating) async {
    var id = await getInt(USER_ID);
    isNetworkAvailable().then((bool) {
      if (bool) {
        if (userReviewData != null) {
          var request = {
            "book_id": mBookDetail.bookId,
            "user_id": id,
            "rating_id": userReviewData.ratingId,
            "rating": rating.toString(),
            "review": text
          };
          showLoading(true);

          updateBookRating(request).then((result) {
            BaseResponse response = BaseResponse.fromJson(result);
            if (response.status) {
              Navigator.of(context).pop();
              fetchBookDetail();
            } else {
              showLoading(false);
              toast(response.message);
            }
            return response.status;
          }).catchError((error) {
            showLoading(false);
            toast(error.toString());
          });
        } else {
          var request = {
            "book_id": mBookDetail.bookId,
            "user_id": id,
            "rating": rating.toString(),
            "review": text,
            "message": "",
            "status": true
          };
          showLoading(true);
          addBookRating(request).then((result) {
            BaseResponse response = BaseResponse.fromJson(result);
            if (response.status) {
              Navigator.of(context).pop();
              fetchBookDetail();
            } else {
              showLoading(false);
              toast(response.message);
            }
            return response.status;
          }).catchError((error) {
            toast(error.toString());
            showLoading(false);
          });
        }
      } else {
        toast(keyString(context, "error_network_no_internet"));
      }
    });
  }

  deleteBookRating(ratingId) async {
    isNetworkAvailable().then((bool) {
      if (bool) {
        showLoading(true);
        var request = {
          "id": userReviewData.ratingId,
        };
        deleteRating(request).then((result) {
          BaseResponse response = BaseResponse.fromJson(result);
          if (response.status) {
            fetchBookDetail();
          } else {
            showLoading(false);
            toast(response.message);
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

  addRemoveToWishList(isWishList) async {
    bool result =
        await addRemoveWishList(context, mBookDetail.bookId, isWishList);
    if (result) {
      fetchBookDetail();
    }
  }

  addBookToCart() {
    isNetworkAvailable().then((bool) {
      if (bool) {
        showLoading(true);

        var request = {
          "book_id": mBookDetail.bookId,
          "added_qty": 1,
          "user_id": id
        };
        addToCart(request).then((result) {
          BaseResponse response = BaseResponse.fromJson(result);
          if (response.status) {
            LiveStream().emit(CART_ITEM_CHANGED, true);
            fetchBookDetail();
          } else {
            showLoading(false);
            toast(response.message);
          }
        }).catchError((error) {
          showLoading(false);
          toast(error.toString());
        });
      } else {
        toast(keyString(context, "error_network_no_internet"));
      }
    });
  }

  sampleClick(context) async {
    if (!_permissionReady) {
      _permissionReady = await checkPermission(context);
      return;
    }
    if (mSampleDownloadTask.status == DownloadTaskStatus.undefined) {
      var id = await requestDownload(
          context: context, downloadTask: mSampleDownloadTask, isSample: true);
      setState(() {
        mSampleDownloadTask.taskId = id;
        mSampleDownloadTask.status = DownloadTaskStatus.running;
      });
      await dbHelper.insert(mSampleDownloadTask);
    } else if (mSampleDownloadTask.status == DownloadTaskStatus.complete) {
      readFile(context, mSampleDownloadTask.mDownloadTask.filename,
          mBookDetail.name);
    } else {
      toast('Downloading');
    }
  }

  readBook(context) async {
    if (!_permissionReady) {
      _permissionReady = await checkPermission(context);
      return;
    }
    if (mBookDownloadTask.mDownloadTask.status ==
        DownloadTaskStatus.undefined) {
      var id = await requestDownload(
          context: context, downloadTask: mBookDownloadTask, isSample: false);
      setState(() {
        mBookDownloadTask.taskId = id;
        mBookDownloadTask.status = DownloadTaskStatus.running;
      });
      await dbHelper.insert(mBookDownloadTask);
    } else if (mBookDownloadTask.status == DownloadTaskStatus.complete) {
      readFile(
          context, mBookDownloadTask.mDownloadTask.filename, mBookDetail.name);
    } else {
      toast('Downloading');
    }
  }

  IconData getCenter() {
    if (mSampleDownloadTask.status == DownloadTaskStatus.running) {
      return Icons.pause;
    } else if (mSampleDownloadTask.status == DownloadTaskStatus.paused) {
      return Icons.play_arrow;
    } else if (mSampleDownloadTask.status == DownloadTaskStatus.failed) {
      return Icons.refresh;
    }
  }

  @override
  Widget build(BuildContext context) {
    changeStatusColor(Theme.of(context).cardTheme.color);
    Widget buildActionForTask() {
      if (mSampleDownloadTask == null) {
        return text(context, keyString(context, "lbl_download_sample"),
            textColor: Theme.of(context).textTheme.title.color,
            fontSize: ts_normal,
            fontFamily: font_medium);
      }
      if (mSampleDownloadTask.status == DownloadTaskStatus.undefined) {
        return text(context, keyString(context, "lbl_download_sample"),
            textColor: Theme.of(context).textTheme.title.color,
            fontSize: ts_normal,
            fontFamily: font_medium);
      } else if (mSampleDownloadTask.status == DownloadTaskStatus.complete) {
        return text(context, keyString(context, "lbl_view_sample"),
            textColor: Theme.of(context).textTheme.title.color,
            fontSize: ts_normal,
            fontFamily: font_medium);
      } else {
        return text(context, keyString(context, "lbl_downloading"),
            textColor: Theme.of(context).textTheme.title.color,
            fontSize: ts_normal,
            fontFamily: font_medium);
      }
    }

    final yourReview = userReviewData != null
        ? Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                headingText(
                  context,
                  keyString(context, "lbl_your_review"),
                ),
                InkWell(
                    onTap: () {
                      controller.text = userReviewData.review;
                      rating = double.parse(userReviewData.rating.toString());
                      showRatingDialog(context);
                    },
                    child: review(context, userReviewData, isUserReview: true,
                        callback: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          // return object of type Dialog

                          return Theme(
                            data: ThemeData(
                                canvasColor:
                                    Theme.of(context).scaffoldBackgroundColor),
                            child: AlertDialog(
                              title: new Text(
                                  keyString(context, "lbl_confirmation")),
                              content: new Text(
                                  keyString(context, "lbl_note_delete")),
                              actions: <Widget>[
                                // usually buttons at the bottom of the dialog
                                new FlatButton(
                                  child: new Text(keyString(context, "close")),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                new FlatButton(
                                  child: new Text(keyString(context, "lbl_ok")),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    deleteBookRating(userReviewData.ratingId);
                                  },
                                )
                              ],
                            ),
                          );
                        },
                      );
                    }).paddingTop(spacing_standard_new)),
              ],
            ).paddingOnly(
                left: spacing_standard_new,
                right: spacing_standard_new,
                top: spacing_standard_new,
                bottom: spacing_standard_new),
          )
        : Container();

    final topReviews = description != null
        ? Container(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                horizontalHeading(
                    context, keyString(context, "lbl_top_reviews"),
                    showViewAll: bookRating.length > 3,
                    callback: bookRating.length > 3
                        ? () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        BookReviews(bookDetail: mBookDetail)));
                          }
                        : null),
                bookRating.length > 0
                    ? ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount:
                            bookRating.length <= 3 ? bookRating.length : 3,
                        shrinkWrap: true,
                        padding: EdgeInsets.only(
                            left: spacing_standard_new,
                            right: spacing_standard_new,
                            top: spacing_standard_new,
                            bottom: spacing_standard),
                        itemBuilder: (context, index) {
                          return review(context, bookRating[index]);
                        },
                      )
                    : text(context, keyString(context, "no_review"),
                            fontSize: ts_normal,
                            fontFamily: font_medium,
                            textColor: Colors.grey.withOpacity(0.7))
                        .paddingOnly(
                            top: spacing_standard_new,
                            left: spacing_standard_new),
                MaterialButton(
                  minWidth: MediaQuery.of(context).size.width,
                  elevation: spacing_control,
                  padding: EdgeInsets.fromLTRB(
                      24, spacing_middle, 24, spacing_middle),
                  color: Theme.of(context).cardTheme.color,
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(spacing_control),
                    side: BorderSide(color: Theme.of(context).cardTheme.color),
                  ),
                  child: text(context, keyString(context, "lbl_write_review"),
                      textColor: Theme.of(context).textTheme.title.color,
                      fontFamily: font_medium,
                      fontSize: ts_normal),
                  onPressed: () async {
                    if (isUserLoggedIn) {
                      showRatingDialog(context);
                    } else {
                      launchScreen(context, SignIn.tag);
                    }
                  },
                )
                    .paddingOnly(
                        left: spacing_standard_new,
                        right: spacing_standard_new,
                        top: spacing_standard_new)
                    .visible(userReviewData == null)
              ],
            ),
          )
        : Container();
    var bookDescriptionWidget = mBookDetail != null
        ? Container(
            width: double.infinity,
            decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).hoverColor.withOpacity(0.15),
                      blurRadius: 5,
                      spreadRadius: 4,
                      offset: Offset.fromDirection(3, 1))
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                text(context, mBookDetail.description,
                    maxLine: 3, isLongText: isExpanded),
                InkWell(
                    onTap: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                    child: text(
                        context,
                        isExpanded
                            ? keyString(context, "lbl_read_less")
                            : keyString(context, "lbl_read_more"),
                        textColor: Theme.of(context).textTheme.title.color,
                        fontFamily: font_semi_bold))
              ],
            ).paddingOnly(
                left: spacing_standard_new, bottom: spacing_standard_new),
          )
        : Container();

    var priceInfo = mBookDetail != null
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              text(
                      context,
                      mBookDetail.discountedPrice != 0
                          ? mBookDetail.discountedPrice
                              .toString()
                              .toCurrencyFormat()
                          : mBookDetail.price.toString().toCurrencyFormat(),
                      textColor: Theme.of(context).textTheme.title.color,
                      fontSize: ts_large,
                      fontFamily: font_bold)
                  .visible(mBookDetail.discountedPrice != 0 ||
                      mBookDetail.price != 0),
              text(
                context,
                mBookDetail.price.toString().toCurrencyFormat(),
                fontSize: ts_normal,
                aDecoration: TextDecoration.lineThrough,
              )
                  .paddingOnly(left: spacing_standard)
                  .visible(mBookDetail.discount != 0),
            ],
          ).paddingOnly(
            top: spacing_standard_new,
          )
        : Container();
    var discountInfo = mBookDetail != null
        ? text(
            context,
            "~ " +
                mBookDetail.discount.toString() +
                keyString(context, "lbl_your_discount"),
            fontFamily: font_medium,
            fontSize: ts_normal,
            textColor: Theme.of(context).errorColor,
          )
            .paddingOnly(left: spacing_standard)
            .visible(mBookDetail.discount != 0)
        : Container();
    var buttons = mBookDetail != null
        ? Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(spacing_standard_new),
                  child: RaisedButton(
                    padding: EdgeInsets.fromLTRB(
                        24, spacing_middle, 24, spacing_middle),
                    elevation: spacing_control,
                    color: Theme.of(context).cardTheme.color,
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(spacing_control),
                      side:
                          BorderSide(color: Theme.of(context).cardTheme.color),
                    ),
                    child: buildActionForTask(),
                    onPressed: () {
                      checkPermission(context).then((hasGranted) {
                        sampleClick(context);
                      });
                    },
                  ),
                ),
              ),
              mBookDetail.is_purchase == 0 && mBookDetail.price != 0
                  ? Padding(
                      padding: const EdgeInsets.all(spacing_standard_new),
                      child: MaterialButton(
                        padding: EdgeInsets.fromLTRB(spacing_large,
                            spacing_middle, spacing_large, spacing_middle),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              new BorderRadius.circular(spacing_control),
                          side: BorderSide(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        elevation: spacing_control,
                        color: Theme.of(context).colorScheme.primary,
                        child: text(context, 'Add to Cart',
                            textColor: white,
                            fontSize: ts_normal,
                            fontFamily: font_medium),
                        onPressed: () {
                          if (isUserLoggedIn) {
                            if (isExistInCart) {
                              toast("Already exisat in cart");
                            } else {
                              addBookToCart();
                            }
                          } else {
                            launchScreen(context, SignIn.tag);
                          }
                        },
                      ),
                    )
                  : Container(),
              mBookDetail.is_purchase == 1 || mBookDetail.price == 0
                  ? Padding(
                      padding: const EdgeInsets.all(spacing_standard_new),
                      child: MaterialButton(
                        padding: EdgeInsets.fromLTRB(
                            24, spacing_middle, 24, spacing_middle),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              new BorderRadius.circular(spacing_control),
                          side: BorderSide(
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                        elevation: spacing_control,
                        color: Theme.of(context).colorScheme.secondary,
                        child: text(context, 'Read Book',
                            textColor: white,
                            fontSize: ts_normal,
                            fontFamily: font_medium),
                        onPressed: () {
                          readBook(context);
                        },
                      ),
                    )
                  : Container()
            ],
          )
        : Container();

    var authorBookList = description != null
        ? BookHorizontalList(
            description.authorBookList,
            isHorizontal: true,
          )
            .paddingTop(spacing_standard_new)
            .visible(description.authorBookList.isNotEmpty)
        : Container();

    var recommondedBooks = description != null
        ? BookHorizontalList(description.recommendedBook)
            .paddingTop(spacing_standard)
            .visible(description.recommendedBook.isNotEmpty)
        : Container();
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Theme.of(context).highlightColor,
        body: Stack(
          children: <Widget>[
            mBookDetail != null
                ? NestedScrollView(
                    headerSliverBuilder:
                        (BuildContext context, bool innerBoxIsScrolled) {
                      return <Widget>[
                        SliverAppBar(
                          expandedHeight: 80 + (width * 0.7) + 100,
                          floating: false,
                          pinned: true,
                          titleSpacing: 0,
                          leading: InkWell(
                            child: Container(
                              padding: EdgeInsets.all(16),
                              child: Icon(
                                Icons.arrow_back,
                                color: Theme.of(context).iconTheme.color,
                              ),
                            ),
                            onTap: () {
                              finish(context);
                            },
                            radius: spacing_standard_new,
                          ),
                          backgroundColor: Theme.of(context).cardTheme.color,
                          actionsIconTheme: Theme.of(context).iconTheme,
                          actions: <Widget>[
                            InkWell(
                              child: Container(
                                width: 40,
                                height: 40,
                                padding: EdgeInsets.all(spacing_middle),
                                child: SvgPicture.asset(
                                  icon_share,
                                  color: Theme.of(context).iconTheme.color,
                                ),
                              ),
                              onTap: () {
                                Share.share(mBookDetail.name +
                                    " by " +
                                    mBookDetail.authorName +
                                    "\n" +
                                    mBaseUrl +
                                    "book/detail/" +
                                    mBookDetail.bookId.toString());
                              },
                              radius: spacing_standard_new,
                            ),
                            InkWell(
                              child: Container(
                                width: 40,
                                height: 40,
                                padding: EdgeInsets.all(spacing_middle),
                                child: SvgPicture.asset(
                                    mBookDetail.isWishList == 0
                                        ? icon_bookmark
                                        : icon_bookmark_fill,
                                    color: Theme.of(context).iconTheme.color),
                              ),
                              onTap: () {
                                if (isUserLoggedIn) {
                                  setState(() {
                                    mBookDetail.isWishList =
                                        mBookDetail.isWishList == 0 ? 1 : 0;
                                  });
                                  addRemoveToWishList(mBookDetail.isWishList);
                                } else {
                                  launchScreen(context, SignIn.tag);
                                }
                              },
                              radius: spacing_standard_new,
                            ).visible(mBookDetail.is_purchase == 0),
                            cartIcon(context, cartCount)
                          ],
                          flexibleSpace: FlexibleSpaceBar(
                            background: Column(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    child: AspectRatio(
                                      child: Card(
                                        semanticContainer: true,
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        elevation: spacing_standard,
                                        margin: EdgeInsets.all(0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              spacing_standard),
                                        ),
                                        child: networkImage(
                                          mBookDetail.frontCover,
                                        ),
                                      ),
                                      aspectRatio: 6 / 9,
                                    ),
                                  ).paddingBottom(spacing_standard_new),
                                ),
                                text(context, mBookDetail.name,
                                    textColor:
                                        Theme.of(context).textTheme.title.color,
                                    fontSize: ts_medium_large,
                                    fontFamily: font_medium,
                                    maxLine: 2),
                                InkWell(
                                  child: text(context, mBookDetail.authorName,
                                          fontFamily: font_medium,
                                          fontSize: ts_extra_normal,
                                          textColor: Theme.of(context)
                                              .textTheme
                                              .button
                                              .color)
                                      .paddingTop(spacing_control),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AuthorDetailScreen(
                                                  authorDetail: description
                                                      .authorDetail[0],
                                                )));
                                  },
                                ),
                                Container(
                                  width: width * 0.35,
                                  margin: EdgeInsets.only(
                                      top: spacing_standard_new),
                                  padding: EdgeInsets.only(
                                      top: spacing_control,
                                      bottom: spacing_control),
                                  decoration: boxDecoration(context,
                                      bgColor: Theme.of(context).highlightColor,
                                      radius: spacing_standard_new),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      RatingBar.readOnly(
                                        initialRating: double.parse(
                                            mBookDetail.totalRating.toString()),
                                        emptyIcon: Icon(Icons.star).icon,
                                        filledIcon: Icon(Icons.star).icon,
                                        filledColor: Colors.amber,
                                        emptyColor:
                                            Colors.grey.withOpacity(0.7),
                                        size: 15,
                                      ),
                                      text(
                                              context,
                                              double.parse(mBookDetail
                                                      .totalRating
                                                      .toStringAsFixed(1))
                                                  .toString(),
                                              fontFamily: font_medium)
                                          .paddingOnly(left: 8),
                                    ],
                                  ),
                                )
                              ],
                            ).paddingTop(80),
                          ),
                        ),
                      ];
                    },
                    body: RefreshIndicator(
                      onRefresh: () {
                        return fetchBookDetail();
                      },
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            bookDescriptionWidget,
                            priceInfo,
                            discountInfo,
                            Container(
                              width: double.infinity,
                              margin:
                                  EdgeInsets.only(top: spacing_standard_new),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).cardTheme.color,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Theme.of(context)
                                            .hoverColor
                                            .withOpacity(0.15),
                                        blurRadius: 5,
                                        spreadRadius: 4,
                                        offset: Offset.fromDirection(3, 1))
                                  ]),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  buttons,
                                  yourReview,
                                  topReviews,
                                  horizontalHeading(
                                          context,
                                          keyString(context,
                                              "lbl_more_books_by_this_author"),
                                          showViewAll: false)
                                      .visible(description
                                          .authorBookList.isNotEmpty),
                                  authorBookList,
                                  horizontalHeading(
                                          context,
                                          keyString(
                                              context, "lnl_you_may_also_like"),
                                          showViewAll: false)
                                      .paddingTop(spacing_standard_new)
                                      .visible(description
                                          .recommendedBook.isNotEmpty),
                                  recommondedBooks,
                                  SizedBox(
                                    height: 70,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : Container(),
            Center(child: loadingWidgetMaker()).visible(isLoading)
          ],
        ));
  }
}
