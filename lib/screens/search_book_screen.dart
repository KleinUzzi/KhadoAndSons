import 'package:flutter/material.dart';
import 'package:granth_flutter/models/response/book_detail.dart';
import 'package:granth_flutter/models/response/book_list.dart';
import 'package:granth_flutter/network/rest_apis.dart';
import 'package:granth_flutter/utils/common.dart';
import 'package:granth_flutter/utils/constants.dart';
import 'package:granth_flutter/utils/resources/colors.dart';
import 'package:granth_flutter/utils/resources/size.dart';
import 'package:granth_flutter/utils/widgets.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:rating_bar/rating_bar.dart';
import '../app_localizations.dart';
import 'book_description_screen.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SearchScreen extends StatefulWidget {
  static String tag = '/SearchScreen';

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with AfterLayoutMixin<SearchScreen> {
  var list = List<BookDetail>();
  var totalBooks = 0;
  var page = 1;
  var scrollController = new ScrollController();
  bool isLoading = false;
  bool isLoadingMoreData = false;
  bool isLastPage = false;
  var searchText = '';
  double width;
  bool isExpanded = false;
  bool isEmpty = false;
  var _permissionReady;
  var lastStatus;
  bool _hasSpeech = false;
  bool _stressTest = false;
  double level = 0.0;
  int _stressLoops = 0;
  String lastWords = "";
  String lastError = "";
  String _currentLocaleId = "";
  List<LocaleName> _localeNames = [];
  final SpeechToText speech = SpeechToText();
  bool isListening = false;
  TextEditingController controller = TextEditingController();
  var isInitialized=false;

  @override
  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      scrollHandler();
    });
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    _permissionReady = await checkRecordAudioPermission(context);
    initSpeechState();
  }

  scrollHandler() {
    if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        !isLastPage &&
        !isLoadingMoreData) {
      page++;
      setState(() {
        isLoadingMoreData = true;
        isLastPage = false;
        isEmpty = false;
      });
      fetchBookList(page);
    }
  }

  Future<void> initSpeechState() async {
    if (!_permissionReady) {
      _permissionReady = await checkRecordAudioPermission(context);
      return;
    }

    bool hasSpeech = await speech.initialize(
        onError: errorListener, onStatus: statusListener);
    if (hasSpeech) {
      _localeNames = await speech.locales();

      var systemLocale = await speech.systemLocale();
      _currentLocaleId = systemLocale.localeId;
    }

    if (!mounted) return;

    setState(() {
      isInitialized=true;
      _hasSpeech = hasSpeech;
    });
  }

  Future<List<BookDetail>> fetchBookList(page) async {
    isNetworkAvailable().then((bool) {
      if (bool) {
        searchBook(page, searchText).then((result) {
          BookListResponse response = BookListResponse.fromJson(result);
          setState(() {
            isLoadingMoreData = false;
            totalBooks = response.pagination.totalItems;
            isLastPage = page == response.pagination.totalPages;
            if (response.data.isEmpty) {
              if (list.isEmpty) {
                isEmpty = true;
              }
              isLastPage = true;
            }
            list.addAll(response.data);
          });
          return response.data;
        }).catchError((error) {
          toast(error.toString());
          setState(() {
            isLoadingMoreData = false;
            isLastPage = true;
          });
        });
      } else {
        toast(keyString(context,"error_network_no_internet"));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    final customeAppBar = Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(top: 8),
      alignment: Alignment.center,
      width: double.infinity,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              elevation: spacing_standard,
              margin: EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(spacing_control),
              ),
              child: Row(
                children: <Widget>[
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                        controller: controller,
                        textInputAction: TextInputAction.search,
                        style: TextStyle(fontFamily: font_regular, fontSize: ts_normal,color: Theme.of(context).textTheme.title.color),
                        decoration: InputDecoration(
                          hintText: 'Search for books',
                          hintStyle: TextStyle(fontFamily: font_regular,color: Theme.of(context).textTheme.subtitle.color),
                          border: InputBorder.none,
                          filled: false,
                        ),
                        onFieldSubmitted: (term) {
                          page = 1;
                          searchText = term;
                          setState(() {
                            list.clear();
                            isLoadingMoreData = true;
                            isEmpty = false;
                          });
                          fetchBookList(page);
                        }),
                  ),
                  InkWell(
                    child: Icon(
                      Icons.mic,
                      color: Theme.of(context).textTheme.subtitle.color,
                    ),
                    onTap: () {
                      startListening();
                    },
                    radius: spacing_standard_new,
                  ),
                ],
              ).paddingOnly(left: 4, right: 4),
            ),
          ),
          SizedBox(
            width: spacing_standard_new,
          ),
          InkWell(
            onTap: () {
              finish(context);
            },
            child: text(context,'Cancel', fontFamily: font_bold, fontSize: ts_normal),
          )
        ],
      ),
    ).paddingOnly(left: 8, right: 8);

    final searchList = Container(
      child: ListView.builder(
        itemCount: list.length,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          BookDetail bookDetail = list[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          BookDescriptionScreen(bookDetail: list[index])));
            },
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(spacing_standard, spacing_control,
                  spacing_standard, spacing_control),
             /* decoration: boxDecoration(
                  bgColor: white, showShadow: true, radius: spacing_control),*/
              child: Row(
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
                    child: networkImage(bookDetail.frontCover,
                        aWidth: width * 0.24,
                        aHeight: width * 0.34,
                        fit: BoxFit.fill),
                  ).paddingAll(spacing_standard),
                  SizedBox(width: spacing_standard),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        text(context,bookDetail.name,
                                textColor: Theme.of(context).textTheme.title.color,
                                fontFamily: font_bold,
                                fontSize: ts_normal,
                                maxLine: 2)
                            .paddingOnly(
                                right: spacing_standard, top: spacing_standard),
                        text(context,
                          bookDetail.authorName,
                        ).paddingOnly(
                            right: spacing_standard, bottom: spacing_standard),
                        Row(
                          children: <Widget>[
                            RatingBar.readOnly(
                              initialRating: bookDetail.totalRating,
                              emptyIcon: Icon(Icons.star).icon,
                              filledIcon: Icon(Icons.star).icon,
                              filledColor: Colors.amber,
                              emptyColor: Colors.grey.withOpacity(0.7),
                              size: spacing_standard_new,
                            ),
                            text(context,bookDetail.totalReview.toString() + ' Reviews')
                                .paddingOnly(left: spacing_standard)
                                .visible(bookDetail.totalReview != null),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            text(context,
                              bookDetail.discountedPrice != 0
                                  ? bookDetail.discountedPrice
                                      .toString()
                                      .toCurrencyFormat()
                                  : bookDetail.price
                                      .toString()
                                      .toCurrencyFormat(),
                              fontSize: ts_extra_normal,
                              fontFamily: font_medium,
                              textColor: Theme.of(context).textTheme.title.color,
                            ).visible(bookDetail.discountedPrice != 0 ||
                                bookDetail.price != 0),
                            text(context,
                              bookDetail.price.toString().toCurrencyFormat(),
                              fontSize: ts_normal,
                              aDecoration: TextDecoration.lineThrough,
                            )
                                .paddingOnly(left: spacing_standard)
                                .visible(bookDetail.discount != 0),
                            text(context,
                              bookDetail.discount.toString() + '% Off',
                              fontFamily: font_medium,
                              fontSize: ts_normal,
                              textColor: Colors.red,
                            )
                                .paddingOnly(left: spacing_standard)
                                .visible(bookDetail.discount != 0),
                          ],
                        ).paddingOnly(
                          top: spacing_standard,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );

    return SafeArea(
      child: Stack(
        children: <Widget>[
          Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: PreferredSize(
                preferredSize: Size(MediaQuery.of(context).size.width, 60),
                child: customeAppBar,
              ),
              body: SingleChildScrollView(
                controller: scrollController,
                physics: BouncingScrollPhysics(),
                child: !isEmpty
                    ? isLoadingMoreData
                        ? Column(
                            children: <Widget>[
                              searchList,
                              loadingWidgetMaker().paddingTop(spacing_large)
                            ],
                          )
                        : searchList
                    : Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            text(context,keyString(context,"error_search")+" \"" + searchText + "\"",
                                textColor: Theme.of(context).textTheme.title.color,
                                fontFamily: font_semi_bold,
                                fontSize: ts_extra_normal),
                            text(context,keyString(context,"note_search"),
                                fontFamily: font_semi_bold, fontSize: ts_normal)
                          ],
                        ).paddingTop(width * 0.2),
                      ),
              )),
          Scaffold(
            backgroundColor: Colors.black.withOpacity(0.5),
            body: Center(
              child: SingleChildScrollView(
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width - 40,
                        height: MediaQuery.of(context).size.width,
                        decoration: boxDecoration(context,
                            bgColor: Theme.of(context).cardTheme.color,
                            showShadow: false,
                            radius: spacing_middle),
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: <Widget>[
                            Container(
                              width: double.infinity,
                              child: Stack(
                                children: <Widget>[
                                  Align(
                                    child: text(context,
                                            speech.isListening
                                                ? keyString(context,"lbl_listening")
                                                : keyString(context,"lbl_time_out"),
                                            fontSize: 24,
                                            fontFamily: font_bold,
                                            textColor: Theme.of(context).textTheme.title.color)
                                        .paddingAll(spacing_standard_new),
                                    alignment: Alignment.topCenter,
                                  ),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: InkWell(
                                        onTap: () {
                                          stopListening();
                                        },
                                        child: Icon(
                                          Icons.clear,
                                          color: Theme.of(context).textTheme.title.color,
                                          size: 24,
                                        ).paddingAll(spacing_standard_new)),
                                  )
                                ],
                              ),
                            ),
                            Center(
                              child: Container(
                                width: 50,
                                height: 50,
                                margin: EdgeInsets.all(spacing_large),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius: .26,
                                        spreadRadius: level * 3,
                                        color: Theme.of(context).colorScheme.secondary.withOpacity(.05))
                                  ],
                                  color: Theme.of(context).colorScheme.secondary,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.mic,
                                    color: white,
                                  ),
                                  /* onPressed: (){
                                    if(_hasSpeech){
                                      if(speech.isListening){
                                        stopListening();
                                      }else{
                                        startListening();
                                      }
                                    }
                                  },*/
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ).visible(speech.isListening)
        ],
      ),
    );
  }

  void changeStatusForStress(String status) {
    if (!_stressTest) {
      return;
    }
    if (speech.isListening) {
      stopListening();
    } else {
      if (_stressLoops >= 100) {
        _stressTest = false;
        print("Stress test complete.");
        return;
      }
      print("Stress loop: $_stressLoops");
      ++_stressLoops;
      startListening();
    }
  }

  void startListening() async {
    if(!_permissionReady){
      _permissionReady = await checkRecordAudioPermission(context);
      return;
    }
    if(!isInitialized){
      initSpeechState();
      return;
    }
    setState(() {
      lastWords = "";
      lastError = "";
    });
    speech.listen(
        onResult: resultListener,
        listenFor: Duration(seconds: 60),
        localeId: _currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: false,
        partialResults: true);
  }

  void stopListening() {
    speech.stop();
    setState(() {
      level = 0.0;
    });
  }

  void cancelListening() {
    speech.cancel();
    setState(() {
      level = 0.0;
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    print("${result.recognizedWords} - ${result.finalResult}");
    if (result.finalResult) {
      page = 1;
      setState(() {
        lastWords = result.recognizedWords;
        controller.text = lastWords;
        list.clear();
        isLoadingMoreData = true;
        isEmpty = false;
      });
      searchText = lastWords;
      fetchBookList(page);
    }
  }

  void soundLevelListener(double level) {
    setState(() {
      this.level = level;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    print(error.errorMsg);
    setState(() {
      lastError = "${error.errorMsg} - ${error.permanent}";
    });
  }

  void statusListener(String status) {
    print(status);
    changeStatusForStress(status);
    setState(() {
      lastStatus = "$status";
    });
  }

}
