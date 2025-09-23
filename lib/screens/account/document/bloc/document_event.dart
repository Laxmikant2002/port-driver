part of 'document_bloc.dart';

/// Base class for all Document events
sealed class DocumentEvent extends Equatable {
  const DocumentEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when driving license is changed
final class DocumentDrivingLicenseChanged extends DocumentEvent {
  const DocumentDrivingLicenseChanged(this.drivingLicense);

  final String drivingLicense;

  @override
  List<Object> get props => [drivingLicense];

  @override
  String toString() => 'DocumentDrivingLicenseChanged(drivingLicense: $drivingLicense)';
}

/// Event triggered when aadhaar is changed
final class DocumentAadhaarChanged extends DocumentEvent {
  const DocumentAadhaarChanged(this.aadhaar);

  final String aadhaar;

  @override
  List<Object> get props => [aadhaar];

  @override
  String toString() => 'DocumentAadhaarChanged(aadhaar: $aadhaar)';
}

/// Event triggered when pan is changed
final class DocumentPanChanged extends DocumentEvent {
  const DocumentPanChanged(this.pan);

  final String pan;

  @override
  List<Object> get props => [pan];

  @override
  String toString() => 'DocumentPanChanged(pan: $pan)';
}

/// Event triggered when address proof is changed
final class DocumentAddressProofChanged extends DocumentEvent {
  const DocumentAddressProofChanged(this.addressProof);

  final String addressProof;

  @override
  List<Object> get props => [addressProof];

  @override
  String toString() => 'DocumentAddressProofChanged(addressProof: $addressProof)';
}

/// Event triggered when RC book is changed
final class DocumentRcBookChanged extends DocumentEvent {
  const DocumentRcBookChanged(this.rcBook);

  final String rcBook;

  @override
  List<Object> get props => [rcBook];

  @override
  String toString() => 'DocumentRcBookChanged(rcBook: $rcBook)';
}

/// Event triggered when insurance is changed
final class DocumentInsuranceChanged extends DocumentEvent {
  const DocumentInsuranceChanged(this.insurance);

  final String insurance;

  @override
  List<Object> get props => [insurance];

  @override
  String toString() => 'DocumentInsuranceChanged(insurance: $insurance)';
}

/// Event triggered when document form is submitted
final class DocumentSubmitted extends DocumentEvent {
  const DocumentSubmitted();

  @override
  String toString() => 'DocumentSubmitted()';
}

/// Event triggered when documents are loaded
final class DocumentsLoaded extends DocumentEvent {
  const DocumentsLoaded();

  @override
  String toString() => 'DocumentsLoaded()';
}

/// Event triggered when a document is selected for viewing/editing
final class DocumentSelected extends DocumentEvent {
  const DocumentSelected(this.document);

  final Document document;

  @override
  List<Object> get props => [document];

  @override
  String toString() => 'DocumentSelected(document: $document)';
}

/// Event triggered when a document is uploaded
final class DocumentUploaded extends DocumentEvent {
  const DocumentUploaded({
    required this.documentType,
    required this.filePath,
    this.fileName,
    this.metadata,
  });

  final DocumentType documentType;
  final String filePath;
  final String? fileName;
  final Map<String, dynamic>? metadata;

  @override
  List<Object> get props => [documentType, filePath, fileName ?? '', metadata ?? {}];

  @override
  String toString() => 'DocumentUploaded(documentType: $documentType, filePath: $filePath)';
}

/// Event triggered when a document is deleted
final class DocumentDeleted extends DocumentEvent {
  const DocumentDeleted(this.documentId);

  final String documentId;

  @override
  List<Object> get props => [documentId];

  @override
  String toString() => 'DocumentDeleted(documentId: $documentId)';
}

/// Event triggered when document upload is retried
final class DocumentRetryUpload extends DocumentEvent {
  const DocumentRetryUpload({
    required this.documentType,
    required this.filePath,
    this.fileName,
    this.metadata,
  });

  final DocumentType documentType;
  final String filePath;
  final String? fileName;
  final Map<String, dynamic>? metadata;

  @override
  List<Object> get props => [documentType, filePath, fileName ?? '', metadata ?? {}];

  @override
  String toString() => 'DocumentRetryUpload(documentType: $documentType, filePath: $filePath)';
}

/// Event triggered when document status is refreshed
final class DocumentStatusRefreshed extends DocumentEvent {
  const DocumentStatusRefreshed();

  @override
  String toString() => 'DocumentStatusRefreshed()';
}