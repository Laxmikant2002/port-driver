import 'package:equatable/equatable.dart';

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
  rejected,
}

class Document extends Equatable {
  final String id;
  final DocumentType type;
  final String title;
  final String description;
  final DocumentStatus status;
  final bool isRequired;
  final bool isNextStep;
  final DateTime? expiryDate;
  final DateTime? uploadedAt;
  final String? fileUrl;
  final String? verificationNotes;
  final Map<String, dynamic>? metadata;

  const Document({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.status,
    required this.isRequired,
    required this.isNextStep,
    this.expiryDate,
    this.uploadedAt,
    this.fileUrl,
    this.verificationNotes,
    this.metadata,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] as String? ?? '',
      type: _parseDocumentType(json['type'] as String? ?? ''),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: _parseStatus(json['status'] as String? ?? ''),
      isRequired: json['isRequired'] as bool? ?? false,
      isNextStep: json['isNextStep'] as bool? ?? false,
      expiryDate: json['expiryDate'] != null 
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.parse(json['uploadedAt'] as String)
          : null,
      fileUrl: json['fileUrl'] as String?,
      verificationNotes: json['verificationNotes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': _documentTypeToString(type),
      'title': title,
      'description': description,
      'status': _statusToString(status),
      'isRequired': isRequired,
      'isNextStep': isNextStep,
      'expiryDate': expiryDate?.toIso8601String(),
      'uploadedAt': uploadedAt?.toIso8601String(),
      'fileUrl': fileUrl,
      'verificationNotes': verificationNotes,
      'metadata': metadata,
    };
  }

  static DocumentType _parseDocumentType(String type) {
    switch (type.toLowerCase()) {
      case 'driver':
        return DocumentType.driver;
      case 'vehicle':
        return DocumentType.vehicle;
      default:
        throw ArgumentError('Invalid document type: $type');
    }
  }

  static String _documentTypeToString(DocumentType type) {
    return type.toString().split('.').last;
  }

  static DocumentStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return DocumentStatus.pending;
      case 'approved':
        return DocumentStatus.approved;
      case 'not_uploaded':
        return DocumentStatus.notUploaded;
      case 'verification_required':
        return DocumentStatus.verificationRequired;
      case 'expired':
        return DocumentStatus.expired;
      case 'rejected':
        return DocumentStatus.rejected;
      default:
        return DocumentStatus.notUploaded;
    }
  }

  static String _statusToString(DocumentStatus status) {
    return status.toString().split('.').last;
  }

  // Helper getters
  bool get isDriver => type == DocumentType.driver;
  bool get isVehicle => type == DocumentType.vehicle;
  bool get isPending => status == DocumentStatus.pending;
  bool get isApproved => status == DocumentStatus.approved;
  bool get isExpired => status == DocumentStatus.expired;
  bool get isNotUploaded => status == DocumentStatus.notUploaded;
  bool get isVerificationRequired => status == DocumentStatus.verificationRequired;
  bool get isRejected => status == DocumentStatus.rejected;
  bool get isValid => isApproved && !isExpired;
  bool get needsAction => isPending || isVerificationRequired || isRejected;

  // Document type specific getters
  bool get isLicense => title.toLowerCase().contains('license');
  bool get isInsurance => title.toLowerCase().contains('insurance');
  bool get isRegistration => title.toLowerCase().contains('registration');
  bool get isAddressProof => title.toLowerCase().contains('address');
  bool get isIdentityProof => title.toLowerCase().contains('identity');

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        description,
        status,
        isRequired,
        isNextStep,
        expiryDate,
        uploadedAt,
        fileUrl,
        verificationNotes,
        metadata,
      ];
}

// Document verification request model
class DocumentVerificationRequest {
  final String documentId;
  final String filePath;
  final String fileType;
  final Map<String, dynamic>? additionalData;

  DocumentVerificationRequest({
    required this.documentId,
    required this.filePath,
    required this.fileType,
    this.additionalData,
  });

  Map<String, dynamic> toJson() {
    return {
      'documentId': documentId,
      'fileType': fileType,
      'additionalData': additionalData,
    };
  }
}

// Document verification response model
class DocumentVerificationResponse {
  final String documentId;
  final DocumentStatus status;
  final String? message;
  final DateTime verifiedAt;
  final String? verifiedBy;

  DocumentVerificationResponse({
    required this.documentId,
    required this.status,
    this.message,
    required this.verifiedAt,
    this.verifiedBy,
  });

  factory DocumentVerificationResponse.fromJson(Map<String, dynamic> json) {
    return DocumentVerificationResponse(
      documentId: json['documentId'] as String,
      status: Document._parseStatus(json['status'] as String),
      message: json['message'] as String?,
      verifiedAt: DateTime.parse(json['verifiedAt'] as String),
      verifiedBy: json['verifiedBy'] as String?,
    );
  }
}