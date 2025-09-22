import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';
import 'package:documents_repo/documents_repo.dart';

part 'document_event.dart';
part 'document_state.dart';

class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  DocumentBloc({required this.documentsRepo}) : super(const DocumentState()) {
    on<DocumentsLoaded>(_onDocumentsLoaded);
    on<DocumentSelected>(_onDocumentSelected);
    on<DocumentUploaded>(_onDocumentUploaded);
    on<DocumentDeleted>(_onDocumentDeleted);
    on<DocumentRetryUpload>(_onDocumentRetryUpload);
    on<DocumentStatusRefreshed>(_onDocumentStatusRefreshed);
  }

  final DocumentsRepo documentsRepo;

  Future<void> _onDocumentsLoaded(
    DocumentsLoaded event,
    Emitter<DocumentState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      // Get documents from repository
      final response = await documentsRepo.getDocuments();
      
      if (response.success && response.documents != null) {
        // Group documents by type
        final driverDocuments = response.documents!
            .where((doc) => _isDriverDocument(doc.type))
            .toList();
        final vehicleDocuments = response.documents!
            .where((doc) => _isVehicleDocument(doc.type))
            .toList();

        emit(state.copyWith(
          driverDocuments: driverDocuments,
          vehicleDocuments: vehicleDocuments,
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: response.message ?? 'Failed to load documents',
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Network error: ${error.toString()}',
      ));
    }
  }

  void _onDocumentSelected(
    DocumentSelected event,
    Emitter<DocumentState> emit,
  ) {
    emit(state.copyWith(
      selectedDocument: event.document,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  Future<void> _onDocumentUploaded(
    DocumentUploaded event,
    Emitter<DocumentState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      final request = DocumentUploadRequest(
        type: event.documentType,
        filePath: event.filePath,
        fileName: event.fileName,
        metadata: event.metadata,
      );

      final response = await documentsRepo.uploadDocument(request);
      
      if (response.success) {
        // Refresh documents after successful upload
        add(const DocumentsLoaded());
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: response.message ?? 'Failed to upload document',
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Upload error: ${error.toString()}',
      ));
    }
  }

  Future<void> _onDocumentDeleted(
    DocumentDeleted event,
    Emitter<DocumentState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      final response = await documentsRepo.deleteDocument(event.documentId);
      
      if (response.success) {
        // Refresh documents after successful deletion
        add(const DocumentsLoaded());
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: response.message ?? 'Failed to delete document',
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Delete error: ${error.toString()}',
      ));
    }
  }

  Future<void> _onDocumentRetryUpload(
    DocumentRetryUpload event,
    Emitter<DocumentState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      final request = DocumentUploadRequest(
        type: event.documentType,
        filePath: event.filePath,
        fileName: event.fileName,
        metadata: event.metadata,
      );

      final response = await documentsRepo.uploadDocument(request);
      
      if (response.success) {
        // Refresh documents after successful retry
        add(const DocumentsLoaded());
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: response.message ?? 'Failed to retry upload',
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Retry error: ${error.toString()}',
      ));
    }
  }

  Future<void> _onDocumentStatusRefreshed(
    DocumentStatusRefreshed event,
    Emitter<DocumentState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      // Refresh documents to get latest status
      add(const DocumentsLoaded());
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Refresh error: ${error.toString()}',
      ));
    }
  }

  bool _isDriverDocument(DocumentType type) {
    return type == DocumentType.drivingLicense ||
           type == DocumentType.aadhaar ||
           type == DocumentType.pan ||
           type == DocumentType.addressProof;
  }

  bool _isVehicleDocument(DocumentType type) {
    return type == DocumentType.rcBook ||
           type == DocumentType.insurance;
  }
}