part of 'document_bloc.dart';

abstract class DocumentEvent extends Equatable {
  const DocumentEvent();

  @override
  List<Object> get props => [];
}

class LoadDocuments extends DocumentEvent {
  const LoadDocuments();
}

class UploadDocument extends DocumentEvent {
  final Map<String, dynamic> document;

  const UploadDocument(this.document);

  @override
  List<Object> get props => [document];
}

class DeleteDocument extends DocumentEvent {
  final String documentId;

  const DeleteDocument(this.documentId);

  @override
  List<Object> get props => [documentId];
}

class UpdateDocumentStatus extends DocumentEvent {
  final String documentId;
  final DocumentStatus status;

  const UpdateDocumentStatus({
    required this.documentId,
    required this.status,
  });

  @override
  List<Object> get props => [documentId, status];
}