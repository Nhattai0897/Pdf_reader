import 'package:hive/hive.dart';
part 'pdf_result.g.dart';

@HiveType(typeId: 0)
class PDFModel {
  @HiveField(0)
  @HiveField(1)
  String? pathFile;
  @HiveField(2)
  DateTime? timeOpen;
  @HiveField(3)
  int? currentIndex;
  @HiveField(4)
  bool? isOpen;
  @HiveField(5)
  bool? isEdit;
  @HiveField(6)
  String? urlLink;

  PDFModel(
      {this.pathFile,
      this.timeOpen,
      this.urlLink,
      this.currentIndex,
      this.isOpen = false,
      this.isEdit = false});

  PDFModel.fromJson(Map<String, dynamic> json) {
    pathFile = json['PathFile'];
    urlLink = json['UrlLink'];
    timeOpen = json['TimeOpen'];
    currentIndex = json['CurrentIndex'];
    isOpen = json['IsOpen'];
    isEdit = json['IsEdit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['PathFile'] = this.pathFile;
    data['UrlLink'] = this.urlLink;
    data['TimeOpen'] = this.timeOpen;
    data['CurrentIndex'] = this.currentIndex;
    data['IsOpen'] = this.isOpen;
    data['IsEdit'] = this.isEdit;
    return data;
  }
}
