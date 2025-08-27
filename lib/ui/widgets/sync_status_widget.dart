import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/responsive_constants.dart';

class SyncStatusWidget extends StatelessWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        return StreamBuilder<bool>(
          stream: transactionProvider.syncStatusStream,
          builder: (context, snapshot) {
            final isSyncing = snapshot.data ?? transactionProvider.isSyncing;
            final unsyncedCount = transactionProvider.unsyncedTransactions.length;
            final failedCount = transactionProvider.failedTransactions.length;

            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: _getBackgroundColor(context, isSyncing, failedCount),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getBorderColor(context, isSyncing, failedCount),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  _buildSyncIcon(context, isSyncing, failedCount),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSyncText(context, isSyncing, unsyncedCount, failedCount),
                  ),
                  if (unsyncedCount > 0 || failedCount > 0)
                    _buildSyncButton(context, transactionProvider),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSyncIcon(BuildContext context, bool isSyncing, int failedCount) {
    IconData iconData;
    Color iconColor;

    if (isSyncing) {
      iconData = CupertinoIcons.arrow_clockwise;
      iconColor = AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context));
    } else if (failedCount > 0) {
      iconData = CupertinoIcons.exclamationmark_triangle;
      iconColor = CupertinoColors.systemRed;
    } else {
      iconData = CupertinoIcons.checkmark_circle;
      iconColor = CupertinoColors.systemGreen;
    }

    return Icon(
      iconData,
      size: ResponsiveConstants.iconSize16,
      color: iconColor,
    );
  }

  Widget _buildSyncText(BuildContext context, bool isSyncing, int unsyncedCount, int failedCount) {
    String text;
    Color textColor;

    if (isSyncing) {
      text = 'Syncing...';
      textColor = AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context));
    } else if (failedCount > 0) {
      text = '$failedCount failed to sync';
      textColor = CupertinoColors.systemRed;
    } else if (unsyncedCount > 0) {
      text = '$unsyncedCount pending sync';
      textColor = AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context));
    } else {
      text = 'All synced';
      textColor = CupertinoColors.systemGreen;
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: ResponsiveConstants.fontSize12,
        color: textColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildSyncButton(BuildContext context, TransactionProvider transactionProvider) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      minSize: 0,
      onPressed: transactionProvider.isSyncing
          ? null
          : () => transactionProvider.syncNow(),
      child: Text(
        'Sync Now',
        style: TextStyle(
          fontSize: ResponsiveConstants.fontSize12,
          color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context, bool isSyncing, int failedCount) {
    if (isSyncing) {
      return AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)).withOpacity(0.1);
    } else if (failedCount > 0) {
      return CupertinoColors.systemRed.withOpacity(0.1);
    } else {
      return AppTheme.getBackgroundColor(CupertinoTheme.brightnessOf(context));
    }
  }

  Color _getBorderColor(BuildContext context, bool isSyncing, int failedCount) {
    if (isSyncing) {
      return AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context));
    } else if (failedCount > 0) {
      return CupertinoColors.systemRed;
    } else {
      return AppTheme.getBorderColor(CupertinoTheme.brightnessOf(context));
    }
  }
}
