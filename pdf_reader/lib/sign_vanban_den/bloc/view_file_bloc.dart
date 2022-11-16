import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf_reader/sign_vanban_den/api/view_file_api.dart';
import 'package:pdf_reader/sign_vanban_den/model/loai_hien_thi_model.dart';
import 'package:pdf_reader/sign_vanban_den/model/loai_ky_so_model.dart';
import 'package:pdf_reader/sign_vanban_den/model/mau_chu_ky_so_model.dart';
import 'package:pdf_reader/sign_vanban_den/state/view_file_state.dart';
import 'package:pdf_reader/sign_vanban_den/utils/bloc_builder_status.dart';
import 'package:pdf_reader/sign_vanban_den/widget/showFlushbar.dart';
import 'package:pdf_reader/utils/bloc_builder_status.dart';
import 'package:pdf_reader/utils/networks.dart';

class ViewFileBloc extends Cubit<ViewFileState> {
  late ViewFileApi? viewFileApi;
  late FileLocalResponse network;
  late BuildContext mainContext;
  late Widget mauChuKyWidget;
  File? fileImageWidget;
  MauChuKySoModel mauChuKyDefault = MauChuKySoModel();
  String? fileName;
  String? fullPathFile;
  bool? isFirst;
  ViewFileBloc({this.viewFileApi})
      : super(ViewFileState(
            status: BlocBuilderStatusCase.initial,
            statusLoadSign: BlocBuilderStatusCase.initial,
            danhSachChuKy: [],
            isUseDefaultConfig: true,
            countPage: 0,
            currentPage: 0,
            isFirst: true,
            isShowWarning: false)) {
    viewFileApi = new ViewFileApi();
    // network = new FileLocalResponse();
  }
  List<LoaiHienThiList> loaiHienThiList = [];
  List<String> loaiCKs = [];
  List<LoaiKySoModel> listTypeCK = [];
  List<MauChuKySoModel>? cauHinhLst = [];

  void initContext(BuildContext context, String tenTepDinhKem) {
    fullPathFile = tenTepDinhKem;
    this.mainContext = context;
    checkFirstTime();
  }

  void checkFirstTime() {
    isFirst = false;
    //AppSettings.getValue(KeyAppSetting.isFirst) ?? true;
  }

  void onFinish() {
    emit(state.copyWith(isFirst: false));
  }

  void initLoading(BuildContext ctx) {
    // _loadingDialog = LoadingDialog(
    //   ctx,
    //   showLogs: true,
    //   isDismissible: false,
    // );
    // _loadingDialog.style(message: "Đang thực hiện ký số");
    // flushbar = FlushbarResponse();
  }

  void setUpListLoaiHienThi(List<LoaiHienThiList>? loaiHienThiListNew) {
    loaiHienThiList = loaiHienThiListNew ?? [];
  }

  void initListCKTemp({List<LoaiKySoModel>? listTypeNew}) {
    listTypeCK = listTypeNew!;
  }

  Future<void> goCauHinh() async {
    // var data = await vanbanMain.ModuleVanBan.goCauHinhKySo!(mainContext);
    // if (data) {
    //   getChuKyImage();
    // }
  }

  Future<MauChuKySoModel?> goCauHinhThamQuyen({required int idMauChuKy}) async {
    // final loadingDialog = LoadingDialog(
    //   this.mainContext,
    //   showLogs: true,
    //   isDismissible: false,
    // );
    // loadingDialog.style(message: "Đang kiểm tra mẫu chữ ký");
    try {
      //loadingDialog.show();
      // emitWarning(isShow: false);
      // var data = await vanbanMain.ModuleVanBan.goChinhSuaKySo!(
      //     mainContext, idMauChuKy);

      // if (data != null && data == 'OKOKOK') {
      //   var mauCKUpdated =
      //       await getMauChuKyThamQuyen(idMauChuKySelected: idMauChuKy);
      //   if (mauCKUpdated != null) {
      //     emit(state.copyWith(status: BlocBuilderStatusCase.loading));
      //     pushDownLoadData(false);
      //     return mauCKUpdated;
      //   } else {
      //     pushDownLoadData(true);
      //   }
      // } else {
      //   emitWarning(isShow: true);
      // }
      //await loadingDialog.hide();
    } catch (e) {
      // await loadingDialog.hide();
      print(e);
      return null;
    }
  }

