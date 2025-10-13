import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:driver/models/document_upload.dart' as local_models;
import 'package:driver/widgets/colors.dart';
import 'package:driver/core/error/document_upload_error.dart';
import 'package:driver/services/services.dart';
import 'package:documents_repo/documents_repo.dart' as documents_repo;

import 'package:driver/screens/document_upload/bloc/document_upload_bloc.dart';
import 'package:driver/locator.dart';

/// {@template enhanced_document_upload_screen}
/// Enhanced document upload screen with Uber/Ola-level features.
/// {@endtemplate}
class EnhancedDocumentUploadScreen extends StatefulWidget {
  /// {@macro enhanced_document_upload_screen}
  const EnhancedDocumentUploadScreen({
    super.key,
    required this.documentType,
  });

  final local_models.DocumentType documentType;

  @override
  State<EnhancedDocumentUploadScreen> createState() => _EnhancedDocumentUploadScreenState();
}

class _EnhancedDocumentUploadScreenState extends State<EnhancedDocumentUploadScreen>
    with TickerProviderStateMixin {
  XFile? _frontImage;
  XFile? _backImage;
  DocumentQualityResult? _qualityResult;
  bool _isValidating = false;
  bool _isAutoCropping = false;
  String? _croppedImagePath;
  
  late AnimationController _progressController;
  late AnimationController _qualityController;
  late Animation<double> _progressAnimation;
  late Animation<double> _qualityAnimation;

  late final DocumentQualityValidator _qualityValidator;
  late final ChunkedUploadService _uploadService;
  late final UploadProgressTracker _progressTracker;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _qualityController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    _qualityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _qualityController, curve: Curves.easeInOut),
    );

    // Initialize services from service locator
    _qualityValidator = sl<DocumentQualityValidator>();
    _uploadService = sl<ChunkedUploadService>();
    _progressTracker = UploadProgressTracker();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _qualityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.documentType.displayName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppColors.textPrimary),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: BlocListener<DocumentUploadBloc, DocumentUploadState>(
        listener: (context, state) {
          if (state.isSuccess) {
            _progressController.forward();
            Navigator.of(context).pop();
            _showSuccessSnackBar('Document uploaded successfully!');
          } else if (state.hasError) {
            _showErrorSnackBar(state.errorMessage!);
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildDocumentInfoSection(),
                const SizedBox(height: 24),
                _buildQualityValidationSection(),
                const SizedBox(height: 24),
                _buildUploadSection(),
                const SizedBox(height: 24),
                _buildProgressSection(),
                const SizedBox(height: 24),
                _buildUploadButton(),
                const SizedBox(height: 24),
                _buildTipsSection(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentInfoSection() {
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getDocumentIcon(widget.documentType),
              size: 32,
              color: AppColors.cyan,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.documentType.displayName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.documentType.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.documentType.requiresBothSides) ...[
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
                  Icon(Icons.info_outline, size: 14, color: AppColors.warning),
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

  Widget _buildQualityValidationSection() {
    if (_qualityResult == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _qualityAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _qualityAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _qualityResult!.needsRetake! 
                  ? AppColors.error.withOpacity(0.1)
                  : AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _qualityResult!.needsRetake! 
                    ? AppColors.error.withOpacity(0.3)
                    : AppColors.success.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _qualityResult!.needsRetake! ? Icons.error : Icons.check_circle,
                      color: _qualityResult!.needsRetake! ? AppColors.error : AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Quality Check',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _qualityResult!.needsRetake! ? AppColors.error : AppColors.success,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_qualityResult!.overallScore}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _qualityResult!.needsRetake! ? AppColors.error : AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._qualityResult!.validations!.map((check) => _buildQualityCheckItem(check)),
                if (_qualityResult!.cropRecommendation != null) ...[
                  const SizedBox(height: 12),
                  _buildCropRecommendation(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQualityCheckItem(DocumentQualityCheck check) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            check.status == QualityStatus.pass ? Icons.check_circle :
            check.status == QualityStatus.warning ? Icons.warning :
            Icons.error,
            size: 16,
            color: check.status == QualityStatus.pass ? AppColors.success :
                   check.status == QualityStatus.warning ? AppColors.warning :
                   AppColors.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              check.message,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropRecommendation() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cyan.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.crop, size: 16, color: AppColors.cyan),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Auto-crop recommended for better visibility',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.cyan,
              ),
            ),
          ),
          TextButton(
            onPressed: _isAutoCropping ? null : _performAutoCrop,
            child: _isAutoCropping
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Auto-crop',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cyan,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
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
            _buildImageUploadCard(
              title: 'Front Side',
              subtitle: 'Take a clear photo of the front',
              image: _frontImage,
              onImageSelected: (image) => _onFrontImageSelected(image),
              isRequired: true,
            ),
            if (widget.documentType.requiresBothSides) ...[
              const SizedBox(height: 16),
              _buildImageUploadCard(
                title: 'Back Side',
                subtitle: 'Take a clear photo of the back',
                image: _backImage,
                onImageSelected: (image) => _onBackImageSelected(image),
                isRequired: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadCard({
    required String title,
    required String subtitle,
    required XFile? image,
    required void Function(XFile) onImageSelected,
    required bool isRequired,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
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
            Row(
              children: [
                Expanded(
                  child: _buildImageUploadButton(
                    icon: Icons.camera_alt,
                    label: 'Retake Photo',
                    onPressed: () => _showImagePicker(onImageSelected),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildImageUploadButton(
                    icon: Icons.folder_open,
                    label: 'Choose File',
                    onPressed: () => _showImagePicker(onImageSelected, fromGallery: true),
                  ),
                ),
                const SizedBox(width: 12),
                _buildImageUploadButton(
                  icon: Icons.analytics,
                  label: 'Check Quality',
                  onPressed: () => _validateImageQuality(image),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: _buildImageUploadButton(
                    icon: Icons.camera_alt,
                    label: 'Take Photo',
                    onPressed: () => _showImagePicker(onImageSelected),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildImageUploadButton(
                    icon: Icons.folder_open,
                    label: 'Choose File',
                    onPressed: () => _showImagePicker(onImageSelected, fromGallery: true),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageUploadButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: AppColors.cyan),
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

  Widget _buildProgressSection() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
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
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upload Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: _progressAnimation.value,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.cyan),
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              Text(
                '${(_progressAnimation.value * 100).toInt()}% Complete',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUploadButton() {
    return BlocBuilder<DocumentUploadBloc, DocumentUploadState>(
      builder: (context, state) {
        final canUpload = _frontImage != null && 
                         (!widget.documentType.requiresBothSides || _backImage != null);
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

  Widget _buildTipsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Tips for Better Results',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._getTipsForDocumentType().map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle, size: 14, color: AppColors.success),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tip,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  List<String> _getTipsForDocumentType() {
    switch (widget.documentType) {
      case local_models.DocumentType.drivingLicense:
        return [
          'Ensure all text is clearly visible',
          'Avoid shadows and glare',
          'Keep the document flat',
          'Use good lighting',
        ];
      case local_models.DocumentType.aadhaarCard:
        return [
          'Make sure QR code is visible',
          'Avoid covering any part of the document',
          'Use even lighting',
          'Keep camera steady',
        ];
      case local_models.DocumentType.panCard:
        return [
          'Ensure PAN number is clearly visible',
          'Avoid reflections on the card',
          'Use natural lighting if possible',
          'Keep the card flat',
        ];
      default:
        return [
          'Use good lighting',
          'Keep the document flat',
          'Avoid shadows and glare',
          'Ensure all text is readable',
        ];
    }
  }

  IconData _getDocumentIcon(local_models.DocumentType type) {
    switch (type) {
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

  void _onFrontImageSelected(XFile image) {
    setState(() {
      _frontImage = image;
      _qualityResult = null;
    });
  }

  void _onBackImageSelected(XFile image) {
    setState(() {
      _backImage = image;
    });
  }

  Future<void> _showImagePicker(
    void Function(XFile) onImageSelected, {
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
        // Validate file before selection
        final error = DocumentUploadErrorHandler.validateFile(image.path, image.name);
        if (error != null) {
          _showErrorSnackBar(DocumentUploadErrorHandler.getUserFriendlyMessage(error));
          return;
        }

        // Check file size
        final file = File(image.path);
        final fileSize = await file.length();
        if (fileSize > DocumentUploadErrorHandler.maxFileSize) {
          _showErrorSnackBar(DocumentUploadErrorHandler.getUserFriendlyMessage(
            FileSizeError(
              actualSize: fileSize,
              maxSize: DocumentUploadErrorHandler.maxFileSize,
            ),
          ));
          return;
        }

        onImageSelected(image);
      }
    } catch (e) {
      final error = DocumentUploadErrorHandler.handleException(e);
      _showErrorSnackBar(DocumentUploadErrorHandler.getUserFriendlyMessage(error));
    }
  }

  Future<void> _validateImageQuality(XFile image) async {
    setState(() => _isValidating = true);

    try {
      final result = await _qualityValidator.validateDocument(
        imagePath: image.path,
        documentType: _convertToRepoDocumentType(widget.documentType),
      );

      setState(() {
        _qualityResult = result;
        _isValidating = false;
      });

      if (result.isSuccess) {
        _qualityController.forward();
      }
    } catch (e) {
      setState(() => _isValidating = false);
      _showErrorSnackBar('Quality validation failed: ${e.toString()}');
    }
  }

  Future<void> _performAutoCrop() async {
    if (_frontImage == null) return;

    setState(() => _isAutoCropping = true);

    try {
      final croppedPath = await _qualityValidator.autoCropDocument(
        imagePath: _frontImage!.path,
        documentType: _convertToRepoDocumentType(widget.documentType),
      );

      if (croppedPath != null) {
        setState(() {
          _croppedImagePath = croppedPath;
          _frontImage = XFile(croppedPath);
        });
        _showSuccessSnackBar('Image cropped successfully!');
      } else {
        _showErrorSnackBar('Auto-crop failed. Please try again.');
      }
    } catch (e) {
      _showErrorSnackBar('Auto-crop error: ${e.toString()}');
    } finally {
      setState(() => _isAutoCropping = false);
    }
  }

  void _uploadDocument(BuildContext context) {
    final bloc = context.read<DocumentUploadBloc>();
    
    if (widget.documentType.requiresBothSides && _frontImage != null && _backImage != null) {
      bloc.add(DocumentUploadCompleted(
        type: widget.documentType,
        frontImagePath: _frontImage!.path,
        backImagePath: _backImage!.path,
        fileName: _frontImage!.name,
        fileSize: File(_frontImage!.path).lengthSync(),
      ));
    } else if (_frontImage != null) {
      bloc.add(DocumentUploadCompleted(
        type: widget.documentType,
        frontImagePath: _frontImage!.path,
        fileName: _frontImage!.name,
        fileSize: File(_frontImage!.path).lengthSync(),
      ));
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Help - ${widget.documentType.displayName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Requirements:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._getTipsForDocumentType().map((tip) => Text('• $tip')),
            const SizedBox(height: 16),
            Text('File Requirements:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('• Format: JPG, PNG, or PDF'),
            Text('• Size: Maximum 5MB'),
            Text('• Quality: Clear and readable'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  documents_repo.DocumentType _convertToRepoDocumentType(local_models.DocumentType localType) {
    switch (localType) {
      case local_models.DocumentType.drivingLicense:
        return documents_repo.DocumentType.drivingLicense;
      case local_models.DocumentType.registrationCertificate:
        return documents_repo.DocumentType.rcBook;
      case local_models.DocumentType.vehicleInsurance:
        return documents_repo.DocumentType.insurance;
      case local_models.DocumentType.profilePicture:
        return documents_repo.DocumentType.profilePicture;
      case local_models.DocumentType.aadhaarCard:
        return documents_repo.DocumentType.aadhaar;
      case local_models.DocumentType.panCard:
        return documents_repo.DocumentType.pan;
      case local_models.DocumentType.addressProof:
        return documents_repo.DocumentType.addressProof;
    }
  }
}
