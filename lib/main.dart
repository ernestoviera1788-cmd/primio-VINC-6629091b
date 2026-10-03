import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'repositories/auth_repository.dart';
import 'repositories/match_repository.dart';
import 'repositories/me_repository.dart';
import 'repositories/notification_repository.dart';
import 'repositories/profile_repository.dart';
import 'router/app_router.dart';
import 'services/auth_service.dart';
import 'theme/theme.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthProvider _auth =
      AuthProvider(service: AuthService(repository: AuthRepository()))..restore();
  late final GoRouter _router = AppRouter.create(_auth);

  @override
  void dispose() {
    _router.dispose();
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => ProfileRepository(tokenProvider: () => _auth.token)),
        Provider(create: (_) => MeRepository(tokenProvider: () => _auth.token)),
        Provider(create: (_) => MatchRepository(tokenProvider: () => _auth.token)),
        Provider(create: (_) => NotificationRepository(tokenProvider: () => _auth.token)),
        ChangeNotifierProvider.value(value: _auth),
      ],
      child: MaterialApp.router(
        title: 'VINCÓ',
        routerConfig: _router,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        locale: const Locale('es'),
        supportedLocales: const [Locale('es'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}
