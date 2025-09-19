import 'dart:io';
import 'package:api_client/src/models/data_state.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// Modern API Client with proper error handling, interceptors, and typed responses
class ApiClient {
  final Dio _dio;
  final String baseUrl;
  String? _authToken;

  ApiClient({
    required this.baseUrl,
    Dio? dio,
    String? authToken,
  }) : _dio = dio ?? Dio(), _authToken = authToken {
    _setupDio();
  }

  void _setupDio() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      validateStatus: (status) => status != null && status < 500,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    );

    // Add request interceptor for auth token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          // Log errors for debugging
          print('API Error: ${error.message ?? error.toString()}');
          handler.next(error);
        },
      ),
    );

    // Add logging interceptor for development
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => print(object),
      ),
    );
  }

  /// Update auth token
  void updateAuthToken(String? token) {
    _authToken = token;
  }

  /// Clear auth token
  void clearAuthToken() {
    _authToken = null;
  }

  /// GET request with proper error handling
  Future<DataState<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return DataSuccess<T>(response.data);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return DataFailed<T>(
        DataError(null, 'Unexpected error: ${e.toString()}'),
      );
    }
  }

  /// POST request with proper error handling
  Future<DataState<T>> post<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return DataSuccess<T>(response.data);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return DataFailed<T>(
        DataError(null, 'Unexpected error: ${e.toString()}'),
      );
    }
  }

  /// PUT request with proper error handling
  Future<DataState<T>> put<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return DataSuccess<T>(response.data);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return DataFailed<T>(
        DataError(null, 'Unexpected error: ${e.toString()}'),
      );
    }
  }

  /// DELETE request with proper error handling
  Future<DataState<T>> delete<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return DataSuccess<T>(response.data);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return DataFailed<T>(
        DataError(null, 'Unexpected error: ${e.toString()}'),
      );
    }
  }

  /// File upload with proper error handling
  Future<DataState<T>> uploadFile<T>(
    String path, {
    required File file,
    required String fieldName,
    Map<String, dynamic>? additionalFields,
    Map<String, String>? headers,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(file.path),
        ...?additionalFields,
      });

      final response = await _dio.post(
        path,
        data: formData,
        options: Options(headers: headers),
      );

      return DataSuccess<T>(response.data);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return DataFailed<T>(
        DataError(null, 'Upload error: ${e.toString()}'),
      );
    }
  }

  /// Handle Dio exceptions with proper error mapping
  DataState<T> _handleDioError<T>(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;
    
    String errorMessage = 'An error occurred';
    
    if (responseData is Map<String, dynamic>) {
      errorMessage = responseData['message'] ?? 
                    responseData['error'] ?? 
                    error.message ?? 
                    'Request failed';
    } else if (error.message != null) {
      errorMessage = error.message!;
    }

    // Map specific status codes to user-friendly messages
    switch (statusCode) {
      case 400:
        errorMessage = 'Invalid request. Please check your input.';
        break;
      case 401:
        errorMessage = 'Authentication failed. Please login again.';
        break;
      case 403:
        errorMessage = 'Access denied. You don\'t have permission.';
        break;
      case 404:
        errorMessage = 'Resource not found.';
        break;
      case 422:
        errorMessage = 'Validation failed. Please check your input.';
        break;
      case 500:
        errorMessage = 'Server error. Please try again later.';
        break;
      case 502:
      case 503:
      case 504:
        errorMessage = 'Service temporarily unavailable. Please try again later.';
        break;
    }

    return DataFailed<T>(
      DataError(statusCode, errorMessage),
    );
  }

  /// Close the Dio instance
  void close() {
    _dio.close();
  }
}