part of 'document_upload_bloc.dart';

/// {@template document_upload_event}
/// Base class for all document upload events.
/// {@endtemplate}
sealed class DocumentUploadEvent extends Equatable {
  /// {@macro document_upload_event}
  const DocumentUploadEvent();

  @override
  List<Object> get props => [];
}

/// {@template document_upload_initialized}
/// Event triggered when the document upload flow is initialized.
/// {@endtemplate}
final class DocumentUploadInitialized extends DocumentUploadEvent {
  /// {@macro document_upload_initialized}
  const DocumentUploadInitialized();

  @override
  String toString() => 'DocumentUploadInitialized()';
}

/// {@template document_upload_started}
/// Event triggered when a document upload is started.
/// {@endtemplate}
final class DocumentUploadStarted extends DocumentUploadEvent {
  /// {@macro document_upload_started}
  const DocumentUploadStarted({
    required this.type,
    required this.filePath,
    this.fileName,
    this.fileSize,
  });

  /// The type of document being uploaded.
  final DocumentType type;

  /// Path to the file being uploaded.
  final String filePath;

  /// Name of the file being uploaded.
  final String? fileName;

  /// Size of the file being uploaded in bytes.
  final int? fileSize;

  @override
  List<Object?> get props => [type, filePath, fileName, fileSize];

  @override
  String toString() => 'DocumentUploadStarted(type: $type, filePath: $filePath)';
}

/// {@template document_upload_progress_updated}
/// Event triggered when upload progress is updated.
/// {@endtemplate}
final class DocumentUploadProgressUpdated extends DocumentUploadEvent {
  /// {@macro document_upload_progress_updated}
  const DocumentUploadProgressUpdated({
    required this.type,
    required this.progress,
  });

  /// The type of document being uploaded.
  final DocumentType type;

  /// Upload progress (0.0 to 1.0).
  final double progress;

  @override
  List<Object> get props => [type, progress];

  @override
  String toString() => 'DocumentUploadProgressUpdated(type: $type, progress: $progress)';
}

/// {@template document_upload_completed}
/// Event triggered when a document upload is completed.
/// {@endtemplate}
final class DocumentUploadCompleted extends DocumentUploadEvent {
  /// {@macro document_upload_completed}
  const DocumentUploadCompleted({
    required this.type,
    required this.frontImagePath,
    this.backImagePath,
    this.fileName,
    this.fileSize,
  });

  /// The type of document that was uploaded.
  final DocumentType type;

  /// Path to the front image.
  final String frontImagePath;

  /// Path to the back image (if applicable).
  final String? backImagePath;

  /// Name of the uploaded file.
  final String? fileName;

  /// Size of the uploaded file in bytes.
  final int? fileSize;

  @override
  List<Object?> get props => [type, frontImagePath, backImagePath, fileName, fileSize];

  @override
  String toString() => 'DocumentUploadCompleted(type: $type, frontImagePath: $frontImagePath)';
}

/// {@template document_upload_failed}
/// Event triggered when a document upload fails.
/// {@endtemplate}
final class DocumentUploadFailed extends DocumentUploadEvent {
  /// {@macro document_upload_failed}
  const DocumentUploadFailed({
    required this.type,
    required this.error,
  });

  /// The type of document that failed to upload.
  final DocumentType type;

  /// Error message describing the failure.
  final String error;

  @override
  List<Object> get props => [type, error];

  @override
  String toString() => 'DocumentUploadFailed(type: $type, error: $error)';
}

/// {@template document_upload_retried}
/// Event triggered when a document upload is retried.
/// {@endtemplate}
final class DocumentUploadRetried extends DocumentUploadEvent {
  /// {@macro document_upload_retried}
  const DocumentUploadRetried({
    required this.type,
    required this.filePath,
    this.fileName,
    this.fileSize,
  });

  /// The type of document being retried.
  final DocumentType type;

  /// Path to the file being uploaded.
  final String filePath;

  /// Name of the file being uploaded.
  final String? fileName;

  /// Size of the file being uploaded in bytes.
  final int? fileSize;

  @override
  List<Object?> get props => [type, filePath, fileName, fileSize];

  @override
  String toString() => 'DocumentUploadRetried(type: $type, filePath: $filePath)';
}

/// {@template document_upload_deleted}
/// Event triggered when a document upload is deleted.
/// {@endtemplate}
final class DocumentUploadDeleted extends DocumentUploadEvent {
  /// {@macro document_upload_deleted}
  const DocumentUploadDeleted({
    required this.type,
  });

  /// The type of document being deleted.
  final DocumentType type;

  @override
  List<Object> get props => [type];

  @override
  String toString() => 'DocumentUploadDeleted(type: $type)';
}

/// {@template document_upload_submitted}
/// Event triggered when all documents are submitted for verification.
/// {@endtemplate}
final class DocumentUploadSubmitted extends DocumentUploadEvent {
  /// {@macro document_upload_submitted}
  const DocumentUploadSubmitted();

  @override
  String toString() => 'DocumentUploadSubmitted()';
}

/// {@template document_upload_status_refreshed}
/// Event triggered when document status is refreshed from server.
/// {@endtemplate}
final class DocumentUploadStatusRefreshed extends DocumentUploadEvent {
  /// {@macro document_upload_status_refreshed}
  const DocumentUploadStatusRefreshed();

  @override
  String toString() => 'DocumentUploadStatusRefreshed()';
}

/// {@template document_upload_recommended_next_changed}
/// Event triggered when the recommended next document is changed.
/// {@endtemplate}
final class DocumentUploadRecommendedNextChanged extends DocumentUploadEvent {
  /// {@macro document_upload_recommended_next_changed}
  const DocumentUploadRecommendedNextChanged({
    required this.type,
    required this.isRecommended,
  });

  /// The type of document.
  final DocumentType type;

  /// Whether this document is recommended next.
  final bool isRecommended;

  @override
  List<Object> get props => [type, isRecommended];

  @override
  String toString() => 'DocumentUploadRecommendedNextChanged(type: $type, isRecommended: $isRecommended)';
}
