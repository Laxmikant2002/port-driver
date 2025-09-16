import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../models/work_location.dart';
import '../bloc/work_bloc.dart';

/// {@template work_location_page}
/// A page that displays the work location selection screen.
/// {@endtemplate}
class WorkLocationPage extends StatelessWidget {
  /// {@macro work_location_page}
  const WorkLocationPage({super.key});

  /// The route name for the work location page.
  static const String routeName = '/work-location';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WorkBloc()..add(const WorkLocationLoaded()),
      child: const WorkLocationView(),
    );
  }
}

/// {@template work_location_view}
/// The view for the work location selection screen.
/// {@endtemplate}
class WorkLocationView extends StatelessWidget {
  /// {@macro work_location_view}
  const WorkLocationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<WorkBloc, WorkState>(
        listener: (context, state) {
          if (state.status == FormzSubmissionStatus.success) {
            Navigator.pushReplacementNamed(context, '/docs-verification');
          } else if (state.status == FormzSubmissionStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Something went wrong'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF6366F1),
                Color(0xFF8B5CF6),
                Color(0xFFA855F7),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        _buildHeader(),
                        const SizedBox(height: 48),
                        _buildFormCard(),
                      ],
                    ),
                  ),
                ),
                _buildBottomSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.attach_money_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Earn with',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Decide when, where, and how you want to earn.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationDropdown(),
            const SizedBox(height: 24),
            _buildReferralCodeField(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDropdown() {
    return BlocBuilder<WorkBloc, WorkState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Where would you like to earn?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: state.workLocationInput.displayError != null
                      ? Colors.red
                      : Colors.transparent,
                ),
              ),
              child: DropdownButtonFormField<WorkLocation>(
                value: state.selectedLocation,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: InputBorder.none,
                  hintText: 'Select your city',
                  hintStyle: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 16,
                  ),
                ),
                items: state.locations.map((location) {
                  return DropdownMenuItem<WorkLocation>(
                    value: location,
                    child: Text(
                      location.name,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (location) {
                  if (location != null) {
                    context.read<WorkBloc>().add(
                          WorkLocationSelected(location),
                        );
                  }
                },
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF6B7280),
                ),
                dropdownColor: Colors.white,
                style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 16,
                ),
              ),
            ),
            if (state.workLocationInput.displayError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Text(
                  state.workLocationInput.displayError!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildReferralCodeField() {
    return BlocBuilder<WorkBloc, WorkState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Referral code (optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: state.referralCode.displayError != null
                      ? Colors.red
                      : Colors.transparent,
                ),
              ),
              child: TextFormField(
                onChanged: (value) {
                  context.read<WorkBloc>().add(ReferralCodeChanged(value));
                },
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: InputBorder.none,
                  hintText: 'Enter referral code',
                  hintStyle: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 16,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
            if (state.referralCode.displayError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Text(
                  state.referralCode.displayError == ReferralCodeValidationError.invalid
                      ? 'Please enter a valid referral code'
                      : 'Invalid referral code',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildTermsText(),
          const SizedBox(height: 24),
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildTermsText() {
    return const Text(
      'By proceeding, I agree that Uber or its representatives may contact me by email, phone, or SMS (including by automatic telephone dialing system) at the email address or number I provide, including for marketing purposes.',
      style: TextStyle(
        fontSize: 12,
        color: Colors.white70,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildNextButton() {
    return BlocBuilder<WorkBloc, WorkState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: state.isValid && state.status != FormzSubmissionStatus.inProgress
                ? () {
                    context.read<WorkBloc>().add(const WorkFormSubmitted());
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF6366F1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              disabledBackgroundColor: Colors.white.withOpacity(0.5),
              disabledForegroundColor: const Color(0xFF6366F1).withOpacity(0.5),
            ),
            child: state.status == FormzSubmissionStatus.inProgress
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF6366F1),
                      ),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 20,
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
