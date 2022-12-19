import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:another_flushbar/flushbar.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fullpdfview/flutter_fullpdfview.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:painter/painter.dart';
import 'package:pdf_reader/sign_vanban_den/bloc/view_file_bloc.dart';
import 'package:pdf_reader/sign_vanban_den/model/choose_image_model.dart';
import 'package:pdf_reader/sign_vanban_den/state/view_file_state.dart';
import 'package:pdf_reader/sign_vanban_den/utils/util.dart';
import 'package:pdf_reader/sign_vanban_den/widget/frame_custom_support.dart';
import 'package:pdf_reader/sign_vanban_den/widget/modal_bottom_sheet_select_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_reader/sign_vanban_den/widget/showFlushbar.dart';
import 'package:pdf_reader/utils/base_multi_language.dart';
import 'package:pdf_reader/utils/bloc_builder_status.dart';
import 'package:pdf_reader/utils/networks.dart';
import 'package:pdf_reader/widget/custom_pick_color.dart';
import 'package:pdf_reader/widget/custom_popup_menu/popup_menu.dart';
import 'dart:ui' as ui;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:native_pdf_renderer/native_pdf_renderer.dart' as nativePDF;

class ViewFileMain extends StatefulWidget {
  String fileKyTen;

  /// Là tên file dùng ký số
  bool isKySo;

  /// Dùng để phân biệt ký số hay xem file, nếu xem file thì (load file Alfresco)
  bool isUseMauChuKy;

  /// Model chữ ký đã chọn dùng cho ký số
  bool? openSigned;

  /// Dùng để mở file đã ký(load file local)
  File? fileImgMauChuKy;

  /// File img đã được capture từ widget trong popup chọn mẫu chữ ký

  bool isNightMode;

  /// Chế độ buổi tối

  bool isUrl;

  /// Get mode file
  bool isPublic;

  ViewFileMain(
      {Key? key,
      required this.fileKyTen,
      required this.isKySo,
      required this.isUseMauChuKy,
      required this.isNightMode,
      required this.isPublic,
      this.isUrl = false,
      this.openSigned,
      this.fileImgMauChuKy})
      : super(key: key);

  @override
  _ViewFileMainState createState() => _ViewFileMainState();
}

class _ViewFileMainState extends State<ViewFileMain> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ViewFileBloc>(
      create: (context) => ViewFileBloc(),
      child: ViewFileHome(
          fileKyTen: widget.fileKyTen,
          isKySo: widget.isKySo,
          isUrl: widget.isUrl,
          isUseMauChuKy: widget.isUseMauChuKy,
          isNightMode: widget.isNightMode,
          openSigned: widget.openSigned,
          fileImgMauChuKy: widget.fileImgMauChuKy,
          isPublic: widget.isPublic),
    );
  }
}

class ViewFileHome extends StatefulWidget {
  String fileKyTen;
  bool isKySo;
  bool isUseMauChuKy;
  bool isUrl;
  bool? openSigned;
  File? fileImgMauChuKy;
  bool isNightMode;
  bool isPublic;

  ViewFileHome(
      {Key? key,
      required this.fileKyTen,
      required this.isKySo,
      required this.isUseMauChuKy,
      required this.isNightMode,
      required this.isUrl,
      required this.isPublic,
      this.openSigned,
      this.fileImgMauChuKy})
      : super(key: key);

  @override
  _ViewFileHomeState createState() => _ViewFileHomeState();
}

