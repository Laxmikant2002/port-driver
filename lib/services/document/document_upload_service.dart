import 'dart:io';
import 'package:documents_repo/documents_repo.dart';
import 'package:documents_repo/src/models/document.dart' as documents_repo;
import 'package:documents_repo/src/models/document_upload_request.dart' as documents_repo;
import 'package:driver/core/error/document_upload_error.dart';
import 'package:driver/models/document_upload.dart' as local_models;

/// {@template document_upload_service}
/// Service for handling document upload operations with proper error handling.
/// {@endtemplate}
class DocumentUploadService {
  /// {@macro document_upload_service}
  const DocumentUploadService({
    required this.documentsRepo,
  });

  final DocumentsRepo documentsRepo;

  /// Uploads a single document image
  Future<DocumentUploadResult> uploadDocument({
    required local_models.DocumentType type,
    required String filePath,
    String? fileName,
    int? fileSize,
    bool isBackImage = false,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Validate file before upload
      final validationError = DocumentUploadErrorHandler.validateFile(filePath, fileName ?? '');
      if (validationError != null) {
        return DocumentUploadResult.failure(validationError);
      }

      // Check file size
      final file = File(filePath);
      if (await file.exists()) {
        final actualFileSize = await file.length();
        if (actualFileSize > DocumentUploadErrorHandler.maxFileSize) {
          return DocumentUploadResult.failure(
            FileSizeError(
              actualSize: actualFileSize,
              maxSize: DocumentUploadErrorHandler.maxFileSize,
            ),
          );
        }
      } else {
        return DocumentUploadResult.failure(FileNotFoundError(filePath: filePath));
      }

      // Create upload request
      final request = documents_repo.DocumentUploadRequest(
        type: _convertToRepoDocumentType(type),
        filePath: filePath,
        fileName: fileName,
        fileSize: fileSize,
        metadata: metadata,
        isBackImage: isBackImage,
      );

      // Upload document
      final response = await documentsRepo.uploadDocument(request);
      
      if (response.success) {
        return DocumentUploadResult.success(
          message: 'Document uploaded successfully',
          document: response.document,
        );
      } else {
        return DocumentUploadResult.failure(
          UploadFailedError(
            message: response.message ?? 'Upload failed',
            retryable: true,
          ),
        );
      }
    } catch (e) {
      final error = DocumentUploadErrorHandler.handleException(e);
      return DocumentUploadResult.failure(error);
    }
  }

  /// Uploads both front and back images for a document
  Future<DocumentUploadResult> uploadDocumentWithBothSides({
    required local_models.DocumentType type,
    required String frontImagePath,
    required String backImagePath,
    String? fileName,
    int? fileSize,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Validate both files
      final frontValidation = DocumentUploadErrorHandler.validateFile(frontImagePath, fileName ?? '');
      if (frontValidation != null) {
        return DocumentUploadResult.failure(frontValidation);
      }

      final backValidation = DocumentUploadErrorHandler.validateFile(backImagePath, fileName ?? '');
      if (backValidation != null) {
        return DocumentUploadResult.failure(backValidation);
      }

      // Check file sizes
      final frontFile = File(frontImagePath);
      final backFile = File(backImagePath);

      if (!await frontFile.exists()) {
        return DocumentUploadResult.failure(FileNotFoundError(filePath: frontImagePath));
      }
      if (!await backFile.exists()) {
        return DocumentUploadResult.failure(FileNotFoundError(filePath: backImagePath));
      }

      final frontFileSize = await frontFile.length();
      final backFileSize = await backFile.length();

      if (frontFileSize > DocumentUploadErrorHandler.maxFileSize) {
        return DocumentUploadResult.failure(
          FileSizeError(
            actualSize: frontFileSize,
            maxSize: DocumentUploadErrorHandler.maxFileSize,
          ),
        );
      }

      if (backFileSize > DocumentUploadErrorHandler.maxFileSize) {
        return DocumentUploadResult.failure(
          FileSizeError(
            actualSize: backFileSize,
            maxSize: DocumentUploadErrorHandler.maxFileSize,
          ),
        );
      }

      // Upload both images
      final response = await documentsRepo.uploadDocumentWithBothSides(
        type: _convertToRepoDocumentType(type),
        frontImagePath: frontImagePath,
        backImagePath: backImagePath,
        fileName: fileName,
        fileSize: fileSize,
        metadata: metadata,
      );

      if (response.success) {
        return DocumentUploadResult.success(
          message: 'Both front and back images uploaded successfully',
          document: response.document,
        );
      } else {
        return DocumentUploadResult.failure(
          UploadFailedError(
            message: response.message ?? 'Upload failed',
            retryable: true,
          ),
        );
      }
    } catch (e) {
      final error = DocumentUploadErrorHandler.handleException(e);
      return DocumentUploadResult.failure(error);
    }
  }

