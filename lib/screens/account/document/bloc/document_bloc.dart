import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';
import 'package:profile_repo/profile_repo.dart';

part 'document_event.dart';
part 'document_state.dart';

class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  DocumentBloc() : super(const DocumentState()) {
    on<LoadDocuments>(_onLoadDocuments);
    on<UploadDocument>(_onUploadDocument);
    on<DeleteDocument>(_onDeleteDocument);
    on<UpdateDocumentStatus>(_onUpdateDocumentStatus);
  }

  final List<Map<String, dynamic>> _mockDocuments = [
    {
      'id': '1',
      'type': 'driver',
      'title': 'Driver\'s License',
      'status': 'pending',
      'isRequired': true,
      'isNextStep': true,
      'expiryDate': '2024-12-31',
    },
    {
      'id': '2',
      'type': 'driver',
      'title': 'Police Verification',
      'status': 'not_uploaded',
      'isRequired': true,
      'isNextStep': false,
      'expiryDate': null,
    },
    {
      'id': '3',
      'type': 'driver',
      'title': 'Address Proof',
      'status': 'approved',
      'isRequired': true,
      'isNextStep': false,
      'expiryDate': '2025-06-30',
    },
    {
      'id': '4',
      'type': 'vehicle',
      'title': 'Vehicle Registration',
      'status': 'approved',
      'isRequired': true,
      'isNextStep': false,
      'expiryDate': '2025-03-15',
    },
    {
      'id': '5',
      'type': 'vehicle',
      'title': 'Insurance Certificate',
      'status': 'expired',
      'isRequired': true,
      'isNextStep': true,
      'expiryDate': '2024-01-01',
    },
    {
      'id': '6',
      'type': 'vehicle',
      'title': 'Fitness Certificate',
      'status': 'not_uploaded',
      'isRequired': false,
      'isNextStep': false,
      'expiryDate': null,
    },
  ];

  final Map<String, DocumentStatus> _mockStatuses = {
    'uan': DocumentStatus.notUploaded,
    'self_photo_id': DocumentStatus.notUploaded,
    'driving_license_front': DocumentStatus.approved,
    'aadhaar_front': DocumentStatus.approved,
    'aadhaar_back': DocumentStatus.approved,
    'profile_photo': DocumentStatus.approved,
    'registration_certificate': DocumentStatus.notUploaded,
    'vehicle_insurance': DocumentStatus.notUploaded,
    'fitness_certificate': DocumentStatus.notUploaded,
    'vehicle_permit': DocumentStatus.notUploaded,
  };

  Future<void> _onLoadDocuments(
    LoadDocuments event,
    Emitter<DocumentState> emit,
  ) async {
    try {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      emit(state.copyWith(
        documents: _mockDocuments,
        statuses: _mockStatuses,
        status: FormzSubmissionStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onUploadDocument(
    UploadDocument event,
    Emitter<DocumentState> emit,
  ) async {
    try {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

      final document = event.document;
      final updatedDocuments = List<Map<String, dynamic>>.from(state.documents);
      final updatedStatuses = Map<String, DocumentStatus>.from(state.statuses);

      final index = updatedDocuments.indexWhere((doc) => doc['id'] == document['id'] as String);
      if (index != -1) {
        updatedDocuments[index] = {
          ...document,
          'isUploaded': true,
          'status': DocumentStatus.pending,
        };
        updatedStatuses[document['id'] as String] = DocumentStatus.pending;
      }

      emit(state.copyWith(
        documents: updatedDocuments,
        statuses: updatedStatuses,
        status: FormzSubmissionStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteDocument(
    DeleteDocument event,
    Emitter<DocumentState> emit,
  ) async {
    try {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

      final updatedDocuments = List<Map<String, dynamic>>.from(state.documents);
      final updatedStatuses = Map<String, DocumentStatus>.from(state.statuses);

      final index = updatedDocuments.indexWhere((doc) => doc['id'] == event.documentId);
      if (index != -1) {
        updatedDocuments[index] = {
          ...updatedDocuments[index],
          'isUploaded': false,
          'status': DocumentStatus.notUploaded,
        };
        updatedStatuses[event.documentId] = DocumentStatus.notUploaded;
      }

      emit(state.copyWith(
        documents: updatedDocuments,
        statuses: updatedStatuses,
        status: FormzSubmissionStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateDocumentStatus(
    UpdateDocumentStatus event,
    Emitter<DocumentState> emit,
  ) async {
    try {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

      final updatedDocuments = List<Map<String, dynamic>>.from(state.documents);
      final updatedStatuses = Map<String, DocumentStatus>.from(state.statuses);

      final index = updatedDocuments.indexWhere((doc) => doc['id'] == event.documentId);
      if (index != -1) {
        updatedDocuments[index] = {
          ...updatedDocuments[index],
          'status': event.status,
        };
        updatedStatuses[event.documentId] = event.status;
      }

      emit(state.copyWith(
        documents: updatedDocuments,
        statuses: updatedStatuses,
        status: FormzSubmissionStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        error: e.toString(),
      ));
    }
  }
}