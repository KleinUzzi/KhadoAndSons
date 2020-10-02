import 'dart:convert';

import 'package:granth_flutter/models/response/login_response.dart';
import 'package:granth_flutter/utils/constants.dart';
import 'package:granth_flutter/utils/network_utils.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';

Future doLogin(request) async {
  print(jsonEncode(request));
  return handleResponse(await postRequest('login', request));
}

Future register(request) async {
  print(jsonEncode(request));
  return handleResponse(await postRequest('register', request));
}

Future getDashboard() async {
  return handleResponse(await getRequest('dashboard-detail'));
}

Future getViewAllBookNextPage(type, page, {categoryId = ''}) async {
  return handleResponse(await getRequest(
      'dashboard-detail?page=$page&type=$type&category_id=$categoryId'));
}

Future getBookList(page, aAuthorId) async {
  return handleResponse(
      await getRequest('book-list?page=$page&author_id=$aAuthorId'));
}

Future searchBook(page, searchText) async {
  return handleResponse(
      await getRequest('book-list?page=$page&search_text=$searchText'));
}

Future getCategoryWiseBookDetail(page, categoryId,subCategoryId) async {
  return handleResponse(
      await getRequest('book-list?page=$page&category_id=$categoryId&subcategory_id=$subCategoryId'));
}

Future getAuthorList() async {
  return handleResponse(await getRequest('author-list'));
}

Future addBookRating(request) async {
  print(jsonEncode(request));
  return handleResponse(await postRequest('add-book-rating', request));
}

Future updateBookRating(request) async {
  print(jsonEncode(request));
  return handleResponse(await postRequest('update-book-rating', request));
}

Future addFeedback(request) async {
  print(jsonEncode(request));
  return handleResponse(await postRequest('add-feedback', request));
}

Future deleteRating(request) async {
  print(jsonEncode(request));
  return handleResponse(await postRequest('delete-book-rating', request));
}

Future changeUserPassword(request) async {
  print(jsonEncode(request));
  return handleResponse(await postRequest('change-password', request));
}

Future sendForgotPasswordRequest(request) async {
  print(jsonEncode(request));
  return handleResponse(await postRequest('forgot-password', request));
}

Future categoryList() async {
  return handleResponse(await getRequest('category-list'));
}

Future getReview(request) async {
  print(jsonEncode(request));
  return handleResponse(await postRequest('book-rating-list', request));
}

Future addFavourite(request) async {
  print(jsonEncode(request));
  return handleResponse(await postRequest('add-remove-wishlist-book', request));
}

Future addSellWithUs(request) async {
  print(jsonEncode(request));
  return handleResponse(await postRequest('sell-with-us', request));
}

Future addToCart(request) async {
  print(jsonEncode(request));
  return handleResponse(await postRequest('add-to-cart', request));
}

Future removeFromCart(request) async {
  print(jsonEncode(request));
  return handleResponse(await postRequest('remove-from-cart', request));
}

Future getCart() async {
  return handleResponse(await getRequest('user-cart'));
}

Future getBookmarks() async {
  return handleResponse(await getRequest('user-wishlist-book'));
}

Future getBookDetail(request) async {
  return handleResponse(await postRequest('book-detail', request));
}

Future transactionHistory() async {
  return handleResponse(await getRequest('get-transaction-history'));
}

Future purchasedBookList() async {
  return handleResponse(await getRequest('user-purchase-book'));
}

Future requestCallBack(request) async {
  return handleResponse(await postRequest('save-callrequest', request));
}

Future subCategories(request) async {
  return handleResponse(await postRequest('sub-category-list', request));
}

Future getNotificationList(request) async {
  return handleResponse(await postRequest('notification-history', request));
}

Future readNotification(request) async {
  return handleResponse(await postRequest('read-notification', request));
}

Future logout() async {
  return handleResponse(await postRequest('logout', null));
}

Future updateUser(userDetail, mSelectedImage) async {
  var request =
      http.MultipartRequest("POST", Uri.parse('${mBaseUrl}save-user-profile'));
  request.fields['user_detail'] = jsonEncode(userDetail);
  if (mSelectedImage != null) {
    final file =
        await http.MultipartFile.fromPath('image', mSelectedImage.path);
    request.files.add(file);
  }
  request.headers.addAll(await buildTokenHeader());
  await request.send().then((response) async {
    print(response.statusCode);
    response.stream.transform(utf8.decoder).listen((value) {
      LoginResponse loginResponse = LoginResponse.fromJson(jsonDecode(value));
      if (loginResponse.status) {
        LoginData data = loginResponse.data;
        setString(USERNAME, data.userName);
        setString(NAME, data.name);
        setString(USER_EMAIL, data.email);
        setString(USER_PROFILE, data.image);
        setString(USER_CONTACT_NO, data.contactNumber);
      }
      toast(loginResponse.message);
    });
  }).catchError((error) {
    print(error.toString());
    toast(error);
  });
}

Future getChecksum(request) async {
  return handleResponse(await postRequest('generate-check-sum', request));
}

Future saveTransaction(Map<String, String> transactionDetails, orderDetails, type, status) async {
  print('transaction_detail' + jsonEncode(transactionDetails));
  print('order_detail' + jsonEncode(orderDetails));
  print('type' + type.toString());
  print('status' + status.toString());
  var request =
      http.MultipartRequest("POST", Uri.parse('${mBaseUrl}save-transaction'));
  request.fields['transaction_detail'] = jsonEncode(transactionDetails);
  request.fields['order_detail'] = jsonEncode(orderDetails);
  request.fields['type'] = type.toString();
  request.fields['status'] = status.toString();
  request.headers.addAll(await buildTokenHeader());
  await request.send().then((res) {
    print(res.statusCode);
    if(transactionDetails['STATUS']=="TXN_SUCCESS"){
      toast("Transaction Successfull.");
    }else{
      toast("Transaction Failed.");
    }
    LiveStream().emit(CART_ITEM_CHANGED, true);
    return res;
  }).catchError((error) {
    throw error;
  });
}

Future verifyToken(request) async {
  print(jsonEncode(request));
  return handleResponse(await postRequest('verify-token', request));
}

Future resendOtp(request) async {
  print(jsonEncode(request));
  return handleResponse(await postRequest('resend-otp', request));
}

Future updatePassword(request) async {
  print(jsonEncode(request));
  return handleResponse(await postRequest('update-password', request));
}

Future generateClientToken() async {
  return handleResponse(await getRequest('generate-client-token'));
}

Future savePayPalTransaction(request) async {
  print(jsonEncode(request));
  return handleResponse(await postRequest('braintree-payment-process', request));
}



