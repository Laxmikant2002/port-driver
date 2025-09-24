import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:documents_repo/documents_repo.dart';
import '../../../widgets/colors.dart';
import '../bloc/document_upload_bloc.dart';
import '../../../models/document_upload.dart';

/// {@template document_upload_flow_screen}
/// Main screen that manages the complete document upload flow.
/// {@endtemplate}
class DocumentUploadFlowScreen extends StatelessWidget {
  /// {@macro document_upload_flow_screen}
  const DocumentUploadFlowScreen({
    super.key,
    required this.documentsRepo,
  });

  final DocumentsRepo documentsRepo;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DocumentUploadBloc(documentsRepo: documentsRepo)
        ..add(const DocumentUploadInitialized()),
      child: const DocumentUploadFlowView(),
    );
  }
}

class DocumentUploadFlowView extends StatefulWidget {
  const DocumentUploadFlowView({super.key});

  @override
  State<DocumentUploadFlowView> createState() => _DocumentUploadFlowViewState();
}

class _DocumentUploadFlowViewState extends State<DocumentUploadFlowView> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressHeader(),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: [
                  _buildIntroStep(),
                  _buildUploadStep(),
                  _buildReviewStep(),
                ],
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Progress Steps
          Row(
            children: [
              _buildProgressStep(0, 'Intro', _currentStep >= 0),
              _buildProgressConnector(_currentStep > 0),
              _buildProgressStep(1, 'Upload', _currentStep >= 1),
              _buildProgressConnector(_currentStep > 1),
              _buildProgressStep(2, 'Review', _currentStep >= 2),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Text
          Text(
            _getProgressText(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStep(int step, String label, bool isActive) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? AppColors.cyan : AppColors.border,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: isActive
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive ? AppColors.cyan : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressConnector(bool isActive) {
    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.cyan : AppColors.border,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  String _getProgressText() {
    switch (_currentStep) {
      case 0:
        return 'Learn about required documents';
      case 1:
        return 'Upload your documents';
      case 2:
        return 'Review and submit for verification';
      default:
        return '';
    }
  }

  Widget _buildIntroStep() {
    return const _IntroStepContent();
  }

  Widget _buildUploadStep() {
    return const _UploadStepContent();
  }

  Widget _buildReviewStep() {
    return const _ReviewStepContent();
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Previous',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: _canProceed() ? _proceedToNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canProceed() ? AppColors.cyan : AppColors.border,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                _getNextButtonText(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _canProceed() ? Colors.white : AppColors.textTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return true; // Always can proceed from intro
      case 1:
        return BlocProvider.of<DocumentUploadBloc>(context)
            .state
            .allRequiredDocumentsUploaded;
      case 2:
        return BlocProvider.of<DocumentUploadBloc>(context)
            .state
            .allRequiredDocumentsUploaded;
      default:
        return false;
    }
  }

  String _getNextButtonText() {
    switch (_currentStep) {
      case 0:
        return 'Start Upload';
      case 1:
        return 'Review Documents';
      case 2:
        return 'Submit for Verification';
      default:
        return 'Next';
    }
  }

  void _proceedToNext() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Submit documents
      context.read<DocumentUploadBloc>().add(
        const DocumentUploadSubmitted(),
      );
    }
  }
}

class _IntroStepContent extends StatelessWidget {
  const _IntroStepContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildDocumentChecklist(),
          const SizedBox(height: 32),
          _buildInfoSection(),
        ],
      ),
    );
  }

  Widget _buildDocumentChecklist() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Required Documents',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...DocumentType.values.where((type) => type.isRequired).map(
              (type) => _DocumentChecklistItem(type: type),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
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
          Icon(
            Icons.info_outline,
            color: AppColors.warning,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Make sure all documents are clear and readable. Blurry or unclear photos will be rejected.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentChecklistItem extends StatelessWidget {
  const _DocumentChecklistItem({required this.type});

  final DocumentType type;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getDocumentIcon(type),
              size: 16,
              color: AppColors.cyan,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              type.displayName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (type.requiresBothSides) ...[
            Icon(
              Icons.info_outline,
              size: 14,
              color: AppColors.warning,
            ),
          ],
        ],
      ),
    );
  }

  IconData _getDocumentIcon(DocumentType type) {
    switch (type) {
      case DocumentType.drivingLicense:
        return Icons.credit_card;
      case DocumentType.registrationCertificate:
        return Icons.directions_car;
      case DocumentType.vehicleInsurance:
        return Icons.security;
      case DocumentType.profilePicture:
        return Icons.person;
      case DocumentType.aadhaarCard:
        return Icons.badge;
      case DocumentType.panCard:
        return Icons.account_balance;
      case DocumentType.addressProof:
        return Icons.location_on;
    }
  }
}

