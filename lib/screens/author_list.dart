
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:granth_flutter/models/response/author.dart';
import 'package:granth_flutter/models/response/author_list.dart';
import 'package:granth_flutter/network/rest_apis.dart';
import 'package:granth_flutter/utils/common.dart';
import 'package:granth_flutter/utils/constants.dart';
import 'package:granth_flutter/utils/resources/colors.dart';
import 'package:granth_flutter/utils/resources/size.dart';
import 'package:granth_flutter/utils/widgets.dart';
import 'package:nb_utils/nb_utils.dart';

import '../app_localizations.dart';
import 'author_detail_screen.dart';

class AuthorsListScreen extends StatefulWidget {
  static String tag = '/AuthorsListScreen';
  @override
  AuthorsListScreenState createState() => AuthorsListScreenState();
}
class AuthorsListScreenState extends State<AuthorsListScreen> with AfterLayoutMixin<AuthorsListScreen>{
  var mBestAuthorList=List<AuthorDetail>();

  bool isLoading=false;

  showLoading(bool show){
    setState(() {
      isLoading=show;
    });
  }
   @override
  void initState() {
    super.initState();
  }
  @override
  void afterFirstLayout(BuildContext context) {
    fetchAuthorList();
  }
  fetchAuthorList(){
    isNetworkAvailable().then((bool) {
          if(bool){
            showLoading(true);

            getAuthorList().then((result){
              showLoading(false);

              AuthorList list=AuthorList.fromJson(result);
              if(list!=null && list.data!=null && list.data.isNotEmpty){
                setState(() {
                  mBestAuthorList.addAll(list.data);

                });
              }
            }).catchError((error) {
              showLoading(false);

              toast(error.toString());
            });
          }else{
            toast(keyString(context,"error_network_no_internet"));
          }
        });
  }
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    var authorList= GridView.builder(
      itemCount: mBestAuthorList.length,
      shrinkWrap: true,
      padding: EdgeInsets.fromLTRB( spacing_standard_new,spacing_standard_new,spacing_standard_new,70),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,crossAxisSpacing: spacing_middle,mainAxisSpacing: spacing_middle),
      scrollDirection: Axis.vertical,
      controller: ScrollController(keepScrollOffset: false),
      itemBuilder: (context, index) {
        return Card(
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: spacing_control_half,
          margin: EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(spacing_control),
          ),
          child: Container(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                InkWell(
                  child: networkImage(mBestAuthorList[index].image,fit: BoxFit.fill,aWidth: double.infinity,aHeight: double.infinity),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AuthorDetailScreen(
                              authorDetail: mBestAuthorList[index],
                            )));
                  },
                ),
                Container(
                  width: double.infinity,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.black,Colors.transparent],  begin: Alignment(2.0, 1.0),
                      end: Alignment(-2.0, -1.0),)
                  ),
                  child: text(context,mBestAuthorList[index].name,
                      textColor: white,
                      fontFamily: font_medium,
                      maxLine: 2,
                      isCentered: true)
                      .paddingOnly(
                      left: spacing_control, right: spacing_control),
                )
              ],
            ),
          ),
        );
      },
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
        centerTitle: true,
        iconTheme: Theme.of(context).iconTheme,
        title: headingText(context,keyString(context,"lbl_authors")),
      ),
      body: Stack(
        children: <Widget>[
          authorList,
          loadingWidgetMaker().visible(isLoading)
        ],
      ),
    );
  }

}