import 'package:equatable/equatable.dart';

/// Driver document model for driver documents
class DriverDocument extends Equatable {
  const DriverDocument({
    required this.id,
    required this.type,
    required this.status,
    this.fileUrl,
    this.fileName,
    this.uploadedAt,
    this.verifiedAt,
    this.rejectedReason,
    this.metadata,
  });

  final String id;
  final DocumentType type;
  final DocumentStatus status;
  final String? fileUrl;
  final String? fileName;
  final DateTime? uploadedAt;
  final DateTime? verifiedAt;
  final String? rejectedReason;
  final Map<String, dynamic>? metadata;

  factory DriverDocument.fromJson(Map<String, dynamic> json) {
    return DriverDocument(
      id: json['id'] as String,
      type: DocumentType.fromString(json['type'] as String),
      status: DocumentStatus.fromString(json['status'] as String),
      fileUrl: json['fileUrl'] as String?,
      fileName: json['fileName'] as String?,
      uploadedAt: json['uploadedAt'] != null 
          ? DateTime.parse(json['uploadedAt'] as String) 
          : null,
      verifiedAt: json['verifiedAt'] != null 
          ? DateTime.parse(json['verifiedAt'] as String) 
          : null,
      rejectedReason: json['rejectedReason'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'status': status.value,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'uploadedAt': uploadedAt?.toIso8601String(),
      'verifiedAt': verifiedAt?.toIso8601String(),
      'rejectedReason': rejectedReason,
      'metadata': metadata,
    };
  }

  DriverDocument copyWith({
    String? id,
    DocumentType? type,
    DocumentStatus? status,
    String? fileUrl,
    String? fileName,
    DateTime? uploadedAt,
    DateTime? verifiedAt,
    String? rejectedReason,
    Map<String, dynamic>? metadata,
  }) {
    return DriverDocument(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      rejectedReason: rejectedReason ?? this.rejectedReason,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        status,
        fileUrl,
        fileName,
        uploadedAt,
        verifiedAt,
        rejectedReason,
        metadata,
      ];

  @override
  String toString() {
    return 'DriverDocument('
        'id: $id, '
        'type: $type, '
        'status: $status, '
        'fileUrl: $fileUrl, '
        'fileName: $fileName, '
        'uploadedAt: $uploadedAt, '
        'verifiedAt: $verifiedAt, '
        'rejectedReason: $rejectedReason'
        ')';
  }
}

/// Document types for driver verification
enum DocumentType {
  drivingLicense('driving_license', 'Driving License'),
  rcBook('rc_book', 'RC Book'),
  insurance('insurance', 'Insurance'),
  profilePicture('profile_picture', 'Profile Picture'),
  aadhaar('aadhaar', 'Aadhaar'),
  pan('pan', 'PAN Card'),
  addressProof('address_proof', 'Address Proof');

  const DocumentType(this.value, this.displayName);

  final String value;
  final String displayName;

  static DocumentType fromString(String value) {
    return DocumentType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Unknown document type: $value'),
    );
  }
}

/// Document verification status
enum DocumentStatus {
  pending('pending', 'Pending'),
  uploading('uploading', 'Uploading'),
  uploaded('uploaded', 'Uploaded'),
  verifying('verifying', 'Verifying'),
  verified('verified', 'Verified'),
  rejected('rejected', 'Rejected'),
  expired('expired', 'Expired');

  const DocumentStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  static DocumentStatus fromString(String value) {
    return DocumentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => throw ArgumentError('Unknown document status: $value'),
    );
  }

  /// Returns whether this status indicates the document is in progress
  bool get isInProgress {
    return this == DocumentStatus.uploading || this == DocumentStatus.verifying;
  }

  /// Returns whether this status indicates the document is completed
  bool get isCompleted {
    return this == DocumentStatus.verified;
  }

  /// Returns whether this status indicates the document needs attention
  bool get needsAttention {
    return this == DocumentStatus.rejected;
  }
}
