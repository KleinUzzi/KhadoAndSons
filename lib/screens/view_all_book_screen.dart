import 'package:flutter/material.dart';
import 'package:KhadoAndSons/models/response/book_detail.dart';
import 'package:KhadoAndSons/models/response/dashboard_response.dart';
import 'package:KhadoAndSons/network/rest_apis.dart';
import 'package:KhadoAndSons/utils/common.dart';
import 'package:KhadoAndSons/utils/constants.dart';
import 'package:KhadoAndSons/utils/resources/colors.dart';
import 'package:KhadoAndSons/utils/resources/size.dart';
import 'package:KhadoAndSons/utils/widgets.dart';
import 'package:nb_utils/nb_utils.dart';

import '../app_localizations.dart';

class ViewAllBooks extends StatefulWidget {
  static String tag = '/ViewAllBooks';
  var type;
  var title;
  var categoryId = '';
  ViewAllBooks({this.type, this.title, this.categoryId = ''});

  @override
  _ViewAllBooksState createState() => _ViewAllBooksState();
}

class _ViewAllBooksState extends State<ViewAllBooks>
    with AfterLayoutMixin<ViewAllBooks> {
  var list = List<BookDetail>();
  var totalBooks = 0;
  var page = 1;
  var scrollController = new ScrollController();
  bool isLoading = false;
  bool isLoadingMoreData = false;
  bool isLastPage = false;

  double width;
  bool isExpanded = false;
  var cartCount = 0;
  var isUserLogin = false;

  @override
  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      scrollHandler();
    });
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    setState(() {
      isLoadingMoreData = true;
    });
    fetchBookList(page);
    isUserLogin = await getBool(IS_LOGGED_IN);
    if (isUserLogin) {
      cartCount = await getInt(CART_COUNT);
    }
  }

  scrollHandler() {
    if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        !isLastPage) {
      page++;
      setState(() {
        isLoadingMoreData = true;
      });
      fetchBookList(page);
    }
  }

  Future<List<BookDetail>> fetchBookList(page) async {
    isNetworkAvailable().then((bool) {
      if (bool) {
        getViewAllBookNextPage(widget.type, page, categoryId: widget.categoryId)
            .then((result) {
          DashboardResponse response = DashboardResponse.fromJson(result);
          setState(() {
            isLoadingMoreData = false;
            totalBooks = response.pagination.totalItems;
            isLastPage = page == response.pagination.totalPages;
            if (response.data.isEmpty) {
              isLastPage = true;
            }
            list.addAll(response.data);
          });
          return response.data;
        }).catchError((error) {
          toast(error.toString());
          setState(() {
            isLoadingMoreData = false;
            isLastPage = true;
          });
        });
      } else {
        toast(keyString(context, "error_network_no_internet"));
        finish(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      elevation: 0.0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      iconTheme: Theme.of(context).iconTheme,
      centerTitle: true,
      actions: <Widget>[cartIcon(context, cartCount).visible(isUserLogin)],
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            widget.title,
          )
              .withStyle(
                  fontSize: ts_extra_normal,
                  color: Theme.of(context).textTheme.title.color,
                  fontFamily: font_bold)
              .paddingTop(spacing_standard_new),
          Text(totalBooks.toString() + ' ' + keyString(context, "lbl_books"))
              .withStyle(
                  fontSize: ts_medium,
                  fontFamily: font_regular,
                  color: Theme.of(context).textTheme.subtitle.color)
              .paddingTop(spacing_control_half)
        ],
      ),
    );

    var books = BookGridList(list);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: appBar,
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SingleChildScrollView(
              controller: scrollController,
              child: list.isNotEmpty
                  ? isLoadingMoreData
                      ? Column(
                          children: <Widget>[
                            books.paddingTop(spacing_standard_new),
                            loadingWidgetMaker()
                          ],
                        )
                      : books.paddingTop(spacing_standard_new)
                  : Center(
                      child: loadingWidgetMaker()
                          .paddingTop(spacing_large)
                          .visible(isLoadingMoreData))),
          Center(
            child: text(context, keyString(context, "error_no_result"),
                fontSize: ts_extra_normal,
                textColor: Theme.of(context).textTheme.title.color),
          ).visible(list.isEmpty && !isLoadingMoreData)
        ],
      ),
    );
  }
}
