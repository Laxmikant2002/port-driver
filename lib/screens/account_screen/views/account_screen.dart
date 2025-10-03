import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:driver/routes/account_routes.dart';
import 'package:driver/screens/account_screen/bloc/account_bloc.dart';
import 'package:driver/widgets/colors.dart';
import 'package:image_picker/image_picker.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  static List<Map<String, dynamic>> getButtonsData(bool isDocumentVerified) {
    return [
      {'text': "Profile", 'icon': Icons.person_outline, 'route': AccountRoutes.profile},
      {'text': "Earnings & Rewards", 'icon': Icons.account_balance_wallet, 'route': AccountRoutes.unifiedEarningsRewards},
      {'text': "Activity", 'icon': Icons.history_rounded, 'route': AccountRoutes.tripHistory},
      {'text': 'Ratings', 'icon': Icons.star_outline, 'route': AccountRoutes.ratings},
      {
        'text': 'Documents', 
        'icon': Icons.file_present, 
        'route': isDocumentVerified ? AccountRoutes.accountDocuments : AccountRoutes.documentIntro
      },
      {'text': "Settings", 'icon': Icons.settings, 'route': AccountRoutes.settings},
      {'text': "Help", 'icon': Icons.help_outline, 'route': AccountRoutes.helpSupport},
      
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AccountBloc()..add(const LoadAccountData()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.background,
          title: Text(
            'Account',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontSize: 20,
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                Icons.notifications_none, 
                color: AppColors.textSecondary,
                size: 24,
              ),
              onPressed: () {
                Navigator.pushNamed(context, AccountRoutes.notificationSettings);
              },
            ),
          ],
        ),
        body: BlocConsumer<AccountBloc, AccountState>(
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
            } else if (state.isSuccess && state.name.value.isEmpty) {
              // This indicates logout was successful
              Navigator.of(context).pushReplacementNamed('/login');
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.isLoaded) {
              return _buildAccountContent(context, state);
            }
            return const Center(child: Text('Something went wrong'));
          },
        ),
      ),
    );
  }

  Widget _buildAccountContent(BuildContext context, AccountState state) {
    final buttonsData = getButtonsData(state.isDocumentVerified);
    
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header Section - Profile screen style
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.cyan.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Column(
              children: [
                // Profile Icon - Styled like profile screen
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    size: 32,
                    color: AppColors.cyan,
                  ),
                ),
                const SizedBox(height: 16),
                // Title - Styled like profile screen
                Text(
                  state.name.value.isNotEmpty ? state.name.value : 'Your Account',
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
                  state.vehicle.value.isNotEmpty 
                      ? '${state.vehicle.value} • Driver' 
                      : 'Manage your profile and settings',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Profile Photo - Styled like profile screen
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.backgroundSecondary,
                          border: Border.all(
                            color: AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: state.profileImage.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(48),
                                child: Image.network(
                                  state.profileImage,
                                  width: 96,
                                  height: 96,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.camera_alt_outlined,
                                      size: 40,
                                      color: AppColors.textTertiary,
                                    );
                                  },
                                ),
                              )
                            : Icon(
                                Icons.camera_alt_outlined,
                                size: 40,
                                color: AppColors.textTertiary,
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _handleProfileImageUpdate(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.cyan,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.surface,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tap camera to update photo',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Content Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // Edit Profile Button - Styled like profile screen continue button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.cyan, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cyan.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, AccountRoutes.profile),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.edit_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Menu Items Card - Profile screen style
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: buttonsData.asMap().entries.map((entry) {
                      final index = entry.key;
                      final button = entry.value;
                      final isLast = index == buttonsData.length - 1;
                      
                      return Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.cyan.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                button['icon'] as IconData,
                                color: AppColors.cyan,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              button['text'] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                letterSpacing: -0.2,
                              ),
                            ),
                            trailing: Icon(
                              Icons.chevron_right,
                              color: AppColors.textTertiary,
                              size: 20,
                            ),
                            onTap: () => Navigator.pushNamed(
                              context,
                              button['route'] as String,
                            ),
                          ),
                          if (!isLast)
                            Divider(
                              height: 1,
                              color: AppColors.border.withValues(alpha: 0.3),
                              indent: 70,
                              endIndent: 24,
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                _buildLogoutButton(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildLogoutButton(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.error.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: ElevatedButton(
            onPressed: state.isSubmitting
                ? null
                : () {
                    context.read<AccountBloc>().add(const LogoutRequested());
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: state.isSubmitting
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.error),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Logging out...',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_outlined),
                      SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Future<void> _handleProfileImageUpdate(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null && context.mounted) {
      context.read<AccountBloc>().add(UpdateProfileImage(image.path));
    }
  }
}

