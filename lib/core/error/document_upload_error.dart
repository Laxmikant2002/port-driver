import 'package:equatable/equatable.dart';

/// {@template document_upload_error}
/// Base class for all document upload related errors.
/// {@endtemplate}
abstract class DocumentUploadError extends Equatable {
  /// {@macro document_upload_error}
  const DocumentUploadError({
    required this.message,
    this.code,
    this.details,
  });

  /// Error message
  final String message;

  /// Error code
  final String? code;

  /// Additional error details
  final Map<String, dynamic>? details;

  @override
  List<Object?> get props => [message, code, details];
}

/// {@template file_not_found_error}
/// Error thrown when a file is not found.
/// {@endtemplate}
class FileNotFoundError extends DocumentUploadError {
  /// {@macro file_not_found_error}
  const FileNotFoundError({
    required String filePath,
  }) : super(
          message: 'File not found: $filePath',
          code: 'FILE_NOT_FOUND',
          details: {'filePath': filePath},
        );
}

/// {@template file_size_error}
/// Error thrown when file size exceeds limit.
/// {@endtemplate}
class FileSizeError extends DocumentUploadError {
  /// {@macro file_size_error}
  const FileSizeError({
    required int actualSize,
    required int maxSize,
  }) : super(
          message: 'File size exceeds limit. Max: ${maxSize ~/ 1024}KB, Actual: ${actualSize ~/ 1024}KB',
          code: 'FILE_SIZE_EXCEEDED',
          details: {'actualSize': actualSize, 'maxSize': maxSize},
        );
}

/// {@template file_format_error}
/// Error thrown when file format is not supported.
/// {@endtemplate}
class FileFormatError extends DocumentUploadError {
  /// {@macro file_format_error}
  const FileFormatError({
    required String fileName,
    required List<String> supportedFormats,
  }) : super(
          message: 'Unsupported file format. Supported: ${supportedFormats.join(', ')}',
          code: 'UNSUPPORTED_FORMAT',
          details: {'fileName': fileName, 'supportedFormats': supportedFormats},
        );
}

/// {@template network_error}
/// Error thrown when network operation fails.
/// {@endtemplate}
class NetworkError extends DocumentUploadError {
  /// {@macro network_error}
  const NetworkError({
    required String message,
    this.statusCode,
  }) : super(
          message: message,
          code: 'NETWORK_ERROR',
          details: {'statusCode': statusCode},
        );

  /// HTTP status code if available
  final int? statusCode;
}

/// {@template upload_failed_error}
/// Error thrown when document upload fails.
/// {@endtemplate}
class UploadFailedError extends DocumentUploadError {
  /// {@macro upload_failed_error}
  const UploadFailedError({
    required String message,
    this.retryable = true,
  }) : super(
          message: message,
          code: 'UPLOAD_FAILED',
          details: {'retryable': retryable},
        );

  /// Whether the upload can be retried
  final bool retryable;
}

/// {@template validation_error}
/// Error thrown when document validation fails.
/// {@endtemplate}
class ValidationError extends DocumentUploadError {
  /// {@macro validation_error}
  const ValidationError({
    required String message,
    required String field,
  }) : super(
          message: message,
          code: 'VALIDATION_ERROR',
          details: {'field': field},
        );

  /// The field that failed validation
  String get field => details?['field'] as String? ?? 'unknown';
}

/// {@template document_upload_error_handler}
/// Utility class for handling document upload errors.
/// {@endtemplate}
class DocumentUploadErrorHandler {
  /// Maximum file size in bytes (5MB)
  static const int maxFileSize = 5 * 1024 * 1024;

  /// Supported image formats
  static const List<String> supportedFormats = ['jpg', 'jpeg', 'png', 'pdf'];

  /// Validates file before upload
  static DocumentUploadError? validateFile(String filePath, String fileName) {
    // Check file format
    final extension = fileName.split('.').last.toLowerCase();
    if (!supportedFormats.contains(extension)) {
      return FileFormatError(
        fileName: fileName,
        supportedFormats: supportedFormats,
      );
    }

    // Note: File size validation would require reading the file
    // This should be done in the UI layer before calling the BLoC
    return null;
  }

  /// Converts generic exceptions to DocumentUploadError
  static DocumentUploadError handleException(dynamic exception) {
    if (exception is DocumentUploadError) {
      return exception;
    }

    if (exception.toString().contains('File not found')) {
      return const FileNotFoundError(filePath: 'unknown');
    }

    if (exception.toString().contains('network') || 
        exception.toString().contains('connection')) {
      return NetworkError(message: exception.toString());
    }

    return UploadFailedError(
      message: exception.toString(),
      retryable: true,
    );
  }

  /// Gets user-friendly error message
  static String getUserFriendlyMessage(DocumentUploadError error) {
    switch (error.runtimeType) {
      case FileNotFoundError:
        return 'The selected file could not be found. Please try selecting another file.';
      case FileSizeError:
        return 'The file is too large. Please select a file smaller than 5MB.';
      case FileFormatError:
        return 'This file format is not supported. Please select a JPG, PNG, or PDF file.';
      case NetworkError:
        return 'Network error. Please check your internet connection and try again.';
      case UploadFailedError:
        return 'Upload failed. Please try again.';
      case ValidationError:
        return error.message;
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
