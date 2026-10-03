import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/theme.dart';
import '../widgets/common/ambient_background.dart';
import '../widgets/common/state_view.dart';
import '../widgets/common/vinco_wordmark.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      body: AnnotatedRegion(
        value: theme.appBarTheme.systemOverlayStyle!,
        child: AmbientBackground(
          child: SafeArea(
            child: auth.status == AuthStatus.restoreFailed
                ? StateView(
                    icon: Icons.cloud_off_rounded,
                    title: 'No pudimos recuperar tu sesión',
                    message: auth.restoreError ?? '',
                    primaryLabel: 'Reintentar',
                    onPrimary: () => context.read<AuthProvider>().restore(),
                    secondaryLabel: 'Cerrar sesión',
                    onSecondary: () => context.read<AuthProvider>().discardStoredSession(),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(child: VincoWordmark()),
                      SizedBox(height: AppTheme.spacingXl),
                      LoadingView(message: 'Preparando VINCÓ…'),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
