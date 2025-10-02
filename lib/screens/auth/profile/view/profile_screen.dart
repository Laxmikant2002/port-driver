import 'package:flutter/material.dart';

import 'package:auth_repo/auth_repo.dart';
import 'package:driver/locator.dart';
import 'package:driver/widgets/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:profile_repo/profile_repo.dart';

import '../bloc/profile_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final user = args['user'] as AuthUser;
    final isNewUser = args['isNewUser'] as bool? ?? true;
    final existingProfile = args['profile'] as DriverProfile?;

    return BlocProvider(
      create: (context) => ProfileBloc(
        authRepo: lc<AuthRepo>(),
        profileRepo: lc<ProfileRepo>(),
        user: user,
        existingProfile: existingProfile,
        isNewUser: isNewUser,
      )..add(const ProfileInitialized()),
      child: const _ProfileScreen(),
    );
  }
}

class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.isSuccess && state.routeDecision != null) {
            // Navigate to next step
            Navigator.pushReplacementNamed(
              context,
              state.routeDecision!.route,
              arguments: state.routeDecision!.arguments,
            );
          } else if (state.hasError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
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
                const _ProfileForm(),
                const SizedBox(height: 24),
                const _ContinueButton(),
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
          // Profile Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.person_add_rounded,
              size: 32,
              color: AppColors.cyan,
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            'Complete Your Profile',
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
            'Tell us about yourself to get started',
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

class _ProfileForm extends StatelessWidget {
  const _ProfileForm();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
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
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Photo Section
          const _ProfilePhotoSection(),
          const SizedBox(height: 24),
          
          // Name Input
          const _NameField(),
          const SizedBox(height: 16),
          
          // Date of Birth
          const _DateOfBirthField(),
          const SizedBox(height: 16),
          
          // Gender Selection
          const _GenderField(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ProfilePhotoSection extends StatelessWidget {
  const _ProfilePhotoSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        return Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _showPhotoOptions(context),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: state.profilePhoto != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(48),
                          child: Image.network(
                            state.profilePhoto!,
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.camera_alt_outlined,
                          size: 40,
                          color: AppColors.textTertiary,
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Add Profile Photo',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Add Profile Photo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            // TODO: Implement camera functionality
                          },
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Camera'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: AppColors.surface,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            // TODO: Implement gallery functionality
                          },
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Gallery'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.info,
                            foregroundColor: AppColors.surface,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        return TextFormField(
          initialValue: state.nameInput.value,
          onChanged: (value) => context.read<ProfileBloc>().add(ProfileNameChanged(value)),
          decoration: InputDecoration(
            labelText: 'Full Name',
            hintText: 'Enter your full name',
            errorText: state.nameInput.displayError,
            prefixIcon: Icon(
              Icons.person_outline,
              color: AppColors.textTertiary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.cyan, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error),
            ),
          ),
        );
      },
    );
  }
}

class _DateOfBirthField extends StatelessWidget {
  const _DateOfBirthField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        return InkWell(
          onTap: () => _selectDateOfBirth(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    state.dateOfBirth != null
                        ? '${state.dateOfBirth!.day}/${state.dateOfBirth!.month}/${state.dateOfBirth!.year}'
                        : 'Select Date of Birth',
                    style: TextStyle(
                      fontSize: 16,
                      color: state.dateOfBirth != null
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 80);
    final lastDate = DateTime(now.year - 18);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: lastDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.cyan,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      context.read<ProfileBloc>().add(ProfileDateOfBirthChanged(selectedDate));
    }
  }
}

class _GenderField extends StatelessWidget {
  const _GenderField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gender',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _GenderOption(
                    label: 'Male',
                    value: 'male',
                    isSelected: state.gender == 'male',
                    onTap: () => context.read<ProfileBloc>().add(const ProfileGenderChanged('male')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GenderOption(
                    label: 'Female',
                    value: 'female',
                    isSelected: state.gender == 'female',
                    onTap: () => context.read<ProfileBloc>().add(const ProfileGenderChanged('female')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GenderOption(
                    label: 'Other',
                    value: 'other',
                    isSelected: state.gender == 'other',
                    onTap: () => context.read<ProfileBloc>().add(const ProfileGenderChanged('other')),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cyan.withOpacity(0.1) : AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.cyan : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.cyan : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final isValid = state.isValid;
        final isLoading = state.isSubmitting;
        
        return Container(
          width: double.infinity,
          height: 56,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            gradient: isValid && !isLoading
                ? LinearGradient(
                    colors: [AppColors.cyan, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isValid && !isLoading
                ? [
                    BoxShadow(
                      color: AppColors.cyan.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: ElevatedButton(
            onPressed: isValid && !isLoading
                ? () => context.read<ProfileBloc>().add(const ProfileSubmitted())
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isValid && !isLoading
                  ? Colors.transparent
                  : AppColors.border,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Saving Profile...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 20,
                        color: isValid ? Colors.white : AppColors.textTertiary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isValid ? Colors.white : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}