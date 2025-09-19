import 'package:equatable/equatable.dart';
import 'document.dart';

/// Request model for document upload
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
      'fileName': fileName,
      'metadata': metadata,
    };
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
    return 'DocumentUploadRequest('
        'type: $type, '
        'filePath: $filePath, '
        'fileName: $fileName, '
        'metadata: $metadata'
        ')';
  }
}
