import 'package:flutter/material.dart';
import 'package:KhadoAndSons/models/response/book_detail.dart';
import 'package:KhadoAndSons/models/response/book_list.dart';
import 'package:KhadoAndSons/models/response/category.dart';
import 'package:KhadoAndSons/models/response/dashboard_response.dart';
import 'package:KhadoAndSons/network/rest_apis.dart';
import 'package:KhadoAndSons/utils/common.dart';
import 'package:KhadoAndSons/utils/constants.dart';
import 'package:KhadoAndSons/utils/resources/colors.dart';
import 'package:KhadoAndSons/utils/resources/size.dart';
import 'package:KhadoAndSons/utils/widgets.dart';
import 'package:nb_utils/nb_utils.dart';

import '../app_localizations.dart';

class CategoryBooks extends StatefulWidget {
  static String tag = '/CategoryBooks';
  var type;
  var title;
  var categoryId = '';
  CategoryBooks({this.type, this.title, this.categoryId = ''});

  @override
  _CategoryBooksState createState() => _CategoryBooksState();
}

class _CategoryBooksState extends State<CategoryBooks>
    with AfterLayoutMixin<CategoryBooks> {
  var list = List<BookDetail>();
  var subCatList = List<Category>();
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
  var selectedCategory = 0;
  var isDataLoaded = false;

  @override
  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    setState(() {
      isLoadingMoreData = true;
    });
    subCategoryList();
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
      fetchBookList();
    }
  }

  Future<List<BookDetail>> fetchBookList() async {
    isNetworkAvailable().then((bool) {
      if (bool) {
        getCategoryWiseBookDetail(page, subCatList[selectedCategory].categoryId,
                subCatList[selectedCategory].subCategoryId)
            .then((result) {
          BookListResponse response = BookListResponse.fromJson(result);
          setState(() {
            if (page == 1) {
              list.clear();
            }
            isLoadingMoreData = false;
            totalBooks = response.pagination.totalItems;
            isLastPage = page == response.pagination.totalPages;
            if (response.data.isEmpty) {
              isLastPage = true;
            }
            list.addAll(response.data);
            isDataLoaded = true;
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

  Future subCategoryList() async {
    isNetworkAvailable().then((bool) {
      if (bool) {
        var request = {"category_id": widget.categoryId};
        subCategories(request).then((result) {
          SubCategoryResponse response = SubCategoryResponse.fromJson(result);
          if (response.data != null && response.data.isNotEmpty) {
            setState(() {
              subCatList.clear();
              subCatList.add(Category(
                  categoryId: widget.categoryId,
                  subCategoryId: "",
                  name: "ALL BOOKS"));
              subCatList.addAll(response.data);
              selectedCategory = 0;
              isLoadingMoreData = true;
              fetchBookList();
              scrollController.addListener(() {
                scrollHandler();
              });
            });
          } else {
            setState(() {
              isDataLoaded = true;
              isLoadingMoreData = false;
            });
          }
        }).catchError((error) {
          toast(error.toString());
          setState(() {
            isLoadingMoreData = false;
            isLastPage = true;
          });
        });
      } else {
        setState(() {
          isLoadingMoreData = false;
        });
        toast(keyString(context, "error_network_no_internet"));
        finish(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      iconTheme: Theme.of(context).iconTheme,
      centerTitle: subCatList.isEmpty,
      actions: <Widget>[cartIcon(context, cartCount).visible(isUserLogin)],
      title: subCatList.isEmpty
          ? Column(
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
                Text(totalBooks.toString() +
                        ' ' +
                        keyString(context, "lbl_books"))
                    .withStyle(
                        fontSize: ts_medium,
                        fontFamily: font_regular,
                        color: Theme.of(context).textTheme.subtitle.color)
                    .paddingTop(spacing_control_half)
              ],
            )
          : Theme(
              data: ThemeData(canvasColor: Theme.of(context).cardTheme.color),
              child: DropdownButton(
                value: subCatList[selectedCategory].name,
                underline: SizedBox(),
                onChanged: (newValue) {
                  setState(() {
                    for (var i = 0; i < subCatList.length; i++) {
                      if (newValue == subCatList[i].name) {
                        if (selectedCategory != i) {
                          selectedCategory = i;
                          page = 1;
                          setState(() {
                            list.clear();
                            isLoadingMoreData = true;
                          });
                          fetchBookList();
                        }
                      }
                    }
                  });
                },
                items: subCatList.map((category) {
                  return DropdownMenuItem(
                    child: Row(
                      children: <Widget>[
                        headingText(context,
                            category.name != null ? category.name : ""),
                      ],
                    ),
                    value: category.name,
                  );
                }).toList(),
              ),
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
          ).visible(list.isEmpty && !isLoadingMoreData & isDataLoaded)
        ],
      ),
    );
  }
}
