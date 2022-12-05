// import 'dart:typed_data';

// class MediaModel {
//   final String? pathFile;
//   final String? urlFile;
//   final Uint8List? uint8list;
//   final bool? isLoading;
//   final bool? isShow;
//   final String? typeFile;
//   final bool? isCurrent;

//   const MediaModel(
//       {this.pathFile,
//       this.urlFile,
//       this.isLoading,
//       this.isShow,
//       this.typeFile,
//       this.uint8list,
//       this.isCurrent});

//   MediaModel copyWith(
//           {pathFile, urlFile, isLoading, isShow, typeFile, uint8list}) =>
//       MediaModel(
//           pathFile: pathFile ?? this.pathFile,
//           urlFile: urlFile ?? this.urlFile,
//           isLoading: isLoading ?? this.isLoading,
//           isShow: isShow ?? this.isShow,
//           typeFile: typeFile ?? this.typeFile,
//           uint8list: uint8list ?? this.uint8list,
//           isCurrent: isCurrent ?? this.isCurrent);

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['FileID'] = "";
//     data['FileName'] = this.pathFile!.split("/").last;
//     data['FilePath'] = "";
//     data['IsUpload'] = "true";
//     data['UrlFile'] = this.urlFile;
//     return data;
//   } 

//   // @override
//   // List<Object> get props =>
//   //     [pathFile.toString(), urlFile.toString(), isLoading, isShow, typeFile.toString(), uint8list.toString(), isCurrent];
// }

// class TepDinhKems {
//   String? fileID;
//   String? fileName;
//   String? filePath;
//   String? isUpload;
//   String? urlFile;

//   TepDinhKems(
//       {this.fileID, this.fileName, this.filePath, this.isUpload, this.urlFile});

//   TepDinhKems.fromJson(Map<String, dynamic> json) {
//     fileID = json['FileID'];
//     fileName = json['FileName'];
//     filePath = json['FilePath'];
//     isUpload = json['IsUpload'];
//     urlFile = json['UrlFile'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['FileID'] = this.fileID;
//     data['FileName'] = this.fileName;
//     data['FilePath'] = this.filePath;
//     data['IsUpload'] = this.isUpload;
//     data['UrlFile'] = this.urlFile;
//     return data;
//   }
// }
