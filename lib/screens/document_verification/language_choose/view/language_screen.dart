import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../widgets/colors.dart';
import '../bloc/language_bloc.dart';
import '../bloc/language_state.dart';
import '../bloc/language_event.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LanguageBloc(),
      child: const LanguageView(),
    );
  }
}

class LanguageView extends StatelessWidget {
  const LanguageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<LanguageBloc, LanguageState>(
        listener: (context, state) {
          if (state.status == LanguageStatus.success) {
            // Navigate to vehicle selection screen
            Navigator.of(context).pushReplacementNamed('/vehicle-selection');
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.08),
                AppColors.background,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _Logo(),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: _LanguageCard(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'logo',
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select your language',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'You can change your language on this screen or anytime in Help.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _LanguageDropdown(),
              const SizedBox(height: 24),
              _LanguageRadioOptions(),
              const SizedBox(height: 32),
              _ContinueButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      buildWhen: (prev, curr) => prev.dropdown != curr.dropdown,
      builder: (context, state) {
        return DropdownButtonFormField<String>(
          value: state.dropdown.value,
          decoration: InputDecoration(
            labelText: 'Language',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: AppColors.background.withOpacity(0.08),
          ),
          items: const [
            DropdownMenuItem(value: 'English (English)', child: Text('English (English)')),
            DropdownMenuItem(value: 'Hindi (हिंदी)', child: Text('Hindi (हिंदी)')),
            DropdownMenuItem(value: 'Marathi (मराठी)', child: Text('Marathi (मराठी)')),
          ],
          onChanged: (value) {
            if (value != null) {
              context.read<LanguageBloc>().add(LanguageDropdownChanged(value));
            }
          },
        );
      },
    );
  }
}

class _LanguageRadioOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      buildWhen: (prev, curr) => prev.radio != curr.radio,
      builder: (context, state) {
        return Column(
          children: [
            _LanguageRadioTile('English', 'English', state.radio.value),
            _LanguageRadioTile('Hindi', 'हिंदी', state.radio.value),
            _LanguageRadioTile('Marathi', 'मराठी', state.radio.value),
          ],
        );
      },
    );
  }
}

class _LanguageRadioTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String groupValue;
  const _LanguageRadioTile(this.title, this.subtitle, this.groupValue);

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      value: title,
      groupValue: groupValue,
      onChanged: (value) {
        if (value != null) {
          context.read<LanguageBloc>().add(LanguageRadioChanged(value));
        }
      },
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      activeColor: AppColors.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      buildWhen: (prev, curr) => prev.isValid != curr.isValid || prev.status != curr.status,
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: state.isValid
                ? () => context.read<LanguageBloc>().add(const LanguageSubmitted())
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: state.isValid ? AppColors.primary : AppColors.primary.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: state.status == LanguageStatus.loading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
