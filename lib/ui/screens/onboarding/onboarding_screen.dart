import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../providers/onboarding_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../router/routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    // Small delay to ensure widget is built
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    
    context.read<OnboardingBloc>().add(const LoadOnboardingStatus());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingLoaded) {
          if (state.hasSeenOnboarding) {
            context.go(AppRoutes.login);
          } else {
            // Navigate to first onboarding page
            context.go(AppRoutes.onboardingPage1);
          }
        }
      },
      child: const CupertinoPageScaffold(
        child: Center(
          child: CupertinoActivityIndicator(),
        ),
      ),
    );
  }
}
