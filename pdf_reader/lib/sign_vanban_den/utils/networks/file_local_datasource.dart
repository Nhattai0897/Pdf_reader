// import 'dart:convert';
// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:module_van_ban/module_van_ban.dart';
// import 'package:open_file/open_file.dart';
// import 'package:path_provider/path_provider.dart';

// // abstract class FileLocalDataSource {
// //   Future<String> getPathLocal(
// //       {EPathType ePathType, String configPathStr, String subPathStr});

// //   Future<String> checkFileExist(String fileName, String configPathStr);

// //   Future<String> downloadFiles(
// //     String url,
// //     String fileName,
// //     String fileURL, {
// //     Function showDownloadProgress,
// //     bool isSumBaseUrl = false,
// //     String pathFolder = "",
// //     String pathStr,
// //   });
// //   Future<ResultType> openFile(String savePath);
// // }

// class FileLocalResponse  {
//   @override
//   Future<String> getPathLocal(
//       {EPathType ePathType, String configPathStr, String subPathStr}) async {
//     Directory pathDir;
//     try {
//       if (ePathType == EPathType.Storage) {
//         if (Platform.isAndroid) {
//           pathDir = (await getExternalStorageDirectories()).first;
//         } else if (Platform.isIOS) {
//           pathDir = await getApplicationDocumentsDirectory();
//         }
//       } else {
//         if (Platform.isAndroid) {
//           pathDir = (await getExternalCacheDirectories()).first;
//         } else if (Platform.isIOS) {
//           pathDir = await getTemporaryDirectory();
//         }
//       }
//       if (pathDir != null) {
//         if (subPathStr != null) {
//           //Nếu truyền thêm thư mục nhỏ hơn
//           Directory directoryNew =
//               Directory('${pathDir.path}/$configPathStr/$subPathStr/');
//           if (!await directoryNew.exists())
//             await directoryNew.create(recursive: true);
//           return directoryNew.path;
//         } else {
//           Directory directoryNew = Directory('${pathDir.path}/$configPathStr/');
//           if (!await directoryNew.exists())
//             await directoryNew.create(recursive: true);
//           return directoryNew.path;
//         }
//       }
//       return null;
//     } catch (error) {
//       print('error: $error');
//       return null;
//     }
//   }

//   @override
//   Future<String> downloadFiles(
//     String url,
//     String fileName,
//     String fileURL, {
//     Function showDownloadProgress,
//     bool isSumBaseUrl = false,
//     String pathFolder = "",
//     String pathStr,
//   }) async {
//     var dio = Dio();
//     dio.interceptors.add(LogInterceptor());

//     try {
//       Response response;
//       final Map<String, dynamic> data = new Map<String, dynamic>();
//       data['fileName'] = fileName ?? "";
//       data['fileURL'] = fileURL ?? "";
//        data['userID'] = ConfigData.getUserID();
//       data['LoaiFile'] = "QLVB";
//       data['DonViID'] = ConfigData.getDonViID() ?? "0"; //Test
      
//       response = await dio.post(
//         url, data: data,
//         onReceiveProgress: showDownloadProgress,
//         //Received data with List<int>
//         options: Options(
//             // responseType: ResponseType.json,
//             responseType: ResponseType.bytes,
//             followRedirects: false,
//             contentType: Headers.formUrlEncodedContentType,
//             //headers: paramHeader,
//             receiveTimeout: 0),
//       );
//       print('response: $response');

//       String tempPath = await getPathLocal(
//         ePathType: EPathType.Storage,
//         configPathStr: pathStr,
//       );
//       print('tempPath: $tempPath');

//       File file = new File("$tempPath$fileName");

//       // final xx = json.decode(response.toString());
//       // var xxxx = xx as Map<String, dynamic>;

//       //ConvertBase64 a = ConvertBase64.fromJson(xxxx);
//       //var bytes = base64.decode(response.data);

//       file.writeAsBytesSync(response.data);
//       print('file.path: ${file.path}');

//       return file.path;
//     } catch (e) {
//       print(e);
//       return null;
//     }
//   }

//   @override
//   Future<ResultType> openFile(String savePath) async {
//     try {
//       print('savePath: $savePath');
//       var resultType = await OpenFile.open(savePath);
//       if (resultType.type == ResultType.done) {
//         print('Mo ung dung thanh cong');
//       } else if (resultType.type == ResultType.noAppToOpen) {
//         print('resultType.type: ${resultType.type}');
//         //Navigator.pop(ctx);
//         print('Không có ứng dụng để mở');
//         return ResultType.noAppToOpen;
//       } else if (resultType.type == ResultType.error) {
//         print('Mở file bị lỗi');
//         return ResultType.error;
//       }
//     } catch (error) {
//       throw (error);
//     }
//   }

//   @override
//   Future<String> checkFileExist(String fileName, String configPathStr) async {
//     if (fileName == null) {
//     } else {
//       String tempPath = await getPathLocal(
//         ePathType: EPathType.Storage,
//         configPathStr: configPathStr,
//       );
//       var savePath = '${tempPath}${fileName}';
//       if (await File(savePath).exists()) {
//         print('check r thì thấy path đã tồn tại');
//         return savePath;
//       } else {
//         print('check r thì thấy path chưa tồn tại');
//         return null;
//       }
//     }
//   }
// }

// enum EPathType { cache, Storage }
