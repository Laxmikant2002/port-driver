import 'dart:io';
import 'package:api_client/src/models/data_state.dart';
import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;
  final String baseUrl;

  ApiClient({
    required this.baseUrl,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      validateStatus: (status) => status != null && status < 400,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      connectTimeout: const Duration(seconds: 5),
    );
  }

  Future<DataState<T>> getReq<T>(
    String path, {
    String? token,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final options = Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      final response = await _dio.get(
        path,
        options: options,
        queryParameters: queryParameters,
      );

      return DataSuccess<T>(response.data);
    } on DioException catch (e) {
      return DataFailed<T>(
        DataError(
          e.response?.statusCode,
          e.response?.data ?? e.message,
        ),
      );
    } catch (e) {
      return DataFailed<T>(
        DataError(null, e.toString()),
      );
    }
  }

  Future<DataState<T>> postReq<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    dynamic bodyJson, // Change type to dynamic to allow FormData
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        queryParameters: queryParameters,
        data: bodyJson, // Pass FormData or Map<String, dynamic>
      );

      if (response.statusCode == 200) {
        return DataSuccess<T>(response.data);
      } else {
        return DataFailed<T>(
          DataError(response.statusCode, response.data),
        );
      }
    } catch (e) {
      return DataFailed<T>(
        DataError(null, e.toString()),
      );
    }
  }

  Future<DataState<T>> putReq<T>(String path, {Map<String, dynamic>? bodyJson}) async {
    try {
      final response = await _dio.put(path, data: bodyJson);
      return DataSuccess<T>(response.data);
    } catch (e) {
      return DataFailed<T>(
        DataError(null, e.toString()),
      );
    }
  }

  Future<DataState<T>> uploadFile<T>(String path, {required File file, required String type}) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
        'type': type,
      });

      final response = await _dio.post(path, data: formData);
      return DataSuccess<T>(response.data);
    } catch (e) {
      return DataFailed<T>(
        DataError(null, e.toString()),
      );
    }
  }
}