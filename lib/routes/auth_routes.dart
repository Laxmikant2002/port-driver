import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:auth_repo/auth_repo.dart';
import 'package:documents_repo/documents_repo.dart';
import 'package:profile_repo/profile_repo.dart';

import 'package:driver/locator.dart';
import 'package:driver/models/document_upload.dart' as local_models;
import 'package:driver/app/bloc/cubit/locale.dart';
import 'package:driver/screens/auth/auth_check_screen.dart';
import 'package:driver/screens/auth/language_selection/bloc/language_selection_bloc.dart';
import 'package:driver/screens/auth/language_selection/view/language_selection_screen.dart';
import 'package:driver/screens/auth/login/login.dart';
import 'package:driver/screens/auth/otp/view/otp_screen.dart';
import 'package:driver/screens/auth/profile/bloc/profile_bloc.dart';
import 'package:driver/screens/auth/profile/view/profile_screen.dart';
import 'package:driver/screens/auth/vehicle_selection/bloc/vehicle_bloc.dart';
import 'package:driver/screens/auth/vehicle_selection/view/vehicle_screen.dart';
import 'package:driver/screens/auth/work_location/bloc/work_bloc.dart';
import 'package:driver/screens/auth/work_location/view/work_screen.dart';
import 'package:driver/screens/document_upload/bloc/document_upload_bloc.dart';
import 'package:driver/screens/document_upload/views/document_upload_screen.dart';

import 'route_constants.dart';

/// Authentication routes for login, OTP, and onboarding flow
class AuthRoutes {
  // Route constants
  static const String login = RouteConstants.login;
  static const String otp = RouteConstants.otp;
  static const String profileCreation = RouteConstants.profileCreation;
  static const String languageSelection = RouteConstants.languageSelection;
  static const String vehicleSelection = RouteConstants.vehicleSelection;
  static const String workLocation = RouteConstants.workLocation;
  static const String documentUpload = RouteConstants.documentUpload;

  /// Returns all authentication and onboarding routes
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      // Authentication flow - AuthCheckScreen is now the initial route
      login: (context) => const AuthCheckScreen(),
      '/login': (context) => const LoginScreen(), // Direct login route
      otp: (context) => const OtpScreen(),
      
      // Onboarding flow
      profileCreation: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        if (args == null) {
          return const Scaffold(
            body: Center(
              child: Text('Invalid arguments for profile creation'),
            ),
          );
        }
        final user = args['user'] as AuthUser;
        final isNewUser = args['isNewUser'] as bool? ?? true;
        final existingProfile = args['profile'] as DriverProfile?;
        
        return BlocProvider(
          create: (context) => ProfileBloc(
            authRepo: sl<AuthRepo>(),
            profileRepo: sl<ProfileRepo>(),
            user: user,
            existingProfile: existingProfile,
            isNewUser: isNewUser,
          )..add(const ProfileInitialized()),
          child: const ProfileScreen(),
        );
      },
      
      languageSelection: (context) {
        return BlocProvider(
          create: (context) => LanguageSelectionBloc(
            localeCubit: context.read<LocaleCubit>(),
          )..add(const LanguageSelectionInitialized()),
          child: const LanguageSelectionScreen(),
        );
      },
      
      vehicleSelection: (context) {
        return BlocProvider(
          create: (context) => VehicleBloc(),
          child: const VehicleScreen(),
        );
      },
      
      workLocation: (context) {
        return BlocProvider(
          create: (context) => WorkBloc(),
          child: const WorkLocationPage(),
        );
      },
      
      documentUpload: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        if (args == null) {
          return const Scaffold(
            body: Center(
              child: Text('Invalid arguments for document upload'),
            ),
          );
        }
        final documentType = args['documentType'] as local_models.DocumentType;
        
        return BlocProvider(
          create: (context) => DocumentUploadBloc(
            documentsRepo: sl<DocumentsRepo>(),
          ),
          child: DocumentUploadScreen(documentType: documentType),
        );
      },
    };
  }
}
