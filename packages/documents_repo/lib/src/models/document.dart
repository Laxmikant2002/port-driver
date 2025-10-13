import 'package:equatable/equatable.dart';

/// Driver document model for driver documents
class DriverDocument extends Equatable {
  const DriverDocument({
    required this.id,
    required this.type,
    required this.status,
    this.frontImageUrl,
    this.backImageUrl,
    this.fileName,
    this.fileSize,
    this.uploadedAt,
    this.verifiedAt,
    this.rejectedReason,
    this.expiryDate,
    this.metadata,
  });

  final String id;
  final DocumentType type;
  final DocumentStatus status;
  final String? frontImageUrl;
  final String? backImageUrl;
  final String? fileName;
  final int? fileSize;
  final DateTime? uploadedAt;
  final DateTime? verifiedAt;
  final String? rejectedReason;
  final DateTime? expiryDate;
  final Map<String, dynamic>? metadata;

  factory DriverDocument.fromJson(Map<String, dynamic> json) {
    return DriverDocument(
      id: json['id'] as String,
      type: DocumentType.fromString(json['type'] as String),
      status: DocumentStatus.fromString(json['status'] as String),
      frontImageUrl: json['frontImageUrl'] as String?,
      backImageUrl: json['backImageUrl'] as String?,
      fileName: json['fileName'] as String?,
      fileSize: json['fileSize'] as int?,
      uploadedAt: json['uploadedAt'] != null 
          ? DateTime.parse(json['uploadedAt'] as String) 
          : null,
      verifiedAt: json['verifiedAt'] != null 
          ? DateTime.parse(json['verifiedAt'] as String) 
          : null,
      rejectedReason: json['rejectedReason'] as String?,
      expiryDate: json['expiryDate'] != null 
          ? DateTime.parse(json['expiryDate'] as String) 
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'status': status.value,
      'frontImageUrl': frontImageUrl,
      'backImageUrl': backImageUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'uploadedAt': uploadedAt?.toIso8601String(),
      'verifiedAt': verifiedAt?.toIso8601String(),
      'rejectedReason': rejectedReason,
      'expiryDate': expiryDate?.toIso8601String(),
      'metadata': metadata,
    };
  }

  DriverDocument copyWith({
    String? id,
    DocumentType? type,
    DocumentStatus? status,
    String? frontImageUrl,
    String? backImageUrl,
    String? fileName,
    int? fileSize,
    DateTime? uploadedAt,
    DateTime? verifiedAt,
    String? rejectedReason,
    DateTime? expiryDate,
    Map<String, dynamic>? metadata,
  }) {
    return DriverDocument(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      frontImageUrl: frontImageUrl ?? this.frontImageUrl,
      backImageUrl: backImageUrl ?? this.backImageUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      rejectedReason: rejectedReason ?? this.rejectedReason,
      expiryDate: expiryDate ?? this.expiryDate,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        status,
        frontImageUrl,
        backImageUrl,
        fileName,
        fileSize,
        uploadedAt,
        verifiedAt,
        rejectedReason,
        expiryDate,
        metadata,
      ];

  @override
  String toString() {
    return 'DriverDocument('
        'id: $id, '
        'type: $type, '
        'status: $status, '
        'frontImageUrl: $frontImageUrl, '
        'backImageUrl: $backImageUrl, '
        'fileName: $fileName, '
        'fileSize: $fileSize, '
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

  /// Returns whether this document type is required for driver verification
  bool get isRequired {
    return this == DocumentType.drivingLicense ||
           this == DocumentType.aadhaar ||
           this == DocumentType.pan ||
           this == DocumentType.rcBook ||
           this == DocumentType.insurance;
  }

  /// Returns whether this document requires both front and back images
  bool get requiresBothSides {
    return this == DocumentType.drivingLicense || 
           this == DocumentType.aadhaar;
  }

  /// Returns the description for this document type
  String get description {
    switch (this) {
      case DocumentType.drivingLicense:
        return 'Upload a clear photo of your driving license';
      case DocumentType.rcBook:
        return 'Upload a clear photo of your vehicle registration certificate';
      case DocumentType.insurance:
        return 'Upload a clear photo of your vehicle insurance document';
      case DocumentType.profilePicture:
        return 'Upload a clear photo of yourself';
      case DocumentType.aadhaar:
        return 'Upload a clear photo of your Aadhaar card';
      case DocumentType.pan:
        return 'Upload a clear photo of your PAN card';
      case DocumentType.addressProof:
        return 'Upload a clear photo of your address proof document';
    }
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
