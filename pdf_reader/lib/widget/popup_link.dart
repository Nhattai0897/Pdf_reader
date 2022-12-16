import 'dart:async';
import 'package:another_flushbar/flushbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf_reader/sign_vanban_den/utils/util.dart';
import 'package:pdf_reader/utils/base_multi_language.dart';
import 'package:pdf_reader/widget/scan_camera/barcode_scanner.dart';

class PopUpLinkPicker extends StatefulWidget {
  final String? title;
  final bool? isCenter;
  final BuildContext ctx;

  /// isRealModalBottom = true thì pop 1 lần, ngc lại false thì pop 2 lần để đóng Bottom sheet ảo, việc cần làm là set biến này bằng false ở những trang k dùng ModalBottomSheet
  // final bool isRealModalBottom;
  final Function(Map<String, String>)? onResult;

  PopUpLinkPicker({
    Key? key,
    this.title,
    required this.ctx,
    this.onResult,
    this.isCenter,
  }) : super(key: key);

  @override
  _PopUpLinkPickerState createState() => _PopUpLinkPickerState();
}

class _PopUpLinkPickerState extends State<PopUpLinkPicker> {
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
    showIcon(false);
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      var cdata = await Clipboard.getData(Clipboard.kTextPlain) ??
          ClipboardData(text: "");
      if (cdata.text != "" && cdata.text!.split(".").last == "pdf") {
        textController.text = cdata.text ?? "";
      }
    });
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

    return Scaffold(
        // resizeToAvoidBottomPadding: false,
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 20.0, bottom: 10),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color.fromRGBO(255, 230, 226, 1),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(100.0)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.4),
                                            blurRadius: 5,
                                            offset:
                                                Offset(3, 5), // Shadow position
                                          ),
                                        ],
                                      ),
                                      child: InkWell(
                                        onTap: () => scanAction(),
                                        child: Stack(
                                          children: [
                                            Hero(
                                              tag: 'scanQR',
                                              child: Image.asset(
                                                "assets/qr-code.png",
                                                width: 65,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 17.5, top: 28.5),
                                              child: Image.asset(
                                                "assets/qr-code.gif",
                                                width: 24.2,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5.0),
                                    child: Text(
                                        Language.of(context)!.trans("OR") ?? "",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                  ),
                                  chooseUrl(context),
                                  devider(),
                                  cancelChooseFile(context),
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

  Future<void> scanAction() async {
    try {
      var qrResult = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ScanQRCode(
          titleGuide: Language.of(context)!.trans("GuideCamera") ?? "",
        ),
      ));
      if (qrResult == null) {
        return;
      }
      if (qrResult == '') {
        Flushbar(
          messageText: Text(Language.of(context)!.trans("QRNVaild") ?? "",
              style: TextStyle(color: Colors.white)),
          icon:
              Icon(Icons.privacy_tip_outlined, color: Colors.yellowAccent[50]),
          backgroundColor: Colors.yellow[600]!,
          flushbarPosition: FlushbarPosition.TOP,
          duration: Duration(milliseconds: 1700),
        )..show(context);

        return;
      }

      getLink(qrResult);
    } catch (e) {
      Flushbar(
        messageText: Text(Language.of(context)!.trans("ScanFailed") ?? "",
            style: TextStyle(color: Colors.white)),
        icon: Icon(Icons.privacy_tip_outlined, color: Colors.redAccent[50]),
        backgroundColor: Colors.red[600]!,
        flushbarPosition: FlushbarPosition.TOP,
        duration: Duration(milliseconds: 1700),
      )..show(context);
    }
  }

  Padding scanQRCode(BuildContext context) {
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
              color: Color.fromRGBO(215, 233, 255, 1),
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
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Image.asset(
                      "assets/qr-code.png",
                      width: 40,
                    ),
                  ),
                  Text("Scan qr code ",
                      style: TextStyle(
                          color: Color.fromRGBO(33, 219, 219, 1.0),
                          fontWeight: FontWeight.bold,
                          fontSize: 15))
                ],
              ),
            )),
      ),
    );
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
                child: Text(Language.of(context)!.trans("Cancel") ?? "",
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

  Padding chooseUrl(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 15.0, right: 15.0, top: 15.0, bottom: 12.0),
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
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      ),
                      child: TextField(
                        controller: textController,
                        onSubmitted: (url) => getLink(url),
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            contentPadding: EdgeInsets.only(
                                left: 15, bottom: 11, top: 11, right: 15),
                            hintText: "https:///www.example.pdf"),
                      )),
                )),
                InkWell(
                  onTap: () => getLink(textController.text),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 2.0),
                    child: Container(
                        child: Image.asset(
                      "assets/add.png",
                    )),
                  ),
                )
              ],
            ),
          )),
    );
  }

  void getLink(String url) {
    if (url != "" && url.split('.').last == "pdf" && url.contains(".pdf")) {
      widget.onResult!({url: url});
    } else {
      Flushbar(
        messageText: Text(
            url == ""
                ? Language.of(context)!.trans("CheckLink") ?? ""
                : Language.of(context)!.trans("FormatLink") ?? "",
            style: TextStyle(color: Colors.white)),
        icon: Icon(Icons.warning, color: Colors.yellowAccent),
        backgroundColor: Colors.amber[500]!,
        flushbarPosition: FlushbarPosition.TOP,
        duration: Duration(seconds: 3),
      )..show(widget.ctx);
    }
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
                messageText: Text(
                    Language.of(context)!.trans("ChoosePDF") ?? "",
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
