import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:driver/screens/account/profile/view/profile_screen.dart' as AccountProfile;
import 'package:driver/screens/document_upload/views/document_upload_screen.dart';
import 'package:driver/screens/document_upload/views/document_intro_screen.dart';
import 'package:driver/screens/document_upload/views/document_review_screen.dart';
import 'package:driver/screens/account/documents/views/documents_list_screen.dart';
import 'package:driver/screens/account/documents/views/document_detail_screen.dart';
import 'package:driver/screens/account/documents/bloc/documents_bloc.dart';
import 'package:driver/screens/document_upload/bloc/document_upload_bloc.dart';
import 'package:driver/screens/account/help_support/views/help_support_screen.dart';
import 'package:driver/screens/account/trip_history/views/trip_history_screen.dart';
import 'package:driver/screens/setting_section/settings/view/settings_screen.dart';
import 'package:driver/screens/setting_section/settings/views/about.dart';
import 'package:driver/screens/setting_section/notification_settings/view/notification_settings_screen.dart';
import 'package:driver/screens/setting_section/privacy/view/privacy_screen.dart';
import 'package:driver/screens/setting_section/support/view/support_screen.dart';
import 'package:driver/screens/setting_section/faq/view/faq_screen.dart';
import 'package:driver/screens/account_status/account_suspended_screen.dart';
import 'package:driver/screens/account_status/account_inactive_screen.dart';
import 'package:driver/models/document_upload.dart' as local_models;
import 'package:driver/locator.dart';
import 'package:history_repo/history_repo.dart';
import 'package:documents_repo/documents_repo.dart';
import 'package:auth_repo/auth_repo.dart';
import 'route_constants.dart';

/// Account management routes for profile, documents, history, settings, and support
class AccountRoutes {
  // Route constants
  static const String profile = RouteConstants.profile;

  // Document routes
  static const String documentsList = RouteConstants.documentsList;
  static const String documentDetail = RouteConstants.documentDetail;
  static const String accountDocuments = RouteConstants.accountDocuments;
  static const String documentIntro = RouteConstants.documentIntro;
  static const String documentUpload = RouteConstants.documentUpload;
  static const String documentReview = RouteConstants.documentReview;

  // History routes
  static const String ridesHistory = RouteConstants.ridesHistory;
  static const String tripHistory = RouteConstants.tripHistory;
  static const String ratings = RouteConstants.ratings;

  // Finance routes
  static const String wallet = RouteConstants.wallet;
  static const String earnings = RouteConstants.earnings;
  static const String transactionHistory = RouteConstants.transactionHistory;
  static const String earningsSummary = RouteConstants.earningsSummary;

  // Rewards routes
  static const String rewards = RouteConstants.rewards;
  static const String achievements = RouteConstants.achievements;
  static const String challenges = RouteConstants.challenges;
  static const String leaderboard = RouteConstants.leaderboard;

  // Settings routes
  static const String settings = RouteConstants.settings;
  static const String privacy = RouteConstants.privacy;
  static const String support = RouteConstants.support;
  static const String about = RouteConstants.about;
  static const String termsOfService = RouteConstants.termsOfService;
  static const String privacyPolicy = RouteConstants.privacyPolicy;

  // Notification routes
  static const String notificationSettings = RouteConstants.notificationSettings;
  static const String bookingNotifications = RouteConstants.bookingNotifications;
  static const String earningsNotifications = RouteConstants.earningsNotifications;
  static const String systemNotifications = RouteConstants.systemNotifications;

  // Help support routes
  static const String helpSupport = RouteConstants.helpSupport;
  static const String faq = RouteConstants.faq;
  static const String contactUs = RouteConstants.contactUs;
  static const String emergency = RouteConstants.emergency;

  // Account status routes
  static const String accountSuspended = RouteConstants.accountSuspended;
  static const String accountInactive = RouteConstants.accountInactive;

  /// Returns all account-related routes
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      // Profile routes (onboarding routes are now in AuthRoutes)
      profile: (context) => const AccountProfile.ProfileScreen(phoneNumber: '+1234567890'),

