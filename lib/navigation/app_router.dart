import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/map/screens/map_screen.dart';
import '../features/reports/screens/reports_screen.dart';
import '../features/reports/screens/report_detail_screen.dart';
import '../features/reports/screens/submit_report_screen.dart';
import '../features/donations/screens/donation_screen.dart';
import '../features/donations/screens/my_donations_screen.dart';
import '../features/donations/screens/donation_success_screen.dart';
import '../features/leaderboard/screens/leaderboard_screen.dart';
import '../features/about/screens/about_screen.dart';
import '../features/admin/screens/admin_dashboard_screen.dart';
import '../features/admin/screens/admin_reports_screen.dart';
import '../features/admin/screens/admin_donations_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import 'shell_navigation.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

GoRouter buildRouter(AuthProvider auth) => GoRouter(
      navigatorKey: _rootKey,
      initialLocation: '/',
      redirect: (context, state) {
        final isAuth  = auth.status == AuthStatus.authenticated;
        final isUnauth= auth.status == AuthStatus.unauthenticated;
        final protectedPaths = [
          '/submit-report', '/my-donations', '/profile', '/admin',
        ];
        final isProtected = protectedPaths.any((p) => state.matchedLocation.startsWith(p));

        if (isUnauth && isProtected) return '/login';
        if (isAuth && (state.matchedLocation == '/login' ||
            state.matchedLocation == '/register')) return '/';
        return null;
      },
      routes: [
        ShellRoute(
          navigatorKey: _shellKey,
          builder: (context, state, child) => ShellNavigation(child: child),
          routes: [
            GoRoute(path: '/',           builder: (c, s) => const HomeScreen()),
            GoRoute(path: '/map',        builder: (c, s) => const MapScreen()),
            GoRoute(path: '/donate',     builder: (c, s) => const DonationScreen()),
            GoRoute(path: '/leaderboard',builder: (c, s) => const LeaderboardScreen()),
            GoRoute(path: '/about',      builder: (c, s) => const AboutScreen()),
            GoRoute(path: '/profile',    builder: (c, s) => const ProfileScreen()),
          ],
        ),
        GoRoute(path: '/login',          builder: (c, s) => const LoginScreen()),
        GoRoute(path: '/register',       builder: (c, s) => const RegisterScreen()),
        GoRoute(path: '/reports',        builder: (c, s) => const ReportsScreen()),
        GoRoute(path: '/reports/:id',    builder: (c, s) =>
            ReportDetailScreen(id: int.parse(s.pathParameters['id']!))),
        GoRoute(path: '/submit-report',  builder: (c, s) => const SubmitReportScreen()),
        GoRoute(path: '/my-donations',   builder: (c, s) => const MyDonationsScreen()),
        GoRoute(path: '/donation/success', builder: (c, s) =>
            DonationSuccessScreen(donationId: int.tryParse(s.uri.queryParameters['donation_id'] ?? ''))),
        GoRoute(path: '/admin', builder: (c, s) => const AdminDashboardScreen(),
          routes: [
            GoRoute(path: 'reports',   builder: (c, s) => const AdminReportsScreen()),
            GoRoute(path: 'donations', builder: (c, s) => const AdminDonationsScreen()),
          ],
        ),
      ],
    );
