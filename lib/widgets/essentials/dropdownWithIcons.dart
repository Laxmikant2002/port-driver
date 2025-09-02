import 'package:flutter/material.dart';

class DropdownWithIcons extends StatefulWidget {
  const DropdownWithIcons({super.key});

  @override
  _DropdownWithIconsState createState() => _DropdownWithIconsState();
}

class _DropdownWithIconsState extends State<DropdownWithIcons> {
  String dropdownValue = 'Anyone'; // Initial value for the dropdown

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(), // Black border
        borderRadius: BorderRadius.circular(8), // Rounded corners
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 3,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: dropdownValue,
            items: const [
              DropdownMenuItem(
                value: 'Anyone',
                child: Row(
                  children: [
                    Icon(Icons.public, size: 14, color: Colors.black),
                    SizedBox(width: 8),
                    Text('Anyone', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'Connections',
                child: Row(
                  children: [
                    Icon(Icons.lock, size: 14, color: Colors.black),
                    SizedBox(width: 8),
                    Text('Connections', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ],
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  dropdownValue = newValue; // Update the dropdown value
                });
              }
            },
            icon: const Icon(Icons.arrow_drop_down), // Dropdown arrow icon
            isDense: true, // Reduces vertical padding
            style: const TextStyle(color: Colors.black, fontSize: 14),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
