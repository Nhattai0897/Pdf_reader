import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pdf_reader/sign_vanban_den/model/pdf_result.dart';
import 'package:pdf_reader/sign_vanban_den/widget/showFlushbar.dart';
import 'package:pdf_reader/utils/networks.dart';
import 'package:pdf_reader/utils/shared_prefs.dart';
import 'package:storage_info/storage_info.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Cubit<DashboardState> {
  late BuildContext mainContext;
  List<GlobalObjectKey<FormState>> newPrivateFileLst = [];
  List<PDFModel> publicCloneList = [];
  List<PDFModel> privateCloneList = [];

  DashboardBloc()
      : super(DashboardState(
          countEditPublic: 0,
          totalSizePublic: "0",
          percent: 0.0,
          totalSizePrivate: "0",
          countEditPrivate: 0,
          indexTab: 0,
          isEnglish: true,
        ));

  void initContext(BuildContext context) {
    this.mainContext = context;
    EasyLoading.init();
    configLoading();
    setupTotalData();
    var language = SharedPrefs().getValue(KeyPrefs.localeCode) ?? 'EN';
    updateLanguage(language == "EN" ? true : false);
  }

  void configLoading() {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.dark
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..progressColor = Colors.yellow
      ..backgroundColor = Colors.green
      ..indicatorColor = Colors.yellow
      ..textColor = Colors.yellow
      ..maskColor = Colors.blue.withOpacity(0.5)
      ..userInteractions = true
      ..dismissOnTap = false;
  }

  void onChangeDay() => emit(state.copyWith(isNight: !state.isNight));

  Future<void> setupTotalData() async {
    var tempPath = await FileLocalResponse().getPathLocal(
      ePathType: EPathType.Storage,
      configPathStr: state.indexTab == 0 ? 'publicFolder' : 'privateFolder',
    );
    dirStatSync(tempPath ?? '');
  }

  void emitIndex(int index) {
    emit(state.copyWith(indexTab: index));
    setupTotalData();
  }

  Future<void> dirStatSync(String dirPath) async {
    int fileNum = 0;
    int totalSize = 0;
    var dir = Directory(dirPath);
    try {
      if (dir.existsSync()) {
        dir
            .listSync(recursive: true, followLinks: false)
            .forEach((FileSystemEntity entity) {
          if (entity is File) {
            fileNum++;
            totalSize += entity.lengthSync();
          }
        });
      }
    } catch (e) {
      print(e.toString());
    }
    var convertSize = formatBytes(totalSize, 2);
    var percent = await _getPercent();
    if (state.indexTab == 0) {
      var editCount = 0;
      for (var i = 0; i < publicCloneList.length; i++) {
        if (publicCloneList[i].isEdit == true) {
          editCount = editCount + 1;
        }
      }
      emit(state.copyWith(
          totalSizePublic: editCount == 0 ? "0" : convertSize,
          percent: percent));
      await Future.delayed(Duration(milliseconds: 100));
      pushpublicEditCountData(fileNum != editCount ? editCount : fileNum);
    } else {
      var editCount = 0;
      for (var i = 0; i < privateCloneList.length; i++) {
        if (privateCloneList[i].isEdit == true) {
          editCount = editCount + 1;
        }
      }
      emit(state.copyWith(
          totalSizePrivate: editCount == 0 ? "0" : convertSize,
          percent: percent));
      await Future.delayed(Duration(milliseconds: 100));
      pushPrivateEditData(fileNum != editCount ? editCount : fileNum);
    }
  }

  Future<double> _getPercent() async {
    var totalSpace = await StorageInfo.getStorageTotalSpace;
    var totalUsed = await StorageInfo.getStorageUsedSpace;
    return (((totalUsed / totalSpace) * 100) / 100);
  }

  static String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0";
    var mb = bytes / 1000 / 1000;
    return mb.toStringAsFixed(decimals);
  }

  void updateLanguage(bool isEnglish) =>
      emit(state.copyWith(isEnglish: isEnglish));

  void warningFlushbar(
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

  //////////// publicEditCount ///////////

  final StreamController<int> publicCountController =
      StreamController<int>.broadcast();

  Stream<int> get streampublicEditCount => publicCountController.stream;

  void pushpublicEditCountData(int publicCount) =>
      publicCountController.sink.add(publicCount);

  ////////////  privateEditCount ///////////

  final StreamController<int> privateCountController =
      StreamController<int>.broadcast();

  Stream<int> get streamPrivateEditCount => privateCountController.stream;

  void pushPrivateEditData(int privateCount) =>
      privateCountController.sink.add(privateCount);

  //////////// private Total ///////////

  final StreamController<int> privateTotalController =
      StreamController<int>.broadcast();

  Stream<int> get streamPrivateTotal => privateTotalController.stream;

  void pushPrivateTotalData(int privateCount) =>
      privateTotalController.sink.add(privateCount);

  //////////// public Total ///////////

  final StreamController<int> publicTotalController =
      StreamController<int>.broadcast();

  Stream<int> get streamPublicTotal => publicTotalController.stream;

  void pushPublicTotalData(int publicCount) =>
      publicTotalController.sink.add(publicCount);

  void dispose() {
    publicCountController.close();
    privateCountController.close();
    privateTotalController.close();
    publicTotalController.close();
  }

  void searchAction(bool isSearch) => emit(state.copyWith(isSearch: isSearch));
}
