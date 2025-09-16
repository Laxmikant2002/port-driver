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
    on<DocumentUploadProgress>(_onDocumentUploadProgress);
    on<DocumentUploadCompleted>(_onDocumentUploadCompleted);
    on<DocumentUploadFailed>(_onDocumentUploadFailed);
    on<DocumentVerificationStarted>(_onDocumentVerificationStarted);
    on<DocumentVerified>(_onDocumentVerified);
    on<DocumentRejected>(_onDocumentRejected);
    on<DocsSubmitted>(_onDocsSubmitted);
  }

  /// Handles loading the required documents.
  Future<void> _onDocsLoaded(
    DocsLoaded event,
    Emitter<DocsState> emit,
  ) async {
    emit(state.copyWith(status: DocsStatus.loading));

    try {
      final documents = _getRequiredDocuments();
      
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
    final updatedDocuments = state.documents.map((doc) {
      if (doc.type == event.documentType) {
        return doc.copyWith(
          status: DocumentStatus.uploading,
          uploadProgress: 0.0,
        );
      }
      return doc;
    }).toList();

    emit(state.copyWith(
      status: DocsStatus.uploading,
      documents: updatedDocuments,
    ));

    // Simulate upload process
    try {
      await _simulateUpload(event.documentType, emit);
    } catch (error) {
      add(DocumentUploadFailed(
        documentType: event.documentType,
        error: error.toString(),
      ));
    }
  }

  /// Handles upload progress updates.
  void _onDocumentUploadProgress(
    DocumentUploadProgress event,
    Emitter<DocsState> emit,
  ) {
    final updatedDocuments = state.documents.map((doc) {
      if (doc.type == event.documentType) {
        return doc.copyWith(uploadProgress: event.progress);
      }
      return doc;
    }).toList();

    emit(state.copyWith(documents: updatedDocuments));
  }

  /// Handles successful document upload completion.
  void _onDocumentUploadCompleted(
    DocumentUploadCompleted event,
    Emitter<DocsState> emit,
  ) {
    final updatedDocuments = state.documents.map((doc) {
      if (doc.type == event.documentType) {
        return doc.copyWith(
          status: DocumentStatus.uploaded,
          uploadProgress: 1.0,
          frontImagePath: event.frontImageUrl,
          backImagePath: event.backImageUrl,
        );
      }
      return doc;
    }).toList();

    // Start verification automatically after upload
    add(DocumentVerificationStarted(event.documentType));

    emit(state.copyWith(
      status: DocsStatus.loaded,
      documents: updatedDocuments,
    ));
  }

  /// Handles failed document upload.
  void _onDocumentUploadFailed(
    DocumentUploadFailed event,
    Emitter<DocsState> emit,
  ) {
    final updatedDocuments = state.documents.map((doc) {
      if (doc.type == event.documentType) {
        return doc.copyWith(
          status: DocumentStatus.pending,
          uploadProgress: 0.0,
        );
      }
      return doc;
    }).toList();

    emit(state.copyWith(
      status: DocsStatus.failure,
      documents: updatedDocuments,
      errorMessage: event.error,
    ));
  }

  /// Handles document verification start.
  void _onDocumentVerificationStarted(
    DocumentVerificationStarted event,
    Emitter<DocsState> emit,
  ) {
    final updatedDocuments = state.documents.map((doc) {
      if (doc.type == event.documentType) {
        return doc.copyWith(status: DocumentStatus.verifying);
      }
      return doc;
    }).toList();

    emit(state.copyWith(documents: updatedDocuments));

    // Simulate verification (in real app, this would be done by backend)
    Future.delayed(const Duration(seconds: 2), () {
      add(DocumentVerified(event.documentType));
    });
  }

  /// Handles successful document verification.
  void _onDocumentVerified(
    DocumentVerified event,
    Emitter<DocsState> emit,
  ) {
    final updatedDocuments = state.documents.map((doc) {
      if (doc.type == event.documentType) {
        return doc.copyWith(status: DocumentStatus.verified);
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

  /// Handles document rejection.
  void _onDocumentRejected(
    DocumentRejected event,
    Emitter<DocsState> emit,
  ) {
    final updatedDocuments = state.documents.map((doc) {
      if (doc.type == event.documentType) {
        return doc.copyWith(
          status: DocumentStatus.rejected,
          rejectionReason: event.reason,
        );
      }
      return doc;
    }).toList();

    emit(state.copyWith(
      documents: updatedDocuments,
      status: DocsStatus.loaded,
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

  /// Returns the list of required documents.
  List<Document> _getRequiredDocuments() {
    return [
      const Document(
        type: DocumentType.drivingLicense,
        title: 'Driving License',
        description: 'Upload front & back photos',
        isRequired: true,
        isRecommendedNext: true,
      ),
      const Document(
        type: DocumentType.registrationCertificate,
        title: 'Registration Certificate (RC)',
        description: 'Upload RC & enter vehicle details',
        isRequired: true,
      ),
      const Document(
        type: DocumentType.vehicleInsurance,
        title: 'Vehicle Insurance',
        description: 'Upload insurance certificate',
        isRequired: true,
      ),
      const Document(
        type: DocumentType.profilePicture,
        title: 'Profile Picture',
        description: 'Take a clear selfie photo',
        isRequired: true,
      ),
      const Document(
        type: DocumentType.aadhaarCard,
        title: 'Aadhaar Card',
        description: 'Upload front & back photos',
        isRequired: true,
      ),
    ];
  }

  /// Simulates the upload process with progress updates.
  Future<void> _simulateUpload(
    DocumentType documentType,
    Emitter<DocsState> emit,
  ) async {
    // Simulate upload progress
    for (int i = 0; i <= 100; i += 10) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      add(DocumentUploadProgress(
        documentType: documentType,
        progress: i / 100,
      ));
    }

    // Complete upload
    add(DocumentUploadCompleted(
      documentType: documentType,
      frontImageUrl: 'https://example.com/front_${documentType.name}.jpg',
      backImageUrl: documentType == DocumentType.drivingLicense || 
                   documentType == DocumentType.aadhaarCard
          ? 'https://example.com/back_${documentType.name}.jpg'
          : null,
    ));
  }
}
