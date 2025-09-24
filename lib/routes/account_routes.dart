import 'package:flutter/material.dart';
import 'package:documents_repo/documents_repo.dart';
import '../screens/documents/views/documents_list_screen.dart';

/// {@template account_routes}
/// Routes for account-related screens.
/// {@endtemplate}
class AccountRoutes {
  /// Route for the documents list screen (for active drivers).
  static const String documents = '/account/documents';

  /// Returns all routes for account management.
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      documents: (context) {
        final documentsRepo = context.read<DocumentsRepo>();
        return DocumentsListScreen(documentsRepo: documentsRepo);
      },
    };
  }
}
