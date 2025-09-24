import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../widgets/colors.dart';
import '../bloc/document_upload_bloc.dart';
import '../../../models/document_upload.dart';

/// {@template document_upload_screen}
/// Screen for uploading individual documents with camera/file picker.
/// {@endtemplate}
class DocumentUploadScreen extends StatelessWidget {
  /// {@macro document_upload_screen}
  const DocumentUploadScreen({
    super.key,
    required this.documentType,
  });

  final DocumentType documentType;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => context.read<DocumentUploadBloc>(),
      child: DocumentUploadView(documentType: documentType),
    );
  }
}

class DocumentUploadView extends StatefulWidget {
  const DocumentUploadView({
    super.key,
    required this.documentType,
  });

  final DocumentType documentType;

  @override
  State<DocumentUploadView> createState() => _DocumentUploadViewState();
}

class _DocumentUploadViewState extends State<DocumentUploadView> {
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
          widget.documentType.displayName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<DocumentUploadBloc, DocumentUploadState>(
        listener: (context, state) {
          if (state.isSuccess) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${widget.documentType.displayName} uploaded successfully'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          } else if (state.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Upload failed'),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                _DocumentInfoSection(documentType: widget.documentType),
                const SizedBox(height: 32),
                _UploadSection(
                  documentType: widget.documentType,
                  frontImage: _frontImage,
                  backImage: _backImage,
                  onFrontImageSelected: (image) => setState(() => _frontImage = image),
                  onBackImageSelected: (image) => setState(() => _backImage = image),
                ),
                const SizedBox(height: 32),
                _DocumentUploadButton(
                  documentType: widget.documentType,
                  frontImage: _frontImage,
                  backImage: _backImage,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DocumentInfoSection extends StatelessWidget {
  const _DocumentInfoSection({required this.documentType});

  final DocumentType documentType;

  @override
  Widget build(BuildContext context) {
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
              color: AppColors.cyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getDocumentIcon(documentType),
              size: 32,
              color: AppColors.cyan,
            ),
          ),
          const SizedBox(height: 16),
          // Document Title
          Text(
            documentType.displayName,
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
            documentType.description,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          if (documentType.requiresBothSides) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Both front and back sides required',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
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
}

class _UploadSection extends StatelessWidget {
  const _UploadSection({
    required this.documentType,
    required this.frontImage,
    required this.backImage,
    required this.onFrontImageSelected,
    required this.onBackImageSelected,
  });

  final DocumentType documentType;
  final XFile? frontImage;
  final XFile? backImage;
  final Function(XFile) onFrontImageSelected;
  final Function(XFile) onBackImageSelected;

  @override
  Widget build(BuildContext context) {
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
              'Upload Photos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            // Front Image Upload
            _ImageUploadCard(
              title: 'Front Side',
              subtitle: 'Take a clear photo of the front',
              image: frontImage,
              onImageSelected: onFrontImageSelected,
              isRequired: true,
            ),
            if (documentType.requiresBothSides) ...[
              const SizedBox(height: 16),
              // Back Image Upload
              _ImageUploadCard(
                title: 'Back Side',
                subtitle: 'Take a clear photo of the back',
                image: backImage,
                onImageSelected: onBackImageSelected,
                isRequired: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ImageUploadCard extends StatelessWidget {
  const _ImageUploadCard({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.onImageSelected,
    required this.isRequired,
  });

  final String title;
  final String subtitle;
  final XFile? image;
  final Function(XFile) onImageSelected;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (isRequired) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Required',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ],
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
            // Image Preview
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
                  File(image!.path),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Replace Button
            Row(
              children: [
                Expanded(
                  child: _ImageUploadButton(
                    icon: Icons.camera_alt,
                    label: 'Retake Photo',
                    onPressed: () => _showImagePicker(context, onImageSelected),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ImageUploadButton(
                    icon: Icons.folder_open,
                    label: 'Choose File',
                    onPressed: () => _showImagePicker(context, onImageSelected, fromGallery: true),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Upload Buttons
            Row(
              children: [
                Expanded(
                  child: _ImageUploadButton(
                    icon: Icons.camera_alt,
                    label: 'Take Photo',
                    onPressed: () => _showImagePicker(context, onImageSelected),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ImageUploadButton(
                    icon: Icons.folder_open,
                    label: 'Choose File',
                    onPressed: () => _showImagePicker(context, onImageSelected, fromGallery: true),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showImagePicker(
    BuildContext context,
    Function(XFile) onImageSelected, {
    bool fromGallery = false,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: fromGallery ? ImageSource.gallery : ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        onImageSelected(image);
      }
    } catch (e) {
      if (context.mounted) {
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
}

class _ImageUploadButton extends StatelessWidget {
  const _ImageUploadButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 16,
        color: AppColors.cyan,
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
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
    );
  }
}

class _DocumentUploadButton extends StatelessWidget {
  const _DocumentUploadButton({
    required this.documentType,
    required this.frontImage,
    required this.backImage,
  });

  final DocumentType documentType;
  final XFile? frontImage;
  final XFile? backImage;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentUploadBloc, DocumentUploadState>(
      builder: (context, state) {
        final canUpload = frontImage != null && 
                         (!documentType.requiresBothSides || backImage != null);
        final isUploading = state.isSubmitting;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: canUpload && !isUploading
                ? const LinearGradient(
                    colors: [AppColors.cyan, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: canUpload && !isUploading
                ? [
                    BoxShadow(
                      color: AppColors.cyan.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: ElevatedButton(
            onPressed: canUpload && !isUploading
                ? () => _uploadDocument(context)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canUpload && !isUploading 
                  ? Colors.transparent 
                  : AppColors.border,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: isUploading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Uploading...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.upload_rounded,
                        size: 20,
                        color: canUpload ? Colors.white : AppColors.textTertiary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Upload Document',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: canUpload ? Colors.white : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  void _uploadDocument(BuildContext context) {
    final bloc = context.read<DocumentUploadBloc>();
    
    // Upload front image
    if (frontImage != null) {
      bloc.add(DocumentUploadStarted(
        type: documentType,
        filePath: frontImage!.path,
        fileName: frontImage!.name,
        fileSize: File(frontImage!.path).lengthSync(),
      ));
    }

    // Upload back image if required
    if (backImage != null && documentType.requiresBothSides) {
      bloc.add(DocumentUploadCompleted(
        type: documentType,
        frontImagePath: frontImage!.path,
        backImagePath: backImage!.path,
        fileName: frontImage!.name,
        fileSize: File(frontImage!.path).lengthSync(),
      ));
    } else if (frontImage != null) {
      bloc.add(DocumentUploadCompleted(
        type: documentType,
        frontImagePath: frontImage!.path,
        fileName: frontImage!.name,
        fileSize: File(frontImage!.path).lengthSync(),
      ));
    }
  }
}
