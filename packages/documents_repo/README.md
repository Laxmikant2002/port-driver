# Documents Repository

A Flutter package for managing driver documents in the driver app.

## Features

- Upload driver documents (Driving License, RC Book, Insurance, Aadhaar, PAN)
- Track document verification status
- Manage document metadata
- Check document verification completeness

## Models

### DriverDocument
Represents a driver document with verification status.

```dart
final document = DriverDocument(
  id: '1',
  type: DocumentType.drivingLicense,
  status: DocumentStatus.verified,
  fileUrl: 'https://example.com/doc.pdf',
  fileName: 'license.pdf',
);
```

### DocumentUploadRequest
Request model for uploading documents.

```dart
final request = DocumentUploadRequest(
  type: DocumentType.drivingLicense,
  filePath: '/path/to/file.pdf',
  fileName: 'license.pdf',
);
```

### DocumentResponse
Response model for document operations.

```dart
final response = DocumentResponse(
  success: true,
  document: document,
  message: 'Document uploaded successfully',
);
```

## Usage

### Initialize the repository

```dart
final documentsRepo = DocumentsRepo(
  apiClient: apiClient,
  localStorage: localStorage,
);
```

### Upload a document

```dart
final request = DocumentUploadRequest(
  type: DocumentType.drivingLicense,
  filePath: '/path/to/file.pdf',
  fileName: 'license.pdf',
);

final response = await documentsRepo.uploadDocument(request);
if (response.success) {
  print('Document uploaded successfully');
}
```

### Get all documents

```dart
final response = await documentsRepo.getDocuments();
if (response.success) {
  final documents = response.documents;
  // Process documents
}
```

### Check if all documents are verified

```dart
final allVerified = await documentsRepo.areAllDocumentsVerified();
if (allVerified) {
  print('All required documents are verified');
}
```

### Get document status summary

```dart
final statusMap = await documentsRepo.getDocumentStatusSummary();
print('Driving License: ${statusMap[DocumentType.drivingLicense]}');
```

## Document Types

- `drivingLicense` - Driving License
- `rcBook` - RC Book
- `insurance` - Insurance
- `aadhaar` - Aadhaar
- `pan` - PAN Card
- `addressProof` - Address Proof

## Document Status

- `pending` - Pending verification
- `verified` - Verified by admin
- `rejected` - Rejected by admin
- `expired` - Document expired

## Dependencies

- `api_client` - For API communication
- `localstorage` - For local storage
- `equatable` - For value equality