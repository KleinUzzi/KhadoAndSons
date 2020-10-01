import 'dart:convert';

import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';

import 'constants.dart';

bool isSuccessful(status) {
  return status >= 200 && status <= 300;
}

Future buildTokenHeader() async {
  var pref = await getSharedPref();
  var header = {
    "Authorization": "Bearer ${pref.getString(TOKEN)}",
    "Content-Type": "application/json",
  };
  print(jsonEncode(header));
  return header;
}

Future<Response> postRequest(String endPoint, body,{bool isFormData=false}) async {
  var pref = await getSharedPref();

  print('URL: $mBaseUrl$endPoint');
  print('Request: $body');
  var headers;
  if(isFormData){
    headers = {'Content-Type': 'application/x-www-form-urlencoded'};
  }else{
    headers = {'Content-Type': 'application/json'};
  }
  var isLoggedIn = await getBool(IS_LOGGED_IN) ?? false;
  if (isLoggedIn) {
    var header = {
      "Authorization": "Bearer ${pref.getString(TOKEN)}",
    };
    headers.addAll(header);
  }
  print(headers.toString());
  final encoding = Encoding.getByName('utf-8');
  var response = await post('$mBaseUrl$endPoint', body: jsonEncode(body), headers: headers);

  print('Status Code: ${response.statusCode}');
  print(jsonDecode(response.body));
  return response;
}

Future<Response> getRequest(String endPoint) async {
  var pref = await getSharedPref();
  var url = '$mBaseUrl$endPoint';
  print('URL: $url');
  var headers = {'Content-Type': 'application/json'};
  var isLoggedIn = await getBool(IS_LOGGED_IN) ?? false;
  if (isLoggedIn) {
    var header = {
      "Authorization": "Bearer ${pref.getString(TOKEN)}",
    };
    headers.addAll(header);
  }
  var response = await get(url,headers: headers);

  print('Status Code: ${response.statusCode}');
  print(jsonDecode(response.body));
  return response;
}

Future handleResponse(Response response) async {
  if (isSuccessful(response.statusCode)) {
    return jsonDecode(response.body);
  } else {
    if (await isJsonValid(response.body)) {
      throw jsonDecode(response.body);
    } else {
      throw errorMsg;
    }
  }
}
/*
Future handleStreamResponse(StreamedResponse response) async {
  if (isSuccessful(response.statusCode)) {
    return jsonDecode(response.body);
  } else {
    if (await isJsonValid(response.body)) {
      throw jsonDecode(response.body);
    } else {
      throw errorMsg;
    }
  }
}
*/

extension json on Map {
  toJson() {
    return jsonEncode(this);
  }
}

extension on String {
  toJson() {
    return jsonEncode(this);
  }
}

Future<bool> isJsonValid(json) async {
  try {
    var f = jsonDecode(json) as Map<String, dynamic>;
    return true;
  } catch (e) {
    print(e.toString());
  }
  return false;
}