  /// Gets all documents for the current driver
  Future<DocumentListResult> getDocuments() async {
    try {
      final response = await documentsRepo.getDocuments();
      
      if (response.success && response.documents != null) {
        return DocumentListResult.success(
          documents: response.documents!,
          message: 'Documents loaded successfully',
        );
      } else {
        return DocumentListResult.failure(
          UploadFailedError(
            message: response.message ?? 'Failed to load documents',
            retryable: true,
          ),
        );
      }
    } catch (e) {
      final error = DocumentUploadErrorHandler.handleException(e);
      return DocumentListResult.failure(error);
    }
  }

  /// Deletes a document
  Future<DocumentUploadResult> deleteDocument(String documentId) async {
    try {
      final response = await documentsRepo.deleteDocument(documentId);
      
      if (response.success) {
        return DocumentUploadResult.success(
          message: 'Document deleted successfully',
          document: response.document,
        );
      } else {
        return DocumentUploadResult.failure(
          UploadFailedError(
            message: response.message ?? 'Failed to delete document',
            retryable: true,
          ),
        );
      }
    } catch (e) {
      final error = DocumentUploadErrorHandler.handleException(e);
      return DocumentUploadResult.failure(error);
    }
  }

  /// Converts local DocumentType to documents_repo DocumentType
  documents_repo.DocumentType _convertToRepoDocumentType(local_models.DocumentType localType) {
    switch (localType) {
      case local_models.DocumentType.drivingLicense:
        return documents_repo.DocumentType.drivingLicense;
      case local_models.DocumentType.registrationCertificate:
        return documents_repo.DocumentType.rcBook;
      case local_models.DocumentType.vehicleInsurance:
        return documents_repo.DocumentType.insurance;
      case local_models.DocumentType.profilePicture:
        return documents_repo.DocumentType.profilePicture;
      case local_models.DocumentType.aadhaarCard:
        return documents_repo.DocumentType.aadhaar;
      case local_models.DocumentType.panCard:
        return documents_repo.DocumentType.pan;
      case local_models.DocumentType.addressProof:
        return documents_repo.DocumentType.addressProof;
    }
  }
}

/// {@template document_upload_result}
/// Result of a document upload operation.
/// {@endtemplate}
class DocumentUploadResult {
  /// {@macro document_upload_result}
  const DocumentUploadResult._({
    required this.isSuccess,
    this.message,
    this.document,
    this.error,
  });

  /// Whether the operation was successful
  final bool isSuccess;

  /// Success message
  final String? message;

  /// Uploaded document
  final documents_repo.DriverDocument? document;

  /// Error if operation failed
  final DocumentUploadError? error;

  /// Creates a successful result
  factory DocumentUploadResult.success({
    required String message,
    documents_repo.DriverDocument? document,
  }) {
    return DocumentUploadResult._(
      isSuccess: true,
      message: message,
      document: document,
    );
  }

  /// Creates a failed result
  factory DocumentUploadResult.failure(DocumentUploadError error) {
    return DocumentUploadResult._(
      isSuccess: false,
      error: error,
    );
  }

  /// Whether the operation failed
  bool get isFailure => !isSuccess;

  /// Gets user-friendly error message
  String? get errorMessage => error != null 
      ? DocumentUploadErrorHandler.getUserFriendlyMessage(error!) 
      : null;
}

/// {@template document_list_result}
/// Result of a document list operation.
/// {@endtemplate}
class DocumentListResult {
  /// {@macro document_list_result}
  const DocumentListResult._({
    required this.isSuccess,
    this.documents,
    this.message,
    this.error,
  });

  /// Whether the operation was successful
  final bool isSuccess;

  /// List of documents
  final List<documents_repo.DriverDocument>? documents;

  /// Success message
  final String? message;

  /// Error if operation failed
  final DocumentUploadError? error;

  /// Creates a successful result
  factory DocumentListResult.success({
    required List<documents_repo.DriverDocument> documents,
    required String message,
  }) {
    return DocumentListResult._(
      isSuccess: true,
      documents: documents,
      message: message,
    );
  }

  /// Creates a failed result
  factory DocumentListResult.failure(DocumentUploadError error) {
    return DocumentListResult._(
      isSuccess: false,
      error: error,
    );
  }

  /// Whether the operation failed
  bool get isFailure => !isSuccess;

  /// Gets user-friendly error message
  String? get errorMessage => error != null 
      ? DocumentUploadErrorHandler.getUserFriendlyMessage(error!) 
      : null;
}
