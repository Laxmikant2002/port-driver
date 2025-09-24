import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';
import 'package:documents_repo/documents_repo.dart';
import '../../../models/document_upload.dart';

part 'document_upload_event.dart';
part 'document_upload_state.dart';

/// {@template document_upload_bloc}
/// A BLoC that manages the document upload flow for driver registration.
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
          status: DocumentStatus.uploading,
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
          status: DocumentStatus.uploaded,
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
    final updatedDocuments = state.documents.map((doc) {
      if (doc.type == event.type) {
        return doc.copyWith(
          status: DocumentStatus.pending,
          uploadProgress: 0.0,
          rejectionReason: event.error,
        );
      }
      return doc;
    }).toList();

    emit(state.copyWith(
      documents: updatedDocuments,
      status: FormzSubmissionStatus.failure,
      errorMessage: event.error,
    ));
  }

  void _onUploadRetried(
    DocumentUploadRetried event,
    Emitter<DocumentUploadState> emit,
  ) {
    final updatedDocuments = state.documents.map((doc) {
      if (doc.type == event.type) {
        return doc.copyWith(
          status: DocumentStatus.uploading,
          uploadProgress: 0.0,
          rejectionReason: null,
        );
      }
      return doc;
    }).toList();

    emit(state.copyWith(
      documents: updatedDocuments,
      status: FormzSubmissionStatus.inProgress,
      errorMessage: null,
    ));
  }

  void _onUploadDeleted(
    DocumentUploadDeleted event,
    Emitter<DocumentUploadState> emit,
  ) {
    final updatedDocuments = state.documents.map((doc) {
      if (doc.type == event.type) {
        return doc.copyWith(
          status: DocumentStatus.pending,
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
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      // Submit all uploaded documents for verification
      final uploadedDocs = state.documents.where((doc) => doc.isUploaded).toList();
      
      for (final doc in uploadedDocs) {
        if (doc.frontImagePath != null) {
          final request = DocumentUploadRequest(
            type: doc.type,
            filePath: doc.frontImagePath!,
            fileName: doc.fileName,
            fileSize: doc.fileSize,
          );

          final response = await documentsRepo.uploadDocument(request);
          if (!response.success) {
            emit(state.copyWith(
              status: FormzSubmissionStatus.failure,
              errorMessage: response.message ?? 'Failed to upload ${doc.title}',
            ));
            return;
          }
        }

        if (doc.backImagePath != null && doc.type.requiresBothSides) {
          final request = DocumentUploadRequest(
            type: doc.type,
            filePath: doc.backImagePath!,
            fileName: doc.fileName,
            fileSize: doc.fileSize,
          );

          final response = await documentsRepo.uploadDocument(request);
          if (!response.success) {
            emit(state.copyWith(
              status: FormzSubmissionStatus.failure,
              errorMessage: response.message ?? 'Failed to upload ${doc.title}',
            ));
            return;
          }
        }
      }

      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Network error: ${e.toString()}',
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
          final serverDoc = response.documents!.firstWhere(
            (doc) => doc.type.value == localDoc.type.value,
            orElse: () => null,
          );

          if (serverDoc != null) {
            return localDoc.copyWith(
              status: DocumentStatus.fromString(serverDoc.status.value),
              rejectionReason: serverDoc.rejectedReason,
              verifiedAt: serverDoc.verifiedAt,
            );
          }
          return localDoc;
        }).toList();

        emit(state.copyWith(documents: updatedDocuments));
      }
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Failed to refresh status: ${e.toString()}',
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
    return DocumentType.values.map((type) {
      return DocumentUpload(
        type: type,
        title: type.displayName,
        description: type.description,
        isRequired: type.isRequired,
      );
    }).toList();
  }
}
