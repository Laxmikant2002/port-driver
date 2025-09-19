part of 'docs_bloc.dart';

/// Base class for all document verification events
sealed class DocsEvent extends Equatable {
  const DocsEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when documents need to be loaded
final class DocsLoaded extends DocsEvent {
  const DocsLoaded();

  @override
  String toString() => 'DocsLoaded()';
}

/// Event triggered when document upload is started
final class DocumentUploadStarted extends DocsEvent {
  const DocumentUploadStarted({
    required this.documentType,
    this.frontImagePath,
    this.backImagePath,
  });

  final DocumentType documentType;
  final String? frontImagePath;
  final String? backImagePath;

  @override
  List<Object?> get props => [documentType, frontImagePath, backImagePath];

  @override
  String toString() => 'DocumentUploadStarted(documentType: $documentType)';
}

/// Event triggered when document status is updated from backend
final class DocumentStatusUpdated extends DocsEvent {
  const DocumentStatusUpdated({
    required this.documentType,
    required this.status,
    this.rejectionReason,
  });

  final DocumentType documentType;
  final DocumentStatus status;
  final String? rejectionReason;

  @override
  List<Object?> get props => [documentType, status, rejectionReason];

  @override
  String toString() => 'DocumentStatusUpdated(documentType: $documentType, status: $status)';
}

/// Event triggered when all documents are submitted for final verification
final class DocsSubmitted extends DocsEvent {
  const DocsSubmitted();

  @override
  String toString() => 'DocsSubmitted()';
}