  Future<MauChuKySoModel?> getMauChuKyThamQuyen(
      {required int idMauChuKySelected}) async {
    // try {
    //   cauHinhLst =
    //       await viewFileApi!.getMauChuKySoByUserID(isUseMauChuKy: true);
    //   if (cauHinhLst != null) {
    //     var updatedMauCK = cauHinhLst!
    //         .firstWhere((element) => element.idMauChuKy == idMauChuKySelected);
    //     return updatedMauCK;
    //   }
    // } catch (e) {
    //   print("Error - Get Chuyen Van Ban - $e");
    //   return null;
    // }
  }

  // void showDialogDelete(contextGobal) {
  //   showDialog(
  //       context: contextGobal,
  //       builder: (_) => new AlertDialog(
  //             title: Text(
  //               'Ông/bà có muốn xóa',
  //               style: CoreTextStyle.regularTextFont(
  //                   fontSize: CoreFontSize.defaultAddTwo),
  //             ),
  //             actions: [
  //               FlatButton(
  //                 child: Text(
  //                   'Hủy',
  //                   style: CoreTextStyle.regularTextFont(
  //                       fontSize: CoreFontSize.defaultSize),
  //                 ),
  //                 onPressed: () => Navigator.of(this.mainContext).pop(),
  //               ),
  //               FlatButton(
  //                 child: Text(
  //                   'Đồng ý',
  //                   style: CoreTextStyle.regularTextFont(
  //                       fontSize: CoreFontSize.defaultSize,
  //                       color: CoreColors.appbar_color),
  //                 ),
  //                 onPressed: () {},
  //               ),
  //             ],
  //           ));
  // }

  // Future<void> getDanhSachChuKy(
  //     {required List<MauChuKySoModel> danhSachChuKy,
  //     required bool isUseMauChuKy}) async {
  //   var danhSachResult;
  //   if (danhSachChuKy.length >= 1) {
  //     danhSachResult = danhSachChuKy;
  //   } else {
  //     danhSachResult = await viewFileApi!
  //         .getMauChuKySoByUserID(isUseMauChuKy: isUseMauChuKy);
  //   }

  //   if (danhSachResult != null) {
  //     for (var item in danhSachResult) {
  //       if (item.isMauChuKyMacDinh == true) {
  //         mauChuKyDefault = item;
  //         break;
  //       }
  //     }
  //     ////// nếu k có chữ ký mặc định /////
  //     if (mauChuKyDefault.idMauChuKy == null) {
  //       mauChuKyDefault = danhSachResult[0];
  //     }
  //     emit(state.copyWith(
  //         danhSachChuKy: danhSachResult,
  //         chuKyMacDinh: mauChuKyDefault,
  //         vitriChuKy: mauChuKyDefault.intViTriChuKyMacDinh,
  //         vTriTrangKySo: mauChuKyDefault.intViTriTrang,
  //         status: BlocBuilderStatusCase.success));
  //     if (mauChuKyDefault != null) {
  //       await getMauChuKy(mauChuKyDefault: mauChuKyDefault);
  //       setChuKyMacDinh(chuKyMacDinh: mauChuKyDefault);
  //     }
  //   } else {
  //     emit(state.copyWith(
  //         danhSachChuKy: null, status: BlocBuilderStatusCase.failure));
  //   }
  // }

  void suDungViTriCauHinhAct({required bool isUse}) {
    emit(state.copyWith(isUseDefaultConfig: isUse));
  }

  Future<void> setChuKyMacDinh({MauChuKySoModel? chuKyMacDinh}) async {
    try {
      emit(state.copyWith(
          statusLoadSign: BlocBuilderStatusCase.loading, isContinue: false));
      await getMauChuKy(mauChuKyDefault: chuKyMacDinh!);
      goShowMauKySo();
      emit(state.copyWith(
          statusLoadSign: BlocBuilderStatusCase.success,
          chuKyMacDinh: chuKyMacDinh,
          vitriChuKy: chuKyMacDinh.intViTriChuKyMacDinh,
          vTriTrangKySo: chuKyMacDinh.intViTriTrang,
          isUseDefaultConfig: true));
    } catch (e) {
      emit(state.copyWith(statusLoadSign: BlocBuilderStatusCase.failure));
      print('error $e');
    }
  }

  void emitWarning({required bool isShow}) {
    emit(state.copyWith(
      isShowWarning: isShow,
    ));
  }

