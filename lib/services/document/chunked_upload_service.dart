import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

/// {@template chunked_upload_service}
/// Service for uploading documents in chunks with progress tracking.
/// {@endtemplate}
class ChunkedUploadService {
  /// {@macro chunked_upload_service}
  const ChunkedUploadService();

  /// Uploads a file in chunks with progress tracking
  Future<ChunkedUploadResult> uploadFileInChunks({
    required String filePath,
    required String uploadUrl,
    required Map<String, String> headers,
    int chunkSize = 1024 * 1024, // 1MB chunks
    Function(double progress)? onProgress,
    Function(String status)? onStatusUpdate,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return ChunkedUploadResult.failure('File not found: $filePath');
      }

      final fileSize = await file.length();
      final totalChunks = (fileSize / chunkSize).ceil();
      final fileName = path.basename(filePath);
      final uploadId = _generateUploadId();

      onStatusUpdate?.call('Preparing upload...');

      // Initialize upload session
      final initResult = await _initializeUpload(
        uploadUrl: uploadUrl,
        fileName: fileName,
        fileSize: fileSize,
        totalChunks: totalChunks,
        uploadId: uploadId,
        headers: headers,
      );

      if (!initResult.isSuccess) {
        return ChunkedUploadResult.failure(initResult.errorMessage!);
      }

      onStatusUpdate?.call('Starting upload...');

      // Upload chunks
      var uploadedBytes = 0;
      for (int chunkIndex = 0; chunkIndex < totalChunks; chunkIndex++) {
        final startByte = chunkIndex * chunkSize;
        final endByte = (startByte + chunkSize).clamp(0, fileSize);
        final chunkSizeActual = endByte - startByte;

        onStatusUpdate?.call('Uploading chunk ${chunkIndex + 1} of $totalChunks...');

        final chunkResult = await _uploadChunk(
          file: file,
          uploadUrl: uploadUrl,
          uploadId: uploadId,
          chunkIndex: chunkIndex,
          startByte: startByte,
          chunkSize: chunkSizeActual,
          headers: headers,
        );

        if (!chunkResult.isSuccess) {
          return ChunkedUploadResult.failure(chunkResult.errorMessage!);
        }

        uploadedBytes += chunkSizeActual;
        final progress = uploadedBytes / fileSize;
        onProgress?.call(progress);
      }

      // Finalize upload
      onStatusUpdate?.call('Finalizing upload...');
      final finalizeResult = await _finalizeUpload(
        uploadUrl: uploadUrl,
        uploadId: uploadId,
        headers: headers,
      );

      if (!finalizeResult.isSuccess) {
        return ChunkedUploadResult.failure(finalizeResult.errorMessage!);
      }

      onStatusUpdate?.call('Upload completed successfully!');
      return ChunkedUploadResult.success(
        uploadId: uploadId,
        fileName: fileName,
        fileSize: fileSize,
        totalChunks: totalChunks,
      );
    } catch (e) {
      return ChunkedUploadResult.failure('Upload failed: ${e.toString()}');
    }
  }

  /// Resumes a failed upload
  Future<ChunkedUploadResult> resumeUpload({
    required String uploadId,
    required String uploadUrl,
    required Map<String, String> headers,
    Function(double progress)? onProgress,
    Function(String status)? onStatusUpdate,
  }) async {
    try {
      onStatusUpdate?.call('Checking upload status...');

      // Get upload status
      final statusResult = await _getUploadStatus(
        uploadUrl: uploadUrl,
        uploadId: uploadId,
        headers: headers,
      );

      if (!statusResult.isSuccess) {
        return ChunkedUploadResult.failure(statusResult.errorMessage!);
      }

      final uploadStatus = statusResult.uploadStatus!;
      
      if (uploadStatus.isCompleted) {
        return ChunkedUploadResult.success(
          uploadId: uploadId,
          fileName: uploadStatus.fileName!,
          fileSize: uploadStatus.fileSize!,
          totalChunks: uploadStatus.totalChunks!,
        );
      }

      onStatusUpdate?.call('Resuming upload from chunk ${uploadStatus.completedChunks + 1}...');

      // Resume from where it left off
      final resumeResult = await _resumeFromChunk(
        uploadUrl: uploadUrl,
        uploadId: uploadId,
        completedChunks: uploadStatus.completedChunks,
        headers: headers,
        onProgress: onProgress,
        onStatusUpdate: onStatusUpdate,
      );

      return resumeResult;
    } catch (e) {
      return ChunkedUploadResult.failure('Resume failed: ${e.toString()}');
    }
  }

  /// Initializes upload session
  Future<ChunkedUploadResult> _initializeUpload({
    required String uploadUrl,
    required String fileName,
    required int fileSize,
    required int totalChunks,
    required String uploadId,
    required Map<String, String> headers,
  }) async {
    try {
      final initUrl = '$uploadUrl/init';
      final body = {
        'uploadId': uploadId,
        'fileName': fileName,
        'fileSize': fileSize.toString(),
        'totalChunks': totalChunks.toString(),
      };

      final response = await http.post(
        Uri.parse(initUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        return ChunkedUploadResult.success(uploadId: uploadId);
      } else {
        return ChunkedUploadResult.failure('Failed to initialize upload: ${response.body}');
      }
    } catch (e) {
      return ChunkedUploadResult.failure('Initialize failed: ${e.toString()}');
    }
  }

  /// Uploads a single chunk
  Future<ChunkedUploadResult> _uploadChunk({
    required File file,
    required String uploadUrl,
    required String uploadId,
    required int chunkIndex,
    required int startByte,
    required int chunkSize,
    required Map<String, String> headers,
  }) async {
    try {
      final chunkData = await file.openRead(startByte, startByte + chunkSize);
      final bytes = await chunkData.toList();
      final chunkBytes = bytes.expand((x) => x).toList();

      final chunkUrl = '$uploadUrl/chunk';
      final request = http.MultipartRequest('POST', Uri.parse(chunkUrl));
      
      request.headers.addAll(headers);
      request.fields['uploadId'] = uploadId;
      request.fields['chunkIndex'] = chunkIndex.toString();
      request.fields['chunkSize'] = chunkSize.toString();
      
      request.files.add(http.MultipartFile.fromBytes(
        'chunk',
        chunkBytes,
        filename: 'chunk_$chunkIndex',
      ));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return ChunkedUploadResult.success(uploadId: uploadId);
      } else {
        return ChunkedUploadResult.failure('Chunk upload failed: $responseBody');
      }
    } catch (e) {
      return ChunkedUploadResult.failure('Chunk upload error: ${e.toString()}');
    }
  }

  /// Finalizes the upload
  Future<ChunkedUploadResult> _finalizeUpload({
    required String uploadUrl,
    required String uploadId,
    required Map<String, String> headers,
  }) async {
    try {
      final finalizeUrl = '$uploadUrl/finalize';
      final body = {'uploadId': uploadId};

      final response = await http.post(
        Uri.parse(finalizeUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        return ChunkedUploadResult.success(uploadId: uploadId);
      } else {
        return ChunkedUploadResult.failure('Finalize failed: ${response.body}');
      }
    } catch (e) {
      return ChunkedUploadResult.failure('Finalize error: ${e.toString()}');
    }
  }

  /// Gets upload status
  Future<ChunkedUploadResult> _getUploadStatus({
    required String uploadUrl,
    required String uploadId,
    required Map<String, String> headers,
  }) async {
    try {
      final statusUrl = '$uploadUrl/status/$uploadId';

      final response = await http.get(
        Uri.parse(statusUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Parse response to get upload status
        // This would typically return JSON with upload status
        final uploadStatus = UploadStatus(
          uploadId: uploadId,
          isCompleted: true, // This would be parsed from response
          completedChunks: 0,
          totalChunks: 1,
          fileName: 'unknown',
          fileSize: 0,
        );
        
        return ChunkedUploadResult.success(uploadId: uploadId, uploadStatus: uploadStatus);
      } else {
        return ChunkedUploadResult.failure('Status check failed: ${response.body}');
      }
    } catch (e) {
      return ChunkedUploadResult.failure('Status check error: ${e.toString()}');
    }
  }

  /// Resumes upload from a specific chunk
  Future<ChunkedUploadResult> _resumeFromChunk({
    required String uploadUrl,
    required String uploadId,
    required int completedChunks,
    required Map<String, String> headers,
    Function(double progress)? onProgress,
    Function(String status)? onStatusUpdate,
  }) async {
    // Implementation would resume from completedChunks
    // This is a simplified version
    onStatusUpdate?.call('Resume functionality not fully implemented');
    return ChunkedUploadResult.failure('Resume not implemented');
  }

  /// Generates unique upload ID
  String _generateUploadId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp * 1000 + DateTime.now().microsecond) % 1000000;
    return 'upload_${timestamp}_$random';
  }
}

