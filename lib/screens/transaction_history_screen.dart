import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:KhadoAndSons/models/response/transaction_history.dart';
import 'package:KhadoAndSons/network/rest_apis.dart';
import 'package:KhadoAndSons/utils/common.dart';
import 'package:KhadoAndSons/utils/constants.dart';
import 'package:KhadoAndSons/utils/resources/colors.dart';
import 'package:KhadoAndSons/utils/resources/size.dart';
import 'package:KhadoAndSons/utils/widgets.dart';
import 'package:nb_utils/nb_utils.dart';

import '../app_localizations.dart';

class TransactionHistoryScreen extends StatefulWidget {
  static String tag = '/TransactionHistoryScreen';

  @override
  _TransactionHistoryScreenState createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen>
    with AfterLayoutMixin<TransactionHistoryScreen> {
  var mIsFirstTime = true;
  var cartCount = 0;
  var list = List<Transaction>();

  @override
  void afterFirstLayout(BuildContext context) async {
    if (mIsFirstTime) {
      fetchTransactionHistory();
      cartCount = await getInt(CART_COUNT);
    }
  }

  bool isLoading = false;

  showLoading(bool show) {
    setState(() {
      isLoading = show;
    });
  }

  fetchTransactionHistory() async {
    isNetworkAvailable().then((bool) {
      if (bool) {
        showLoading(true);
        transactionHistory().then((result) {
          TransactionHistory transactionHistory =
              TransactionHistory.fromJson(result);
          setState(() {
            list.addAll(transactionHistory.data.reversed);
          });
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
    var width = MediaQuery.of(context).size.width;

    final transactionList = ListView.builder(
        itemCount: list.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          print(list[index].other_transaction_detail.bANKTXNID.toString() +
              "*" +
              list[index].other_transaction_detail.sTATUS.toString());
          return Container(
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(spacing_standard, spacing_control,
                spacing_standard, spacing_control),
            decoration: boxDecoration(context,
                showShadow: true, radius: spacing_control),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Card(
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: spacing_control,
                  margin: EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(spacing_control),
                  ),
                  child: networkImage(list[index].front_cover,
                      aWidth: width * 0.18,
                      aHeight: width * 0.28,
                      fit: BoxFit.fill),
                ).paddingAll(spacing_standard),
                SizedBox(width: spacing_standard),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: text(context, list[index].bookName,
                                    textColor:
                                        Theme.of(context).textTheme.title.color,
                                    fontFamily: font_bold,
                                    fontSize: ts_normal,
                                    maxLine: 2)
                                .paddingOnly(right: spacing_standard),
                          ),
                          text(
                                  context,
                                  list[index]
                                      .total_amount
                                      .toString()
                                      .toCurrencyFormat(),
                                  textColor:
                                      Theme.of(context).textTheme.title.color,
                                  fontFamily: font_bold,
                                  fontSize: ts_normal,
                                  maxLine: 2)
                              .paddingOnly(right: spacing_standard),
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ).paddingTop(spacing_control),
                      text(
                              context,
                              list[index].other_transaction_detail.oRDERID ==
                                      "null"
                                  ? "NA"
                                  : "#" +
                                      list[index]
                                          .other_transaction_detail
                                          .oRDERID
                                          .toString(),
                              fontSize: ts_normal,
                              maxLine: 2)
                          .paddingOnly(right: spacing_standard),
                      text(
                        context,
                        list[index]
                            .other_transaction_detail
                            .tXNDATE
                            .formatDateTime(),
                        fontSize: ts_normal,
                      ).paddingOnly(
                          right: spacing_standard, bottom: spacing_standard),
                      text(
                              context,
                              list[index].payment_status == 'TXN_SUCCESS' ||
                                      list[index].payment_status == 'approved'
                                  ? "Done"
                                  : "Failed",
                              textColor: list[index].payment_status ==
                                          'TXN_SUCCESS' ||
                                      list[index].payment_status == 'approved'
                                  ? Colors.green
                                  : Theme.of(context).errorColor,
                              fontFamily: font_bold,
                              fontSize: ts_normal)
                          .paddingOnly(
                              right: spacing_standard,
                              bottom: spacing_standard_new,
                              top: spacing_standard_new),
                    ],
                  ),
                )
              ],
            ),
          );
        });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
        centerTitle: true,
        iconTheme: Theme.of(context).iconTheme,
        title:
            headingText(context, keyString(context, "lbl_transaction_history")),
        actions: <Widget>[
          cartIcon(context, cartCount),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          list.isNotEmpty
              ? transactionList
              : Container(
                  alignment: Alignment.center,
                  child: text(context, keyString(context, "error_no_result"),
                      fontSize: ts_extra_normal,
                      textColor: Theme.of(context).textTheme.title.color),
                ).visible(!isLoading),
          loadingWidgetMaker().visible(isLoading)
        ],
      ),
    );
  }
}
