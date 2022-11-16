import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf_reader/sign_vanban_den/bloc/view_file_bloc.dart';
import 'package:pdf_reader/sign_vanban_den/model/mau_chu_ky_so_model.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:pdf_reader/sign_vanban_den/page/view_file_home.dart';
import 'package:pdf_reader/sign_vanban_den/state/view_file_state.dart';
import 'package:pdf_reader/sign_vanban_den/widget/no_data_screen.dart';

class DigitalSignMain {
  final BuildContext mainContext;
  final String fileKyTen;
  final bool isKySo;
  final bool isUseMauChuKy;
  List<MauChuKySoModel>? danhSachChuKy;
  final bool isNightMode;
  final Function(String)? resultData;

  DigitalSignMain._({
    required this.mainContext,
    required this.fileKyTen,
    required this.isKySo,
    required this.isUseMauChuKy,
    required this.isNightMode,
    this.danhSachChuKy,
    this.resultData,
  });
  ////// Init
  var screenWidth = 0.0;
  var screenHeight = 0.0;
  bool isIpad = false;
  File? fileImgMauChuKy;
  MauChuKySoModel? selectedMauChuKy =
      MauChuKySoModel(tenMauChuKy: "Danh sách chữ ký");
  GlobalKey _globalKey = new GlobalKey();

  factory DigitalSignMain.goKySo(
          {required BuildContext mainContext,
          required String fileKyTen,
          required bool isKySo,
          required bool isUseMauChuKy,
          required bool isNightMode,
          List<MauChuKySoModel>? danhSachChuKy,
          final Function(String)? resultData}) =>
      DigitalSignMain._(
        fileKyTen: fileKyTen,
        isKySo: isKySo,
        isUseMauChuKy: isUseMauChuKy,
        danhSachChuKy: danhSachChuKy,
        isNightMode: isNightMode,
        mainContext: mainContext,
        resultData: resultData,
      )..navigateFnc();

