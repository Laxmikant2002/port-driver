part of 'documents_bloc.dart';

/// {@template documents_event}
/// Base class for all documents events.
/// {@endtemplate}
sealed class DocumentsEvent extends Equatable {
  /// {@macro documents_event}
  const DocumentsEvent();

  @override
  List<Object> get props => [];
}

/// {@template documents_loaded}
/// Event triggered when documents are loaded.
/// {@endtemplate}
final class DocumentsLoaded extends DocumentsEvent {
  /// {@macro documents_loaded}
  const DocumentsLoaded();

  @override
  String toString() => 'DocumentsLoaded()';
}

/// {@template document_status_refreshed}
/// Event triggered when document status is refreshed.
/// {@endtemplate}
final class DocumentStatusRefreshed extends DocumentsEvent {
  /// {@macro document_status_refreshed}
  const DocumentStatusRefreshed();

  @override
  String toString() => 'DocumentStatusRefreshed()';
}

/// {@template document_reupload_requested}
/// Event triggered when a document re-upload is requested.
/// {@endtemplate}
final class DocumentReuploadRequested extends DocumentsEvent {
  /// {@macro document_reupload_requested}
  const DocumentReuploadRequested({
    required this.documentId,
  });

  /// The ID of the document to re-upload.
  final String documentId;

  @override
  List<Object> get props => [documentId];

  @override
  String toString() => 'DocumentReuploadRequested(documentId: $documentId)';
}

/// {@template document_deleted}
/// Event triggered when a document is deleted.
/// {@endtemplate}
final class DocumentDeleted extends DocumentsEvent {
  /// {@macro document_deleted}
  const DocumentDeleted({
    required this.documentId,
  });

  /// The ID of the document to delete.
  final String documentId;

  @override
  List<Object> get props => [documentId];

  @override
  String toString() => 'DocumentDeleted(documentId: $documentId)';
}

/// {@template document_expiry_notification_toggled}
/// Event triggered when expiry notification is toggled.
/// {@endtemplate}
final class DocumentExpiryNotificationToggled extends DocumentsEvent {
  /// {@macro document_expiry_notification_toggled}
  const DocumentExpiryNotificationToggled({
    required this.documentId,
    required this.enabled,
  });

  /// The ID of the document.
  final String documentId;

  /// Whether the notification is enabled.
  final bool enabled;

  @override
  List<Object> get props => [documentId, enabled];

  @override
  String toString() => 'DocumentExpiryNotificationToggled(documentId: $documentId, enabled: $enabled)';
}
