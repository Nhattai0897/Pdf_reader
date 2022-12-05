import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_fullpdfview/flutter_fullpdfview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:painter/painter.dart';
import 'package:pdf_reader/sign_vanban_den/bloc/view_file_bloc.dart';
import 'package:pdf_reader/sign_vanban_den/state/view_file_state.dart';
import 'package:pdf_reader/sign_vanban_den/utils/util.dart';
import 'package:pdf_reader/sign_vanban_den/widget/frame_custom_support.dart';
import 'package:pdf_reader/sign_vanban_den/widget/modal_bottom_sheet_select_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_reader/sign_vanban_den/widget/showFlushbar.dart';
import 'package:pdf_reader/utils/bloc_builder_status.dart';
import 'package:pdf_reader/utils/networks.dart';
import 'package:pdf_reader/widget/custom_popup_menu/popup_menu.dart';
import 'dart:ui' as ui;
import 'package:syncfusion_flutter_pdf/pdf.dart';

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
  late String valueStr;
  late ViewFileBloc bloc;
  late Random random;
  double ratioParam = 0.0;
  bool _isLoading = true;
  bool isReady = false;
  String pathFile = '';
  String pathPDF = "";
  String noiDungButPhe = '';
  Offset offset = Offset.zero;
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
  double widthPage = 0.0;
  double heightPage = 0.0;
  double screenWidth = 0.0;
  double screenHeight = 0.0;
  double paddingTop = 0.0;
  int countBack = 0;
  int pages = 0;
  int pageIndexTemp = 0;
  int pageIndex = 0;
  double finalPageHeight = 0.0;
  double finalPageWidth = 0.0;
  double firstPageHeight = 0.0;
  double firstPageWidth = 0.0;
  DateTime datetime = DateTime.now();
  String pathOrisinal = "";
  var tempDir;
  String? tempPath;
  String _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  TextEditingController noiDungButPheController = TextEditingController();
  bool isUseSignTemp = false;
  bool isLoadFileSuccess = false;
  bool isNightMode = false;
  bool isEdit = false;
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
    pathOrisinal = widget.fileKyTen;
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
    {
      Navigator.pop(context, pathPDF == "" ? pathOrisinal : pathPDF);
      return true;
    }
  }

  void initDataUI(maincontext) {
    screenWidth = MediaQuery.of(maincontext).size.width;
    screenHeight = MediaQuery.of(maincontext).size.height;
    paddingTop = 30 + MediaQuery.of(context).padding.top;
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
    finalPageWidth = screenWidth;
    finalPageHeight = screenWidth;
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
                            Navigator.pop(maincontext,
                                pathPDF == "" ? pathOrisinal : pathPDF);
                          },
                          icon:
                              Icon(Icons.arrow_back_ios, color: Colors.white)),
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
                                            'Page ${state.currentPage! + 1}${state.countPage != 0 ? ' / ' + state.countPage.toString() : ''}',
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
                                        'assets/progress_save.gif',
                                        width: 100,
                                      )
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(right: 15.0),
                                        child: Image.asset('assets/loading.gif',
                                            width: 85)),
                            SizedBox(height: 10),
                            Text(isShowError
                                ? "Unable to load document!"
                                : isEdit
                                    ? "Document saving..."
                                    : "Document loading...")
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
                                  context, state.isShowSign, snapshot, state)
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
                                      Image.asset('assets/progress_save.gif',
                                          width: 100),
                                      SizedBox(height: 10),
                                      Text("Document saving...")
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

  // Future<File> _getLocalFile(String filename) async {
  //   String dir = (await getApplicationDocumentsDirectory()).path;
  //   File f = new File('$dir/$filename');
  //   return f;
  // }

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
                        "Signature",
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
                            tooltip: 'Undo',
                            onPressed: () {
                              if (_controllerSign.isEmpty) {
                                bloc.warningButPhe(
                                    title: ' Nothing to undo',
                                    loaiThongBao: LoaiThongBao.canhBao);
                              } else {
                                _controllerSign.undo();
                              }
                            }),
                        new IconButton(
                            icon:
                                new Image.asset('assets/eraser.png', width: 23),
                            tooltip: 'Clear',
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
                                      title: 'Vui lòng ký',
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
                                noiDungButPhe = noiDungButPheController.text;
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
                                    child: Text("Sign",
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
                                      child: Text("Cancel"),
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
          setState(() {
            pages = _pages;
            isReady = true;
          });
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
              title: "the file does not exist, please check the path again!",
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
                        Visibility(
                          visible: countBack != 0,
                          maintainState: true,
                          child: InkWell(
                              onTap: (() => showDialogUndo(context)),
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
                                      "All",
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
                            onTap: () => optionMenu(
                                formKeyList, state.countPage ?? 0, snapshotPDF),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: Image.asset(
                                "assets/next.png",
                                height: 31,
                              ),
                            )),
                        InkWell(
                            onTap: () async {
                              setState(() {
                                isEdit = true;
                              });
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
                              text: 'Are you sure you want to',
                              style: TextStyle(
                                  decoration: TextDecoration.none,
                                  fontSize: 11,
                                  color: Colors.black)),
                          TextSpan(
                              text: ' undo all ',
                              style: TextStyle(
                                  decoration: TextDecoration.none,
                                  fontSize: 11,
                                  color: Colors.red)),
                          TextSpan(
                              text: 'edits?',
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
                            onPressed: () {
                              iniStateFnc(pathFile: pathOrisinal);
                              setState(() => countBack = 0);
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Sure",
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
                                "Cancel",
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
                pathFileLocal: pathPDF, snapshotPDF: snapshotPDF, state: state),
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
                pathFileLocal: pathPDF, snapshotPDF: snapshotPDF, state: state),
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
                pathFileLocal: pathPDF, snapshotPDF: snapshotPDF, state: state),
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
                    state: state);
              } else {
                bloc.warningButPhe(
                    title: "File editing failed, please try again!",
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
                        title: ' Nothing to undo',
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
              "assets/gallery.png",
              height: 25,
            ),
          ),
          InkWell(
            onTap: () =>
                modalBottomSheetTextField(maincontext, snapshotPDF, state),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Image.asset(
                "assets/edit-text.png",
                height: 25,
              ),
            ),
          ),
          InkWell(
            onTap: () => bloc.showSignFrame(true),
            child: Image.asset(
              "assets/signature.png",
              height: 25,
            ),
          ),
          InkWell(
            onTap: () {
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
    bloc.emitTypeWidget(typeEditCase: TypeEditCase.all);
    cancelChonViTriKy();
    setState(() {
      isEdit = false;
    });
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
    offset = Offset(0.0, 0.0);
    dxFrame = 0.0;
    dyFrame = 0.0;
  }

  void iniStateFnc({required String pathFile}) {
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
    });

    //Test
    // noiDungButPheController.text =
    //     'Căn cứ Quyết định số 678/QĐ-BNV ngày 27/8/2019 của Bộ trưởng Bộ Nội vụ ban hành Quy chế phát ngôn và cung cấp thông tin cho báo chí của Bộ Nội vụ;';

    if (widget.isKySo == false) {
      if (widget.isUrl) {
        //Online
        changePDF(pathFile.toString()).then((value) {
          if (value != null) {
            valueStr = value;
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
            valueStr = value;
          } else {
            bloc.pushDownLoadData(true);
          }
        });
      } else {
        //Off line
        loadDocument(pathFile.toString());
        pathPDF = widget.fileKyTen;
        isLoadFileSuccess = true;
      }
    }
  }

  Future<String?> editPDF(
      {required String pathFileLocal,
      required AsyncSnapshot<PDFViewController> snapshotPDF,
      required ViewFileState state}) async {
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
        var nameOld = widget.fileKyTen.split("/").last.replaceAll(".pdf", '');
        var nameFile =
            '${nameOld}_edit_${datetime.day}${datetime.hour}${datetime.second}_${getRandomString(4)}.pdf';
        var linkResult = "$tempPath$nameFile";
        pathFile = linkResult;
        File(pathFile).writeAsBytes(document.saveSync());
        setState(() {
          _isLoading = true;
          countBack = countBack + 1;
        });
        await Future.delayed(Duration(milliseconds: 500));
        loadDocument(linkResult);

        closeEdit();
        //Delete old file
        await File(pathFileLocal).delete();
        //Dispose the document.
        document.dispose();
        return linkResult;
      } else {
        return '';
      }
    } catch (e) {
      print('error edit file: $e');
      bloc.pushDownLoadDraw(false);
      bloc.warningButPhe(
          title: "File editing failed, please try again!",
          loaiThongBao: LoaiThongBao.thatBai);

      setState(() => _isLoading = false);
      return '';
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

  Future<File> fromAsset(String asset, String filename) async {
    Completer<File> completer = Completer();
    try {
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/$filename");
      var data = await rootBundle.load(asset);
      var bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }
    return completer.future;
  }

  Future<File?> createFileOfPdfUrl(String link) async {
    try {
      final filename = link.substring(link.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(link));
      var response = await request.close();
      if (response.statusCode != 404) {
        var bytes = await consolidateHttpClientResponseBytes(response);
        String dir = (await getApplicationDocumentsDirectory()).path;
        File file = File('$dir/$filename');
        await file.writeAsBytes(bytes);
        return file;
      } else {
        bloc.pushErrorData(true);
        return null;
      }
    } catch (e) {
      bloc.pushErrorData(true);
      await Future.delayed(Duration(milliseconds: 50));
      bloc.warningButPhe(
          title: 'File download failed, please check the link again',
          loaiThongBao: LoaiThongBao.thatBai);
      pathPDF = 'error';
      return null;
    }
  }

  Future<String?> changePDF(link) async {
    setState(() => _isLoading = true);
    await createFileOfPdfUrl(link).then((value) {
      if (value != null) {
        pathPDF = value.path;
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
                            "Content",
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
                                          title: 'Please enter content!',
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
                                    noiDungButPhe =
                                        noiDungButPheController.text;
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
                                        child: Text("Continue",
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
                                          child: Text('Cancel'),
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
                  hintText: "Type something!",
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

// ignore: must_be_immutable
class ColorPickerButton extends StatefulWidget {
  PainterController controller;
  bool background;
  double opacity;

  ColorPickerButton(
      {required this.controller,
      required this.background,
      required this.opacity});

  @override
  _ColorPickerButtonState createState() => new _ColorPickerButtonState();
}

class _ColorPickerButtonState extends State<ColorPickerButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(right: 5.0),
        child: InkWell(
          onTap: () => pickColor(
              callbackColor: (color) => setState(() => _color = color)),
          child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.circular(100),
                color: _color,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset('assets/rainbow.png', width: 22),
                  Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                          color: Colors.white),
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0)),
                            color: _color),
                      )),
                ],
              )),
        ));
  }

  void pickColor({required Function callbackColor}) {
    Color pickerColor = _color;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey[50],
              content: SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text("Choose color",
                        style: TextStyle(color: Colors.black)),
                  ),
                  BlockPicker(
                    pickerColor: pickerColor, //default color
                    onColorChanged: (Color color) {
                      setState(() => _color = color);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Text("Gray scale",
                        style: TextStyle(color: Colors.black)),
                  ),
                  Container(
                    width: 350,
                    child: new StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                      return new Slider(
                        value: widget.opacity,
                        onChanged: (double value) => setState(() {
                          widget.opacity = value;
                          _color = _color.withOpacity(value);
                        }),
                        min: 0.0,
                        max: 1.0,
                        activeColor: _color.withOpacity(widget.opacity),
                      );
                    }),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Text("Size", style: TextStyle(color: Colors.black)),
                  ),
                  Row(children: [
                    InkWell(
                      onTap: () => widget.controller.thickness = 1.0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: _color.withOpacity(0.0),
                                  width: 2,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15.0)),
                                color: Colors.white),
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0)),
                                  color: _color),
                            )),
                      ),
                    ),
                    InkWell(
                      onTap: () => widget.controller.thickness = 4.0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: _color.withOpacity(1.0),
                                  width: 2,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15.0)),
                                color: Colors.white),
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0)),
                                  color: _color),
                            )),
                      ),
                    ),
                    InkWell(
                      onTap: () => widget.controller.thickness = 12.0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: _color.withOpacity(0.0),
                                  width: 2,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15.0)),
                                color: Colors.white),
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0)),
                                  color: _color),
                            )),
                      ),
                    ),
                  ])
                ],
              )),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 35,
                          width: 100,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: Offset(0, 3),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Center(
                              child: Text("Cancel"),
                            ),
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: InkWell(
                          onTap: () {
                            callbackColor.call(_color);
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 35,
                            width: 100,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset: Offset(0, 3),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(5),
                              color: _color.withOpacity(1.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Center(
                                child: Text("Confirm",
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          )),
                    ),
                  ],
                )
              ],
            );
          });
        });
  }

  Color get _color => widget.controller.drawColor.withOpacity(widget.opacity);

  IconData get _iconData =>
      widget.background ? Icons.format_color_fill : Icons.brush;

  set _color(Color color) {
    widget.controller.drawColor = color.withOpacity(widget.opacity);
  }
}
