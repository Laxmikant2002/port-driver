import 'package:equatable/equatable.dart';
import 'document.dart';

/// Response model for document operations
class DocumentResponse extends Equatable {
  const DocumentResponse({
    required this.success,
    this.document,
    this.documents,
    this.message,
  });

  final bool success;
  final Document? document;
  final List<Document>? documents;
  final String? message;

  factory DocumentResponse.fromJson(Map<String, dynamic> json) {
    return DocumentResponse(
      success: json['success'] as bool? ?? false,
      document: json['document'] != null 
          ? Document.fromJson(json['document'] as Map<String, dynamic>)
          : null,
      documents: json['documents'] != null
          ? (json['documents'] as List)
              .map((doc) => Document.fromJson(doc as Map<String, dynamic>))
              .toList()
          : null,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'document': document?.toJson(),
      'documents': documents?.map((doc) => doc.toJson()).toList(),
      'message': message,
    };
  }

  DocumentResponse copyWith({
    bool? success,
    Document? document,
    List<Document>? documents,
    String? message,
  }) {
    return DocumentResponse(
      success: success ?? this.success,
      document: document ?? this.document,
      documents: documents ?? this.documents,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [success, document, documents, message];

  @override
  String toString() {
    return 'DocumentResponse('
        'success: $success, '
        'document: $document, '
        'documents: ${documents?.length ?? 0}, '
        'message: $message'
        ')';
  }
}
