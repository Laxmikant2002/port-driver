import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../widgets/colors.dart';
import '../bloc/settings_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc()..add(const SettingsLoaded()),
      child: const SettingsView(),
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state.hasError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'An error occurred'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const _HeaderSection(),
                const SizedBox(height: 24),
                const _SettingsList(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.cyan.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          // Settings Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.settings_rounded,
              size: 32,
              color: AppColors.cyan,
            ),
          ),
          const SizedBox(height: 16),
          // Header Text
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your app preferences and account settings',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SettingsList extends StatelessWidget {
  const _SettingsList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 32,
                offset: const Offset(0, 12),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: AppColors.border.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSettingsItem(
                icon: Icons.language_rounded,
                title: 'App Language',
                subtitle: state.language,
                onTap: () {
                  Navigator.pushNamed(context, '/language');
                },
              ),
              const _Divider(),
              _buildSettingsItem(
                icon: Icons.notifications_rounded,
                title: 'Notifications',
                subtitle: 'Manage notification preferences',
                onTap: () {
                  Navigator.pushNamed(context, '/notifications');
                },
              ),
              const _Divider(),
              _buildSettingsItem(
                icon: Icons.shield_rounded,
                title: 'Privacy',
                subtitle: 'Control your privacy settings',
                onTap: () {
                  Navigator.pushNamed(context, '/privacy');
                },
              ),
              const _Divider(),
              _buildSettingsItem(
                icon: Icons.support_agent_rounded,
                title: 'Support',
                subtitle: 'Get help and contact support',
                onTap: () {
                  Navigator.pushNamed(context, '/support');
                },
              ),
              const _Divider(),
              _buildSettingsItem(
                icon: Icons.help_outline_rounded,
                title: 'FAQ',
                subtitle: 'Frequently asked questions',
                onTap: () {
                  Navigator.pushNamed(context, '/faq');
                },
              ),
              const _Divider(),
              _buildSettingsItem(
                icon: Icons.info_outline_rounded,
                title: 'About',
                subtitle: 'App version and information',
                onTap: () {
                  Navigator.pushNamed(context, '/about');
                },
              ),
              const _Divider(),
              _buildSettingsItem(
                icon: Icons.delete_outline_rounded,
                title: 'Delete Account',
                subtitle: 'Permanently delete your account',
                titleColor: AppColors.error,
                iconColor: AppColors.error,
                onTap: () => _showDeleteAccountConfirmation(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? titleColor,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.cyan).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.cyan,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteAccountConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete Account',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
          style: TextStyle(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'CANCEL',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'DELETE',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<SettingsBloc>().add(const AccountDeletionRequested());
    }
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: AppColors.border,
    );
  }
}