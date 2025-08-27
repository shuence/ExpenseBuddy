import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/responsive_constants.dart';

class TransactionMenu extends StatelessWidget {
  const TransactionMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      title: Text(
        'Transaction Options',
        style: TextStyle(
          fontSize: ResponsiveConstants.fontSize18,
          fontWeight: FontWeight.w600,
          color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
        ),
      ),
      message: Text(
        'Choose an action to manage your transactions',
        style: TextStyle(
          fontSize: ResponsiveConstants.fontSize14,
          color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)),
        ),
      ),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            _showFilterOptions(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.slider_horizontal_3,
                color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
                size: ResponsiveConstants.iconSize20,
              ),
              const SizedBox(width: 8),
              const Text('Filter Transactions'),
            ],
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            _showSortOptions(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.sort_down,
                color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
                size: ResponsiveConstants.iconSize20,
              ),
              const SizedBox(width: 8),
              const Text('Sort Transactions'),
            ],
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            _showDateRangeOptions(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.calendar,
                color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
                size: ResponsiveConstants.iconSize20,
              ),
              const SizedBox(width: 8),
              const Text('Date Range'),
            ],
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            _exportTransactions(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.share,
                color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
                size: ResponsiveConstants.iconSize20,
              ),
              const SizedBox(width: 8),
              const Text('Export Data'),
            ],
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            _showAnalytics(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.chart_bar,
                color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
                size: ResponsiveConstants.iconSize20,
              ),
              const SizedBox(width: 8),
              const Text('View Analytics'),
            ],
          ),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(context),
        isDefaultAction: true,
        child: const Text('Cancel'),
      ),
    );
  }

  void _showFilterOptions(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Filter by Category'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Food & Dining'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Transportation'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bills & Utilities'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entertainment'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Shopping'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Health & Fitness'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Sort Transactions'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Date (Newest First)'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Date (Oldest First)'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Amount (Highest First)'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Amount (Lowest First)'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Category (A-Z)'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showDateRangeOptions(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Select Date Range'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Today'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('This Week'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('This Month'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Last 3 Months'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('This Year'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Custom Range'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _exportTransactions(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Export Transactions'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Export as PDF'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Export as CSV'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Export as Excel'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Share via Email'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showAnalytics(BuildContext context) {
    // Navigate to analytics screen
    // context.push(AppRoutes.analytics);
  }
}
