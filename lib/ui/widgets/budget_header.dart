import 'package:flutter/cupertino.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/responsive_constants.dart';

class BudgetHeader extends StatelessWidget {
  final String currentMonth;
  final VoidCallback? onMonthTap;

  const BudgetHeader({
    super.key,
    required this.currentMonth,
    this.onMonthTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isDesktop = context.isDesktop;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onMonthTap,
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    currentMonth,
                    style: TextStyle(
                      fontSize: _getMonthFontSize(isTablet, isDesktop),
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: ResponsiveConstants.spacing8),
                Icon(
                  CupertinoIcons.chevron_down,
                  size: _getChevronSize(isTablet, isDesktop),
                  color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: ResponsiveConstants.spacing16),
        Row(
          children: [
            Text(
              'Budgets',
              style: TextStyle(
                fontSize: _getTitleFontSize(isTablet, isDesktop),
                fontWeight: FontWeight.bold,
                color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
              ),
            ),
            SizedBox(width: ResponsiveConstants.spacing12),
            GestureDetector(
              onTap: () {
                // TODO: Add menu functionality
              },
              child: Icon(
                CupertinoIcons.line_horizontal_3,
                size: _getMenuIconSize(isTablet, isDesktop),
                color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Responsive helper methods
  double _getMonthFontSize(bool isTablet, bool isDesktop) {
    if (isDesktop) return ResponsiveConstants.fontSize20;
    if (isTablet) return ResponsiveConstants.fontSize18;
    return ResponsiveConstants.fontSize16;
  }

  double _getTitleFontSize(bool isTablet, bool isDesktop) {
    if (isDesktop) return ResponsiveConstants.fontSize24;
    if (isTablet) return ResponsiveConstants.fontSize20;
    return ResponsiveConstants.fontSize18;
  }

  double _getChevronSize(bool isTablet, bool isDesktop) {
    if (isDesktop) return ResponsiveConstants.iconSize20;
    if (isTablet) return ResponsiveConstants.iconSize16;
    return ResponsiveConstants.iconSize16;
  }

  double _getMenuIconSize(bool isTablet, bool isDesktop) {
    if (isDesktop) return ResponsiveConstants.iconSize24;
    if (isTablet) return ResponsiveConstants.iconSize20;
    return ResponsiveConstants.iconSize20;
  }
}
