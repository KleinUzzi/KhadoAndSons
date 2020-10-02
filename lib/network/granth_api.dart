import 'dart:async';
import 'dart:convert';
import "dart:core";
import 'dart:io';

import 'package:granth_flutter/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';

class GranthAPI {
  String url;
  bool isHttps;

  GranthAPI() {
    this.url = mBaseUrl;
    if (this.url.startsWith("https")) {
      this.isHttps = true;
    } else {
      this.isHttps = false;
    }
  }

  _getOAuthURL(String requestMethod, String endpoint) {
    var url = this.url + endpoint;
    return url;
  }

  Future<http.Response> getAsync(String endPoint) async {
    var url = this._getOAuthURL("GET", endPoint);

    print(url);
    final response = await http.get(url);
    print(response.statusCode);
    print(jsonDecode(response.body));

    return response;
  }

  Future<http.Response> postAsync(String endPoint, Map data) async {
    var url = this._getOAuthURL("POST", endPoint);
    print(url);

    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
    };
    if (await getBool(IS_LOGGED_IN)) {
      var header = {
        "Authorization": "Bearer ${await getString(TOKEN)}",
      };
      headers.addAll(header);
    }
    print(jsonEncode(headers));
    print(jsonEncode(data));

    var client = new http.Client();
    var response = await client.post(url, body: jsonEncode(data), headers: headers);

    print(response.statusCode);
    print(jsonDecode(response.body));
    return response;
  }
}
