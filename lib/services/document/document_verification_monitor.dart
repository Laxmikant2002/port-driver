import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:documents_repo/documents_repo.dart';
import 'package:documents_repo/src/models/document.dart' as documents_repo;

/// {@template document_verification_monitor}
/// Service for monitoring document verification status in real-time.
/// {@endtemplate}
class DocumentVerificationMonitor {
  /// {@macro document_verification_monitor}
  DocumentVerificationMonitor({
    required this.documentsRepo,
  }) : _statusController = StreamController<DocumentVerificationUpdate>.broadcast();

  final DocumentsRepo documentsRepo;
  final StreamController<DocumentVerificationUpdate> _statusController;
  Timer? _pollingTimer;
  bool _isMonitoring = false;

  /// Stream of verification status updates
  Stream<DocumentVerificationUpdate> get statusUpdates => _statusController.stream;

  /// Starts monitoring document verification status
  void startMonitoring({
    Duration pollingInterval = const Duration(minutes: 2),
  }) {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _pollingTimer = Timer.periodic(pollingInterval, (_) {
      _checkVerificationStatus();
    });

    // Initial check
    _checkVerificationStatus();
  }

  /// Stops monitoring
  void stopMonitoring() {
    _isMonitoring = false;
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Checks verification status and emits updates
  Future<void> _checkVerificationStatus() async {
    try {
      final response = await documentsRepo.getDocuments();
      
      if (response.success && response.documents != null) {
        for (final document in response.documents!) {
          final update = DocumentVerificationUpdate(
            documentId: document.id,
            documentType: document.type,
            oldStatus: _getLastKnownStatus(document.id),
            newStatus: document.status,
            timestamp: DateTime.now(),
            message: _getStatusMessage(document.status),
            requiresAction: _requiresAction(document.status),
          );

          // Only emit if status changed
          if (update.oldStatus != update.newStatus) {
            _statusController.add(update);
            _updateLastKnownStatus(document.id, document.status);
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking verification status: $e');
    }
  }

  /// Gets the last known status for a document
  DocumentStatus? _getLastKnownStatus(String documentId) {
    return _lastKnownStatuses[documentId];
  }

  /// Updates the last known status for a document
  void _updateLastKnownStatus(String documentId, DocumentStatus status) {
    _lastKnownStatuses[documentId] = status;
  }

  final Map<String, DocumentStatus> _lastKnownStatuses = {};

  /// Gets appropriate message for status
  String _getStatusMessage(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.pending:
        return 'Document is pending verification';
      case DocumentStatus.uploading:
        return 'Document is being uploaded';
      case DocumentStatus.uploaded:
        return 'Document uploaded successfully';
      case DocumentStatus.verifying:
        return 'Document is being verified by our team';
      case DocumentStatus.verified:
        return 'Document verified successfully!';
      case DocumentStatus.rejected:
        return 'Document was rejected. Please check the reason and re-upload';
      case DocumentStatus.expired:
        return 'Document has expired. Please renew';
    }
  }

  /// Checks if status requires user action
  bool _requiresAction(DocumentStatus status) {
    return status == DocumentStatus.rejected || status == DocumentStatus.expired;
  }

  /// Disposes the monitor
  void dispose() {
    stopMonitoring();
    _statusController.close();
  }
}

/// {@template document_verification_update}
/// Update about document verification status change.
/// {@endtemplate}
class DocumentVerificationUpdate {
  /// {@macro document_verification_update}
  const DocumentVerificationUpdate({
    required this.documentId,
    required this.documentType,
    required this.oldStatus,
    required this.newStatus,
    required this.timestamp,
    required this.message,
    required this.requiresAction,
  });

  final String documentId;
  final documents_repo.DocumentType documentType;
  final DocumentStatus? oldStatus;
  final DocumentStatus newStatus;
  final DateTime timestamp;
  final String message;
  final bool requiresAction;

  /// Whether this is a positive update (verified, uploaded)
  bool get isPositiveUpdate {
    return newStatus == DocumentStatus.verified || 
           newStatus == DocumentStatus.uploaded;
  }

  /// Whether this is a negative update (rejected, expired)
  bool get isNegativeUpdate {
    return newStatus == DocumentStatus.rejected || 
           newStatus == DocumentStatus.expired;
  }

  /// Whether this is a status change
  bool get isStatusChange => oldStatus != newStatus;
}

/// {@template document_verification_notification}
/// Notification for document verification updates.
/// {@endtemplate}
class DocumentVerificationNotification {
  /// {@macro document_verification_notification}
  const DocumentVerificationNotification({
    required this.title,
    required this.body,
    required this.type,
    required this.documentId,
    required this.documentType,
    this.actionRequired = false,
    this.actionText,
  });

  final String title;
  final String body;
  final NotificationType type;
  final String documentId;
  final documents_repo.DocumentType documentType;
  final bool actionRequired;
  final String? actionText;

  /// Creates notification from verification update
  factory DocumentVerificationNotification.fromUpdate(
    DocumentVerificationUpdate update,
  ) {
    String title;
    String body;
    NotificationType type;
    bool actionRequired = false;
    String? actionText;

    switch (update.newStatus) {
      case DocumentStatus.verified:
        title = 'Document Verified!';
        body = 'Your ${update.documentType.displayName} has been verified successfully.';
        type = NotificationType.success;
        break;
      case DocumentStatus.rejected:
        title = 'Document Rejected';
        body = 'Your ${update.documentType.displayName} was rejected. Please check the reason and re-upload.';
        type = NotificationType.error;
        actionRequired = true;
        actionText = 'Re-upload';
        break;
      case DocumentStatus.verifying:
        title = 'Verification in Progress';
        body = 'Your ${update.documentType.displayName} is being verified by our team.';
        type = NotificationType.info;
        break;
      case DocumentStatus.expired:
        title = 'Document Expired';
        body = 'Your ${update.documentType.displayName} has expired. Please renew it.';
        type = NotificationType.warning;
        actionRequired = true;
        actionText = 'Renew';
        break;
      default:
        title = 'Document Update';
        body = update.message;
        type = NotificationType.info;
    }

    return DocumentVerificationNotification(
      title: title,
      body: body,
      type: type,
      documentId: update.documentId,
      documentType: update.documentType,
      actionRequired: actionRequired,
      actionText: actionText,
    );
  }
}

/// {@template notification_type}
/// Type of notification.
/// {@endtemplate}
enum NotificationType {
  success('success', 'Success'),
  error('error', 'Error'),
  warning('warning', 'Warning'),
  info('info', 'Information');

  const NotificationType(this.value, this.displayName);

  final String value;
  final String displayName;
}

/// Extension to add verification monitoring to DriverDocument
extension DriverDocumentVerification on documents_repo.DriverDocument {
  /// Whether this document is currently being verified
  bool get isBeingVerified => status == DocumentStatus.verifying;

  /// Whether this document has been verified
  bool get isVerified => status == DocumentStatus.verified;

  /// Whether this document was rejected
  bool get isRejected => status == DocumentStatus.rejected;

  /// Whether this document has expired
  bool get isExpired => status == DocumentStatus.expired;

  /// Whether this document needs attention
  bool get needsAttention => isRejected || isExpired;

  /// Gets verification status emoji
  String get statusEmoji {
    switch (status) {
      case DocumentStatus.verified:
        return '✅';
      case DocumentStatus.verifying:
        return '⏳';
      case DocumentStatus.rejected:
        return '❌';
      case DocumentStatus.expired:
        return '⏰';
      case DocumentStatus.uploaded:
        return '📤';
      case DocumentStatus.uploading:
        return '📤';
      case DocumentStatus.pending:
        return '⏸️';
    }
  }

  /// Gets verification status color
  VerificationStatusColor get statusColor {
    switch (status) {
      case DocumentStatus.verified:
        return VerificationStatusColor.green;
      case DocumentStatus.verifying:
        return VerificationStatusColor.blue;
      case DocumentStatus.rejected:
        return VerificationStatusColor.red;
      case DocumentStatus.expired:
        return VerificationStatusColor.orange;
      case DocumentStatus.uploaded:
        return VerificationStatusColor.blue;
      case DocumentStatus.uploading:
        return VerificationStatusColor.blue;
      case DocumentStatus.pending:
        return VerificationStatusColor.gray;
    }
  }
}

/// {@template verification_status_color}
/// Color for verification status.
/// {@endtemplate}
enum VerificationStatusColor {
  green('green'),
  blue('blue'),
  red('red'),
  orange('orange'),
  gray('gray');

  const VerificationStatusColor(this.value);

  final String value;
}