  Future<void> getMauChuKy({required MauChuKySoModel mauChuKyDefault}) async {}

  Future<void> getMauChuKyConvertFile(
      {required MauChuKySoModel mauChuKyDefault,
      required GlobalKey globalKey,
      required bool isUsedSignTemp}) async {}

  Future<void> getMauChuKyThamQuyenConvertFile(
      {required MauChuKySoModel mauChuKyDefault,
      required GlobalKey globalKey}) async {}

  Future<void> getImageChuKy(
      {required MauChuKySoModel mauChuKyDefault}) async {}

  void goShowMauKySo() {
    if (mauChuKyWidget != null) {
      emit(state.copyWith(mauChuKy: mauChuKyWidget));
    }
  }

  void warningButPhe(
      {required String title, required LoaiThongBao loaiThongBao}) {
    showFlushbar(
      ctx: mainContext,
      loaiThongBao: loaiThongBao,
      message: title,
      tgianHienThi: 2,
      icon: Icon(
        Icons.warning,
        size: 28,
        color: Colors.yellowAccent,
      ),
    );
  }

  void showSignFrame(bool isShowSign) =>
      emit(state.copyWith(isShowSign: isShowSign));

  void showDrawFrame(bool isDraw) => emit(state.copyWith(isDraw: isDraw));

  Future<String?> loadTepDinhKem(String tenTepDinhKem) async {
    // fullPathFile = tenTepDinhKem;
    // String tenFile = tenTepDinhKem.split("/").last;
    // // String? path = await network.checkFileExist(tenFile, "vanban");
    // if (tenTepDinhKem != null && tenTepDinhKem != '') {
    //   this.fileName = tenFile;
    //   return tenTepDinhKem;
    // } else {
    //   try {
    //     var userId = ConfigData.getUserID() ?? '0';
    //     var donViId = ConfigData.getDonViID() ?? '0';
    //     String url = ConfigData.BASE_URL! + '/FileManager/DownloadFileAlfresco';
    //     var pathStrTemp = await network.downloadFiles(
    //         url,
    //         tenTepDinhKem.split("|").first,
    //         "QLVB",
    //         userId,
    //         donViId,
    //         tenTepDinhKem.split("|").last,
    //         pathStr: "vanban");

    //     if (pathStrTemp != null) {
    //       this.fileName = pathStrTemp.split("/").last.split("|").first;
    //       return pathStrTemp;
    //     } else {
    //       return null;
    //     }
    //   } catch (e) {
    //     print("Download file ky ten: $e");
    //     return null;
    //   }
    // }
  }

  Future<String?> returnFilePath(String tenFile) async {
    String? tempPath = await FileLocalResponse().getPathLocal(
      ePathType: EPathType.Storage,
      configPathStr: "vanban",
    );
    File file = new File("$tempPath$tenFile");
    var pathStrTemp = await fromAsset(file);
    return pathStrTemp.path;
  }

  Future<File> fromAsset(File file) {
    Completer<File> completer = Completer();
    try {
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }
    return completer.future;
  }

  void postChuKyDemo() {
    // flushbar.showFlushbar(
    //   ctx: mainContext,
    //   loaiThongBao: LoaiThongBao.canhBao,
    //   message: "Tài khoản này chưa được đăng ký sim ký số",
    //   tgianHienThi: 3,
    //   icon: Icon(
    //     Icons.info_outlined,
    //     size: 28,
    //     color: ConfigColor.colorIconAppbar,
    //   ),
    // );
  }

  //////// Get Image Chữ Ký ///////
  void getChuKyImage() async {
    // emit(state.copyWith(status: BlocBuilderStatusCase.loading));
    // var dataResult = await viewFileApi?.getChuKyImage();
    // if (dataResult != null) {
    //   loaiCKs = dataResult.split("|");
    //   emit(state.copyWith(
    //       imageLoai1: loaiCKs[0],
    //       imageLoai2: loaiCKs[1],
    //       imageLoai3: loaiCKs[2],
    //       status: BlocBuilderStatusCase.success));
    // } else {
    //   emit(state.copyWith(status: BlocBuilderStatusCase.failure));
    // }
  }

