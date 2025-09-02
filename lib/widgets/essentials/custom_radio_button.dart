import 'package:flutter/material.dart';

class CustomRadioButton extends StatelessWidget {
  const CustomRadioButton({
    required this.value,
    required this.selectedLanguage,
    required this.changeSelectedValue,
    super.key,
  });

  final String value;
  final String selectedLanguage;
  final ValueChanged<String?> changeSelectedValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: RadioListTile<String>(
        value: value,
        groupValue: selectedLanguage,
        onChanged: changeSelectedValue, 
        title: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        activeColor: Colors.black,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            color: Color.fromARGB(255, 209, 209, 209),
          ),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
