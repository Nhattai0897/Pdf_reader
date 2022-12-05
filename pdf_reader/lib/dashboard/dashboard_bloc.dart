import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pdf_reader/sign_vanban_den/widget/showFlushbar.dart';
import 'package:pdf_reader/utils/networks.dart';
import 'package:storage_info/storage_info.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Cubit<DashboardState> {
  late BuildContext mainContext;
  List<GlobalObjectKey<FormState>> newPrivateFileLst = [];

  DashboardBloc()
      : super(DashboardState(
          publicCount: 0,
          privateCount: 0,
          countEditPublic: 0,
          totalSizePublic: "0",
          percent: 0.0,
          totalSizePrivate: "0",
          countEditPrivate: 0,
          indexTab: 0,
        ));

  void initContext(BuildContext context) {
    this.mainContext = context;
    EasyLoading.init();
    configLoading();
    setupTotalData();
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

  void updatePublicCount(int count) => emit(state.copyWith(publicCount: count));
  void updatePrivateCount(int count) =>
      emit(state.copyWith(privateCount: count));

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
    state.indexTab == 0
        ? emit(state.copyWith(
            countEditPublic: fileNum,
            totalSizePublic: convertSize,
            percent: percent))
        : emit(state.copyWith(
            countEditPrivate: fileNum,
            totalSizePrivate: convertSize,
            percent: percent));
  }

  Future<double> _getPercent() async {
    var totalSpace = await StorageInfo.getStorageTotalSpace;
    var totalUsed = await StorageInfo.getStorageUsedSpace;
    return (((totalUsed / totalSpace) * 100) / 100);
  }

  static String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0";
    // var i = (log(bytes) / log(1024)).floor();
    // return ((bytes / pow(1024, i)).toStringAsFixed(decimals));
    var mb = bytes / 1000 / 1000;
    return mb.toStringAsFixed(decimals);
  }

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

  void searchAction(bool isSearch) => emit(state.copyWith(isSearch: isSearch));
}
