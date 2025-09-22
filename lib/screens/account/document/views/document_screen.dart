import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:documents_repo/documents_repo.dart';
import '../../../../widgets/colors.dart';
import '../bloc/document_bloc.dart';

class DocumentScreen extends StatelessWidget {
  final DocumentsRepo documentsRepo;
  
  const DocumentScreen({
    Key? key,
    required this.documentsRepo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DocumentBloc(documentsRepo: documentsRepo)
        ..add(const DocumentsLoaded()),
      child: const DocumentView(),
    );
  }
}

class DocumentView extends StatelessWidget {
  const DocumentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<DocumentBloc, DocumentState>(
        listener: (context, state) {
          if (state.isSuccess) {
            // Handle success if needed
          } else if (state.hasError) {
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
          child: Column(
            children: [
              const _HeaderSection(),
              const SizedBox(height: 24),
              Expanded(
                child: BlocBuilder<DocumentBloc, DocumentState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.cyan),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          const _ProgressSection(),
                          const SizedBox(height: 24),
                          const _DriverDocumentsSection(),
                          const SizedBox(height: 24),
                          const _VehicleDocumentsSection(),
                          const SizedBox(height: 32),
                        ],
                      ),
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
          // Document Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.description_outlined,
              size: 32,
              color: AppColors.cyan,
            ),
          ),
          const SizedBox(height: 16),
          // Header Text
          Text(
            'Document Verification',
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
            'Upload and verify your documents to complete registration',
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

class _ProgressSection extends StatelessWidget {
  const _ProgressSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentBloc, DocumentState>(
      builder: (context, state) {
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.trending_up,
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
                          'Verification Progress',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${state.verifiedDocuments}/${state.totalDocuments} documents verified',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(state.verificationProgress * 100).toInt()}% Complete',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (state.allDocumentsVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'All Verified',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: state.verificationProgress,
                      backgroundColor: AppColors.backgroundSecondary,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        state.allDocumentsVerified ? AppColors.success : AppColors.cyan,
                      ),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DriverDocumentsSection extends StatelessWidget {
  const _DriverDocumentsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentBloc, DocumentState>(
      builder: (context, state) {
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
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
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
                            'Driver Documents',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Personal identification documents',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Document Items
                ...state.driverDocuments.map((document) => _DocumentItem(document: document)).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VehicleDocumentsSection extends StatelessWidget {
  const _VehicleDocumentsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentBloc, DocumentState>(
      builder: (context, state) {
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
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.directions_car_rounded,
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
                            'Vehicle Documents',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Vehicle registration and insurance',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Document Items
                ...state.vehicleDocuments.map((document) => _DocumentItem(document: document)).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DocumentItem extends StatelessWidget {
  final Document document;

  const _DocumentItem({required this.document});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(document.status),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getBorderColor(document.status),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _handleDocumentTap(context),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // Document Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getIconBackgroundColor(document.status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getDocumentIcon(document.type),
                color: _getIconColor(document.status),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Document Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.type.displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getStatusText(document.status),
                    style: TextStyle(
                      fontSize: 13,
                      color: _getStatusTextColor(document.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Status Icon
            _buildStatusIcon(document.status),
          ],
        ),
      ),
    );
  }

  void _handleDocumentTap(BuildContext context) {
    context.read<DocumentBloc>().add(DocumentSelected(document));
    // Navigate to document detail/upload screen
    // Navigator.push(context, MaterialPageRoute(...));
  }

  Color _getBackgroundColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.verified:
        return AppColors.success.withOpacity(0.1);
      case DocumentStatus.pending:
        return AppColors.warning.withOpacity(0.1);
      case DocumentStatus.rejected:
        return AppColors.error.withOpacity(0.1);
      case DocumentStatus.expired:
        return AppColors.error.withOpacity(0.1);
      default:
        return AppColors.background;
    }
  }

  Color _getBorderColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.verified:
        return AppColors.success.withOpacity(0.3);
      case DocumentStatus.pending:
        return AppColors.warning.withOpacity(0.3);
      case DocumentStatus.rejected:
        return AppColors.error.withOpacity(0.3);
      case DocumentStatus.expired:
        return AppColors.error.withOpacity(0.3);
      default:
        return AppColors.border;
    }
  }

  Color _getIconBackgroundColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.verified:
        return AppColors.success.withOpacity(0.2);
      case DocumentStatus.pending:
        return AppColors.warning.withOpacity(0.2);
      case DocumentStatus.rejected:
        return AppColors.error.withOpacity(0.2);
      case DocumentStatus.expired:
        return AppColors.error.withOpacity(0.2);
      default:
        return AppColors.cyan.withOpacity(0.1);
    }
  }

  Color _getIconColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.verified:
        return AppColors.success;
      case DocumentStatus.pending:
        return AppColors.warning;
      case DocumentStatus.rejected:
        return AppColors.error;
      case DocumentStatus.expired:
        return AppColors.error;
      default:
        return AppColors.cyan;
    }
  }

  IconData _getDocumentIcon(DocumentType type) {
    switch (type) {
      case DocumentType.drivingLicense:
        return Icons.credit_card;
      case DocumentType.rcBook:
        return Icons.directions_car;
      case DocumentType.insurance:
        return Icons.security;
      case DocumentType.aadhaar:
        return Icons.badge;
      case DocumentType.pan:
        return Icons.account_balance;
      case DocumentType.addressProof:
        return Icons.location_on;
    }
  }

  String _getStatusText(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.verified:
        return 'Verified';
      case DocumentStatus.pending:
        return 'Under Review';
      case DocumentStatus.rejected:
        return 'Rejected';
      case DocumentStatus.expired:
        return 'Expired';
    }
  }

  Color _getStatusTextColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.verified:
        return AppColors.success;
      case DocumentStatus.pending:
        return AppColors.warning;
      case DocumentStatus.rejected:
        return AppColors.error;
      case DocumentStatus.expired:
        return AppColors.error;
    }
  }

  Widget _buildStatusIcon(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.verified:
        return Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.success,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 16,
          ),
        );
      case DocumentStatus.pending:
        return Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.warning,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.schedule,
            color: Colors.white,
            size: 16,
          ),
        );
      case DocumentStatus.rejected:
      case DocumentStatus.expired:
        return Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.close,
            color: Colors.white,
            size: 16,
          ),
        );
    }
  }
}
