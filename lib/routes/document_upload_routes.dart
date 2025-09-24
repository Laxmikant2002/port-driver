import 'package:flutter/material.dart';
import 'package:documents_repo/documents_repo.dart';
import '../screens/document_upload/views/document_intro_screen.dart';
import '../screens/document_upload/views/document_upload_screen.dart';
import '../screens/document_upload/views/document_review_screen.dart';
import '../models/document_upload.dart';

/// {@template document_upload_routes}
/// Routes for the document upload flow.
/// {@endtemplate}
class DocumentUploadRoutes {
  /// Route for the document upload intro screen.
  static const String documentIntro = '/document-intro';
  
  /// Route for individual document upload screen.
  static const String documentUpload = '/document-upload';
  
  /// Route for document review and submit screen.
  static const String documentReview = '/document-review';

  /// Returns all routes for the document upload flow.
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      documentIntro: (context) {
        final documentsRepo = context.read<DocumentsRepo>();
        return DocumentIntroScreen(documentsRepo: documentsRepo);
      },
      documentUpload: (context) {
        final documentType = ModalRoute.of(context)?.settings.arguments as DocumentType?;
        if (documentType == null) {
          return const Scaffold(
            body: Center(
              child: Text('Invalid document type'),
            ),
          );
        }
        return DocumentUploadScreen(documentType: documentType);
      },
      documentReview: (context) {
        final documentsRepo = context.read<DocumentsRepo>();
        return DocumentReviewScreen(documentsRepo: documentsRepo);
      },
    };
  }
}
