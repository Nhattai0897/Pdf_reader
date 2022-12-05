import 'package:pdf_reader/sign_vanban_den/utils/bloc_builder_status.dart';

class DashboardState {
  BlocBuilderStatusCase? status;
  bool isNight;
  bool isPublish;
  bool isSearch;
  int publicCount;
  int privateCount;
  int countEditPublic;
  String totalSizePublic;
  double percent;
  int? countEditPrivate;
  String? totalSizePrivate;
  int indexTab;
  DashboardState(
      {this.status = BlocBuilderStatusCase.initial,
      this.isNight = false,
      this.isPublish = true,
      this.isSearch = false,
      required this.publicCount,
      required this.privateCount,
      required this.countEditPublic,
      required this.totalSizePublic,
      required this.countEditPrivate,
      required this.totalSizePrivate,
      required this.indexTab,
      required this.percent});
  DashboardState copyWith(
      {BlocBuilderStatusCase? status,
      bool? isNight,
      bool? isPublish,
      bool? isSearch,
      int? publicCount,
      int? privateCount,
      int? privateCoun,
      int? countEditPublic,
      String? totalSizePublic,
      int? countEditPrivate,
      String? totalSizePrivate,
      int? indexTab,
      double? percent}) {
    return DashboardState(
        status: status ?? this.status,
        isNight: isNight ?? this.isNight,
        isPublish: isPublish ?? this.isPublish,
        isSearch: isSearch ?? this.isSearch,
        publicCount: publicCount ?? this.publicCount,
        privateCount: privateCount ?? this.privateCount,
        totalSizePublic: totalSizePublic ?? this.totalSizePublic,
        countEditPublic: countEditPublic ?? this.countEditPublic,
        percent: percent ?? this.percent,
        totalSizePrivate: totalSizePrivate ?? this.totalSizePrivate,
        countEditPrivate: countEditPrivate ?? this.countEditPrivate,
        indexTab: indexTab ?? this.indexTab);
  }
}
