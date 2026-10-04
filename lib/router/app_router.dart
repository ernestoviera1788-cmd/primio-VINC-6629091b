import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/discovery/discovery_provider.dart';
import '../providers/matches_provider.dart';
import '../providers/me_provider.dart';
import '../providers/notifications_provider.dart';
import '../repositories/match_repository.dart';
import '../repositories/me_repository.dart';
import '../repositories/notification_repository.dart';
import '../repositories/profile_repository.dart';
import '../screens/activity_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/conversations_screen.dart';
import '../screens/discover_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/full_profile_screen.dart';
import '../screens/login_screen.dart';
import '../screens/matches_screen.dart';
import '../screens/my_public_profile_screen.dart';
import '../screens/photos_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/welcome_screen.dart';
import '../services/discovery_service.dart';
import '../services/match_service.dart';
import '../services/me_service.dart';
import '../services/notification_service.dart';
import '../widgets/common/app_shell.dart';

class AppRouter {
  static const _authRoutes = {'/welcome', '/login', '/signup', '/forgot-password'};

  static GoRouter create(AuthProvider auth) => GoRouter(
        initialLocation: '/discover',
        refreshListenable: auth,
        redirect: (context, state) {
          final loc = state.matchedLocation;
          switch (auth.status) {
            case AuthStatus.restoring:
            case AuthStatus.restoreFailed:
              return loc == '/splash' ? null : '/splash';
            case AuthStatus.signedOut:
              return _authRoutes.contains(loc) ? null : '/welcome';
            case AuthStatus.guest:
            case AuthStatus.signedIn:
              return _authRoutes.contains(loc) || loc == '/splash' ? '/discover' : null;
          }
        },
        routes: [
          GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
          GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
          GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
          GoRoute(path: '/signup', builder: (_, _) => const SignupScreen()),
          GoRoute(path: '/forgot-password', builder: (_, _) => const ForgotPasswordScreen()),
          StatefulShellRoute.indexedStack(
            // Session-scoped state: recreated after every sign-in.
            builder: (context, state, navigationShell) {
              final profiles = context.read<ProfileRepository>();
              final me = context.read<MeRepository>();
              final matches = context.read<MatchRepository>();
              final notifications = context.read<NotificationRepository>();
              return MultiProvider(
                providers: [
                  ChangeNotifierProvider(
                    create: (_) => DiscoveryProvider(service: DiscoveryService(repository: profiles))..loadInitial(),
                  ),
                  ChangeNotifierProvider(create: (_) => MeProvider(service: MeService(repository: me))..load()),
                  Provider(create: (_) => MatchService(repository: matches)),
                  ChangeNotifierProvider(
                    create: (ctx) => MatchesProvider(service: ctx.read<MatchService>())..load(),
                  ),
                  ChangeNotifierProvider(
                    create: (_) => NotificationsProvider(service: NotificationService(repository: notifications))
                      ..load()
                      ..startPolling(),
                  ),
                ],
                child: AppShell(navigationShell: navigationShell),
              );
            },
            branches: [
              StatefulShellBranch(routes: [
                GoRoute(
                  path: '/discover',
                  builder: (_, _) => const DiscoverScreen(),
                  routes: [
                    GoRoute(
                      path: 'profile/:id',
                      builder: (_, state) => FullProfileScreen(profileId: state.pathParameters['id']!),
                    ),
                  ],
                ),
              ]),
              StatefulShellBranch(routes: [
                GoRoute(path: '/activity', builder: (_, _) => const ActivityScreen()),
              ]),
              StatefulShellBranch(routes: [
                GoRoute(path: '/matches', builder: (_, _) => const MatchesScreen()),
              ]),
              StatefulShellBranch(routes: [
                GoRoute(
                  path: '/messages',
                  builder: (_, _) => const ConversationsScreen(),
                  routes: [
                    GoRoute(
                      path: 'chat/:conversationId',
                      builder: (context, state) {
                        final id = state.pathParameters['conversationId']!;
                        return ChangeNotifierProvider(
                          create: (ctx) => ChatProvider(service: ctx.read<MatchService>(), conversationId: id)..start(),
                          child: ChatScreen(conversationId: id),
                        );
                      },
                    ),
                  ],
                ),
              ]),
              StatefulShellBranch(routes: [
                GoRoute(
                  path: '/profile',
                  builder: (_, _) => const ProfileScreen(),
                  routes: [
                    GoRoute(path: 'public', builder: (_, _) => const MyPublicProfileScreen()),
                    GoRoute(path: 'edit', builder: (_, _) => const EditProfileScreen()),
                    GoRoute(path: 'photos', builder: (_, _) => const PhotosScreen()),
                    GoRoute(path: 'settings', builder: (_, _) => const SettingsScreen()),
                  ],
                ),
              ]),
            ],
          ),
        ],
      );
}
