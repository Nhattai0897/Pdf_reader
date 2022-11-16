import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;


abstract class NetworkDataSource {
  Future<NetWorkResult> get(
      String url, {
        Map<String, String> headers,
      });

  Future<NetWorkResult> post(
      Uri url, {
        Map<String, String> headers,
        Map<String, String> body,
      });
}

class RemoteDataSourceException extends HttpException {
  final int statusCode;

  RemoteDataSourceException(this.statusCode, String message) : super(message);

  @override
  String toString() =>
      'RemoteDataSourceException{statusCode=$statusCode, message=$message}';
}

class NetWorkResult {
  final ENetWorkStatus? status;
  final dynamic dataResult;
  final String? ErrorMessages;

  NetWorkResult({this.status, this.dataResult, this.ErrorMessages});
}

enum ENetWorkStatus {
  Successful,
  Error,
  UnConnectInternet,
  Timeout,
  Authentication,
}

class NetworkResponse extends NetworkDataSource {
  var isInternetCheck;
  final timeLimit = 10;

  Future<NetWorkResult> get(
    String url, {
    Map<String, String>? headers,
  }) async =>
      _helper(
        'GET',
        Uri.parse(url),
        headers: headers!,
      );

  Future<NetWorkResult> post(
    Uri url, {
    Map<String, String>? headers,
    Map<String, String>? body,
  }) async =>
      _helper(
        'POST',
        url,
        headers: headers!,
        body: body!,
      );

  Future<NetWorkResult> _helper(
    String method,
    Uri url, {
    Map<String, String>? headers,
    Map<String, String>? body,
  }) async {
    try {
      internetConnectionChecking().then((isConnect) {
        if (!isConnect) {
          // return null;
          return NetWorkResult(
              dataResult: null,
              ErrorMessages: "Not Connect Internet",
              status: ENetWorkStatus.UnConnectInternet);
        }
      });

      final request = http.Request(method, url);
      if (body != null) {
        request.bodyFields = body;
      }
      if (headers != null) {
        request.headers.addAll(headers);
      }

      var streamedResponse =
          await request.send();

      var statusCode = streamedResponse.statusCode;
      if (statusCode != 200) {
        // throw RemoteDataSourceException(statusCode, decoded['message']);
        return NetWorkResult(
            dataResult: null,
            ErrorMessages: "Lỗi",
            status: ENetWorkStatus.Error);
      }

      final decoded =
          json.decode(await streamedResponse.stream.bytesToString());
      // return decoded;
      return NetWorkResult(
          dataResult: decoded,
          ErrorMessages: null,
          status: ENetWorkStatus.Successful);
    } on http.ClientException catch (e) {
      return NetWorkResult(
          dataResult: null,
          ErrorMessages: e.message,
          status: ENetWorkStatus.Error);
    } on TimeoutException catch (e) {
      return NetWorkResult(
          dataResult: null,
          ErrorMessages: e.message,
          status: ENetWorkStatus.Error);
    } catch (e) {
      return NetWorkResult(
          dataResult: null,
          ErrorMessages: e.toString(),
          status: ENetWorkStatus.Error);
    }
  }

  ///@TaiNguyen 2020-11-08: check internet connection
  Future<bool> internetConnectionChecking() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }
}
