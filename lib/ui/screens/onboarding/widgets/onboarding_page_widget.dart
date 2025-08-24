import 'package:flutter/cupertino.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../models/onboarding_model.dart';

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;
  final Animation<double> fadeAnimation;

  const OnboardingPageWidget({
    super.key,
    required this.page,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Padding(
        padding: EdgeInsets.all(ResponsiveConstants.spacing16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image Section
            Expanded(
              flex: 2,
              child: Center(
                child: Image.asset(
                  page.imagePath,
                  width: ResponsiveConstants.containerHeight280,
                  height: ResponsiveConstants.containerHeight200,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Text Content Section
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    page.title,
                    style: TextStyle(
                      fontSize: ResponsiveConstants.fontSize24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getTextPrimaryColor(Brightness.light),
                      letterSpacing: -0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // Subtitle
                  Text(
                    page.subtitle,
                    style: TextStyle(
                      fontSize: ResponsiveConstants.fontSize24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getPrimaryColor(Brightness.light),
                      letterSpacing: -0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: ResponsiveConstants.spacing16),

                  // Description
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveConstants.spacing24,
                    ),
                    child: Text(
                      page.description,
                      style: TextStyle(
                        fontSize: ResponsiveConstants.fontSize14,
                        color: AppTheme.getTextSecondaryColor(Brightness.light),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
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
