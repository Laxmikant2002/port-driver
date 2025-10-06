import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:driver/locator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  // Set to true only when you need to debug specific BLoC issues
  static const bool _enableBlocLogging = false;

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    
    // Only log when explicitly enabled
    if (_enableBlocLogging) {
      log('onChange(${bloc.runtimeType}, $change)');
    }
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    // Always log errors
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  // Enhanced error handling with Firebase Crashlytics
  FlutterError.onError = (details) {
    log('Flutter Error: ${details.exceptionAsString()}', stackTrace: details.stack);
    
    // Send to Firebase Crashlytics in production
    if (kReleaseMode) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    }
  };

  // Handle platform errors with Firebase Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    log('Platform Error: $error', stackTrace: stack);
    
    // Send to Firebase Crashlytics in production
    if (kReleaseMode) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
    return true;
  };

  Bloc.observer = const AppBlocObserver();

  // Initialize Flutter binding
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Firebase Crashlytics
  if (kReleaseMode) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  }
  
  // Initialize dependencies with proper error handling
  try {
    await initializeDependencies();
    log('Dependencies initialized successfully');
  } catch (e, stackTrace) {
    log('Failed to initialize dependencies: $e', stackTrace: stackTrace);
    // Handle initialization failure gracefully
    rethrow;
  }

  runApp(await builder());
}
