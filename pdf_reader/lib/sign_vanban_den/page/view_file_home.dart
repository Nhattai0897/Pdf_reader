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
import 'package:pdf_reader/sign_vanban_den/model/loai_hien_thi_model.dart';
import 'package:pdf_reader/sign_vanban_den/model/loai_ky_so_model.dart';
import 'package:pdf_reader/sign_vanban_den/model/mau_chu_ky_so_model.dart';
import 'package:pdf_reader/sign_vanban_den/state/view_file_state.dart';
import 'package:pdf_reader/sign_vanban_den/utils/util.dart';
import 'package:pdf_reader/sign_vanban_den/widget/frame_custom_support.dart';
import 'package:pdf_reader/sign_vanban_den/widget/modal_bottom_sheet_select_file.dart';
import 'package:pdf_reader/sign_vanban_den/widget/no_data_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_reader/sign_vanban_den/widget/showFlushbar.dart';
import 'package:pdf_reader/utils/bloc_builder_status.dart';
import 'dart:ui' as ui;
import 'package:showcaseview/showcaseview.dart';

class ViewFileMain extends StatefulWidget {
  String fileKyTen;

  /// Là tên file dùng ký số
  bool isKySo;

  /// Dùng để phân biệt ký số hay xem file, nếu xem file thì (load file Alfresco)
  bool isUseMauChuKy;

  /// Dùng để phân biệt ký cá nhân hay ký số bút phê
  List<MauChuKySoModel>? danhSachChuKy;

  /// Danh sách mẫu chữ ký đã cấu hình theo loại ký số
  MauChuKySoModel? selectedMauChuKy;

  /// Model chữ ký đã chọn dùng cho ký số
  bool? openSigned;

  /// Dùng để mở file đã ký(load file local)
  File? fileImgMauChuKy;

  /// File img đã được capture từ widget trong popup chọn mẫu chữ ký

  bool isNightMode;

  /// Chế độ buổi tối

  ViewFileMain(
      {Key? key,
      required this.fileKyTen,
      required this.isKySo,
      required this.isUseMauChuKy,
      required this.isNightMode,
      this.danhSachChuKy,
      this.selectedMauChuKy,
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
          danhSachChuKy: widget.danhSachChuKy,
          isUseMauChuKy: widget.isUseMauChuKy,
          isNightMode: widget.isNightMode,
          selectedMauChuKy: widget.selectedMauChuKy,
          openSigned: widget.openSigned,
          fileImgMauChuKy: widget.fileImgMauChuKy),
    );
  }
}

class ViewFileHome extends StatefulWidget {
  String fileKyTen;
  bool isKySo;
  bool isUseMauChuKy;
  List<MauChuKySoModel>? danhSachChuKy;
  MauChuKySoModel? selectedMauChuKy;
  bool? openSigned;
  File? fileImgMauChuKy;
  bool isNightMode;

  ViewFileHome(
      {Key? key,
      required this.fileKyTen,
      required this.isKySo,
      required this.isUseMauChuKy,
      required this.isNightMode,
      this.danhSachChuKy,
      this.selectedMauChuKy,
      this.openSigned,
      this.fileImgMauChuKy})
      : super(key: key);

  @override
  _ViewFileHomeState createState() => _ViewFileHomeState();
}

