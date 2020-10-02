import 'dart:convert';
import 'dart:io';


import 'package:granth_flutter/models/response/base_response.dart';
import 'package:granth_flutter/models/response/book_detail.dart';
import 'package:granth_flutter/models/response/cart_response.dart';
import 'package:granth_flutter/models/response/login_response.dart';
import 'package:granth_flutter/models/response/wishlist_response.dart';
import 'package:granth_flutter/network/rest_apis.dart';
import 'package:granth_flutter/screens/home_screen.dart';
import 'package:granth_flutter/utils/common.dart';
import 'package:granth_flutter/utils/constants.dart';

import 'package:nb_utils/nb_utils.dart';

import '../app_localizations.dart';



addRemoveWishList(context,var id,var isWishList) async{
  toast('processing');
  isNetworkAvailable().then((bool) {
    if(bool){
      var request= {"book_id":id,"is_wishlist":isWishList};
      addFavourite(request).then((result){
        BaseResponse response = BaseResponse.fromJson(result);
        if (response.status) {
          LiveStream().emit(WISH_DATA_ITEM_CHANGED, true);

        }
      }).catchError((error) {
        toast(error.toString());
      });
    }else{
      toast(keyString(context,"error_network_no_internet"));
    }
  });
}
removeBookFromCart(context,CartItem cartItem,{addToWishList=false}) async {
  toast('processing');
  isNetworkAvailable().then((bool) {
    if (bool) {
      var request = {
        "id": cartItem.cart_mapping_id,

      };
      removeFromCart(request).then((result) {
        BaseResponse response = BaseResponse.fromJson(result);
        if (response.status) {
          LiveStream().emit(CART_ITEM_CHANGED, true);
          if(addToWishList){
            addRemoveWishList(context,cartItem.book_id,"1" );
          }
        }
      }).catchError((error) {
        toast(error.toString());
      });
    } else {
      toast(keyString(context,"error_network_no_internet"));
    }
  });
}

Future<bool>addBookToCart(context,var bookId,{bool removeFromWishList=false}) async{
  var userId= await  getInt(USER_ID);
  isNetworkAvailable().then((bool) {
    if(bool){
      var request={"book_id":bookId,"added_qty":1,"user_id":userId};
      addToCart(request).then((result){
        BaseResponse response = BaseResponse.fromJson(result);
        if (response.status) {
          LiveStream().emit(CART_ITEM_CHANGED, true);
          if(removeFromWishList){
            addRemoveWishList(context,bookId,"0" );
          }
        }
        return response.status;
      }).catchError((error) {
        toast(error.toString());
      });
    }else{
      toast(keyString(context,"error_network_no_internet"));
    }
  });
}
fetchCartData(context) async {
  isNetworkAvailable().then((bool) {
    if(bool){
      getCart().then((result) async{
        print(result);
        CartResponse response=CartResponse.fromJson(result);
        setString(CART_DATA,jsonEncode(result));
        setInt(CART_COUNT,response.data.length);
        LiveStream().emit(CART_COUNT_ACTION, response.data.length);
        LiveStream().emit(CART_DATA_CHANGED, response.data);
      }).catchError((error) {
        print(error);
        toast(error.toString());
      });
    }else{
      toast(keyString(context,"error_network_no_internet"));
    }
  });
}
Future<WishListResponse>fetchWishListData(context) async {

  isNetworkAvailable().then((bool) {
    if(bool){
      getBookmarks().then((result) async{
        print(result);
        WishListResponse response=WishListResponse.fromJson(result);
        setString(WISH_LIST_DATA,jsonEncode(result));
        setInt(WISH_LIST_COUNT_CHANGED,response.data.length);
        print("wishllist count"+response.data.length.toString());
        LiveStream().emit(WISH_LIST_COUNT_CHANGED, response.data.length);
        LiveStream().emit(WISH_LIST_DATA_CHANGED, response.data);
        return response;
      }).catchError((error) {
        print(error);

        toast(error.toString());
      });
    }else{
      toast(keyString(context,"error_network_no_internet"));
    }
  });
}
doLogout(context)async{
 ConfirmAction confirmAction=await showAlertDialog(context, keyString(context,"msg_logout"));
 if(confirmAction==ConfirmAction.ACCEPT){
   isNetworkAvailable().then((bool) {
     if(bool){
       logout().then((result) async{
         var sharePref= await getSharedPref();
         sharePref.remove(TOKEN);
         sharePref.remove(USERNAME);
         sharePref.remove(NAME);
         sharePref.remove(LAST_NAME);
         sharePref.remove(USER_DISPLAY_NAME);
         sharePref.remove(USER_ID);
         sharePref.remove(USER_EMAIL);
         sharePref.remove(USER_PROFILE);
         sharePref.remove(USER_CONTACT_NO);
         sharePref.remove(CART_DATA);
         sharePref.remove(CART_COUNT);
         sharePref.remove(WISH_LIST_DATA);
         sharePref.remove(WISH_LIST_COUNT);
         sharePref.setBool(IS_LOGGED_IN, false);
         launchScreenWithNewTask(context, HomeScreen.tag);
       }).catchError((error) {
         toast(error.toString());
       });
     }else{
       toast(keyString(context,"error_network_no_internet"));
     }
   });
 }

}

saveUserData(LoginData data){
    setBool(IS_LOGGED_IN, true);
    setString(TOKEN, data.apiToken);
    setString(USERNAME, data.userName);
    setString(NAME, data.name);
    setString(USER_EMAIL, data.email);
    setString(USER_PROFILE, data.image);
    setString(USER_CONTACT_NO, data.contactNumber);
    setInt(USER_ID, data.id);
}
onReadNotification(var notificationId){
  isNetworkAvailable().then((bool) {
        if(bool){
          var request={
            "notification_id":notificationId
          };
          readNotification(request).then((result){

          }).catchError((error) {
            toast(error.toString());
          });
        }else{

        }
      });
}

/*
saveTransaction(var orderDetail,var transactionDetail,var type,var status) async{
  isNetworkAvailable().then((bool) {
        if(bool){
          saveTransaction(request).then((result){

          }).catchError((error) {
            toast(error.toString());
          });
        }else{
          toast(error_network_no_internet);
        }
      })
}*/
