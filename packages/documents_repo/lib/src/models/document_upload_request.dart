import 'package:equatable/equatable.dart';
import 'document.dart';

/// Document upload request model
class DocumentUploadRequest extends Equatable {
  const DocumentUploadRequest({
    required this.type,
    required this.filePath,
    this.fileName,
    this.fileSize,
    this.metadata,
    this.isBackImage = false,
  });

  final DocumentType type;
  final String filePath;
  final String? fileName;
  final int? fileSize;
  final Map<String, dynamic>? metadata;
  final bool isBackImage;

  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
      'filePath': filePath,
      'fileName': fileName,
      'fileSize': fileSize,
      'metadata': metadata,
      'isBackImage': isBackImage,
    };
  }

  factory DocumentUploadRequest.fromJson(Map<String, dynamic> json) {
    return DocumentUploadRequest(
      type: DocumentType.fromString(json['type'] as String),
      filePath: json['filePath'] as String,
      fileName: json['fileName'] as String?,
      fileSize: json['fileSize'] as int?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isBackImage: json['isBackImage'] as bool? ?? false,
    );
  }

  DocumentUploadRequest copyWith({
    DocumentType? type,
    String? filePath,
    String? fileName,
    int? fileSize,
    Map<String, dynamic>? metadata,
    bool? isBackImage,
  }) {
    return DocumentUploadRequest(
      type: type ?? this.type,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      metadata: metadata ?? this.metadata,
      isBackImage: isBackImage ?? this.isBackImage,
    );
  }

  @override
  List<Object?> get props => [type, filePath, fileName, fileSize, metadata, isBackImage];

  @override
  String toString() {
    return 'DocumentUploadRequest(type: $type, filePath: $filePath, fileName: $fileName)';
  }
}