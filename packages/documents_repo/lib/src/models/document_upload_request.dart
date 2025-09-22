import 'package:equatable/equatable.dart';
import 'document.dart';

/// Document upload request model
class DocumentUploadRequest extends Equatable {
  const DocumentUploadRequest({
    required this.type,
    required this.filePath,
    this.fileName,
    this.metadata,
  });

  final DocumentType type;
  final String filePath;
  final String? fileName;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
      'filePath': filePath,
      'fileName': fileName,
      'metadata': metadata,
    };
  }

  factory DocumentUploadRequest.fromJson(Map<String, dynamic> json) {
    return DocumentUploadRequest(
      type: DocumentType.fromString(json['type'] as String),
      filePath: json['filePath'] as String,
      fileName: json['fileName'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  DocumentUploadRequest copyWith({
    DocumentType? type,
    String? filePath,
    String? fileName,
    Map<String, dynamic>? metadata,
  }) {
    return DocumentUploadRequest(
      type: type ?? this.type,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [type, filePath, fileName, metadata];

  @override
  String toString() {
    return 'DocumentUploadRequest(type: $type, filePath: $filePath, fileName: $fileName)';
  }
}