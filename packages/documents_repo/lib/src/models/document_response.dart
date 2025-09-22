import 'package:equatable/equatable.dart';
import 'document.dart';

/// Document response model for API responses
class DocumentResponse extends Equatable {
  const DocumentResponse({
    required this.success,
    this.message,
    this.documents,
    this.document,
  });

  final bool success;
  final String? message;
  final List<Document>? documents;
  final Document? document;

  factory DocumentResponse.fromJson(Map<String, dynamic> json) {
    return DocumentResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      documents: json['documents'] != null
          ? (json['documents'] as List<dynamic>)
              .map((e) => Document.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      document: json['document'] != null
          ? Document.fromJson(json['document'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'documents': documents?.map((e) => e.toJson()).toList(),
      'document': document?.toJson(),
    };
  }

  DocumentResponse copyWith({
    bool? success,
    String? message,
    List<Document>? documents,
    Document? document,
  }) {
    return DocumentResponse(
      success: success ?? this.success,
      message: message ?? this.message,
      documents: documents ?? this.documents,
      document: document ?? this.document,
    );
  }

  @override
  List<Object?> get props => [success, message, documents, document];

  @override
  String toString() {
    return 'DocumentResponse(success: $success, message: $message, documents: ${documents?.length}, document: $document)';
  }
}