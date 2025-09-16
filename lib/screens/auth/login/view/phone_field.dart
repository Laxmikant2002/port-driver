import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/login_bloc.dart';
import '../../../../widgets/colors.dart';
import '../../../../constants/app_constants.dart';

class PhoneField extends StatefulWidget {
  const PhoneField({super.key});

  @override
  State<PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<PhoneField>
    with SingleTickerProviderStateMixin {
  late AnimationController _validationController;
  late Animation<Color?> _borderColorAnimation;
  String _selectedCountryCode = AppConstants.kDefaultCountryCode;
  
  @override
  void initState() {
    super.initState();
    _validationController = AnimationController(
      duration: AppConstants.kValidationAnimationDuration,
      vsync: this,
    );
    
    _borderColorAnimation = ColorTween(
      begin: AppColors.borderFocus.withOpacity(0.5),
      end: AppColors.success,
    ).animate(CurvedAnimation(
      parent: _validationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _validationController.dispose();
    super.dispose();
  }

  String _getDigitCountText(String phoneNumber) {
    // Remove country code and formatting to get raw digits
    final rawDigits = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    final digitCount = rawDigits.length;
    
    return '$digitCount/${AppConstants.kPhoneNumberLength}';
  }

  Color _getDigitCountColor(String phoneNumber) {
    final rawDigits = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    final digitCount = rawDigits.length;
    
    if (digitCount == 0) return AppColors.textSecondary;
    if (digitCount == AppConstants.kPhoneNumberLength) return AppColors.success;
    return AppColors.error;
  }

  String _getCompletePhoneNumber(String phoneNumber) {
    final countryCode = AppConstants.kCountryCodes[_selectedCountryCode] ?? '+91';
    return '$countryCode$phoneNumber';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        // Trigger validation animation when valid
        if (state.phoneInput.isValid) {
          _validationController.forward();
        } else {
          _validationController.reverse();
        }

        return AnimatedBuilder(
          animation: _borderColorAnimation,
          child: _buildPhoneField(state),
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.kBorderRadius),
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: state.phoneInput.isValid 
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.textTertiary.withOpacity(0.03),
                    blurRadius: state.phoneInput.isValid ? 12 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: child,
            );
          },
        );
      },
    );
  }

  Widget _buildPhoneField(LoginState state) {
    final currentPhoneValue = state.phoneInput.value;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Enhanced Country code container with dropdown - Reduced width
        Container(
          height: AppConstants.kFieldHeight,
          padding: const EdgeInsets.symmetric(horizontal: 12), // Reduced from 16 to 12
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.kBorderRadius),
            border: Border.all(
              color: AppColors.border,
              width: 1.5,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCountryCode,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCountryCode = newValue;
                  });
                }
              },
              items: AppConstants.kCountryCodes.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 20, // Reduced from 24 to 20
                        height: 14, // Reduced from 16 to 14
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Center(
                          child: Text(
                            AppConstants.kCountryFlags[entry.key] ?? '🌍',
                            style: const TextStyle(fontSize: 10), // Reduced from 12 to 10
                          ),
                        ),
                      ),
                      const SizedBox(width: 6), // Reduced from 8 to 6
                      Text(
                        entry.value,
                        style: const TextStyle(
                          fontSize: AppConstants.kInputTextSize,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              dropdownColor: AppColors.surface,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
                size: AppConstants.kIconSize,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppConstants.kPaddingMedium),
        // Enhanced Phone number input
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'Mobile Number',
              labelStyle: TextStyle(
                color: state.phoneInput.isValid 
                    ? AppColors.success 
                    : AppColors.textSecondary,
                fontSize: AppConstants.kBodyTextSize,
                fontWeight: FontWeight.w600,
              ),
              hintText: 'Enter ${AppConstants.kPhoneNumberLength}-digit number',
              hintStyle: TextStyle(
                color: AppColors.textTertiary.withOpacity(0.7),
                fontSize: AppConstants.kBodyTextSize,
                fontWeight: FontWeight.w400,
              ),
              errorText: state.phoneInput.displayError != null 
                  ? _getFormattedErrorText(state.phoneInput.displayError!) 
                  : null,
              errorStyle: const TextStyle(
                color: AppColors.error,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              // Add digit count as suffix using BLoC state
              suffixText: _getDigitCountText(currentPhoneValue),
              suffixStyle: TextStyle(
                color: _getDigitCountColor(currentPhoneValue),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              // Success indicator icon next to digit count
              suffixIcon: state.phoneInput.isValid
                  ? Container(
                      margin: const EdgeInsets.all(AppConstants.kPaddingMedium),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(AppConstants.kPaddingMedium),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.kBorderRadius),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.kBorderRadius),
                borderSide: BorderSide(
                  color: state.phoneInput.isValid 
                      ? AppColors.success.withOpacity(0.5)
                      : AppColors.border,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.kBorderRadius),
                borderSide: BorderSide(
                  color: state.phoneInput.isValid 
                      ? AppColors.success 
                      : AppColors.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.kBorderRadius),
                borderSide: const BorderSide(
                  color: AppColors.error,
                  width: 2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.kBorderRadius),
                borderSide: const BorderSide(
                  color: AppColors.error,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.kPaddingLarge,
                vertical: AppConstants.kBorderRadius,
              ),
            ),
            onChanged: (value) {
              // Haptic feedback for better UX
              if (value.length == AppConstants.kPhoneNumberLength) {
                HapticFeedback.lightImpact();
              }
              context.read<LoginBloc>().add(ChangePhone(value));
            },
            style: const TextStyle(
              fontSize: AppConstants.kInputTextSize,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: 0.5,
            ),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            autofocus: false,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(AppConstants.kPhoneNumberLength),
            ],
            maxLength: AppConstants.kPhoneNumberLength,
            buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
              return null; // Hide the counter as we have custom suffix
            },
          ),
        ),
      ],
    );
  }

  String _getFormattedErrorText(String error) {
    final countryCode = AppConstants.kCountryCodes[_selectedCountryCode] ?? '+91';
    switch (error) {
      case 'empty':
        return 'Mobile number is required';
      case 'invalid':
        return 'Please enter a valid ${AppConstants.kPhoneNumberLength}-digit number';
      case 'incomplete':
        return 'Number should be ${AppConstants.kPhoneNumberLength} digits ($countryCode XXXXXXXXXX)';
      default:
        return error;
    }
  }
}