  Future<void> navigateFnc() async {
    initDataUI();
    if (danhSachChuKy!.length == 1) {
      String? pathFile = await Navigator.push(
          this.mainContext,
          MaterialPageRoute(
              builder: (context) => ViewFileMain(
                    isKySo: isKySo,
                    isUseMauChuKy: isUseMauChuKy,
                    fileKyTen: fileKyTen,
                    danhSachChuKy: danhSachChuKy,
                    isNightMode: isNightMode,
                    selectedMauChuKy: danhSachChuKy![0],
                  )));
      resultData!.call(pathFile ?? '');
    } else {
      showModalBottomSheet(
          barrierColor: Colors.black.withOpacity(0.7),
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          context: mainContext,
          builder: (BuildContext bc) {
            return MultiBlocProvider(
                providers: [
                  BlocProvider<ViewFileBloc>(
                      create: (context) => ViewFileBloc()
                        ..initContext(context, fileKyTen.toString()))
                ],
                child: BlocBuilder<ViewFileBloc, ViewFileState>(
                    builder: (context, state) {
                  var bloc = BlocProvider.of<ViewFileBloc>(context);
                  if (state.chuKyMacDinh != null) {
                    selectedMauChuKy = state.chuKyMacDinh;
                  }
                  return Container(
                    height: screenHeight,
                    child: Center(
                      child: Container(
                        height: !isUseMauChuKy
                            ? screenHeight * 0.25
                            : screenHeight * 0.55,
                        width: screenWidth - 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            buildHeaderPopUp(mainContext),
                            SizedBox(height: 10),
                            //dropdownMauChuKy(state, bloc),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    isUseMauChuKy
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                top: 5.0,
                                                left: 15.0,
                                                right: 15.0,
                                                bottom: 5.0),
                                            child: RepaintBoundary(
                                                key: _globalKey,
                                                child: state.mauChuKy ??
                                                    NoDataScreen(
                                                        isVisible: true)),
                                          )
                                        : SizedBox(),
                                  ],
                                ),
                              ),
                            ),
                            // Expanded(child: SizedBox()),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: InkWell(
                                    onTap: () async {
                                      try {
                                        if (selectedMauChuKy == null) {
                                          // FlushbarResponse flushbar =
                                          //     new FlushbarResponse();
                                          // flushbar.showFlushbar(
                                          //   ctx: mainContext,
                                          //   loaiThongBao: LoaiThongBao.canhBao,
                                          //   message: "Vui lòng chọn mẫu chữ ký",
                                          //   tgianHienThi: 3,
                                          //   icon: Icon(
                                          //     Icons.info_outlined,
                                          //     size: 28,
                                          //     color: Colors.red,
                                          //   ),
                                          // );
                                          return;
                                        }
                                        if (isUseMauChuKy) {
                                          await _capturePng();
                                        }
                                        String? pathFile = await Navigator.push(
                                            this.mainContext,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ViewFileMain(
                                                        isKySo: isKySo,
                                                        isUseMauChuKy:
                                                            isUseMauChuKy,
                                                        fileKyTen: fileKyTen,
                                                        danhSachChuKy:
                                                            state.danhSachChuKy,
                                                        selectedMauChuKy:
                                                            selectedMauChuKy!,
                                                        isNightMode:
                                                            isNightMode,
                                                        fileImgMauChuKy:
                                                            fileImgMauChuKy)));
                                        Navigator.pop(mainContext, pathFile);
                                        resultData!.call(pathFile ?? '');
                                      } catch (e) {
                                        print(e);
                                      }
                                    },
                                    child: chonmauCKButton()),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }));
          });
    }
  }

  Container chonmauCKButton() {
    return Container(
      height: 40,
      width: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: Colors.red,
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Center(
          child: Text("Chọn mẫu chữ ký", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  // Container dropdownMauChuKy(ViewFileState state, ViewFileBloc bloc) {
  //   return Container(
  //     decoration: BoxDecoration(border: Border.all(color: Colors.black)),
  //     width: screenWidth - 60,
  //     child: Row(
  //       children: [
  //         SizedBox(width: 15.0),
  //         Container(
  //           width: screenWidth - 80,
  //           child: DropdownButton<MauChuKySoModel>(
  //             isExpanded: true,
  //             hint: Text("Chọn mẫu chữ ký"),
  //             menuMaxHeight: 600,
  //             autofocus: true,
  //             value: selectedMauChuKy,
  //             underline: SizedBox(),
  //             items: (state.danhSachChuKy ?? []).map((MauChuKySoModel value) {
  //               var tenChuKy = value.tenMauChuKy ?? '';
  //               var macDinh =
  //                   value.isMauChuKyMacDinh == true ? ' (mặc định)' : '';
  //               return DropdownMenuItem<MauChuKySoModel>(
  //                 value: value,
  //                 child: Container(
  //                   width: screenWidth - 120,
  //                   child: Row(
  //                     children: [
  //                       Expanded(
  //                         child: Text(tenChuKy + macDinh,
  //                             maxLines: 3,
  //                             overflow: TextOverflow.ellipsis,
  //                             style: TextStyle(
  //                                 color: Colors.black,
  //                                 fontSize: 15,
  //                                 fontWeight: FontWeight.w700)),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               );
  //             }).toList(),
  //             onChanged: (val) {
  //               if (val != null) {
  //                 bloc.setChuKyMacDinh(chuKyMacDinh: val);
  //               }
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Padding buildButPheItem({required MauChuKySoModel chuKyModel}) {
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: Card(
        elevation: 2.0,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 15.0, bottom: 5.0),
            child: Padding(
              padding: const EdgeInsets.only(right: 5.0, bottom: 5, top: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 4.0),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Icon(Icons.person_outline_rounded,
                            color: Colors.blue[400]),
                      ),
                      Text(chuKyModel.hoTenNguoiKy ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.black)),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Icon(Icons.email_outlined,
                            size: 22, color: Colors.blue[400]),
                      ),
                      Text(chuKyModel.emailNguoiKy ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.black)),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Icon(Icons.apartment, color: Colors.blue[400]),
                      ),
                      Text(
                          chuKyModel.tenPhongBanNguoiKy != null
                              ? chuKyModel.tenPhongBanNguoiKy!.toLowerCase()
                              : '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.black)),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Icon(Icons.phone, color: Colors.blue[400]),
                      ),
                      Text(chuKyModel.sdtKySo ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void initDataUI() {
    isIpad = isIpadCheck();
    screenWidth = MediaQuery.of(mainContext).size.width;
    screenHeight = MediaQuery.of(mainContext).size.height;
    if (danhSachChuKy == null) {
      danhSachChuKy = [];
    }
  }

  bool isIpadCheck() {
    var shortestSide = MediaQuery.of(mainContext).size.shortestSide;
    return shortestSide > 600;
  }

  Future<File?> _capturePng() async {
    try {
      final dateFolder = DateTime.now().day;
      Random random = Random();
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
      fileImgMauChuKy = fileMauChuKy;
      // bloc.emitFileWidget(fileImageWidget: fileMauChuKy);
      return fileMauChuKy;
    } catch (e) {
      print('_capturePng' + "$e");
      return null;
    }
  }

  Container buildHeaderPopUp(context) {
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
}
