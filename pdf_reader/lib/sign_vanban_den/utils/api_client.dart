import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:package_info/package_info.dart'; 

String? authenToken;

class ApiClient {
  late Dio _dio;

  final String? apiBaseUrl = 'url fake';

  Future<Dio> getDio() async {
    bool isShowLog = true;

    var options = new BaseOptions(
        connectTimeout: 15000,
        receiveTimeout: 10000,
        baseUrl: apiBaseUrl!,
        contentType: Headers.formUrlEncodedContentType);

    _dio = new Dio(options);
    _dio.interceptors.add(AuthInterceptor(_dio)); // token

    _dio.interceptors
        .add(LogInterceptor(responseBody: isShowLog, requestBody: isShowLog));

    //thêm https  setHttpsPEM(),etHttpsPKCS12()
    //  setFindProxy()
    return _dio;
  }
}

class AuthInterceptor extends Interceptor {
  String PLATFORM = "android";

  final Dio dio;

  AuthInterceptor(this.dio);

  @override
  onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String version = packageInfo.version;
    if (Platform.isIOS) {
      PLATFORM = "ios";
    } else if (Platform.isAndroid) {
      PLATFORM = "android";
    } else if (Platform.isWindows) {
      PLATFORM = "Windows";
    } else if (Platform.isMacOS) {
      PLATFORM = "macos";
    } else if (Platform.isLinux) {
      PLATFORM = "Linux";
    }

    Map<String, String> headers = new Map();
    headers["Accept-Charset"] = "utf-8";
    headers["Connection"] = "keep-alive";
    headers["Accept"] = "*/*";
    headers["x-version"] = version;
    headers["x-platform"] = PLATFORM;

    /// setting authentication token -> khi cần thì mở ra
    String token = authenToken!;
    if (null != token && token.isNotEmpty) {
      headers[HttpHeaders.authorizationHeader] = "Bearer $token";
    } else {
      var dataToken = await getTokenFromServer(headers);
      if (dataToken != null) {
        var token = dataToken;
        headers[HttpHeaders.authorizationHeader] = "Bearer $token";
      }
    }
    options.headers = headers;
    return super.onRequest(options, handler);
  }

  @override
  onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    Response? responseRetry = await scheduleRequestRetry(response);
    return super.onResponse(responseRetry!, handler);
  }

  @override
  onError(
    DioError err,
    ErrorInterceptorHandler handler,
  ) async {
    Response? response = await scheduleRequestRetry(err.response!);
    if (response != null && response.statusCode == 200) {
      handler.resolve(response);
    }
    return super.onError(err, handler);
  }

  Future<Response?> scheduleRequestRetry(Response response) async {
    if (response != null && response.statusCode == 401) {
      var dataToken = await getTokenFromServer(response.requestOptions.headers);
      if (dataToken != null) {
        /// retry request
        try {
          var responseRetry = await dio.fetch(response.requestOptions);
          return responseRetry;
        } catch (e) {
          return null;
        }
      }
    }
    return response;
  }

  // Future<String> getTokenFromServer() async {
  //   String userName = AppSettings.getValue(KeyAppSetting.userName);
  //   String secretKey = await getSecretKeyByClientId(userName);
  //
  //   Map<String, String> bodys = {
  //     'grant_type': 'client_credentials',
  //     'client_id': userName,
  //     'client_secret': secretKey,
  //   };
  //
  //   try {
  //     var response = await Dio().fetch(RequestOptions(
  //         method: "POST",
  //         baseUrl: CoreGlobal.instance.apiBaseUrl,
  //         path: '/getToken',
  //         data: bodys,
  //         contentType: Headers.formUrlEncodedContentType));
  //
  //     if (response.statusCode == 200 && response.data != null) {
  //       String token = response.data["access_token"];
  //       authenToken = token;
  //       return token;
  //     }
  //   } on DioError catch (e) {
  //
  //
  //   }
  //   return null;
  // }

  Future<String?> getTokenFromServer(Map<String, dynamic> headers) async {
    String userName = 'ConfigData.getUsername';

    /// chưa đăng nhập không lấy token được
    if (userName == null) return null;

    String secretKey = await getSecretKeyByClientId(userName);

    Map<String, String> headersToken = {
      'grant_type': 'client_credentials',
      'client_id': userName,
      'client_secret': secretKey,
    };
    headers.addAll(headersToken);
    try {
      var response = await Dio().fetch(RequestOptions(
          method: "POST",
          baseUrl:  'URL fake',
          path: '/getToken',
          headers: headers,
          contentType: Headers.formUrlEncodedContentType));

      if (response.statusCode == 200 && response.data != null) {
        String token = response.data["access_token"];
        authenToken = token;
        return token;
      }
    } on DioError catch (e) {}
    return null;
  }

  Future<String> getSecretKeyByClientId(String userName) async {
    String secretSubString = "Viet_Info";
    String secretKey = "$userName@$secretSubString";
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    return stringToBase64.encode(secretKey);
    //
    // String secretSubString = "Viet_Info_Quan10_QuanLyDoThi_Key";
    // String secretKey = "$userName@$secretSubString";
    // try {
    //   final key = Key.fromUtf8(secretSubString);
    //   final iv = IV.fromLength(16);
    //   final encrypter =
    //   Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));
    //   final encrypted = encrypter.encrypt(secretKey, iv: iv);
    //   //final decrypted = encrypter.decrypt(encrypted, iv: iv);
    //   return encrypted.base64;
    // } catch (e) {
    //   print(e);
    // }
    // return "";
  }
}