class _ViewFileHomeState extends State<ViewFileHome>
    with TickerProviderStateMixin {
  GlobalKey _globalKey = new GlobalKey();
  GlobalKey _globalKeyTextField = new GlobalKey();
  GlobalKey _globalKeySign = new GlobalKey();
  final GlobalKey _containerFakePDFViewKey = GlobalKey();
  late String valueStr;
  late ViewFileBloc bloc;
  late Random random;
  double ratioParam = 0.0;
  bool _isLoading = true;
  bool isReady = false;
  bool isThemButPhe = false;
  bool? isShow;
  String pathFile = '';
  String pathPDF = "";
  String? _linkResult;
  String soTrang = '';
  String viTri = '';
  String noiDungButPhe = '';
  bool isViTriMacDinh = false;
  Offset offset = Offset.zero;
  double dxFrame = 0.0;
  double dyFrame = 0.0;
  double widthFrame = 0.0;
  double heightFrame = 0.0;
  // double topPosition = 0.0;
  // double leftPosition = 0.0;
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
  int pages = 0;
  int countBack = 0;
  int pageIndex = 0;
  int loaiHienThi = 0;
  double finalPageHeight = 0.0;
  double finalPageWidth = 0.0;
  double firstPageHeight = 0.0;
  double firstPageWidth = 0.0;
  List<LoaiHienThiList> loaiHienThiList = [];
  List<LoaiKySoModel> loaiKySoList = [];
  MauChuKySoModel selectedMauChuKy =
      MauChuKySoModel(tenMauChuKy: "Danh sách chữ ký");
  BuildContext? myContext;
  TextEditingController noiDungButPheController = TextEditingController();
  bool isUseSignTemp = false;
  bool isLoadFileSuccess = false;
  bool isNightMode = false;
  bool isEdit = false;
  PainterController _controllerSign = _newControllerSign();
  static PainterController _newControllerSign() {
    PainterController controller = new PainterController();
    controller.thickness = 4.0;
    controller.drawColor = Colors.black.withOpacity(0.7);
    controller.backgroundColor = Colors.blue.withOpacity(0.1);
    return controller;
  }

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
    iniStateFnc();
  }

  @override
  void dispose() {
    super.dispose();
    bloc.closeStream();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext maincontext) {
    Completer<PDFViewController> _controller = Completer<PDFViewController>();
    initDataUI(maincontext);
    return MaterialApp(
        home: Scaffold(
            resizeToAvoidBottomInset: false,
            body: buildContentKySo(_controller, maincontext)));
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
        screenWidth / 5.0; // dùng cho giới hạn kéo to hay thu nhỏ widget chữ ký
    maxWidthSize =
        screenWidth / 1.8; // dùng cho giới hạn kéo to hay thu nhỏ widget chữ ký
    finalPageWidth = screenWidth;
    finalPageHeight = screenWidth;
    firstPageWidth = screenWidth;
    firstPageHeight = screenHeight;
  }

  Widget buildContentKySo(
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
                          onPressed: () =>
                              Navigator.pop(maincontext, _linkResult),
                          icon:
                              Icon(Icons.arrow_back_ios, color: Colors.white)),
                      Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Container(
                            child: Text(
                          'Page ${state.currentPage! + 1}${state.countPage != 0 ? ' / ' + state.countPage.toString() : ''}',
                          style: TextStyle(color: Colors.white),
                        )),
                      ),
                      const Spacer(),
                      const SizedBox(width: 5.0),
                      Visibility(
                          child: buildHeaderPDF(_controller, state),
                          visible: widget.isKySo,
                          maintainState: true),
                      const SizedBox(width: 5.0)
                    ],
                  ))),
          Expanded(
              child: _isLoading
                  ? StreamBuilder<bool>(
                      stream: bloc.streamDownload,
                      builder: (context, snapshot) {
                        var isShowError = snapshot.data ?? false;
                        return Center(
                            child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            isShowError
                                ? SizedBox()
                                : CircularProgressIndicator(),
                            SizedBox(width: 15),
                            Text(isShowError
                                ? "Unable to load document!"
                                : "Document loading...")
                          ],
                        ));
                      })
                  : FutureBuilder<PDFViewController>(
                      future: _controller.future,
                      builder:
                          (context, AsyncSnapshot<PDFViewController> snapshot) {
                        if (snapshot.hasData && state.countPage == 0)
                          getCountPage(snapshot);
                        double width = 0.0;
                        double height = 0.0;
                        networkCall(snapshot, width, height, maincontext);
                        return Stack(children: [
                          buildPdfView(_controller, snapshot),
                          buildDragParent(
                              networkCall(snapshot, width, height, maincontext),
                              state.isDraw),
                          buildSignParent(
                              context, state.isShowSign, snapshot, state)
                        ]);
                      },
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

                /// Container dùng để chặn scroll 2 đầu bên ngoài frame limit
                height: screenHeight,
                child: Center(
                  child: Container(
                    color: Colors.transparent,
                    key: _containerFakePDFViewKey,
                    width: builder.data?.elementAt(0) ?? 0.0,
                    height: builder.data?.elementAt(1) ?? 0.0,
                    child: isDraw ?? false
                        ? new Painter(_controllerDraw)
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
                              // padding: const EdgeInsets.only(top: 2.0, bottom: 5.0, left: 5.0, right: 5.0),
                              padding: const EdgeInsets.only(
                                  top: 0.0, bottom: 0.0, left: 0.0, right: 0.0),
                              child: pathFile.isNotEmpty
                                  ? Image.file(
                                      File(pathFile),
                                      //state.fileImageWidget!,
                                      fit: BoxFit.fill,
                                    )
                                  : SizedBox(),
                            )),
                  ),
                ),
              ),
            );
          }),
    );
  }

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
                width: screenWidth - 30,
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
                      padding: const EdgeInsets.only(top: 8.30, bottom: 5.0),
                      child: Text("Chữ ký"),
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
                                width: 150,
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
                                  width: 150,
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
        backgroundColor: bgcolors.WHITE,
        //widget.isNightMode ? bgcolors.BLACK : bgcolors.WHITE,
        nightMode: widget.isNightMode,
        onRender: (_pages) async {
          setState(() {
            pages = _pages;
            isReady = true;
          });
          if (snapshotPDF.hasData) {
            await snapshotPDF.data!.setPageWithAnimation(_pages);
            await Future.delayed(Duration(milliseconds: 50));
            await snapshotPDF.data!.setPageWithAnimation(0);
          }
        },
        onViewCreated: (PDFViewController pdfViewController) =>
            _controller.complete(pdfViewController),
        onError: (error) => setState(() => isReady = false),
        onPageChanged: (int page, int total) {
          pageIndex = page;
          bloc.setCountCurrentPage(currentPage: page);
        });
  }

  /// Widget này dùng khi chỉ có 1 mẫu chữ ký(cá nhân) navigate qua trực tiếp k show lên trong popup nên k cap widget dc, cho nên đem qua đây show lên r cap widget và show
  // Stack buildMCKTemp(ViewFileState state) {
  //   return Stack(
  //     children: [
  //       Container(
  //         child: Column(
  //           children: [
  //             Padding(
  //               padding: const EdgeInsets.only(
  //                   top: 5.0, left: 15.0, right: 15.0, bottom: 5.0),
  //               child: RepaintBoundary(
  //                   key: _globalKey,
  //                   child: state.mauChuKy ?? NoDataScreen(isVisible: true)),
  //             ),
  //             Spacer()
  //           ],
  //         ),
  //       ),
  //       Container(
  //         width: double.infinity,
  //         height: double.infinity,
  //         color: Colors.black,
  //       )
  //     ],
  //   );
  // }

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
                            child: buildHeaderCase(
                                state.typeEditCase, maincontext, snapshotPDF)),
                      ))
                  : Row(
                      children: [
                        InkWell(
                            onTap: () {
                              setState(() {
                                isEdit = true;
                              });
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

  Widget buildHeaderCase(TypeEditCase? editCase, maincontext, snapshotPDF) {
    Widget widget = SizedBox();
    switch (editCase) {
      case TypeEditCase.image:
        widget = Row(children: [
          InkWell(
            onTap: () {
              bloc.emitTypeWidget(typeEditCase: TypeEditCase.all);
              setState(() {
                isEdit = false;
              });
              bloc.pushIndexCalculator(false);
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
            onTap: () {
              bloc.emitTypeWidget(typeEditCase: TypeEditCase.all);
              setState(() {
                isEdit = false;
              });
              bloc.pushIndexCalculator(false);
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
            onTap: () {
              bloc.emitTypeWidget(typeEditCase: TypeEditCase.all);
              setState(() {
                isEdit = false;
              });
              bloc.pushIndexCalculator(false);
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
          Padding(
            padding: const EdgeInsets.only(left: 5),
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
                  // bloc.emitTypeWidget(typeEditCase: TypeEditCase.image);
                }
              }, fAlbum: () async {
                await showMediaSelection(
                    index: 0,
                    context: maincontext,
                    loaiChucNangDinhKem: MediaLoaiChucNangDinhKem.Album);
                if (pathFile.isNotEmpty) {
                  bloc.pushIndexCalculator(true);
                  //bloc.emitTypeWidget(typeEditCase: TypeEditCase.image);
                }
              });
            },
            child: Image.asset(
              "assets/gallery.png",
              height: 25,
            ),
          ),
          InkWell(
            onTap: () => modalBottomSheetTextField(maincontext, snapshotPDF),
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
            onTap: () {
              setState(() {
                isEdit = false;
              });
              bloc.pushIndexCalculator(false);
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
    }
    return widget;
  }

  Future<void> showMediaSelection({
    required BuildContext context,
    required int index,
    MediaLoaiChucNangDinhKem? loaiChucNangDinhKem,
  }) async {
    Uint8List? imageUint8List;
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
        //  print('pathFile 123: $pathFile');
        break;
      case MediaLoaiChucNangDinhKem.File:
        // File file = await FilePicker.getFile();
        // pathFile = file.path;
        FilePickerResult? file = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'xlsx', 'docx'],
          allowMultiple: false,
        );
        pathFile = file!.paths.first!;
        Navigator.pop(context);
        // print('pathFile 123: $pathFile');
        break;
      case MediaLoaiChucNangDinhKem.Video:
        // TODO: Handle this case.
        break;
    }
  }

  void cancelChonViTriKy() {
    offset = Offset(0.0, 0.0);
    dxFrame = 0.0;
    dyFrame = 0.0;
  }

  // FutureBuilder buildThemButPhe(
  //     bool isShowError,
  //     AsyncSnapshot<PDFViewController> snapshotPDF,
  //     ViewFileState state,
  //     Completer<PDFViewController> _controller) {
  //   return FutureBuilder<PDFViewController>(
  //       future: _controller.future,
  //       builder: (maincontext, AsyncSnapshot<PDFViewController> snapshotPDF) {
  //         return RaisedButton(
  //           color: !isShowError ? Colors.grey[200] : Colors.red,
  //           shape:
  //               RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
  //           onPressed: () =>
  //               modalBottomSheetTextField(maincontext, snapshotPDF),
  //           child: Text("Thêm bút phê"),
  //         );
  //       });
  // }

  // Future<List<int>> readData(String name) async {
  //   final ByteData data = await rootBundle.load(ConfigImages.fontLink!);
  //   return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  // }

  void iniStateFnc() {
    // loaiHienThiList = LoaiHienThiList.loaiHienThiList(context);
    // loaiKySoList = LoaiKySoModel.listLoaiChuKyModel(context);
    random = new Random();
    bloc = BlocProvider.of<ViewFileBloc>(context);
    // bloc.setUpListLoaiHienThi(loaiHienThiList);
    //  bloc.initListCKTemp(listTypeNew: loaiKySoList);
    bloc.initContext(context, widget.fileKyTen.toString());
    bloc.initLoading(context);
    if (widget.isUseMauChuKy == true && widget.fileImgMauChuKy != null) {
      bloc.emitFileWidget(fileImageWidget: widget.fileImgMauChuKy!);
    }
    //Test
    // noiDungButPheController.text =
    //   'Căn cứ Quyết định số 678/QĐ-BNV ngày 27/8/2019 của Bộ trưởng Bộ Nội vụ ban hành Quy chế phát ngôn và cung cấp thông tin cho báo chí của Bộ Nội vụ;';
    bloc.getChuKyImage();
    if (widget.isKySo == false) {
      // if (widget.fileKyTen.contains('www')) {
      //   //Online
      //   changePDF(widget.fileKyTen.toString());
      // } else {
      //   //Off line
      //   loadDocument(widget.fileKyTen.toString());
      // }
    } else {
      changePDF(widget.fileKyTen.toString()).then((value) {
        if (value != null) {
          valueStr = value;
        } else {
          bloc.pushDownLoadData(true);
        }
      });
    }
  }

  // Future<bool> editPDF(
  //     {required String pathFileLocal,
  //     required String noiDung,
  //     required AsyncSnapshot<PDFViewController> snapshotPDF,
  //     required ViewFileState state}) async {
  //   try {
  //     //Load the existing PDF document.
  //     final PdfDocument document =
  //         PdfDocument(inputBytes: File(pathFileLocal).readAsBytesSync());
  //     //Get the existing PDF page.
  //     final PdfPage page = document.pages[pageIndex];
  //     // final List<int> fontData = await _readData('Sarabun-Regular.ttf');
  //     // final File? imgTextField = await _capturePngTextField();
  //     double dx = 0.0;
  //     double dy = 0.0;
  //     double widthFrame = 0.0;
  //     double heightFrame = 0.0;
  //     if (snapshotPDF.hasData) {
  //       final dataPDF = snapshotPDF.data!;
  //       final currentPage = await dataPDF.getCurrentPage() ?? 0;
  //       final widthPage = await dataPDF.getPageWidth(currentPage) ?? 0.0;
  //       final heightPage = await dataPDF.getPageHeight(currentPage) ?? 0.0;

  //       final widthPDFCanvas = page.size.width;
  //       final heightPDFCanvas = page.size.height;
  //       final widthPDFForScreen = MediaQuery.of(context).size.width;
  //       final heightPDFForScreen = (widthPDFForScreen * heightPage) / widthPage;
  //       final ratioWidthCanvas = widthPDFCanvas / widthPDFForScreen;
  //       final ratioHeightCanvas = heightPDFCanvas / heightPDFForScreen;
  //       widthFrame = this.widthFrame * ratioWidthCanvas;
  //       heightFrame = this.heightFrame * ratioHeightCanvas;
  //       dx = dxFrame * ratioWidthCanvas;
  //       dy = dyFrame * ratioHeightCanvas;
  //       // final containerFakePDFViewKeyContext =
  //       //     _containerFakePDFViewKey.currentContext;
  //       // if (containerFakePDFViewKeyContext != null) {
  //       //   final box =
  //       //       containerFakePDFViewKeyContext.findRenderObject() as RenderBox;
  //       //   final pos = box.localToGlobal(Offset.zero);
  //       //   print("pos.dy => ${pos.dy}");
  //       // }
  //     }
  //     page.graphics.drawImage(
  //         PdfBitmap(state.fileImageWidget!.readAsBytesSync()),
  //         Rect.fromLTWH(dx, dy, widthFrame, heightFrame));
  //     // page.graphics.drawString(noiDung, PdfTrueTypeFont(fontData, 11.0),
  //     //     brush: PdfSolidBrush(PdfColor(0, 0, 0)),
  //     //     bounds: Rect.fromLTWH(dx, dy, widthFrame, heightFrame));

  //     //Save the document.
  //     String? tempPath = await FileLocalResponse().getPathLocal(
  //       ePathType: EPathType.Storage,
  //       configPathStr: 'vanban',
  //     );
  //     //var tenFile = widget.fileKyTen.replaceAll('.pdf', '');
  //     //String fileName = '$tenFile.pdf';
  //     var linkResult = "$tempPath${widget.fileKyTen}";
  //     pathFile = linkResult;
  //     File(pathFile).writeAsBytes(document.save());
  //     // setState(() => _isLoading = true);
  //     // await Future.delayed(Duration(seconds: 1));
  //     // loadDocument(linkResult);
  //     // await Future.delayed(Duration(seconds: 1));
  //     await snapshotPDF.data!.setPage(pageIndex);
  //     //Dispose the document.
  //     document.dispose();
  //     return true;
  //   } catch (e) {
  //     print('error edit file: $e');
  //     return false;
  //   }
  // }

  Future<void> getCountPage(AsyncSnapshot<PDFViewController> snapshot) async {
    final int pageCount = await snapshot.data!.getPageCount() ?? 0;
    bloc.setCountPage(countPage: pageCount);
  }

  Widget buildChonMauButton(maincontext, snapshotPDF, ViewFileState state) {
    return FlatButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      color: Colors.white,
      onPressed: () async {
        await snapshotPDF.data!.resetZoom(1);
        await getSizeFirstPage(snapshotPDF, pageIndex, state);
        // if (state.fileImageWidget == null) {
        // await bloc.getMauChuKyConvertFile(
        //     mauChuKyDefault: widget.selectedMauChuKy!,
        //     globalKey: _globalKey,
        //     isUsedSignTemp: isUseSignTemp);
        // }
        // bloc.pushShowData(true);
        bloc.checkFirstTime();
      },
      child: Text("Chọn vị trí chữ ký"),
      //"Chọn mẫu"
    );
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

  Widget buildFirstFrameCH(String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
      child: Container(
          width: double.infinity,
          height: screenWidth * 0.3,
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 0)),
          child: Image.network('url fake' + imageUrl, fit: BoxFit.fill)),
    );
  }

  Widget buildListLoaiKySo({required List<LoaiKySoModel> loaiKySoList}) {
    return Container(
      height: 40,
      child: ListView.builder(
          padding: EdgeInsets.only(top: 0, left: 10),
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: loaiKySoList.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {},
              // blocBT.pushIndexTypeCK(index),
              child: Container(
                width: screenWidth / 3.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  child: Row(
                    children: [
                      _buildCheckIcon(loaiKySoList[index].isChoose),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Text(loaiKySoList[index].title.toString()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  Widget _buildCheckIcon(bool? isCheck) {
    return isCheck!
        ? Container(
            width: screenWidth * 0.05,
            height: screenWidth * 0.05,
            decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.all(Radius.circular(50))),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                width: screenWidth * 0.03,
                height: screenWidth * 0.03,
                decoration: BoxDecoration(
                    color: Colors.red,
                    border: Border.all(width: 2.0, color: Colors.white),
                    borderRadius: BorderRadius.all(Radius.circular(50))),
              ),
            ))
        : Container(
            width: screenWidth * 0.05,
            height: screenWidth * 0.05,
            decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(width: 2.0, color: Colors.red),
                borderRadius: BorderRadius.all(Radius.circular(50))),
          );
  }

  Future<File?> createFileOfPdfUrl(String link) async {
    try {
      final url = link;
      final filename = link.substring(link.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      String dir = (await getApplicationDocumentsDirectory()).path;
      File file = File('$dir/$filename');
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      bloc.pushErrorData(true);
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

  void settingModalBottomSheetV2(
      context, AsyncSnapshot<PDFViewController> snapshotPDF, int pageIndex) {
    Future.delayed(Duration(milliseconds: 500)).then((value) {});
    showModalBottomSheet(
        barrierColor: Colors.black.withOpacity(0.7),
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext bc) {
          return ShowCaseWidget(
            onFinish: () => bloc.onFinish(),
            builder: Builder(builder: (context) {
              myContext = context;
              return Container(
                height: screenHeight,
                child: Center(
                  child: BlocBuilder<ViewFileBloc, ViewFileState>(
                      builder: (contextMain, state) {
                    return Container(
                      height: screenHeight * 0.55,
                      width: screenWidth - 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          buildHeaderPopUp(snapshotPDF, pageIndex, context),
                          SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black)),
                            width: screenWidth - 60,
                            child: Row(
                              children: [
                                SizedBox(width: 15.0),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 5.0, left: 15.0, right: 15.0, bottom: 5.0),
                            child: RepaintBoundary(
                                key: _globalKey,
                                child: state.mauChuKy ??
                                    NoDataScreen(isVisible: true)),
                          ),
                          Visibility(
                            visible: false,
                            child: Row(
                              children: [
                                Checkbox(
                                  activeColor: Colors.red,
                                  value: isViTriMacDinh == true
                                      ? state.isUseDefaultConfig
                                      : isViTriMacDinh,
                                  onChanged: (isUse) {
                                    if (isViTriMacDinh) {
                                      bloc.suDungViTriCauHinhAct(
                                          isUse: isUse ?? false);
                                    }
                                  },
                                ),
                                Expanded(
                                    child: Text(
                                        isViTriMacDinh
                                            ? "Vị trí chữ ký đã cấu hình (${viTri != '' ? 'vị trí: $viTri - ' : ''}$soTrang)"
                                            : "Vị trí chữ ký đã cấu hình",
                                        style: TextStyle(
                                            color: isViTriMacDinh
                                                ? Colors.black
                                                : Colors.grey,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700)))
                              ],
                            ),
                          ),
                          Expanded(child: SizedBox()),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: InkWell(
                                  onTap: () async {
                                    try {
                                      await getSizeFirstPage(
                                          snapshotPDF, pageIndex, state);
                                      await _capturePng();
                                      //bloc.pushShowData(true);
                                      bloc.checkFirstTime();
                                      Navigator.of(myContext!).pop();
                                    } catch (e) {
                                      print(e);
                                    }
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 150,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.red,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Center(
                                        child: Text("Thực hiện ký số",
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                    ),
                                  )),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              );
            }),
          );
        });
  }

  void modalBottomSheetTextField(
      contextBT, AsyncSnapshot<PDFViewController> snapshotPDF) {
    showModalBottomSheet(
        barrierColor: Colors.black.withOpacity(0.3),
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: contextBT,
        builder: (BuildContext bc) {
          return InkWell(
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: BlocBuilder<ViewFileBloc, ViewFileState>(
                builder: (contextBT, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight / 3.0),
                    child: Container(
                      width: screenWidth - 30,
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
                            padding:
                                const EdgeInsets.only(top: 8.30, bottom: 5.0),
                            child: Text("Nội dung bút phê"),
                          ),
                          _buildTextField(contextBT),
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: 10.0, top: 5.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                    onTap: () async {
                                      if (noiDungButPheController
                                          .text.isEmpty) {
                                        bloc.warningButPhe(
                                            title:
                                                'Vui lòng nhập nội dung bút phê',
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
                                      width: 150,
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
                                          child: Text("Thực hiện bút phê",
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ),
                                      ),
                                    )),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: InkWell(
                                      onTap: () {
                                        noiDungButPheController.clear();
                                        Navigator.pop(contextBT);
                                      },
                                      child: Container(
                                        height: 40,
                                        width: 150,
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 1,
                                              blurRadius: 2,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(10),
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
              );
            }),
          );
        });
  }

  Widget buildSignFrame(context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      margin: EdgeInsets.all(5),
      child: RepaintBoundary(
          key: _globalKeySign,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            height: screenHeight / 3,
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
      margin: EdgeInsets.all(5),
      child: RepaintBoundary(
          key: _globalKeyTextField,
          child: TextField(
            autofocus: true,
            onChanged: (value) {
              if (value.length > 220) bloc.showLimitLength();
            },
            controller: noiDungButPheController,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Nhập nội dung bút phê",
              fillColor: Colors.transparent,
              filled: true,
            ),
            maxLines: 10,
            minLines: 1,
          )),
    );
  }

  Future<File?> _capturePng() async {
    try {
      final dateFolder = DateTime.now().day;
      late int tailNumber;
      tailNumber = random.nextInt(1000);
      final RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject()! as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      File fileMauChuKy = await File(
              '${tempDir.path}/mauChuKy_image_$dateFolder@$tailNumber.png')
          .create();
      fileMauChuKy.writeAsBytesSync(pngBytes);
      bloc.emitFileWidget(fileImageWidget: fileMauChuKy);
      return fileMauChuKy;
    } catch (e) {
      print('_capturePng' + "$e");
      return null;
    }
  }

  Future<File?> _capturePngTextField() async {
    try {
      late int tailNumber;
      final dateFolder = DateTime.now().day;
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
      final dateFolder = DateTime.now().day;
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

  List<DropdownMenuItem<MauChuKySoModel>> buildDropdownMenuItems(
      List<MauChuKySoModel>? list) {
    List<DropdownMenuItem<MauChuKySoModel>> items = [];
    for (MauChuKySoModel company in list!) {
      items.add(
        DropdownMenuItem(
          value: company,
          child: Text(company.tenMauChuKy!),
        ),
      );
    }
    return items;
  }

  Container buildHeaderPopUp(
      AsyncSnapshot<PDFViewController> snapshotPDF, int pageIndex, context) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          topLeft: Radius.circular(10),
        ),
      ),
      child: BlocBuilder<ViewFileBloc, ViewFileState>(
          builder: (contextMain, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              Text("Danh sách mẫu chữ ký",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
              Spacer(),
              InkWell(
                onTap: () {
                  // getSizeFirstPage(snapshotPDF, pageIndex, state);
                  // bloc.pushShowData(true);
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: Colors.white,
                ),
              )
            ],
          ),
        );
      }),
    );
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
                      onTap: () => widget.controller.thickness = 2.0,
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
