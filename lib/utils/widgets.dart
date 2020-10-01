import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:KhadoAndSons/app_localizations.dart';
import 'package:KhadoAndSons/models/response/book_detail.dart';
import 'package:KhadoAndSons/models/response/book_rating.dart';
import 'package:KhadoAndSons/screens/book_description_screen.dart';
import 'package:KhadoAndSons/screens/cart_screen.dart';
import 'package:KhadoAndSons/screens/signIn.dart';
import 'package:KhadoAndSons/utils/common.dart';
import 'package:KhadoAndSons/utils/constants.dart';
import 'package:KhadoAndSons/utils/resources/colors.dart';
import 'package:KhadoAndSons/utils/resources/images.dart';
import 'package:KhadoAndSons/utils/resources/size.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:rating_bar/rating_bar.dart';
import 'package:intl/intl.dart';

Widget text(context, var text,
    {var fontSize = ts_medium,
    textColor = textColorSecondary,
    var fontFamily = font_regular,
    var isCentered = false,
    var maxLine = 1,
    var latterSpacing = 0.2,
    var isLongText = false,
    var isJustify = false,
    var aDecoration}) {
  return Text(
    text,
    textAlign: isCentered
        ? TextAlign.center
        : isJustify
            ? TextAlign.justify
            : TextAlign.start,
    maxLines: isLongText ? 20 : maxLine,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
        fontFamily: fontFamily,
        decoration: aDecoration != null ? aDecoration : null,
        fontSize: double.parse(fontSize.toString()).toDouble(),
        height: 1.5,
        color: textColor == textColorSecondary
            ? Theme.of(context).textTheme.subtitle.color
            : textColor.toString().isNotEmpty
                ? textColor
                : null,
        letterSpacing: latterSpacing),
  );
}

Widget toolBarTitle(BuildContext context, String title) {
  return text(context, title,
      fontSize: ts_medium_large,
      textColor: Theme.of(context).textTheme.title.color,
      fontFamily: font_bold);
}

Widget headingText(BuildContext context, var aHeadingText,
    {var afontsize = ts_extra_normal}) {
  return text(context, aHeadingText,
      fontSize: afontsize,
      fontFamily: font_bold,
      textColor: Theme.of(context).textTheme.title.color);
}

BoxDecoration boxDecoration(BuildContext context,
    {double radius = 2,
    Color color = Colors.transparent,
    Color bgColor = white,
    var showShadow = false}) {
  return BoxDecoration(
      //gradient: LinearGradient(colors: [bgColor, whiteColor]),
      color: bgColor == white ? Theme.of(context).cardTheme.color : bgColor,
      boxShadow: showShadow
          ? [
              BoxShadow(
                  color: Theme.of(context).hoverColor.withOpacity(0.2),
                  blurRadius: 5,
                  spreadRadius: 3,
                  offset: Offset(1, 3))
            ]
          : [BoxShadow(color: Colors.transparent)],
      border: Border.all(color: color),
      borderRadius: BorderRadius.all(Radius.circular(radius)));
}

Widget networkImage(String image,
    {String aPlaceholder = placeholder,
    double aWidth,
    double aHeight,
    var fit = BoxFit.fill}) {
  return image != null && image.isNotEmpty
      ? FadeInImage(
          placeholder: AssetImage(placeholder),
          image: NetworkImage(image),
          width: aWidth != null ? aWidth : null,
          height: aHeight != null ? aHeight : null,
          fit: fit,
        )
      : Image.asset(
          aPlaceholder,
          width: aWidth,
          height: aHeight,
          fit: BoxFit.fill,
        );
}

class AppButton extends StatefulWidget {
  var textContent;
  VoidCallback onPressed;

  AppButton({@required this.textContent, @required this.onPressed});

  @override
  State<StatefulWidget> createState() {
    return AppButtonState();
  }
}

class AppButtonState extends State<AppButton> {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
        onPressed: widget.onPressed,
        textColor: white,
        elevation: 4,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
        padding: const EdgeInsets.all(0.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.all(Radius.circular(spacing_standard)),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.textContent,
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ));
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return null;
  }
}

class BookGridList extends StatelessWidget {
  var list = List<BookDetail>();
  var isHorizontal = false;

