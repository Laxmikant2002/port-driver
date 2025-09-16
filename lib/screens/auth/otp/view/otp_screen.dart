import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auth_repo/auth_repo.dart';
import 'package:formz/formz.dart';
import 'package:driver/locator.dart';
import '../../../../widgets/colors.dart';

import '../bloc/otp_bloc.dart';
import 'otp_field.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final phone = ModalRoute.of(context)!.settings.arguments as String;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => OtpBloc(lc<AuthRepo>(), phone),
        ),
      ],
      child: const _OtpScreen(),
    );
  }
}

class _OtpScreen extends StatelessWidget {
  const _OtpScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: BlocListener<OtpBloc, OtpState>(
        listener: (context, state) {
          if (state.status == FormzSubmissionStatus.success) {
            // For new users, navigate to profile screen
            // For existing users, navigate to home
            // TODO: Check if user is new or existing from API response
            final phone = ModalRoute.of(context)!.settings.arguments as String;
            Navigator.pushReplacementNamed(context, '/profile', arguments: phone);
          } else if (state.status == FormzSubmissionStatus.failure && state.error != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: AppColors.error,
                  duration: const Duration(seconds: 4),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  action: SnackBarAction(
                    label: 'Dismiss',
                    textColor: AppColors.textLight,
                    onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                  ),
                ),
              );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                const _Logo(),
                const SizedBox(height: 48),
                const _OtpCard(),
                const SizedBox(height: 32),
                _ChangeNumberLink(),
                const SizedBox(height: 16),
                // Testing bypass button (remove for production)
                const _BypassButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VerifyButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OtpBloc, OtpState>(
      builder: (context, state) {
        final isLoading = state.status == FormzSubmissionStatus.inProgress;
        final isDisabled = isLoading || !state.isValid;
        
        return Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: isDisabled 
                ? null 
                : LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isDisabled 
                ? null 
                : [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: ElevatedButton(
            onPressed: isDisabled ? null : () => context.read<OtpBloc>().add(const VerifyOtp()),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDisabled ? Colors.grey[300] : Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    'Verify OTP',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDisabled ? AppColors.textSecondary : Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            'Electric Loading Gadi',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Secure Verification',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpCard extends StatelessWidget {
  const _OtpCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32), // Increased padding for better spacing
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24), // More rounded for modern look
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08), // Subtle primary color shadow
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Center align for better hierarchy
        children: [
          // Icon with background circle
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.sms_outlined,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Verify Your Number',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28, // Larger for better hierarchy
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'We sent a 4-digit OTP to your number.\nPlease enter it below to continue.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          const OtpField(),
          const SizedBox(height: 24),
          const _ResendText(),
          const SizedBox(height: 32),
          _VerifyButton(),
        ],
      ),
    );
  }
}

class _ResendText extends StatelessWidget {
  const _ResendText();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OtpBloc, OtpState>(
      builder: (context, state) {
        return Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                if (state.canResend)
                  GestureDetector(
                    onTap: () => context.read<OtpBloc>().add(const ResendOtp()),
                    child: Text(
                      'Resend OTP',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                else
                  Text(
                    'Resend in ${state.resendTimer}s',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
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

Widget _ChangeNumberLink() {
  return Builder(
    builder: (context) => Center(
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Text(
          'Change Number',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    ),
  );
}

class _BypassButton extends StatelessWidget {
  const _BypassButton();

  @override
  Widget build(BuildContext context) {
    final phone = ModalRoute.of(context)!.settings.arguments as String;
    
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () => Navigator.pushReplacementNamed(context, '/profile', arguments: phone),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.warning,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'BYPASS OTP (TESTING)',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}