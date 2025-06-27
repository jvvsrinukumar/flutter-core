import 'dart:convert';
import 'dart:io';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_core/core/cloud_logging.dart';
import 'package:flutter_core/core/framework/api_response_model.dart';
import 'package:flutter_core/core/framework/server_error.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';

import 'api_request_model.dart';

final logService = LogService(
  'APIRequestService',
  Level.error, // Set the log level as per your requirement
);

abstract class APIRequestService<T extends ApiRequestModel,
    U extends ApiResponseModel> {
  Future<Either<ServerError, U>> request({
    required String scheme,
    required String hostUrl,
    required String apiUrlEndPoint,
    T? requestModel,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? pathParameters,
    required HttpMethod httpMethod,
  }) async {
    try {
      if (pathParameters?.isNotEmpty ?? false) {
        for (var entry in pathParameters!.entries) {
          if (apiUrlEndPoint.contains(entry.key)) {
            apiUrlEndPoint =
                apiUrlEndPoint.replaceAll(entry.key, entry.value.toString());
          }
        }
        apiUrlEndPoint = apiUrlEndPoint.replaceAll('{', '');
        apiUrlEndPoint = apiUrlEndPoint.replaceAll('}', '');
      }
      Uri requestUri = Uri.https(
        hostUrl,
        apiUrlEndPoint,
        queryParameters,
      );

      if (scheme == "http") {
        requestUri = Uri.http(
          hostUrl,
          apiUrlEndPoint,
          queryParameters,
        );
      }
      logService.info(message: 'Actual URI $requestUri');
      logService.info(message: 'HTTP METHOD $httpMethod');

      var json = {};
      if (requestModel != null) {
        json = requestModel.toJson();
        if (kDebugMode) {
          print(json);
        }
      }

      Response? response;
      switch (httpMethod) {
        case HttpMethod.post:
          response = await post(
            requestUri,
            body: jsonEncode(json),
            headers: _setHeaders(),
          );
          logService.info(
              message:
                  'Response Code ${response.statusCode} calling API:$apiUrlEndPoint using ${httpMethod.name}');
          //TODO Check what APIs return 201 when using POST
          if (response.statusCode == 201) {
            final data = response.body;
            return Right(parseAPIResponse(data));
          }
          if (response.statusCode == 200) {
            final data = response.body;
            return Right(parseAPIResponse(data));
          }
          break;
        case HttpMethod.get:
          response = await get(
            requestUri,
            headers: _setHeaders(),
          );
          logService.info(
              message:
                  'Response Code ${response.statusCode} calling API:$apiUrlEndPoint using ${httpMethod.name}');
          if (response.statusCode == 200) {
            final data = response.body;
            return Right(parseAPIResponse(data));
          }
          break;
        case HttpMethod.delete:
          // TODO: Handle this case.
          break;
        case HttpMethod.patch:
          response = await patch(
            requestUri,
            body: jsonEncode(json),
            headers: _setHeaders(),
          );
          logService.info(
              message:
                  'Response Code ${response.statusCode} calling API:$apiUrlEndPoint using ${httpMethod.name}');
          if (response.statusCode == 201) {
            final data = response.body;
            return Right(parseAPIResponse(data));
          }
          if (response.statusCode == 200) {
            final data = response.body;
            return Right(parseAPIResponse(data));
          }
          break;
        case HttpMethod.put:
          response = await put(
            requestUri,
            body: jsonEncode(json),
            headers: _setHeaders(),
            //headers:  HeaderResolver.resolve(hostUrl),
          );
          logService.info(
              message:
                  'Response Code ${response.statusCode} calling API:$apiUrlEndPoint using ${httpMethod.name}');
          if (response.statusCode == 201) {
            final data = response.body;
            return Right(parseAPIResponse(data));
          }
          //TODO Check what APIs return 200 when using POST
          if (response.statusCode == 200) {
            final data = response.body;
            return Right(parseAPIResponse(data));
          }
          break;
      }

      logService.error(
          message:
              'Invalid Response Code: ${response?.statusCode} and message: ${response!.body.toString()} calling API:$apiUrlEndPoint using ${httpMethod.name}');
      return Left(ServerError(
        message: response.body.toString(),
        code: response.statusCode.toString(),
      ));
    } on HttpException catch (e) {
      logService.error(
          message:
              'HttpException calling API:$apiUrlEndPoint. Error:  ${e.message}');
      return Left(ServerError(message: 'HTTP Exception', code: "101"));
    } on SocketException catch (e) {
      logService.error(
          message:
              'SocketException calling API:$apiUrlEndPoint. Error:  ${e.message}');
      return Left(ServerError(message: 'No Internet Connection', code: "101"));
    } on FormatException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      logService.error(
          message:
              'FormatException calling API:$apiUrlEndPoint. Error:  ${e.message}');
      return Left(ServerError(message: 'Invalid Format', code: "102"));
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Exception calling API:$apiUrlEndPoint. Error:  ${e.toString()}');
      }
      logService.error(
          message:
              'Exception calling API:$apiUrlEndPoint. Error:  ${e.toString()}');
      return Left(ServerError(message: 'Unknown Exception', code: "103"));
    }
  }

  _setHeaders() => {
        // 'Access-Control-Allow-Origin': '*',
        // 'Access-Control-Allow-Methods': 'POST, GET, OPTIONS, DELETE, PUT',
        // 'Access-Control-Allow-Headers':
        //     'origin, x-requested-with, content-type, X-API-Key, X-App-ID',
        'Content-type': 'application/json',
        'Accept': 'application/json'
      };

  U parseAPIResponse(String data);
}

enum HttpMethod {
  get,
  post,
  delete,
  put,
  patch,
}

class HeaderResolver {
  static Map<String, String> resolve(String hostUrl) {
    if (hostUrl.contains('auth.example.com')) {
      return {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer someAuthToken',
      };
    } else if (hostUrl.contains('version.example.com')) {
      return {
        'Content-Type': 'application/json',
        // 'X-API-Key': EnvironmentConfig.apiKey,
      };
    } else {
      return {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
    }
  }
}
