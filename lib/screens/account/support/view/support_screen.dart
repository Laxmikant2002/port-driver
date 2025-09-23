import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../widgets/colors.dart';
import '../bloc/support_bloc.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SupportBloc()..add(const SupportLoaded()),
      child: const SupportView(),
    );
  }
}

class SupportView extends StatelessWidget {
  const SupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<SupportBloc, SupportState>(
        listener: (context, state) {
          if (state.isSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: const Text('Support ticket submitted successfully'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            Navigator.of(context).pop();
          } else if (state.hasError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Failed to submit support ticket'),
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
                const _SupportForm(),
                const SizedBox(height: 32),
                const _SubmitButton(),
                const SizedBox(height: 24),
                const _ContactInfoSection(),
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
          // Support Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.support_agent_rounded,
              size: 32,
              color: AppColors.cyan,
            ),
          ),
          const SizedBox(height: 16),
          // Header Text
          Text(
            'Contact Support',
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
            'We\'re here to help! Send us your questions or issues',
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

class _SupportForm extends StatelessWidget {
  const _SupportForm();

  @override
  Widget build(BuildContext context) {
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
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.message_rounded,
                    color: AppColors.cyan,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Support Request',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        'Fill in the details below',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Form Fields
            const _SubjectField(),
            const SizedBox(height: 24),
            const _PriorityField(),
            const SizedBox(height: 24),
            const _MessageField(),
            const SizedBox(height: 24),
            const _AttachmentSection(),
          ],
        ),
      ),
    );
  }
}

class _SubjectField extends StatelessWidget {
  const _SubjectField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SupportBloc, SupportState>(
      buildWhen: (previous, current) => previous.subject != current.subject,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subject',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              onChanged: (subject) => context
                  .read<SupportBloc>()
                  .add(SupportSubjectChanged(subject)),
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Brief description of your issue',
                hintStyle: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 16,
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.title,
                    color: AppColors.cyan,
                    size: 20,
                  ),
                ),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.cyan,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.error,
                    width: 1,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.error,
                    width: 2,
                  ),
                ),
                errorText: state.subject.displayError != null
                    ? 'Subject is required'
                    : null,
                errorStyle: TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PriorityField extends StatelessWidget {
  const _PriorityField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SupportBloc, SupportState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Priority',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: state.priority,
                  isExpanded: true,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Low', child: Text('Low')),
                    DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'High', child: Text('High')),
                    DropdownMenuItem(value: 'Urgent', child: Text('Urgent')),
                  ],
                  onChanged: (priority) {
                    if (priority != null) {
                      context.read<SupportBloc>().add(SupportPriorityChanged(priority));
                    }
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MessageField extends StatelessWidget {
  const _MessageField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SupportBloc, SupportState>(
      buildWhen: (previous, current) => previous.message != current.message,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Message',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              onChanged: (message) => context
                  .read<SupportBloc>()
                  .add(SupportMessageChanged(message)),
              maxLines: 5,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Describe your issue in detail...',
                hintStyle: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 16,
                ),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.cyan,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.error,
                    width: 1,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.error,
                    width: 2,
                  ),
                ),
                errorText: state.message.displayError != null
                    ? state.message.displayError == SupportMessageValidationError.empty
                        ? 'Message is required'
                        : 'Message must be at least 10 characters'
                    : null,
                errorStyle: TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AttachmentSection extends StatelessWidget {
  const _AttachmentSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SupportBloc, SupportState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attachments (Optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  if (state.attachments.isEmpty) ...[
                    Icon(
                      Icons.attach_file,
                      color: AppColors.textTertiary,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No attachments added',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 14,
                      ),
                    ),
                  ] else ...[
                    ...state.attachments.asMap().entries.map((entry) {
                      final index = entry.key;
                      final attachment = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.attach_file,
                              color: AppColors.cyan,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                attachment.split('/').last,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                context.read<SupportBloc>().add(SupportAttachmentRemoved(index));
                              },
                              icon: Icon(
                                Icons.close,
                                color: AppColors.error,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Handle file attachment
                      context.read<SupportBloc>().add(const SupportAttachmentAdded('sample_file.pdf'));
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Attachment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cyan.withOpacity(0.1),
                      foregroundColor: AppColors.cyan,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SupportBloc, SupportState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.isValid != current.isValid,
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: state.isValid
                ? LinearGradient(
                    colors: [AppColors.cyan, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: state.isValid
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
            onPressed: state.isValid
                ? () => context.read<SupportBloc>().add(const SupportSubmitted())
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: state.isValid ? Colors.transparent : AppColors.border,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
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
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Submitting...',
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
                        Icons.send_rounded,
                        size: 20,
                        color: state.isValid ? Colors.white : AppColors.textTertiary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Submit Support Request',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: state.isValid ? Colors.white : AppColors.textTertiary,
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

class _ContactInfoSection extends StatelessWidget {
  const _ContactInfoSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.info_outline,
              color: AppColors.warning,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need Immediate Help?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'For urgent issues, call our support hotline directly.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Support Hotline: +91 9876543210',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