  Future<String?> postChuKy(
      int? pageIndex,
      double? x,
      double? y,
      double? width,
      double? height,
      int? loaiChuKy,
      double? widthPage,
      double? heightPage,
      String? fileKyTen,
      double? ratio,
      double? firstPageHeight,
      File? mauChuKyFile,
      String sdtKySo,
      int mauChuKySoID) async {
    // try {
    //   // _loadingDialog.show();
    //   // http.ByteStream? stream = await viewFileApi!.postChuKy(
    //   //     pageIndex!,
    //   //     x! < 0 ? 0.0 : x,
    //   //     y! < 0 ? 0.0 : y,
    //   //     width!,
    //   //     height!,
    //   //     loaiChuKy!,
    //   //     widthPage!,
    //   //     heightPage!,
    //   //     fileKyTen!,
    //   //     ratio!,
    //   //     mauChuKyFile,
    //   //     sdtKySo,
    //   //     mauChuKySoID,
    //   //     fileKyTen);
    //   // await mauChuKyFile!.delete();
    //   // pushShowData(false);

    //   /// Ẩn frame limit size
    //   if (stream != null) {
    //     stream.transform(utf8.decoder).listen((value) async {
    //       await _loadingDialog.hide();
    //       GuiChuKyResult dataResult;
    //       dataResult = GuiChuKyResult.fromJson(jsonDecode(value));
    //       if (dataResult == null) {
    //         emit(state.copyWith(status: BlocBuilderStatusCase.failure));
    //         flushbar.showFlushbar(
    //           ctx: mainContext,
    //           loaiThongBao: LoaiThongBao.thatBai,
    //           message: 'Ký số không thành công',
    //           tgianHienThi: 2,
    //           icon: Icon(
    //             Icons.error_outline_rounded,
    //             size: 28,
    //             color: ConfigColor.colorIconAppbar,
    //           ),
    //         );
    //         return null;
    //       } else if (dataResult.urlFileSigned == null) {
    //         emit(state.copyWith(status: BlocBuilderStatusCase.failure));
    //         flushbar.showFlushbar(
    //           ctx: mainContext,
    //           loaiThongBao: LoaiThongBao.thatBai,
    //           message: (dataResult.messageError == '')
    //               ? 'Ký số không thành công'
    //               : dataResult.messageError,
    //           tgianHienThi: 2,
    //           icon: Icon(
    //             Icons.error_outline_rounded,
    //             size: 28,
    //             color: ConfigColor.colorIconAppbar,
    //           ),
    //         );
    //         return null;
    //       } else {
    //         emit(state.copyWith(status: BlocBuilderStatusCase.success));
    //         flushbar.showFlushbar(
    //           ctx: mainContext,
    //           loaiThongBao: LoaiThongBao.thanhCong,
    //           message: 'Ký số thành công',
    //           tgianHienThi: 2,
    //           icon: Icon(
    //             Icons.check_circle,
    //             size: 28,
    //             color: ConfigColor.colorIconAppbar,
    //           ),
    //         );
    //         Navigator.pop(mainContext,
    //             dataResult.urlFileSigned + "|" + dataResult.urlAlfresco);
    //       }

    //       //back thêm lần nữa
    //       Navigator.pop(mainContext,
    //           dataResult.urlFileSigned + "|" + dataResult.urlAlfresco);
    //       //return dataResult.urlFileSigned + "|" + dataResult.urlAlfresco;
    //     });
    //   } else {
    //     await _loadingDialog.hide();
    //     emit(state.copyWith(status: BlocBuilderStatusCase.failure));
    //     flushbar.showFlushbar(
    //       ctx: mainContext,
    //       loaiThongBao: LoaiThongBao.thatBai,
    //       message: 'Ký số không thành công',
    //       tgianHienThi: 2,
    //       icon: Icon(
    //         Icons.error_outline_rounded,
    //         size: 28,
    //         color: ConfigColor.colorIconAppbar,
    //       ),
    //     );
    //     return null;
    //   }
    // } catch (e) {
    //   print('lỗi ký số : $e');
    //   await _loadingDialog.hide();
    //   emit(state.copyWith(status: BlocBuilderStatusCase.failure));
    //   flushbar.showFlushbar(
    //     ctx: mainContext,
    //     loaiThongBao: LoaiThongBao.thatBai,
    //     message: 'Ký số không thành công',
    //     tgianHienThi: 2,
    //     icon: Icon(
    //       Icons.error_outline_rounded,
    //       size: 28,
    //       color: ConfigColor.colorIconAppbar,
    //     ),
    //   );
    //   return null;
    // }
  }

