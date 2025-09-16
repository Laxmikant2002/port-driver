import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import '../bloc/login_bloc.dart';
import 'phone_field.dart';
import '../../../../widgets/colors.dart';
import '../../../../constants/app_constants.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(),
      child: _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: AppConstants.kFadeAnimationDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Clean solid background (matches screenshot's light blue vibe)
          Container(
            decoration: const BoxDecoration(
              color: AppColors.backgroundPrimary,
              // Removed radial gradient for cleaner look
            ),
          ),
          // Fullscreen background illustration - FIXED: Use contain for no distortion with increased height
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).size.height * 0.10, // Extend image higher by reducing bottom space
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Image.asset(
                'assets/background anime .png',
                fit: BoxFit.contain, // CHANGED: From cover to contain—preserves aspect ratio
                alignment: Alignment.topCenter, // Changed to topCenter to push image up and make it appear taller
                // UPDATED: Use responsive cache helpers for optimal performance
                cacheWidth: context.backgroundCacheWidth,
                cacheHeight: context.backgroundCacheHeight,
                errorBuilder: (context, error, stackTrace) {
                  // FALLBACK: Clean gradient background if asset fails
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFE3F2FD), // Light blue top (matches screenshot)
                          Color(0xFFF8FAFC), // Very light blue-white bottom
                        ],
                        stops: [0.0, 1.0],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // UPDATED: Much lighter overlay to preserve image vibrancy - positioned to match image area
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).size.height * 0.25, // Match the image positioning
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    AppColors.backgroundPrimary.withOpacity(0.02), // REDUCED: Much lighter
                    AppColors.backgroundPrimary.withOpacity(0.05), // REDUCED: Much lighter
                  ],
                  stops: const [0.0, 0.6, 0.85, 1.0], // ADJUSTED: More transparent for better illustration visibility
                ),
              ),
            ),
          ),
          // Responsive company branding and content
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(context.responsivePadding),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppConstants.kPaddingLarge,
                        vertical: AppConstants.kPaddingMedium,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(AppConstants.kContainerBorderRadius),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        'Electric Loading Gadi',
                        style: TextStyle(
                          fontSize: context.isMobile ? AppConstants.kBrandTextSize : 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                const _BottomCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomCard extends StatelessWidget {
  const _BottomCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveHorizontalPadding,
        vertical: context.responsiveVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.kCardBorderRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -12),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 40,
            offset: const Offset(0, -20),
            spreadRadius: 0,
          ),
        ],
      ),
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state.status == FormzSubmissionStatus.success) {
            Navigator.pushNamed(context, '/signup');
          } else if (state.status == FormzSubmissionStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error ?? 'Submission failed'),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.kBorderRadius),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome header with modern styling
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.kPaddingMedium,
                    vertical: AppConstants.kPaddingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.kPaddingMedium),
                  ),
                  child: const Text(
                    '👋',
                    style: TextStyle(fontSize: AppConstants.kIconSize),
                  ),
                ),
                const SizedBox(width: AppConstants.kPaddingMedium),
                Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: context.isMobile ? AppConstants.kTitleTextSize : 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _showInfoDialog(context),
                  child: Container(
                    padding: const EdgeInsets.all(AppConstants.kPaddingSmall),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: AppColors.teal,
                      size: AppConstants.kIconSize,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.kPaddingMedium),
            Text(
              'Enter your mobile number for quick and secure access to deliveries',
              style: TextStyle(
                fontSize: AppConstants.kBodyTextSize,
                color: AppColors.textSecondary,
                height: 1.4,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: AppConstants.kPaddingXLarge),
            const PhoneField(),
            const SizedBox(height: AppConstants.kPaddingLarge + 4),
            BlocBuilder<LoginBloc, LoginState>(
              builder: (context, state) {
                final isValid = state.phoneInput.isValid;
                return AnimatedOpacity(
                  opacity: isValid ? 1.0 : 0.0,
                  duration: AppConstants.kValidationAnimationDuration,
                  child: isValid
                      ? const _ContinueButton()
                      : const SizedBox.shrink(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.kContainerBorderRadius),
        ),
        title: const Text(
          'Why Mobile Number?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'We need your mobile number to send OTP for verification and delivery updates.',
          style: TextStyle(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.teal.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Got it',
              style: TextStyle(
                color: AppColors.teal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        final isLoading = state.status == FormzSubmissionStatus.inProgress;
        return SizedBox(
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.buttonGradient,
              borderRadius: BorderRadius.circular(AppConstants.kButtonBorderRadius),
              boxShadow: [
                BoxShadow(
                  color: AppColors.teal.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () => context.read<LoginBloc>().add(SubmitLogin()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(
                  vertical: context.isMobile ? 18 : 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.kButtonBorderRadius),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}
