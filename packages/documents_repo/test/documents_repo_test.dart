import 'package:flutter_test/flutter_test.dart';
import 'package:documents_repo/documents_repo.dart';

void main() {
  group('Document Model Tests', () {
    test('should create document from JSON', () {
      final json = {
        'id': '1',
        'type': 'driving_license',
        'status': 'verified',
        'fileUrl': 'https://example.com/doc.pdf',
        'fileName': 'license.pdf',
        'uploadedAt': '2023-01-01T00:00:00Z',
        'verifiedAt': '2023-01-02T00:00:00Z',
        'rejectedReason': null,
        'metadata': {'size': 1024},
      };

      final document = DriverDocument.fromJson(json);

      expect(document.id, '1');
      expect(document.type, DocumentType.drivingLicense);
      expect(document.status, DocumentStatus.verified);
      expect(document.frontImageUrl, 'https://example.com/doc.pdf');
      expect(document.fileName, 'license.pdf');
      expect(document.metadata, {'size': 1024});
    });

    test('should convert document to JSON', () {
      final document = DriverDocument(
        id: '1',
        type: DocumentType.drivingLicense,
        status: DocumentStatus.verified,
        frontImageUrl: 'https://example.com/doc.pdf',
        fileName: 'license.pdf',
        uploadedAt: DateTime.parse('2023-01-01T00:00:00Z'),
        verifiedAt: DateTime.parse('2023-01-02T00:00:00Z'),
        metadata: {'size': 1024},
      );

      final json = document.toJson();

      expect(json['id'], '1');
      expect(json['type'], 'driving_license');
      expect(json['status'], 'verified');
      expect(json['fileUrl'], 'https://example.com/doc.pdf');
      expect(json['fileName'], 'license.pdf');
      expect(json['metadata'], {'size': 1024});
    });
  });

  group('DocumentUploadRequest Tests', () {
    test('should create upload request', () {
      final request = DocumentUploadRequest(
        type: DocumentType.drivingLicense,
        filePath: '/path/to/file.pdf',
        fileName: 'license.pdf',
        metadata: {'size': 1024},
      );

      expect(request.type, DocumentType.drivingLicense);
      expect(request.filePath, '/path/to/file.pdf');
      expect(request.fileName, 'license.pdf');
      expect(request.metadata, {'size': 1024});
    });

    test('should convert to JSON', () {
      final request = DocumentUploadRequest(
        type: DocumentType.drivingLicense,
        filePath: '/path/to/file.pdf',
        fileName: 'license.pdf',
      );

      final json = request.toJson();

      expect(json['type'], 'driving_license');
      expect(json['fileName'], 'license.pdf');
    });
  });

  group('DocumentResponse Tests', () {
    test('should create response from JSON', () {
      final json = {
        'success': true,
        'document': {
          'id': '1',
          'type': 'driving_license',
          'status': 'verified',
        },
        'message': 'Document uploaded successfully',
      };

      final response = DocumentResponse.fromJson(json);

      expect(response.success, true);
      expect(response.document?.id, '1');
      expect(response.document?.type, DocumentType.drivingLicense);
      expect(response.message, 'Document uploaded successfully');
    });
  });
}