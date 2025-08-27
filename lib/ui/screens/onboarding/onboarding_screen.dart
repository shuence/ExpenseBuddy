import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/responsive_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/onboarding_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../router/routes.dart';
import '../../../services/shared_prefs_service.dart';
import 'widgets/onboarding_page_widget.dart';
import 'widgets/onboarding_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
    
    // Load onboarding status
    context.read<OnboardingBloc>().add(const LoadOnboardingStatus());
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int pageIndex) {
    context.read<OnboardingBloc>().add(GoToPage(pageIndex));
  }

  void _onNextPage() {
    final onboardingBloc = context.read<OnboardingBloc>();
    
    if (onboardingBloc.isLastPage) {
      _completeOnboarding();
    } else {
      onboardingBloc.add(const NextPage());
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPreviousPage() {
    final onboardingBloc = context.read<OnboardingBloc>();
    
    if (!onboardingBloc.isFirstPage) {
      onboardingBloc.add(const PreviousPage());
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding() {
    context.read<OnboardingBloc>().add(const CompleteOnboarding());
    SharedPrefsService.getInstance().then((sp) async {
      await sp.setFirstLaunch(false);
      if (!mounted) return;
      context.go(AppRoutes.login);
    });
  }

  void _skipOnboarding() {
    context.read<OnboardingBloc>().add(const CompleteOnboarding());
    SharedPrefsService.getInstance().then((sp) async {
      await sp.setFirstLaunch(false);
      if (!mounted) return;
      context.go(AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingLoaded && state.hasSeenOnboarding) {
          context.go(AppRoutes.login);
        }
      },
      child: BlocBuilder<OnboardingBloc, OnboardingState>(
        builder: (context, state) {
          if (state is OnboardingLoading) {
            return const CupertinoPageScaffold(
              child: Center(
                child: CupertinoActivityIndicator(),
              ),
            );
          }

          if (state is OnboardingLoaded) {
            return _buildOnboardingContent(state);
          }

          return const CupertinoPageScaffold(
            child: Center(
              child: CupertinoActivityIndicator(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOnboardingContent(OnboardingLoaded state) {
    return CupertinoPageScaffold(
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
                  if (!context.read<OnboardingBloc>().isFirstPage)
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _onPreviousPage,
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

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: state.pages.length,
                itemBuilder: (context, index) {
                  final page = state.pages[index];
                  return OnboardingPageWidget(
                    page: page,
                    fadeAnimation: _fadeAnimation,
                  );
                },
              ),
            ),

            // Bottom Section
            Container(
              padding: EdgeInsets.all(ResponsiveConstants.spacing24),
              child: Column(
                children: [
                  // Page Indicators
                  OnboardingIndicator(
                    currentPage: state.currentPageIndex,
                    totalPages: state.pages.length,
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
                         context.read<OnboardingBloc>().isLastPage ? 'Get Started' : 'Next',
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
    );
  }
}