  Future<String?> postChuKyVanBannDiAct(
      bool isKyNhay,
      int? pageIndex,
      double? x,
      double? y,
      double? width,
      double? height,
      int? loaiChuKy,
      double? widthPage,
      double? heightPage,
      String? fileKyTen,
      double? ratio,
      double? firstPageHeight,
      File? mauChuKyFile,
      String sdtKySo,
      String signerName,
      int mauChuKySoID) async {
    // try {
    //   _loadingDialog.show();
    //   http.ByteStream? stream = await viewFileApi!.postChuKyVanBannDi(
    //       isKyNhay,
    //       pageIndex!,
    //       x! < 0 ? 0.0 : x,
    //       y! < 0 ? 0.0 : y,
    //       width!,
    //       height!,
    //       loaiChuKy!,
    //       widthPage!,
    //       heightPage!,
    //       fileKyTen!,
    //       ratio!,
    //       mauChuKyFile,
    //       signerName,
    //       sdtKySo,
    //       mauChuKySoID,
    //       fullPathFile ?? "");
    //   // await mauChuKyFile!.delete();
    //   pushShowData(false);

    //   /// Ẩn frame limit size
    //   if (stream != null) {
    //     stream.transform(utf8.decoder).listen((value) async {
    //       await _loadingDialog.hide();
    //       GuiChuKyResult dataResult;
    //       dataResult = GuiChuKyResult.fromJson(jsonDecode(value));
    //       if (dataResult == null) {
    //         emit(state.copyWith(status: BlocBuilderStatusCase.failure));
    //         flushbar.showFlushbar(
    //           ctx: mainContext,
    //           loaiThongBao: LoaiThongBao.thatBai,
    //           message: 'Ký số không thành công',
    //           tgianHienThi: 2,
    //           icon: Icon(
    //             Icons.error_outline_rounded,
    //             size: 28,
    //             color: ConfigColor.colorIconAppbar,
    //           ),
    //         );
    //         return null;
    //       } else if (dataResult.urlFileSigned == null) {
    //         emit(state.copyWith(status: BlocBuilderStatusCase.failure));
    //         flushbar.showFlushbar(
    //           ctx: mainContext,
    //           loaiThongBao: LoaiThongBao.thatBai,
    //           message: (dataResult.messageError == '')
    //               ? 'Ký số không thành công'
    //               : dataResult.messageError,
    //           tgianHienThi: 2,
    //           icon: Icon(
    //             Icons.error_outline_rounded,
    //             size: 28,
    //             color: ConfigColor.colorIconAppbar,
    //           ),
    //         );
    //         return null;
    //       } else {
    //         emit(state.copyWith(status: BlocBuilderStatusCase.success));
    //         flushbar.showFlushbar(
    //           ctx: mainContext,
    //           loaiThongBao: LoaiThongBao.thanhCong,
    //           message: 'Ký số thành công',
    //           tgianHienThi: 2,
    //           icon: Icon(
    //             Icons.check_circle,
    //             size: 28,
    //             color: ConfigColor.colorIconAppbar,
    //           ),
    //         );
    //         Navigator.pop(mainContext,
    //             dataResult.urlFileSigned + "|" + dataResult.urlAlfresco);
    //       }

    //       //back thêm lần nữa
    //       Navigator.pop(mainContext,
    //           dataResult.urlFileSigned + "|" + dataResult.urlAlfresco);
    //       //return dataResult.urlFileSigned + "|" + dataResult.urlAlfresco;
    //     });
    //   } else {
    //     await _loadingDialog.hide();
    //     emit(state.copyWith(status: BlocBuilderStatusCase.failure));
    //     flushbar.showFlushbar(
    //       ctx: mainContext,
    //       loaiThongBao: LoaiThongBao.thatBai,
    //       message: 'Ký số không thành công',
    //       tgianHienThi: 2,
    //       icon: Icon(
    //         Icons.error_outline_rounded,
    //         size: 28,
    //         color: ConfigColor.colorIconAppbar,
    //       ),
    //     );
    //     return null;
    //   }
    // } catch (e) {
    //   print('lỗi ký số : $e');
    //   await _loadingDialog.hide();
    //   emit(state.copyWith(status: BlocBuilderStatusCase.failure));
    //   flushbar.showFlushbar(
    //     ctx: mainContext,
    //     loaiThongBao: LoaiThongBao.thatBai,
    //     message: 'Ký số không thành công',
    //     tgianHienThi: 2,
    //     icon: Icon(
    //       Icons.error_outline_rounded,
    //       size: 28,
    //       color: ConfigColor.colorIconAppbar,
    //     ),
    //   );
    //   return null;
    // }
  }

