// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:module_van_ban/digital_sign/sign_vanban_den/model/mau_chu_ky_so_model.dart';
// import 'package:module_van_ban/digital_sign/sign_vanban_den/utils/api_client.dart';
// // import 'package:module_van_ban/ky_ten/utils/networks/network_response.dart';
// import 'package:vietinfo_dev_core/vietinfo_dev_core.dart';
// import 'package:module_van_ban/module_van_ban.dart';

class ViewFileApi {
  // late NetworkDataSource network;
  // late ApiClient apiClient;
  // ViewFileApi() {
  //   network = NetworkResponse();
  //   apiClient = ApiClient();
  // }

  // Future<http.ByteStream?> postChuKy(
  //     int pageIndex,
  //     double x,
  //     double y,
  //     double width,
  //     double height,
  //     int loaiChuKy,
  //     double widthPage,
  //     double heightPage,
  //     String fileKyTen,
  //     double ratio,
  //     File? mauChuKyFile,
  //     String sdtKySo,
  //     int mauChuKySoID,
  //     String fullPathFile) async {
  //   try {
  //     var postUri = Uri.parse(ConfigData.BASE_URL! + "/ChuKySo/GuiChuKy");
  //     var request = new http.MultipartRequest("POST", postUri);
  //     request.fields['PageIndex'] = pageIndex.toString();
  //     request.fields['CoordinateX'] = x.toString();
  //     request.fields['CoordinateY'] = y.toString();
  //     request.fields['Width'] = width.toString();
  //     request.fields['Height'] = height.toString();
  //     request.fields['LoaiChuKy'] = loaiChuKy.toString();
  //     request.fields['WidthPage'] = widthPage.toString();
  //     request.fields['HeightPage'] = heightPage.toString();
  //     request.fields['FileName'] = fileKyTen;
  //     request.fields['UserID'] = ConfigData.getUserID() ?? "";
  //     request.fields['SdtKySo'] = sdtKySo;
  //     request.fields['MauChuKySoID'] = mauChuKySoID.toString();
  //     request.fields['FullPathFile'] = fullPathFile.toString();
  //     print("FullPathFile: $fullPathFile");

  //     Uri uri = Uri(path: mauChuKyFile!.path);
  //     request.files.add(new http.MultipartFile.fromBytes(
  //         'file', await File.fromUri(uri).readAsBytes(),
  //         filename: mauChuKyFile.path.split("/").last));
  //     http.StreamedResponse streamedResponse = await request.send();
  //     if (streamedResponse.statusCode == 200) {
  //       return streamedResponse.stream;
  //     } else {
  //       return null;
  //     }
  //   } catch (e) {
  //     print("loi get chu ky: $e");
  //     return null;
  //   }
  // }

  // Future<http.ByteStream?> postChuKyVanBannDi(
  //     bool isKyNhay,
  //     int pageIndex,
  //     double x,
  //     double y,
  //     double width,
  //     double height,
  //     int loaiChuKy,
  //     double widthPage,
  //     double heightPage,
  //     String fileKyTen,
  //     double ratio,
  //     File? mauChuKyFile,
  //     String signerName,
  //     String sdtKySo,
  //     int mauChuKySoID,
  //     String fullPathFile) async {
  //   try {
  //     var postUri = isKyNhay
  //         ? Uri.parse(ConfigData.BASE_URL! + "/ChuKySo/GuiChuKyNhay")
  //         : Uri.parse(ConfigData.BASE_URL! + "/ChuKySo/GuiChuKyThamQuyen");
  //     var request = new http.MultipartRequest("POST", postUri);
  //     request.fields['PageIndex'] = pageIndex.toString();
  //     request.fields['CoordinateX'] = x.toString();
  //     request.fields['CoordinateY'] = y.toString();
  //     request.fields['Width'] = width.toString();
  //     request.fields['Height'] = height.toString();
  //     request.fields['LoaiChuKy'] = loaiChuKy.toString();
  //     request.fields['WidthPage'] = widthPage.toString();
  //     request.fields['HeightPage'] = heightPage.toString();
  //     request.fields['FileName'] = fileKyTen;
  //     request.fields['UserID'] = ConfigData.getUserID() ?? "";
  //     request.fields['SdtKySo'] = sdtKySo;
  //     request.fields['SignerName'] = signerName;
  //     request.fields['MauChuKySoID'] = mauChuKySoID.toString();
  //     request.fields['FullPathFile'] = fullPathFile.toString();
  //    // print("FullPathFile: $fullPathFile");
  //    // print('Sizeable x: $x, y: $y');

  //     Uri uri = Uri(path: mauChuKyFile!.path);
  //     request.files.add(new http.MultipartFile.fromBytes(
  //         'file', await File.fromUri(uri).readAsBytes(),
  //         filename: mauChuKyFile.path.split("/").last));
  //     http.StreamedResponse streamedResponse = await request.send();
  //     if (streamedResponse.statusCode == 200) {
  //       return streamedResponse.stream;
  //     } else {
  //       return null;
  //     }
  //   } catch (e) {
  //     print("loi get chu ky: $e");
  //     return null;
  //   }
  // }

