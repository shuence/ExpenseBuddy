import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/responsive_constants.dart';
import 'package:go_router/go_router.dart';
import '../../../router/routes.dart';
import '../../../services/shared_prefs_service.dart';
import '../../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();

    // Trigger authentication check after animation completes
    Future.delayed(const Duration(milliseconds: 3000), () async {
      if (mounted) {
        context.read<AuthBloc>().add(AuthCheckRequested());
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _navigateBasedOnState(AuthState state) async {
    if (!mounted) return;
    
    try {
      if (state is Authenticated) {
        // User is authenticated and has preferences, go to home
        context.go(AppRoutes.home);
      } else if (state is AuthenticatedButNoPreferences) {
        // User is authenticated but needs to set preferences
        context.go(AppRoutes.userPreferences);
      } else if (state is UnAuthenticated) {
        // User is not authenticated, check if first launch
        final sp = await SharedPrefsService.getInstance();
        final isFirst = sp.isFirstLaunch();
        
        if (isFirst) {
          context.go(AppRoutes.onboardingPage1);
        } else {
          context.go(AppRoutes.login);
        }
      } else if (state is AuthError) {
        // Auth error, go to login
        debugPrint('Auth error: ${state.message}');
        context.go(AppRoutes.login);
      }
      // For AuthInitial and AuthLoading, stay on splash screen
    } catch (e) {
      debugPrint('Navigation error: $e');
      // Fallback navigation
      if (mounted) context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        _navigateBasedOnState(state);
      },
      child: CupertinoPageScaffold(
        backgroundColor: AppTheme.getBackgroundColor(Brightness.light),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveConstants.spacing24,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Main App Icon with Animation
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Image.asset(
                            'assets/images/splash_screen.png',
                            width: ResponsiveConstants.containerHeight280,
                            height: ResponsiveConstants.containerHeight312,
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: ResponsiveConstants.spacing32),

                  // App Name
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      AppConstants.appName,
                      style: TextStyle(
                        fontSize: ResponsiveConstants.fontSize32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getTextPrimaryColor(Brightness.light),
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  SizedBox(height: ResponsiveConstants.spacing16),

                  // Tagline
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveConstants.spacing40,
                      ),
                      child: Text(
                        'Smart expense tracking for your financial freedom',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: ResponsiveConstants.fontSize16,
                          fontWeight: FontWeight.normal,
                          color: AppTheme.getTextSecondaryColor(Brightness.light),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: ResponsiveConstants.spacing48),

                  // Loading Indicator
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: CupertinoActivityIndicator(
                      color: AppTheme.getPrimaryColor(Brightness.light),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