  Future<String?> postReviewFile(
      int? pageIndex,
      double? x,
      double? y,
      double? width,
      double? height,
      int? loaiChuKy,
      double? widthPage,
      double? heightPage,
      String? fileKyTen,
      double? ratio,
      double? firstPageHeight,
      File? mauChuKyFile,
      String sdtKySo,
      String signerName,
      int mauChuKySoID) async {
    // try {
    //   // if (fileKyTen == null) {
    //   //   flushbar.showFlushbar(
    //   //     ctx: mainContext,
    //   //     loaiThongBao: LoaiThongBao.thatBai,
    //   //     message: 'Tải bản xem thử không thành công',
    //   //     tgianHienThi: 2,
    //   //     icon: Icon(
    //   //       Icons.error_outline_rounded,
    //   //       size: 28,
    //   //       color: ConfigColor.colorIconAppbar,
    //   //     ),
    //   //   );
    //   //   return null;
    //   // }
    //   // fileKyTen = fileKyTen != null ? fileKyTen : "";
    //   // //  _loadingDialog.show();
    //   // String tenFile = fileKyTen.split("/").last.split("|").last;
    //   // if (tenFile != null && tenFile != '') {
    //   //   this.fileName = tenFile;
    //   // }
    //   // http.ByteStream? stream = await viewFileApi!.postReviewFile(
    //   //     pageIndex!,
    //   //     x! < 0 ? 0.0 : x,
    //   //     y! < 0 ? 0.0 : y,
    //   //     width!,
    //   //     height!,
    //   //     loaiChuKy!,
    //   //     widthPage!,
    //   //     heightPage!,
    //   //     fileKyTen,
    //   //     ratio!,
    //   //     mauChuKyFile,
    //   //     signerName,
    //   //     sdtKySo,
    //   //     mauChuKySoID,
    //   //     fullPathFile ?? "");
    //   // pushShowData(false);

    //   // /// Ẩn frame limit size
    //   // if (stream != null) {
    //   //   var value = await utf8.decoder.bind(stream).join();
    //   //   if (value != null && value.isNotEmpty) {
    //   //     GuiChuKyResult? dataResult =
    //   //         GuiChuKyResult.fromJson(jsonDecode(value));
    //   //     if (dataResult == null ||
    //   //         dataResult.urlAlfresco == null &&
    //   //             dataResult.urlFileSigned == null) {
    //   //       emit(state.copyWith(status: BlocBuilderStatusCase.failure));
    //   //       // flushbar.showFlushbar(
    //   //       //   ctx: mainContext,
    //   //       //   loaiThongBao: LoaiThongBao.thatBai,
    //   //       //   message: 'Tải bản xem thử không thành công',
    //   //       //   tgianHienThi: 2,
    //   //       //   icon: Icon(
    //   //       //     Icons.error_outline_rounded,
    //   //       //     size: 28,
    //   //       //     color: ConfigColor.colorIconAppbar,
    //   //       //   ),
    //   //       // );
    //   //       return null;
    //   //     } else {
    //   //       return await Future.delayed(Duration(milliseconds: 200))
    //   //           .then((value) => dataResult.urlFileSigned);
    //   //     }
    //   //   }
    //   // } else {
    //   //   // await _loadingDialog.hide();
    //   //   //  emit(state.copyWith(status: BlocBuilderStatusCase.failure));
    //   //   // flushbar.showFlushbar(
    //   //   //   ctx: mainContext,
    //   //   //   loaiThongBao: LoaiThongBao.thatBai,
    //   //   //   message: 'Tải bản xem thử không thành công',
    //   //   //   tgianHienThi: 2,
    //   //   //   icon: Icon(
    //   //   //     Icons.error_outline_rounded,
    //   //   //     size: 28,
    //   //   //     color: ConfigColor.colorIconAppbar,
    //   //   //   ),
    //   //   // );
    //   //   return null;
    //   // }
    // } catch (e) {
    //   print('lỗi review ký số : $e');
    //   await _loadingDialog.hide();
    //   // emit(state.copyWith(status: BlocBuilderStatusCase.failure));
    //   // flushbar.showFlushbar(
    //   //   ctx: mainContext,
    //   //   loaiThongBao: LoaiThongBao.thatBai,
    //   //   message: 'Tải bản xem thử không thành công',
    //   //   tgianHienThi: 2,
    //   //   icon: Icon(
    //   //     Icons.error_outline_rounded,
    //   //     size: 28,
    //   //     color: ConfigColor.colorIconAppbar,
    //   //   ),
    //   // );
    //   return null;
    // }
  }

