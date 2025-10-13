import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:driver/app/bloc/cubit/locale.dart';

class LocaleSelector extends StatefulWidget {
  const LocaleSelector({super.key});

  @override
  State<LocaleSelector> createState() => _LocaleSelectorState();
}

class _LocaleSelectorState extends State<LocaleSelector> {
  final List<Map<String, String>> languageOptions = [
    {'displayName': 'English', 'value': 'en'},
    {'displayName': 'हिंदी', 'value': 'hi'},
    {'displayName': 'मराठी', 'value': 'mr'},
  ];

  String? selectedLanguage;

  @override
  void initState() {
    super.initState();
    // Get the initial locale from LocaleCubit and set the selected language
    final locale = context.read<LocaleCubit>().state;
    selectedLanguage = locale.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedLanguage,
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Colors.blueAccent,
                size: 18,
              ),
              style: const TextStyle(color: Colors.black87, fontSize: 14),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(8),
              onChanged: (newValue) {
                setState(() {
                  selectedLanguage = newValue;
                });
                context.read<LocaleCubit>().selectLocale(newValue!);
              },
              items: languageOptions.map((language) {
                return DropdownMenuItem<String>(
                  value: language['value'],
                  child: Row(
                    children: [
                      const Icon(
                        Icons.language,
                        size: 18,
                        color: Color.fromRGBO(32, 110, 243, 1),
                      ),
                      const SizedBox(width: 4),
                      Text(language['displayName']!),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
