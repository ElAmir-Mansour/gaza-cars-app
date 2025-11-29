import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/cars/presentation/pages/add_car_page.dart';
import '../../features/cars/presentation/pages/car_details_page.dart';
import '../../features/cars/presentation/pages/edit_car_page.dart';
import '../../features/cars/presentation/pages/favorites_page.dart';
import '../../features/cars/presentation/pages/my_listings_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/cars/domain/entities/car_entity.dart';
import '../../features/chat/presentation/pages/chat_list_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/auth/presentation/pages/complete_profile_page.dart';
import '../../features/settings/presentation/pages/privacy_policy_page.dart';
import '../../features/settings/presentation/pages/about_page.dart';

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/complete-profile',
      builder: (context, state) => const CompleteProfilePage(),
    ),
    GoRoute(
      path: '/add-car',
      builder: (context, state) => const AddCarPage(),
    ),
    GoRoute(
      path: '/car-details',
      name: 'car_details',
      builder: (context, state) {
        debugPrint('📍 Navigating to /car-details');
        if (state.extra == null) {
          print('❌ Error: state.extra is null');
          return const Scaffold(body: Center(child: Text('Error: No car data passed')));
        }
        final car = state.extra as CarEntity;
        print('📦 Received car: ${car.make} ${car.model}');
        return CarDetailsPage(car: car);
      },
    ),
    GoRoute(
      path: '/my-listings',
      builder: (context, state) => const MyListingsPage(),
    ),
    GoRoute(
      path: '/favorites',
      builder: (context, state) => const FavoritesPage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/edit-car',
      builder: (context, state) {
        final car = state.extra as CarEntity;
        return EditCarPage(car: car);
      },
    ),
    GoRoute(
      path: '/chats',
      builder: (context, state) => const ChatListPage(),
    ),
    GoRoute(
      path: '/chat/:id',
      builder: (context, state) {
        final chatId = state.pathParameters['id']!;
        final extra = state.extra as Map<String, dynamic>?;
        final title = extra?['title'] as String?;
        final otherUserId = extra?['otherUserId'] as String?;
        return ChatPage(chatId: chatId, title: title, otherUserId: otherUserId);
      },
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardPage(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: '/profile/edit',
      builder: (context, state) => const EditProfilePage(),
    ),
    GoRoute(
      path: '/privacy-policy',
      builder: (context, state) => const PrivacyPolicyPage(),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutPage(),
    ),
  ],
  errorBuilder: (context, state) {
    debugPrint('❌ Router Error: ${state.error}');
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 50),
            const SizedBox(height: 16),
            Text('Page Not Found: ${state.uri.toString()}'),
            const SizedBox(height: 8),
            Text('Error: ${state.error}'),
          ],
        ),
      ),
    );
  },
);
