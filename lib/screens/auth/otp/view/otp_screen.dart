import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auth_repo/auth_repo.dart';
import 'package:formz/formz.dart';
import 'package:profile_repo/profile_repo.dart';
import 'package:driver/locator.dart';
import '../../../../widgets/colors.dart';
import 'package:driver/routes/account_routes.dart';
import 'package:driver/routes/main_routes.dart';

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
          create: (context) => OtpBloc(
            authRepo: lc<AuthRepo>(),
            profileRepo: lc<ProfileRepo>(),
            phone: phone,
          ),
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
      backgroundColor: AppColors.background,
      body: BlocListener<OtpBloc, OtpState>(
        listener: (context, state) {
          if (state.isSuccess && state.user != null && state.routeDecision != null) {
            // Navigate based on route decision from backend
            final routeDecision = state.routeDecision!;
            
            // Log the route decision for debugging
            debugPrint('Route Decision: ${routeDecision.reason}');
            debugPrint('Navigating to: ${routeDecision.route}');
            
            Navigator.pushReplacementNamed(
              context, 
              routeDecision.route, 
              arguments: routeDecision.arguments,
            );
          } else if (state.hasError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.error,
                  duration: const Duration(seconds: 4),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  action: SnackBarAction(
                    label: 'Dismiss',
                    textColor: AppColors.textTertiary,
                    onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
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
                const SizedBox(height: 32),
                const _OtpCard(),
                const SizedBox(height: 32),
                _ChangeNumberLink(),
                const SizedBox(height: 16),
                // Testing bypass button (remove for production)
                const _BypassButton(),
                const SizedBox(height: 24),
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
        final isLoading = state.isSubmitting;
        final isDisabled = isLoading || !state.isValid;
        
        return Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: isDisabled 
                ? null 
                : LinearGradient(
                    colors: [AppColors.cyan, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isDisabled 
                ? null 
                : [
                    BoxShadow(
                      color: AppColors.cyan.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: ElevatedButton(
            onPressed: isDisabled ? null : () => context.read<OtpBloc>().add(const OtpSubmitted()),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDisabled ? AppColors.border : Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Verifying...',
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
                        color: isDisabled ? AppColors.textTertiary : Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Verify OTP',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDisabled ? AppColors.textTertiary : Colors.white,
                          letterSpacing: 0.5,
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
          // OTP Icon
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
          // Welcome Text
          Text(
            'Verify Your Number',
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
            'Enter the OTP sent to your mobile number',
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

class _OtpCard extends StatelessWidget {
  const _OtpCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title
          Text(
            'Verify Your Number',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We sent a 4-digit OTP to your number.\nPlease enter it below to continue.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          const OtpField(),
          const SizedBox(height: 16),
          const _ResendText(),
          const SizedBox(height: 24),
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
                color: AppColors.border,
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
                    onTap: () => context.read<OtpBloc>().add(const OtpResendRequested()),
                    child: Text(
                      'Resend OTP',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.cyan,
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
            color: AppColors.cyan,
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