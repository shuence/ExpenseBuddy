import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/responsive_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/onboarding_model.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../router/routes.dart';
import '../../../services/shared_prefs_service.dart';
import 'widgets/onboarding_page_widget.dart';

class OnboardingPageScreen extends StatefulWidget {
  final int pageIndex;
  final OnboardingPage page;
  final bool isFirstPage;
  final bool isLastPage;

  const OnboardingPageScreen({
    super.key,
    required this.pageIndex,
    required this.page,
    required this.isFirstPage,
    required this.isLastPage,
  });

  @override
  State<OnboardingPageScreen> createState() => _OnboardingPageScreenState();
}

class _OnboardingPageScreenState extends State<OnboardingPageScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    
    // Check if user has already seen onboarding and redirect if needed
    if (widget.isFirstPage) {
      _checkOnboardingStatus();
    }
  }

  void _checkOnboardingStatus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<OnboardingBloc>().add(const LoadOnboardingStatus());
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onNextPage() {
    if (widget.isLastPage) {
      _completeOnboarding();
    } else {
      // Navigate to next onboarding page
      final nextRoute = _getNextRoute();
      if (nextRoute != null) {
        context.push(nextRoute);
      }
    }
  }

  void _completeOnboarding() {
    context.read<OnboardingBloc>().add(const CompleteOnboarding());
    SharedPrefsService.getInstance().then((sp) async {
      await sp.setFirstLaunch(false);
      if (!mounted) return;
      context.push(AppRoutes.login);
    });
  }

  void _skipOnboarding() {
    context.read<OnboardingBloc>().add(const CompleteOnboarding());
    SharedPrefsService.getInstance().then((sp) async {
      await sp.setFirstLaunch(false);
      if (!mounted) return;
      context.push(AppRoutes.login);
    });
  }

  String? _getNextRoute() {
    switch (widget.pageIndex) {
      case 0:
        return AppRoutes.onboardingPage2;
      case 1:
        return AppRoutes.onboardingPage3;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingLoaded && widget.isFirstPage) {
          if (state.hasSeenOnboarding) {
            context.go(AppRoutes.login);
          }
        }
      },
      child: CupertinoPageScaffold(
      backgroundColor: AppTheme.getBackgroundColor(Brightness.light),
      child: SafeArea(
        child: Column(
          children: [
            // Top Bar with Back and Skip
            Padding(
              padding: EdgeInsets.all(ResponsiveConstants.spacing16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button (only show if not first page)
                  if (!widget.isFirstPage)
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                      child: Icon(
                        CupertinoIcons.chevron_left,
                        size: ResponsiveConstants.iconSize24,
                        color: AppTheme.getTextSecondaryColor(Brightness.light),
                      ),
                    )
                  else
                    SizedBox(width: ResponsiveConstants.iconSize24),

                  // Skip Button
                  CupertinoButton(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveConstants.spacing12,
                      vertical: ResponsiveConstants.spacing8,
                    ),
                    onPressed: _skipOnboarding,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: AppTheme.getPrimaryColor(Brightness.light),
                        fontSize: ResponsiveConstants.fontSize14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: OnboardingPageWidget(
                page: widget.page,
                fadeAnimation: _fadeAnimation,
              ),
            ),

            // Bottom Section
            Container(
              padding: EdgeInsets.all(ResponsiveConstants.spacing24),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      OnboardingData.pages.length,
                      (index) => Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: ResponsiveConstants.spacing4,
                        ),
                        width: widget.pageIndex == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: widget.pageIndex == index
                              ? AppTheme.getPrimaryColor(Brightness.light)
                              : AppTheme.getPrimaryColor(Brightness.light).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: ResponsiveConstants.spacing32),

                  // Next/Get Started Button
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton.filled(
                      onPressed: _onNextPage,
                      padding: EdgeInsets.symmetric(
                        vertical: ResponsiveConstants.spacing16,
                      ),
                      borderRadius: BorderRadius.circular(ResponsiveConstants.radius12),
                      child: Text(
                        widget.isLastPage ? 'Get Started' : 'Next',
                        style: TextStyle(
                          fontSize: ResponsiveConstants.fontSize16,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
