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
          child: Column(
            children: [
              const _HeaderSection(),
              const SizedBox(height: 24),
              Expanded(
                child: BlocBuilder<DocsBloc, DocsState>(
                  builder: (context, state) {
                    if (state.status == DocsStatus.loading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return Column(
                      children: [
                          const SizedBox(height: 16),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _buildDocumentsList(context, state),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentsList(BuildContext context, DocsState state) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: state.documents.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final document = state.documents[index];
        return _buildDocumentCard(context, document);
      },
    );
  }

  Widget _buildDocumentCard(BuildContext context, Document document) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getBorderColor(document.status),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.border.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                _buildDocumentIcon(document),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              document.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          if (document.isRequired)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Required',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        document.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (document.isRecommendedNext && 
                          document.status == DocumentStatus.pending)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Recommended next step',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.success,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _buildStatusWidget(context, document),
              ],
            ),
            if (document.status == DocumentStatus.uploading)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: document.uploadProgress,
                      backgroundColor: AppColors.backgroundSecondary,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cyan),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Uploading... ${(document.uploadProgress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            if (document.status == DocumentStatus.rejected && 
                document.rejectionReason != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          document.rejectionReason!,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentIcon(Document document) {
    IconData iconData;
    Color iconColor;

    switch (document.type) {
      case DocumentType.drivingLicense:
        iconData = Icons.credit_card_rounded;
        iconColor = AppColors.info;
        break;
      case DocumentType.registrationCertificate:
        iconData = Icons.description_rounded;
        iconColor = AppColors.primary;
        break;
      case DocumentType.vehicleInsurance:
        iconData = Icons.security_rounded;
        iconColor = AppColors.success;
        break;
      case DocumentType.profilePicture:
        iconData = Icons.person_rounded;
        iconColor = AppColors.warning;
        break;
      case DocumentType.aadhaarCard:
        iconData = Icons.badge_rounded;
        iconColor = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }

  Widget _buildStatusWidget(BuildContext context, Document document) {
    switch (document.status) {
      case DocumentStatus.pending:
        return _buildUploadButton(context, document);
      case DocumentStatus.uploading:
        return const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.cyan),
          ),
        );
      case DocumentStatus.uploaded:
      case DocumentStatus.verifying:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.warningLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Verifying',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      case DocumentStatus.verified:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 24,
          ),
        );
      case DocumentStatus.rejected:
        return _buildUploadButton(context, document, isRetry: true);
    }
  }

  Widget _buildUploadButton(
    BuildContext context, 
    Document document, {
    bool isRetry = false,
  }) {
    return ElevatedButton(
      onPressed: () => _handleUpload(context, document),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.cyan,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Text(
        isRetry ? 'Retry' : 'Upload',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Color _getBorderColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.pending:
        return AppColors.border;
      case DocumentStatus.uploading:
      case DocumentStatus.uploaded:
      case DocumentStatus.verifying:
        return AppColors.cyan;
      case DocumentStatus.verified:
        return AppColors.success;
      case DocumentStatus.rejected:
        return AppColors.error;
    }
  }

  void _handleUpload(BuildContext context, Document document) {
    // In a real app, this would open camera/gallery picker
    // For now, we'll just simulate upload
    context.read<DocsBloc>().add(
          DocumentUploadStarted(
            documentType: document.type,
            frontImagePath: 'mock_front_path.jpg',
            backImagePath: document.requiresBothSides 
                ? 'mock_back_path.jpg' 
                : null,
          ),
        );
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
              Icons.upload_file_rounded,
              size: 32,
              color: AppColors.cyan,
            ),
          ),
          const SizedBox(height: 16),
          // Welcome Text
          Text(
            'Document Verification',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Upload your documents to complete the registration process',
            style: TextStyle(
              fontSize: 14,
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