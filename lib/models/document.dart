import 'package:equatable/equatable.dart';

/// {@template document_type}
/// Enum representing different types of documents required for verification.
/// {@endtemplate}
enum DocumentType {
  /// Driving license document
  drivingLicense,
  
  /// Registration certificate document
  registrationCertificate,
  
  /// Vehicle insurance document
  vehicleInsurance,
  
  /// Profile picture
  profilePicture,
  
  /// Aadhaar card document
  aadhaarCard,
}

/// {@template document_status}
/// Enum representing the upload and verification status of a document.
/// {@endtemplate}
enum DocumentStatus {
  /// Document upload is pending
  pending,
  
  /// Document is being uploaded
  uploading,
  
  /// Document upload completed successfully
  uploaded,
  
  /// Document is being verified
  verifying,
  
  /// Document verification completed successfully
  verified,
  
  /// Document verification failed
  rejected,
}

/// {@template document}
/// A model representing a document required for driver verification.
/// {@endtemplate}
class Document extends Equatable {
  /// {@macro document}
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

  /// Upload progress percentage (0.0 to 1.0).
  final double uploadProgress;

  /// Reason for rejection if document was rejected.
  final String? rejectionReason;

  /// Whether this document is marked as the recommended next step.
  final bool isRecommendedNext;

  /// Creates a copy of this document with the given fields replaced.
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

  /// Creates a document from a JSON map.
  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      type: DocumentType.values[json['type'] as int],
      title: json['title'] as String,
      description: json['description'] as String,
      isRequired: json['isRequired'] as bool,
      status: DocumentStatus.values[json['status'] as int],
      frontImagePath: json['frontImagePath'] as String?,
      backImagePath: json['backImagePath'] as String?,
      uploadProgress: (json['uploadProgress'] as num?)?.toDouble() ?? 0.0,
      rejectionReason: json['rejectionReason'] as String?,
      isRecommendedNext: json['isRecommendedNext'] as bool? ?? false,
    );
  }

  /// Converts this document to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'title': title,
      'description': description,
      'isRequired': isRequired,
      'status': status.index,
      'frontImagePath': frontImagePath,
      'backImagePath': backImagePath,
      'uploadProgress': uploadProgress,
      'rejectionReason': rejectionReason,
      'isRecommendedNext': isRecommendedNext,
    };
  }

  /// Returns the icon for this document type.
  String get iconPath {
    switch (type) {
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
    }
  }

  /// Returns whether this document requires both front and back images.
  bool get requiresBothSides {
    return type == DocumentType.drivingLicense || 
           type == DocumentType.aadhaarCard;
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

  @override
  String toString() {
    return 'Document(type: $type, title: $title, status: $status)';
  }
}