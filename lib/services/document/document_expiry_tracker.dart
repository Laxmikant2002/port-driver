import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:documents_repo/documents_repo.dart';

/// {@template document_expiry_tracker}
/// Service for tracking document expiry and sending renewal reminders.
/// {@endtemplate}
class DocumentExpiryTracker {
  /// {@macro document_expiry_tracker}
  const DocumentExpiryTracker();

  /// Checks if any documents are expiring soon and returns alerts
  List<DocumentExpiryAlert> checkExpiringDocuments(List<DriverDocument> documents) {
    final alerts = <DocumentExpiryAlert>[];
    final now = DateTime.now();

    for (final document in documents) {
      if (document.expiryDate == null) continue;

      final daysUntilExpiry = document.expiryDate!.difference(now).inDays;
      
      if (daysUntilExpiry <= 0) {
        alerts.add(DocumentExpiryAlert(
          document: document,
          type: DocumentExpiryType.expired,
          daysUntilExpiry: daysUntilExpiry,
          priority: DocumentExpiryPriority.critical,
          message: '${document.type.displayName} has expired. Please renew immediately.',
        ));
      } else if (daysUntilExpiry <= 7) {
        alerts.add(DocumentExpiryAlert(
          document: document,
          type: DocumentExpiryType.expiringSoon,
          daysUntilExpiry: daysUntilExpiry,
          priority: DocumentExpiryPriority.high,
          message: '${document.type.displayName} expires in $daysUntilExpiry days.',
        ));
      } else if (daysUntilExpiry <= 30) {
        alerts.add(DocumentExpiryAlert(
          document: document,
          type: DocumentExpiryType.expiringSoon,
          daysUntilExpiry: daysUntilExpiry,
          priority: DocumentExpiryPriority.medium,
          message: '${document.type.displayName} expires in $daysUntilExpiry days.',
        ));
      }
    }

    return alerts;
  }

  /// Gets renewal recommendations based on document status
  List<DocumentRenewalRecommendation> getRenewalRecommendations(List<DriverDocument> documents) {
    final recommendations = <DocumentRenewalRecommendation>[];
    final alerts = checkExpiringDocuments(documents);

    for (final alert in alerts) {
      recommendations.add(DocumentRenewalRecommendation(
        document: alert.document,
        urgency: alert.priority,
        recommendedAction: _getRecommendedAction(alert.document.type),
        estimatedProcessingTime: _getEstimatedProcessingTime(alert.document.type),
        requiredDocuments: _getRequiredDocuments(alert.document.type),
      ));
    }

    return recommendations;
  }

  String _getRecommendedAction(DocumentType type) {
    switch (type) {
      case DocumentType.drivingLicense:
        return 'Visit your local RTO office or apply online through Parivahan portal';
      case DocumentType.rcBook:
        return 'Contact your vehicle dealer or visit RTO for renewal';
      case DocumentType.insurance:
        return 'Contact your insurance provider or renew online';
      case DocumentType.aadhaar:
        return 'Visit Aadhaar enrollment center for biometric update';
      case DocumentType.pan:
        return 'Apply for PAN renewal through NSDL or UTIITSL';
      default:
        return 'Contact relevant authority for renewal';
    }
  }

  String _getEstimatedProcessingTime(DocumentType type) {
    switch (type) {
      case DocumentType.drivingLicense:
        return '7-15 days';
      case DocumentType.rcBook:
        return '10-20 days';
      case DocumentType.insurance:
        return '1-3 days';
      case DocumentType.aadhaar:
        return '5-10 days';
      case DocumentType.pan:
        return '3-7 days';
      default:
        return '5-15 days';
    }
  }

  List<String> _getRequiredDocuments(DocumentType type) {
    switch (type) {
      case DocumentType.drivingLicense:
        return ['Current license', 'Address proof', 'Medical certificate', 'Passport size photo'];
      case DocumentType.rcBook:
        return ['Current RC', 'Insurance certificate', 'PUC certificate', 'Address proof'];
      case DocumentType.insurance:
        return ['Previous insurance', 'RC copy', 'Driving license', 'Address proof'];
      case DocumentType.aadhaar:
        return ['Current Aadhaar', 'Address proof', 'Biometric verification'];
      case DocumentType.pan:
        return ['Current PAN', 'Address proof', 'Identity proof'];
      default:
        return ['Current document', 'Address proof', 'Identity proof'];
    }
  }
}

/// {@template document_expiry_alert}
/// Alert for document expiry tracking.
/// {@endtemplate}
class DocumentExpiryAlert extends Equatable {
  /// {@macro document_expiry_alert}
  const DocumentExpiryAlert({
    required this.document,
    required this.type,
    required this.daysUntilExpiry,
    required this.priority,
    required this.message,
  });

  final DriverDocument document;
  final DocumentExpiryType type;
  final int daysUntilExpiry;
  final DocumentExpiryPriority priority;
  final String message;

  @override
  List<Object> get props => [document, type, daysUntilExpiry, priority, message];
}

/// {@template document_renewal_recommendation}
/// Recommendation for document renewal.
/// {@endtemplate}
class DocumentRenewalRecommendation extends Equatable {
  /// {@macro document_renewal_recommendation}
  const DocumentRenewalRecommendation({
    required this.document,
    required this.urgency,
    required this.recommendedAction,
    required this.estimatedProcessingTime,
    required this.requiredDocuments,
  });

  final DriverDocument document;
  final DocumentExpiryPriority urgency;
  final String recommendedAction;
  final String estimatedProcessingTime;
  final List<String> requiredDocuments;

  @override
  List<Object> get props => [document, urgency, recommendedAction, estimatedProcessingTime, requiredDocuments];
}

/// {@template document_expiry_type}
/// Type of document expiry alert.
/// {@endtemplate}
enum DocumentExpiryType {
  expired('expired', 'Expired'),
  expiringSoon('expiring_soon', 'Expiring Soon'),
  renewalDue('renewal_due', 'Renewal Due');

  const DocumentExpiryType(this.value, this.displayName);

  final String value;
  final String displayName;
}

/// {@template document_expiry_priority}
/// Priority level for document expiry alerts.
/// {@endtemplate}
enum DocumentExpiryPriority {
  low('low', 'Low'),
  medium('medium', 'Medium'),
  high('high', 'High'),
  critical('critical', 'Critical');

  const DocumentExpiryPriority(this.value, this.displayName);

  final String value;
  final String displayName;
}

/// Extension to add expiry tracking to DriverDocument
extension DriverDocumentExpiry on DriverDocument {
  /// Whether this document has expired
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  /// Whether this document is expiring soon (within 30 days)
  bool get isExpiringSoon {
    if (expiryDate == null || isExpired) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 30;
  }

  /// Number of days until expiry (negative if expired)
  int get daysUntilExpiry {
    if (expiryDate == null) return 0;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  /// Formatted expiry status
  String get expiryStatus {
    if (expiryDate == null) return 'No expiry';
    if (isExpired) return 'Expired';
    if (isExpiringSoon) return 'Expiring soon';
    return 'Valid';
  }

  /// Priority level for expiry alerts
  DocumentExpiryPriority get expiryPriority {
    if (isExpired) return DocumentExpiryPriority.critical;
    if (daysUntilExpiry <= 7) return DocumentExpiryPriority.high;
    if (daysUntilExpiry <= 30) return DocumentExpiryPriority.medium;
    return DocumentExpiryPriority.low;
  }
}
