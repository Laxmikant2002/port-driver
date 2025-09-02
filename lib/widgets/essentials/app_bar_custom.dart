import 'package:flutter/material.dart';

class AppBarCustom extends StatelessWidget implements PreferredSizeWidget {
  const AppBarCustom({
    super.key,
    this.backButton = false,
    this.title,
    this.titleColor = Colors.white, // Default title color
  });

  final bool backButton;
  final String? title;
  final Color titleColor; // New parameter for dynamic title color

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: backButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context); // Go back to the previous screen
              },
            )
          : null,
      title: title != null
          ? Text(
              title!,
              style: TextStyle(
                  color: titleColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,), // Apply dynamic color
            )
          : null,
      centerTitle: true, // Center the title
    );
  }

  // Implement preferredSize to specify the height of the AppBar
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
