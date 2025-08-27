import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/constants/app_constants.dart';

class TransactionFilterTabs extends StatelessWidget {
  final TransactionFilter selectedFilter;
  final Function(TransactionFilter) onFilterChanged;

  const TransactionFilterTabs({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = CupertinoTheme.brightnessOf(context);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ResponsiveConstants.spacing20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildFilterTab('All', TransactionFilter.all, CupertinoIcons.list_bullet, brightness),
            SizedBox(width: ResponsiveConstants.spacing12),
            _buildFilterTab('Income', TransactionFilter.income, CupertinoIcons.arrow_down_left, brightness),
            SizedBox(width: ResponsiveConstants.spacing12),
            _buildFilterTab('Expenses', TransactionFilter.expenses, CupertinoIcons.arrow_up_right, brightness),
            SizedBox(width: ResponsiveConstants.spacing12),
            _buildFilterTab('Transfer', TransactionFilter.transfer, CupertinoIcons.arrow_right_arrow_left, brightness),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String title, TransactionFilter filter, IconData icon, Brightness brightness) {
    final isSelected = selectedFilter == filter;
    
    return GestureDetector(
      onTap: () => onFilterChanged(filter),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveConstants.spacing16,
          vertical: ResponsiveConstants.spacing12,
        ),
        decoration: BoxDecoration(
          gradient: isSelected 
              ? LinearGradient(
                  colors: [
                    AppTheme.getPrimaryColor(brightness),
                    AppTheme.getPrimaryColor(brightness).withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected 
              ? null
              : AppTheme.getSurfaceColor(brightness),
          borderRadius: BorderRadius.circular(ResponsiveConstants.radius20),
          border: isSelected 
              ? null 
              : Border.all(
                  color: AppTheme.getPrimaryColor(brightness).withOpacity(0.1),
                  width: 1,
                ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.getPrimaryColor(brightness).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: AppTheme.getPrimaryColor(brightness).withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppTheme.getPrimaryColor(brightness).withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? CupertinoColors.white
                  : AppTheme.getPrimaryColor(brightness),
              size: ResponsiveConstants.iconSize16,
            ),
            SizedBox(width: ResponsiveConstants.spacing8),
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveConstants.fontSize12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected 
                    ? CupertinoColors.white 
                    : AppTheme.getTextPrimaryColor(brightness),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