  BookGridList(this.list);

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Container(
      child: GridView.builder(
        itemCount: list.length,
        shrinkWrap: true,
        padding: EdgeInsets.fromLTRB(spacing_standard, spacing_control,
            spacing_standard, spacing_standard),
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, childAspectRatio: 9 / 18),
        scrollDirection: Axis.vertical,
        controller: ScrollController(keepScrollOffset: false),
        itemBuilder: (context, index) {
          BookDetail bookDetail = list[index];
          print(bookDetail.discountedPrice.toString());
          print(bookDetail.price.toString());
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BookDescriptionScreen(
                                bookDetail: list[index])));
                  },
                  child: Card(
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    elevation: spacing_control_half,
                    margin: EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(spacing_control),
                    ),
                    child: networkImage(bookDetail.frontCover,
                        aWidth: double.infinity, aHeight: double.infinity),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    bookDetail.name,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  )
                      .withStyle(
                          color: Theme.of(context).textTheme.title.color,
                          fontFamily: font_bold,
                          fontSize: ts_medium)
                      .paddingOnly(right: 8, bottom: 0, top: 8),
                  Text(
                    bookDetail.authorName,
                    maxLines: 1,
                  )
                      .withStyle(
                          color: Theme.of(context).textTheme.subtitle.color,
                          fontFamily: font_regular,
                          fontSize: ts_medium)
                      .paddingOnly(right: 8),
                  Row(
                    children: <Widget>[
                      text(
                        context,
                        bookDetail.discountedPrice != 0
                            ? bookDetail.discountedPrice
                                .toString()
                                .toCurrencyFormat()
                            : bookDetail.price.toString().toCurrencyFormat(),
                        fontFamily: font_bold,
                        textColor: Theme.of(context).textTheme.title.color,
                      ).visible(bookDetail.discountedPrice != 0 ||
                          bookDetail.price != 0),
                      text(
                        context,
                        "Free",
                        fontFamily: font_bold,
                        textColor: Theme.of(context).errorColor,
                      ).visible(bookDetail.discountedPrice == 0 &&
                          bookDetail.price == 0),
                      text(
                        context,
                        bookDetail.price.toString().toCurrencyFormat(),
                        aDecoration: TextDecoration.lineThrough,
                      ).paddingOnly(left: spacing_standard).visible(
                          bookDetail.discount != 0 && bookDetail.price != 0),
                    ],
                  ),
                ],
              ).paddingBottom(spacing_control),
            ],
          ).paddingAll(spacing_control);
        },
      ),
    );
  }
}

class BookHorizontalList extends StatelessWidget {
  var list = List<BookDetail>();
  var isHorizontal = false;

  BookHorizontalList(this.list, {this.isHorizontal = false});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return !isHorizontal
        ? Container(
            height: width * (9 / 16),
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: list.length,
                shrinkWrap: true,
                padding: EdgeInsets.only(right: spacing_standard_new),
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(left: spacing_standard_new),
                    width: width * 0.28,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: InkWell(
                            child: Card(
                              semanticContainer: true,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              elevation: spacing_control_half,
                              margin: EdgeInsets.all(0),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(spacing_control),
                              ),
                              child: networkImage(
                                list[index].frontCover,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          BookDescriptionScreen(
                                              bookDetail: list[index])));
                            },
                            radius: spacing_control,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              list[index].name + "\n",
                              maxLines: 2,
                            )
                                .withStyle(
                                    color:
                                        Theme.of(context).textTheme.title.color,
                                    fontFamily: font_medium,
                                    fontSize: ts_medium)
                                .paddingTop(spacing_standard),
                            Text(
                              list[index].authorName,
                              maxLines: 1,
                            ).withStyle(
                                color:
                                    Theme.of(context).textTheme.subtitle.color,
                                fontFamily: font_regular,
                                fontSize: ts_medium_small)
                          ],
                        ),
                      ],
                    ),
                  );
                }),
          ).paddingOnly(top: spacing_standard_new)
        : Container(
            height: (width * 0.4) + 24,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: list.length,
                padding: EdgeInsets.only(right: spacing_standard_new),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BookDescriptionScreen(
                                  bookDetail: list[index])));
                    },
                    child: Container(
                      child: Stack(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(
                                top: width * 0.08,
                                bottom: spacing_standard_new),
                            padding:
                                EdgeInsets.only(bottom: spacing_standard_new),
                            decoration: boxDecoration(context,
                                showShadow: true,
                                radius: spacing_control,
                                bgColor: Theme.of(context).cardTheme.color),
                            width: width - 48,
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: width * 0.27,
                                ).paddingOnly(
                                    left: spacing_standard_new,
                                    right: spacing_standard_new),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              list[index].name,
                                              maxLines: 2,
                                            ).withStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .title
                                                    .color,
                                                fontFamily: font_bold),
                                            Text(
                                              list[index].authorName,
                                            ).withStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .subtitle
                                                    .color,
                                                fontFamily: font_semi_bold,
                                                fontSize: ts_medium),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        list[index].description,
                                        maxLines: 3,
                                      ).withStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .subtitle
                                              .color,
                                          fontFamily: font_regular,
                                          fontSize: ts_medium)
                                    ],
                                  ).paddingOnly(
                                      top: spacing_standard_new,
                                      right: spacing_standard_new),
                                )
                              ],
                            ),
                          ),
                          Card(
                                  semanticContainer: true,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  elevation: spacing_control,
                                  margin: EdgeInsets.all(0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(spacing_control),
                                  ),
                                  child: networkImage(
                                    list[index].frontCover,
                                    aWidth: width * 0.27,
                                    aHeight: width * 0.4,
                                  ))
                              .paddingOnly(
                                  left: spacing_standard_new,
                                  right: spacing_standard_new,
                                  bottom: spacing_standard_new),
                        ],
                      ).paddingLeft(spacing_standard_new),
                    ),
                  );
                }),
          ).paddingTop(spacing_standard_new);
  }
}

