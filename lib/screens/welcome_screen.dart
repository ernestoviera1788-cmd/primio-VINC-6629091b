import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/responsive_layout.dart';
import '../theme/theme.dart';
import '../widgets/auth/onboarding_page.dart';
import '../widgets/common/ambient_background.dart';
import '../widgets/common/vinco_wordmark.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  static const _pages = [
    ('assets/images/onboarding_1.png', 'Desliza con intención', 'Ve perfiles reales a pantalla completa. A la derecha si te gusta, a la izquierda para otro día.'),
    ('assets/images/onboarding_2.png', 'Cuando es mutuo, hay vínculo', 'Si los dos se eligen, se enciende un vínculo y ya pueden conversar.'),
    ('assets/images/onboarding_3.png', 'Tu ritmo, tu privacidad', 'Tú decides qué mostrar y a quién conocer. Tus datos se quedan contigo.'),
  ];

  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce) {
      _controller.jumpToPage(page);
    } else {
      _controller.animateToPage(page, duration: const Duration(milliseconds: 380), curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isLast = _page == _pages.length - 1;

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: theme.appBarTheme.systemOverlayStyle!,
        child: AmbientBackground(
          child: SafeArea(
            child: ResponsiveLayout.constrain(
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppTheme.spacingLg, AppTheme.spacingSm, AppTheme.spacingSm, 0),
                    child: Row(
                      children: [
                        const VincoWordmark(),
                        const Spacer(),
                        if (!isLast) TextButton(onPressed: () => _goTo(_pages.length - 1), child: const Text('Saltar')),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: _pages.length,
                      onPageChanged: (i) => setState(() => _page = i),
                      itemBuilder: (_, i) => OnboardingPage(image: _pages[i].$1, title: _pages[i].$2, body: _pages[i].$3),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _pages.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXs),
                          width: i == _page ? AppTheme.spacingLg : AppTheme.spacingSm,
                          height: AppTheme.spacingSm,
                          decoration: BoxDecoration(
                            color: i == _page ? colors.primary : colors.outlineVariant,
                            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingLg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FilledButton(
                          onPressed: isLast ? () => context.push('/signup') : () => _goTo(_page + 1),
                          child: Text(isLast ? 'Crear cuenta' : 'Siguiente'),
                        ),
                        const SizedBox(height: AppTheme.spacingSm),
                        OutlinedButton(onPressed: () => context.push('/login'), child: const Text('Ya tengo cuenta')),
                        TextButton(
                          onPressed: () => context.read<AuthProvider>().continueAsGuest(),
                          child: const Text('Explorar como invitado'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              maxWidth: AppTheme.maxCardWidth,
            ),
          ),
        ),
      ),
    );
  }
}
