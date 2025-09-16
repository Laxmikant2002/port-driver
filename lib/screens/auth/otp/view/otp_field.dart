import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';
import '../../../../widgets/colors.dart';
import '../bloc/otp_bloc.dart';

class OtpField extends StatelessWidget {
  const OtpField({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OtpBloc, OtpState>(
      builder: (context, state) {
        return Pinput(
          length: 4,
          onChanged: (value) {
            context.read<OtpBloc>().add(ChangeOtp(value));
          },
          defaultPinTheme: PinTheme(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            textStyle: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          focusedPinTheme: PinTheme(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            textStyle: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          errorPinTheme: PinTheme(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.errorBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error, width: 2),
            ),
            textStyle: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          errorText: state.otpInput.error != null
              ? state.otpInput.errorMessage
              : null,
          errorTextStyle: const TextStyle(
            color: AppColors.error,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autofocus: true,
        );
      },
    );
  }
}