      // Document routes
      accountDocuments: (context) {
        return BlocProvider(
          create: (_) => DocumentsBloc(documentsRepo: lc<DocumentsRepo>())
            ..add(const DocumentsLoaded()),
          child: const DocumentsListScreen(),
        );
      },
      documentsList: (context) {
        return BlocProvider(
          create: (_) => DocumentsBloc(documentsRepo: lc<DocumentsRepo>())
            ..add(const DocumentsLoaded()),
          child: const DocumentsListScreen(),
        );
      },
      documentDetail: (context) {
        final documentId = ModalRoute.of(context)?.settings.arguments as String?;
        if (documentId == null) {
          return const Scaffold(
            body: Center(
              child: Text('Invalid document ID'),
            ),
          );
        }
        return BlocProvider(
          create: (_) => DocumentsBloc(documentsRepo: lc<DocumentsRepo>())
            ..add(const DocumentsLoaded()),
          child: DocumentDetailScreen(documentId: documentId),
        );
      },
      documentIntro: (context) {
        return BlocProvider(
          create: (_) => DocumentsBloc(documentsRepo: lc<DocumentsRepo>()),
          child: const DocumentIntroScreen(),
        );
      },
      documentUpload: (context) {
        final documentType = ModalRoute.of(context)?.settings.arguments as local_models.DocumentType?;
        if (documentType == null) {
          return const Scaffold(
            body: Center(
              child: Text('Invalid document type'),
            ),
          );
        }
        return BlocProvider(
          create: (_) => DocumentUploadBloc(documentsRepo: lc<DocumentsRepo>())
            ..add(const DocumentUploadInitialized()),
          child: DocumentUploadScreen(documentType: documentType),
        );
      },
      documentReview: (context) {
        return BlocProvider(
          create: (_) => DocumentsBloc(documentsRepo: lc<DocumentsRepo>()),
          child: const DocumentReviewScreen(),
        );
      },

      // History routes
      ridesHistory: (context) {
        return const Scaffold(
          body: Center(
            child: Text('Rides History Screen - Implementation needed'),
          ),
        );
      },
      tripHistory: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final driverId = args?['driverId'] as String? ?? 
                        lc<AuthRepo>().currentUser?.id ?? '';
        
        return TripHistoryScreen(
          historyRepo: lc<HistoryRepo>(),
          driverId: driverId,
        );
      },
      ratings: (context) {
        return const Scaffold(
          body: Center(
            child: Text('Ratings Screen - Implementation needed'),
          ),
        );
      },

      // Finance routes
      wallet: (context) {
        return const Scaffold(
          body: Center(
            child: Text('Wallet Screen - Implementation needed'),
          ),
        );
      },
      earnings: (context) {
        return const Scaffold(
          body: Center(
            child: Text('Earnings - Full screen implementation needed'),
          ),
        );
      },
      transactionHistory: (context) {
        return const Scaffold(
          body: Center(
            child: Text('Transaction History - Full screen implementation needed'),
          ),
        );
      },
      earningsSummary: (context) {
        return const Scaffold(
          body: Center(
            child: Text('Earnings Summary - Full screen implementation needed'),
          ),
        );
      },

      // Rewards routes
      rewards: (context) {
        return const Scaffold(
          body: Center(
            child: Text('Rewards Screen - Implementation needed with rewardsRepo'),
          ),
        );
      },
      achievements: (context) {
        return const Scaffold(
          body: Center(
            child: Text('Achievements Screen - Implementation needed with rewardsRepo'),
          ),
        );
      },
      challenges: (context) {
        return const Scaffold(
          body: Center(
            child: Text('Challenges Screen - Implementation needed with rewardsRepo'),
          ),
        );
      },
      leaderboard: (context) {
        return const Scaffold(
          body: Center(
            child: Text('Leaderboard - Full screen implementation needed'),
          ),
        );
      },

      // Settings routes
      settings: (context) => const SettingsScreen(),
      privacy: (context) => const PrivacyScreen(),
      support: (context) => const SupportScreen(),
      about: (context) => const AboutScreen(),
      termsOfService: (context) {
        return const Scaffold(
          body: Center(
            child: Text('Terms of Service - Full screen implementation needed'),
          ),
        );
      },
      privacyPolicy: (context) {
        return const Scaffold(
          body: Center(
            child: Text('Privacy Policy - Full screen implementation needed'),
          ),
        );
      },

      // Notification routes
      notificationSettings: (context) => const NotificationSettingsScreen(),
      bookingNotifications: (context) {
        return const Scaffold(
          body: Center(
            child: Text('Booking Notifications - Full screen implementation needed'),
          ),
        );
      },
      earningsNotifications: (context) {
        return const Scaffold(
          body: Center(
            child: Text('Earnings Notifications - Full screen implementation needed'),
          ),
        );
      },
      systemNotifications: (context) {
        return const Scaffold(
          body: Center(
            child: Text('System Notifications - Full screen implementation needed'),
          ),
        );
      },

      // Help support routes
      helpSupport: (context) => const HelpSupportScreen(),
      faq: (context) => const FaqScreen(),
      contactUs: (context) => const HelpSupportScreen(),
      emergency: (context) => const HelpSupportScreen(),

      // Account status routes
      accountSuspended: (context) {
        final profile = ModalRoute.of(context)?.settings.arguments;
        return AccountSuspendedScreen(profile: profile);
      },
      accountInactive: (context) {
        final profile = ModalRoute.of(context)?.settings.arguments;
        return AccountInactiveScreen(profile: profile);
      },
    };
  }
}