/// {@template chunked_upload_result}
/// Result of chunked upload operation.
/// {@endtemplate}
class ChunkedUploadResult {
  /// {@macro chunked_upload_result}
  const ChunkedUploadResult._({
    required this.isSuccess,
    this.uploadId,
    this.fileName,
    this.fileSize,
    this.totalChunks,
    this.uploadStatus,
    this.errorMessage,
  });

  final bool isSuccess;
  final String? uploadId;
  final String? fileName;
  final int? fileSize;
  final int? totalChunks;
  final UploadStatus? uploadStatus;
  final String? errorMessage;

  factory ChunkedUploadResult.success({
    required String uploadId,
    String? fileName,
    int? fileSize,
    int? totalChunks,
    UploadStatus? uploadStatus,
  }) {
    return ChunkedUploadResult._(
      isSuccess: true,
      uploadId: uploadId,
      fileName: fileName,
      fileSize: fileSize,
      totalChunks: totalChunks,
      uploadStatus: uploadStatus,
    );
  }

  factory ChunkedUploadResult.failure(String errorMessage) {
    return ChunkedUploadResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }

  bool get isFailure => !isSuccess;
}

/// {@template upload_status}
/// Status of chunked upload.
/// {@endtemplate}
class UploadStatus {
  /// {@macro upload_status}
  const UploadStatus({
    required this.uploadId,
    required this.isCompleted,
    required this.completedChunks,
    required this.totalChunks,
    required this.fileName,
    required this.fileSize,
  });

