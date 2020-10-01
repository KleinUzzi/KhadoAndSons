import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:KhadoAndSons/models/response/book_detail.dart';
import 'package:KhadoAndSons/models/response/book_rating.dart';
import 'package:KhadoAndSons/models/response/book_rating_list.dart';
import 'package:KhadoAndSons/network/rest_apis.dart';
import 'package:KhadoAndSons/utils/common.dart';
import 'package:KhadoAndSons/utils/constants.dart';
import 'package:KhadoAndSons/utils/resources/colors.dart';
import 'package:KhadoAndSons/utils/resources/images.dart';
import 'package:KhadoAndSons/utils/resources/size.dart';
import 'package:KhadoAndSons/utils/widgets.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../app_localizations.dart';

class BookReviews extends StatefulWidget {
  static String tag = '/BookReviews';
  BookDetail bookDetail;

  BookReviews({this.bookDetail});

  @override
  BookReviewsState createState() => BookReviewsState();
}

class BookReviewsState extends State<BookReviews>
    with AfterLayoutMixin<BookReviews> {
  var list = List<BookRating>();
  double fiveStar = 0;
  double fourStar = 0;
  double threeStar = 0;
  double twoStar = 0;
  double oneStar = 0;
  bool isLoading = false;

  showLoading(bool show) {
    setState(() {
      isLoading = show;
    });
  }

  fetchReviews() {
    isNetworkAvailable().then((bool) {
      if (bool) {
        showLoading(true);
        var request = {"book_id": widget.bookDetail.bookId};
        getReview(request).then((result) {
          BookRatingList ratingList = BookRatingList.fromJson(result);
          showLoading(false);

          if (ratingList.data != null && ratingList.data.isNotEmpty) {
            setState(() {
              list.clear();
              list.addAll(ratingList.data);
              setRating();
            });
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

  @override
  void afterFirstLayout(BuildContext context) async {
    fetchReviews();
  }

  setRating() {
    fiveStar = 0;
    fourStar = 0;
    threeStar = 0;
    twoStar = 0;
    oneStar = 0;
    list.forEach((review) {
      switch (review.rating) {
        case 5:
          fiveStar++;
          break;
        case 4:
          fourStar++;
          break;
        case 3:
          threeStar++;
          break;
        case 2:
          twoStar++;
          break;
        case 1:
          oneStar++;
          break;
      }
    });
    fiveStar = (fiveStar * 100) / list.length;
    fourStar = (fourStar * 100) / list.length;
    threeStar = (threeStar * 100) / list.length;
    twoStar = (twoStar * 100) / list.length;
    oneStar = (oneStar * 100) / list.length;
    print(fiveStar);
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    final topReviews = list != null && list.isNotEmpty
        ? ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemCount: list.length,
            shrinkWrap: true,
            padding: EdgeInsets.only(
                left: spacing_standard_new,
                right: spacing_standard_new,
                top: spacing_standard_new,
                bottom: 70),
            itemBuilder: (context, index) {
              BookRating bookRating = list[index];
              return Container(
                margin: EdgeInsets.only(top: spacing_standard),
                padding: EdgeInsets.all(spacing_middle),
                decoration: boxDecoration(context,
                    radius: spacing_control, showShadow: true),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    bookRating.profileImage != null
                        ? networkImage(bookRating.profileImage,
                                aWidth: 40, aHeight: 40)
                            .cornerRadiusWithClipRRect(25)
                        : Image.asset(
                            ic_profile,
                            width: 40,
                            height: 40,
                          ).cornerRadiusWithClipRRect(25),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          text(context, bookRating.userName,
                              fontFamily: font_medium,
                              textColor:
                                  Theme.of(context).textTheme.title.color,
                              fontSize: ts_normal),
                          Row(
                            children: <Widget>[
                              text(
                                context,
                                bookRating.createdAt.toString().formatDate(),
                              ),
                              SizedBox(
                                width: spacing_control,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 14,
                                  ),
                                  text(
                                      context,
                                      double.parse(bookRating.rating.toString())
                                          .toString(),
                                      textColor: textColorSecondary,
                                      fontFamily: font_medium,
                                      fontSize: ts_medium),
                                ],
                              )
                            ],
                          ),
                          text(context, bookRating.review ?? "",
                              isLongText: false,
                              maxLine: 3,
                              textColor: textColorSecondary)
                        ],
                      ).paddingLeft(spacing_standard_new),
                    ),
                  ],
                ),
              );
            })
        : Container();
    var reviewInfo = Container(
      margin: EdgeInsets.all(spacing_standard_new),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            height: width * 0.33,
            width: width * 0.33,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).hoverColor.withOpacity(0.15)),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                reviewText(widget.bookDetail.totalRating,
                    size: 28.0, fontSize: 30, fontFamily: font_bold),
                text(
                    context,
                    list.length.toString() +
                        " " +
                        keyString(context, "lbl_reviews"),
                    fontSize: ts_normal),
              ],
            ),
          ),
          SizedBox(
            width: spacing_standard_new,
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    reviewText(5),
                    ratingProgress(fiveStar, Colors.green)
                  ],
                ),
                SizedBox(
                  height: spacing_control_half,
                ),
                Row(
                  children: <Widget>[
                    reviewText(4),
                    ratingProgress(fourStar, Colors.green)
                  ],
                ),
                SizedBox(
                  height: spacing_control_half,
                ),
                Row(
                  children: <Widget>[
                    reviewText(3),
                    ratingProgress(threeStar, Colors.amber)
                  ],
                ),
                SizedBox(
                  height: spacing_control_half,
                ),
                Row(
                  children: <Widget>[
                    reviewText(2),
                    ratingProgress(twoStar, Colors.amber)
                  ],
                ),
                SizedBox(
                  height: spacing_control_half,
                ),
                Row(
                  children: <Widget>[
                    reviewText(1),
                    ratingProgress(oneStar, Colors.red)
                  ],
                )
              ],
            ),
          )
        ],
      ).paddingTop(80),
    );
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 80 + (width * 0.38),
              floating: false,
              pinned: true,
              backgroundColor: Theme.of(context).cardTheme.color,
              iconTheme: Theme.of(context).iconTheme,
              title: headingText(
                context,
                keyString(context, "lbl_reviews"),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: reviewInfo,
              ),
            ),
          ];
        },
        body: RefreshIndicator(
          onRefresh: () {
            fetchReviews();
            return;
          },
          child: SingleChildScrollView(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                topReviews,
                loadingWidgetMaker().visible(isLoading)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget reviewText(rating,
      {size = 15.0, fontSize = ts_extra_normal, fontFamily = font_medium}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        text(context, rating.toString(),
            textColor: Theme.of(context).textTheme.title.color,
            fontFamily: fontFamily,
            fontSize: fontSize),
        SizedBox(
          width: spacing_control,
        ),
        Icon(
          Icons.star,
          color: Colors.amber,
          size: size,
        )
      ],
    );
  }

  Widget ratingProgress(value, color) {
    return Expanded(
      child: LinearPercentIndicator(
        lineHeight: 10.0,
        percent: value / 100,
        linearStrokeCap: LinearStrokeCap.roundAll,
        backgroundColor: Colors.grey.withOpacity(0.2),
        progressColor: color,
      ),
    );
  }
}