Widget horizontalHeading(context, var title,
    {bool showViewAll = true, var callback}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      headingText(context, title),
      GestureDetector(
        onTap: callback,
        child: Container(
          padding: EdgeInsets.only(
              left: spacing_standard_new,
              top: spacing_control,
              bottom: spacing_control),
          child: text(context, keyString(context, "lbl_view_all").toUpperCase(),
              textColor: Theme.of(context).textTheme.button.color,
              fontFamily: font_medium),
        ).visible(showViewAll),
      )
    ],
  ).paddingOnly(
      left: spacing_standard_new,
      right: spacing_standard_new,
      top: spacing_standard);
}

extension StringExtension on String {
  String toCurrencyFormat({var format = '\$'}) {
    return format + this;
  }

  String formatDateTime() {
    if (this == null || this.isEmpty || this == "null") {
      return "NA";
    } else {
      return DateFormat("HH:mm dd MMM yyyy", "en_US").format(
          DateFormat("yyyy-MM-dd HH:mm:ss", "en_US")
              .parse(this.replaceAll("T", " ").replaceAll(".0", "")));
    }
  }

  String formatDate() {
    if (this == null || this.isEmpty || this == "null") {
      return "NA";
    } else {
      return DateFormat("dd MMM yyyy", "en_US")
          .format(DateFormat("yyyy-MM-dd", "en_US").parse(this));
    }
  }
}

String getCurrentDate() {
  return DateFormat("yyyy-MM-dd HH:mm:ss.0", "en_US").format(DateTime.now());
}

Widget loadingWidgetMaker() {
  return Container(
    alignment: Alignment.center,
    child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: spacing_control,
        margin: EdgeInsets.all(4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: Container(
          width: 45,
          height: 45,
          padding: const EdgeInsets.all(8.0),
          child: CircularProgressIndicator(
            strokeWidth: 3,
          ),
        )),
  );
}

Widget ratingBar({rating = 0.0, size = 15.0}) {
  return RatingBar.readOnly(
    initialRating: double.parse(rating.toString()),
    emptyIcon: Icon(Icons.star).icon,
    filledIcon: Icon(Icons.star).icon,
    filledColor: Colors.amber,
    emptyColor: Colors.grey.withOpacity(0.5),
    size: size,
  );
}

Widget review(BuildContext context, BookRating bookRating,
    {bool isUserReview = false, VoidCallback callback}) {
  return Stack(
    children: <Widget>[
      Container(
        margin: EdgeInsets.only(top: spacing_standard),
        padding: EdgeInsets.all(spacing_middle),
        decoration: boxDecoration(context,
            radius: spacing_control,
            showShadow: true,
            bgColor: Theme.of(context).cardTheme.color),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            bookRating.profileImage != null
                ? networkImage(bookRating.profileImage, aWidth: 40, aHeight: 40)
                    .cornerRadiusWithClipRRect(25)
                : Image.asset(
                    ic_profile,
                    width: 40,
                    height: 40,
                  ).cornerRadiusWithClipRRect(25),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  text(context, bookRating.userName,
                      fontFamily: font_medium,
                      textColor: Theme.of(context).textTheme.title.color,
                      fontSize: ts_normal),
                  Row(
                    children: <Widget>[
                      ratingBar(rating: bookRating.rating),
                      text(
                        context,
                        bookRating.createdAt,
                      ).paddingOnly(left: 8),
                    ],
                  ),
                  text(
                    context,
                    bookRating.review != null ? bookRating.review : "NA",
                    isLongText: true,
                  ),
                ],
              ).paddingLeft(spacing_standard_new),
            ),
          ],
        ),
      ),
      Align(
        alignment: Alignment.topRight,
        child: IconButton(
          icon: Icon(
            Icons.delete,
            size: 20,
            color: Theme.of(context).textTheme.subtitle.color,
          ),
          onPressed: callback,
        ),
      ).paddingTop(spacing_standard).visible(isUserReview),
    ],
  );
}

