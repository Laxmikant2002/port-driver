import 'package:equatable/equatable.dart';

/// {@template document_type}
/// Enum representing different types of documents required for driver verification.
/// {@endtemplate}
enum DocumentType {
  /// Driving license document
  drivingLicense('driving_license', 'Driving License'),
  
  /// Registration certificate document
  registrationCertificate('rc_book', 'RC Book'),
  
  /// Vehicle insurance document
  vehicleInsurance('insurance', 'Insurance'),
  
  /// Profile picture
  profilePicture('profile_picture', 'Profile Picture'),
  
  /// Aadhaar card document
  aadhaarCard('aadhaar', 'Aadhaar Card'),
  
  /// PAN card document
  panCard('pan', 'PAN Card'),
  
  /// Address proof document
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
           this == DocumentType.aadhaarCard ||
           this == DocumentType.panCard;
  }

  /// Returns whether this document requires both front and back images
  bool get requiresBothSides {
    return this == DocumentType.drivingLicense || 
           this == DocumentType.aadhaarCard;
  }

  /// Returns the icon path for this document type
  String get iconPath {
    switch (this) {
      case DocumentType.drivingLicense:
        return 'assets/icons/driving_license.png';
      case DocumentType.registrationCertificate:
        return 'assets/icons/registration_certificate.png';
      case DocumentType.vehicleInsurance:
        return 'assets/icons/vehicle_insurance.png';
      case DocumentType.profilePicture:
        return 'assets/icons/profile_picture.png';
      case DocumentType.aadhaarCard:
        return 'assets/icons/aadhaar_card.png';
      case DocumentType.panCard:
        return 'assets/icons/pan_card.png';
      case DocumentType.addressProof:
        return 'assets/icons/address_proof.png';
    }
  }

  /// Returns the description for this document type
  String get description {
    switch (this) {
      case DocumentType.drivingLicense:
        return 'Upload a clear photo of your driving license';
      case DocumentType.registrationCertificate:
        return 'Upload a clear photo of your vehicle registration certificate';
      case DocumentType.vehicleInsurance:
        return 'Upload a clear photo of your vehicle insurance document';
      case DocumentType.profilePicture:
        return 'Upload a clear photo of yourself';
      case DocumentType.aadhaarCard:
        return 'Upload a clear photo of your Aadhaar card';
      case DocumentType.panCard:
        return 'Upload a clear photo of your PAN card';
      case DocumentType.addressProof:
        return 'Upload a clear photo of your address proof document';
    }
  }
}

/// {@template document_status}
/// Enum representing the upload and verification status of a document.
/// {@endtemplate}
enum DocumentStatus {
  /// Document upload is pending
  pending('pending', 'Pending'),
  
  /// Document is being uploaded
  uploading('uploading', 'Uploading'),
  
  /// Document upload completed successfully
  uploaded('uploaded', 'Uploaded'),
  
  /// Document is being verified
  verifying('verifying', 'Verifying'),
  
  /// Document verification completed successfully
  verified('verified', 'Verified'),
  
  /// Document verification failed
  rejected('rejected', 'Rejected');

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

/// {@template document_upload}
/// A model representing a document upload with file information and status.
/// {@endtemplate}
class DocumentUpload extends Equatable {
  /// {@macro document_upload}
  const DocumentUpload({
    this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.isRequired,
    this.status = DocumentStatus.pending,
    this.frontImagePath,
    this.backImagePath,
    this.fileName,
    this.fileSize,
    this.uploadProgress = 0.0,
    this.rejectionReason,
    this.isRecommendedNext = false,
    this.uploadedAt,
    this.verifiedAt,
    this.expiryDate,
    this.expiryNotificationEnabled = true,
  });

  /// The unique ID of the document.
  final String? id;

  /// The type of document.
  final DocumentType type;

  /// The display title of the document.
  final String title;

  /// The description or instructions for the document.
  final String description;

  /// Whether this document is required for verification.
  final bool isRequired;

  /// The current status of the document.
  final DocumentStatus status;

  /// Path to the front image of the document (if applicable).
  final String? frontImagePath;

  /// Path to the back image of the document (if applicable).
  final String? backImagePath;

  /// Name of the uploaded file.
  final String? fileName;

  /// Size of the uploaded file in bytes.
  final int? fileSize;

  /// Upload progress percentage (0.0 to 1.0).
  final double uploadProgress;

  /// Reason for rejection if document was rejected.
  final String? rejectionReason;

  /// Whether this document is marked as the recommended next step.
  final bool isRecommendedNext;

  /// When the document was uploaded.
  final DateTime? uploadedAt;

  /// When the document was verified.
  final DateTime? verifiedAt;

  /// When the document expires (if applicable).
  final DateTime? expiryDate;

  /// Whether expiry notifications are enabled for this document.
  final bool expiryNotificationEnabled;

  /// Returns whether this document has been uploaded
  bool get isUploaded => frontImagePath != null || backImagePath != null;

  /// Returns whether this document is currently being processed
  bool get isProcessing => status.isInProgress;

  /// Returns whether this document is verified
  bool get isVerified => status.isCompleted;

  /// Returns whether this document needs attention
  bool get needsAttention => status.needsAttention;

  /// Returns whether this document is expired
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  /// Returns whether this document is expiring soon (within 30 days)
  bool get isExpiringSoon {
    if (expiryDate == null || isExpired) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 30;
  }

