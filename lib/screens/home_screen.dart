import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:KhadoAndSons/models/response/author.dart';
import 'package:KhadoAndSons/models/response/book_detail.dart';
import 'package:KhadoAndSons/models/response/category.dart';
import 'package:KhadoAndSons/models/response/dashboard_response.dart';
import 'package:KhadoAndSons/models/response/slider.dart';
import 'package:KhadoAndSons/network/common_api_calls.dart';
import 'package:KhadoAndSons/network/rest_apis.dart';
import 'package:KhadoAndSons/screens/about_app_screen.dart';
import 'package:KhadoAndSons/screens/author_detail_screen.dart';
import 'package:KhadoAndSons/screens/author_list.dart';
import 'package:KhadoAndSons/screens/cart_screen.dart';
import 'package:KhadoAndSons/screens/category_book_screen.dart';
import 'package:KhadoAndSons/screens/change_password_screen.dart';
import 'package:KhadoAndSons/screens/feedback_screen.dart';
import 'package:KhadoAndSons/screens/library_screen.dart';
import 'package:KhadoAndSons/screens/profile_screen.dart';
import 'package:KhadoAndSons/screens/search_book_screen.dart';
import 'package:KhadoAndSons/screens/setting_screen.dart';
import 'package:KhadoAndSons/screens/signIn.dart';
import 'package:KhadoAndSons/screens/transaction_history_screen.dart';
import 'package:KhadoAndSons/screens/view_all_book_screen.dart';
import 'package:KhadoAndSons/screens/wishlist_screens.dart';
import 'package:KhadoAndSons/utils/slider_widget.dart';
import 'package:KhadoAndSons/utils/admob_utils.dart';
import 'package:KhadoAndSons/utils/common.dart';
import 'package:KhadoAndSons/utils/constants.dart';
import 'package:KhadoAndSons/utils/resources/colors.dart';
import 'package:KhadoAndSons/utils/resources/images.dart';
import 'package:KhadoAndSons/utils/resources/size.dart';
import 'package:KhadoAndSons/utils/widgets.dart';
import 'package:launch_review/launch_review.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share/share.dart';
import 'package:firebase_admob/firebase_admob.dart';

import '../app_localizations.dart';
import 'package:firebase_admob/firebase_admob.dart';

class HomeScreen extends StatefulWidget {
  static String tag = '/HomeScreen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AfterLayoutMixin<HomeScreen> {
  var mCategories = List<Category>();
  var mSliderList = List<HomeSlider>();
  var mNewestBook = List<BookDetail>();
  var mPopularBook = List<BookDetail>();
  var mRecommendedBook = List<BookDetail>();
  var mTopSellingBook = List<BookDetail>();
  var mBestAuthorList = List<AuthorDetail>();
  var mIsFirstTime = true;
  var gradientColor2 = <Color>[
    Color(0xFF48c6ef),
    Color(0xFFF6889D),
    Color(0xFF1e3c72),
    Color(0xFF8360c3),
    Color(0xFF1e130c)
  ];
  var gradientColor1 = <Color>[
    Color(0xFF6f86d6),
    Color(0xFFFd988d),
    Color(0xFF22a5298),
    Color(0xFF2ebf91),
    Color(0xFF9a8478)
  ];
  var colors = [cat_1, cat_2, cat_3, cat_4, cat_5];
  var cartCount = 0;
  var isUserLogin = false;
  DashboardResponse dashboardResponse;
  var isLoading = false;
  var isError = false;
  var noInternetConnection = true;
  var noDataAvailable = false;
  BannerAd _bannerAd;