Widget cartIcon(context, cartCount) {
  return InkWell(
    child: Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          margin: EdgeInsets.only(right: spacing_standard_new),
          padding: EdgeInsets.all(spacing_standard),
          child: Image.asset(
            icoCart,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Container(
            margin: EdgeInsets.only(top: spacing_control),
            padding: EdgeInsets.all(6),
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: Colors.red),
            child: text(context, cartCount.toString(), textColor: white),
          ).visible(cartCount != 0),
        )
      ],
    ),
    onTap: () {
      callCart(context);
    },
    radius: spacing_standard_new,
  );
}

void callCart(context) async {
  var isLoggedIn = await getBool(IS_LOGGED_IN) ?? false;
  launchScreen(context, isLoggedIn ? CartScreen.tag : SignIn.tag);
}

class PinEntryTextField extends StatefulWidget {
  final String lastPin;
  final int fields;
  final onSubmit;
  final fieldWidth;
  final fontSize;
  final isTextObscure;
  final showFieldAsBox;

  PinEntryTextField(
      {this.lastPin,
      this.fields: 4,
      this.onSubmit,
      this.fieldWidth: 40.0,
      this.fontSize: 20.0,
      this.isTextObscure: false,
      this.showFieldAsBox: false})
      : assert(fields > 0);

  @override
  State createState() {
    return PinEntryTextFieldState();
  }
}

class PinEntryTextFieldState extends State<PinEntryTextField> {
  List<String> _pin;
  List<FocusNode> _focusNodes;
  List<TextEditingController> _textControllers;

  Widget textfields = Container();

  @override
  void initState() {
    super.initState();
    _pin = List<String>(widget.fields);
    _focusNodes = List<FocusNode>(widget.fields);
    _textControllers = List<TextEditingController>(widget.fields);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        if (widget.lastPin != null) {
          for (var i = 0; i < widget.lastPin.length; i++) {
            _pin[i] = widget.lastPin[i];
          }
        }
        textfields = generateTextFields(context);
      });
    });
  }

  @override
  void dispose() {
    _textControllers.forEach((TextEditingController t) => t.dispose());
    super.dispose();
  }

  Widget generateTextFields(BuildContext context) {
    List<Widget> textFields = List.generate(widget.fields, (int i) {
      return buildTextField(i, context);
    });

    if (_pin.first != null) {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    }

    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        verticalDirection: VerticalDirection.down,
        children: textFields);
  }

  void clearTextFields() {
    _textControllers.forEach(
        (TextEditingController tEditController) => tEditController.clear());
    _pin.clear();
  }

  Widget buildTextField(int i, BuildContext context) {
    if (_focusNodes[i] == null) {
      _focusNodes[i] = FocusNode();
    }
    if (_textControllers[i] == null) {
      _textControllers[i] = TextEditingController();
      if (widget.lastPin != null) {
        _textControllers[i].text = widget.lastPin[i];
      }
    }

    _focusNodes[i].addListener(() {
      if (_focusNodes[i].hasFocus) {}
    });

    final String lastDigit = _textControllers[i].text;

    return Container(
      width: widget.fieldWidth,
      margin: EdgeInsets.only(right: 10.0),
      child: TextField(
        controller: _textControllers[i],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: font_medium,
            fontSize: widget.fontSize),
        focusNode: _focusNodes[i],
        obscureText: widget.isTextObscure,
        decoration: InputDecoration(
            counterText: "",
            border: widget.showFieldAsBox
                ? OutlineInputBorder(borderSide: BorderSide(width: 2.0))
                : null),
        onChanged: (String str) {
          setState(() {
            _pin[i] = str;
          });
          if (i + 1 != widget.fields) {
            _focusNodes[i].unfocus();
            if (lastDigit != null && _pin[i] == '') {
              FocusScope.of(context).requestFocus(_focusNodes[i - 1]);
            } else {
              FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
            }
          } else {
            _focusNodes[i].unfocus();
            if (lastDigit != null && _pin[i] == '') {
              FocusScope.of(context).requestFocus(_focusNodes[i - 1]);
            }
          }
          if (_pin.every((String digit) => digit != null && digit != '')) {
            widget.onSubmit(_pin.join());
          }
        },
        onSubmitted: (String str) {
          if (_pin.every((String digit) => digit != null && digit != '')) {
            widget.onSubmit(_pin.join());
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return textfields;
  }
}
