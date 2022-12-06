import 'dart:async';
import 'package:another_flushbar/flushbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf_reader/sign_vanban_den/utils/util.dart';

class PopUpListPicker extends StatefulWidget {
  final List<Map<String, String>>? listData;
  final String? title;
  final bool? isCenter;
  final BuildContext ctx;
  final List<String>? imageList;
  final bool isZalo;
  final bool isDownloadFolder;
  final bool isAccess;
  final bool isWarning;
  final bool isRequestAllFile;

  /// isRealModalBottom = true thì pop 1 lần, ngc lại false thì pop 2 lần để đóng Bottom sheet ảo, việc cần làm là set biến này bằng false ở những trang k dùng ModalBottomSheet
  // final bool isRealModalBottom;
  final Function(Map<String, String>)? onResult;

  final Function()? onRequsetPermis;

  PopUpListPicker(
      {Key? key,
      this.listData,
      this.title,
      required this.ctx,
      required this.onRequsetPermis,
      required this.isZalo,
      required this.isDownloadFolder,
      this.onResult,
      this.isCenter,
      this.imageList,
      required this.isWarning,
      required this.isAccess,
      required this.isRequestAllFile
      //this.isRealModalBottom
      })
      : super(key: key);

  @override
  _PopUpListPickerState createState() => _PopUpListPickerState();
}

class _PopUpListPickerState extends State<PopUpListPicker> {
  var screenWidth, screenHeight;

  List<Map<String, String>>? listDataTemp;

  TextEditingController textController = TextEditingController();

  StreamController showIconStreamController = StreamController<bool>();

  Stream get showIconStream => showIconStreamController.stream;

  void showIcon(bool value) {
    showIconStreamController.sink.add(value);
  }

  StreamController changeDataStreamController = StreamController<bool>();

  Stream get changeDataStream => changeDataStreamController.stream;

