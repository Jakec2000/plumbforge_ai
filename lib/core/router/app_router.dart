import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/intake/presentation/screens/splash_screen.dart';
import '../../features/intake/presentation/screens/home_screen.dart';
import '../../features/intake/presentation/screens/new_job_intake_screen.dart';
import '../../features/intake/presentation/screens/ar_camera_screen.dart';
import '../../features/quoting/presentation/screens/quote_preview_screen.dart';
import '../../features/pricing/domain/models/quote_item.dart';
import '../../features/ai_takeoff/domain/models/takeoff_result.dart';
import '../../features/scheduling/presentation/screens/ai_routing_dashboard.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
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