  /// Returns the number of days until expiry (negative if expired)
  int get daysUntilExpiry {
    if (expiryDate == null) return 0;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  /// Returns a formatted expiry status string
  String get expiryStatus {
    if (expiryDate == null) return 'No expiry';
    if (isExpired) return 'Expired';
    if (isExpiringSoon) return 'Expiring soon';
    return 'Valid';
  }

  /// Returns the formatted file size
  String get formattedFileSize {
    if (fileSize == null) return '';
    if (fileSize! < 1024) return '${fileSize}B';
    if (fileSize! < 1024 * 1024) return '${(fileSize! / 1024).toStringAsFixed(1)}KB';
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  /// Creates a copy of this document upload with the given fields replaced.
  DocumentUpload copyWith({
    String? id,
    DocumentType? type,
    String? title,
    String? description,
    bool? isRequired,
    DocumentStatus? status,
    String? frontImagePath,
    String? backImagePath,
    String? fileName,
    int? fileSize,
    double? uploadProgress,
    String? rejectionReason,
    bool? isRecommendedNext,
    DateTime? uploadedAt,
    DateTime? verifiedAt,
    DateTime? expiryDate,
    bool? expiryNotificationEnabled,
  }) {
    return DocumentUpload(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      isRequired: isRequired ?? this.isRequired,
      status: status ?? this.status,
      frontImagePath: frontImagePath ?? this.frontImagePath,
      backImagePath: backImagePath ?? this.backImagePath,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      isRecommendedNext: isRecommendedNext ?? this.isRecommendedNext,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      expiryDate: expiryDate ?? this.expiryDate,
      expiryNotificationEnabled: expiryNotificationEnabled ?? this.expiryNotificationEnabled,
    );
  }

  /// Creates a document upload from a JSON map.
  factory DocumentUpload.fromJson(Map<String, dynamic> json) {
    return DocumentUpload(
      id: json['id'] as String?,
      type: DocumentType.fromString(json['type'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      isRequired: json['isRequired'] as bool,
      status: DocumentStatus.fromString(json['status'] as String),
      frontImagePath: json['frontImagePath'] as String?,
      backImagePath: json['backImagePath'] as String?,
      fileName: json['fileName'] as String?,
      fileSize: json['fileSize'] as int?,
      uploadProgress: (json['uploadProgress'] as num?)?.toDouble() ?? 0.0,
      rejectionReason: json['rejectionReason'] as String?,
      isRecommendedNext: json['isRecommendedNext'] as bool? ?? false,
      uploadedAt: json['uploadedAt'] != null 
          ? DateTime.parse(json['uploadedAt'] as String) 
          : null,
      verifiedAt: json['verifiedAt'] != null 
          ? DateTime.parse(json['verifiedAt'] as String) 
          : null,
      expiryDate: json['expiryDate'] != null 
          ? DateTime.parse(json['expiryDate'] as String) 
          : null,
      expiryNotificationEnabled: json['expiryNotificationEnabled'] as bool? ?? true,
    );
  }

  /// Converts this document upload to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'title': title,
      'description': description,
      'isRequired': isRequired,
      'status': status.value,
      'frontImagePath': frontImagePath,
      'backImagePath': backImagePath,
      'fileName': fileName,
      'fileSize': fileSize,
      'uploadProgress': uploadProgress,
      'rejectionReason': rejectionReason,
      'isRecommendedNext': isRecommendedNext,
      'uploadedAt': uploadedAt?.toIso8601String(),
      'verifiedAt': verifiedAt?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'expiryNotificationEnabled': expiryNotificationEnabled,
    };
  }

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        description,
        isRequired,
        status,
        frontImagePath,
        backImagePath,
        fileName,
        fileSize,
        uploadProgress,
        rejectionReason,
        isRecommendedNext,
        uploadedAt,
        verifiedAt,
        expiryDate,
        expiryNotificationEnabled,
      ];

  @override
  String toString() {
    return 'DocumentUpload(type: $type, title: $title, status: $status)';
  }
}

/// {@template document_upload_request}
/// A model representing a request to upload a document.
/// {@endtemplate}
class DocumentUploadRequest extends Equatable {
  /// {@macro document_upload_request}
  const DocumentUploadRequest({
    required this.type,
    required this.filePath,
    this.fileName,
    this.fileSize,
    this.metadata,
  });

  /// The type of document being uploaded.
  final DocumentType type;

  /// Path to the file being uploaded.
  final String filePath;

  /// Name of the file being uploaded.
  final String? fileName;

  /// Size of the file being uploaded in bytes.
  final int? fileSize;

  /// Additional metadata for the upload.
  final Map<String, dynamic>? metadata;

  /// Converts this request to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
      'filePath': filePath,
      'fileName': fileName,
      'fileSize': fileSize,
      'metadata': metadata,
    };
  }

  /// Creates a document upload request from a JSON map.
  factory DocumentUploadRequest.fromJson(Map<String, dynamic> json) {
    return DocumentUploadRequest(
      type: DocumentType.fromString(json['type'] as String),
      filePath: json['filePath'] as String,
      fileName: json['fileName'] as String?,
      fileSize: json['fileSize'] as int?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  DocumentUploadRequest copyWith({
    DocumentType? type,
    String? filePath,
    String? fileName,
    int? fileSize,
    Map<String, dynamic>? metadata,
  }) {
    return DocumentUploadRequest(
      type: type ?? this.type,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [type, filePath, fileName, fileSize, metadata];

  @override
  String toString() {
    return 'DocumentUploadRequest(type: $type, filePath: $filePath, fileName: $fileName)';
  }
}
