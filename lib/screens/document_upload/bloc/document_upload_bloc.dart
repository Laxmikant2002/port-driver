import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:documents_repo/documents_repo.dart';
import 'package:documents_repo/src/models/document.dart' as documents_repo;
import 'package:documents_repo/src/models/document_upload_request.dart' as documents_repo;
import 'package:driver/models/document_upload.dart' hide DocumentStatus, DocumentType;
import 'package:driver/models/document_upload.dart' as local_models show DocumentStatus, DocumentType;
import 'package:driver/core/error/document_upload_error.dart';

part 'document_upload_event.dart';
part 'document_upload_state.dart';

/// {@template document_upload_bloc}
/// BLoC for managing document upload flow with modern state management.
/// {@endtemplate}
class DocumentUploadBloc extends Bloc<DocumentUploadEvent, DocumentUploadState> {
  /// {@macro document_upload_bloc}
  DocumentUploadBloc({
    required this.documentsRepo,
  }) : super(const DocumentUploadState()) {
    on<DocumentUploadInitialized>(_onInitialized);
    on<DocumentUploadStarted>(_onUploadStarted);
    on<DocumentUploadProgressUpdated>(_onUploadProgressUpdated);
    on<DocumentUploadCompleted>(_onUploadCompleted);
    on<DocumentUploadFailed>(_onUploadFailed);
    on<DocumentUploadRetried>(_onUploadRetried);
    on<DocumentUploadDeleted>(_onUploadDeleted);
    on<DocumentUploadSubmitted>(_onSubmitted);
    on<DocumentUploadStatusRefreshed>(_onStatusRefreshed);
    on<DocumentUploadRecommendedNextChanged>(_onRecommendedNextChanged);
  }

  final DocumentsRepo documentsRepo;

  void _onInitialized(
    DocumentUploadInitialized event,
    Emitter<DocumentUploadState> emit,
  ) {
    emit(state.copyWith(
      documents: _createDefaultDocuments(),
      status: FormzSubmissionStatus.initial,
    ));
  }

  void _onUploadStarted(
    DocumentUploadStarted event,
    Emitter<DocumentUploadState> emit,
  ) {
    final updatedDocuments = state.documents.map((doc) {
      if (doc.type == event.type) {
        return doc.copyWith(
          status: local_models.DocumentStatus.uploading,
          uploadProgress: 0.0,
        );
      }
      return doc;
    }).toList();

    emit(state.copyWith(
      documents: updatedDocuments,
      status: FormzSubmissionStatus.inProgress,
    ));
  }

  void _onUploadProgressUpdated(
    DocumentUploadProgressUpdated event,
    Emitter<DocumentUploadState> emit,
  ) {
    final updatedDocuments = state.documents.map((doc) {
      if (doc.type == event.type) {
        return doc.copyWith(
          uploadProgress: event.progress,
        );
      }
      return doc;
    }).toList();

    emit(state.copyWith(documents: updatedDocuments));
  }

  void _onUploadCompleted(
    DocumentUploadCompleted event,
    Emitter<DocumentUploadState> emit,
  ) {
    final updatedDocuments = state.documents.map((doc) {
      if (doc.type == event.type) {
        return doc.copyWith(
          status: local_models.DocumentStatus.uploaded,
          frontImagePath: event.frontImagePath,
          backImagePath: event.backImagePath,
          fileName: event.fileName,
          fileSize: event.fileSize,
          uploadProgress: 1.0,
          uploadedAt: DateTime.now(),
        );
      }
      return doc;
    }).toList();

    emit(state.copyWith(
      documents: updatedDocuments,
      status: FormzSubmissionStatus.initial,
    ));
  }

  void _onUploadFailed(
    DocumentUploadFailed event,
    Emitter<DocumentUploadState> emit,
  ) {
    final error = DocumentUploadErrorHandler.handleException(event.error);
    
    final updatedDocuments = state.documents.map((doc) {
      if (doc.type == event.type) {
        return doc.copyWith(
          status: local_models.DocumentStatus.pending,
          uploadProgress: 0.0,
          rejectionReason: error.message,
        );
      }
      return doc;
    }).toList();

    emit(state.copyWith(
      documents: updatedDocuments,
      status: FormzSubmissionStatus.failure,
      error: error,
    ));
  }

  void _onUploadRetried(
    DocumentUploadRetried event,
    Emitter<DocumentUploadState> emit,
  ) {
    final updatedDocuments = state.documents.map((doc) {
      if (doc.type == event.type) {
        return doc.copyWith(
          status: local_models.DocumentStatus.uploading,
          uploadProgress: 0.0,
          rejectionReason: null,
        );
      }
      return doc;
    }).toList();

    emit(state.copyWith(
      documents: updatedDocuments,
      status: FormzSubmissionStatus.inProgress,
      error: null,
      isRetrying: true,
    ));
  }

