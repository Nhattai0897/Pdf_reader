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
  @HiveField(7)
  double? propress;
  @HiveField(8)
  String? isDownloadSuccess;
  @HiveField(9)
  String? status;
  @HiveField(10)
  bool? isNew;

  PDFModel(
      {this.pathFile,
      this.timeOpen,
      this.urlLink,
      this.currentIndex,
      this.isOpen = false,
      this.isEdit = false,
      this.isNew = false,
      this.propress = 0,
      this.isDownloadSuccess,
      this.status = "none"});

  PDFModel.fromJson(Map<String, dynamic> json) {
    pathFile = json['PathFile'];
    urlLink = json['UrlLink'];
    timeOpen = json['TimeOpen'];
    currentIndex = json['CurrentIndex'];
    isOpen = json['IsOpen'];
    isEdit = json['IsEdit'];
    propress = json['Propress'];
    isDownloadSuccess = json['isDownloadSuccess'];
    status = json['Status'];
    isNew = json['IsNew'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['PathFile'] = this.pathFile;
    data['UrlLink'] = this.urlLink;
    data['TimeOpen'] = this.timeOpen;
    data['CurrentIndex'] = this.currentIndex;
    data['IsOpen'] = this.isOpen;
    data['IsEdit'] = this.isEdit;
    data['Propress'] = this.propress;
    data['isDownloadSuccess'] = this.isDownloadSuccess;
    data['Status'] = this.status;
     data['IsNew'] = this.isNew;
    return data;
  }
}
