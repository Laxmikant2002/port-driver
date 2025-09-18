import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../models/document.dart';

part 'docs_event.dart';
part 'docs_state.dart';

/// {@template docs_bloc}
/// BLoC responsible for managing document verification process.
/// {@endtemplate}
class DocsBloc extends Bloc<DocsEvent, DocsState> {
  /// {@macro docs_bloc}
  DocsBloc() : super(const DocsState()) {
    on<DocsLoaded>(_onDocsLoaded);
    on<DocumentUploadStarted>(_onDocumentUploadStarted);
    on<DocumentStatusUpdated>(_onDocumentStatusUpdated);
    on<DocsSubmitted>(_onDocsSubmitted);
  }

  /// Handles loading the required documents.
  Future<void> _onDocsLoaded(
    DocsLoaded event,
    Emitter<DocsState> emit,
  ) async {
    emit(state.copyWith(status: DocsStatus.loading));

    try {
      // TODO: Replace with actual API call to get document status from backend
      final documents = await _fetchDocumentStatusFromBackend();
      
      emit(state.copyWith(
        status: DocsStatus.loaded,
        documents: documents,
        totalDocuments: documents.where((doc) => doc.isRequired).length,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: DocsStatus.failure,
        errorMessage: 'Failed to load documents: $error',
      ));
    }
  }

  /// Handles document upload start.
  Future<void> _onDocumentUploadStarted(
    DocumentUploadStarted event,
    Emitter<DocsState> emit,
  ) async {
    // Navigate to specific document screen instead of simulating upload
    // This will be handled by the UI navigation
  }

  /// Handles document status update from backend.
  void _onDocumentStatusUpdated(
    DocumentStatusUpdated event,
    Emitter<DocsState> emit,
  ) {
    final updatedDocuments = state.documents.map((doc) {
      if (doc.type == event.documentType) {
        return doc.copyWith(
          status: event.status,
          rejectionReason: event.rejectionReason,
        );
      }
      return doc;
    }).toList();

    final completedCount = updatedDocuments
        .where((doc) => doc.isRequired && doc.status == DocumentStatus.verified)
        .length;

    emit(state.copyWith(
      documents: updatedDocuments,
      completedDocuments: completedCount,
      status: completedCount == state.totalDocuments 
          ? DocsStatus.completed 
          : DocsStatus.loaded,
    ));
  }

  /// Handles final document submission.
  Future<void> _onDocsSubmitted(
    DocsSubmitted event,
    Emitter<DocsState> emit,
  ) async {
    emit(state.copyWith(status: DocsStatus.submitted));

    try {
      // Simulate submission to backend
      await Future<void>.delayed(const Duration(seconds: 2));
      
      emit(state.copyWith(status: DocsStatus.completed));
    } catch (error) {
      emit(state.copyWith(
        status: DocsStatus.failure,
        errorMessage: 'Failed to submit documents: $error',
      ));
    }
  }

  /// Fetches document status from backend API.
  Future<List<Document>> _fetchDocumentStatusFromBackend() async {
    // TODO: Replace with actual API call
    // This should call your backend API to get the current status of all documents
    // Example API call:
    // final response = await apiClient.get('/driver/documents/status');
    // return response.data.map((doc) => Document.fromJson(doc)).toList();
    
    // For now, return documents with pending status
    return [
      const Document(
        type: DocumentType.drivingLicense,
        title: 'Driving License',
        description: 'Upload front & back photos',
        isRequired: true,
        isRecommendedNext: true,
        status: DocumentStatus.pending,
      ),
      const Document(
        type: DocumentType.profilePicture,
        title: 'Profile Picture',
        description: 'Take a clear selfie photo',
        isRequired: true,
        status: DocumentStatus.pending,
      ),
      const Document(
        type: DocumentType.aadhaarCard,
        title: 'Aadhaar Card',
        description: 'Upload front & back photos',
        isRequired: true,
        status: DocumentStatus.pending,
      ),
      const Document(
        type: DocumentType.registrationCertificate,
        title: 'Registration Certificate (RC)',
        description: 'Upload RC & enter vehicle details',
        isRequired: true,
        status: DocumentStatus.pending,
      ),
      const Document(
        type: DocumentType.vehicleInsurance,
        title: 'Vehicle Insurance',
        description: 'Upload insurance certificate',
        isRequired: true,
        status: DocumentStatus.pending,
      ),
    ];
  }
}