  // Future<String?> postKySoKhongSuDungMCK(String? path, int mauChuKySoID,
  //     String sdtKySo, String fullPathFile) async {
  //   try {
  //     _loadingDialog.style(
  //         message: "Đang thực hiện ký số",
  //         messageTextStyle:
  //             ConfigTextStyle.boldStyle(fontSize: ConfigFontSize.sizeDefault));
  //     _loadingDialog.show();
  //     await Future.delayed(Duration(milliseconds: 300));
  //     var filename = path!.split('/').last;
  //     http.ByteStream? stream = await viewFileApi!.postKySoKhongSuDungMCK(
  //         path, filename, mauChuKySoID, sdtKySo, fullPathFile);
  //     if (stream != null) {
  //       await _loadingDialog.hide();
  //       stream.transform(utf8.decoder).listen((value) async {
  //         GuiChuKyResult dataResult;
  //         dataResult = GuiChuKyResult.fromJson(jsonDecode(value));
  //         if (dataResult == null) {
  //           emit(state.copyWith(status: BlocBuilderStatusCase.failure));
  //           showFlusBar('Ký số không thành công', LoaiThongBao.thatBai);
  //           return null;
  //         } else if (dataResult.urlFileSigned == null) {
  //           emit(state.copyWith(status: BlocBuilderStatusCase.failure));
  //           showFlusBar(
  //               (dataResult.messageError == '')
  //                   ? 'Ký số không thành công'
  //                   : dataResult.messageError,
  //               LoaiThongBao.thatBai);
  //           return null;
  //         } else {
  //           emit(state.copyWith(status: BlocBuilderStatusCase.success));
  //           showFlusBar('Ký số thành công', LoaiThongBao.thanhCong);
  //           Navigator.pop(mainContext,
  //               dataResult.urlFileSigned + "|" + dataResult.urlAlfresco);
  //         }
  //         //back thêm lần nữa
  //         Navigator.pop(mainContext,
  //             dataResult.urlFileSigned + "|" + dataResult.urlAlfresco);
  //       });
  //     } else {
  //       await _loadingDialog.hide();
  //       emit(state.copyWith(status: BlocBuilderStatusCase.failure));
  //       showFlusBar('Ký số không thành công', LoaiThongBao.thatBai);
  //       return null;
  //     }
  //   } catch (e) {
  //     print('lỗi ký số : $e');
  //     await _loadingDialog.hide();
  //     emit(state.copyWith(status: BlocBuilderStatusCase.failure));
  //     showFlusBar('Ký số không thành công', LoaiThongBao.thatBai);
  //     return null;
  //   }
  // }

  void emitFileWidget({required File fileImageWidget}) {
    emit(state.copyWith(fileImageWidget: fileImageWidget));
  }

  void emitTypeWidget({required TypeEditCase typeEditCase}) {
    emit(state.copyWith(typeEditCase: typeEditCase));
  }

  void setCountPage({required int countPage}) {
    emit(state.copyWith(countPage: countPage));
  }

  void setCountCurrentPage({required int currentPage}) {
    emit(state.copyWith(currentPage: currentPage));
  }

  void showLimitLength() {
    // flushbar.showFlushbar(
    //   ctx: mainContext,
    //   loaiThongBao: LoaiThongBao.canhBao,
    //   message: 'Nội dung không vượt quá 250 ký tự!',
    //   tgianHienThi: 2,
    //   icon: Icon(
    //     Icons.warning,
    //     size: 28,
    //     color: Colors.yellow,
    //   ),
    // );
    FocusScope.of(mainContext).requestFocus(FocusNode());
  }

  ////////////
  // Future<http.ByteStream?> uploadFileAlfresco(
  //     String? path, String? filename) async {
  //   var postUri =
  //       Uri.parse("${ConfigData.BASE_URL}/FileManager/UploadFileAlfresco");

