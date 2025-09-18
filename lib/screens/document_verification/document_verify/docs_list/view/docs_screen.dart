import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../models/document.dart';
import '../../../../../widgets/colors.dart';
import '../bloc/docs_bloc.dart';

class DocsPage extends StatelessWidget {
  const DocsPage({super.key});

  /// The route name for the document verification page.
  static const String routeName = '/docs-verification';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DocsBloc()..add(const DocsLoaded()),
      child: const DocsView(),
    );
  }
}

class DocsView extends StatelessWidget {
  const DocsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<DocsBloc, DocsState>(
        listener: (context, state) {
          if (state.status == DocsStatus.completed) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('All documents verified successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
          } else if (state.status == DocsStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Something went wrong'),
                  backgroundColor: AppColors.error,
                ),
              );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const _HeaderSection(),
                const SizedBox(height: 24),
                BlocBuilder<DocsBloc, DocsState>(
                  builder: (context, state) {
                    if (state.status == DocsStatus.loading) {
                      return const SizedBox(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        _ProgressIndicator(state: state),
                        const SizedBox(height: 24),
                        _buildDocumentsList(context, state),
                        const SizedBox(height: 24),
                        _buildActionButtons(context, state),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentsList(BuildContext context, DocsState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 32,
            offset: const Offset(0, 12),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.border.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
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
                        'Document Verification',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        'Complete all required documents',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Documents List
            ...state.documents.asMap().entries.map((entry) {
              final index = entry.key;
              final document = entry.value;
              return Column(
                children: [
                  _buildDocumentCard(context, document),
                  if (index < state.documents.length - 1) const SizedBox(height: 16),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard(BuildContext context, Document document) {
    return InkWell(
      onTap: () => _navigateToDocumentScreen(context, document),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getDocumentBorderColor(document.status),
            width: 1.5,
          ),
        ),
        child: Row(
        children: [
          // Document Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getDocumentIconBgColor(document.status),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getDocumentIcon(document.type),
              color: _getDocumentIconColor(document.status),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Document Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child:                       Text(
                        document.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    if (document.isRequired)
                      Text(
                        '*',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  document.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatusChip(document.status),
                    const Spacer(),
                    if (document.isRecommendedNext)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cyan.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.cyan,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Action Button
          InkWell(
            onTap: () => _navigateToDocumentScreen(context, document),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.cyan.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.cyan,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    ));
  }

  void _navigateToDocumentScreen(BuildContext context, Document document) {
    // Navigate to specific document verification screen based on document type
    switch (document.type) {
      case DocumentType.drivingLicense:
        Navigator.of(context).pushNamed('/license-verification');
        break;
      case DocumentType.profilePicture:
        Navigator.of(context).pushNamed('/profile-picture-verification');
        break;
      case DocumentType.aadhaarCard:
        Navigator.of(context).pushNamed('/aadhar-verification');
        break;
      case DocumentType.registrationCertificate:
        Navigator.of(context).pushNamed('/rc-verification');
        break;
      case DocumentType.vehicleInsurance:
        Navigator.of(context).pushNamed('/insurance-verification');
        break;
    }
  }

  // Removed conversion helpers and navigation to ModernDocsScreen

  Widget _buildActionButtons(BuildContext context, DocsState state) {
    final allCompleted = state.documents.every(
      (doc) => !doc.isRequired || doc.status == DocumentStatus.verified,
    );
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: allCompleted 
                  ? () => context.read<DocsBloc>().add(const DocsSubmitted())
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: allCompleted ? AppColors.primary : AppColors.border,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: allCompleted ? 4 : 0,
                shadowColor: AppColors.primary.withOpacity(0.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    allCompleted ? Icons.check_circle_outline_rounded : Icons.pending_outlined,
                    size: 20,
                    color: allCompleted ? Colors.white : AppColors.textTertiary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    allCompleted ? 'Submit Documents' : 'Upload Documents',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: allCompleted ? Colors.white : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Testing Button - Navigate to Home Screen
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cyan,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: AppColors.cyan.withOpacity(0.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.home_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Testing - Go to Home',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!allCompleted) ...[
            const SizedBox(height: 12),
            Text(
              'Please upload all required documents to proceed',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  // Helper methods for document styling
  IconData _getDocumentIcon(DocumentType type) {
    switch (type) {
      case DocumentType.drivingLicense:
        return Icons.credit_card_rounded;
      case DocumentType.registrationCertificate:
        return Icons.assignment_rounded;
      case DocumentType.vehicleInsurance:
        return Icons.security_rounded;
      case DocumentType.profilePicture:
        return Icons.person_rounded;
      case DocumentType.aadhaarCard:
        return Icons.badge_rounded;
    }
  }

  Color _getDocumentIconColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.pending:
        return AppColors.textSecondary;
      case DocumentStatus.uploading:
        return AppColors.cyan;
      case DocumentStatus.uploaded:
        return AppColors.warning;
      case DocumentStatus.verifying:
        return AppColors.warning;
      case DocumentStatus.verified:
        return AppColors.success;
      case DocumentStatus.rejected:
        return AppColors.error;
    }
  }

  Color _getDocumentIconBgColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.pending:
        return AppColors.textSecondary.withOpacity(0.1);
      case DocumentStatus.uploading:
        return AppColors.cyan.withOpacity(0.1);
      case DocumentStatus.uploaded:
        return AppColors.warning.withOpacity(0.1);
      case DocumentStatus.verifying:
        return AppColors.warning.withOpacity(0.1);
      case DocumentStatus.verified:
        return AppColors.success.withOpacity(0.1);
      case DocumentStatus.rejected:
        return AppColors.error.withOpacity(0.1);
    }
  }

  Color _getDocumentBorderColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.pending:
        return AppColors.border;
      case DocumentStatus.uploading:
        return AppColors.cyan;
      case DocumentStatus.uploaded:
        return AppColors.warning;
      case DocumentStatus.verifying:
        return AppColors.warning;
      case DocumentStatus.verified:
        return AppColors.success;
      case DocumentStatus.rejected:
        return AppColors.error;
    }
  }

  Widget _buildStatusChip(DocumentStatus status) {
    final statusInfo = _getStatusInfo(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusInfo['bgColor'] as Color?,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusInfo['icon'] as IconData,
            size: 12,
            color: statusInfo['color'] as Color,
          ),
          const SizedBox(width: 4),
          Text(
            statusInfo['text'] as String,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: statusInfo['color'] as Color,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.pending:
        return {
          'text': 'Pending',
          'icon': Icons.schedule_rounded,
          'color': AppColors.textSecondary,
          'bgColor': AppColors.textSecondary.withOpacity(0.1),
        };
      case DocumentStatus.uploading:
        return {
          'text': 'Uploading',
          'icon': Icons.cloud_upload_rounded,
          'color': AppColors.cyan,
          'bgColor': AppColors.cyan.withOpacity(0.1),
        };
      case DocumentStatus.uploaded:
        return {
          'text': 'Uploaded',
          'icon': Icons.cloud_done_rounded,
          'color': AppColors.warning,
          'bgColor': AppColors.warning.withOpacity(0.1),
        };
      case DocumentStatus.verifying:
        return {
          'text': 'Verifying',
          'icon': Icons.hourglass_empty_rounded,
          'color': AppColors.warning,
          'bgColor': AppColors.warning.withOpacity(0.1),
        };
      case DocumentStatus.verified:
        return {
          'text': 'Verified',
          'icon': Icons.verified_rounded,
          'color': AppColors.success,
          'bgColor': AppColors.success.withOpacity(0.1),
        };
      case DocumentStatus.rejected:
        return {
          'text': 'Rejected',
          'icon': Icons.cancel_rounded,
          'color': AppColors.error,
          'bgColor': AppColors.error.withOpacity(0.1),
        };
    }
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.cyan.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          // Document Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.verified_user_rounded,
              size: 32,
              color: AppColors.cyan,
            ),
          ),
          const SizedBox(height: 16),
          // Welcome Text
          Text(
            'Welcome, User',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your document verification to start driving',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  final DocsState state;
  
  const _ProgressIndicator({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${state.completedDocuments}/${state.totalDocuments}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: state.progressPercentage,
            backgroundColor: AppColors.backgroundSecondary,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}