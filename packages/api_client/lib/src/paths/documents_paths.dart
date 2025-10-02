import 'package:api_client/src/paths/base_paths.dart';

class DocumentsPaths extends BasePaths {
  // Document Management
  static final String uploadDocument = "${BasePaths.baseUrl}/driver/documents/upload";
  static final String getDocuments = "${BasePaths.baseUrl}/driver/documents";
  static final String getDocument = "${BasePaths.baseUrl}/driver/documents";
  static final String deleteDocument = "${BasePaths.baseUrl}/driver/documents";
  
  // Document Verification (Admin endpoints - for reference)
  static final String verifyDocument = "${BasePaths.baseUrl}/admin/documents/verify";
  static final String getPendingDocuments = "${BasePaths.baseUrl}/admin/documents/pending";
  
  // Document Status & Verification
  static final String getVerificationStatus = "${BasePaths.baseUrl}/driver/verification-status";
  static final String checkDocumentStatus = "${BasePaths.baseUrl}/driver/documents/status";
  
  // Document Types
  static final String getDocumentTypes = "${BasePaths.baseUrl}/driver/documents/types";
  static final String getRequiredDocuments = "${BasePaths.baseUrl}/driver/documents/required";
}
