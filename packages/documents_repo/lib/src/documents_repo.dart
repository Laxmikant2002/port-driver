import 'dart:io';
import 'package:api_client/api_client.dart';
import 'package:documents_repo/src/models/document.dart';
import 'package:documents_repo/src/models/document_upload_request.dart';
import 'package:documents_repo/src/models/document_response.dart';
import 'package:localstorage/localstorage.dart';

/// Documents Repository for managing driver documents
class DocumentsRepo {
  const DocumentsRepo({
    required this.apiClient,
    required this.localStorage,
  });

  final ApiClient apiClient;
  final Localstorage localStorage;

  /// Upload a document
  Future<DocumentResponse> uploadDocument(DocumentUploadRequest request) async {
    try {
      final file = File(request.filePath);
      if (!await file.exists()) {
        return DocumentResponse(
          success: false,
          message: 'File not found: ${request.filePath}',
        );
      }

      final response = await apiClient.uploadFile<Map<String, dynamic>>(
        '/documents/upload',
        file: file,
        fieldName: 'document',
        additionalFields: request.toJson(),
      );

      if (response is DataSuccess) {
        final data = response.data!;
        return DocumentResponse.fromJson(data);
      }

      if (response is DataFailed) {
        return DocumentResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Failed to upload document',
        );
      }

      return DocumentResponse(
        success: false,
        message: 'Unexpected error occurred',
      );
    } catch (e) {
      return DocumentResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get all documents for the current driver
  Future<DocumentResponse> getDocuments() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>('/documents');

      if (response is DataSuccess) {
        final data = response.data!;
        return DocumentResponse.fromJson(data);
      }

      if (response is DataFailed) {
        return DocumentResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Failed to fetch documents',
        );
      }

      return DocumentResponse(
        success: false,
        message: 'Unexpected error occurred',
      );
    } catch (e) {
      return DocumentResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get a specific document by ID
  Future<DocumentResponse> getDocument(String documentId) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>('/documents/$documentId');

      if (response is DataSuccess) {
        final data = response.data!;
        return DocumentResponse.fromJson(data);
      }

      if (response is DataFailed) {
        return DocumentResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Failed to fetch document',
        );
      }

      return DocumentResponse(
        success: false,
        message: 'Unexpected error occurred',
      );
    } catch (e) {
      return DocumentResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Delete a document
  Future<DocumentResponse> deleteDocument(String documentId) async {
    try {
      final response = await apiClient.delete<Map<String, dynamic>>('/documents/$documentId');

      if (response is DataSuccess) {
        final data = response.data!;
        return DocumentResponse.fromJson(data);
      }

      if (response is DataFailed) {
        return DocumentResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Failed to delete document',
        );
      }

      return DocumentResponse(
        success: false,
        message: 'Unexpected error occurred',
      );
    } catch (e) {
      return DocumentResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get documents by type
  Future<DocumentResponse> getDocumentsByType(DocumentType type) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '/documents',
        queryParameters: {'type': type.value},
      );

      if (response is DataSuccess) {
        final data = response.data!;
        return DocumentResponse.fromJson(data);
      }

      if (response is DataFailed) {
        return DocumentResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Failed to fetch documents',
        );
      }

      return DocumentResponse(
        success: false,
        message: 'Unexpected error occurred',
      );
    } catch (e) {
      return DocumentResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Check if all required documents are uploaded and verified
  Future<bool> areAllDocumentsVerified() async {
    try {
      final response = await getDocuments();
      if (!response.success || response.documents == null) {
        return false;
      }

      final requiredTypes = [
        DocumentType.drivingLicense,
        DocumentType.insurance,
        DocumentType.aadhaar,
      ];

      for (final type in requiredTypes) {
        final document = response.documents!.firstWhere(
          (doc) => doc.type == type,
          orElse: () => throw StateError('DriverDocument not found'),
        );

        if (document.status != DocumentStatus.verified) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get document verification status summary
  Future<Map<DocumentType, DocumentStatus>> getDocumentStatusSummary() async {
    try {
      final response = await getDocuments();
      if (!response.success || response.documents == null) {
        return {};
      }

      final Map<DocumentType, DocumentStatus> statusMap = {};
      
      for (final document in response.documents!) {
        statusMap[document.type] = document.status;
      }

      return statusMap;
    } catch (e) {
      return {};
    }
  }
}
