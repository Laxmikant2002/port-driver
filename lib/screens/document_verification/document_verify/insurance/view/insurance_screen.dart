import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../../../widgets/colors.dart';
import '../bloc/insurance_bloc.dart';

class InsuranceScreen extends StatelessWidget {
  const InsuranceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InsuranceBloc(),
      child: const InsuranceView(),
    );
  }
}

class InsuranceView extends StatelessWidget {
  const InsuranceView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<InsuranceBloc, InsuranceState>(
        listener: (context, state) {
          if (state.status == InsuranceStatus.success) {
            Navigator.of(context).pop(); // Go back to docs screen
          } else if (state.status == InsuranceStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Failed to submit Insurance'),
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
                const _InsuranceForm(),
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
              Icons.security_rounded,
              size: 32,
              color: AppColors.cyan,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Upload Insurance Certificate',
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
            'Upload your vehicle insurance certificate for verification',
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

class _InsuranceForm extends StatelessWidget {
  const _InsuranceForm();

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
                    Icons.security_rounded,
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
                        'Insurance Verification',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        'Enter policy details and upload certificate',
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
            const _PolicyNumberField(),
            const SizedBox(height: 24),
            const _ExpiryDateField(),
            const SizedBox(height: 24),
            const _InsuranceImageField(),
          ],
        ),
      ),
    );
  }
}

class _PolicyNumberField extends StatelessWidget {
  const _PolicyNumberField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InsuranceBloc, InsuranceState>(
      buildWhen: (previous, current) => previous.policyNumber != current.policyNumber,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Policy Number',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              onChanged: (policyNumber) => context
                  .read<InsuranceBloc>()
                  .add(InsurancePolicyNumberChanged(policyNumber)),
              keyboardType: TextInputType.text,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Enter your insurance policy number',
                hintStyle: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 16,
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    color: AppColors.cyan,
                    size: 20,
                  ),
                ),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.cyan,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.error,
                    width: 1,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.error,
                    width: 2,
                  ),
                ),
                errorText: state.policyNumber.displayError != null
                    ? (state.policyNumber.error == InsurancePolicyNumberValidationError.empty
                        ? 'Policy number is required'
                        : 'Enter a valid policy number')
                    : null,
                errorStyle: TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ExpiryDateField extends StatelessWidget {
  const _ExpiryDateField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InsuranceBloc, InsuranceState>(
      buildWhen: (previous, current) => previous.expiryDate != current.expiryDate,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expiry Date',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              onChanged: (expiryDate) => context
                  .read<InsuranceBloc>()
                  .add(InsuranceExpiryDateChanged(expiryDate)),
              keyboardType: TextInputType.datetime,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'DD/MM/YYYY or YYYY-MM-DD',
                hintStyle: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 16,
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.cyan,
                    size: 20,
                  ),
                ),
                suffixIcon: GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.calendar_month_outlined,
                      color: AppColors.cyan,
                      size: 20,
                    ),
                  ),
                ),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.cyan,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.error,
                    width: 1,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.error,
                    width: 2,
                  ),
                ),
                errorText: state.expiryDate.displayError != null
                    ? (state.expiryDate.error == InsuranceExpiryDateValidationError.empty
                        ? 'Expiry date is required'
                        : 'Enter a valid date (DD/MM/YYYY or YYYY-MM-DD)')
                    : null,
                errorStyle: TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.cyan,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      final formattedDate = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      context.read<InsuranceBloc>().add(InsuranceExpiryDateChanged(formattedDate));
    }
  }
}

class _InsuranceImageField extends StatelessWidget {
  const _InsuranceImageField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InsuranceBloc, InsuranceState>(
      buildWhen: (previous, current) => previous.insuranceImage != current.insuranceImage,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Insurance Certificate',
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
                    color: state.insuranceImage.displayError != null
                        ? AppColors.error
                        : AppColors.border,
                    width: state.insuranceImage.displayError != null ? 2 : 1,
                  ),
                ),
                child: state.insuranceImage.value.isEmpty
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
                            'Tap to upload insurance certificate',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Camera or Gallery',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(state.insuranceImage.value),
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
                      ),
              ),
            ),
            if (state.insuranceImage.displayError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Insurance certificate is required',
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
                const SizedBox(width: 12),
                Expanded(
                  child: _ImageOptionButton(
                    icon: Icons.photo_library_outlined,
                    label: 'Choose from Gallery',
                    onTap: () => _pickFromGallery(context),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
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
                const SizedBox(width: 16),
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
        context.read<InsuranceBloc>().add(InsuranceImageChanged(image.path));
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
        context.read<InsuranceBloc>().add(InsuranceImageChanged(image.path));
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to pick image: ${e.toString()}');
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
    return BlocBuilder<InsuranceBloc, InsuranceState>(
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
                ? () => context.read<InsuranceBloc>().add(const InsuranceSubmitted())
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
            child: state.status == InsuranceStatus.loading
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
                        'Verifying Insurance...',
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
                        'Verify Insurance',
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