  // Future<http.ByteStream?> postReviewFile(
  //     int pageIndex,
  //     double x,
  //     double y,
  //     double width,
  //     double height,
  //     int loaiChuKy,
  //     double widthPage,
  //     double heightPage,
  //     String fileKyTen,
  //     double ratio,
  //     File? mauChuKyFile,
  //     String signerName,
  //     String sdtKySo,
  //     int mauChuKySoID,
  //     String fullPathFile) async {
  //   try {
  //     var postUri =
  //         Uri.parse(ConfigData.BASE_URL! + "/ChuKySo/PreviewSignBySingerName");
  //     var request = new http.MultipartRequest("POST", postUri);
  //     request.fields['PageIndex'] = pageIndex.toString();
  //     request.fields['CoordinateX'] = x.toString();
  //     request.fields['CoordinateY'] = y.toString();
  //     request.fields['Width'] = width.toString();
  //     request.fields['Height'] = height.toString();
  //     request.fields['LoaiChuKy'] = loaiChuKy.toString();
  //     request.fields['WidthPage'] = widthPage.toString();
  //     request.fields['HeightPage'] = heightPage.toString();
  //     request.fields['FileName'] = fileKyTen;
  //     request.fields['UserID'] = ConfigData.getUserID() ?? "";
  //     request.fields['SdtKySo'] = sdtKySo;
  //     request.fields['SignerName'] = signerName;
  //     request.fields['MauChuKySoID'] = mauChuKySoID.toString();
  //     request.fields['FullPathFile'] = fullPathFile.toString();
  //     print("FullPathFile: $fullPathFile");
  //     Uri uri = Uri(path: mauChuKyFile!.path);
  //     request.files.add(new http.MultipartFile.fromBytes(
  //         'file', await File.fromUri(uri).readAsBytes(),
  //         filename: mauChuKyFile.path.split("/").last));
  //     http.StreamedResponse streamedResponse = await request.send();
  //     if (streamedResponse.statusCode == 200) {
  //       return streamedResponse.stream;
  //     } else {
  //       return null;
  //     }
  //   } catch (e) {
  //     print("loi get chu ky: $e");
  //     return null;
  //   }
  // }

  // Future<http.ByteStream?> postKySoKhongSuDungMCK(
  //     String? path,
  //     String? filename,
  //     int mauChuKySoID,
  //     String sdtKySo,
  //     String fullPathFile) async {
  //   var postUri = Uri.parse(
  //       "${ConfigData.BASE_URL}/ChuKySo/ThucHienKySoKhongSuDungMauChuKy");
  //   var request = new http.MultipartRequest("POST", postUri);
  //   request.fields['UserID'] = ConfigData.getUserID() ?? '';
  //   request.fields['MauChuKySoID'] = mauChuKySoID.toString();
  //   request.fields['SdtKySo'] = sdtKySo.toString();
  //   request.fields['FullPathFile'] = fullPathFile.toString();
  //   print("FullPathFile: $fullPathFile");

  //   Uri uri = Uri(path: path);
  //   request.files.add(new http.MultipartFile.fromBytes(
  //       'filedata', await File.fromUri(uri).readAsBytes(),
  //       filename: filename));

  //   try {
  //     http.StreamedResponse streamedResponse = await request.send();
  //     if (streamedResponse.statusCode != 200) {
  //       return null;
  //     }
  //    // print(streamedResponse.stream.toString());
  //     return streamedResponse.stream;
  //   } catch (e) {
  //     print('Error postKySoKhongSuDungMCK: $e');
  //     return null;
  //   }
  // }

  // Future<List<MauChuKySoModel>?> getMauChuKySoByUserID(
  //     {required bool isUseMauChuKy}) async {
  //   try {
  //     var userId = ConfigData.getUserID();
  //     final url = ConfigData.BASE_URL! +
  //         "/MauChuKySo/GetMauChuKySoByUserID?userID=$userId";
  //     final result = await network.get(url);
  //     if (result != null && result.dataResult != null) {
  //       final datas = result.dataResult as List;
  //       List<MauChuKySoModel> list = [];
  //       List<MauChuKySoModel> listLoai1 = [];
  //       List<MauChuKySoModel> listLoai2 = [];

  //       list = datas.map((item) {
  //         return MauChuKySoModel.fromJson(item);
  //       }).toList();
  //       for (var item in list) {
  //         if (item.intLoaiChuKySo == 1) {
  //           listLoai1.add(item);
  //         } else if (item.intLoaiChuKySo == 2) {
  //           listLoai2.add(item);
  //         }
  //       }
  //       return isUseMauChuKy ? listLoai2 : listLoai1;
  //     }
  //     return null;
  //   } catch (ex) {
  //     print(ex);
  //     return null;
  //   }
  // }

  // Future<String?> getChuKyImage() async {
  //   try {
  //     var userId = ConfigData.getUserID();
  //     var userName = ConfigData.getUsername();
  //     final url = ConfigData.BASE_URL! +
  //         "/ChuKySo/GetUrlHinhChuKyByUserID/$userId/0/$userName";

  //     final result = await network.get(url);
  //     if (result.dataResult != null) {
  //       return result.dataResult["result"];
  //     }
  //     return null;
  //   } catch (ex) {
  //     print(ex);
  //     return null;
  //   }
  // }
}
