import 'package:flutter/material.dart';
import 'package:documents_repo/documents_repo.dart';
import '../screens/account/documents/views/documents_list_screen.dart';
import '../screens/account/documents/views/document_detail_screen.dart';

/// {@template document_routes}
/// Routes for active driver document management.
/// {@endtemplate}
class DocumentRoutes {
  /// Route for the documents list screen (for active drivers).
  static const String documentsList = '/documents-list';
  
  /// Route for individual document detail and re-upload screen.
  static const String documentDetail = '/document-detail';

  /// Returns all routes for document management.
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      documentsList: (context) {
        final documentsRepo = context.read<DocumentsRepo>();
        return DocumentsListScreen(documentsRepo: documentsRepo);
      },
      documentDetail: (context) {
        final documentsRepo = context.read<DocumentsRepo>();
        final documentId = ModalRoute.of(context)?.settings.arguments as String?;
        if (documentId == null) {
          return const Scaffold(
            body: Center(
              child: Text('Invalid document ID'),
            ),
          );
        }
        return DocumentDetailScreen(
          documentsRepo: documentsRepo,
          documentId: documentId,
        );
      },
    };
  }
}
