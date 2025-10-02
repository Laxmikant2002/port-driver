import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:driver/app/bloc/cubit/locale.dart';
import 'package:driver/app/bloc/auth_bloc.dart';
import 'package:driver/l10n/l10n.dart';
import 'package:driver/routes/app_routes.dart';
import 'package:driver/widgets/essentials/notification_handler.dart';
import 'package:driver/locator.dart';
import 'package:auth_repo/auth_repo.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LocaleCubit(),
        ),
        BlocProvider(
          create: (context) => AuthBloc(
            authRepo: lc<AuthRepo>(),
          ),
        ),
      ],
      child: const _App(),
    );
  }
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, state) {
        return NotificationHandler(
          child: MaterialApp(
            theme: ThemeData(
              appBarTheme: AppBarTheme(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              ),
              useMaterial3: true,
            ),
            routes: AppRoutes.getAllRoutes(),
            locale: state,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            initialRoute: '/',
          ),
        );
      },
    );
  }
}
