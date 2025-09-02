part of 'document_bloc.dart';

enum DocumentType {
  driver,
  vehicle,
}

enum DocumentStatus {
  pending,
  approved,
  notUploaded,
  verificationRequired,
  expired,
}

class DocumentState extends Equatable {
  final List<Map<String, dynamic>> documents;
  final Map<String, DocumentStatus> statuses;
  final FormzSubmissionStatus status;
  final String? error;

  const DocumentState({
    this.documents = const [],
    this.statuses = const {},
    this.status = FormzSubmissionStatus.initial,
    this.error,
  });

  DocumentState copyWith({
    List<Map<String, dynamic>>? documents,
    Map<String, DocumentStatus>? statuses,
    FormzSubmissionStatus? status,
    String? error,
  }) {
    return DocumentState(
      documents: documents ?? this.documents,
      statuses: statuses ?? this.statuses,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  int get totalDocuments => documents.length;

  int get verifiedDocuments =>
      documents.where((doc) => doc['status'] == DocumentStatus.approved).length;

  bool get hasPendingVerifications =>
      documents.any((doc) => doc['status'] == DocumentStatus.pending);

  bool get hasExpiredDocuments =>
      documents.any((doc) => doc['status'] == DocumentStatus.expired);

  List<Map<String, dynamic>> get driverDocuments =>
      documents.where((doc) => doc['type'] == DocumentType.driver.name).toList();

  List<Map<String, dynamic>> get vehicleDocuments =>
      documents.where((doc) => doc['type'] == DocumentType.vehicle.name).toList();

  @override
  List<Object?> get props => [documents, statuses, status, error];
}

class DocumentInitial extends DocumentState {}

class DocumentLoading extends DocumentState {}

class DocumentLoaded extends DocumentState {
  final List<Map<String, dynamic>> documents;
  final Map<String, DocumentStatus> statuses;

  const DocumentLoaded({
    required this.documents,
    required this.statuses,
  });

  int get totalDocuments => documents.length;

  int get verifiedDocuments =>
      documents.where((doc) => doc['status'] == DocumentStatus.approved).length;

  bool get hasPendingVerifications =>
      documents.any((doc) => doc['status'] == DocumentStatus.pending);

  bool get hasExpiredDocuments =>
      documents.any((doc) => doc['status'] == DocumentStatus.expired);

  List<Map<String, dynamic>> get driverDocuments =>
      documents.where((doc) => doc['type'] == DocumentType.driver.name).toList();

  List<Map<String, dynamic>> get vehicleDocuments =>
      documents.where((doc) => doc['type'] == DocumentType.vehicle.name).toList();

  @override
  List<Object> get props => [documents, statuses];
}

class DocumentError extends DocumentState {
  final String message;

  const DocumentError(this.message);

  @override
  List<Object> get props => [message];
}

class DocumentUploadSuccess extends DocumentState {
  final String documentId;

  const DocumentUploadSuccess(this.documentId);

  @override
  List<Object> get props => [documentId];
}

class DocumentUploadFailure extends DocumentState {
  final String message;

  const DocumentUploadFailure(this.message);

  @override
  List<Object> get props => [message];
}

class DocumentDeleteSuccess extends DocumentState {
  final String documentId;

  const DocumentDeleteSuccess(this.documentId);

  @override
  List<Object> get props => [documentId];
}

class DocumentDeleteFailure extends DocumentState {
  final String message;

  const DocumentDeleteFailure(this.message);

  @override
  List<Object> get props => [message];
}