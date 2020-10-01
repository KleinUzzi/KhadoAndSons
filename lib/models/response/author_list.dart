import 'package:KhadoAndSons/models/response/author.dart';

class AuthorList {
  List<AuthorDetail> data;

  AuthorList({this.data});

  factory AuthorList.fromJson(Map<String, dynamic> json) {
    return AuthorList(
      data: json['data'] != null
          ? (json['data'] as List).map((i) => AuthorDetail.fromJson(i)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