class _UploadStepContent extends StatelessWidget {
  const _UploadStepContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentUploadBloc, DocumentUploadState>(
      builder: (context, state) {
        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildProgressSection(state),
              const SizedBox(height: 24),
              _buildDocumentList(state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressSection(DocumentUploadState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Upload Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: state.uploadProgress,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.cyan),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            '${state.uploadedDocuments} of ${state.totalDocuments} documents uploaded',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentList(DocumentUploadState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Documents',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...state.documents.map((doc) => _DocumentUploadItem(document: doc)),
          ],
        ),
      ),
    );
  }
}

class _DocumentUploadItem extends StatelessWidget {
  const _DocumentUploadItem({required this.document});

  final DocumentUpload document;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(document.status).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to individual upload screen
          Navigator.of(context).pushNamed(
            '/document-upload',
            arguments: document.type,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getStatusColor(document.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getDocumentIcon(document.type),
                size: 20,
                color: _getStatusColor(document.status),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    document.status.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(document.status),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.pending:
        return AppColors.textSecondary;
      case DocumentStatus.uploading:
      case DocumentStatus.verifying:
        return AppColors.warning;
      case DocumentStatus.uploaded:
        return AppColors.cyan;
      case DocumentStatus.verified:
        return AppColors.success;
      case DocumentStatus.rejected:
        return AppColors.error;
    }
  }

  IconData _getDocumentIcon(DocumentType type) {
    switch (type) {
      case DocumentType.drivingLicense:
        return Icons.credit_card;
      case DocumentType.registrationCertificate:
        return Icons.directions_car;
      case DocumentType.vehicleInsurance:
        return Icons.security;
      case DocumentType.profilePicture:
        return Icons.person;
      case DocumentType.aadhaarCard:
        return Icons.badge;
      case DocumentType.panCard:
        return Icons.account_balance;
      case DocumentType.addressProof:
        return Icons.location_on;
    }
  }
}

class _ReviewStepContent extends StatelessWidget {
  const _ReviewStepContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentUploadBloc, DocumentUploadState>(
      builder: (context, state) {
        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildSummarySection(state),
              const SizedBox(height: 24),
              _buildDocumentStatusList(state),
              const SizedBox(height: 24),
              _buildVerificationInfo(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummarySection(DocumentUploadState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Document Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Uploaded',
                  '${state.uploadedDocuments}',
                  AppColors.cyan,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Verified',
                  '${state.verifiedDocuments}',
                  AppColors.success,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Pending',
                  '${state.pendingDocuments}',
                  AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentStatusList(DocumentUploadState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Document Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...state.documents.map((doc) => _DocumentStatusItem(document: doc)),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Your documents will be reviewed by our admin team. You will receive a notification once verification is complete.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentStatusItem extends StatelessWidget {
  const _DocumentStatusItem({required this.document});

  final DocumentUpload document;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(document.status).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getStatusColor(document.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getDocumentIcon(document.type),
              size: 20,
              color: _getStatusColor(document.status),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  document.status.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    color: _getStatusColor(document.status),
                  ),
                ),
              ],
            ),
          ),
          if (document.isUploaded)
            Icon(
              Icons.check_circle,
              size: 20,
              color: AppColors.success,
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.pending:
        return AppColors.textSecondary;
      case DocumentStatus.uploading:
      case DocumentStatus.verifying:
        return AppColors.warning;
      case DocumentStatus.uploaded:
        return AppColors.cyan;
      case DocumentStatus.verified:
        return AppColors.success;
      case DocumentStatus.rejected:
        return AppColors.error;
    }
  }

  IconData _getDocumentIcon(DocumentType type) {
    switch (type) {
      case DocumentType.drivingLicense:
        return Icons.credit_card;
      case DocumentType.registrationCertificate:
        return Icons.directions_car;
      case DocumentType.vehicleInsurance:
        return Icons.security;
      case DocumentType.profilePicture:
        return Icons.person;
      case DocumentType.aadhaarCard:
        return Icons.badge;
      case DocumentType.panCard:
        return Icons.account_balance;
      case DocumentType.addressProof:
        return Icons.location_on;
    }
  }
}
