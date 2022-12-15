import 'package:pdf_reader/sign_vanban_den/utils/bloc_builder_status.dart';

class DashboardState {
  BlocBuilderStatusCase? status;
  bool isNight;
  bool isPublish;
  bool isSearch;
  int countEditPublic;
  String totalSizePublic;
  double percent;
  int? countEditPrivate;
  String? totalSizePrivate;
  int indexTab;
  bool isEnglish;
  DashboardState(
      {this.status = BlocBuilderStatusCase.initial,
      this.isNight = false,
      this.isPublish = true,
      this.isSearch = false,
      required this.countEditPublic,
      required this.totalSizePublic,
      required this.countEditPrivate,
      required this.totalSizePrivate,
      required this.indexTab,
      required this.percent,
      required this.isEnglish});
  DashboardState copyWith(
      {BlocBuilderStatusCase? status,
      bool? isNight,
      bool? isPublish,
      bool? isSearch,
      int? countEditPublic,
      String? totalSizePublic,
      int? countEditPrivate,
      String? totalSizePrivate,
      int? indexTab,
      double? percent,
      bool? isEnglish}) {
    return DashboardState(
        status: status ?? this.status,
        isNight: isNight ?? this.isNight,
        isPublish: isPublish ?? this.isPublish,
        isSearch: isSearch ?? this.isSearch,
        totalSizePublic: totalSizePublic ?? this.totalSizePublic,
        countEditPublic: countEditPublic ?? this.countEditPublic,
        percent: percent ?? this.percent,
        totalSizePrivate: totalSizePrivate ?? this.totalSizePrivate,
        countEditPrivate: countEditPrivate ?? this.countEditPrivate,
        indexTab: indexTab ?? this.indexTab,
        isEnglish: isEnglish ?? this.isEnglish);
  }
}
