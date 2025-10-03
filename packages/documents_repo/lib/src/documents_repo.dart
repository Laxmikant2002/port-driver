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

  /// Upload a document (front or back image)
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
        DocumentsPaths.uploadDocument,
        file: file,
        fieldName: 'file',
        additionalFields: {
          'documentType': request.type.value,
          'fileName': request.fileName,
          'fileSize': request.fileSize,
          'metadata': request.metadata,
          'isBackImage': request.isBackImage,
        },
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

  /// Upload both front and back images for a document
  Future<DocumentResponse> uploadDocumentWithBothSides({
    required DocumentType type,
    required String frontImagePath,
    required String backImagePath,
    String? fileName,
    int? fileSize,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Upload front image
      final frontRequest = DocumentUploadRequest(
        type: type,
        filePath: frontImagePath,
        fileName: fileName,
        fileSize: fileSize,
        metadata: metadata,
        isBackImage: false,
      );

      final frontResponse = await uploadDocument(frontRequest);
      if (!frontResponse.success) {
        return frontResponse;
      }

      // Upload back image
      final backRequest = DocumentUploadRequest(
        type: type,
        filePath: backImagePath,
        fileName: fileName,
        fileSize: fileSize,
        metadata: metadata,
        isBackImage: true,
      );

      final backResponse = await uploadDocument(backRequest);
      if (!backResponse.success) {
        return backResponse;
      }

      // Return success response
      return DocumentResponse(
        success: true,
        message: 'Both front and back images uploaded successfully',
        document: frontResponse.document,
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
      final response = await apiClient.get<Map<String, dynamic>>(DocumentsPaths.getDocuments);

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
      final response = await apiClient.get<Map<String, dynamic>>('${DocumentsPaths.getDocument}/$documentId');

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
      final response = await apiClient.delete<Map<String, dynamic>>('${DocumentsPaths.deleteDocument}/$documentId');

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
        DocumentsPaths.getDocuments,
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

  /// Get verification status
  Future<Map<String, dynamic>?> getVerificationStatus() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(DocumentsPaths.getVerificationStatus);

      if (response is DataSuccess) {
        return response.data!;
      }

      return null;
    } catch (e) {
      return null;
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
        DocumentType.aadhaar,
        DocumentType.pan,
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

  /// Get required document types
  Future<List<DocumentType>> getRequiredDocumentTypes() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(DocumentsPaths.getRequiredDocuments);

      if (response is DataSuccess) {
        final data = response.data!;
        final types = (data['requiredTypes'] as List<dynamic>)
            .map((e) => DocumentType.fromString(e as String))
            .toList();
        return types;
      }

      return [DocumentType.drivingLicense, DocumentType.aadhaar, DocumentType.pan];
    } catch (e) {
      return [DocumentType.drivingLicense, DocumentType.aadhaar, DocumentType.pan];
    }
  }
}
