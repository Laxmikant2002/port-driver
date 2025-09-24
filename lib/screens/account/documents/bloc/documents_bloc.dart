import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:documents_repo/documents_repo.dart';
import '../../../models/document_upload.dart';

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
              status: DocumentStatus.pending,
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

  DocumentUpload _convertToDocumentUpload(doc) {
    return DocumentUpload(
      id: doc.id,
      type: DocumentType.fromString(doc.type.value),
      title: doc.type.displayName,
      description: doc.type.description,
      isRequired: doc.type.isRequired,
      status: DocumentStatus.fromString(doc.status.value),
      frontImagePath: doc.fileUrl,
      fileName: doc.fileName,
      uploadedAt: doc.uploadedAt,
      verifiedAt: doc.verifiedAt,
      rejectionReason: doc.rejectedReason,
      expiryDate: _calculateExpiryDate(doc.type),
      expiryNotificationEnabled: true,
    );
  }

  DateTime? _calculateExpiryDate(DocumentType type) {
    // This would typically come from the API
    // For now, we'll simulate expiry dates based on document type
    final now = DateTime.now();
    switch (type) {
      case DocumentType.drivingLicense:
        return now.add(const Duration(days: 365 * 5)); // 5 years
      case DocumentType.registrationCertificate:
        return now.add(const Duration(days: 365 * 15)); // 15 years
      case DocumentType.vehicleInsurance:
        return now.add(const Duration(days: 365)); // 1 year
      case DocumentType.aadhaarCard:
        return null; // No expiry
      case DocumentType.panCard:
        return null; // No expiry
      case DocumentType.profilePicture:
        return null; // No expiry
      case DocumentType.addressProof:
        return null; // No expiry
    }
  }
}
