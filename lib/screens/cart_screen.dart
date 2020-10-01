import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:KhadoAndSons/models/request/order_detail.dart';
import 'package:KhadoAndSons/models/response/book_detail.dart';
import 'package:KhadoAndSons/models/response/braintree_payment_responses.dart';
import 'package:KhadoAndSons/models/response/cart_response.dart';
import 'package:KhadoAndSons/models/response/wishlist_response.dart';
import 'package:KhadoAndSons/network/common_api_calls.dart';
import 'package:KhadoAndSons/network/rest_apis.dart';
import 'package:KhadoAndSons/screens/book_description_screen.dart';
import 'package:KhadoAndSons/utils/common.dart';
import 'package:KhadoAndSons/utils/constants.dart';
import 'package:KhadoAndSons/utils/payment/cart_payment.dart';
import 'package:KhadoAndSons/utils/resources/colors.dart';
import 'package:KhadoAndSons/utils/resources/images.dart';
import 'package:KhadoAndSons/utils/resources/size.dart';
import 'package:KhadoAndSons/utils/widgets.dart';
import 'package:nb_utils/nb_utils.dart';

import '../app_localizations.dart';

class CartScreen extends StatefulWidget {
  static String tag = '/CartScreen';

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with AfterLayoutMixin<CartScreen> {
  var list = List<CartItem>();
  var wishList = List<WishListItem>();
  double width;
  var mIsFirstTime = true;
  var totalMrp = 0.0;
  var total = 0.0;
  var discount = 0.0;
  var paymentMethod = "";
  var userId;
  var userEmail;
  var phoneNo;
  var wishListCount = 0;
  var platform;
  bool isPayPalEnabled = false;
  bool isPayTmEnabled = false;
  var authorization;

  @override
  void initState() {
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    if (mIsFirstTime) {
      platform = Theme.of(context).platform;
      isPayPalEnabled = await getBool(IS_PAYPAL_ENABLED);
      isPayTmEnabled = await getBool(IS_PAYTM_ENABLED);
      LiveStream().on(CART_DATA_CHANGED, (value) {
        if (mounted) {
          if (value != null) {
            showLoading(false);
            setCartItem(value);
          }
        }
      });
      LiveStream().on(WISH_LIST_DATA_CHANGED, (value) {
        if (mounted) {
          if (value != null) {
            showLoading(false);
            setWishListItem(value);
          }
        }
      });
      var cartItemList = await cartItems();
      setCartItem(cartItemList);
      var wishListItemList = await wishListItems();
      setWishListItem(wishListItemList);
      userId = await getInt(USER_ID);
      userEmail = await getString(USER_EMAIL) ?? "";
      phoneNo = await getString(USER_CONTACT_NO) ?? "";
    }
  }

  getClientToken(context) async {
    showLoading(true);
    isNetworkAvailable().then((bool) {
      if (bool) {
        generateClientToken().then((result) async {
          print(result);
          ClientTokenResponse response = ClientTokenResponse.fromJson(result);
          processBrainTreePayment(context, response.data);
        }).catchError((error) {
          print(error);
          toast(error.toString());
          finish(context);
          showLoading(false);
        });
      } else {
        toast(keyString(context, "error_network_no_internet"));
        finish(context);
        showLoading(false);
      }
    });
  }

  void setCartItem(List<CartItem> cartItems) {
    setState(() {
      list.clear();
      list.addAll(cartItems);
      var mrp = 0.0;
      var discounts = 0.0;
      list.forEach((cartItem) {
        mrp += tryParse(cartItem.price.toString()) ?? 0;
        discounts += getPercentageRate(tryParse(cartItem.price.toString()),
            tryParse(cartItem.discount.toString()));
      });
      totalMrp = mrp;
      discount = discounts;
      total = mrp - discounts;
    });
  }

  void setWishListItem(List<WishListItem> cartItems) {
    setState(() {
      wishList.clear();
      wishList.addAll(cartItems);
      wishListCount = cartItems.length;
    });
  }

  bool isLoading = false;

  showLoading(bool show) {
    setState(() {
      isLoading = show;
    });
  }

  OrderDetail getOrderDetail() {
    var orderDetail = OrderDetail();
    var otherOrder = List<BookData>();
    list.forEach((cartItem) {
      orderDetail.book_id = cartItem.book_id;
      orderDetail.price = cartItem.price;
      orderDetail.discount = cartItem.price;
      orderDetail.quantity = cartItem.addedQty;
      orderDetail.cash_on_delivery = cartItem.cash_on_delivery;
      BookData otherOrderData = BookData();
      otherOrderData.book_id = cartItem.book_id;
      otherOrderData.discount = cartItem.discount;
      otherOrderData.price = cartItem.price;
      otherOrder.add(otherOrderData);
    });
    orderDetail.other_detail = OtherDetail(data: otherOrder);
    orderDetail.gstnumber = "";
    orderDetail.is_hard_copy = "1";
    orderDetail.shipping_cost = "";
    orderDetail.total_amount = total.toString();
    orderDetail.user_id = userId;
    orderDetail.discount = discount;
    orderDetail.payment_type = 1;
    orderDetail.gstnumber = "";
    orderDetail.is_hard_copy = "1";
    return orderDetail;
  }

  processPayTmPayment(context) async {
    showLoading(true);
    CartPayment.payWithPayTm(
            context, total, getOrderDetail().toJson(), paymentMethod)
        .then((result) {
      showLoading(false);
      LiveStream().emit(CART_ITEM_CHANGED, true);
    }).catchError((error) {
      toast(error);
      showLoading(false);
    });
    /* if(paymentMethod==PAYTM){

    }else if(paymentMethod==PAYPAL){
      CartPayment.paywithPayPal(context,authorization,total.toString(), orderDetail.toJson()).then((result) {
        showLoading(false);
        LiveStream().emit(CART_ITEM_CHANGED, true);
      }).catchError((error) {
        toast(error);
        showLoading(false);
      });
    }*/
  }

  processBrainTreePayment(context, token) async {
    showLoading(true);
    CartPayment.paywithPayPal(
            context, token, total.toString(), getOrderDetail().toJson())
        .then((res) {
      print(res + "paypal********************");
    }).catchError((error) {
      showLoading(false);
      toast(error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    placeOrder() {
      if (!isPayTmEnabled && !isPayPalEnabled) {
        toast("Payment option are not available");
        return;
      }
      if (paymentMethod.isNotEmpty) {
        if (paymentMethod == PAYPAL) {
          getClientToken(context);
        } else if (paymentMethod == PAYTM) {
          processPayTmPayment(context);
        }
      } else {
        toast(keyString(context, "error_select_payment_option"));
      }

      toast(keyString(context, "lbl_processing"));
    }

    final cartItems = list.isNotEmpty
        ? ListView.builder(
            itemCount: list.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return cartItemRow(list[index]);
            })
        : Container();

    final priceDetail = Container(
      decoration: boxDecoration(context, showShadow: true),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                  child: text(context, keyString(context, "lbl_total_mrp"),
                      fontSize: ts_normal)),
              text(context, totalMrp.toString().toCurrencyFormat(),
                  fontSize: ts_normal,
                  textColor: Theme.of(context).textTheme.title.color),
            ],
          ).paddingAll(spacing_standard_new),
          Row(
            children: <Widget>[
              Expanded(
                  child: text(context, keyString(context, "lbl_discount"),
                      fontSize: ts_normal)),
              text(context, "-" + discount.toString().toCurrencyFormat(),
                  textColor: Colors.green, fontSize: ts_normal),
            ],
          ).paddingOnly(
              left: spacing_standard_new,
              right: spacing_standard_new,
              bottom: spacing_standard),
          Divider(
            thickness: 0.8,
          ),
          Row(
            children: <Widget>[
              Expanded(
                  child: text(context, keyString(context, "lbl_total"),
                      textColor: Theme.of(context).textTheme.title.color,
                      fontFamily: font_semi_bold,
                      fontSize: ts_normal)),
              text(context, total.toString().toCurrencyFormat(),
                  textColor: Theme.of(context).textTheme.title.color,
                  fontSize: ts_normal,
                  fontFamily: font_bold),
            ],
          ).paddingOnly(
              left: spacing_standard_new,
              right: spacing_standard_new,
              top: spacing_control,
              bottom: spacing_standard_new),
        ],
      ),
    ).paddingOnly(
        left: spacing_standard_new,
        right: spacing_standard_new,
        bottom: spacing_control);

    final next = Container(
      color: Theme.of(context).cardTheme.color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Wrap(
            children: <Widget>[
              text(context, keyString(context, "lbl_total_amount"),
                  textColor: Theme.of(context).textTheme.title.color,
                  fontFamily: font_medium,
                  fontSize: ts_normal),
              text(context, total.toString().toCurrencyFormat(),
                  textColor: Theme.of(context).textTheme.title.color,
                  fontFamily: font_bold,
                  fontSize: ts_extra_normal),
            ],
          ),
          MaterialButton(
            child: text(context, keyString(context, "lbl_place_order"),
                textColor: white, fontSize: ts_normal, fontFamily: font_medium),
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(spacing_control))),
            elevation: 5.0,
            minWidth: 150,
            height: 40,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              if (!isLoading) {
                placeOrder();
              }
            },
          ),
        ],
      ).paddingOnly(left: 16, right: 16, top: 8, bottom: 8),
    ).withShadow();

    var paymentOptions = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        headingText(context, keyString(context, "lbl_payment_method"))
            .paddingAll(16)
            .visible(isPayPalEnabled || isPayTmEnabled),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: boxDecoration(context, showShadow: true),
                padding: EdgeInsets.all(spacing_standard_new),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Image.asset(
                          icon_paytm,
                          width: 60,
                          height: 30,
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: paymentMethod == PAYTM
                                  ? Theme.of(context).primaryColor
                                  : null,
                              border: paymentMethod == PAYTM
                                  ? null
                                  : Border.all(color: Colors.grey, width: 0.5)),
                          child: Icon(
                            Icons.done,
                            color: white,
                            size: 16,
                          ).visible(paymentMethod == PAYTM),
                        )
                      ],
                    ),
                    text(context, keyString(context, "lbl_paytm"),
                            textColor: Theme.of(context).textTheme.title.color,
                            fontFamily: font_bold,
                            fontSize: ts_normal)
                        .paddingTop(spacing_standard)
                  ],
                ),
              ).onTap(() {
                setState(() {
                  paymentMethod = PAYTM;
                });
              }).paddingRight(spacing_standard),
            ).visible(isPayTmEnabled),
            Expanded(
              child: Container(
                decoration: boxDecoration(context, showShadow: true),
                padding: EdgeInsets.all(spacing_standard_new),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SvgPicture.asset(
                          icon_paypal,
                          width: 30,
                          height: 30,
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: paymentMethod == PAYPAL
                                  ? Theme.of(context).primaryColor
                                  : null,
                              border: paymentMethod == PAYPAL
                                  ? null
                                  : Border.all(color: Colors.grey, width: 0.5)),
                          child: Icon(
                            Icons.done,
                            color: white,
                            size: 16,
                          ).visible(paymentMethod == PAYPAL),
                        )
                      ],
                    ),
                    text(context, keyString(context, "lbl_paypal"),
                            textColor: Theme.of(context).textTheme.title.color,
                            fontFamily: font_bold,
                            fontSize: ts_normal)
                        .paddingTop(spacing_standard)
                  ],
                ),
              ).onTap(() {
                setState(() {
                  paymentMethod = PAYPAL;
                });
              }).paddingLeft(spacing_standard),
            ).visible(isPayPalEnabled)
          ],
        ).paddingOnly(left: spacing_standard_new, right: spacing_standard_new)
      ],
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: headingText(context, keyString(context, "lbl_cart")),
        centerTitle: true,
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: <Widget>[
          Badge(
            badgeContent:
                text(context, wishListCount.toString(), textColor: white),
            badgeColor: Colors.red,
            showBadge: wishListCount > 0,
            position: BadgePosition.topEnd(end: -5),
            animationType: BadgeAnimationType.fade,
            child: SvgPicture.asset(
              icon_bookmark,
              height: 24,
              width: 24,
              color: Theme.of(context).textTheme.title.color,
            ),
          ).paddingAll(12).onTap(() {
            if (wishListCount > 0) {
              showBottomSheetDialog(context);
            } else {
              toast(keyString(context, "error_wishlist_empty"));
            }
          })
        ],
      ),
      body: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () {
                    LiveStream().emit(CART_ITEM_CHANGED, true);
                    LiveStream().emit(WISH_DATA_ITEM_CHANGED, true);
                    return null;
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        headingText(
                                context, keyString(context, "lbl_cart_items"))
                            .paddingAll(16),
                        cartItems,
                        headingText(context,
                                keyString(context, "lbl_payment_detail"))
                            .paddingAll(16),
                        priceDetail,
                        paymentOptions
                      ],
                    ).paddingBottom(70),
                  ),
                ),
              ).visible(list.isNotEmpty),
              Container(
                alignment: Alignment.center,
                child: Column(
                  children: <Widget>[
                    SvgPicture.asset(ic_empty, width: 180, height: 180),
                    text(context, keyString(context, "error_cart_empty"),
                            textColor: textColorSecondary,
                            fontFamily: font_bold,
                            fontSize: ts_large)
                        .paddingTop(spacing_standard_new),
                  ],
                ),
              ).visible(list.isEmpty),
              next.visible(list.isNotEmpty)
            ],
          ),
          Center(
            child: loadingWidgetMaker(),
          ).visible(isLoading)
        ],
      ),
    );
  }

  showBottomSheetDialog(context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      isDismissible: true,
      backgroundColor: Theme.of(context).cardTheme.color,
      builder: (context) {
        return Container(
          height: width * 0.45 + 70,
          margin: EdgeInsets.only(top: spacing_standard_new),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: wishListCount,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(left: spacing_standard_new),
                width: width * 0.28,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    InkWell(
                      child: Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        elevation: spacing_control_half,
                        margin: EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(spacing_control),
                        ),
                        child: networkImage(
                          wishList[index].front_cover,
                          aWidth: width * 0.28,
                          aHeight: width * 0.4,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BookDescriptionScreen(
                                    bookDetail: BookDetail(
                                        bookId: wishList[index].book_id))));
                      },
                      radius: spacing_control,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            wishList[index].name,
                            maxLines: 2,
                          )
                              .withStyle(
                                  color:
                                      Theme.of(context).textTheme.title.color,
                                  fontFamily: font_medium,
                                  fontSize: ts_medium)
                              .paddingTop(spacing_standard),
                          Text(
                            wishList[index].author_name,
                            maxLines: 1,
                          ).withStyle(
                              color: textColorSecondary,
                              fontFamily: font_regular,
                              fontSize: ts_medium_small),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Row(
                                  children: <Widget>[
                                    text(
                                            context,
                                            wishList[index].discount != 0
                                                ? discountedPrice(
                                                        tryParse(wishList[index]
                                                            .price),
                                                        tryParse(wishList[index]
                                                            .discount))
                                                    .toString()
                                                    .toCurrencyFormat()
                                                : wishList[index]
                                                    .price
                                                    .toString()
                                                    .toCurrencyFormat(),
                                            textColor: Theme.of(context)
                                                .textTheme
                                                .title
                                                .color,
                                            fontFamily: font_medium)
                                        .visible(wishList[index].price != 0),
                                    text(
                                            context,
                                            wishList[index]
                                                .price
                                                .toString()
                                                .toCurrencyFormat(),
                                            aDecoration:
                                                TextDecoration.lineThrough,
                                            fontSize: ts_medium_small)
                                        .paddingOnly(left: spacing_control_half)
                                        .visible(wishList[index].discount != 0),
                                  ],
                                ),
                              ),
                              InkWell(
                                  onTap: () {
                                    addBookToCart(
                                        context, wishList[index].book_id,
                                        removeFromWishList: true);
                                    finish(context);
                                  },
                                  child: Icon(
                                    Icons.add_shopping_cart,
                                    color: textColorSecondary,
                                    size: 18,
                                  )).visible(wishList[index].price != 0)
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ).paddingAll(8);
      },
    );
  }

  Widget cartItemRow(CartItem cartItem) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(spacing_standard_new, spacing_control,
          spacing_standard_new, spacing_control),
      decoration:
          boxDecoration(context, showShadow: true, radius: spacing_control),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              elevation: spacing_control,
              margin: EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(spacing_control),
              ),
              child: networkImage(cartItem.front_cover,
                  aWidth: width * 0.24,
                  aHeight: width * 0.34,
                  fit: BoxFit.fill),
            ).paddingAll(spacing_standard),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      text(context, cartItem.name,
                              textColor:
                                  Theme.of(context).textTheme.title.color,
                              fontFamily: font_bold,
                              fontSize: ts_normal,
                              maxLine: 2)
                          .paddingOnly(
                              left: spacing_standard, top: spacing_control),
                      text(context, cartItem.author_name, fontSize: ts_normal)
                          .paddingOnly(
                              left: spacing_standard, bottom: spacing_control),
                      Row(
                        children: <Widget>[
                          text(
                                  context,
                                  cartItem.discount != 0
                                      ? discountedPrice(
                                              tryParse(
                                                  cartItem.price.toString()),
                                              tryParse(
                                                  cartItem.discount.toString()))
                                          .toString()
                                          .toCurrencyFormat()
                                      : cartItem.price
                                          .toString()
                                          .toCurrencyFormat(),
                                  textColor:
                                      Theme.of(context).textTheme.title.color,
                                  fontSize: ts_extra_normal,
                                  fontFamily: font_medium)
                              .visible(cartItem.price != 0),
                          text(
                            context,
                            cartItem.price.toString().toCurrencyFormat(),
                            fontSize: ts_normal,
                            aDecoration: TextDecoration.lineThrough,
                          )
                              .paddingOnly(left: spacing_standard)
                              .visible(cartItem.discount != 0),
                          text(
                            context,
                            cartItem.discount.toString() +
                                keyString(context, "lbl_off"),
                            fontFamily: font_medium,
                            fontSize: ts_normal,
                            textColor: Colors.red,
                          )
                              .paddingOnly(left: spacing_standard)
                              .visible(cartItem.discount != 0),
                        ],
                      ).paddingLeft(
                        spacing_standard,
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Divider(
                        height: 0.5,
                        color: Theme.of(context).dividerColor,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.bookmark_border,
                                size: 20,
                                color: grey_color,
                              ),
                              Text(keyString(context, "lbl_move_to_wishlist"))
                                  .withStyle(
                                      fontSize: 14,
                                      fontFamily: font_regular,
                                      color: textColorSecondary),
                            ],
                          )
                              .paddingOnly(
                                  top: spacing_standard,
                                  bottom: spacing_standard)
                              .onTap(() {
                            removeBookFromCart(context, cartItem,
                                addToWishList: true);
                          }),
                          Container(
                            width: 0.5,
                            height: 30,
                            color: Theme.of(context).dividerColor,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: grey_color,
                              ),
                              Text(keyString(context, "lbl_remove")).withStyle(
                                  fontSize: 14,
                                  fontFamily: font_regular,
                                  color: textColorSecondary),
                            ],
                          )
                              .paddingOnly(
                                  top: spacing_standard,
                                  bottom: spacing_standard)
                              .onTap(() {
                            removeBookFromCart(context, cartItem);
                          })
                        ],
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
