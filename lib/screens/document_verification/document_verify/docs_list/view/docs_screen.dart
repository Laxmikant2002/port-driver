import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../models/document.dart';
import '../bloc/docs_bloc.dart';

/// {@template docs_page}
/// A page that displays the document verification screen.
/// {@endtemplate}
class DocsPage extends StatelessWidget {
  /// {@macro docs_page}
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

/// {@template docs_view}
/// The view for the document verification screen.
/// {@endtemplate}
class DocsView extends StatelessWidget {
  /// {@macro docs_view}
  const DocsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Document Verification',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocListener<DocsBloc, DocsState>(
        listener: (context, state) {
          if (state.status == DocsStatus.completed) {
            // Navigate to next screen or show completion
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('All documents verified successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state.status == DocsStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Something went wrong'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<DocsBloc, DocsState>(
          builder: (context, state) {
            if (state.status == DocsStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return Column(
              children: [
                _buildHeader(state),
                _buildProgressIndicator(state),
                Expanded(
                  child: _buildDocumentsList(context, state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(DocsState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload your documents to complete registration.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Progress',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(DocsState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${state.completedDocuments}/${state.totalDocuments}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF059669),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: state.progressPercentage,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsList(BuildContext context, DocsState state) {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(document.status),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                          if (document.isRequired)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '*',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        document.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      if (document.isRecommendedNext && 
                          document.status == DocumentStatus.pending)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            'Recommended next step',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF059669),
                              fontWeight: FontWeight.w500,
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
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: document.uploadProgress,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF3B82F6),
                      ),
                      minHeight: 4,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Uploading... ${(document.uploadProgress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            if (document.status == DocumentStatus.rejected && 
                document.rejectionReason != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          document.rejectionReason!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
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
        iconData = Icons.credit_card;
        iconColor = const Color(0xFF3B82F6);
        break;
      case DocumentType.registrationCertificate:
        iconData = Icons.description;
        iconColor = const Color(0xFF8B5CF6);
        break;
      case DocumentType.vehicleInsurance:
        iconData = Icons.security;
        iconColor = const Color(0xFF10B981);
        break;
      case DocumentType.profilePicture:
        iconData = Icons.person;
        iconColor = const Color(0xFFF59E0B);
        break;
      case DocumentType.aadhaarCard:
        iconData = Icons.badge;
        iconColor = const Color(0xFEF43F5E);
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
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
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
          ),
        );
      case DocumentStatus.uploaded:
      case DocumentStatus.verifying:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFBBF24).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'Verifying',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFFFBBF24),
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      case DocumentStatus.verified:
        return const Icon(
          Icons.check_circle,
          color: Color(0xFF059669),
          size: 24,
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
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        elevation: 0,
      ),
      child: Text(
        isRetry ? 'Retry' : 'Upload',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getBorderColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.pending:
        return const Color(0xFFE5E7EB);
      case DocumentStatus.uploading:
      case DocumentStatus.uploaded:
      case DocumentStatus.verifying:
        return const Color(0xFF3B82F6);
      case DocumentStatus.verified:
        return const Color(0xFF059669);
      case DocumentStatus.rejected:
        return const Color(0xFEF43F5E);
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
