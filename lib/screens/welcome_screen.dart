import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../theme/responsive_layout.dart';
import '../theme/theme.dart';
import '../widgets/common/gradient_button.dart';

/// Portada de VINCÓ con la foto del usuario como fondo.
/// Sin barra de navegación: solo Crear cuenta / Ya tengo cuenta.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: theme.appBarTheme.systemOverlayStyle!,
        child: Stack(
          children: [
            // Foto del usuario a pantalla completa.
            const Positioned.fill(
              child: Image(
                image: AssetImage('assets/images/welcome_terrace.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            // Velo inferior para legibilidad de la tarjeta.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.05),
                      Colors.black.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.55),
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: ResponsiveLayout.constrain(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    // Solo los dos botones, directo sobre la planilla.
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingLg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GradientButton(
                            onPressed: () => context.push('/signup'),
                            label: 'Crear cuenta',
                            icon: Icons.person_add_outlined,
                          ),
                          const SizedBox(height: AppTheme.spacingSm),
                          Center(
                            child: SizedBox(
                              width: 260,
                              child: OutlinedButton.icon(
                                onPressed: () => context.push('/login'),
                                icon: const Icon(Icons.login_rounded),
                                label: const Text('Ya tengo cuenta'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingMd),
                        ],
                      ),
                    ),
                  ],
                ),
                maxWidth: AppTheme.maxCardWidth,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

