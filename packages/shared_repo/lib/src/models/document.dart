import 'package:equatable/equatable.dart';

/// Document model for KYC/document verification
class Document extends Equatable {
  const Document({
    required this.type,
    required this.title,
    required this.description,
    required this.isRequired,
    this.status = DocumentStatus.pending,
    this.frontImagePath,
    this.backImagePath,
    this.uploadProgress = 0.0,
    this.rejectionReason,
    this.isRecommendedNext = false,
  });

  final DocumentType type;
  final String title;
  final String description;
  final bool isRequired;
  final DocumentStatus status;
  final String? frontImagePath;
  final String? backImagePath;
  final double uploadProgress;
  final String? rejectionReason;
  final bool isRecommendedNext;

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      type: DocumentType.fromString(json['type'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      isRequired: json['isRequired'] as bool,
      status: DocumentStatus.fromString(json['status'] as String),
      frontImagePath: json['frontImagePath'] as String?,
      backImagePath: json['backImagePath'] as String?,
      uploadProgress: (json['uploadProgress'] as num?)?.toDouble() ?? 0.0,
      rejectionReason: json['rejectionReason'] as String?,
      isRecommendedNext: json['isRecommendedNext'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
      'title': title,
      'description': description,
      'isRequired': isRequired,
      'status': status.value,
      'frontImagePath': frontImagePath,
      'backImagePath': backImagePath,
      'uploadProgress': uploadProgress,
      'rejectionReason': rejectionReason,
      'isRecommendedNext': isRecommendedNext,
    };
  }

  Document copyWith({
    DocumentType? type,
    String? title,
    String? description,
    bool? isRequired,
    DocumentStatus? status,
    String? frontImagePath,
    String? backImagePath,
    double? uploadProgress,
    String? rejectionReason,
    bool? isRecommendedNext,
  }) {
    return Document(
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      isRequired: isRequired ?? this.isRequired,
      status: status ?? this.status,
      frontImagePath: frontImagePath ?? this.frontImagePath,
      backImagePath: backImagePath ?? this.backImagePath,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      isRecommendedNext: isRecommendedNext ?? this.isRecommendedNext,
    );
  }

  @override
  List<Object?> get props => [
        type,
        title,
        description,
        isRequired,
        status,
        frontImagePath,
        backImagePath,
        uploadProgress,
        rejectionReason,
        isRecommendedNext,
      ];
}

/// Document types
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
           this == DocumentType.panCard ||
           this == DocumentType.registrationCertificate ||
           this == DocumentType.vehicleInsurance;
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

/// Document status
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
