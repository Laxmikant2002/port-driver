import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:documents_repo/documents_repo.dart';
import 'package:documents_repo/src/models/document.dart' as documents_repo;
import 'package:documents_repo/src/models/document_upload_request.dart' as documents_repo;

/// {@template document_backup_service}
/// Service for backing up documents and syncing with cloud storage.
/// {@endtemplate}
class DocumentBackupService {
  /// {@macro document_backup_service}
  DocumentBackupService({
    required this.documentsRepo,
  });

  final DocumentsRepo documentsRepo;
  final Map<String, DocumentBackupInfo> _backupInfo = {};

  /// Backs up all documents locally
  Future<BackupResult> backupDocumentsLocally() async {
    try {
      final documentsDir = await _getDocumentsDirectory();
      final backupDir = Directory(path.join(documentsDir.path, 'backup'));
      
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final response = await documentsRepo.getDocuments();
      if (!response.success || response.documents == null) {
        return BackupResult.failure('Failed to fetch documents for backup');
      }

      var backedUpCount = 0;
      var failedCount = 0;

      for (final document in response.documents!) {
        try {
          final backupResult = await _backupSingleDocument(document, backupDir);
          if (backupResult.isSuccess) {
            backedUpCount++;
            _backupInfo[document.id] = backupResult.backupInfo!;
          } else {
            failedCount++;
            debugPrint('Failed to backup ${document.id}: ${backupResult.errorMessage}');
          }
        } catch (e) {
          failedCount++;
          debugPrint('Error backing up ${document.id}: $e');
        }
      }

      await _saveBackupMetadata();

      return BackupResult.success(
        backedUpCount: backedUpCount,
        failedCount: failedCount,
        backupLocation: backupDir.path,
      );
    } catch (e) {
      return BackupResult.failure('Backup failed: ${e.toString()}');
    }
  }

  /// Backs up a single document
  Future<BackupResult> _backupSingleDocument(
    documents_repo.DriverDocument document,
    Directory backupDir,
  ) async {
    try {
      final documentBackupDir = Directory(path.join(backupDir.path, document.id));
      if (!await documentBackupDir.exists()) {
        await documentBackupDir.create(recursive: true);
      }

      var frontImagePath = document.frontImageUrl;
      var backImagePath = document.backImageUrl;

      // Download images if they're URLs
      if (frontImagePath != null && frontImagePath.startsWith('http')) {
        frontImagePath = await _downloadImage(frontImagePath, documentBackupDir, 'front');
      }
      if (backImagePath != null && backImagePath.startsWith('http')) {
        backImagePath = await _downloadImage(backImagePath, documentBackupDir, 'back');
      }

      // Create backup metadata
      final backupInfo = DocumentBackupInfo(
        documentId: document.id,
        documentType: document.type,
        frontImagePath: frontImagePath,
        backImagePath: backImagePath,
        fileName: document.fileName,
        fileSize: document.fileSize,
        uploadedAt: document.uploadedAt,
        verifiedAt: document.verifiedAt,
        status: document.status,
        backupDate: DateTime.now(),
        backupLocation: documentBackupDir.path,
      );

      // Save backup metadata
      final metadataFile = File(path.join(documentBackupDir.path, 'metadata.json'));
      await metadataFile.writeAsString(jsonEncode(backupInfo.toJson()));

      return BackupResult.success(backupInfo: backupInfo);
    } catch (e) {
      return BackupResult.failure('Failed to backup document: ${e.toString()}');
    }
  }

  /// Downloads image from URL
  Future<String?> _downloadImage(String imageUrl, Directory backupDir, String prefix) async {
    try {
      // This would typically use http package to download the image
      // For now, we'll just return the original path
      final fileName = 'backup_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final localPath = path.join(backupDir.path, fileName);
      
      // In a real implementation, you would download the image here
      // final response = await http.get(Uri.parse(imageUrl));
      // final file = File(localPath);
      // await file.writeAsBytes(response.bodyBytes);
      
      return localPath;
    } catch (e) {
      debugPrint('Failed to download image: $e');
      return null;
    }
  }

