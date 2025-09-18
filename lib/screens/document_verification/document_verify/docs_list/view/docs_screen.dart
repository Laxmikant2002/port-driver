import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../models/document.dart';
import '../../../../../widgets/colors.dart';
import '../bloc/docs_bloc.dart';

class DocsPage extends StatelessWidget {
  const DocsPage({super.key});

  /// The route name for the document verification page.
  static const String routeName = '/docs-verification';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DocsBloc()..add(const DocsLoaded()),
      child: const DocsView(),
    );
  }
}

class DocsView extends StatelessWidget {
  const DocsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<DocsBloc, DocsState>(
        listener: (context, state) {
          if (state.status == DocsStatus.completed) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('All documents verified successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
          } else if (state.status == DocsStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Something went wrong'),
                  backgroundColor: AppColors.error,
                ),
              );
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              const _HeaderSection(),
              const SizedBox(height: 24),
              Expanded(
                child: BlocBuilder<DocsBloc, DocsState>(
                  builder: (context, state) {
                    if (state.status == DocsStatus.loading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return Column(
                      children: [
                        const SizedBox(height: 16),
                        Expanded(
                          child: _buildDocumentsList(context, state),
                        ),
                        _buildActionButtons(context),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentsList(BuildContext context, DocsState state) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: state.documents.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final document = state.documents[index];
        return _buildDocumentCard(context, document);
      },
    );
  }

  Widget _buildDocumentCard(BuildContext context, Document document) {
    // Replace with a simple ListTile for now
    return ListTile(
      title: Text(document.type.toString()),
      subtitle: Text(document.status.toString()),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () {},
    );
  }

  // Removed conversion helpers and navigation to ModernDocsScreen

  Widget _buildActionButtons(BuildContext context) {
    // Removed ModernDocsScreen and VerificationStatusScreen navigation
    return SizedBox.shrink();
  }

  // Removed navigation helpers for ModernDocsScreen and VerificationStatusScreen
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
          // Location Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.directions_car_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Signing up for Karimnagar • Rides',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Welcome Text
          Text(
            'Welcome, Laxmikant',
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
            'Here\'s what you need to do to set up your account',
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

class _ProgressIndicator extends StatelessWidget {
  final DocsState state;
  
  const _ProgressIndicator({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${state.completedDocuments}/${state.totalDocuments}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: state.progressPercentage,
            backgroundColor: AppColors.backgroundSecondary,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}