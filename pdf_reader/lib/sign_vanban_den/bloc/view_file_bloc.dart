import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; 
import 'package:pdf_reader/sign_vanban_den/state/view_file_state.dart';
import 'package:pdf_reader/sign_vanban_den/utils/bloc_builder_status.dart';
import 'package:pdf_reader/sign_vanban_den/widget/showFlushbar.dart';
import 'package:pdf_reader/utils/bloc_builder_status.dart';
import 'package:pdf_reader/utils/networks.dart';

class ViewFileBloc extends Cubit<ViewFileState> {
  late FileLocalResponse network;
  late BuildContext mainContext;
  late Widget mauChuKyWidget;
  File? fileImageWidget;
  String? fileName;
  String? fullPathFile;
  bool? isFirst;
  ViewFileBloc()
      : super(ViewFileState(
            status: BlocBuilderStatusCase.initial,
            statusLoadSign: BlocBuilderStatusCase.initial,
            isUseDefaultConfig: true,
            countPage: 0,
            currentPage: 0,
            isFirst: true,
            isShowWarning: false));

  void initContext(BuildContext context, String tenTepDinhKem) {
    fullPathFile = tenTepDinhKem;
    this.mainContext = context;
    checkFirstTime();
  }

  void checkFirstTime() => isFirst = false;

  void onFinish() => emit(state.copyWith(isFirst: false));

  void suDungViTriCauHinhAct({required bool isUse}) =>
      emit(state.copyWith(isUseDefaultConfig: isUse));

  void emitWarning({required bool isShow}) {
    emit(state.copyWith(
      isShowWarning: isShow,
    ));
  }

  void warningButPhe(
      {required String title, required LoaiThongBao loaiThongBao}) {
    showFlushbar(
      ctx: mainContext,
      loaiThongBao: loaiThongBao,
      message: title,
      tgianHienThi: 2,
      icon: Icon(
        loaiThongBao == LoaiThongBao.canhBao
            ? Icons.warning
            : loaiThongBao == LoaiThongBao.thanhCong
                ? Icons.check_circle_outline_outlined
                : Icons.clear,
        size: 28,
        color: loaiThongBao == LoaiThongBao.canhBao
            ? Colors.yellow[100]
            : loaiThongBao == LoaiThongBao.thanhCong
                ? Colors.green[100]
                : Colors.red[100],
      ),
    );
  }

  void showSignFrame(bool isShowSign) =>
      emit(state.copyWith(isShowSign: isShowSign));

  void showDrawFrame(bool isDraw) => emit(state.copyWith(isDraw: isDraw));

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
    FocusScope.of(mainContext).requestFocus(FocusNode());
    warningButPhe(
        title:
            "Text length exceeds the allowed number of characters (allow input of 220 characters)",
        loaiThongBao: LoaiThongBao.canhBao);
  }

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

  final StreamController<bool> errorController =
      StreamController<bool>.broadcast();

  Stream<bool> get streamError => errorController.stream;

  void pushErrorData(bool isShow) {
    errorController.sink.add(isShow);
  }

  ///////////////////////////////
  final StreamController<bool> errorDownLoadController =
      StreamController<bool>.broadcast();

  Stream<bool> get streamDownload => errorDownLoadController.stream;

  void pushDownLoadData(bool isShow) {
    errorDownLoadController.sink.add(isShow);
  } ///////////////////////////////

  final StreamController<bool> loadingDrawController =
      StreamController<bool>.broadcast();

  Stream<bool> get streamLoadingDraw => loadingDrawController.stream;

  void pushDownLoadDraw(bool isShow) {
    loadingDrawController.sink.add(isShow);
  }

  ///////////////////////////////

  final StreamController<int> typeCKController =
      StreamController<int>.broadcast();

  Stream<int> get streamTypeCK => typeCKController.stream;

  void pushTypeCKData(int type) {
    typeCKController.sink.add(type);
  }

  /////////////////////////////
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

  ////////////////////
  final StreamController<bool> readyController =
      StreamController<bool>.broadcast();

  Stream<bool> get streamReady => readyController.stream;

  void pushReady(bool type) {
    readyController.sink.add(type);
  }

  void closeStream() {
    readyController.close();
    typeCKImageController.close();
    updateController.close();
    errorController.close();
    errorDownLoadController.close();
    calculatorController.close();
    typeCKController.close();
    showNoteController.close();
    loadingDrawController.close();
  }
}
