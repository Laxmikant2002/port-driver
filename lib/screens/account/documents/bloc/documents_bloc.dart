import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:documents_repo/documents_repo.dart';
import 'package:documents_repo/src/models/document.dart' as documents_repo;
import 'package:driver/models/document_upload.dart' hide DocumentStatus, DocumentType;
import 'package:driver/models/document_upload.dart' as local_models show DocumentStatus, DocumentType;

part 'documents_event.dart';
part 'documents_state.dart';

/// {@template documents_bloc}
/// BLoC for managing active driver documents (list, status, expiry).
/// {@endtemplate}
class DocumentsBloc extends Bloc<DocumentsEvent, DocumentsState> {
  /// {@macro documents_bloc}
  DocumentsBloc({
    required this.documentsRepo,
  }) : super(const DocumentsState()) {
    on<DocumentsLoaded>(_onDocumentsLoaded);
    on<DocumentStatusRefreshed>(_onDocumentStatusRefreshed);
    on<DocumentReuploadRequested>(_onDocumentReuploadRequested);
    on<DocumentDeleted>(_onDocumentDeleted);
    on<DocumentExpiryNotificationToggled>(_onDocumentExpiryNotificationToggled);
  }

  final DocumentsRepo documentsRepo;

  Future<void> _onDocumentsLoaded(
    DocumentsLoaded event,
    Emitter<DocumentsState> emit,
  ) async {
    emit(state.copyWith(status: DocumentsStatus.loading));

    try {
      final response = await documentsRepo.getDocuments();
      
      if (response.success && response.documents != null) {
        final documents = response.documents!
            .map((doc) => _convertToDocumentUpload(doc))
            .toList();

        emit(state.copyWith(
          status: DocumentsStatus.success,
          documents: documents,
        ));
      } else {
        emit(state.copyWith(
          status: DocumentsStatus.failure,
          errorMessage: response.message ?? 'Failed to load documents',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: DocumentsStatus.failure,
        errorMessage: 'Network error: ${e.toString()}',
      ));
    }
  }

  Future<void> _onDocumentStatusRefreshed(
    DocumentStatusRefreshed event,
    Emitter<DocumentsState> emit,
  ) async {
    try {
      final response = await documentsRepo.getDocuments();
      
      if (response.success && response.documents != null) {
        final documents = response.documents!
            .map((doc) => _convertToDocumentUpload(doc))
            .toList();

        emit(state.copyWith(documents: documents));
      }
    } catch (e) {
      // Silent fail for refresh - don't show error
    }
  }

  Future<void> _onDocumentReuploadRequested(
    DocumentReuploadRequested event,
    Emitter<DocumentsState> emit,
  ) async {
    emit(state.copyWith(
      status: DocumentsStatus.reuploading,
      selectedDocumentId: event.documentId,
    ));

    try {
      // Delete existing document first
      final deleteResponse = await documentsRepo.deleteDocument(event.documentId);
      
      if (deleteResponse.success) {
        // Update local state
        final updatedDocuments = state.documents.map((doc) {
          if (doc.id == event.documentId) {
            return doc.copyWith(
              status: local_models.DocumentStatus.pending,
              frontImagePath: null,
              backImagePath: null,
              fileName: null,
              fileSize: null,
              uploadedAt: null,
              rejectionReason: null,
            );
          }
          return doc;
        }).toList();

        emit(state.copyWith(
          status: DocumentsStatus.success,
          documents: updatedDocuments,
          selectedDocumentId: null,
        ));
      } else {
        emit(state.copyWith(
          status: DocumentsStatus.failure,
          errorMessage: deleteResponse.message ?? 'Failed to delete document',
          selectedDocumentId: null,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: DocumentsStatus.failure,
        errorMessage: 'Network error: ${e.toString()}',
        selectedDocumentId: null,
      ));
    }
  }

  Future<void> _onDocumentDeleted(
    DocumentDeleted event,
    Emitter<DocumentsState> emit,
  ) async {
    try {
      final response = await documentsRepo.deleteDocument(event.documentId);
      
      if (response.success) {
        final updatedDocuments = state.documents
            .where((doc) => doc.id != event.documentId)
            .toList();

        emit(state.copyWith(documents: updatedDocuments));
      } else {
        emit(state.copyWith(
          status: DocumentsStatus.failure,
          errorMessage: response.message ?? 'Failed to delete document',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: DocumentsStatus.failure,
        errorMessage: 'Network error: ${e.toString()}',
      ));
    }
  }

  void _onDocumentExpiryNotificationToggled(
    DocumentExpiryNotificationToggled event,
    Emitter<DocumentsState> emit,
  ) {
    final updatedDocuments = state.documents.map((doc) {
      if (doc.id == event.documentId) {
        return doc.copyWith(
          expiryNotificationEnabled: event.enabled,
        );
      }
      return doc;
    }).toList();

    emit(state.copyWith(documents: updatedDocuments));
  }

  DocumentUpload _convertToDocumentUpload(documents_repo.Document doc) {
    return DocumentUpload(
      id: doc.id,
      type: _convertDocumentType(doc.type),
      title: _convertDocumentType(doc.type).displayName,
      description: _convertDocumentType(doc.type).description,
      isRequired: _convertDocumentType(doc.type).isRequired,
      status: _convertDocumentStatus(doc.status),
      frontImagePath: doc.fileUrl,
      backImagePath: null, // documents_repo model doesn't have back image
      fileName: doc.fileName,
      uploadedAt: doc.uploadedAt,
      verifiedAt: doc.verifiedAt,
      rejectionReason: doc.rejectedReason,
      expiryDate: _calculateExpiryDate(_convertDocumentType(doc.type)),
      expiryNotificationEnabled: true,
    );
  }

  DateTime? _calculateExpiryDate(local_models.DocumentType type) {
    // This would typically come from the API
    // For now, we'll simulate expiry dates based on document type
    final now = DateTime.now();
    switch (type) {
      case local_models.DocumentType.drivingLicense:
        return now.add(const Duration(days: 365 * 5)); // 5 years
      case local_models.DocumentType.registrationCertificate:
        return now.add(const Duration(days: 365 * 15)); // 15 years
      case local_models.DocumentType.vehicleInsurance:
        return now.add(const Duration(days: 365)); // 1 year
      case local_models.DocumentType.aadhaarCard:
        return null; // No expiry
      case local_models.DocumentType.panCard:
        return null; // No expiry
      case local_models.DocumentType.profilePicture:
        return null; // No expiry
      case local_models.DocumentType.addressProof:
        return null; // No expiry
    }
  }

  /// Convert documents_repo DocumentType to local DocumentType
  local_models.DocumentType _convertDocumentType(documents_repo.DocumentType repoType) {
    switch (repoType) {
      case documents_repo.DocumentType.drivingLicense:
        return local_models.DocumentType.drivingLicense;
      case documents_repo.DocumentType.rcBook:
        return local_models.DocumentType.registrationCertificate;
      case documents_repo.DocumentType.insurance:
        return local_models.DocumentType.vehicleInsurance;
      case documents_repo.DocumentType.profilePicture:
        return local_models.DocumentType.profilePicture;
      case documents_repo.DocumentType.aadhaar:
        return local_models.DocumentType.aadhaarCard;
      case documents_repo.DocumentType.pan:
        return local_models.DocumentType.panCard;
      case documents_repo.DocumentType.addressProof:
        return local_models.DocumentType.addressProof;
    }
  }

  /// Convert documents_repo DocumentStatus to local DocumentStatus
  local_models.DocumentStatus _convertDocumentStatus(documents_repo.DocumentStatus repoStatus) {
    switch (repoStatus) {
      case documents_repo.DocumentStatus.pending:
        return local_models.DocumentStatus.pending;
      case documents_repo.DocumentStatus.uploading:
        return local_models.DocumentStatus.uploading;
      case documents_repo.DocumentStatus.uploaded:
        return local_models.DocumentStatus.uploaded;
      case documents_repo.DocumentStatus.verifying:
        return local_models.DocumentStatus.verifying;
      case documents_repo.DocumentStatus.verified:
        return local_models.DocumentStatus.verified;
      case documents_repo.DocumentStatus.rejected:
        return local_models.DocumentStatus.rejected;
      case documents_repo.DocumentStatus.expired:
        return local_models.DocumentStatus.rejected; // Map expired to rejected for now
    }
  }
}