  Future<Null> fetchDashboardData() async {
    isNetworkAvailable().then((bool) {
      setState(() {
        noInternetConnection = bool;
      });
      if (bool) {
        setState(() {
          isError = false;
          isLoading = true;
        });
        noDataAvailable = true;
        getDashboard().then((res) {
          if (!mounted) {
            return;
          }
          print(res);
          dashboardResponse = DashboardResponse.fromJson(res);
          setState(() {
            isLoading = false;
            if (dashboardResponse.categoryBook != null &&
                dashboardResponse.categoryBook.length > 0) {
              mCategories.clear();
              mCategories.addAll(dashboardResponse.categoryBook);
              noDataAvailable = false;
            }
            if (dashboardResponse.slider != null &&
                dashboardResponse.slider.length > 0) {
              mSliderList.clear();
              mSliderList.addAll(dashboardResponse.slider);
            }
            if (dashboardResponse.topSearchBook != null &&
                dashboardResponse.topSearchBook.length > 0) {
              mNewestBook.clear();
              mNewestBook.addAll(dashboardResponse.topSearchBook);
              noDataAvailable = false;
            }
            if (dashboardResponse.popularBook != null &&
                dashboardResponse.popularBook.length > 0) {
              mPopularBook.clear();
              mPopularBook.addAll(dashboardResponse.popularBook);
              noDataAvailable = false;
            }
            if (dashboardResponse.recommendedBook != null &&
                dashboardResponse.recommendedBook.length > 0) {
              mRecommendedBook.clear();
              mRecommendedBook.addAll(dashboardResponse.recommendedBook);
              noDataAvailable = false;
            }
            if (dashboardResponse.topSellBook != null &&
                dashboardResponse.topSellBook.length > 0) {
              mTopSellingBook.clear();
              mTopSellingBook.addAll(dashboardResponse.topSellBook);
              noDataAvailable = false;
            }
            if (dashboardResponse.topAuthor != null &&
                dashboardResponse.topAuthor.length > 0) {
              mBestAuthorList.clear();
              mBestAuthorList.addAll(dashboardResponse.topAuthor);
              noDataAvailable = false;
            }
          });
          if (dashboardResponse.configuration != null &&
              dashboardResponse.configuration.isNotEmpty) {
            dashboardResponse.configuration.forEach((config) {
              setString(config.key, config.value);
              print(config.key + "*" + config.value);
            });
          }
          setBool(IS_PAYPAL_ENABLED, dashboardResponse.isPayPalEnabled);
          setBool(IS_PAYTM_ENABLED, dashboardResponse.isPayTmEnabled);
        }).catchError((error) {
          toast(error.toString());
          setState(() {
            isError = true;
            isLoading = false;
          });
        });
      } else {
        toast(noInternetMsg);
      }
    });
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    if (mIsFirstTime) {
      FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId);
      _bannerAd = createBannerAd()..load();

      LiveStream().on(CART_COUNT_ACTION, (value) {
        if (!mounted) {
          return;
        }
        setState(() {
          cartCount = value;
        });
      });
      LiveStream().on(CART_ITEM_CHANGED, (value) {
        if (!mounted) {
          return;
        }
        fetchCartData(context);
      });
      LiveStream().on(WISH_DATA_ITEM_CHANGED, (value) {
        if (!mounted) {
          return;
        }
        fetchWishListData(context);
      });
      if (mounted) {
        initOneSingalPlatformState(context);
      }
      isUserLogin = await getBool(IS_LOGGED_IN);
      fetchDashboardData();
      if (isUserLogin) {
        fetchCartData(context);
        fetchWishListData(context);
      }
      mIsFirstTime = false;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: BannerAd.testAdUnitId,
      size: AdSize.banner,
      listener: (MobileAdEvent event) {
        print("BannerAd event $event");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    changeStatusColor(Theme.of(context).scaffoldBackgroundColor);
    var width = MediaQuery.of(context).size.width;
    var slider = Padding(
      padding: const EdgeInsets.only(top: 60.0),
      child:
          mSliderList.isNotEmpty ? HomeSliderWidget(mSliderList) : Container(),
    );
    var categoryList = Container(
      height: width * 0.2,
      margin: EdgeInsets.only(top: spacing_standard_new),
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: mCategories.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CategoryBooks(
                              type: 'category',
                              title: mCategories[index].name,
                              categoryId:
                                  mCategories[index].categoryId.toString(),
                            )));
              },
              child: Container(
                width: width * 0.4,
                height: width * 0.2,
                margin: EdgeInsets.only(
                    left: spacing_standard, right: spacing_control),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.all(Radius.circular(spacing_standard)),
                    gradient: LinearGradient(
                      colors: [
                        gradientColor1[index % gradientColor1.length],
                        gradientColor2[index % gradientColor2.length]
                      ],
                    )),
                child: text(context, mCategories[index].name,
                    textColor: white,
                    fontFamily: font_bold,
                    fontSize: ts_extra_normal,
                    maxLine: 3,
                    isCentered: true),
              ),
            );
          }),
    );

    var authorList = Container(
      height: width * 0.5,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: mBestAuthorList.length,
          itemBuilder: (context, index) {
            return Container(
              width: width * 0.2,
              margin: EdgeInsets.only(left: spacing_standard_new),
              child: Column(
                children: <Widget>[
                  InkWell(
                    radius: width * 0.1,
                    child: CircleAvatar(
                      radius: width * 0.1,
                      backgroundImage: mBestAuthorList[index].image != null
                          ? NetworkImage(mBestAuthorList[index].image)
                          : AssetImage(ic_profile),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AuthorDetailScreen(
                                    authorDetail: mBestAuthorList[index],
                                  )));
                    },
                  ),
                  text(context, mBestAuthorList[index].name,
                          textColor: Theme.of(context).textTheme.title.color,
                          fontFamily: font_medium,
                          maxLine: 2,
                          isCentered: true)
                      .paddingOnly(
                          left: spacing_control, right: spacing_control)
                ],
              ),
            ).paddingTop(spacing_standard_new);
          }),
    );

    var popularbookList = BookHorizontalList(
      mPopularBook,
      isHorizontal: true,
    );

    var newBook =
        BookHorizontalList(mNewestBook).visible(mNewestBook.isNotEmpty);

    var recoomBooks = BookHorizontalList(mRecommendedBook)
        .visible(mRecommendedBook.isNotEmpty);

    var topSeelling =
        BookHorizontalList(mTopSellingBook).visible(mTopSellingBook.isNotEmpty);

    var containerBody = dashboardResponse != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              horizontalHeading(context, keyString(context, "top_search_books"),
                  callback: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewAllBooks(
                              type: type_top_search,
                              title: keyString(context, "top_search_books"),
                            )));
              }).visible(dashboardResponse.topSearchBook != null &&
                  dashboardResponse.topSearchBook.isNotEmpty),
              newBook.visible(dashboardResponse.topSearchBook != null &&
                  dashboardResponse.topSearchBook.isNotEmpty),
              horizontalHeading(context, keyString(context, "lbl_collections"),
                      showViewAll: false)
                  .visible(dashboardResponse.categoryBook != null &&
                      dashboardResponse.categoryBook.isNotEmpty),
              categoryList.paddingOnly(bottom: spacing_standard_new).visible(
                  dashboardResponse.categoryBook != null &&
                      dashboardResponse.categoryBook.isNotEmpty),
              horizontalHeading(
                  context, keyString(context, "recommended_books"),
                  callback: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewAllBooks(
                              type: type_recommended,
                              title: keyString(context, "recommended_books"),
                            )));
              }).visible(dashboardResponse.recommendedBook != null &&
                  dashboardResponse.recommendedBook.isNotEmpty),
              recoomBooks.visible(dashboardResponse.recommendedBook != null &&
                  dashboardResponse.recommendedBook.isNotEmpty),
              horizontalHeading(context, keyString(context, "popular_books"),
                  callback: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewAllBooks(
                              type: type_popular,
                              title: keyString(context, "popular_books"),
                            )));
              }).visible(dashboardResponse.recommendedBook != null &&
                  dashboardResponse.recommendedBook.isNotEmpty),
              popularbookList.visible(
                  dashboardResponse.recommendedBook != null &&
                      dashboardResponse.recommendedBook.isNotEmpty),
              horizontalHeading(context, keyString(context, "lbl_top_selling"),
                  callback: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewAllBooks(
                              type: type_top_sell,
                              title: keyString(context, "lbl_top_selling"),
                            )));
              }).visible(dashboardResponse.topSellBook != null &&
                  dashboardResponse.topSellBook.isNotEmpty),
              topSeelling.visible(dashboardResponse.topSellBook != null &&
                  dashboardResponse.topSellBook.isNotEmpty),
              horizontalHeading(context, keyString(context, "best_author"),
                  callback: () {
                launchScreen(context, AuthorsListScreen.tag);
              }).visible(dashboardResponse.topAuthor != null &&
                  dashboardResponse.topAuthor.isNotEmpty),
              authorList.visible(dashboardResponse.topAuthor != null &&
                  dashboardResponse.topAuthor.isNotEmpty),
            ],
          )
        : Container();

    var someError = Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(icon_error_illus, width: 70, height: 70),
          text(context, keyString(context, "error_something_wrong")),
          MaterialButton(
            textColor: Theme.of(context).textTheme.title.color,
            child: text(context, keyString(context, "lbl_try_again"),
                fontSize: ts_normal,
                textColor: Theme.of(context).textTheme.title.color),
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(5.0),
              side: BorderSide(color: Theme.of(context).textTheme.title.color),
            ),
            onPressed: () {
              fetchDashboardData();
            },
          )
        ],
      ),
    ).visible(isError && dashboardResponse == null);

    var noInternetError = Container(
      alignment: Alignment.center,
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            icon_antenna,
            width: 120,
            height: 120,
          ),
          text(context, keyString(context, "error_network_no_internet"),
                  textColor: Theme.of(context).textTheme.title.color,
                  fontFamily: font_medium,
                  fontSize: ts_medium_large)
              .paddingTop(spacing_standard_new),
          MaterialButton(
            padding:
                EdgeInsets.fromLTRB(30, spacing_standard, 30, spacing_standard),
            textColor: white,
            child: text(context, keyString(context, "lbl_try_again"),
                fontSize: ts_normal,
                textColor: Theme.of(context).textTheme.title.color,
                fontFamily: font_medium),
            color: Colors.amber,
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(5.0),
              side: BorderSide(color: Colors.amber),
            ),
            onPressed: () {
              fetchDashboardData();
            },
          ).paddingTop(spacing_standard_new)
        ],
      ),
    ).visible(!noInternetConnection && dashboardResponse == null);
    var noData = Container(
      alignment: Alignment.center,
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            no_data,
            width: 180,
            height: 180,
          ),
          text(context, "No Books available",
                  textColor: Theme.of(context).textTheme.subtitle.color,
                  fontFamily: font_medium,
                  fontSize: ts_large)
              .paddingTop(spacing_standard_new),
        ],
      ),
    ).visible(noDataAvailable && !isLoading && !isError);
    GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
          child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: mSliderList.isNotEmpty
                  ? (MediaQuery.of(context).size.width * 0.55) + 60
                  : 60,
              floating: false,
              pinned: true,
              titleSpacing: 0,
              leading: InkWell(
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: SvgPicture.asset(
                    icon_menu,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
                onTap: () {
                  _scaffoldKey.currentState.openDrawer();
                },
                radius: spacing_standard_new,
              ),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              actionsIconTheme: Theme.of(context).iconTheme,
              actions: <Widget>[
                InkWell(
                  child: Container(
                    width: 40,
                    height: 40,
                    padding: EdgeInsets.all(spacing_middle),
                    child: SvgPicture.asset(
                      icon_search,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                  onTap: () {
                    launchScreen(context, SearchScreen.tag);
                  },
                  radius: spacing_standard_new,
                ),
                cartIcon(context, cartCount).visible(isUserLogin)
              ],
              title: toolBarTitle(context, keyString(context, "app_name")),
              flexibleSpace: FlexibleSpaceBar(
                background: slider,
              ),
            ),
          ];
        },
        body: RefreshIndicator(
          onRefresh: () {
            fetchDashboardData();
            return;
          },
          child: Stack(
            children: <Widget>[
              dashboardResponse != null
                  ? SingleChildScrollView(
                      child: containerBody,
                    )
                  : Container(),
              someError,
              noInternetError,
              noData,
              Center(
                child: loadingWidgetMaker(),
              ).visible(isLoading)
            ],
          ),
        ),
      )),
      drawer: HomeDrawer(),
    );
  }
}