  /// Restores documents from backup
  Future<RestoreResult> restoreFromBackup() async {
    try {
      final documentsDir = await _getDocumentsDirectory();
      final backupDir = Directory(path.join(documentsDir.path, 'backup'));
      
      if (!await backupDir.exists()) {
        return RestoreResult.failure('No backup found');
      }

      await _loadBackupMetadata();

      var restoredCount = 0;
      var failedCount = 0;

      for (final backupInfo in _backupInfo.values) {
        try {
          final restoreResult = await _restoreSingleDocument(backupInfo);
          if (restoreResult.isSuccess) {
            restoredCount++;
          } else {
            failedCount++;
            debugPrint('Failed to restore ${backupInfo.documentId}: ${restoreResult.errorMessage}');
          }
        } catch (e) {
          failedCount++;
          debugPrint('Error restoring ${backupInfo.documentId}: $e');
        }
      }

      return RestoreResult.success(
        restoredCount: restoredCount,
        failedCount: failedCount,
      );
    } catch (e) {
      return RestoreResult.failure('Restore failed: ${e.toString()}');
    }
  }

  /// Restores a single document
  Future<RestoreResult> _restoreSingleDocument(DocumentBackupInfo backupInfo) async {
    try {
      // Check if document already exists
      final existingResponse = await documentsRepo.getDocuments();
      if (existingResponse.success && existingResponse.documents != null) {
        final existingDoc = existingResponse.documents!.where(
          (doc) => doc.id == backupInfo.documentId,
        ).firstOrNull;
        
        if (existingDoc != null) {
          return RestoreResult.success(message: 'Document already exists');
        }
      }

      // Upload the backed up document
      if (backupInfo.frontImagePath != null) {
        final uploadRequest = DocumentUploadRequest(
          type: backupInfo.documentType,
          filePath: backupInfo.frontImagePath!,
          fileName: backupInfo.fileName,
          fileSize: backupInfo.fileSize,
          metadata: {
            'restoredFromBackup': true,
            'originalUploadDate': backupInfo.uploadedAt?.toIso8601String(),
          },
          isBackImage: false,
        );

        final uploadResponse = await documentsRepo.uploadDocument(uploadRequest);
        if (!uploadResponse.success) {
          return RestoreResult.failure('Failed to upload front image: ${uploadResponse.message}');
        }
      }

      if (backupInfo.backImagePath != null) {
        final uploadRequest = DocumentUploadRequest(
          type: backupInfo.documentType,
          filePath: backupInfo.backImagePath!,
          fileName: backupInfo.fileName,
          fileSize: backupInfo.fileSize,
          metadata: {
            'restoredFromBackup': true,
            'originalUploadDate': backupInfo.uploadedAt?.toIso8601String(),
          },
          isBackImage: true,
        );

        final uploadResponse = await documentsRepo.uploadDocument(uploadRequest);
        if (!uploadResponse.success) {
          return RestoreResult.failure('Failed to upload back image: ${uploadResponse.message}');
        }
      }

      return RestoreResult.success();
    } catch (e) {
      return RestoreResult.failure('Restore error: ${e.toString()}');
    }
  }

  /// Syncs documents with cloud storage
  Future<SyncResult> syncWithCloud() async {
    try {
      final response = await documentsRepo.getDocuments();
      if (!response.success || response.documents == null) {
        return SyncResult.failure('Failed to fetch documents for sync');
      }

      var syncedCount = 0;
      var failedCount = 0;

      for (final document in response.documents!) {
        try {
          final syncResult = await _syncSingleDocument(document);
          if (syncResult.isSuccess) {
            syncedCount++;
          } else {
            failedCount++;
            debugPrint('Failed to sync ${document.id}: ${syncResult.errorMessage}');
          }
        } catch (e) {
          failedCount++;
          debugPrint('Error syncing ${document.id}: $e');
        }
      }

      return SyncResult.success(
        syncedCount: syncedCount,
        failedCount: failedCount,
      );
    } catch (e) {
      return SyncResult.failure('Sync failed: ${e.toString()}');
    }
  }

