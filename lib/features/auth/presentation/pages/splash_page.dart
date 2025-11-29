import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _startSplash();
  }

  Future<void> _startSplash() async {
    // Wait for minimum 2 seconds AND for auth status to be determined
    await Future.wait([
      Future.delayed(const Duration(seconds: 2)),
      _waitForAuth(),
    ]);

    if (!mounted) return;

    // Check if we already navigated to onboarding
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    if (!hasSeenOnboarding) return;

    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      context.go('/');
    } else {
      context.go('/login');
    }
  }

  Future<void> _waitForAuth() async {
    // Check onboarding status first
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    if (!hasSeenOnboarding) {
      if (mounted) context.go('/onboarding');
      return;
    }

    final authBloc = context.read<AuthBloc>();
    // If already determined, return immediately
    if (authBloc.state is AuthAuthenticated || authBloc.state is AuthUnauthenticated || authBloc.state is AuthError) {
      return;
    }
    
    // Wait for a state change that indicates completion
    await authBloc.stream.firstWhere((state) => 
      state is AuthAuthenticated || state is AuthUnauthenticated || state is AuthError
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Icon(
              Icons.directions_car_filled,
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Gaza Cars',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
