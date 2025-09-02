import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:driver/screens/account/settings/bloc/settings_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc()..add(LoadSettings()),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Settings',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: BlocConsumer<SettingsBloc, SettingsState>(
          listener: (context, state) {
            if (state is SettingsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is AccountDeleted) {
              Navigator.of(context).pushReplacementNamed('/login');
            }
          },
          builder: (context, state) {
            if (state is SettingsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is SettingsLoaded) {
              return _buildSettingsList(context, state);
            }
            return const Center(child: Text('Something went wrong'));
          },
        ),
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context, SettingsLoaded state) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const SizedBox(height: 16),
        _buildSettingsItem(
          icon: Icons.language,
          iconColor: Colors.black,
          title: 'App Language',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.currentLanguage,
                style: const TextStyle(color: Colors.grey),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
          onTap: () {
            Navigator.pushNamed(context, '/language');
          },
        ),
        const SizedBox(height: 16),
        _buildSettingsItem(
          icon: Icons.notifications_outlined,
          iconColor: Colors.black,
          title: 'Notifications',
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () {
            Navigator.pushNamed(context, '/notifications');
          },
        ),
        const SizedBox(height: 16),
        _buildSettingsItem(
          icon: Icons.shield_outlined,
          iconColor: Colors.black,
          title: 'Privacy',
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () {
            Navigator.pushNamed(context, '/privacy');
          },
        ),
        const SizedBox(height: 16),
        _buildSettingsItem(
          icon: Icons.support_outlined,
          iconColor: Colors.black,
          title: 'Support',
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () {
            Navigator.pushNamed(context, '/support');
          },
        ),
        const SizedBox(height: 16),
        _buildSettingsItem(
          icon: Icons.help_outline,
          iconColor: Colors.black,
          title: 'FAQ',
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () {
            Navigator.pushNamed(context, '/faq');
          },
        ),
        const SizedBox(height: 16),
        _buildSettingsItem(
          icon: Icons.info_outline,
          iconColor: Colors.black,
          title: 'About',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Version ${state.appVersion}',
                style: const TextStyle(color: Colors.grey),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
          onTap: () {
            Navigator.pushNamed(context, '/about');
          },
        ),
        const SizedBox(height: 16),
        _buildSettingsItem(
          icon: Icons.delete_outline,
          iconColor: Colors.red,
          title: 'Delete Account',
          titleColor: Colors.red,
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () => _showDeleteAccountConfirmation(context),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    Color? titleColor,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: titleColor ?? Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  Future<void> _showDeleteAccountConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Delete Account',
          style: TextStyle(color: Colors.black),
        ),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'DELETE',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<SettingsBloc>().add(DeleteAccountRequested());
    }
  }
}