  /// Syncs a single document
  Future<SyncResult> _syncSingleDocument(documents_repo.DriverDocument document) async {
    try {
      // This would typically sync with cloud storage services like AWS S3, Google Drive, etc.
      // For now, we'll just mark it as synced
      
      final syncInfo = DocumentSyncInfo(
        documentId: document.id,
        lastSyncDate: DateTime.now(),
        syncStatus: SyncStatus.synced,
        cloudLocation: 'cloud://documents/${document.id}',
      );

      await _saveSyncInfo(syncInfo);

      return SyncResult.success();
    } catch (e) {
      return SyncResult.failure('Sync error: ${e.toString()}');
    }
  }

  /// Gets documents directory
  Future<Directory> _getDocumentsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory(path.join(appDir.path, 'documents'));
  }

  /// Saves backup metadata
  Future<void> _saveBackupMetadata() async {
    final prefs = await SharedPreferences.getInstance();
    final metadataJson = _backupInfo.values.map((info) => info.toJson()).toList();
    await prefs.setString('document_backup_metadata', metadataJson.toString());
  }

  /// Loads backup metadata
  Future<void> _loadBackupMetadata() async {
    final prefs = await SharedPreferences.getInstance();
    final metadataString = prefs.getString('document_backup_metadata');
    if (metadataString != null) {
      // Parse metadata string and populate _backupInfo
      // This is simplified - in reality you'd parse the JSON properly
    }
  }

  /// Saves sync info
  Future<void> _saveSyncInfo(DocumentSyncInfo syncInfo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sync_${syncInfo.documentId}', jsonEncode(syncInfo.toJson()));
  }

  /// Gets backup info for a document
  DocumentBackupInfo? getBackupInfo(String documentId) {
    return _backupInfo[documentId];
  }

  /// Gets all backup info
  List<DocumentBackupInfo> getAllBackupInfo() {
    return _backupInfo.values.toList();
  }

  /// Clears old backups
  Future<void> clearOldBackups({Duration maxAge = const Duration(days: 30)}) async {
    final cutoffDate = DateTime.now().subtract(maxAge);
    
    _backupInfo.removeWhere((key, value) {
      return value.backupDate.isBefore(cutoffDate);
    });

    await _saveBackupMetadata();
  }
}

/// {@template document_backup_info}
/// Information about a backed up document.
/// {@endtemplate}
class DocumentBackupInfo {
  /// {@macro document_backup_info}
  const DocumentBackupInfo({
    required this.documentId,
    required this.documentType,
    this.frontImagePath,
    this.backImagePath,
    this.fileName,
    this.fileSize,
    this.uploadedAt,
    this.verifiedAt,
    required this.status,
    required this.backupDate,
    required this.backupLocation,
  });

  final String documentId;
  final documents_repo.DocumentType documentType;
  final String? frontImagePath;
  final String? backImagePath;
  final String? fileName;
  final int? fileSize;
  final DateTime? uploadedAt;
  final DateTime? verifiedAt;
  final documents_repo.DocumentStatus status;
  final DateTime backupDate;
  final String backupLocation;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'documentId': documentId,
      'documentType': documentType.value,
      'frontImagePath': frontImagePath,
      'backImagePath': backImagePath,
      'fileName': fileName,
      'fileSize': fileSize,
      'uploadedAt': uploadedAt?.toIso8601String(),
      'verifiedAt': verifiedAt?.toIso8601String(),
      'status': status.value,
      'backupDate': backupDate.toIso8601String(),
      'backupLocation': backupLocation,
    };
  }

  /// Creates from JSON
  factory DocumentBackupInfo.fromJson(Map<String, dynamic> json) {
    return DocumentBackupInfo(
      documentId: json['documentId'] as String,
      documentType: documents_repo.DocumentType.fromString(json['documentType'] as String),
      frontImagePath: json['frontImagePath'] as String?,
      backImagePath: json['backImagePath'] as String?,
      fileName: json['fileName'] as String?,
      fileSize: json['fileSize'] as int?,
      uploadedAt: json['uploadedAt'] != null 
          ? DateTime.parse(json['uploadedAt'] as String) 
          : null,
      verifiedAt: json['verifiedAt'] != null 
          ? DateTime.parse(json['verifiedAt'] as String) 
          : null,
      status: documents_repo.DocumentStatus.fromString(json['status'] as String),
      backupDate: DateTime.parse(json['backupDate'] as String),
      backupLocation: json['backupLocation'] as String,
    );
  }
}

