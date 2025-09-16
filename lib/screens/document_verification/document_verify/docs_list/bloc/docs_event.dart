part of 'docs_bloc.dart';

/// {@template docs_event}
/// Base class for all document verification events.
/// {@endtemplate}
abstract class DocsEvent extends Equatable {
  /// {@macro docs_event}
  const DocsEvent();

  @override
  List<Object?> get props => [];
}

/// {@template docs_loaded}
/// Event triggered when documents need to be loaded.
/// {@endtemplate}
class DocsLoaded extends DocsEvent {
  /// {@macro docs_loaded}
  const DocsLoaded();
}

/// {@template document_upload_started}
/// Event triggered when document upload is started.
/// {@endtemplate}
class DocumentUploadStarted extends DocsEvent {
  /// {@macro document_upload_started}
  const DocumentUploadStarted({
    required this.documentType,
    this.frontImagePath,
    this.backImagePath,
  });

  /// The type of document being uploaded.
  final DocumentType documentType;

  /// Path to the front image (if applicable).
  final String? frontImagePath;

  /// Path to the back image (if applicable).
  final String? backImagePath;

  @override
  List<Object?> get props => [documentType, frontImagePath, backImagePath];
}

/// {@template document_upload_progress}
/// Event triggered when document upload progress changes.
/// {@endtemplate}
class DocumentUploadProgress extends DocsEvent {
  /// {@macro document_upload_progress}
  const DocumentUploadProgress({
    required this.documentType,
    required this.progress,
  });

  /// The type of document being uploaded.
  final DocumentType documentType;

  /// Upload progress (0.0 to 1.0).
  final double progress;

  @override
  List<Object?> get props => [documentType, progress];
}

/// {@template document_upload_completed}
/// Event triggered when document upload is completed.
/// {@endtemplate}
class DocumentUploadCompleted extends DocsEvent {
  /// {@macro document_upload_completed}
  const DocumentUploadCompleted({
    required this.documentType,
    this.frontImageUrl,
    this.backImageUrl,
  });

  /// The type of document that was uploaded.
  final DocumentType documentType;

  /// URL of the uploaded front image.
  final String? frontImageUrl;

  /// URL of the uploaded back image.
  final String? backImageUrl;

  @override
  List<Object?> get props => [documentType, frontImageUrl, backImageUrl];
}

/// {@template document_upload_failed}
/// Event triggered when document upload fails.
/// {@endtemplate}
class DocumentUploadFailed extends DocsEvent {
  /// {@macro document_upload_failed}
  const DocumentUploadFailed({
    required this.documentType,
    required this.error,
  });

  /// The type of document that failed to upload.
  final DocumentType documentType;

  /// The error message.
  final String error;

  @override
  List<Object?> get props => [documentType, error];
}

/// {@template document_verification_started}
/// Event triggered when document verification starts.
/// {@endtemplate}
class DocumentVerificationStarted extends DocsEvent {
  /// {@macro document_verification_started}
  const DocumentVerificationStarted(this.documentType);

  /// The type of document being verified.
  final DocumentType documentType;

  @override
  List<Object?> get props => [documentType];
}

/// {@template document_verified}
/// Event triggered when document verification is completed successfully.
/// {@endtemplate}
class DocumentVerified extends DocsEvent {
  /// {@macro document_verified}
  const DocumentVerified(this.documentType);

  /// The type of document that was verified.
  final DocumentType documentType;

  @override
  List<Object?> get props => [documentType];
}

/// {@template document_rejected}
/// Event triggered when document verification is rejected.
/// {@endtemplate}
class DocumentRejected extends DocsEvent {
  /// {@macro document_rejected}
  const DocumentRejected({
    required this.documentType,
    required this.reason,
  });

  /// The type of document that was rejected.
  final DocumentType documentType;

  /// The reason for rejection.
  final String reason;

  @override
  List<Object?> get props => [documentType, reason];
}

/// {@template docs_submitted}
/// Event triggered when all documents are submitted for final verification.
/// {@endtemplate}
class DocsSubmitted extends DocsEvent {
  /// {@macro docs_submitted}
  const DocsSubmitted();
}