  void changeData(bool value) {
    changeDataStreamController.sink.add(value);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.isCenter != null ? widget.isCenter : true;
    listDataTemp = widget.listData;
    showIcon(false);
    if (!widget.isAccess && widget.isWarning) {
      WidgetsBinding.instance!.addPostFrameCallback((_) => Flushbar(
            messageText: Text(
                'External storage access is denied, so the list of suggestions will be hidden',
                style: TextStyle(color: Colors.white)),
            icon: Icon(Icons.warning_amber_rounded,
                color: Colors.yellowAccent[100]),
            backgroundColor: Colors.yellow[700]!,
            flushbarPosition: FlushbarPosition.TOP,
            duration: Duration(seconds: 3),
          )..show(context));
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    showIconStreamController.close();
    changeDataStreamController.close();
    textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return widget.imageList != null
        ? Scaffold(
            backgroundColor: Colors.black.withOpacity(0.5),
            body: Column(
              mainAxisAlignment: widget.isCenter == true
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.end,
              children: [
                AnimationConfiguration.synchronized(
                  duration: Duration(milliseconds: 500),
                  child: SlideAnimation(
                    verticalOffset: 600,
                    child: Container(
                      margin: EdgeInsets.only(left: 20, right: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      child: _listDataDialog(
                          context, listDataTemp ?? [], widget.imageList),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AnimationConfiguration.synchronized(
                    duration: Duration(milliseconds: 600),
                    child: SlideAnimation(
                      verticalOffset: 600,
                      child: SafeArea(
                        top: false,
                        bottom: false,
                        child: Container(
                          padding: EdgeInsets.only(
                              top: 8, bottom: 0, left: 20, right: 20),
                          alignment: Alignment.topCenter,
                          child: Container(
                            height: 44,
                            width: screenWidth,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: new BorderRadius.circular(10.0),
                            ),
                            child: FlatButton(
                              shape: new RoundedRectangleBorder(
                                  borderRadius:
                                      new BorderRadius.circular(10.0)),
                              padding: EdgeInsets.all(0),
                              child: MediaQuery(
                                data: MediaQuery.of(context)
                                    .copyWith(textScaleFactor: 1.0),
                                child: Text(
                                  "HUỶ",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              onPressed: () {
                                int count = Platform.isIOS ? 1 : 1;
                                Navigator.of(context)
                                    .popUntil((_) => count++ >= 2);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ))
        : Scaffold(
            backgroundColor: Colors.black.withOpacity(0.7),
            body: Stack(
              children: [
                InkWell(
                  onTap: () {
                    int count = Platform.isIOS ? 1 : 1;
                    Navigator.of(context).popUntil((_) => count++ >= 2);
                  },
                  child: Container(),
                ),
                Column(
                  mainAxisAlignment: widget.isCenter == true
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 15.0, right: 15, top: 18),
                      child: AnimationConfiguration.synchronized(
                        duration: Duration(milliseconds: 500),
                        child: SlideAnimation(
                          verticalOffset: 600,
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 0.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      listDataTemp != null &&
                                              listDataTemp?.length != 0
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 15.0),
                                              child: Text("Suggest",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16)),
                                            )
                                          : SizedBox(),
                                      listDataTemp != null &&
                                              listDataTemp?.length != 0
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15.0,
                                                  top: 5.0,
                                                  bottom: 5),
                                              child: Container(
                                                width: double.infinity,
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "Suggest file from ",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 11,
                                                          fontWeight: FontWeight
                                                              .normal),
                                                    ),
                                                    widget.isDownloadFolder
                                                        ? Row(
                                                            children: [
                                                              Text(
                                                                "download  ",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        11,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal),
                                                              ),
                                                              Container(
                                                                width: 12,
                                                                child: Image.asset(
                                                                    "assets/download.png"),
                                                              )
                                                            ],
                                                          )
                                                        : SizedBox(),
                                                    widget.isZalo &&
                                                            widget
                                                                .isDownloadFolder
                                                        ? Text(
                                                            " & ",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 11,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal),
                                                          )
                                                        : SizedBox(),
                                                    widget.isZalo
                                                        ? Row(
                                                            children: [
                                                              Text(
                                                                "Zalo ",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        11,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal),
                                                              ),
                                                              Container(
                                                                width: 14,
                                                                child: Image.asset(
                                                                    "assets/zalo.png"),
                                                              )
                                                            ],
                                                          )
                                                        : SizedBox(),
                                                    Text(
                                                      "folder ",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 11,
                                                          fontWeight: FontWeight
                                                              .normal),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : SizedBox(),
                                      _listDataDialog(
                                          context, listDataTemp ?? [], []),
                                      listDataTemp != null &&
                                              listDataTemp?.length != 0
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5.0),
                                              child: Text("OR",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16)),
                                            )
                                          : SizedBox(),
                                      listDataTemp == null ||
                                              listDataTemp?.length == 0
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 25, bottom: 15),
                                              child: Container(
                                                width: 105,
                                                child: Image.asset(
                                                    "assets/5g.png"),
                                              ),
                                            )
                                          : SizedBox(),
                                      chooseFileStorage(context),
                                      devider(),
                                      cancelChooseFile(context),
                                      widget.isAccess == false
                                          ? widget.isRequestAllFile
                                              ? chooseSuggest(context)
                                              : SizedBox()
                                          : SizedBox(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ));
  }

  Padding cancelChooseFile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 15.0, right: 15.0, bottom: 15.0, top: 10.0),
      child: InkWell(
        onTap: () {
          int count = Platform.isIOS ? 1 : 1;
          Navigator.of(context).popUntil((_) => count++ >= 2);
        },
        child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 5,
                  offset: Offset(3, 5), // Shadow position
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Center(
                child: Text("Cancel",
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ),
            )),
      ),
    );
  }

  Container devider() {
    return Container(width: 150, height: 1.0, color: Colors.grey[300]);
  }

  Padding chooseSuggest(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 5.0),
      child: InkWell(
        onTap: () => widget.onRequsetPermis!(),
        child: Container(
            width: double.infinity,
            height: 50,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 0.0),
                    child: Image.asset(
                      "assets/idea.gif",
                      width: 35,
                    ),
                  ),
                  Text("Show list of suggested files",
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Color.fromRGBO(51, 204, 204, 1.0),
                          fontWeight: FontWeight.w400,
                          fontSize: 14))
                ],
              ),
            )),
      ),
    );
  }

  Padding chooseFileStorage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 15.0, right: 15.0, top: 15.0, bottom: 12.0),
      child: InkWell(
        onTap: () => showMediaSelection(
            index: 0,
            context: context,
            loaiChucNangDinhKem: MediaLoaiChucNangDinhKem.File),
        child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 230, 226, 1),
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 5,
                  offset: Offset(3, 5), // Shadow position
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/add.png",
                  ),
                  Text("Choose file from storage",
                      style: TextStyle(
                          color: Color.fromRGBO(252, 87, 59, 1.0),
                          fontWeight: FontWeight.bold,
                          fontSize: 15))
                ],
              ),
            )),
      ),
    );
  }

  Future<void> showMediaSelection({
    required BuildContext context,
    required int index,
    MediaLoaiChucNangDinhKem? loaiChucNangDinhKem,
  }) async {
    ImagePicker picker = ImagePicker();
    switch (loaiChucNangDinhKem!) {
      case MediaLoaiChucNangDinhKem.Camera:
        PickedFile? pickedFile =
            await picker.getImage(source: ImageSource.camera);

        Navigator.pop(context);
        break;
      case MediaLoaiChucNangDinhKem.Album:
        PickedFile? pickedFile =
            await picker.getImage(source: ImageSource.gallery);

        Navigator.pop(context);
        break;
      case MediaLoaiChucNangDinhKem.File:
        FilePickerResult? file = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
          allowMultiple: false,
        );
        if (file != null) {
          Map<String, String> data = {
            file.paths.first ?? "": file.paths.first?.split("/").last ?? ""
          };

          if (!data.keys.toString().split(".").last.contains("pdf")) {
            try {
              Flushbar(
                messageText: Text("Please choose pdf file!",
                    style: TextStyle(color: Colors.white)),
                icon: Icon(Icons.warning, color: Colors.yellowAccent),
                backgroundColor: Colors.amber[500]!,
                flushbarPosition: FlushbarPosition.TOP,
                duration: Duration(seconds: 3),
              )..show(widget.ctx);
              return;
            } catch (e) {
              print('error flusbar $e');
            }
          }
          widget.onResult!(data);
          Navigator.pop(context);
        }

        break;
      case MediaLoaiChucNangDinhKem.Video:
        break;
    }
  }

  Widget _listDataDialog(BuildContext context,
      List<Map<String, String>> listData, List<String>? imageList) {
    String title, id;
    double heightDialog;
    if (listData.length <= 3) {
      heightDialog = listData.length * 47.0;
    } else if (listData.length < 10) {
      heightDialog = listData.length * 45.0;
    } else {
      heightDialog = 200;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
              color: Colors.grey.withOpacity(0.1)),
          padding: EdgeInsets.only(top: 0),
          margin: EdgeInsets.symmetric(horizontal: 0),
          height: heightDialog,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 5),
              itemCount: listData.length,
              itemBuilder: (BuildContext context, int index) {
                title = listData[index].values.first;
                id = listData[index].keys.first;
                bool isZalo = listData[index].keys.first.contains("/Zalo");
                return _renderFrameItem(
                    title: listData[index].values.first,
                    isZaloFolder: isZalo,
                    index: index,
                    context: context,
                    images: imageList!.isEmpty ? "" : imageList[index],
                    data: {id: title});
              },
            ),
          )),
    );
  }

  Widget _renderFrameItem({
    @required String? title,
    required bool isZaloFolder,
    @required Map<String, String>? data,
    @required int? index,
    @required BuildContext? context,
    @required String? images,
  }) {
    return Container(
        height: 45,
        color: Colors.transparent,
        child: InkWell(
          splashColor: Colors.grey[300],
          onTap: () {
            widget.onResult!(data!);
            Navigator.pop(widget.ctx);
            // int count = Platform.isIOS ? 0 : 1;
            //Navigator.of(context).popUntil((_) => count++ >= 2);
          },
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    child: Padding(
                        padding: const EdgeInsets.only(left: 8, top: 12),
                        child: Image.asset(
                            images == "" ? "assets/file-format.png" : images!)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30, top: 8),
                    child: Container(
                      width: isZaloFolder ? 13 : 11,
                      child: Padding(
                          padding: const EdgeInsets.all(0),
                          child: Image.asset(images == ""
                              ? isZaloFolder
                                  ? "assets/zalo.png"
                                  : "assets/download.png"
                              : images!)),
                    ),
                  )
                ],
              ),
              SizedBox(width: 5),
              Expanded(
                  child: Text(
                title ?? "",
                style: TextStyle(fontSize: 12.0),
              )),
            ],
          ),
        ));
  }
}
