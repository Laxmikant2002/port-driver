import 'dart:io';
import 'package:api_client/api_client.dart';
import 'package:dio/dio.dart';
import 'package:profile_repo/src/models/document_model.dart';
import 'package:profile_repo/src/models/driver_profile.dart';

class ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepository(this._apiClient);

  Future<DataState<DriverProfile>> getProfile() async {
    return await _apiClient.getReq('/driver/profile');
  }

  Future<DataState<DriverProfile>> updateProfile(Map<String, dynamic> data) async {
    return await _apiClient.putReq('/driver/profile', bodyJson: data);
  }

  Future<DataState<String>> uploadDocument(String type, File file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
      'type': type,
    });
    return await _apiClient.postReq('/driver/documents', bodyJson: formData);
  }

  Future<DataState<List<Document>>> getDocuments() async {
    final response = await _apiClient.getReq('/driver/documents');
    if (response is DataSuccess) {
      final documents = (response.data as List)
          .map((doc) => Document.fromJson(doc))
          .toList();
      return DataSuccess(documents);
    }
    return response as DataState<List<Document>>;
  }

  Future<DataState> uploadVerifiedDocument(DocumentVerificationRequest request) async {
    final formData = FormData.fromMap({
      'documentId': request.documentId,
      'file': await MultipartFile.fromFile(request.filePath),
      'fileType': request.fileType,
      'additionalData': request.additionalData,
    });

    final response = await _apiClient.postReq(
      '/driver/documents/upload',
      bodyJson: formData,
    );

    if (response is DataSuccess) {
      return DataSuccess(Document.fromJson(response.data));
    }
    return response;
  }

  Future<DataState> verifyDocument(String documentId) async {
    final response = await _apiClient.postReq(
      '/driver/documents/$documentId/verify',
    );

    if (response is DataSuccess) {
      return DataSuccess(DocumentVerificationResponse.fromJson(response.data));
    }
    return response;
  }
}