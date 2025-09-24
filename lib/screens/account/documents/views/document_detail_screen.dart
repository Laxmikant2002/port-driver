import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:documents_repo/documents_repo.dart';
import '../../../widgets/colors.dart';
import '../bloc/documents_bloc.dart';
import '../../../models/document_upload.dart';

/// {@template document_detail_screen}
/// Screen for viewing document details and re-uploading if needed.
/// {@endtemplate}
class DocumentDetailScreen extends StatelessWidget {
  /// {@macro document_detail_screen}
  const DocumentDetailScreen({
    super.key,
    required this.documentsRepo,
    required this.documentId,
  });

  final DocumentsRepo documentsRepo;
  final String documentId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DocumentsBloc(documentsRepo: documentsRepo)
        ..add(const DocumentsLoaded()),
      child: DocumentDetailView(documentId: documentId),
    );
  }
}

class DocumentDetailView extends StatefulWidget {
  const DocumentDetailView({
    super.key,
    required this.documentId,
  });

  final String documentId;

  @override
  State<DocumentDetailView> createState() => _DocumentDetailViewState();
}

class _DocumentDetailViewState extends State<DocumentDetailView> {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _frontImage;
  XFile? _backImage;

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
          'Document Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: AppColors.textPrimary,
            ),
            onSelected: (value) {
              switch (value) {
                case 'refresh':
                  context.read<DocumentsBloc>().add(
                    const DocumentStatusRefreshed(),
                  );
                  break;
                case 'delete':
                  _showDeleteConfirmation(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Refresh Status'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Delete Document', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<DocumentsBloc, DocumentsState>(
        builder: (context, state) {
          final document = state.documents.firstWhere(
            (doc) => doc.id == widget.documentId,
            orElse: () => throw StateError('Document not found'),
          );

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildDocumentInfoSection(document),
                const SizedBox(height: 24),
                _buildDocumentPreviewSection(document),
                const SizedBox(height: 24),
                _buildStatusSection(document),
                const SizedBox(height: 24),
                _buildExpirySection(document),
                const SizedBox(height: 24),
                _buildReuploadSection(document),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDocumentInfoSection(DocumentUpload document) {
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
          // Document Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(document).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getDocumentIcon(document.type),
              size: 32,
              color: _getStatusColor(document),
            ),
          ),
          const SizedBox(height: 16),
          // Document Title
          Text(
            document.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Document Description
          Text(
            document.description,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(document).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              document.status.displayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _getStatusColor(document),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentPreviewSection(DocumentUpload document) {
    if (!document.isUploaded) {
      return const SizedBox.shrink();
    }

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
              'Document Preview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            if (document.frontImagePath != null) ...[
              _buildImagePreview('Front Side', document.frontImagePath!),
              if (document.backImagePath != null) ...[
                const SizedBox(height: 16),
                _buildImagePreview('Back Side', document.backImagePath!),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(String title, String imagePath) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.border,
                  child: Icon(
                    Icons.image_not_supported,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection(DocumentUpload document) {
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
              'Status Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatusItem('Status', document.status.displayName, _getStatusColor(document)),
            if (document.uploadedAt != null)
              _buildStatusItem('Uploaded', _formatDate(document.uploadedAt!), AppColors.textSecondary),
            if (document.verifiedAt != null)
              _buildStatusItem('Verified', _formatDate(document.verifiedAt!), AppColors.success),
            if (document.rejectionReason != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rejection Reason',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      document.rejectionReason!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpirySection(DocumentUpload document) {
    if (document.expiryDate == null) {
      return const SizedBox.shrink();
    }

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
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: _getExpiryColor(document),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Expiry Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatusItem('Expiry Date', _formatDate(document.expiryDate!), AppColors.textSecondary),
            _buildStatusItem('Status', document.expiryStatus, _getExpiryColor(document)),
            if (document.daysUntilExpiry != 0)
              _buildStatusItem('Days Until Expiry', '${document.daysUntilExpiry} days', _getExpiryColor(document)),
            const SizedBox(height: 16),
            Row(
              children: [
                Switch(
                  value: document.expiryNotificationEnabled,
                  onChanged: (value) {
                    context.read<DocumentsBloc>().add(
                      DocumentExpiryNotificationToggled(
                        documentId: document.id!,
                        enabled: value,
                      ),
                    );
                  },
                  activeColor: AppColors.cyan,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Enable expiry notifications',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReuploadSection(DocumentUpload document) {
    if (document.status == DocumentStatus.verified && !document.isExpired) {
      return const SizedBox.shrink();
    }

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
              'Re-upload Document',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              document.isExpired 
                  ? 'This document has expired and needs to be renewed.'
                  : 'Upload a new version of this document.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            if (document.type.requiresBothSides) ...[
              _buildImageUploadCard(
                'Front Side',
                'Take a clear photo of the front',
                _frontImage,
                (image) => setState(() => _frontImage = image),
              ),
              const SizedBox(height: 16),
              _buildImageUploadCard(
                'Back Side',
                'Take a clear photo of the back',
                _backImage,
                (image) => setState(() => _backImage = image),
              ),
            ] else ...[
              _buildImageUploadCard(
                'Document Photo',
                'Take a clear photo of the document',
                _frontImage,
                (image) => setState(() => _frontImage = image),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _canReupload() ? _reuploadDocument : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canReupload() ? AppColors.cyan : AppColors.border,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Re-upload Document',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _canReupload() ? Colors.white : AppColors.textTertiary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadCard(
    String title,
    String subtitle,
    XFile? image,
    Function(XFile) onImageSelected,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          if (image != null) ...[
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(image.path),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showImagePicker(onImageSelected),
                  icon: Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: AppColors.cyan,
                  ),
                  label: Text(
                    'Take Photo',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.cyan,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    side: BorderSide(color: AppColors.cyan),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showImagePicker(onImageSelected, fromGallery: true),
                  icon: Icon(
                    Icons.folder_open,
                    size: 16,
                    color: AppColors.cyan,
                  ),
                  label: Text(
                    'Choose File',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.cyan,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    side: BorderSide(color: AppColors.cyan),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  bool _canReupload() {
    return _frontImage != null && 
           (!_needsBackImage() || _backImage != null);
  }

  bool _needsBackImage() {
    final document = context.read<DocumentsBloc>().state.documents.firstWhere(
      (doc) => doc.id == widget.documentId,
    );
    return document.type.requiresBothSides;
  }

  void _reuploadDocument() {
    // Navigate to document upload screen with the document type
    final document = context.read<DocumentsBloc>().state.documents.firstWhere(
      (doc) => doc.id == widget.documentId,
    );
    
    Navigator.of(context).pushNamed(
      '/document-upload',
      arguments: document.type,
    );
  }

  Future<void> _showImagePicker(
    Function(XFile) onImageSelected, {
    bool fromGallery = false,
  }) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: fromGallery ? ImageSource.gallery : ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        onImageSelected(image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Document',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this document? This action cannot be undone.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<DocumentsBloc>().add(
                DocumentDeleted(documentId: widget.documentId),
              );
              Navigator.of(context).pop(); // Go back to list
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(DocumentUpload document) {
    switch (document.status) {
      case DocumentStatus.pending:
        return AppColors.textSecondary;
      case DocumentStatus.uploading:
      case DocumentStatus.verifying:
        return AppColors.warning;
      case DocumentStatus.uploaded:
        return AppColors.cyan;
      case DocumentStatus.verified:
        return AppColors.success;
      case DocumentStatus.rejected:
        return AppColors.error;
    }
  }

  Color _getExpiryColor(DocumentUpload document) {
    if (document.isExpired) return AppColors.error;
    if (document.isExpiringSoon) return AppColors.warning;
    return AppColors.success;
  }

  IconData _getDocumentIcon(DocumentType type) {
    switch (type) {
      case DocumentType.drivingLicense:
        return Icons.credit_card;
      case DocumentType.registrationCertificate:
        return Icons.directions_car;
      case DocumentType.vehicleInsurance:
        return Icons.security;
      case DocumentType.profilePicture:
        return Icons.person;
      case DocumentType.aadhaarCard:
        return Icons.badge;
      case DocumentType.panCard:
        return Icons.account_balance;
      case DocumentType.addressProof:
        return Icons.location_on;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
