import 'dart:async';
import 'dart:convert';

import 'package:braintree_payment/braintree_payment.dart';
import 'package:flutter/services.dart';
import 'package:KhadoAndSons/models/response/braintree_payment_responses.dart';
import 'package:KhadoAndSons/models/response/checksum_response.dart';
import 'package:KhadoAndSons/network/rest_apis.dart';
import 'package:KhadoAndSons/utils/constants.dart';

import '../../app_localizations.dart';
import '../common.dart';
import '../widgets.dart';

class CartPayment {
  static const CHANNEL = "granth_payment";
  static const PAYPAL_CHANNEL = "granth_braintree_payment";
  static const CURRENCY_CODE = "USD";

  static const MethodChannel _channel = const MethodChannel(CHANNEL);
  static const MethodChannel _paypal_channel =
      const MethodChannel(PAYPAL_CHANNEL);

  static Future payWithPayTm(context, totalAmount, orderDetail, paymentType) {
    makePayment(context, totalAmount).then((result) {
      CheckSumResponse checksum = CheckSumResponse.fromJson(result);
      return proceesPaytmPayment(context, checksum, orderDetail);
    }).catchError((error) {
      throw error;
    });
  }

  static Future makePayment(context, total) {
    var request = {
      "TXN_AMOUNT": total.toString(),
      "EMAIL": 'test@gmail.com',
      "MOBILE_NO": '000000000',
    };
    return getChecksum(request);
    /*isNetworkAvailable().then((bool) {
      if (bool) {
        getChecksum(request).then((result) {
          print(result);
          return response;
        }).catchError((error) {
          throw error;
        });
      } else {
        throw keyString(context, "error_network_no_internet");
      }
    });*/
  }

  static Future paywithPayPal(context, token, total, orderDetail) async {
    BraintreePayment braintreePayment = new BraintreePayment();
    var data = await braintreePayment.showDropIn(
        nonce: token,
        amount: total,
        enableGooglePay: false,
        nameRequired: true);
    print("Response of the payment $data");
    if (data["status"] == "fail") {
      throw data["message"];
    } else if (data["status"] == "success") {
      var request = {
        "payment_method_nonce": data["paymentNonce"],
        "amount": total
      };
      savePayPalTransaction(request).then((res) async {
        CreateTransactionResponse response =
            CreateTransactionResponse.fromJson(res);
        if (response.data.transaction != null) {
          Transaction transaction = response.data.transaction;
          makePayment(context, total).then((result) async {
            CheckSumResponse checksum = CheckSumResponse.fromJson(result);
            var transactionDetail = <String, String>{
              "BANKNAME": "NA",
              "ORDERID": checksum.data.order_data.oRDER_ID,
              "CHECKSUMHASH": checksum.data.checksum_data.cHECKSUMHASH,
              "TXNAMOUNT": checksum.data.order_data.tXN_AMOUNT.toString(),
              "TXNDATE": getCurrentDate(),
              "MID": "NA",
              "TXNID": transaction.id,
              "PAYMENTMODE": PAYPAL,
              "CURRENCY": CURRENCY_CODE,
              "BANKTXNID": "NA",
              "GATEWAYNAME": "NA",
              "RESPMSG": transaction.processorResponseType,
              "STATUS": transaction.status == "settling" ||
                      transaction.status == "submitted_for_settlement"
                  ? "TXN_SUCCESS"
                  : "TXN_FAILURE",
            };

            showTransactionDialog(
                context,
                transaction.status == "settling" ||
                    transaction.status == "submitted_for_settlement");

            return saveTransaction(transactionDetail, orderDetail, PAYPAL, 1);
          }).catchError((error) {
            throw error;
          });
        } else {
          throw "Unable to create a transaction." + response.message;
        }
      }).catchError((error) {
        throw error;
      });
    }
  }

  static Future proceesPaytmPayment(
      context, CheckSumResponse response, orderDetail) async {
    await startPayTmPayment(response).then((Map<dynamic, dynamic> inResponse) {
      print(jsonEncode(inResponse));
      if (inResponse.containsKey("error")) {
        throw inResponse["errorMessage"];
      } else {
        var status;
        if (inResponse["RESPCODE"] != null &&
            inResponse["RESPCODE"].toString() == "01") {
          status = 1;
        } else {
          status = 2;
        }
        var request = <String, String>{
          "BANKNAME": inResponse["BANKNAME"].toString(),
          "ORDERID": inResponse["ORDERID"].toString(),
          "CHECKSUMHASH": response.data.checksum_data.cHECKSUMHASH,
          "TXNAMOUNT": inResponse["TXNAMOUNT"].toString(),
          "TXNDATE": inResponse["TXNDATE"].toString(),
          "MID": inResponse["MID"].toString(),
          "TXNID": inResponse["TXNID"].toString(),
          "PAYMENTMODE": inResponse["PAYMENTMODE"].toString(),
          "CURRENCY": inResponse["CURRENCY"].toString(),
          "BANKTXNID": inResponse["BANKTXNID"].toString(),
          "GATEWAYNAME": inResponse["GATEWAYNAME"].toString(),
          "RESPMSG": inResponse["RESPMSG"].toString(),
          "STATUS": inResponse["STATUS"].toString(),
        };
        showTransactionDialog(
            context, inResponse["STATUS"].toString() == "TXN_SUCCESS");

        return saveTransaction(request, orderDetail, PAYTM, status);
      }
    }).catchError((error) {
      throw error;
    });
  }

  static Future<Map<dynamic, dynamic>> startPayTmPayment(
      CheckSumResponse checkSumResponse) async {
    OrderData paytm = checkSumResponse.data.order_data;

    try {
      Map<dynamic, dynamic> response =
          await _channel.invokeMethod('startPaytmPayment', <String, dynamic>{
        "mId": paytm.mID.toString().trim(),
        "testing": true,
        'orderId': paytm.oRDER_ID.toString().trim(),
        'custId': paytm.cUST_ID.toString().trim(),
        'channelId': paytm.cHANNEL_ID.toString().trim(),
        'txnAmount': paytm.tXN_AMOUNT.toString().trim(),
        'website': paytm.wEBSITE.toString().trim(),
        'callBackUrl': paytm.cALLBACK_URL.toString().trim(),
        'industryTypeId': paytm.iNDUSTRY_TYPE_ID.toString().trim(),
        'checkSumHash':
            checkSumResponse.data.checksum_data.cHECKSUMHASH.toString().trim(),
        'email': paytm.eMAIL.toString().trim(),
        'mobile_no': paytm.mOBILE_NO.toString().trim()
      });
      return response;
    } on PlatformException catch (e) {
      throw 'error: ${e.message}';
    }
  }

  static initializePayPAl(String clientToken) async {
    await _paypal_channel.invokeMethod(
        'initialize_paypal', <String, dynamic>{"client_token": clientToken});
  }

  static Future<Map<dynamic, dynamic>> startPayPalPayment(
      String totalAmount) async {
    try {
      Map<dynamic, dynamic> response = await _paypal_channel
          .invokeMethod('startPayPalPayment', <String, dynamic>{
        "total_amount": totalAmount,
        "currency_code": CURRENCY_CODE,
      });
      return response;
    } on PlatformException catch (e) {
      throw 'error: ${e.message}';
    }
  }
}
