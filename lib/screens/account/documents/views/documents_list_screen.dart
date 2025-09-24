import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:documents_repo/documents_repo.dart';
import 'package:driver/widgets/colors.dart';
import '../bloc/documents_bloc.dart';
import 'package:driver/models/document_upload.dart' hide DocumentStatus, DocumentType;
import 'package:driver/models/document_upload.dart' as local_models show DocumentStatus, DocumentType;

/// {@template documents_list_screen}
/// Screen for active drivers to view and manage their uploaded documents.
/// {@endtemplate}
class DocumentsListScreen extends StatelessWidget {
  /// {@macro documents_list_screen}
  const DocumentsListScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const DocumentsListView();
  }
}

class DocumentsListView extends StatelessWidget {
  const DocumentsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'My Documents',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              context.read<DocumentsBloc>().add(
                const DocumentStatusRefreshed(),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<DocumentsBloc, DocumentsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.hasError) {
            return _buildErrorState(state.errorMessage!);
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<DocumentsBloc>().add(
                const DocumentStatusRefreshed(),
              );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildSummarySection(state),
                  const SizedBox(height: 24),
                  _buildAlertsSection(state),
                  const SizedBox(height: 24),
                  _buildDocumentsSection(state),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load documents',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Retry loading
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cyan,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(DocumentsState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: AppColors.cyan,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Document Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${state.approvedCount} of ${state.totalDocuments} documents approved',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Approved',
                  '${state.approvedCount}',
                  AppColors.success,
                  Icons.check_circle,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Expired',
                  '${state.expiredCount}',
                  AppColors.error,
                  Icons.schedule,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Expiring Soon',
                  '${state.expiringSoonCount}',
                  AppColors.warning,
                  Icons.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAlertsSection(DocumentsState state) {
    final alerts = <Widget>[];

    if (state.hasExpiredDocuments) {
      alerts.add(_buildAlertCard(
        'Expired Documents',
        'You have ${state.expiredCount} expired document(s) that need to be renewed.',
        AppColors.error,
        Icons.schedule,
      ));
    }

    if (state.hasExpiringSoonDocuments) {
      alerts.add(_buildAlertCard(
        'Documents Expiring Soon',
        'You have ${state.expiringSoonCount} document(s) expiring within 30 days.',
        AppColors.warning,
        Icons.warning,
      ));
    }

    if (state.hasRejectedDocuments) {
      alerts.add(_buildAlertCard(
        'Rejected Documents',
        'You have ${state.rejectedCount} rejected document(s) that need to be re-uploaded.',
        AppColors.error,
        Icons.cancel,
      ));
    }

    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: alerts.map((alert) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: alert,
      )).toList(),
    );
  }

  Widget _buildAlertCard(String title, String message, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection(DocumentsState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'All Documents',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...state.documents.map((doc) => _DocumentCard(document: doc)),
          ],
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.document});

  final DocumentUpload document;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          if (document.id != null) {
            Navigator.of(context).pushNamed(
              '/document-detail',
              arguments: document.id,
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Document Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getDocumentIcon(),
                  size: 20,
                  color: _getStatusColor(),
                ),
              ),
              const SizedBox(width: 12),
              // Document Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          document.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadge(),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          document.status.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getStatusColor(),
                          ),
                        ),
                        if (document.expiryDate != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            document.expiryStatus,
                            style: TextStyle(
                              fontSize: 12,
                              color: _getExpiryColor(),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (document.rejectionReason != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        document.rejectionReason!,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.error,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Action Icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color badgeColor;
    String badgeText;

    if (document.isExpired) {
      badgeColor = AppColors.error;
      badgeText = 'Expired';
    } else if (document.isExpiringSoon) {
      badgeColor = AppColors.warning;
      badgeText = 'Expiring Soon';
    } else if (document.status == local_models.DocumentStatus.verified) {
      badgeColor = AppColors.success;
      badgeText = 'Approved';
    } else if (document.status == local_models.DocumentStatus.rejected) {
      badgeColor = AppColors.error;
      badgeText = 'Rejected';
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        badgeText,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: badgeColor,
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (document.status) {
      case local_models.DocumentStatus.pending:
        return AppColors.textSecondary;
      case local_models.DocumentStatus.uploading:
      case local_models.DocumentStatus.verifying:
        return AppColors.warning;
      case local_models.DocumentStatus.uploaded:
        return AppColors.cyan;
      case local_models.DocumentStatus.verified:
        return AppColors.success;
      case local_models.DocumentStatus.rejected:
        return AppColors.error;
    }
  }

  Color _getExpiryColor() {
    if (document.isExpired) return AppColors.error;
    if (document.isExpiringSoon) return AppColors.warning;
    return AppColors.success;
  }

  IconData _getDocumentIcon() {
    switch (document.type) {
      case local_models.DocumentType.drivingLicense:
        return Icons.credit_card;
      case local_models.DocumentType.registrationCertificate:
        return Icons.directions_car;
      case local_models.DocumentType.vehicleInsurance:
        return Icons.security;
      case local_models.DocumentType.profilePicture:
        return Icons.person;
      case local_models.DocumentType.aadhaarCard:
        return Icons.badge;
      case local_models.DocumentType.panCard:
        return Icons.account_balance;
      case local_models.DocumentType.addressProof:
        return Icons.location_on;
    }
  }
}
