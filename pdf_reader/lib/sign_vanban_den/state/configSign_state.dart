 
import 'package:pdf_reader/sign_vanban_den/utils/bloc_builder_status.dart';

class ConfigSignState {
  BlocBuilderStatusCase? status;
  ConfigSignState({this.status = BlocBuilderStatusCase.initial});
  ConfigSignState copyWith({BlocBuilderStatusCase? status}) {
    return ConfigSignState(
      status: status ?? this.status,
    );
  }
}
