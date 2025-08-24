import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/responsive_constants.dart';
import '../../../router/routes.dart';

class NoRouteFoundScreen extends StatelessWidget {
  const NoRouteFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Page Not Found',
          style: TextStyle(
            color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: CupertinoColors.white,
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveConstants.spacing24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Illustration
              Container(
                width: ResponsiveConstants.containerHeight120,
                height: ResponsiveConstants.containerHeight120,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(ResponsiveConstants.radius16),
                ),
                                  child: Icon(
                    CupertinoIcons.exclamationmark_triangle,
                    size: ResponsiveConstants.iconSize40,
                    color: CupertinoColors.systemOrange,
                  ),
              ),
              
              SizedBox(height: ResponsiveConstants.spacing32),
              
              // Error Title
              Text(
                'Oops! Page Not Found',
                style: TextStyle(
                  fontSize: ResponsiveConstants.fontSize28,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.black,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: ResponsiveConstants.spacing16),
              
              // Error Description
              Text(
                'The page you are looking for doesn\'t exist or has been moved. Please check the URL or navigate back to a valid page.',
                style: TextStyle(
                  fontSize: ResponsiveConstants.fontSize16,
                  color: CupertinoColors.systemGrey,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: ResponsiveConstants.spacing48),
              
              // Action Buttons
              Column(
                children: [
                  // Go Home Button
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton.filled(
                      onPressed: () {
                        context.go(AppRoutes.expenses);
                      },
                      padding: EdgeInsets.symmetric(
                        vertical: ResponsiveConstants.spacing16,
                      ),
                      borderRadius: BorderRadius.circular(ResponsiveConstants.radius12),
                      child: Text(
                        'Go to Home',
                        style: TextStyle(
                          fontSize: ResponsiveConstants.fontSize18,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: ResponsiveConstants.spacing16),
                  
                  // Go Back Button
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      onPressed: () {
                        context.pop();
                      },
                      padding: EdgeInsets.symmetric(
                        vertical: ResponsiveConstants.spacing16,
                      ),
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(ResponsiveConstants.radius12),
                      child: Text(
                        'Go Back',
                        style: TextStyle(
                          fontSize: ResponsiveConstants.fontSize18,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.black,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: ResponsiveConstants.spacing24),
                  
                  // Help Text
                  Text(
                    'Need help? Contact support',
                    style: TextStyle(
                      fontSize: ResponsiveConstants.fontSize14,
                      color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
