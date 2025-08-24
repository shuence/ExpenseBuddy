import 'package:flutter/cupertino.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/theme/app_theme.dart';

class OnboardingIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const OnboardingIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => _buildDot(index),
      ),
    );
  }

  Widget _buildDot(int index) {
    final isActive = index == currentPage;
    final isCompleted = index < currentPage;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveConstants.spacing4,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isActive 
            ? ResponsiveConstants.spacing24 
            : ResponsiveConstants.spacing8,
        height: ResponsiveConstants.spacing8,
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.getPrimaryColor(Brightness.light)
              : isCompleted
                  ? AppTheme.getPrimaryColor(Brightness.light).withOpacity(0.6)
                  : AppTheme.getTextSecondaryColor(Brightness.light).withOpacity(0.3),
          borderRadius: BorderRadius.circular(ResponsiveConstants.radius4),
        ),
      ),
    );
  }
}
