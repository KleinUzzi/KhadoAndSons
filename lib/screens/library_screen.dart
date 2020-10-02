import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:granth_flutter/models/response/book_detail.dart';
import 'package:granth_flutter/models/response/book_list.dart';
import 'package:granth_flutter/models/response/downloaded_book.dart';
import 'package:granth_flutter/network/rest_apis.dart';
import 'package:granth_flutter/utils/common.dart';
import 'package:granth_flutter/utils/constants.dart';
import 'package:granth_flutter/utils/database_helper.dart';
import 'package:granth_flutter/utils/resources/colors.dart';
import 'package:granth_flutter/utils/resources/size.dart';
import 'package:granth_flutter/utils/widgets.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import '../app_localizations.dart';


class LibraryScreen extends StatefulWidget {
  static String tag = '/LibraryScreen';

  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with AfterLayoutMixin<LibraryScreen> {
  double width;
  var purchasedList = List<DownloadedBook>();
  var sampleList = List<DownloadedBook>();
  var downloadedList = List<DownloadedBook>();
  bool isLoading = false;
  bool isUserLoggedIn = false;
  ReceivePort _port = ReceivePort();
  final dbHelper = DatabaseHelper.instance;
  var isDataLoaded=false;

  var _permissionReady;

  showLoading(bool show) {
    setState(() {
      isLoading = show;
    });
  }



  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    _bindBackgroundIsolate(context);
    FlutterDownloader.registerCallback(downloadCallback);
    var islogin = await getBool(IS_LOGGED_IN) ?? false;
    _permissionReady = await checkPermission(context);

    setState(() {
      isUserLoggedIn = islogin;
    });

    fetchData(context);
  }



