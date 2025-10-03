import 'package:documents_repo/documents_repo.dart';
import 'package:documents_repo/src/models/document.dart' as documents_repo;
import 'package:documents_repo/src/models/document_upload_request.dart' as documents_repo;
import 'package:driver/core/error/document_upload_error.dart';
import 'package:driver/models/document_upload.dart' as local_models;
import 'package:driver/services/core/service_interface.dart';
import 'package:driver/services/document/document_quality_validator.dart';
import 'package:driver/services/document/document_expiry_tracker.dart';
import 'package:driver/services/document/document_backup_service.dart';
import 'package:driver/services/document/document_verification_monitor.dart';

/// {@template document_service_interface}
/// Interface for document-related operations.
/// {@endtemplate}
abstract class DocumentServiceInterface extends ServiceInterface {
  /// {@macro document_service_interface}
  const DocumentServiceInterface();

  /// Upload a single document
  Future<ServiceResult<documents_repo.DriverDocument>> uploadDocument({
    required local_models.DocumentType type,
    required String filePath,
    required String fileName,
    required int fileSize,
    bool isBackImage = false,
  });

  /// Upload both front and back images for a document
  Future<ServiceResult<documents_repo.DriverDocument>> uploadDualSidedDocument({
    required local_models.DocumentType type,
    required String frontImagePath,
    required String frontFileName,
    required int frontFileSize,
    required String backImagePath,
    required String backFileName,
    required int backFileSize,
  });

  /// Get all documents for the current driver
  Future<ServiceResult<List<local_models.DocumentUpload>>> getDocuments();

  /// Get document by ID
  Future<ServiceResult<local_models.DocumentUpload>> getDocument(String documentId);

  /// Delete a document
  Future<ServiceResult<void>> deleteDocument(String documentId);

  /// Check if all required documents are verified
  Future<ServiceResult<bool>> areAllDocumentsVerified();
}

/// {@template document_quality_service_interface}
/// Interface for document quality validation operations.
/// {@endtemplate}
abstract class DocumentQualityServiceInterface extends ServiceInterface {
  /// {@macro document_quality_service_interface}
  const DocumentQualityServiceInterface();

  /// Validate document quality
  Future<ServiceResult<DocumentQualityResult>> validateDocument({
    required String imagePath,
    required documents_repo.DocumentType documentType,
  });

  /// Auto-crop document based on detected edges
  Future<ServiceResult<String?>> autoCropDocument({
    required String imagePath,
    required documents_repo.DocumentType documentType,
  });

  /// Get quality validation tips for document type
  List<String> getQualityTips(documents_repo.DocumentType documentType);
}

/// {@template document_expiry_service_interface}
/// Interface for document expiry tracking operations.
/// {@endtemplate}
abstract class DocumentExpiryServiceInterface extends ServiceInterface {
  /// {@macro document_expiry_service_interface}
  const DocumentExpiryServiceInterface();

  /// Check for expiring documents
  Future<ServiceResult<List<DocumentExpiryAlert>>> checkExpiringDocuments(
    List<documents_repo.DriverDocument> documents,
  );

  /// Get renewal recommendations
  Future<ServiceResult<List<DocumentRenewalRecommendation>>> getRenewalRecommendations(
    List<documents_repo.DriverDocument> documents,
  );

  /// Schedule expiry notifications
  Future<ServiceResult<void>> scheduleExpiryNotifications(
    List<DocumentExpiryAlert> alerts,
  );
}

/// {@template document_backup_service_interface}
/// Interface for document backup and sync operations.
/// {@endtemplate}
abstract class DocumentBackupServiceInterface extends ServiceInterface {
  /// {@macro document_backup_service_interface}
  const DocumentBackupServiceInterface();

  /// Backup all documents locally
  Future<ServiceResult<BackupResult>> backupDocumentsLocally();

  /// Restore documents from backup
  Future<ServiceResult<RestoreResult>> restoreFromBackup();

  /// Sync documents with cloud storage
  Future<ServiceResult<SyncResult>> syncWithCloud();

  /// Get backup information for a document
  ServiceResult<DocumentBackupInfo?> getBackupInfo(String documentId);

  /// Clear old backups
  Future<ServiceResult<void>> clearOldBackups({Duration maxAge = const Duration(days: 30)});
}

/// {@template document_verification_service_interface}
/// Interface for document verification monitoring operations.
/// {@endtemplate}
abstract class DocumentVerificationServiceInterface extends ServiceInterface {
  /// {@macro document_verification_service_interface}
  const DocumentVerificationServiceInterface();

  /// Start monitoring document verification status
  void startMonitoring({Duration pollingInterval = const Duration(minutes: 2)});

  /// Stop monitoring
  void stopMonitoring();

  /// Stream of verification status updates
  Stream<DocumentVerificationUpdate> get statusUpdates;

  /// Get current verification status
  Future<ServiceResult<Map<String, DocumentStatus>>> getCurrentStatus();
}

/// {@template document_service_module}
/// Main document service module that coordinates all document operations.
/// {@endtemplate}
class DocumentServiceModule {
  /// {@macro document_service_module}
  const DocumentServiceModule({
    required this.documentsRepo,
    required this.uploadService,
    required this.qualityService,
    required this.expiryService,
    required this.backupService,
    required this.verificationService,
  });

  final DocumentsRepo documentsRepo;
  final DocumentServiceInterface uploadService;
  final DocumentQualityServiceInterface qualityService;
  final DocumentExpiryServiceInterface expiryService;
  final DocumentBackupServiceInterface backupService;
  final DocumentVerificationServiceInterface verificationService;

  /// Initialize all document services
  Future<void> initialize() async {
    await uploadService.initialize();
    await qualityService.initialize();
    await expiryService.initialize();
    await backupService.initialize();
    await verificationService.initialize();
  }

  /// Dispose all document services
  Future<void> dispose() async {
    await uploadService.dispose();
    await qualityService.dispose();
    await expiryService.dispose();
    await backupService.dispose();
    await verificationService.dispose();
  }

  /// Get service health status
  Map<String, bool> get healthStatus => {
    'upload': uploadService.isInitialized,
    'quality': qualityService.isInitialized,
    'expiry': expiryService.isInitialized,
    'backup': backupService.isInitialized,
    'verification': verificationService.isInitialized,
  };
}

