import 'dart:io';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class FileLocalResponse {
  @override
  Future<String?> getPathLocal(
      {EPathType? ePathType, String? configPathStr, String? subPathStr}) async {
    Directory? pathDir;
    try {
      if (ePathType == EPathType.Storage) {
        if (Platform.isAndroid) {
          pathDir = (await getExternalStorageDirectories())!.first;
        } else if (Platform.isIOS) {
          pathDir = await getApplicationDocumentsDirectory();
        }
      } else {
        if (Platform.isAndroid) {
          pathDir = (await getExternalCacheDirectories())!.first;
        } else if (Platform.isIOS) {
          pathDir = await getTemporaryDirectory();
        }
      }
      if (pathDir != null) {
        if (subPathStr != null) {
          //Nếu truyền thêm thư mục nhỏ hơn
          Directory directoryNew =
              Directory('${pathDir.path}/$configPathStr/$subPathStr/');
          if (!await directoryNew.exists())
            await directoryNew.create(recursive: true);
          return directoryNew.path;
        } else {
          Directory directoryNew = Directory('${pathDir.path}/$configPathStr/');
          if (!await directoryNew.exists())
            await directoryNew.create(recursive: true);
          return directoryNew.path;
        }
      }
      return null;
    } catch (error) {
      print('error: $error');
      return null;
    }
  }

  @override
  Future<String?> downloadFiles(
    String? url,
    String? fileID,
    String? loaiFile,
    String? userID,
    String? donViID,
    String? fileName, {
    Function(int, int)? showDownloadProgress,
    bool isSumBaseUrl = false,
    String? pathStr,
  }) async {
    var dio = new Dio();
    dio.interceptors.add(LogInterceptor());

    try {
      Response response;
      final Map<String, dynamic> data = new Map<String, dynamic>();
      data['fileID'] = fileID ?? "";
      data['loaiFile'] = loaiFile ?? "";
      data['userID'] = userID ?? "0";
      data['donViID'] = donViID ?? "0";
      data['fileName'] = fileName ?? "";
      response = await dio.post(
        url!,
        data: data,
        onReceiveProgress: showDownloadProgress,
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            contentType: Headers.formUrlEncodedContentType,
            //headers: paramHeader,
            receiveTimeout: 30000),
      );
      String? tempPath = await getPathLocal(
        ePathType: EPathType.Storage,
        configPathStr: pathStr.toString(),
      );

      File file = new File("$tempPath$fileName");

      file.writeAsBytesSync(response.data);

      return file.path;
    } catch (e) {
      print('downloadFiles $e');
      return null;
    }
  }

  Future<ResultType?> openFile(String savePath) async {
    try {
      //print('savePath: $savePath');
      var resultType = await OpenFile.open(savePath);
      if (resultType.type == ResultType.done) {
      } else if (resultType.type == ResultType.noAppToOpen) {
        return ResultType.noAppToOpen;
      } else if (resultType.type == ResultType.error) {
        return ResultType.error;
      }
    } catch (error) {
      throw (error);
    }
  }

  Future<String?> checkFileExist(
      String? fileName, String? configPathStr) async {
    if (fileName == null) {
      return null;
    } else {
      String? tempPath = await getPathLocal(
        ePathType: EPathType.Storage,
        configPathStr: "vanban",
      );

      ///storage/emulated/0/Android/data/tech.vietinfo.tpthuduccongchuc/files/vanban/FILE_20220803_154832_NhiemVu_VPHU-TM-411-2022.pdf
      try {
        var savePath = '$tempPath$fileName';
        if (await File(savePath).exists()) {
          print('check r thì thấy path đã tồn tại');
          return savePath;
        } else {
          print('check r thì thấy path chưa tồn tại');
          return null;
        }
      } catch (e) {
        print('checkFileExist $e');
      }
    }
  }
}

enum EPathType { cache, Storage }