  //   var request = new http.MultipartRequest("POST", postUri);

  //   request.fields['UserID'] = ConfigData.getUserID()!;
  //   request.fields['LoaiFileAlfresco'] = "QLVB";
  //   request.fields['donViID'] = ConfigData.getDonViID()!;

  //   Uri uri = Uri(path: path);
  //   request.files.add(new http.MultipartFile.fromBytes(
  //       'filedata', await File.fromUri(uri).readAsBytes(),
  //       filename: filename));

  //   // print('//////////Alfresco///////');
  //   try {
  //     http.StreamedResponse streamedResponse = await request.send();
  //     if (streamedResponse.statusCode != 200) {
  //       return null;
  //     }
  //     return streamedResponse.stream;
  //   } catch (e) {
  //     print('Error anfreshco: $e');
  //   }
  // }

  ////////////

  // final StreamController<bool> showController =
  //     StreamController<bool>.broadcast();

  // Stream<bool> get streamShow => showController.stream;

  // void pushShowData(bool isShow) {
  //   showController.sink.add(isShow);
  // }

  ////////////

  final StreamController<bool> showNoteController =
      StreamController<bool>.broadcast();

  Stream<bool> get streamNote => showNoteController.stream;

  void pushShowNoteData(bool isShow) {
    showNoteController.sink.add(isShow);
  }

  //////////////////////////////
  final StreamController<String> updateController =
      StreamController<String>.broadcast();

  Stream<String> get streamUpdate => updateController.stream;

  void pushUpdate(String link) {
    updateController.sink.add(link);
  }

  //////////////////////////////
  final StreamController<List<LoaiHienThiList>> updateListController =
      StreamController<List<LoaiHienThiList>>.broadcast();

  Stream<List<LoaiHienThiList>> get streamUpdateList =>
      updateListController.stream;

  void pushListUpdate(int index) {
    for (var i = 0; i < loaiHienThiList.length; i++) {
      if (i == index) {
        loaiHienThiList[i].isChoose = !loaiHienThiList[i].isChoose!;
      } else {
        loaiHienThiList[i].isChoose = false;
      }
    }
    updateListController.sink.add(loaiHienThiList);
  }

  final StreamController<bool> errorController =
      StreamController<bool>.broadcast();

  Stream<bool> get streamError => errorController.stream;

  void pushErrorData(bool isShow) {
    errorController.sink.add(isShow);
  }

  final StreamController<bool> errorDownLoadController =
      StreamController<bool>.broadcast();

  Stream<bool> get streamDownload => errorDownLoadController.stream;

  void pushDownLoadData(bool isShow) {
    errorDownLoadController.sink.add(isShow);
  }

  ///////////////////////////////

  final StreamController<int> typeCKController =
      StreamController<int>.broadcast();

  Stream<int> get streamTypeCK => typeCKController.stream;

  void pushTypeCKData(int type) {
    typeCKController.sink.add(type);
  }

  //////////////////////////////
  final StreamController<List<LoaiKySoModel>> typeController =
      StreamController<List<LoaiKySoModel>>.broadcast();

  Stream<List<LoaiKySoModel>> get streamType => typeController.stream;

  void pushIndexTypeCK(int index) {
    for (var i = 0; i < listTypeCK.length; i++) {
      if (index == i) {
        listTypeCK[i].isChoose = true;
      } else {
        listTypeCK[i].isChoose = false;
      }
    }
    typeController.sink.add(listTypeCK);
  }

  ////////////////////
  final StreamController<int> typeCKImageController =
      StreamController<int>.broadcast();

  Stream<int> get streamTypeCKImage => typeCKImageController.stream;

  void pushTypeCKImageData(int type) {
    typeCKImageController.sink.add(type);
  }

  ///////////////////////////////

  final StreamController<bool> calculatorController =
      StreamController<bool>.broadcast();

  Stream<bool> get streamcCalculator => calculatorController.stream;

  void pushIndexCalculator(bool isUpdate) {
    calculatorController.sink.add(isUpdate);
  }

  void closeStream() {
    typeCKImageController.close();
    typeController.close();
    // showController.close();
    updateController.close();
    updateListController.close();
    errorController.close();
    errorDownLoadController.close();
    calculatorController.close();
    typeCKController.close();
    showNoteController.close();
  }
}
