import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../bloc/login_bloc.dart';
import '../../../../widgets/colors.dart';

class PhoneField extends StatefulWidget {
  const PhoneField({super.key});

  @override
  State<PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<PhoneField>
    with SingleTickerProviderStateMixin {
  late AnimationController _validationController;
  late Animation<Color?> _borderColorAnimation;
  String _currentPhoneNumber = '';
  
  @override
  void initState() {
    super.initState();
    _validationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _borderColorAnimation = ColorTween(
      begin: AppColors.border,
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

  String _getDigitCountText() {
    // Remove country code and formatting to get raw digits
    final rawDigits = _currentPhoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    final digitCount = rawDigits.length;
    
    return '$digitCount/10';
  }

  Color _getDigitCountColor() {
    final rawDigits = _currentPhoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    final digitCount = rawDigits.length;
    
    if (digitCount == 0) return AppColors.textSecondary;
    if (digitCount == 10) return AppColors.success;
    return AppColors.error;
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
                borderRadius: BorderRadius.circular(18),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: state.phoneInput.isValid 
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.border.withOpacity(0.5),
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
    return IntlPhoneField(
      decoration: InputDecoration(
        labelText: 'Mobile Number',
        labelStyle: TextStyle(
          color: state.phoneInput.isValid 
              ? AppColors.success 
              : AppColors.textSecondary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        hintText: 'Enter your mobile number',
        hintStyle: TextStyle(
          color: AppColors.textTertiary.withOpacity(0.7),
          fontSize: 16,
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
        // Add digit count as suffix
        suffixText: _getDigitCountText(),
        suffixStyle: TextStyle(
          color: _getDigitCountColor(),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        // Success indicator icon next to digit count
        suffixIcon: state.phoneInput.isValid
            ? Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: state.phoneInput.isValid 
                ? AppColors.success.withOpacity(0.5)
                : AppColors.border,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: state.phoneInput.isValid 
                ? AppColors.success 
                : AppColors.cyan,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      initialCountryCode: 'IN', // Default to India (+91)
      onChanged: (phone) {
        // Update local state for digit count
        setState(() {
          _currentPhoneNumber = phone.number;
        });
        // Haptic feedback for better UX
        if (phone.number.length == 10) {
          HapticFeedback.lightImpact();
        }
        context.read<LoginBloc>().add(PhoneChanged(phone.number));
      },
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.5,
      ),
      flagsButtonPadding: const EdgeInsets.only(left: 20),
      dropdownIconPosition: IconPosition.trailing,
      dropdownIcon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.textSecondary,
        size: 24,
      ),
      showCountryFlag: true,
      showDropdownIcon: true,
      // Accessibility improvements
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      autofocus: false,
    );
  }

  String _getFormattedErrorText(String error) {
    switch (error) {
      case 'empty':
        return 'Mobile number is required';
      case 'invalid':
        return 'Please enter a valid 10-digit number';
      default:
        return error;
    }
  }
}