class _ViewFileHomeState extends State<ViewFileHome>
    with TickerProviderStateMixin {
  GlobalKey _globalKeyDraw = new GlobalKey();
  GlobalKey _globalKeyTextField = new GlobalKey();
  GlobalKey _globalKeySign = new GlobalKey();
  final GlobalKey _containerFakePDFViewKey = GlobalKey();
  String dir = "";
  late ViewFileBloc bloc;
  late Random random;
  bool _isLoading = true;
  bool? isReady;
  String pathFile = "";
  String pathPDF = "";
  double dxFrame = 0.0;
  double dyFrame = 0.0;
  double widthFrame = 0.0;
  double heightFrame = 0.0;
  double widthDefault = 0.0;
  double heightDefault = 0.0;
  double minHeightSize = 0.0;
  double maxHeightSize = 0.0;
  double minWidthSize = 0.0;
  double maxWidthSize = 0.0;
  double screenWidth = 0.0;
  double screenHeight = 0.0;
  int countBack = 0;
  int countEdit = 0;
  int pages = 0;
  int pageIndexTemp = 0;
  int pageIndex = 0;
  late CancelToken cancelToken;
  double firstPageHeight = 0.0;
  double firstPageWidth = 0.0;
  DateTime datetime = DateTime.now();
  List<ChosseImageModel> images = [];
  String pathOriginal = "";
  double percent = 0;
  var tempDir;
  var document;
  int countLoadImage = 0;
  String? tempPath;
  String _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  TextEditingController noiDungButPheController = TextEditingController();
  bool isLoadFileSuccess = false;
  bool isNightMode = false;
  bool isEdit = false;
  bool isEditForCap = false;

  late GlobalObjectKey<FormState> formKeyList;
  PainterController _controllerSign = _newControllerSign();
  static PainterController _newControllerSign() {
    PainterController controller = new PainterController();
    controller.thickness = 4.0;
    controller.drawColor = Colors.black.withOpacity(0.7);
    controller.backgroundColor = Colors.transparent;
    return controller;
  }

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(random.nextInt(_chars.length))));
  PainterController _controllerDraw = _newControllerDraw();
  static PainterController _newControllerDraw() {
    PainterController controller = new PainterController();
    controller.thickness = 4.0;
    controller.drawColor = Colors.black.withOpacity(0.7);
    controller.backgroundColor = Colors.transparent;
    return controller;
  }

  @override
  initState() {
    super.initState();
    pathOriginal = widget.fileKyTen;
    iniStateFnc(pathFile: widget.fileKyTen);
  }

  @override
  void dispose() {
    super.dispose();
    bloc.closeStream();
    _controllerSign.dispose();
    _controllerDraw.dispose();
    noiDungButPheController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext maincontext) {
    Completer<PDFViewController> _controller = Completer<PDFViewController>();
    initDataUI(maincontext);
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: buildPDFFrame(_controller, maincontext)),
    );
  }

  Future<bool> onWillPop() async {
    if (isReady != null) {
      Navigator.pop(context, pathPDF == "" ? pathOriginal : pathPDF);
      return true;
    } else {
      Flushbar(
        messageText: Text(Language.of(context)!.trans("FilePreparation") ?? "",
            style: TextStyle(color: Colors.white)),
        icon:
            Icon(Icons.warning_amber_rounded, color: Colors.yellowAccent[100]),
        backgroundColor: Colors.yellow[700]!,
        flushbarPosition: FlushbarPosition.TOP,
        duration: Duration(seconds: 1),
      )..show(context);
      return false;
    }
  }

  void initDataUI(maincontext) {
    screenWidth = MediaQuery.of(maincontext).size.width;
    screenHeight = MediaQuery.of(maincontext).size.height;
    widthFrame = (widthFrame == 0.0) ? screenWidth / 2.2 : widthFrame;
    heightFrame = (heightFrame == 0.0) ? screenHeight / 8 : heightFrame;
    widthDefault = (screenWidth / 2.2);
    heightDefault = screenHeight * 0.08;
    minHeightSize = screenHeight *
        0.01; // dùng cho giới hạn kéo to hay thu nhỏ widget chữ ký
    maxHeightSize = screenHeight *
        0.2; // dùng cho giới hạn kéo to hay thu nhỏ widget chữ ký
    minWidthSize =
        screenWidth / 8.0; // dùng cho giới hạn kéo to hay thu nhỏ widget chữ ký
    maxWidthSize =
        screenWidth / 1.8; // dùng cho giới hạn kéo to hay thu nhỏ widget chữ ký
    firstPageWidth = screenWidth;
    firstPageHeight = screenHeight;
    formKeyList = GlobalObjectKey<FormState>(1);
  }

  Widget buildPDFFrame(
      Completer<PDFViewController> _controller, BuildContext maincontext) {
    return BlocBuilder<ViewFileBloc, ViewFileState>(
        builder: (contextMain, state) {
      return Column(
        children: [
          Container(
              height: 60.0 + MediaQuery.of(context).padding.top,
              color: Color.fromRGBO(118, 71, 248, 1.0),
              child: Padding(
                  padding:
                      EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                          onPressed: () {
                            if (widget.isUrl) {
                              if (percent != 0) {
                                cancelToken.cancel();
                              }
                              Navigator.pop(maincontext,
                                  pathPDF == "" ? pathOriginal : pathPDF);
                            } else if (isReady != null) {
                              Navigator.pop(maincontext,
                                  pathPDF == "" ? pathOriginal : pathPDF);
                            }
                          },
                          icon: isReady != null
                              ? Icon(Icons.arrow_back_ios,
                                  color: Colors.white.withOpacity(0.8))
                              : Container(
                                  width: 40,
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.7),
                                    child: CircularProgressIndicator(
                                        strokeWidth: 3.0,
                                        color: Colors.white.withOpacity(0.2)),
                                  ))),
                      Expanded(
                        child: StreamBuilder<bool>(
                            stream: bloc.streamReady,
                            builder: (context, snapshot) {
                              var isReadyLoad = snapshot.data ?? true;
                              return isReadyLoad
                                  ? Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(0.0),
                                          child: Container(
                                              child: Text(
                                            '${Language.of(context)!.trans("Page") ?? ""} ${state.currentPage! + 1}${state.countPage != 0 ? ' / ' + state.countPage.toString() : ''}',
                                            style:
                                                TextStyle(color: Colors.white),
                                          )),
                                        ),
                                        const Spacer(),
                                        const SizedBox(width: 5.0),
                                        Visibility(
                                            child: buildHeaderPDF(
                                                _controller, state),
                                            visible: widget.isKySo,
                                            maintainState: true),
                                        const SizedBox(width: 5.0),
                                      ],
                                    )
                                  : SizedBox();
                            }),
                      )
                    ],
                  ))),
          Expanded(
              child: _isLoading
                  ? StreamBuilder<bool>(
                      stream: bloc.streamDownload,
                      builder: (context, snapshot) {
                        var isShowError = snapshot.data ?? false;
                        return Center(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            isShowError
                                ? Image.asset('assets/blocked.png', width: 65)
                                : isEdit
                                    ? Image.asset(
                                        'assets/loading.gif',
                                        width: 85,
                                      )
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(right: 15.0),
                                        child: Image.asset('assets/loading.gif',
                                            width: 85)),
                            SizedBox(
                                height: isShowError == false && isEdit == true
                                    ? 10
                                    : 10),
                            Text(isShowError
                                ? Language.of(context)!.trans("UnableLoad") ??
                                    ""
                                : isEdit
                                    ? Language.of(context)!.trans("DocSave") ??
                                        ""
                                    : widget.isUrl
                                        ? "${Language.of(context)!.trans("DocLoad") ?? ""} (${percent.toStringAsFixed(1)}%)"
                                        : "${Language.of(context)!.trans("DocLoad") ?? ""}...")
                          ],
                        ));
                      })
                  : Stack(
                      children: [
                        FutureBuilder<PDFViewController>(
                          future: _controller.future,
                          builder: (context,
                              AsyncSnapshot<PDFViewController> snapshot) {
                            if (snapshot.hasData && state.countPage == 0)
                              getCountPage(snapshot);
                            double width = 0.0;
                            double height = 0.0;
                            networkCall(snapshot, width, height, maincontext);
                            return Stack(children: [
                              buildPdfView(_controller, snapshot),
                              buildDragParent(
                                  networkCall(
                                      snapshot, width, height, maincontext),
                                  state.isDraw),
                              buildSignParent(
                                  context, state.isShowSign, snapshot, state),
                              buildImageFrame(context, state)
                            ]);
                          },
                        ),
                        StreamBuilder<bool>(
                            stream: bloc.streamLoadingDraw,
                            builder: (context, snapshot) {
                              var isLoadingDraw = snapshot.data ?? false;
                              return Visibility(
                                visible: isLoadingDraw,
                                maintainState: true,
                                child: Container(
                                  color: Colors.white,
                                  child: Center(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10.0),
                                        child: Image.asset('assets/loading.gif',
                                            width: 85),
                                      ),
                                      Text(Language.of(context)!
                                              .trans("DocSave") ??
                                          "")
                                    ],
                                  )),
                                ),
                              );
                            })
                      ],
                    )),
        ],
      );
    });
  }

  Future<List<double>> networkCall(
      snapshot, double width, double height, maincontext) async {
    if (snapshot.hasData) {
      final data = snapshot.data!;
      final indexPage = await data.getCurrentPage() ?? 0;
      width = await data.getPageWidth(indexPage) ?? 0;
      height = await data.getPageHeight(indexPage) ?? 0;
    }
    final ratioWidth = width / screenWidth;
    height = height / ratioWidth;
    if (height.isNaN) {
      return <double>[screenWidth, screenHeight / 2];
    } else {
      return <double>[width, height];
    }
  }

  FutureBuilder<List<double>> buildDragParent(
      Future<List<double>> fetchNetworkCall, bool? isDraw) {
    return FutureBuilder<List<double>>(
      future: fetchNetworkCall,
      builder: (context, builder) => StreamBuilder<bool>(
          stream: bloc.streamcCalculator,
          builder: (context, snapshotSize) {
            var result = snapshotSize.data ?? false;
            return Visibility(
              visible: result,
              child: Container(
                color: Colors.transparent,
                // Container dùng để chặn scroll 2 đầu bên ngoài frame limit
                height: screenHeight,
                child: Center(
                  child: Container(
                    color: Colors.transparent,
                    key: _containerFakePDFViewKey,
                    width: builder.data?.elementAt(0) ?? 0.0,
                    height: builder.data?.elementAt(1) ?? 50.0,
                    child: isDraw ?? false
                        ? RepaintBoundary(
                            key: _globalKeyDraw,
                            child: new Painter(_controllerDraw))
                        : ResizebleWidget(
                            onDrag: (y, x, width, height) {
                              dyFrame = y;
                              dxFrame = x;
                              widthFrame = width;
                              heightFrame = height;
                            },
                            left: dxFrame,
                            top: dyFrame,
                            width: widthFrame,
                            height: heightFrame,
                            minHeightSize: minHeightSize,
                            maxHeightSize: maxHeightSize,
                            minWidthSize: minWidthSize,
                            maxWidthSize: maxWidthSize,
                            limitHeight: builder.data?.elementAt(1) ?? 0.0,
                            child: Padding(
                              padding: const EdgeInsets.all(0),
                              child: Visibility(
                                  visible: pathFile.isNotEmpty,
                                  maintainState: true,
                                  child: Image(
                                    image: FileImage(File(pathFile)),
                                    frameBuilder: (context, child, frame,
                                        wasSynchronouslyLoaded) {
                                      return frame == null
                                          ? Container(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(65.0),
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                              width: widthFrame,
                                              height: widthFrame,
                                            )
                                          : child;
                                    },
                                  )),
                            )),
                  ),
                ),
              ),
            );
          }),
    );
  }

  Widget buildImageFrame(BuildContext context, ViewFileState state) {
    return state.showCapImage
        ? Container(
            color: Colors.black.withOpacity(0.4),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: screenHeight / 9),
                  child: Container(
                    width: screenWidth - 45,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: Offset(0, 3),
                        ),
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 15, bottom: 0.0),
                          child: Text(
                            Language.of(context)!.trans("GallerySave") ?? "",
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                        ),
                        FutureBuilder<List<ChosseImageModel>>(
                            future: _saveScreen(pathPDF, state.countPage ?? 0),
                            builder: (data, builder) {
                              if (builder.connectionState ==
                                      ConnectionState.waiting &&
                                  countLoadImage == 0) {
                                countLoadImage = countLoadImage + 1;
                                return Container(
                                    height: screenHeight / 2.8,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Center(
                                            child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset('assets/loading.gif',
                                                width: 85),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10.0),
                                              child: Text(Language.of(context)!
                                                      .trans("LoadImage") ??
                                                  ""),
                                            )
                                          ],
                                        )),
                                      ],
                                    ));
                              }
                              if (builder.hasData) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: Container(
                                      height: screenHeight / 2.8,
                                      child: GridView.builder(
                                        padding: const EdgeInsets.all(0),
                                        shrinkWrap: true,
                                        itemCount: state.imagesSeleted.length,
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          mainAxisSpacing: 5,
                                          crossAxisSpacing: 5,
                                        ),
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return state.imagesSeleted[index]
                                                      .utf8Data !=
                                                  null
                                              ? InkWell(
                                                  onTap: () {
                                                    var newList =
                                                        state.imagesSeleted;
                                                    newList[index].isselect =
                                                        !newList[index]
                                                            .isselect!;

                                                    bloc.updateSeletedLst(
                                                        imagesSeleted: newList);
                                                  },
                                                  child: Container(
                                                      color: Colors.grey[300],
                                                      child: Stack(
                                                          alignment:
                                                              Alignment.center,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .symmetric(
                                                                      vertical:
                                                                          5),
                                                              child: Image
                                                                  .memory(state
                                                                      .imagesSeleted[
                                                                          index]
                                                                      .utf8Data!),
                                                            ),
                                                            Positioned(
                                                              top: 0,
                                                              right: 3,
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .only(
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                            5),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            5),
                                                                  ),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors
                                                                              .grey[
                                                                          400]!,
                                                                      blurRadius:
                                                                          4,
                                                                      offset:
                                                                          Offset(
                                                                              3,
                                                                              3),
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      vertical:
                                                                          2,
                                                                      horizontal:
                                                                          3),
                                                                  child: Text(
                                                                    '${Language.of(context)!.trans("Page") ?? ""} ${(index + 1)}',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            10),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Positioned(
                                                                top: state
                                                                        .imagesSeleted[
                                                                            index]
                                                                        .isselect!
                                                                    ? 1
                                                                    : 3,
                                                                left: 3,
                                                                child: Container(
                                                                    width: state.imagesSeleted[index].isselect! ? 16 : 12,
                                                                    child: state.imagesSeleted[index].isselect!
                                                                        ? Image.asset('assets/checkmark.png')
                                                                        : Image.asset(
                                                                            'assets/blank-check-box.png',
                                                                            color:
                                                                                Colors.grey[600],
                                                                          )))
                                                          ])),
                                                )
                                              : SizedBox();
                                        },
                                      )),
                                );
                              }
                              return Container(height: screenHeight / 2.8);
                            }),
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: 10.0, top: 5.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                  onTap: () async {
                                    try {
                                      var indexWhere = state.imagesSeleted
                                          .indexWhere((element) =>
                                              element.isselect == true);
                                      if (indexWhere == -1) {
                                        Flushbar(
                                          messageText: Text(
                                              Language.of(context)!
                                                      .trans("ChooseImgWarn") ??
                                                  "",
                                              style: TextStyle(
                                                  color: Colors.white)),
                                          icon: Icon(
                                              Icons.warning_amber_rounded,
                                              color: Colors.yellow[100]),
                                          backgroundColor: Colors.yellow[700]!,
                                          flushbarPosition:
                                              FlushbarPosition.TOP,
                                          duration:
                                              Duration(milliseconds: 3000),
                                        )..show(context);
                                        return;
                                      } else {
                                        for (var i = 0;
                                            i < state.imagesSeleted.length;
                                            i++) {
                                          if (state.imagesSeleted[i].isselect ==
                                              true) {
                                            await ImageGallerySaver.saveImage(
                                                state.imagesSeleted[i]
                                                    .utf8Data!);
                                          }
                                        }
                                        bloc.showImageCapture(isShow: false);
                                        Flushbar(
                                          messageText: Text(
                                              Language.of(context)!
                                                      .trans("ImgSaved") ??
                                                  "",
                                              style: TextStyle(
                                                  color: Colors.white)),
                                          icon: Icon(
                                              Icons
                                                  .check_circle_outline_outlined,
                                              color: Colors.green[100]),
                                          backgroundColor: Colors.green[600]!,
                                          flushbarPosition:
                                              FlushbarPosition.TOP,
                                          duration:
                                              Duration(milliseconds: 3000),
                                        )..show(context);
                                      }
                                    } catch (e) {
                                      bloc.showImageCapture(isShow: false);
                                      Flushbar(
                                        messageText: Text(
                                            Language.of(context)!
                                                    .trans("ImgSaveFaild") ??
                                                "",
                                            style:
                                                TextStyle(color: Colors.white)),
                                        icon: Icon(Icons.warning,
                                            color: Colors.red[100]),
                                        backgroundColor: Colors.red,
                                        flushbarPosition: FlushbarPosition.TOP,
                                        duration: Duration(milliseconds: 3000),
                                      )..show(context);
                                    }
                                  },
                                  child: Container(
                                    height: 40,
                                    width: screenWidth / 2.5,
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 1,
                                          blurRadius: 2,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.blue,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Center(
                                        child: Text(
                                            Language.of(context)!
                                                    .trans("Save") ??
                                                "",
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                    ),
                                  )),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: InkWell(
                                    onTap: () =>
                                        bloc.showImageCapture(isShow: false),
                                    child: Container(
                                      height: 40,
                                      width: screenWidth / 2.5,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 1,
                                            blurRadius: 2,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Center(
                                          child: Text(Language.of(context)!
                                                  .trans("Cancel") ??
                                              ""),
                                        ),
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        : SizedBox();
  }

  void closeAllPopUp() => bloc.showSignFrame(false);

  Visibility buildSignParent(BuildContext context, bool? visible,
      AsyncSnapshot<PDFViewController> snapshotPDF, ViewFileState state) {
    return Visibility(
      visible: visible ?? false,
      maintainState: true,
      child: Container(
        color: Colors.black.withOpacity(0.4),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: screenHeight / 9),
              child: Container(
                width: screenWidth - 45,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: Offset(0, 3),
                    ),
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 5.0),
                      child: Text(
                        Language.of(context)!.trans("Signature") ?? "",
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ),
                    buildSignFrame(context),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ColorPickerButton(
                            controller: _controllerSign,
                            background: false,
                            opacity: 0.7),
                        new IconButton(
                            icon: Image.asset('assets/back.png', width: 23),
                            tooltip: Language.of(context)!.trans("Undo") ?? "",
                            onPressed: () {
                              if (_controllerSign.isEmpty) {
                                bloc.warningButPhe(
                                    title: Language.of(context)!
                                            .trans("NothingUndo") ??
                                        "",
                                    loaiThongBao: LoaiThongBao.canhBao);
                              } else {
                                _controllerSign.undo();
                              }
                            }),
                        new IconButton(
                            icon:
                                new Image.asset('assets/eraser.png', width: 23),
                            tooltip: Language.of(context)!.trans("Clear") ?? "",
                            onPressed: _controllerSign.clear),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0, top: 5.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                              onTap: () async {
                                if (_controllerSign.isEmpty) {
                                  bloc.warningButPhe(
                                      title: Language.of(context)!
                                              .trans("PleaseSign") ??
                                          "",
                                      loaiThongBao: LoaiThongBao.canhBao);
                                  return;
                                }
                                bloc.emitTypeWidget(
                                    typeEditCase: TypeEditCase.sign);
                                await snapshotPDF.data!.resetZoom(1);
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                await Future.delayed(
                                    Duration(milliseconds: 500));
                                var fileConvert = await _capturePngSign();
                                if (fileConvert != null) {
                                  pathFile = fileConvert.path;
                                }
                                bloc.showSignFrame(false);
                                await Future.delayed(
                                    Duration(milliseconds: 500));
                                await getSizeFirstPage(
                                    snapshotPDF, pageIndex, state);
                              },
                              child: Container(
                                height: 40,
                                width: screenWidth / 2.5,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 1,
                                      blurRadius: 2,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.blue,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Center(
                                    child: Text(
                                        Language.of(context)!.trans("Sign") ??
                                            "",
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              )),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: InkWell(
                                onTap: () => bloc.showSignFrame(false),
                                child: Container(
                                  height: 40,
                                  width: screenWidth / 2.5,
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 1,
                                        blurRadius: 2,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Center(
                                      child: Text(Language.of(context)!
                                              .trans("Cancel") ??
                                          ""),
                                    ),
                                  ),
                                )),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  PDFView buildPdfView(Completer<PDFViewController> _controller,
      AsyncSnapshot<PDFViewController> snapshotPDF) {
    return PDFView(
        filePath: pathPDF,
        defaultPage: 0,
        fitEachPage: true,
        fitPolicy: FitPolicy.HEIGHT,
        dualPageMode: false,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
        displayAsBook: true,
        pageSnap: true,
        backgroundColor: widget.isNightMode ? bgcolors.BLACK : bgcolors.WHITE,
        nightMode: widget.isNightMode,
        onRender: (_pages) async {
          if (snapshotPDF.hasData) {
            if (pathFile != '') {
              await snapshotPDF.data!.setPageWithAnimation(pageIndexTemp);
            } else {
              if (_pages == 1 || _pages == 2) {
                await snapshotPDF.data!.setZoom(1.07);
              } else {
                await snapshotPDF.data!.setPageWithAnimation(_pages);
                await Future.delayed(Duration(milliseconds: 50));
                await snapshotPDF.data!.setPageWithAnimation(0);
                await Future.delayed(Duration(milliseconds: 500));
                await snapshotPDF.data!.setZoom(1.07);
                await Future.delayed(Duration(milliseconds: 40));
                await snapshotPDF.data!.resetZoom(1);
              }
            }
          }
          await Future.delayed(Duration(milliseconds: 300));
          setState(() {
            pages = _pages;
            isReady = true;
          });
        },
        onViewCreated: (PDFViewController pdfViewController) =>
            _controller.complete(pdfViewController),
        onError: (error) async {
          print('link $error');
          setState(() {
            isReady = false;
            _isLoading = true;
          });
          bloc.warningButPhe(
              title: Language.of(context)!.trans("FileNExist") ?? "",
              loaiThongBao: LoaiThongBao.thatBai);
          await Future.delayed(Duration(milliseconds: 40));
          bloc.pushReady(false);
          await Future.delayed(Duration(milliseconds: 40));
          bloc.pushDownLoadData(true);
        },
        onPageChanged: (int page, int total) {
          pageIndex = page;
          bloc.setCountCurrentPage(currentPage: page);
        });
  }

  FutureBuilder buildHeaderPDF(
      Completer<PDFViewController> _controller, ViewFileState state) {
    return FutureBuilder<PDFViewController>(
        future: _controller.future,
        builder: (maincontext, AsyncSnapshot<PDFViewController> snapshotPDF) {
          return Visibility(
              child: isEdit
                  ? Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0))),
                        child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: buildHeaderCase(state.typeEditCase,
                                maincontext, snapshotPDF, state)),
                      ))
                  : Row(
                      children: [
                        InkWell(
                            onTap: () => bloc.showImageCapture(isShow: true),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: Image.asset(
                                "assets/import.png",
                                height: 28,
                              ),
                            )),
                        Visibility(
                          visible: countBack != 0,
                          maintainState: true,
                          child: InkWell(
                              onTap: (() {
                                bloc.showImageCapture(isShow: false);
                                showDialogUndo(context);
                              }),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 15),
                                child: Stack(
                                  alignment: AlignmentDirectional.bottomStart,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Image.asset(
                                        "assets/back.png",
                                        height: 27,
                                      ),
                                    ),
                                    Text(
                                      Language.of(context)!.trans("All") ?? "",
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              )),
                        ),
                        InkWell(
                            key: formKeyList,
                            onTap: () {
                              bloc.showImageCapture(isShow: false);
                              optionMenu(formKeyList, state.countPage ?? 0,
                                  snapshotPDF);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: Image.asset(
                                "assets/next.png",
                                height: 31,
                              ),
                            )),
                        InkWell(
                            onTap: () async {
                              setState(() => isEdit = true);
                              bloc.showImageCapture(isShow: false);
                              await snapshotPDF.data!.resetZoom(1);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: Image.asset(
                                "assets/pencil.png",
                                height: 23,
                              ),
                            ))
                      ],
                    ),
              visible: isLoadFileSuccess,
              maintainState: true);
        });
  }

  void showDialogUndo(contextGobal) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)), //this right here
            child: Container(
              height: screenHeight / 3.8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 10),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Image.asset(
                            "assets/file-2.png",
                            width: 83,
                          ),
                        ),
                        Image.asset(
                          "assets/undo.png",
                          width: 28,
                        )
                      ],
                    ),
                  )),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan>[
                          TextSpan(
                              text: Language.of(context)!.trans("Quesktion") ??
                                  "",
                              style: TextStyle(
                                  decoration: TextDecoration.none,
                                  fontSize: 11,
                                  color: Colors.black)),
                          TextSpan(
                              text:
                                  Language.of(context)!.trans("UndoAll") ?? "",
                              style: TextStyle(
                                  decoration: TextDecoration.none,
                                  fontSize: 11,
                                  color: Colors.red)),
                          TextSpan(
                              text: Language.of(context)!.trans("edits") ?? "",
                              style: TextStyle(
                                  decoration: TextDecoration.none,
                                  fontSize: 11,
                                  color: Colors.black))
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: screenWidth / 3.3,
                          child: RaisedButton(
                            onPressed: () async {
                              percent = 0;
                              countEdit = 0;
                              setState(() => _isLoading = true);
                              await Future.delayed(Duration(milliseconds: 50));
                              loadDocument(pathOriginal);
                              setState(() => countBack = 0);
                              Navigator.pop(context);
                            },
                            child: Text(
                              Language.of(context)!.trans("Sure") ?? "",
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Color.fromRGBO(220, 73, 85, 1),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: SizedBox(
                            width: screenWidth / 3.3,
                            child: RaisedButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                Language.of(context)!.trans("Cancel") ?? "",
                                style: TextStyle(color: Colors.black),
                              ),
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  void optionMenu(GlobalKey<State<StatefulWidget>> btnKey, int countPage,
      AsyncSnapshot<PDFViewController> snapshotPDF) {
    List<MenuItem> listPDF = [];
    for (var i = 0; i < countPage; i++) {
      listPDF.add(MenuItem.forList(
        title: i.toString(),
      ));
    }
    PopupMenu menu = PopupMenu(
        context: context,
        config: MenuConfig.forList(
            backgroundColor: Colors.black.withOpacity(0.8),
            lineColor: Colors.white,
            itemWidth: 33),
        items: listPDF,
        onClickMenu: (item, index) => onClickMenu(item, snapshotPDF),
        index: pageIndex,
        isHorizonal: true);
    menu.show(widgetKey: btnKey);
  }

  Future<void> onClickMenu(MenuItemProvider item,
      AsyncSnapshot<PDFViewController> snapshotPDF) async {
    await snapshotPDF.data!.setPageWithAnimation(int.parse(item.menuTitle));
    pageIndex = int.parse(item.menuTitle);
  }

  Widget buildHeaderCase(
      TypeEditCase? editCase, maincontext, snapshotPDF, ViewFileState state) {
    Widget widget = SizedBox();
    switch (editCase) {
      case TypeEditCase.image:
        widget = Row(children: [
          InkWell(
            onTap: () => editPDF(
                pathFileLocal: pathPDF,
                snapshotPDF: snapshotPDF,
                state: state,
                countPage: pages),
            child: Padding(
              padding: const EdgeInsets.only(left: 5),
              child: InkWell(
                child: Image.asset(
                  "assets/save.png",
                  height: 25,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: InkWell(
              onTap: () => customModalBottomSheet(maincontext,
                  isAlbum: true,
                  isChupHinh: true,
                  isFile: false, fChupHinh: () async {
                await showMediaSelection(
                    index: 0,
                    context: maincontext,
                    loaiChucNangDinhKem: MediaLoaiChucNangDinhKem.Camera);
                if (pathFile.isNotEmpty) {
                  bloc.pushIndexCalculator(true);
                  bloc.emitTypeWidget(typeEditCase: TypeEditCase.image);
                }
              }, fAlbum: () async {
                await showMediaSelection(
                    index: 0,
                    context: maincontext,
                    loaiChucNangDinhKem: MediaLoaiChucNangDinhKem.Album);
                if (pathFile.isNotEmpty) {
                  bloc.pushIndexCalculator(true);
                  bloc.emitTypeWidget(typeEditCase: TypeEditCase.image);
                }
              }),
              child: Image.asset(
                "assets/replace.png",
                height: 25,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              bloc.emitTypeWidget(typeEditCase: TypeEditCase.all);
              setState(() {
                isEdit = false;
              });
              bloc.pushIndexCalculator(false);
              bloc.showDrawFrame(false);
              _controllerSign.clear();
              _controllerDraw.clear();
              noiDungButPheController.clear();
            },
            child: Image.asset(
              "assets/cancel.png",
              height: 25,
            ),
          ),
        ]);
        break;
      case TypeEditCase.text:
        widget = Row(children: [
          InkWell(
            onTap: () => editPDF(
                pathFileLocal: pathPDF,
                snapshotPDF: snapshotPDF,
                state: state,
                countPage: pages),
            child: Padding(
              padding: const EdgeInsets.only(left: 5),
              child: InkWell(
                child: Image.asset(
                  "assets/save.png",
                  height: 25,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: InkWell(
              onTap: () =>
                  modalBottomSheetTextField(maincontext, snapshotPDF, state),
              child: Image.asset(
                "assets/rename.png",
                height: 27,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              bloc.emitTypeWidget(typeEditCase: TypeEditCase.all);
              setState(() {
                isEdit = false;
              });
              bloc.pushIndexCalculator(false);
              bloc.showDrawFrame(false);
              _controllerSign.clear();
              _controllerDraw.clear();
              noiDungButPheController.clear();
            },
            child: Image.asset(
              "assets/cancel.png",
              height: 25,
            ),
          ),
        ]);
        break;
      case TypeEditCase.sign:
        widget = Row(children: [
          InkWell(
            onTap: () => editPDF(
                pathFileLocal: pathPDF,
                snapshotPDF: snapshotPDF,
                state: state,
                countPage: pages),
            child: Padding(
              padding: const EdgeInsets.only(left: 5),
              child: InkWell(
                child: Image.asset(
                  "assets/save.png",
                  height: 25,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: InkWell(
              onTap: () => bloc.showSignFrame(true),
              child: Image.asset(
                "assets/digital-signature.png",
                height: 27,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              bloc.emitTypeWidget(typeEditCase: TypeEditCase.all);
              setState(() {
                isEdit = false;
              });
              bloc.pushIndexCalculator(false);
              bloc.showDrawFrame(false);
              _controllerSign.clear();
              _controllerDraw.clear();
              noiDungButPheController.clear();
            },
            child: Image.asset(
              "assets/cancel.png",
              height: 25,
            ),
          ),
        ]);
        break;
      case TypeEditCase.draw:
        widget = Row(children: [
          InkWell(
            onTap: () async {
              bloc.pushDownLoadDraw(true);
              var fileConvert = await _capturePngDraw();
              if (fileConvert != null) {
                pathFile = fileConvert.path;
                editPDF(
                    pathFileLocal: pathPDF,
                    snapshotPDF: snapshotPDF,
                    state: state,
                    countPage: pages);
              } else {
                bloc.warningButPhe(
                    title: Language.of(context)!.trans("EditFaild") ?? "",
                    loaiThongBao: LoaiThongBao.thatBai);
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 5),
              child: InkWell(
                child: Image.asset(
                  "assets/save.png",
                  height: 25,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: ColorPickerButton(
                controller: _controllerDraw, background: false, opacity: 0.7),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: new InkWell(
                child: Image.asset('assets/back.png', width: 23),
                onTap: () {
                  if (_controllerDraw.isEmpty) {
                    bloc.warningButPhe(
                        title: Language.of(context)!.trans("NothingUndo") ?? "",
                        loaiThongBao: LoaiThongBao.canhBao);
                  } else {
                    _controllerDraw.undo();
                  }
                }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: new InkWell(
                child: new Image.asset('assets/eraser.png', width: 23),
                onTap: _controllerDraw.clear),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: InkWell(
              onTap: () {
                bloc.emitTypeWidget(typeEditCase: TypeEditCase.all);
                setState(() {
                  isEdit = false;
                });
                bloc.pushIndexCalculator(false);
                bloc.showDrawFrame(false);
                _controllerSign.clear();
                _controllerDraw.clear();
                noiDungButPheController.clear();
              },
              child: Image.asset(
                "assets/cancel.png",
                height: 25,
              ),
            ),
          ),
        ]);
        break;
      default:
        widget = Row(children: [
          InkWell(
            onTap: () {
              closeAllPopUp();
              customModalBottomSheet(maincontext,
                  isAlbum: true,
                  isChupHinh: true,
                  isFile: false, fChupHinh: () async {
                await showMediaSelection(
                    index: 0,
                    context: maincontext,
                    loaiChucNangDinhKem: MediaLoaiChucNangDinhKem.Camera);
                if (pathFile.isNotEmpty) {
                  bloc.pushIndexCalculator(true);
                  bloc.emitTypeWidget(typeEditCase: TypeEditCase.image);
                }
              }, fAlbum: () async {
                await showMediaSelection(
                    index: 0,
                    context: maincontext,
                    loaiChucNangDinhKem: MediaLoaiChucNangDinhKem.Album);
                if (pathFile.isNotEmpty) {
                  bloc.pushIndexCalculator(true);
                  bloc.emitTypeWidget(typeEditCase: TypeEditCase.image);
                }
              });
            },
            child: Image.asset(
              "assets/gallery.png",
              height: 25,
            ),
          ),
          InkWell(
            onTap: () {
              closeAllPopUp();
              modalBottomSheetTextField(maincontext, snapshotPDF, state);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Image.asset(
                "assets/edit-text.png",
                height: 25,
              ),
            ),
          ),
          InkWell(
              onTap: () {
                closeAllPopUp();
                bloc.showSignFrame(true);
              },
              child: Image.asset(
                "assets/signature.png",
                height: 25,
              )),
          InkWell(
            onTap: () {
              closeAllPopUp();
              bloc.pushIndexCalculator(true);
              bloc.showDrawFrame(true);
              bloc.emitTypeWidget(typeEditCase: TypeEditCase.draw);
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 13.0, right: 10.0),
              child: Image.asset(
                "assets/highlight.png",
                height: 25,
              ),
            ),
          ),
          InkWell(
            onTap: () => closeEdit(),
            child: Image.asset(
              "assets/cancel.png",
              height: 25,
            ),
          ),
        ]);
        break;
    }
    return widget;
  }

  void closeEdit() {
    closeAllPopUp();
    bloc.emitTypeWidget(typeEditCase: TypeEditCase.all);
    cancelChonViTriKy();
    setState(() => isEdit = false);
    bloc.pushIndexCalculator(false);
    bloc.showDrawFrame(false);
    _controllerSign.clear();
    _controllerDraw.clear();
    noiDungButPheController.clear();
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
        pathFile = pickedFile?.path ?? '';
        Navigator.pop(context);
        // print('pathFile 123: $pathFile');
        break;
      case MediaLoaiChucNangDinhKem.Album:
        PickedFile? pickedFile =
            await picker.getImage(source: ImageSource.gallery);
        pathFile = pickedFile?.path ?? '';
        Navigator.pop(context);
        break;
      case MediaLoaiChucNangDinhKem.File:
        // File file = await FilePicker.getFile();
        FilePickerResult? file = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'xlsx', 'docx'],
          allowMultiple: false,
        );
        pathFile = file!.paths.first!;
        Navigator.pop(context);
        break;
      case MediaLoaiChucNangDinhKem.Video:
        break;
    }
  }

  void cancelChonViTriKy() {
    dxFrame = 0.0;
    dyFrame = 0.0;
  }

  void iniStateFnc({required String pathFile}) {
    cancelToken = CancelToken();
    random = new Random();
    bloc = BlocProvider.of<ViewFileBloc>(context);
    bloc.initContext(context, pathFile.toString());
    pathPDF = pathFile;
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      tempPath = await FileLocalResponse().getPathLocal(
        ePathType: EPathType.Storage,
        configPathStr: widget.isPublic ? 'publicFolder' : 'privateFolder',
      );
      tempDir = await getTemporaryDirectory();
      dir = (await getApplicationDocumentsDirectory()).path;
      document = await nativePDF.PdfDocument.openFile(pathPDF);
    });
    if (widget.isKySo == false) {
      if (widget.isUrl) {
        //Online
        changePDF(pathFile.toString()).then((value) {
          if (value != null) {
            //  valueStr = value;
          } else {
            bloc.pushDownLoadData(true);
          }
        });
      } else {
        //Off line
        loadDocument(pathFile.toString());
      }
    } else {
      if (widget.isUrl == true ||
          pathFile.contains('.com') ||
          pathFile.contains('https')) {
        //Online
        changePDF(pathFile.toString()).then((value) {
          if (value != null) {
            //valueStr = value;
          } else {
            bloc.pushDownLoadData(true);
          }
        });
      } else {
        //Off line
        //isReady = false;
        loadDocument(pathFile.toString());
        pathPDF = widget.fileKyTen;
        isLoadFileSuccess = true;
      }
    }
  }

  Future<String?> editPDF(
      {required String pathFileLocal,
      required AsyncSnapshot<PDFViewController> snapshotPDF,
      required ViewFileState state,
      required int countPage}) async {
    try {
      pageIndexTemp = pageIndex;
      //Load the existing PDF document.
      final PdfDocument document =
          PdfDocument(inputBytes: File(pathFileLocal).readAsBytesSync());
      //Get the existing PDF page.
      final PdfPage page = document.pages[pageIndex];

      double dx = 0.0;
      double dy = 0.0;
      if (snapshotPDF.hasData) {
        final dataPDF = snapshotPDF.data!;
        //final currentPage = await dataPDF.getCurrentPage() ?? 0;
        final widthPage = await dataPDF.getPageWidth(pageIndex) ?? 0.0;
        final heightPage = await dataPDF.getPageHeight(pageIndex) ?? 0.0;
        final widthPDFCanvas = page.size.width;
        final heightPDFCanvas = page.size.height;
        final widthPDFForScreen = MediaQuery.of(context).size.width;
        final heightPDFForScreen = (widthPDFForScreen * heightPage) / widthPage;
        final ratioWidthCanvas = widthPDFCanvas / widthPDFForScreen;
        final ratioHeightCanvas = heightPDFCanvas / heightPDFForScreen;
        widthFrame = this.widthFrame * ratioWidthCanvas;
        heightFrame = this.heightFrame * ratioHeightCanvas;
        dx = dxFrame * ratioWidthCanvas;
        dy = dyFrame * ratioHeightCanvas;
        //Draw the image
        page.graphics.drawImage(
            PdfBitmap(File(pathFile).readAsBytesSync()),
            Rect.fromLTWH(
                state.typeEditCase == TypeEditCase.draw ? 0.0 : dx,
                state.typeEditCase == TypeEditCase.draw ? 0.0 : dy,
                state.typeEditCase == TypeEditCase.draw
                    ? widthPDFCanvas
                    : widthFrame,
                state.typeEditCase == TypeEditCase.draw
                    ? heightPDFCanvas
                    : heightFrame));
        //Save the document.
        if (tempPath == null || tempPath == "") {
          tempPath = await FileLocalResponse().getPathLocal(
            ePathType: EPathType.Storage,
            configPathStr: widget.isPublic ? 'publicFolder' : 'privateFolder',
          );
        }
        var nameOld = widget.fileKyTen.contains("_edit_")
            ? widget.fileKyTen
                .split("/")
                .last
                .split("_edit_")
                .first
                .replaceAll(".pdf", '')
            : widget.fileKyTen.split("/").last.replaceAll(".pdf", '');
        var nameFile =
            '${nameOld}_edit_${datetime.day}${datetime.hour}${datetime.second}_${getRandomString(4)}.pdf';
        var linkResult = "$tempPath$nameFile";
        // Delete sign file or capture
        await File(pathFile).delete();
        pathFile = linkResult;
        countLoadImage = 0;
        File(pathFile).writeAsBytes(document.saveSync());
        setState(() {
          _isLoading = true;
          countBack = countBack + 1;
          countEdit = countEdit + 1;
          isEditForCap = true;
        });
        await Future.delayed(Duration(milliseconds: 500));
        loadDocument(linkResult);

        closeEdit();

        if (countEdit != 1) {
          //Delete old file
          if (!pathFileLocal.contains("/storage/emulated/0/Download/")) {
            await File(pathFileLocal).delete();
          }
        }

        //Dispose the document.
        document.dispose();
        if (state.typeEditCase == TypeEditCase.draw) {
          widthFrame = screenWidth / 2.2;
          heightFrame = screenHeight / 8;
        }
        return linkResult;
      } else {
        return '';
      }
    } catch (e) {
      debugPrint('error edit file: $e');
      bloc.pushDownLoadDraw(false);
      bloc.warningButPhe(
          title: Language.of(context)!.trans("EditFaild") ?? "",
          loaiThongBao: LoaiThongBao.thatBai);

      setState(() => _isLoading = false);
      return '';
    }
  }

  Future<List<ChosseImageModel>> _saveScreen(
      String filePath, int countPage) async {
    try {
      if (images.length == 0 || isEditForCap) {
        if (isEditForCap) {
          isEditForCap = false;
          document = await nativePDF.PdfDocument.openFile(pathPDF);
        }

        images = [];
        for (var i = 1; i < countPage + 1; i++) {
          final page = await document.getPage(i);
          final pageImage = await page.render(
              width: page.width,
              height: page.height,
              backgroundColor: "#f6f6f6");
          await page.close();
          images.add(
              ChosseImageModel(utf8Data: pageImage?.bytes!, isselect: false));
        }
        bloc.updateSeletedLst(imagesSeleted: images);
      }
      return images;
    } catch (e) {
      bloc.showImageCapture(isShow: false);
      Flushbar(
        title: Language.of(context)!.trans("ErrorConvertImg") ?? "",
        flushbarStyle: FlushbarStyle.FLOATING,
        messageText: Text(Language.of(context)!.trans("occurredDownload") ?? "",
            style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.normal)),
        icon: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: Image.asset(
                'assets/icon_notification.png',
                width: 20,
              ),
            ),
          ),
        ),
        titleColor: Colors.grey[350],
        backgroundColor: Colors.black.withOpacity(0.8),
        flushbarPosition: FlushbarPosition.TOP,
        barBlur: 1.0,
        margin: EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(15),
        duration: Duration(milliseconds: 3000),
      )..show(context);
      print(e);
      return [];
    }
  }

  Future<void> getCountPage(AsyncSnapshot<PDFViewController> snapshot) async {
    final int pageCount = await snapshot.data!.getPageCount() ?? 0;
    bloc.setCountPage(countPage: pageCount);
  }

  Future<void> getSizeFirstPage(AsyncSnapshot<PDFViewController> snapshot,
      int index, ViewFileState state) async {
    final snapshotPDF = snapshot.data!;
    final indexPage = await snapshotPDF.getCurrentPage() ?? 0;
    double heightPDF = await snapshotPDF.getPageHeight(indexPage) ?? 0.0;
    double widthPDF = await snapshotPDF.getPageWidth(indexPage) ?? 0.0;
    double tilePDF = widthPDF / screenWidth;
    double heightLimitFrame = heightPDF / tilePDF;
    firstPageHeight = heightLimitFrame;
    firstPageWidth = screenWidth;
    bloc.pushIndexCalculator(true);
  }

  Future<String?> createFileOfPdfUrl(String link) async {
    try {
      final filename = link.substring(link.lastIndexOf("/") + 1);
      if (dir == "") {
        dir = (await getApplicationDocumentsDirectory()).path;
      }
      final dio = Dio();

      Response response = await dio.download(link, '$dir/$filename',
          cancelToken: cancelToken,
          options: Options(
              responseType: ResponseType.bytes,
              followRedirects: false,
              contentType: Headers.formUrlEncodedContentType,
              receiveTimeout: 60 * 1000,
              sendTimeout: 10000), onReceiveProgress: (count, total) {
        setState(() => percent = (count / total) * 100);
      });
      if (response.statusCode != 404) {
        return '$dir/$filename';
      } else {
        isReady = false;
        bloc.pushErrorData(true);
        return null;
      }
    } catch (e) {
      isReady = false;
      bloc.pushErrorData(true);
      await Future.delayed(Duration(milliseconds: 50));
      if (percent == 0) {
        bloc.warningButPhe(
            title: Language.of(context)!.trans("DoanloadFFaild") ?? "",
            loaiThongBao: LoaiThongBao.thatBai);
      }
      pathPDF = 'error';
      return null;
    }
  }

  Future<String?> changePDF(link) async {
    setState(() => _isLoading = true);
    await createFileOfPdfUrl(link).then((value) {
      if (value != null && value != "") {
        pathPDF = value;
        isLoadFileSuccess = true;
        setState(() => _isLoading = false);
        return pathPDF;
      } else {
        setState(() => _isLoading = true);
        return null;
      }
    });
  }

  void modalBottomSheetTextField(BuildContext contextBT,
      AsyncSnapshot<PDFViewController> snapshotPDF, ViewFileState state) {
    showModalBottomSheet(
        barrierColor: Colors.black.withOpacity(0.3),
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: contextBT,
        builder: (BuildContext bc) {
          return InkWell(
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: screenHeight / 3.0),
                  child: Container(
                    width: screenWidth - 60,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: Offset(0, 3),
                        ),
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 5.0),
                          child: Text(
                            Language.of(context)!.trans("Content") ?? "",
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                        ),
                        _buildTextField(contextBT),
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: 10.0, top: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                  onTap: () async {
                                    if (noiDungButPheController.text.isEmpty) {
                                      bloc.warningButPhe(
                                          title: Language.of(context)!
                                                  .trans("EnterContent") ??
                                              "",
                                          loaiThongBao: LoaiThongBao.canhBao);
                                      return;
                                    }

                                    bloc.emitTypeWidget(
                                        typeEditCase: TypeEditCase.text);

                                    await snapshotPDF.data!.resetZoom(1);
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                    await Future.delayed(
                                        Duration(milliseconds: 500));
                                    var fileConvert =
                                        await _capturePngTextField();
                                    if (fileConvert != null) {
                                      pathFile = fileConvert.path;
                                    }
                                    Navigator.pop(contextBT);
                                    await Future.delayed(
                                        Duration(milliseconds: 500));
                                    await getSizeFirstPage(
                                        snapshotPDF, pageIndex, state);
                                    // bloc.pushShowData(true);
                                  },
                                  child: Container(
                                    height: 40,
                                    width: screenWidth / 3,
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 1,
                                          blurRadius: 2,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.blue,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Center(
                                        child: Text(
                                            Language.of(context)!
                                                    .trans("Continue") ??
                                                "",
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                    ),
                                  )),
                              Padding(
                                padding: const EdgeInsets.only(left: 15.0),
                                child: InkWell(
                                    onTap: () {
                                      noiDungButPheController.clear();
                                      Navigator.pop(contextBT);
                                    },
                                    child: Container(
                                      height: 40,
                                      width: screenWidth / 3,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 1,
                                            blurRadius: 2,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Center(
                                          child: Text(Language.of(context)!
                                                  .trans("Cancel") ??
                                              ""),
                                        ),
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }

  Widget buildSignFrame(context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      margin: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      child: RepaintBoundary(
          key: _globalKeySign,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            height: screenHeight / 3.5,
            child: new Painter(_controllerSign),
          )),
    );
  }

  Widget _buildTextField(context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: RepaintBoundary(
            key: _globalKeyTextField,
            child: TextField(
              autofocus: true,
              onChanged: (value) {
                print(value.length);
                if (value.length > 220) bloc.showLimitLength();
              },
              style: TextStyle(fontSize: 18),
              controller: noiDungButPheController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: Language.of(context)!.trans("TypeSomething") ?? "",
                  fillColor: Colors.transparent,
                  filled: true,
                  hintStyle: TextStyle(fontSize: 16)),
              maxLines: 10,
              minLines: 1,
            )),
      ),
    );
  }

  Future<File?> _capturePngTextField() async {
    try {
      late int tailNumber;
      final dateFolder = datetime.day;
      tailNumber = random.nextInt(1000);
      final RenderRepaintBoundary? boundary = _globalKeyTextField.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      ui.Image image = await boundary!.toImage(pixelRatio: 3.0);

      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      File fileMauChuKy = await File(
              '${tempDir.path}/TextFieldmauChuKy_image_$tailNumber@$dateFolder.png')
          .create();
      fileMauChuKy.writeAsBytesSync(pngBytes);
      bloc.emitFileWidget(fileImageWidget: fileMauChuKy);
      return fileMauChuKy;
    } catch (e) {
      print('_capturePng' + "$e");
      return null;
    }
  }

  Future<File?> _capturePngSign() async {
    try {
      late int tailNumber;
      final dateFolder = datetime.day;
      tailNumber = random.nextInt(1000);
      final RenderRepaintBoundary? boundary = _globalKeySign.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      ui.Image image = await boundary!.toImage(pixelRatio: 3.0);

      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      File fileMauChuKy = await File(
              '${tempDir.path}/TextFieldmauChuKySign_image_$tailNumber@$dateFolder.png')
          .create();
      fileMauChuKy.writeAsBytesSync(pngBytes);
      bloc.emitFileWidget(fileImageWidget: fileMauChuKy);
      return fileMauChuKy;
    } catch (e) {
      print('_capturePngSign' + "$e");
      return null;
    }
  }

  Future<File?> _capturePngDraw() async {
    try {
      late int tailNumber;
      final dateFolder = datetime.day;
      tailNumber = random.nextInt(1000);
      final RenderRepaintBoundary? boundary = _globalKeyDraw.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      ui.Image image = await boundary!.toImage(pixelRatio: 3.0);

      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      // final tempDir = await getTemporaryDirectory();
      File fileMauChuKy = await File(
              '${tempDir.path}/SignDraw_image_$tailNumber@$dateFolder.png')
          .create();
      fileMauChuKy.writeAsBytesSync(pngBytes);
      bloc.emitFileWidget(fileImageWidget: fileMauChuKy);
      return fileMauChuKy;
    } catch (e) {
      print('_capturePngDraw' + "$e");
      return null;
    }
  }

  void loadDocument(String? link) {
    if (link != null) {
      pathPDF = link;
      setState(() => _isLoading = false);
    }
  }
}
