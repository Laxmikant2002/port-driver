import 'package:flutter/material.dart';
import 'package:driver/widgets/colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextInputType inputType;
  final bool obscureText; // Added obscureText parameter
  final Widget? prefixIcon;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? errorStyle;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.inputType,
    this.obscureText = false, // Initialize obscureText
    this.prefixIcon,
    required this.onChanged,
    this.errorText,
    this.textStyle,
    this.labelStyle,
    this.hintStyle,
    this.errorStyle,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText, // Use obscureText for password masking
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon,
        errorText: errorText,
        labelStyle: labelStyle,
        hintStyle: hintStyle,
        errorStyle: errorStyle,
      ),
      keyboardType: inputType,
      onChanged: onChanged,
      style: textStyle,
    );
  }
}
