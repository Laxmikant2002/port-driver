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

/// {@template document_status_updated}
/// Event triggered when document status is updated from backend.
/// {@endtemplate}
class DocumentStatusUpdated extends DocsEvent {
  /// {@macro document_status_updated}
  const DocumentStatusUpdated({
    required this.documentType,
    required this.status,
    this.rejectionReason,
  });

  /// The type of document that was updated.
  final DocumentType documentType;

  /// The new status of the document.
  final DocumentStatus status;

  /// The reason for rejection (if applicable).
  final String? rejectionReason;

  @override
  List<Object?> get props => [documentType, status, rejectionReason];
}

/// {@template docs_submitted}
/// Event triggered when all documents are submitted for final verification.
/// {@endtemplate}
class DocsSubmitted extends DocsEvent {
  /// {@macro docs_submitted}
  const DocsSubmitted();
}
