import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../../../../widgets/colors.dart';
import '../bloc/license_bloc.dart';

class LicenseScreen extends StatelessWidget {
  const LicenseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LicenseBloc(),
      child: const LicenseView(),
    );
  }
}

class LicenseView extends StatelessWidget {
  const LicenseView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<LicenseBloc, LicenseState>(
        listener: (context, state) {
          if (state.isSuccess) {
            Navigator.of(context).pop(); // Go back to docs screen
          } else if (state.hasError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Failed to submit License'),
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
                const _HeaderSection(),
                const SizedBox(height: 24),
                const _LicenseForm(),
                const SizedBox(height: 32),
                const _SubmitButton(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.card_membership_rounded,
              size: 32,
              color: AppColors.cyan,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Upload Driving License',
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
            'Upload front and back photos of your driving license or PDF document',
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

class _LicenseForm extends StatelessWidget {
  const _LicenseForm();

  @override
  Widget build(BuildContext context) {
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.card_membership_rounded,
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
                        'License Verification',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        'Upload front and back photos or PDF of your driving license',
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
            const SizedBox(height: 32),
            const _LicenseFrontImageField(),
            const SizedBox(height: 24),
            const _LicenseBackImageField(),
          ],
        ),
      ),
    );
  }
}

class _LicenseFrontImageField extends StatelessWidget {
  const _LicenseFrontImageField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LicenseBloc, LicenseState>(
      buildWhen: (previous, current) => previous.frontImage != current.frontImage,
      builder: (context, state) {
        return _ImageUploadCard(
          title: 'License Front Photo',
          subtitle: 'Take a clear photo of the front side',
          icon: Icons.card_membership_rounded,
          imagePath: state.frontImage.value,
                errorText: state.frontImage.errorMessage,
          onImageSelected: (path) => context
              .read<LicenseBloc>()
              .add(LicenseFrontImageChanged(path)),
        );
      },
    );
  }
}

class _LicenseBackImageField extends StatelessWidget {
  const _LicenseBackImageField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LicenseBloc, LicenseState>(
      buildWhen: (previous, current) => previous.backImage != current.backImage,
      builder: (context, state) {
        return _ImageUploadCard(
          title: 'License Back Photo',
          subtitle: 'Take a clear photo of the back side',
          icon: Icons.card_membership_rounded,
          imagePath: state.backImage.value,
                errorText: state.backImage.errorMessage,
          onImageSelected: (path) => context
              .read<LicenseBloc>()
              .add(LicenseBackImageChanged(path)),
        );
      },
    );
  }
}

class _ImageUploadCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String imagePath;
  final String? errorText;
  final Function(String) onImageSelected;

  const _ImageUploadCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.imagePath,
    required this.onImageSelected,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
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
        GestureDetector(
          onTap: () => _showImagePickerOptions(context),
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: errorText != null ? AppColors.error : AppColors.border,
                width: errorText != null ? 2 : 1,
              ),
            ),
            child: imagePath.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cyan.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.add_photo_alternate_outlined,
                          color: AppColors.cyan,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Camera, Gallery or File',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  )
                : _buildFilePreview(imagePath),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              errorText!,
              style: TextStyle(
                color: AppColors.error,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ImageOptionButton(
                icon: Icons.camera_alt_outlined,
                label: 'Take Photo',
                onTap: () => _takePhoto(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ImageOptionButton(
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                onTap: () => _pickFromGallery(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ImageOptionButton(
                icon: Icons.attach_file_outlined,
                label: 'Upload File',
                onTap: () => _pickFile(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilePreview(String filePath) {
    final file = File(filePath);
    final extension = filePath.split('.').last.toLowerCase();
    
    if (extension == 'pdf') {
      return Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.picture_as_pdf,
                color: AppColors.error,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'PDF Document',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              filePath.split('/').last,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          file,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 160,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.background,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load image',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
  }

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _ImageOptionButton(
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _takePhoto(context);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ImageOptionButton(
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickFromGallery(context);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ImageOptionButton(
                    icon: Icons.attach_file_outlined,
                    label: 'File',
                    onTap: () {
                      Navigator.pop(context);
                      _pickFile(context);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _takePhoto(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (image != null) {
        onImageSelected(image.path);
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to take photo: ${e.toString()}');
    }
  }

  void _pickFromGallery(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (image != null) {
        onImageSelected(image.path);
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to pick image: ${e.toString()}');
    }
  }

  void _pickFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        onImageSelected(result.files.single.path!);
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to pick file: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class _ImageOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageOptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.cyan,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LicenseBloc, LicenseState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.isValid != current.isValid,
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: state.isValid
                ? LinearGradient(
                    colors: [AppColors.cyan, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: state.isValid
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
            onPressed: state.isValid
                ? () => context.read<LicenseBloc>().add(const LicenseSubmitted())
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: state.isValid ? Colors.transparent : AppColors.border,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: state.isSubmitting
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
                        'Verifying License...',
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
                        Icons.verified_user_outlined,
                        size: 20,
                        color: state.isValid ? Colors.white : AppColors.textTertiary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Verify License',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: state.isValid ? Colors.white : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}