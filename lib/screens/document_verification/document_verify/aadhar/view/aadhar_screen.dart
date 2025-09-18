import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../widgets/colors.dart';
import '../bloc/aadhar_bloc.dart';

class AadharScreen extends StatelessWidget {
  const AadharScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AadharBloc(),
      child: const AadharView(),
    );
  }
}

class AadharView extends StatelessWidget {
  const AadharView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<AadharBloc, AadharState>(
        listener: (context, state) {
          if (state.status == AadharStatus.success) {
            Navigator.of(context).pop(); // Go back to docs screen
          } else if (state.status == AadharStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Failed to submit Aadhaar'),
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
                const _AadharForm(),
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
              Icons.credit_card_rounded,
              size: 32,
              color: AppColors.cyan,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Verify Your Identity',
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
            'Upload your Aadhaar card for verification',
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

class _AadharForm extends StatelessWidget {
  const _AadharForm();

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
                    Icons.credit_card_rounded,
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
                        'Aadhaar Verification',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Enter your Aadhaar number and upload image',
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
            const SizedBox(height: 32),
            const _AadharNumberField(),
            const SizedBox(height: 24),
            const _AadharImageField(),
          ],
        ),
      ),
    );
  }
}

class _AadharNumberField extends StatelessWidget {
  const _AadharNumberField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AadharBloc, AadharState>(
      buildWhen: (previous, current) => previous.aadharNumber != current.aadharNumber,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aadhaar Number',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              onChanged: (aadharNumber) => context
                  .read<AadharBloc>()
                  .add(AadharNumberChanged(aadharNumber)),
              keyboardType: TextInputType.number,
              maxLength: 12,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Enter your 12-digit Aadhaar number',
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
                    Icons.credit_card_outlined,
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
                errorText: state.aadharNumber.displayError != null
                    ? (state.aadharNumber.error == AadharNumberValidationError.empty
                        ? 'Aadhaar number is required'
                        : 'Enter a valid 12-digit Aadhaar number')
                    : null,
                errorStyle: TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                counterText: '',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AadharImageField extends StatelessWidget {
  const _AadharImageField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AadharBloc, AadharState>(
      buildWhen: (previous, current) => previous.aadharImage != current.aadharImage,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aadhaar Card Image',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                // TODO: Implement image picker
              },
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: state.aadharImage.value.isEmpty
                    ? Center(
                        child: Icon(Icons.badge_rounded, color: AppColors.cyan, size: 48),
                      )
                    : Center(
                        child: Text('Image selected', style: TextStyle(color: AppColors.cyan)),
                      ),
              ),
            ),
            if (state.aadharImage.displayError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Aadhaar image is required',
                  style: TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AadharBloc, AadharState>(
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
                ? () => _submitDocument(context, state)
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
            child: state.status == AadharStatus.loading
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
                        'Uploading to Admin...',
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
                        Icons.upload_outlined,
                        size: 20,
                        color: state.isValid ? Colors.white : AppColors.textTertiary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Submit for Review',
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

  Future<void> _submitDocument(BuildContext context, AadharState state) async {
    // Simulate submission and show success message
    context.read<AadharBloc>().add(const AadharSubmitted());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Aadhaar document submitted for admin review'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.of(context).pop();
  }
}