  final String uploadId;
  final bool isCompleted;
  final int completedChunks;
  final int totalChunks;
  final String fileName;
  final int fileSize;

  /// Upload progress percentage
  double get progress {
    if (totalChunks == 0) return 0.0;
    return completedChunks / totalChunks;
  }

  /// Whether upload is in progress
  bool get isInProgress => !isCompleted && completedChunks > 0;

  /// Whether upload is pending
  bool get isPending => !isCompleted && completedChunks == 0;
}

/// {@template upload_progress_tracker}
/// Tracks upload progress across multiple files.
/// {@endtemplate}
class UploadProgressTracker {
  /// {@macro upload_progress_tracker}
  UploadProgressTracker();

  final Map<String, UploadProgress> _uploads = {};

  /// Starts tracking an upload
  void startTracking(String uploadId, String fileName, int fileSize) {
    _uploads[uploadId] = UploadProgress(
      uploadId: uploadId,
      fileName: fileName,
      fileSize: fileSize,
      uploadedBytes: 0,
      status: UploadStatusType.uploading,
    );
  }

  /// Updates upload progress
  void updateProgress(String uploadId, int uploadedBytes) {
    final progress = _uploads[uploadId];
    if (progress != null) {
      _uploads[uploadId] = progress.copyWith(uploadedBytes: uploadedBytes);
    }
  }

  /// Marks upload as completed
  void markCompleted(String uploadId) {
    final progress = _uploads[uploadId];
    if (progress != null) {
      _uploads[uploadId] = progress.copyWith(status: UploadStatusType.completed);
    }
  }

  /// Marks upload as failed
  void markFailed(String uploadId, String error) {
    final progress = _uploads[uploadId];
    if (progress != null) {
      _uploads[uploadId] = progress.copyWith(
        status: UploadStatusType.failed,
        error: error,
      );
    }
  }

  /// Gets upload progress
  UploadProgress? getProgress(String uploadId) {
    return _uploads[uploadId];
  }

  /// Gets all uploads
  List<UploadProgress> get allUploads => _uploads.values.toList();

  /// Gets overall progress percentage
  double get overallProgress {
    if (_uploads.isEmpty) return 0.0;
    
    final totalBytes = _uploads.values.fold<int>(0, (sum, upload) => sum + upload.fileSize);
    final uploadedBytes = _uploads.values.fold<int>(0, (sum, upload) => sum + upload.uploadedBytes);
    
    return totalBytes > 0 ? uploadedBytes / totalBytes : 0.0;
  }

  /// Clears completed uploads
  void clearCompleted() {
    _uploads.removeWhere((key, value) => value.status == UploadStatusType.completed);
  }
}

/// {@template upload_progress}
/// Progress information for a single upload.
/// {@endtemplate}
class UploadProgress {
  /// {@macro upload_progress}
  const UploadProgress({
    required this.uploadId,
    required this.fileName,
    required this.fileSize,
    required this.uploadedBytes,
    required this.status,
    this.error,
  });

  final String uploadId;
  final String fileName;
  final int fileSize;
  final int uploadedBytes;
  final UploadStatusType status;
  final String? error;

  /// Progress percentage
  double get progress {
    if (fileSize == 0) return 0.0;
    return uploadedBytes / fileSize;
  }

  /// Whether upload is completed
  bool get isCompleted => status == UploadStatusType.completed;

  /// Whether upload failed
  bool get isFailed => status == UploadStatusType.failed;

  /// Whether upload is in progress
  bool get isInProgress => status == UploadStatusType.uploading;

  /// Creates a copy with updated values
  UploadProgress copyWith({
    String? uploadId,
    String? fileName,
    int? fileSize,
    int? uploadedBytes,
    UploadStatusType? status,
    String? error,
  }) {
    return UploadProgress(
      uploadId: uploadId ?? this.uploadId,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      uploadedBytes: uploadedBytes ?? this.uploadedBytes,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}

/// {@template upload_status_type}
/// Type of upload status.
/// {@endtemplate}
enum UploadStatusType {
  uploading('uploading', 'Uploading'),
  completed('completed', 'Completed'),
  failed('failed', 'Failed'),
  paused('paused', 'Paused');

  const UploadStatusType(this.value, this.displayName);

  final String value;
  final String displayName;
}
