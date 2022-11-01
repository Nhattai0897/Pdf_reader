import 'package:pdf_reader/utils/bloc_builder_status.dart';

class DashboardState {
  BlocBuilderStatusCase? status;
  bool isNight;
  bool isPublish;
  bool isSearch;
  DashboardState(
      {this.status = BlocBuilderStatusCase.initial,
      this.isNight = false,
      this.isPublish = true,
      this.isSearch = false});
  DashboardState copyWith(
      {BlocBuilderStatusCase? status,
      bool? isNight,
      bool? isPublish,
      bool? isSearch}) {
    return DashboardState(
        status: status ?? this.status,
        isNight: isNight ?? this.isNight,
        isPublish: isPublish ?? this.isPublish,
        isSearch: isSearch ?? this.isSearch);
  }
}
