import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/responsive_constants.dart';
import 'transaction_menu.dart';

class TransactionsHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSearchTap;

  const TransactionsHeader({
    super.key,
    this.title = 'Transactions',
    this.onSearchTap,
  });

  void _onMenuPressed(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => const TransactionMenu(),
    );
  }

  void _onSearchPressed() {
    onSearchTap?.call();
    // Implement search functionality
  }

  @override
  Widget build(BuildContext context) {
    final brightness = CupertinoTheme.brightnessOf(context);
    
    return Container(
      padding: EdgeInsets.fromLTRB(
        ResponsiveConstants.spacing20,
        ResponsiveConstants.spacing16,
        ResponsiveConstants.spacing20,
        ResponsiveConstants.spacing8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveConstants.fontSize24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextPrimaryColor(brightness),
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: ResponsiveConstants.spacing2),
                Text(
                  'Manage your financial records',
                  style: TextStyle(
                    fontSize: ResponsiveConstants.fontSize12,
                    color: AppTheme.getTextSecondaryColor(brightness),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          Row(
            children: [
              // Search Button
              GestureDetector(
                onTap: _onSearchPressed,
                child: Container(
                  width: ResponsiveConstants.containerHeight48,
                  height: ResponsiveConstants.containerHeight48,
                  decoration: BoxDecoration(
                    color: AppTheme.getSurfaceColor(brightness),
                    borderRadius: BorderRadius.circular(ResponsiveConstants.radius16),
                    border: Border.all(
                      color: AppTheme.getPrimaryColor(brightness).withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.getPrimaryColor(brightness).withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    CupertinoIcons.search,
                    color: AppTheme.getPrimaryColor(brightness),
                    size: ResponsiveConstants.iconSize20,
                  ),
                ),
              ),
              
              SizedBox(width: ResponsiveConstants.spacing12),
              
              // Menu Button
              GestureDetector(
                onTap: () => _onMenuPressed(context),
                child: Container(
                  width: ResponsiveConstants.containerHeight48,
                  height: ResponsiveConstants.containerHeight48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.getPrimaryColor(brightness),
                        AppTheme.getPrimaryColor(brightness).withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(ResponsiveConstants.radius16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.getPrimaryColor(brightness).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    CupertinoIcons.ellipsis_vertical,
                    color: CupertinoColors.white,
                    size: ResponsiveConstants.iconSize20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