  void _onUploadDeleted(
    DocumentUploadDeleted event,
    Emitter<DocumentUploadState> emit,
  ) {
    final updatedDocuments = state.documents.map((doc) {
      if (doc.type == event.type) {
        return doc.copyWith(
          status: local_models.DocumentStatus.pending,
          frontImagePath: null,
          backImagePath: null,
          fileName: null,
          fileSize: null,
          uploadProgress: 0.0,
          uploadedAt: null,
          rejectionReason: null,
        );
      }
      return doc;
    }).toList();

    emit(state.copyWith(
      documents: updatedDocuments,
      status: FormzSubmissionStatus.initial,
    ));
  }

  Future<void> _onSubmitted(
    DocumentUploadSubmitted event,
    Emitter<DocumentUploadState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress, error: null));

    try {
      // Submit all uploaded documents for verification
      final uploadedDocs = state.documents.where((doc) => doc.isUploaded).toList();
      
      for (final doc in uploadedDocs) {
        if (doc.type.requiresBothSides && doc.frontImagePath != null && doc.backImagePath != null) {
          // Upload both front and back images
          final response = await documentsRepo.uploadDocumentWithBothSides(
            type: _convertToRepoDocumentType(doc.type),
            frontImagePath: doc.frontImagePath!,
            backImagePath: doc.backImagePath!,
            fileName: doc.fileName,
            fileSize: doc.fileSize,
            metadata: {'uploadedAt': doc.uploadedAt?.toIso8601String()},
          );
          
          if (!response.success) {
            final error = UploadFailedError(
              message: response.message ?? 'Failed to upload ${doc.title}',
              retryable: true,
            );
            emit(state.copyWith(
              status: FormzSubmissionStatus.failure,
              error: error,
            ));
            return;
          }
        } else if (doc.frontImagePath != null) {
          // Upload single image
          final request = documents_repo.DocumentUploadRequest(
            type: _convertToRepoDocumentType(doc.type),
            filePath: doc.frontImagePath!,
            fileName: doc.fileName,
            fileSize: doc.fileSize,
            metadata: {'uploadedAt': doc.uploadedAt?.toIso8601String()},
            isBackImage: false,
          );

          final response = await documentsRepo.uploadDocument(request);
          if (!response.success) {
            final error = UploadFailedError(
              message: response.message ?? 'Failed to upload ${doc.title}',
              retryable: true,
            );
            emit(state.copyWith(
              status: FormzSubmissionStatus.failure,
              error: error,
            ));
            return;
          }
        }
      }

      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } catch (e) {
      final error = DocumentUploadErrorHandler.handleException(e);
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        error: error,
      ));
    }
  }

  Future<void> _onStatusRefreshed(
    DocumentUploadStatusRefreshed event,
    Emitter<DocumentUploadState> emit,
  ) async {
    try {
      final response = await documentsRepo.getDocuments();
      if (response.success && response.documents != null) {
        // Update document statuses based on server response
        final updatedDocuments = state.documents.map((localDoc) {
          try {
            final serverDoc = response.documents!.firstWhere(
              (doc) => doc.type.value == localDoc.type.value,
            );
            return localDoc.copyWith(
              status: _convertDocumentStatus(serverDoc.status),
              rejectionReason: serverDoc.rejectedReason,
              verifiedAt: serverDoc.verifiedAt,
            );
          } catch (e) {
            return localDoc;
          }
        }).toList();

        emit(state.copyWith(documents: updatedDocuments, error: null));
      }
    } catch (e) {
      final error = DocumentUploadErrorHandler.handleException(e);
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        error: error,
      ));
    }
  }

  void _onRecommendedNextChanged(
    DocumentUploadRecommendedNextChanged event,
    Emitter<DocumentUploadState> emit,
  ) {
    final updatedDocuments = state.documents.map((doc) {
      if (doc.type == event.type) {
        return doc.copyWith(isRecommendedNext: event.isRecommended);
      }
      return doc;
    }).toList();

    emit(state.copyWith(documents: updatedDocuments));
  }

  List<DocumentUpload> _createDefaultDocuments() {
    return local_models.DocumentType.values.map((type) {
      return DocumentUpload(
        type: type,
        title: type.displayName,
        description: type.description,
        isRequired: type.isRequired,
      );
    }).toList();
  }

  /// Convert local DocumentType to documents_repo DocumentType
  documents_repo.DocumentType _convertToRepoDocumentType(local_models.DocumentType localType) {
    switch (localType) {
      case local_models.DocumentType.drivingLicense:
        return documents_repo.DocumentType.drivingLicense;
      case local_models.DocumentType.registrationCertificate:
        return documents_repo.DocumentType.rcBook;
      case local_models.DocumentType.vehicleInsurance:
        return documents_repo.DocumentType.insurance;
      case local_models.DocumentType.profilePicture:
        return documents_repo.DocumentType.profilePicture;
      case local_models.DocumentType.aadhaarCard:
        return documents_repo.DocumentType.aadhaar;
      case local_models.DocumentType.panCard:
        return documents_repo.DocumentType.pan;
      case local_models.DocumentType.addressProof:
        return documents_repo.DocumentType.addressProof;
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
