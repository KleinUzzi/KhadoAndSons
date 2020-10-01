import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:KhadoAndSons/models/response/author.dart';
import 'package:KhadoAndSons/models/response/book_detail.dart';
import 'package:KhadoAndSons/models/response/book_list.dart';
import 'package:KhadoAndSons/network/rest_apis.dart';
import 'package:KhadoAndSons/utils/common.dart';
import 'package:KhadoAndSons/utils/constants.dart';
import 'package:KhadoAndSons/utils/resources/colors.dart';
import 'package:KhadoAndSons/utils/resources/size.dart';
import 'package:KhadoAndSons/utils/widgets.dart';
import 'package:nb_utils/nb_utils.dart';

import '../app_localizations.dart';
import 'book_description_screen.dart';

class AuthorDetailScreen extends StatefulWidget {
  static String tag = '/AuthorDetailScreen';
  AuthorDetail authorDetail;

  AuthorDetailScreen({this.authorDetail});

  @override
  AuthorDetailScreenState createState() => AuthorDetailScreenState();
}

class AuthorDetailScreenState extends State<AuthorDetailScreen>
    with TickerProviderStateMixin<AuthorDetailScreen> {
  var mIsFirstTime = true;
  var totalBooks = 0;
  var page = 1;
  var scrollController = new ScrollController();
  bool isLoading = false;
  bool isLoadingMoreData = false;
  bool isLastPage = false;
  var list = List<BookDetail>();

  double width;
  bool isExpanded = false;

  @override
  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoadingMoreData = true;
    });
    fetchAuthorBookList(page);
    scrollController.addListener(() {
      scrollHandler();
    });
  }

  scrollHandler() {
    if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        !isLastPage) {
      page++;
      setState(() {
        isLoadingMoreData = true;
      });
      fetchAuthorBookList(page);
    }
  }

  Future<List<BookDetail>> fetchAuthorBookList(page) async {
    isNetworkAvailable().then((bool) {
      if (bool) {
        getBookList(page, widget.authorDetail.author_id).then((result) {
          BookListResponse response = BookListResponse.fromJson(result);
          setState(() {
            isLoadingMoreData = false;
            totalBooks = response.pagination.totalItems;
            isLastPage = page == response.pagination.totalPages;
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
      }
    });
  }

  Widget listItemBuilder(context, BookDetail bookDetail) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    BookDescriptionScreen(bookDetail: bookDetail)));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Card(
            semanticContainer: true,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            elevation: spacing_control_half,
            margin: EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(spacing_control),
            ),
            child: networkImage(
              bookDetail.frontCover,
              aHeight: width * 0.4,
              aWidth: width * 0.3,
            ),
          ),
          Text(
            bookDetail.name,
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          )
              .withStyle(
                  color: Theme.of(context).textTheme.title.color,
                  fontFamily: font_bold,
                  fontSize: ts_medium_small)
              .paddingOnly(right: 8, bottom: 0, top: 8),
          Expanded(
            child: Text(
              bookDetail.authorName,
              maxLines: 1,
            )
                .withStyle(
                    color: Theme.of(context).textTheme.subtitle.color,
                    fontFamily: font_regular,
                    fontSize: ts_medium_small)
                .paddingOnly(right: 8, bottom: 8),
          ),
        ],
      ).paddingAll(8),
    );
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    final authorDetail = Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              elevation: spacing_standard,
              margin: EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(spacing_standard),
              ),
              child: networkImage(
                widget.authorDetail.image,
                aHeight: width * 0.4,
                aWidth: width * 0.4,
              )).paddingBottom(spacing_standard_new),
          Text(
            widget.authorDetail.name,
          )
              .withStyle(
                  color: Theme.of(context).textTheme.title.color,
                  fontFamily: font_bold,
                  fontSize: ts_large)
              .paddingOnly(bottom: 4),
          Container(
            margin: EdgeInsets.only(top: spacing_control),
            padding: EdgeInsets.fromLTRB(spacing_middle, spacing_control,
                spacing_middle, spacing_control),
            decoration: boxDecoration(context,
                radius: spacing_standard_new,
                bgColor: Theme.of(context).primaryColor.withOpacity(0.15),
                showShadow: true),
            child: Text(keyString(context, "lbl_publishBook") +
                    totalBooks.toString())
                .withStyle(
                    color: Theme.of(context).textTheme.title.color,
                    fontFamily: font_medium),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.authorDetail.description,
                maxLines: isExpanded ? null : 3,
              )
                  .withStyle(
                      color: Theme.of(context).textTheme.subtitle.color,
                      fontFamily: font_regular)
                  .paddingOnly(
                      left: spacing_standard_new,
                      right: spacing_standard_new,
                      top: spacing_standard_new),
              Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(keyString(context, "lbl_description"))
                          .withStyle(
                              color: Theme.of(context).textTheme.title.color,
                              fontFamily: font_regular)
                          .withWidth(200),
                      Expanded(
                          child: Text(
                        widget.authorDetail.designation,
                        maxLines: 3,
                      ).withStyle(
                              color: Theme.of(context).textTheme.subtitle.color,
                              fontFamily: font_regular)),
                    ],
                  ).paddingOnly(top: 16, left: 16, right: 16),
                  Row(
                    children: <Widget>[
                      Text(keyString(context, "lbl_address"))
                          .withStyle(
                              color: Theme.of(context).textTheme.title.color,
                              fontFamily: font_regular)
                          .withWidth(200),
                      Expanded(
                          child: Text(
                        widget.authorDetail.address,
                        maxLines: 3,
                      ).withStyle(
                              color: Theme.of(context).textTheme.subtitle.color,
                              fontFamily: font_regular)),
                    ],
                  ).paddingOnly(top: 8, left: 16, right: 16),
                  Row(
                    children: <Widget>[
                      Text(keyString(context, "lbl_education"))
                          .withStyle(
                              color: Theme.of(context).textTheme.title.color,
                              fontFamily: font_regular)
                          .withWidth(200),
                      Expanded(
                          child: Text(
                        widget.authorDetail.education,
                        maxLines: 3,
                      ).withStyle(
                              color: Theme.of(context).textTheme.subtitle.color,
                              fontFamily: font_regular)),
                    ],
                  ).paddingOnly(top: 8, left: 16, right: 16, bottom: 16)
                ],
              ).visible(isExpanded),
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
                          fontFamily: font_semi_bold)
                      .paddingOnly(
                          left: spacing_standard_new, top: spacing_standard))
            ],
          ),
        ],
      ),
    );

    final books = Container(
      child: GridView.builder(
        itemCount: list.length,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: 70),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, childAspectRatio: width * 0.5 / width * 1.2),
        scrollDirection: Axis.vertical,
        controller: ScrollController(keepScrollOffset: false),
        itemBuilder: (context, index) {
          return listItemBuilder(context, list[index]);
        },
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        brightness: Brightness.light,
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        controller: scrollController,
        child: Column(
          children: <Widget>[
            authorDetail,
            Divider(thickness: 0.8),
            Stack(
              children: <Widget>[
                isLoadingMoreData
                    ? Column(
                        children: <Widget>[books, loadingWidgetMaker()],
                      )
                    : books,
                loadingWidgetMaker().visible(list.isEmpty && isLoadingMoreData),
                Center(
                  child: text(
                      context, keyString(context, "error_no_published_book"),
                      fontSize: ts_extra_normal,
                      textColor: Theme.of(context).textTheme.title.color),
                ).paddingTop(30.0).visible(list.isEmpty && !isLoadingMoreData)
              ],
            )
          ],
        ),
      ),
    );
  }
}
