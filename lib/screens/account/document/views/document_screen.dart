import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import '../bloc/document_bloc.dart' as bloc;
import 'package:profile_repo/profile_repo.dart' as repo;

class DocumentScreen extends StatelessWidget {
  const DocumentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => bloc.DocumentBloc()..add(const bloc.LoadDocuments()),
      child: const _DocumentScreen(),
    );
  }
}

class _DocumentScreen extends StatelessWidget {
  const _DocumentScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Documents',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Add help functionality
            },
            child: const Text(
              'Help',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<bloc.DocumentBloc, bloc.DocumentState>(
        builder: (context, state) {
          if (state.status == FormzSubmissionStatus.inProgress) {
            return const Center(child: CircularProgressIndicator());
          }

          final documents = state.documents
              .whereType<Map<String, dynamic>>() // Ensure the elements are maps
              .map((doc) => repo.Document.fromJson(doc)) // Convert to repo.Document
              .toList();
          final driverDocs = documents.where((doc) => doc.isDriver).toList();
          final vehicleDocs = documents.where((doc) => doc.isVehicle).toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),
                _buildDocumentSection(
                  'Driver Documents',
                  driverDocs,
                ),
                const SizedBox(height: 16),
                _buildDocumentSection(
                  'Vehicle Documents',
                  vehicleDocs,
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDocumentSection(String title, List<repo.Document> documents) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...documents.map((doc) => _buildDocumentItem(doc)).toList(),
      ],
    );
  }

  Widget _buildDocumentItem(repo.Document doc) {
    final isOptional = !doc.isRequired;
    final isCompleted = doc.isApproved;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0.5),
      decoration: BoxDecoration(
        color: _getBackgroundColor(doc.status),
        border: Border.all(
          color: Colors.grey.shade100,
          width: 0.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (doc.isNextStep)
              const Text(
                'Recommended next step',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF2261DD),
                  fontWeight: FontWeight.w500,
                ),
              )
            else if (isOptional)
              const Text(
                'Optional',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w500,
                ),
              )
            else if (isCompleted)
              const Text(
                'Completed',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w500,
                ),
              )
            else
              const Text(
                'Required',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w500,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              doc.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                height: 1.2,
              ),
            ),
          ],
        ),
        trailing: _buildStatusIcon(doc.status),
      ),
    );
  }

  Color _getBackgroundColor(repo.DocumentStatus status) {
    switch (status) {
      case repo.DocumentStatus.approved:
        return const Color(0xFFEDF7ED);
      case repo.DocumentStatus.pending:
      case repo.DocumentStatus.verificationRequired:
        return const Color(0xFFF5F5F5);
      case repo.DocumentStatus.notUploaded:
        return const Color(0xFFF5F5F5);
      case repo.DocumentStatus.expired:
        return const Color(0xFFFFEBEE);
      case repo.DocumentStatus.rejected:
        return const Color(0xFFFFF3E0); // Example color for rejected status
      default:
        return const Color(0xFFFFFFFF);
    }
  }

  Widget _buildStatusIcon(repo.DocumentStatus status) {
    switch (status) {
      case repo.DocumentStatus.approved:
        return Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF108043),
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 18,
          ),
        );
      case repo.DocumentStatus.notUploaded:
      case repo.DocumentStatus.pending:
      case repo.DocumentStatus.verificationRequired:
      case repo.DocumentStatus.expired:
        return const Icon(
          Icons.chevron_right,
          color: Color(0xFF666666),
          size: 24,
        );
      case repo.DocumentStatus.rejected:
        return const Icon(
          Icons.error_outline,
          color: Color(0xFFFF6F00), // Example color for rejected status
          size: 24,
        );
    }
  }
}
