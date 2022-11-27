import 'package:disk_space/disk_space.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Cubit<DashboardState> {
  late BuildContext mainContext;
  late List<GlobalObjectKey<FormState>> formKeyList;
  List<GlobalObjectKey<FormState>> newPrivateFileLst = [];

  DashboardBloc() : super(DashboardState());

  void initContext(BuildContext context) {
    this.mainContext = context;
    EasyLoading.init();
    configLoading();
    // checkTime();
    // await EasyLoading.show(
    //   status: 'loading...',
    //   maskType: EasyLoadingMaskType.black,
    // );
    formKeyList =
        new List.generate(0, (index) => GlobalObjectKey<FormState>(index));
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

  void checkTime() {
    var hour = DateTime.now().hour;
   // var isNight = hour >= 6 && hour <= 17;
    // emit(state.copyWith(isNight: !isNight));
  }

  Future<void> onChangeDay() async {
    emit(state.copyWith(isNight: !state.isNight));
    print('diskspace ${await DiskSpace.getFreeDiskSpace}');
    print('diskspace ${await DiskSpace.getTotalDiskSpace}');
  }

  void searchAction(bool isSearch) => emit(state.copyWith(isSearch: isSearch));
}
