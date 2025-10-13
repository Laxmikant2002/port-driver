import 'dart:async';
import 'dart:io';
import 'dart:developer';
import 'package:api_client/src/models/data_state.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Modern API Client with proper error handling, interceptors, offline support, and performance optimization
class ApiClient {
  final Dio _dio;
  final String baseUrl;
  final Connectivity _connectivity;
  String? _authToken;
  String? _refreshToken;
  bool _isRefreshing = false;
  final List<Completer<void>> _refreshCompleters = [];
  final Map<String, DateTime> _requestTimestamps = {};
  final Map<String, int> _retryCounts = {};

  ApiClient({
    required this.baseUrl,
    required Connectivity connectivity,
    Dio? dio,
    String? authToken,
    String? refreshToken,
  }) : _dio = dio ?? Dio(), 
       _connectivity = connectivity,
       _authToken = authToken, 
       _refreshToken = refreshToken {
    _setupDio();
  }

  void _setupDio() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      validateStatus: (status) => status != null && status < 500,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'DriverApp/1.0.0',
      },
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      followRedirects: true,
      maxRedirects: 3,
    );

    // Add request interceptor for auth token and performance tracking
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          
          // Track request timestamp for performance monitoring
          final requestKey = '${options.method}_${options.path}';
          _requestTimestamps[requestKey] = DateTime.now();
          
          // Check connectivity before making request
          final connectivityResult = await _connectivity.checkConnectivity();
          if (connectivityResult.contains(ConnectivityResult.none)) {
            handler.reject(
              DioException(
                requestOptions: options,
                error: 'No internet connection',
                type: DioExceptionType.connectionError,
              ),
            );
            return;
          }
          
          handler.next(options);
        },
        onResponse: (response, handler) {
          // Track response time
          final requestKey = '${response.requestOptions.method}_${response.requestOptions.path}';
          final startTime = _requestTimestamps[requestKey];
          if (startTime != null) {
            final duration = DateTime.now().difference(startTime);
            log('API Request: ${response.requestOptions.path} took ${duration.inMilliseconds}ms');
            _requestTimestamps.remove(requestKey);
          }
          
          handler.next(response);
        },
        onError: (error, handler) async {
          // Handle 401 errors with token refresh
          if (error.response?.statusCode == 401 && _refreshToken != null) {
            try {
              await _handleTokenRefresh();
              // Retry the original request
              final options = error.requestOptions;
              if (_authToken != null) {
                options.headers['Authorization'] = 'Bearer $_authToken';
              }
              final response = await _dio.fetch(options);
              handler.resolve(response);
              return;
            } catch (refreshError) {
              // Refresh failed, clear tokens and continue with error
              _clearTokens();
              handler.next(error);
              return;
            }
          }
          
          // Handle retry logic for network errors
          if (_shouldRetry(error)) {
            final requestKey = '${error.requestOptions.method}_${error.requestOptions.path}';
            final retryCount = _retryCounts[requestKey] ?? 0;
            
            if (retryCount < 3) {
              _retryCounts[requestKey] = retryCount + 1;
              log('Retrying request ${retryCount + 1}/3 for ${error.requestOptions.path}');
              
              // Wait before retry (exponential backoff)
              await Future.delayed(Duration(seconds: retryCount + 1));
              
              try {
                final response = await _dio.fetch(error.requestOptions);
                _retryCounts.remove(requestKey);
                handler.resolve(response);
                return;
              } catch (retryError) {
                // Continue with original error if retry fails
              }
            }
          }
          
          // Log errors for debugging
          log('API Error: ${error.message ?? error.toString()}');
          handler.next(error);
        },
      ),
    );

    // Add logging interceptor for development
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: false, // Disable response body logging for performance
          logPrint: (object) => log(object.toString()),
        ),
      );
    }
  }

  /// Check if request should be retried
  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
           error.type == DioExceptionType.receiveTimeout ||
           error.type == DioExceptionType.connectionError ||
           (error.response?.statusCode != null && 
            error.response!.statusCode! >= 500);
  }

  /// Update auth token
  void updateAuthToken(String? token) {
    _authToken = token;
  }

  /// Update refresh token
  void updateRefreshToken(String? token) {
    _refreshToken = token;
  }

  /// Update both tokens
  void updateTokens({String? authToken, String? refreshToken}) {
    _authToken = authToken;
    _refreshToken = refreshToken;
  }

  /// Clear auth token
  void clearAuthToken() {
    _authToken = null;
  }

  /// Clear all tokens
  void _clearTokens() {
    _authToken = null;
    _refreshToken = null;
  }

  /// Handle token refresh
  Future<void> _handleTokenRefresh() async {
    if (_isRefreshing) {
      // If already refreshing, wait for it to complete
      final completer = Completer<void>();
      _refreshCompleters.add(completer);
      return completer.future;
    }

    _isRefreshing = true;

    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': _refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        _authToken = data['accessToken'];
        _refreshToken = data['refreshToken'];
        
        // Complete all waiting requests
        for (final completer in _refreshCompleters) {
          completer.complete();
        }
        _refreshCompleters.clear();
      } else {
        throw Exception('Token refresh failed');
      }
    } catch (e) {
      // Complete all waiting requests with error
      for (final completer in _refreshCompleters) {
        completer.completeError(e);
      }
      _refreshCompleters.clear();
      rethrow;
    } finally {
      _isRefreshing = false;
    }
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
        DataError(
          message: 'Unexpected error: ${e.toString()}',
          type: DataErrorType.unknown,
        ),
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
        DataError(
          message: 'Unexpected error: ${e.toString()}',
          type: DataErrorType.unknown,
        ),
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
        DataError(
          message: 'Unexpected error: ${e.toString()}',
          type: DataErrorType.unknown,
        ),
      );
    }
  }

  /// PATCH request with proper error handling
  Future<DataState<T>> patch<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.patch(
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
        DataError(
          message: 'Unexpected error: ${e.toString()}',
          type: DataErrorType.unknown,
        ),
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
        DataError(
          message: 'Unexpected error: ${e.toString()}',
          type: DataErrorType.unknown,
        ),
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
        DataError(
          message: 'Upload error: ${e.toString()}',
          type: DataErrorType.unknown,
        ),
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
      DataError(
        message: errorMessage,
        type: DataErrorType.server,
        statusCode: statusCode,
      ),
    );
  }

  /// Close the Dio instance
  void close() {
    _dio.close();
  }
}