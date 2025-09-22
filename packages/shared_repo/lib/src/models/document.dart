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
  drivingLicense,
  registrationCertificate,
  vehicleInsurance,
  profilePicture,
  aadhaarCard,
}

/// Document status
enum DocumentStatus {
  pending,
  uploading,
  uploaded,
  verifying,
  verified,
  rejected,
}
