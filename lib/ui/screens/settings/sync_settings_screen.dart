import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../services/timer_background_sync_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/responsive_constants.dart';
import '../../widgets/sync_status_widget.dart';

class SyncSettingsScreen extends StatefulWidget {
  const SyncSettingsScreen({super.key});

  @override
  State<SyncSettingsScreen> createState() => _SyncSettingsScreenState();
}

class _SyncSettingsScreenState extends State<SyncSettingsScreen> {
  final TimerBackgroundSyncService _backgroundSyncService = TimerBackgroundSyncService();
  Map<String, dynamic> _syncStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSyncStats();
  }

  Future<void> _loadSyncStats() async {
    setState(() => _isLoading = true);
    
    try {
      final transactionProvider = context.read<TransactionProvider>();
      final stats = await transactionProvider.getSyncStats('current_user_id');
      setState(() {
        _syncStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Sync Settings'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSyncStatusSection(),
            const SizedBox(height: 24),
            _buildSyncStatsSection(),
            const SizedBox(height: 24),
            _buildSyncActionsSection(),
            const SizedBox(height: 24),
            _buildBackgroundSyncSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatusSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(CupertinoTheme.brightnessOf(context)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getBorderColor(CupertinoTheme.brightnessOf(context)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sync Status',
            style: TextStyle(
              fontSize: ResponsiveConstants.fontSize18,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
            ),
          ),
          const SizedBox(height: 12),
          const SyncStatusWidget(),
        ],
      ),
    );
  }

  Widget _buildSyncStatsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(CupertinoTheme.brightnessOf(context)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getBorderColor(CupertinoTheme.brightnessOf(context)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sync Statistics',
            style: TextStyle(
              fontSize: ResponsiveConstants.fontSize18,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const CupertinoActivityIndicator()
          else
            _buildStatsGrid(),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Pending',
                '${_syncStats['pendingTransactions'] ?? 0}',
                CupertinoIcons.clock,
                CupertinoColors.systemOrange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Failed',
                '${(_syncStats['recentSyncLogs'] as List?)?.where((log) => log['status'] == 'failed').length ?? 0}',
                CupertinoIcons.exclamationmark_triangle,
                CupertinoColors.systemRed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Connected',
                _syncStats['isConnected'] == true ? 'Yes' : 'No',
                CupertinoIcons.wifi,
                _syncStats['isConnected'] == true ? CupertinoColors.systemGreen : CupertinoColors.systemRed,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Syncing',
                _syncStats['isSyncing'] == true ? 'Yes' : 'No',
                CupertinoIcons.arrow_clockwise,
                _syncStats['isSyncing'] == true ? CupertinoColors.systemBlue : CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveConstants.fontSize16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveConstants.fontSize12,
              color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncActionsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(CupertinoTheme.brightnessOf(context)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getBorderColor(CupertinoTheme.brightnessOf(context)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sync Actions',
            style: TextStyle(
              fontSize: ResponsiveConstants.fontSize18,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
            ),
          ),
          const SizedBox(height: 16),
                     _buildActionButton(
             'Sync Now',
             'Manually sync all pending transactions',
             CupertinoIcons.arrow_clockwise,
             () => _manualSync(),
           ),
           const SizedBox(height: 12),
           _buildActionButton(
             'Full Sync',
             'Fetch Firebase data + sync local changes',
             CupertinoIcons.arrow_2_circlepath,
             () => _fullSync(),
           ),
          const SizedBox(height: 12),
                     _buildActionButton(
             'View Sync Log',
             'Check recent sync activities',
             CupertinoIcons.list_bullet,
             () => _viewSyncLog(),
           ),
           const SizedBox(height: 12),
           _buildActionButton(
             'Debug Sync Status',
             'Show detailed sync information',
             CupertinoIcons.info_circle,
             () => _debugSyncStatus(),
           ),
           const SizedBox(height: 12),
           _buildActionButton(
             'Mark All as Synced',
             'Fix pending sync status for existing data',
             CupertinoIcons.checkmark_circle,
             () => _markAllAsSynced(),
           ),
           const SizedBox(height: 12),
                       _buildActionButton(
              'Retry Failed Syncs',
              'Retry transactions that failed to sync',
              CupertinoIcons.arrow_clockwise_circle,
              () => _retryFailedSyncs(),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              'Force Sync All Pending',
              'Force sync all pending transactions to Firebase',
              CupertinoIcons.arrow_2_circlepath_circle,
              () => _forceSyncAllPending(),
            ),
        ],
      ),
    );
  }

  Widget _buildBackgroundSyncSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(CupertinoTheme.brightnessOf(context)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getBorderColor(CupertinoTheme.brightnessOf(context)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Background Sync',
            style: TextStyle(
              fontSize: ResponsiveConstants.fontSize18,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Automatically sync data in the background every hour when connected to the internet.',
            style: TextStyle(
              fontSize: ResponsiveConstants.fontSize14,
              color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)),
            ),
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            'Test Background Sync',
            'Trigger a background sync task',
            CupertinoIcons.play_circle,
            () => _testBackgroundSync(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, String subtitle, IconData icon, VoidCallback onPressed) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.getBackgroundColor(CupertinoTheme.brightnessOf(context)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.getBorderColor(CupertinoTheme.brightnessOf(context)),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: ResponsiveConstants.fontSize14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: ResponsiveConstants.fontSize12,
                      color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _manualSync() async {
    try {
      final transactionProvider = context.read<TransactionProvider>();
      await transactionProvider.syncNow();
      await _loadSyncStats();
      
      if (mounted) {
        _showAlert('Sync Complete', 'All pending transactions have been synced successfully.');
      }
    } catch (e) {
      if (mounted) {
        _showAlert('Sync Failed', 'Failed to sync transactions: $e');
      }
    }
  }

  Future<void> _fullSync() async {
    try {
      final transactionProvider = context.read<TransactionProvider>();
      await transactionProvider.fullSync();
      await _loadSyncStats();
      
      if (mounted) {
        _showAlert('Full Sync Complete', 'Firebase data fetched and local changes synced successfully.');
      }
    } catch (e) {
      if (mounted) {
        _showAlert('Full Sync Failed', 'Failed to perform full sync: $e');
      }
    }
  }

  Future<void> _viewSyncLog() async {
    // Navigate to sync log screen
    // You can implement this later
    _showAlert('Coming Soon', 'Sync log feature will be available soon.');
  }

  Future<void> _testBackgroundSync() async {
    try {
      await _backgroundSyncService.manualSync();
      _showAlert('Background Sync', 'Manual sync completed successfully.');
    } catch (e) {
      _showAlert('Error', 'Failed to perform manual sync: $e');
    }
  }

  void _debugSyncStatus() {
    final transactionProvider = context.read<TransactionProvider>();
    transactionProvider.debugSyncStatus();
    _showAlert('Debug Info', 'Check the console/logs for detailed sync information.');
  }

  Future<void> _markAllAsSynced() async {
    try {
      final transactionProvider = context.read<TransactionProvider>();
      await transactionProvider.markAllAsSynced();
      await _loadSyncStats();
      _showAlert('Success', 'All pending transactions have been marked as synced.');
    } catch (e) {
      _showAlert('Error', 'Failed to mark transactions as synced: $e');
    }
  }

  Future<void> _retryFailedSyncs() async {
    try {
      final transactionProvider = context.read<TransactionProvider>();
      await transactionProvider.retryFailedSyncs();
      await _loadSyncStats();
      _showAlert('Success', 'Failed syncs have been retried successfully.');
    } catch (e) {
      _showAlert('Error', 'Failed to retry failed syncs: $e');
    }
  }
  
  Future<void> _forceSyncAllPending() async {
    try {
      final transactionProvider = context.read<TransactionProvider>();
      await transactionProvider.forceSyncAllPending();
      await _loadSyncStats();
      _showAlert('Success', 'All pending transactions have been force synced successfully.');
    } catch (e) {
      _showAlert('Error', 'Failed to force sync pending transactions: $e');
    }
  }

  void _showAlert(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