  void _bindBackgroundIsolate(context) {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate(context);
      return;
    }
    _port.listen((dynamic data) {
      print('UI Isolate Callback: $data');
      String id = data[0];
      final task = purchasedList?.firstWhere((task) => task.taskId == id);
      if (task != null) {
        if (data[1] == DownloadTaskStatus.complete) {
          fetchData(context);
        }
        setState(() {
          task.status = data[1];
        });
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static void downloadCallback(String id, DownloadTaskStatus status,
      int progress) {
    print(
        'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
    final SendPort send =
    IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  DownloadedBook isExists(List<DownloadedBook> tasks, BookDetail mBookDetail) {
    DownloadedBook exist;
    tasks.forEach((task) {
      if (task.bookId == mBookDetail.bookId.toString() &&
          task.fileType == "purchased") {
        exist = task;
      }
    });
    if (exist == null) {
      exist = defaultBook(mBookDetail, "purchased");
    }
    return exist;
  }
  void fetchData(context) async {
    showLoading(true);
    List<DownloadTask> tasks = await FlutterDownloader.loadTasks();
    List<DownloadedBook> books = await dbHelper.queryAllRows();
    if (books.isNotEmpty && tasks.isNotEmpty) {
      var samples = List<DownloadedBook>();
      var downloaded = List<DownloadedBook>();
      books.forEach((DownloadedBook book) {
        var task = tasks.firstWhere((task) => task.taskId == book.taskId);
        if (task != null) {
          book.mDownloadTask = task;
          book.status = task.status;
          if (book.fileType == "sample") {
            samples.add(book);
          }
          if (book.fileType == "purchased") {
            downloaded.add(book);
          }
        }
      });
      setState(() {
        sampleList.clear();
        downloadedList.clear();
        sampleList.addAll(samples);
        downloadedList.addAll(downloaded);
      });
    }else{
      setState(() {
        sampleList.clear();
        downloadedList.clear();
      });
    }

    if (isUserLoggedIn) {
      isNetworkAvailable().then((bool) async{
        if (bool) {
          purchasedBookList().then((result) {
            BookListResponse response = BookListResponse.fromJson(result);
            setString(LIBRARY_DATA,jsonEncode(response));
            setLibraryData(response,books,tasks);
            showLoading(false);
            setState(() {
              isDataLoaded=true;
            });
          }).catchError((error) async{
            showLoading(false);
            toast(error.toString());
            BookListResponse data = await libraryItems();
            setLibraryData(data,books,tasks);
          });
        } else {
          BookListResponse data = await libraryItems();
          setLibraryData(data,books,tasks);
          toast(keyString(context,"error_network_no_internet"));
          showLoading(false);
        }
      });
    }else{
      setState(() {
        isDataLoaded=true;
      });
      showLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery
        .of(context)
        .size
        .width;
    var purchased = purchasedList.isNotEmpty
        ? getList(purchasedList,context)
        : Center(child: text(context,keyString(context,"err_no_books_purchased"), fontSize: ts_extra_normal,
        textColor: Theme.of(context).textTheme.title.color),).visible(isDataLoaded);
    var samples = sampleList.isNotEmpty ? getList(sampleList,context) : Center(
      child: text(context,keyString(context,"err_no_sample_books_downloaded"), fontSize: ts_extra_normal,
          textColor: Theme.of(context).textTheme.title.color),).visible(isDataLoaded);
    var downloaded = downloadedList.isNotEmpty
        ? getList(downloadedList,context)
        : Center(child: text(context,keyString(context,"err_no_books_downloaded"), fontSize: ts_extra_normal,
        textColor: Theme.of(context).textTheme.title.color),).visible(isDataLoaded);

    return Container(

      color: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        children: <Widget>[
          DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: isUserLoggedIn ? AppBar(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  iconTheme: Theme.of(context).iconTheme,
                  centerTitle: true,
                  bottom: PreferredSize(
                    preferredSize: Size(double.infinity, 50),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: TabBar(
                        isScrollable: false,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorColor: Theme.of(context).textTheme.title.color,
                        labelPadding: EdgeInsets.only(left: 10, right: 10),
                        tabs: [
                          Tab(child: headingText(context,keyString(context,"lbl_samples"))),
                          Tab(child: headingText(context,keyString(context,"lbl_purchased"))),
                          Tab(child: headingText(context,keyString(context,"lbl_downloaded"))),
                        ],
                      ),
                    ),
                  ),
                  title: headingText(context,keyString(context,"lbl_my_library"))
              ) : AppBar(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  iconTheme: Theme.of(context).iconTheme,
                  centerTitle: true,
                  title: headingText(context,keyString(context,"lbl_samples"))
              ),
              body: isUserLoggedIn ? TabBarView(
                children: [
                  samples,
                  purchased,
                  downloaded,
                ],
              ) : samples,
            ),
          ),
          Center(child: loadingWidgetMaker(),).visible(isLoading)
        ],
      ),
    );
  }

  onBookClick(context, DownloadedBook mSampleDownloadTask) async {
    if (!_permissionReady) {
      _permissionReady = await checkPermission(context);
      return;
    }
    if (mSampleDownloadTask.status == DownloadTaskStatus.undefined) {
      var id = await requestDownload(
          context: context, downloadTask: mSampleDownloadTask, isSample: false);
      setState(() {
        mSampleDownloadTask.taskId = id;
        mSampleDownloadTask.status = DownloadTaskStatus.running;
      });
      await dbHelper.insert(mSampleDownloadTask);
    } else if (mSampleDownloadTask.status == DownloadTaskStatus.failed) {
      var id = await retryDownload(mSampleDownloadTask.taskId);
      setState(() {
        mSampleDownloadTask.taskId = id;
      });
    } else if (mSampleDownloadTask.status == DownloadTaskStatus.complete) {
      readFile(context,
              mSampleDownloadTask.mDownloadTask.filename,
          mSampleDownloadTask.bookName);
    } else {
      toast(mSampleDownloadTask.bookName +" "+ keyString(context,"lbl_is_downloading"));
    }
  }

  remove(DownloadedBook task,context) async {
    await delete(task.taskId);
    await dbHelper.delete(task.id);
    fetchData(context);
  }

  Widget getList(List<DownloadedBook> list,context) {
    return GridView.builder(
      itemCount: list.length,
      shrinkWrap: true,
      padding: EdgeInsets.only(bottom: spacing_standard_new,
          top: spacing_standard_new,
          left: spacing_control,
          right: spacing_control),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, childAspectRatio: 9 / 16.5),
      scrollDirection: Axis.vertical,
      controller: ScrollController(keepScrollOffset: false),
      itemBuilder: (context, index) {
        DownloadedBook bookDetail = list[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            InkWell(
              onTap: () {
                onBookClick(context, bookDetail);
              },
              child: Stack(
                alignment: Alignment.bottomRight,
                children: <Widget>[
                  AspectRatio(
                    child: Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        elevation: spacing_control_half,
                        margin: EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              spacing_control),
                        ),
                        child: networkImage(
                            bookDetail.frontCover,
                            fit: BoxFit.fill
                        )),
                    aspectRatio: 6/9,
                  ),
                  bookDetail.status == DownloadTaskStatus.undefined
                      ? Container(
                      margin: EdgeInsets.all(spacing_control),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.2)
                      ),
                      padding: EdgeInsets.all(spacing_control),
                      child: Icon(
                        Icons.file_download, size: 14, color: white,))
                      : bookDetail.status == DownloadTaskStatus.complete
                      ? InkWell(
                    onTap: () {
                      remove(bookDetail,context);
                    },
                    child: Container(
                        margin: EdgeInsets.all(spacing_control),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.2)
                        ),
                        padding: EdgeInsets.all(spacing_control),
                        child: Icon(
                          Icons.delete, size: 14, color: Colors.red,)),
                  )
                      : Container()
                ],
              ),
            ),
            Text(
              bookDetail.bookName,
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ).withStyle(color: Theme.of(context).textTheme.title.color,
                fontFamily: font_bold,
                fontSize: ts_medium).paddingOnly(right: 8, bottom: 0, top: 8),
          ],
        ).paddingAll(spacing_control);
      },
    );
  }

  void setLibraryData(BookListResponse response,List<DownloadedBook> books,List<DownloadTask> tasks) {
    var purchased = List<DownloadedBook>();

    if (response.data.isNotEmpty) {
      DownloadedBook book;
      response.data.forEach((bookDetail) {
        if (books != null && books.isNotEmpty) {
          book = isExists(books, bookDetail);
          if (book.taskId != null) {
            var task = tasks.firstWhere((task) =>
            task.taskId == book.taskId);
            book.mDownloadTask = task;
            book.status = task.status;
          } else {
            book = defaultBook(bookDetail, "purchased");
            book.mDownloadTask = defaultTask(bookDetail.filePath);
          }
        } else {
          book = defaultBook(bookDetail, "purchased");
          book.mDownloadTask = defaultTask(bookDetail.filePath);
        }
        purchased.add(book);
      });
      setState(() {
        purchasedList.clear();
        purchasedList.addAll(purchased);
      });
    }
  }


}
