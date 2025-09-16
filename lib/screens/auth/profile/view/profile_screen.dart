import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../widgets/colors.dart';

import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';
import '../bloc/profile_event.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final phone = ModalRoute.of(context)!.settings.arguments as String;

    return BlocProvider(
      create: (_) => ProfileBloc(phone: phone),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.success) {
            // Navigate to home or dashboard
            Navigator.of(context).pushReplacementNamed('/home');
          } else if (state.status == ProfileStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Profile setup failed'),
                  backgroundColor: Colors.red,
                ),
              );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.background,
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  const _WelcomeText(),
                  const SizedBox(height: 40),
                  const _ProfileForm(),
                  const SizedBox(height: 32),
                  const _SubmitButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Logo widget removed as requested

class _WelcomeText extends StatelessWidget {
  const _WelcomeText();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Complete Your Profile',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Please fill in your details to complete the registration',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ProfileForm extends StatelessWidget {
  const _ProfileForm();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: AppColors.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const _FirstNameField(),
            const SizedBox(height: 20),
            const _LastNameField(),
            const SizedBox(height: 20),
            const _EmailField(),
            const SizedBox(height: 20),
            const _PhoneField(),
            const SizedBox(height: 20),
            const _AlternativePhoneField(),
          ],
        ),
      ),
    );
  }
}

class _FirstNameField extends StatelessWidget {
  const _FirstNameField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (previous, current) => previous.firstName != current.firstName,
      builder: (context, state) {
        return TextFormField(
          onChanged: (firstName) => context
              .read<ProfileBloc>()
              .add(ProfileFirstNameChanged(firstName)),
          decoration: InputDecoration(
            labelText: 'First Name *',
            prefixIcon: Icon(
              Icons.person,
              color: AppColors.primary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorText: state.firstName.displayError != null
                ? 'First name is required'
                : null,
          ),
        );
      },
    );
  }
}

class _LastNameField extends StatelessWidget {
  const _LastNameField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (previous, current) => previous.lastName != current.lastName,
      builder: (context, state) {
        return TextFormField(
          onChanged: (lastName) => context
              .read<ProfileBloc>()
              .add(ProfileLastNameChanged(lastName)),
          decoration: InputDecoration(
            labelText: 'Last Name *',
            prefixIcon: Icon(
              Icons.person_outline,
              color: AppColors.primary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorText: state.lastName.displayError != null
                ? 'Last name is required'
                : null,
          ),
        );
      },
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return TextFormField(
          onChanged: (email) =>
              context.read<ProfileBloc>().add(ProfileEmailChanged(email)),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email (Optional)',
            prefixIcon: Icon(
              Icons.email,
              color: AppColors.primary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorText: state.email.displayError != null
                ? 'Enter a valid email address'
                : null,
          ),
        );
      },
    );
  }
}

class _PhoneField extends StatelessWidget {
  const _PhoneField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        return TextFormField(
          initialValue: state.phone,
          enabled: false,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            prefixIcon: Icon(
              Icons.phone,
              color: AppColors.primary.withOpacity(0.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary.withOpacity(0.3),
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary.withOpacity(0.2),
              ),
            ),
            filled: true,
            fillColor: AppColors.primary.withOpacity(0.05),
          ),
        );
      },
    );
  }
}

class _AlternativePhoneField extends StatelessWidget {
  const _AlternativePhoneField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (previous, current) =>
          previous.alternativePhone != current.alternativePhone,
      builder: (context, state) {
        return TextFormField(
          onChanged: (alternativePhone) => context
              .read<ProfileBloc>()
              .add(ProfileAlternativePhoneChanged(alternativePhone)),
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Alternative Phone (Optional)',
            prefixIcon: Icon(
              Icons.phone_android,
              color: AppColors.primary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorText: state.alternativePhone.displayError != null
                ? 'Enter a valid phone number'
                : null,
          ),
        );
      },
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.isValid != current.isValid,
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: state.isValid
                ? () => context.read<ProfileBloc>().add(const ProfileSubmitted())
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ).copyWith(
              backgroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.disabled)) {
                  return AppColors.primary.withOpacity(0.3);
                }
                return null;
              }),
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: state.isValid
                    ? LinearGradient(
                        colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                      )
                    : null,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                alignment: Alignment.center,
                child: state.status == ProfileStatus.loading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Complete Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
