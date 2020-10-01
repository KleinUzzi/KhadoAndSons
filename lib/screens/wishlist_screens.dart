import 'package:flutter/material.dart';
import 'package:KhadoAndSons/models/response/book_detail.dart';
import 'package:KhadoAndSons/models/response/wishlist_response.dart';
import 'package:KhadoAndSons/network/common_api_calls.dart';
import 'package:KhadoAndSons/screens/book_description_screen.dart';
import 'package:KhadoAndSons/utils/common.dart';
import 'package:KhadoAndSons/utils/constants.dart';
import 'package:KhadoAndSons/utils/resources/colors.dart';
import 'package:KhadoAndSons/utils/resources/size.dart';
import 'package:KhadoAndSons/utils/widgets.dart';
import 'package:nb_utils/nb_utils.dart';
import '../app_localizations.dart';

class WishlistScreen extends StatefulWidget {
  static String tag = '/WishlistScreen';

  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen>
    with AfterLayoutMixin<WishlistScreen> {
  var list = List<WishListItem>();
  var mIsFirstTime = true;
  var cartCount = 0;
  var isUserLogin = false;
  var liveStream;

  @override
  void afterFirstLayout(BuildContext context) async {
    if (mIsFirstTime) {
      liveStream = LiveStream();
      var wishListItemList = await wishListItems();
      isUserLogin = await getBool(IS_LOGGED_IN);
      var count = await getInt(CART_COUNT);
      setState(() {
        list.addAll(wishListItemList);
        if (isUserLogin) {
          cartCount = count;
        }
      });
      liveStream.on(WISH_LIST_DATA_CHANGED, (value) {
        if (mounted) {
          if (value != null) {
            setState(() {
              list.clear();
              list.addAll(value);
            });
          }
        }
      });
      liveStream.on(CART_COUNT_ACTION, (value) {
        if (!mounted) {
          return;
        }
        setState(() {
          cartCount = value;
        });
      });
    }
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
        children: <Widget>[
          headingText(context, keyString(context, "lbl_wish_list"))
              .paddingTop(spacing_standard_new),
          Text(list.length.toString() + ' ' + keyString(context, "lbl_books"))
              .withStyle(
                  fontSize: ts_medium,
                  fontFamily: font_regular,
                  color: textColorSecondary)
              .paddingTop(spacing_control_half)
        ],
      ),
    );

    final wishlist = Container(
      child: GridView.builder(
        itemCount: list.length,
        shrinkWrap: true,
        padding: EdgeInsets.only(
            bottom: 70,
            left: spacing_control,
            right: spacing_control,
            top: spacing_control),
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, childAspectRatio: 9 / 19),
        scrollDirection: Axis.vertical,
        controller: ScrollController(keepScrollOffset: false),
        itemBuilder: (context, index) {
          WishListItem bookDetail = list[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BookDescriptionScreen(
                              bookDetail:
                                  BookDetail(bookId: bookDetail.book_id))));
                },
                child: AspectRatio(
                  aspectRatio: 6 / 9,
                  child: Card(
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    elevation: spacing_control_half,
                    margin: EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(spacing_control),
                    ),
                    child: networkImage(
                      bookDetail.front_cover,
                    ),
                  ),
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
                      fontSize: ts_medium)
                  .paddingOnly(right: 8, bottom: 0, top: 8),
              Text(
                bookDetail.author_name,
                maxLines: 1,
              )
                  .withStyle(
                      color: textColorSecondary,
                      fontFamily: font_regular,
                      fontSize: ts_medium)
                  .paddingOnly(right: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Wrap(
                      children: <Widget>[
                        text(
                                context,
                                bookDetail.discount != 0
                                    ? discountedPrice(
                                            tryParse(bookDetail.price),
                                            tryParse(bookDetail.discount))
                                        .toString()
                                        .toCurrencyFormat()
                                    : bookDetail.price
                                        .toString()
                                        .toCurrencyFormat(),
                                textColor:
                                    Theme.of(context).textTheme.title.color,
                                fontFamily: font_medium)
                            .visible(bookDetail.price != 0),
                        text(context,
                                bookDetail.price.toString().toCurrencyFormat(),
                                aDecoration: TextDecoration.lineThrough,
                                fontSize: ts_medium_small)
                            .paddingOnly(left: spacing_control_half)
                            .visible(bookDetail.discount != 0),
                      ],
                    ),
                  ),
                  InkWell(
                      onTap: () {
                        addBookToCart(context, bookDetail.book_id,
                            removeFromWishList: true);
                      },
                      child: Icon(
                        Icons.add_shopping_cart,
                        color: textColorSecondary,
                        size: 18,
                      )).visible(bookDetail.price != 0)
                ],
              )
            ],
          ).paddingAll(8);
        },
      ),
    );

    return Scaffold(
      appBar: appBar,
      body: SingleChildScrollView(child: wishlist),
    );
  }
}