class HomeSliderWidget extends StatelessWidget {
  List<HomeSlider> mSliderList;

  HomeSliderWidget(this.mSliderList);

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    width = width - 50;
    final Size cardSize = Size(width, width / 1.8);
    return SliderWidget(
      viewportFraction: 0.9,
      height: cardSize.height,
      enlargeCenterPage: true,
      scrollDirection: Axis.horizontal,
      items: mSliderList.map((slider) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              height: cardSize.height,
              margin: EdgeInsets.symmetric(horizontal: spacing_control),
              child: Card(
                semanticContainer: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                elevation: spacing_control,
                margin: EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: networkImage(slider.slideImage),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

class HomeDrawer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeDrawerState();
  }
}

class HomeDrawerState extends State<HomeDrawer> {
  var selectedItem = -1;
  var userProfile;
  var userName;
  var userEmail;
  var isUserLogin = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    var pref = await getSharedPref();
    setState(() {
      isUserLogin = pref.getBool(IS_LOGGED_IN) ?? false;
      userProfile = pref.getString(USER_PROFILE) ?? '';
      userName = pref.getString(USERNAME) ?? '';
      userEmail = pref.getString(USER_EMAIL) ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    var profileWidget = Container(
      alignment: Alignment.bottomLeft,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          spacing_standard_new, 40, spacing_standard_new, 40),
      color: Theme.of(context).primaryColor,
      /*User Profile*/
      child: isUserLogin
          ? GestureDetector(
              onTap: () {
                callNext(context, ProfileScreen.tag);
              },
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: userProfile != null
                        ? NetworkImage(userProfile)
                        : AssetImage(ic_profile),
                    radius: 40,
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          text(context, userName,
                              textColor: white,
                              fontFamily: font_bold,
                              fontSize: ts_medium_large),
                          SizedBox(height: 8),
                          text(context, userEmail,
                              textColor: white, fontSize: ts_normal),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )
          : GestureDetector(
              onTap: () {
                callNext(context, SignIn.tag);
              },
              child: text(context, keyString(context, "lbl_login"),
                      textColor: white, fontFamily: font_bold, fontSize: 25)
                  .paddingAll(spacing_standard_new)),
    );
    var body = Container(
      width: MediaQuery.of(context).size.width,
      color: Theme.of(context).cardTheme.color,
      child: Column(
        children: <Widget>[
          profileWidget,
          SizedBox(
            height: 30,
          ),
          getDrawerItem(icon_home, keyString(context, "lbl_dashboard"),
              pos: () {
            Navigator.of(context).pop();
          }),
          getDrawerItem(icon_book, keyString(context, "lbl_my_library"),
              pos: () {
            callNext(context, LibraryScreen.tag);
          }),
          getDrawerItem(icon_cart, keyString(context, "lbl_my_cart"), pos: () {
            callNext(context, CartScreen.tag);
          }).visible(isUserLogin),
          SizedBox(
            height: 20,
          ),
          Divider(
            height: 1,
          ),
          SizedBox(height: 20),
          Column(
            children: <Widget>[
              getDrawerItem(icon_bookmark, keyString(context, "lbl_wish_list"),
                  pos: () {
                callNext(context, WishlistScreen.tag);
              }),
              getDrawerItem(
                  icon_bank, keyString(context, "lbl_transaction_history"),
                  pos: () {
                callNext(context, TransactionHistoryScreen.tag);
              }),
              getDrawerItem(
                  icon_password, keyString(context, "lbl_change_password"),
                  pos: () {
                callNext(context, ChangePasswordScreen.tag);
              }),
              getDrawerItem(icon_logout, keyString(context, "lbl_logout"),
                  pos: () {
                doLogout(context);
              }),
              SizedBox(height: 20),
              Divider(
                height: 1,
              ),
              SizedBox(height: 20),
            ],
          ).visible(isUserLogin),
          getDrawerItem(icon_settings, keyString(context, "settings"), pos: () {
            callNext(context, SettingScreen.tag);
          }),
          getDrawerItem(icon_share, keyString(context, "lbl_share_app"),
              pos: () {
            Share.share('check out my website https://google.com');
          }),
          getDrawerItem(icon_rate, keyString(context, "lbl_rate_app"), pos: () {
            LaunchReview.launch();
          }),
          getDrawerItem(icon_shield, keyString(context, "lbl_privacy_policy"),
              pos: () {
            redirectUrl("https://www.google.com");
          }),
          getDrawerItem(
              icon_contract, keyString(context, "lbl_terms_amp_condition"),
              pos: () {
            redirectUrl("https://www.google.com");
          }),
          getDrawerItem(icon_blog, keyString(context, "lbl_feedback"), pos: () {
            callNext(context, FeedbackScreen.tag);
          }),
          getDrawerItem(icon_info, keyString(context, "lbl_about_app"),
              pos: () {
            callNext(context, AboutApp.tag);
          }),
        ],
      ),
    );
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: MediaQuery.of(context).size.height,
      color: Theme.of(context).cardTheme.color,
      child: Drawer(
        elevation: 8,
        child: SafeArea(
          child: SingleChildScrollView(
            child: body,
          ),
        ),
      ),
    );
  }

  callNext(context, tag) {
    Navigator.of(context).pop();
    launchScreen(context, tag);
  }

  Widget getDrawerItem(String icon, String name, {VoidCallback pos}) {
    return InkWell(
      onTap: pos,
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 14, 20, 14),
        child: Row(
          children: <Widget>[
            SvgPicture.asset(
              icon,
              width: 20,
              height: 20,
              color: Theme.of(context).iconTheme.color,
            ),
            SizedBox(width: 20),
            text(context, name,
                textColor: Theme.of(context).textTheme.title.color,
                fontSize: ts_normal,
                fontFamily: font_medium)
          ],
        ),
      ),
    );
  }
}