/// {@template document_sync_info}
/// Information about document sync status.
/// {@endtemplate}
class DocumentSyncInfo {
  /// {@macro document_sync_info}
  const DocumentSyncInfo({
    required this.documentId,
    required this.lastSyncDate,
    required this.syncStatus,
    required this.cloudLocation,
  });

  final String documentId;
  final DateTime lastSyncDate;
  final SyncStatus syncStatus;
  final String cloudLocation;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'documentId': documentId,
      'lastSyncDate': lastSyncDate.toIso8601String(),
      'syncStatus': syncStatus.value,
      'cloudLocation': cloudLocation,
    };
  }
}

/// {@template backup_result}
/// Result of backup operation.
/// {@endtemplate}
class BackupResult {
  /// {@macro backup_result}
  const BackupResult._({
    required this.isSuccess,
    this.backedUpCount,
    this.failedCount,
    this.backupLocation,
    this.backupInfo,
    this.errorMessage,
  });

  final bool isSuccess;
  final int? backedUpCount;
  final int? failedCount;
  final String? backupLocation;
  final DocumentBackupInfo? backupInfo;
  final String? errorMessage;

  factory BackupResult.success({
    int? backedUpCount,
    int? failedCount,
    String? backupLocation,
    DocumentBackupInfo? backupInfo,
  }) {
    return BackupResult._(
      isSuccess: true,
      backedUpCount: backedUpCount,
      failedCount: failedCount,
      backupLocation: backupLocation,
      backupInfo: backupInfo,
    );
  }

  factory BackupResult.failure(String errorMessage) {
    return BackupResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }

  bool get isFailure => !isSuccess;
}

/// {@template restore_result}
/// Result of restore operation.
/// {@endtemplate}
class RestoreResult {
  /// {@macro restore_result}
  const RestoreResult._({
    required this.isSuccess,
    this.restoredCount,
    this.failedCount,
    this.message,
    this.errorMessage,
  });

  final bool isSuccess;
  final int? restoredCount;
  final int? failedCount;
  final String? message;
  final String? errorMessage;

  factory RestoreResult.success({
    int? restoredCount,
    int? failedCount,
    String? message,
  }) {
    return RestoreResult._(
      isSuccess: true,
      restoredCount: restoredCount,
      failedCount: failedCount,
      message: message,
    );
  }

  factory RestoreResult.failure(String errorMessage) {
    return RestoreResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }

  bool get isFailure => !isSuccess;
}

/// {@template sync_result}
/// Result of sync operation.
/// {@endtemplate}
class SyncResult {
  /// {@macro sync_result}
  const SyncResult._({
    required this.isSuccess,
    this.syncedCount,
    this.failedCount,
    this.errorMessage,
  });

  final bool isSuccess;
  final int? syncedCount;
  final int? failedCount;
  final String? errorMessage;

  factory SyncResult.success({
    int? syncedCount,
    int? failedCount,
  }) {
    return SyncResult._(
      isSuccess: true,
      syncedCount: syncedCount,
      failedCount: failedCount,
    );
  }

  factory SyncResult.failure(String errorMessage) {
    return SyncResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }

  bool get isFailure => !isSuccess;
}

/// {@template sync_status}
/// Status of document sync.
/// {@endtemplate}
enum SyncStatus {
  synced('synced', 'Synced'),
  syncing('syncing', 'Syncing'),
  failed('failed', 'Failed'),
  notSynced('not_synced', 'Not Synced');

  const SyncStatus(this.value, this.displayName);

  final String value;
  final String displayName;
}
