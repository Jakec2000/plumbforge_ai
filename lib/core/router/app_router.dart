import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/intake/presentation/screens/splash_screen.dart';
import '../../features/intake/presentation/screens/home_screen.dart';
import '../../features/intake/presentation/screens/new_job_intake_screen.dart';
import '../../features/intake/presentation/screens/ar_camera_screen.dart';
import '../../features/quoting/presentation/screens/quote_preview_screen.dart';
import '../../features/pricing/domain/models/quote_item.dart';
import '../../features/ai_takeoff/domain/models/takeoff_result.dart';
import '../../features/scheduling/presentation/screens/ai_routing_dashboard.dart';
import '../../features/pricing/presentation/screens/supplier_integrations_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/home';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/intake',
        name: 'intake',
        builder: (context, state) => const NewJobIntakeScreen(),
      ),
      GoRoute(
        path: '/ar-camera',
        name: 'ar-camera',
        builder: (context, state) => const ArCameraScreen(),
      ),
      GoRoute(
        path: '/routing',
        name: 'routing',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('AI Routing')),
          body: const AiRoutingDashboard(),
        ),
      ),
      GoRoute(
        path: '/integrations',
        name: 'integrations',
        builder: (context, state) => const SupplierIntegrationsScreen(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: '/quote-preview',
        name: 'quote-preview',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          return QuotePreviewScreen(
            quoteSummary: extras['summary'] as QuoteSummary,
            takeoffResult: extras['result'] as TakeoffResult,
          );
        },
      ),
    ],
  );
});
