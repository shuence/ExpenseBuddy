# 🔄 Offline Sync System - ExpenseBuddy

This document explains the comprehensive offline sync system implemented in ExpenseBuddy, which ensures your expense data is always available and synchronized across devices.

## 🏗️ Architecture Overview

The offline sync system consists of several key components:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Local SQLite  │◄──►│   Sync Service  │◄──►│   Firebase      │
│   Database      │    │                 │    │   Firestore     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │              ┌─────────────────┐              │
         └──────────────►│  Connectivity   │◄─────────────┘
                        │   Service       │
                        └─────────────────┘
                                │
                        ┌─────────────────┐
                        │  Background     │
                        │  Sync Service   │
                        └─────────────────┘
```

## 📁 File Structure

```
lib/
├── data/local/
│   └── local_database_service.dart    # SQLite database operations
├── services/
│   ├── sync_service.dart              # Main sync logic
│   ├── connectivity_service.dart      # Network connectivity monitoring
│   ├── background_sync_service.dart   # Background sync with WorkManager
│   └── service_initializer.dart       # Service initialization
├── models/
│   └── transaction_model.dart         # Enhanced with sync fields
├── providers/
│   └── transaction_provider.dart      # Updated to use sync service
└── ui/
    ├── widgets/
    │   └── sync_status_widget.dart    # Sync status display
    └── screens/settings/
        └── sync_settings_screen.dart  # Sync management UI
```

## 🔧 Key Components

### 1. Enhanced Transaction Model

The `TransactionModel` now includes sync-related fields:

```dart
class TransactionModel {
  // ... existing fields ...
  
  // Sync-related fields
  final SyncStatus syncStatus;        // synced, pending, failed
  final int syncAttempts;             // Number of sync attempts
  final DateTime? lastSyncAttempt;    // Last sync attempt timestamp
  final String? syncError;            // Error message if sync failed
}
```

### 2. Local Database Service (SQLite)

- **Purpose**: Local storage for offline access
- **Features**:
  - CRUD operations for transactions
  - Sync status tracking
  - Sync log management
  - Automatic indexing for performance

```dart
// Example usage
final localDb = LocalDatabaseService();
await localDb.insertTransaction(transaction);
final unsynced = await localDb.getUnsyncedTransactions(userId);
```

### 3. Sync Service

- **Purpose**: Orchestrates data synchronization between local and remote
- **Features**:
  - Automatic sync on connectivity changes
  - Periodic sync every 5 minutes
  - Conflict resolution
  - Error handling and retry logic

```dart
// Example usage
final syncService = SyncService();
await syncService.addTransaction(transaction);  // Saves locally + syncs if online
await syncService.syncNow();                    // Manual sync
```

### 4. Connectivity Service

- **Purpose**: Monitors network connectivity changes
- **Features**:
  - Real-time connectivity status
  - Automatic sync triggering on reconnection
  - Connection type detection (WiFi, Mobile, etc.)

### 5. Background Sync Service

- **Purpose**: Syncs data even when app is closed
- **Features**:
  - Uses WorkManager for background tasks
  - Periodic sync every hour
  - Battery-optimized scheduling

## 🚀 How It Works

### 1. Adding a Transaction

```dart
// User adds a new expense
final transaction = TransactionModel(
  id: 'unique_id',
  title: 'Coffee',
  amount: 5.99,
  // ... other fields
);

// 1. Save to local database immediately (offline safe)
await localDb.insertTransaction(transaction);

// 2. Try to sync to Firebase if online
if (connectivityService.isConnected) {
  await firebaseService.addTransaction(transaction);
  await localDb.markTransactionAsSynced(transaction.id);
} else {
  // Transaction remains marked as 'pending'
  // Will sync when connection is restored
}
```

### 2. Sync Process

```dart
// When connectivity is restored:
1. Get all unsynced transactions from local DB
2. For each transaction:
   - Try to sync to Firebase
   - Mark as 'synced' on success
   - Mark as 'failed' on error (with retry logic)
3. Pull latest changes from Firebase
4. Update local database
```

### 3. Conflict Resolution

- **Local-first approach**: Local changes take priority
- **Timestamp-based**: Uses `updatedAt` field for conflict detection
- **Merge strategy**: Combines local and remote changes intelligently

## 📱 User Experience

### 1. Sync Status Widget

Shows real-time sync status in the UI:

- ✅ **All synced**: Green checkmark
- ⏳ **Pending**: Orange clock icon with count
- ❌ **Failed**: Red warning icon with count
- 🔄 **Syncing**: Blue spinning icon

### 2. Sync Settings Screen

Provides comprehensive sync management:

- **Sync Statistics**: Pending, failed, connection status
- **Manual Sync**: Force sync all pending transactions
- **Background Sync**: Test and manage background sync
- **Sync Log**: View recent sync activities

### 3. Offline Indicators

- Subtle indicators when working offline
- Clear feedback when sync completes
- Error messages for failed syncs

## ⚙️ Configuration

### 1. Sync Intervals

```dart
// In sync_service.dart
static const Duration _syncInterval = Duration(minutes: 5);  // In-app sync

// In background_sync_service.dart
frequency: const Duration(hours: 1),  // Background sync
```

### 2. Retry Logic

```dart
// Maximum sync attempts before marking as failed
const int maxSyncAttempts = 3;

// Exponential backoff for retries
final delay = Duration(seconds: pow(2, attemptNumber));
```

### 3. Background Sync Constraints

```dart
constraints: Constraints(
  networkType: NetworkType.connected,    // Only when online
  requiresBatteryNotLow: false,          // Don't require full battery
  requiresCharging: false,               // Don't require charging
  requiresDeviceIdle: false,             // Don't require device idle
  requiresStorageNotLow: false,          // Don't require storage
),
```

## 🔍 Debugging & Monitoring

### 1. Sync Logs

All sync operations are logged to the local database:

```dart
// View sync logs
final logs = await localDb.getSyncLog(limit: 100);
for (final log in logs) {
  print('${log['operation']} - ${log['status']} - ${log['error']}');
}
```

### 2. Sync Statistics

Get comprehensive sync statistics:

```dart
final stats = await syncService.getSyncStats(userId);
print('Pending: ${stats['pendingTransactions']}');
print('Connected: ${stats['isConnected']}');
print('Syncing: ${stats['isSyncing']}');
```

### 3. Debug Mode

Enable debug logging in development:

```dart
// In background_sync_service.dart
isInDebugMode: true,  // Set to false in production
```

## 🛠️ Installation & Setup

### 1. Dependencies

Add these to your `pubspec.yaml`:

```yaml
dependencies:
  sqflite: ^2.3.3+1
  path: ^1.9.0
  connectivity_plus: ^6.0.5
  workmanager: ^0.5.2
```

### 2. Initialize Services

```dart
// In main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize all services
  await ServiceInitializer().initialize();
  
  runApp(const ExpenseBuddyApp());
}
```

### 3. Update Transaction Provider

```dart
// Use sync service instead of direct Firebase calls
await syncService.addTransaction(transaction);
await syncService.updateTransaction(transaction);
await syncService.deleteTransaction(id);
```

## 🧪 Testing

### 1. Offline Testing

1. Enable airplane mode
2. Add/edit transactions
3. Verify they're saved locally
4. Disable airplane mode
5. Check that sync occurs automatically

### 2. Background Sync Testing

1. Add transactions while app is open
2. Close the app completely
3. Wait for background sync (or trigger manually)
4. Reopen app and verify sync status

### 3. Conflict Testing

1. Add same transaction on two devices
2. Modify on both devices
3. Sync both devices
4. Verify conflict resolution

## 🚨 Troubleshooting

### Common Issues

1. **Sync not working**
   - Check internet connection
   - Verify Firebase configuration
   - Check sync logs for errors

2. **Background sync not triggering**
   - Ensure WorkManager is initialized
   - Check device battery optimization settings
   - Verify app permissions

3. **Data conflicts**
   - Check sync logs for conflict details
   - Verify timestamp handling
   - Review conflict resolution logic

### Debug Commands

```dart
// Force sync
await syncService.syncNow();

// Clear all data
await syncService.clearAllData();

// View sync status
final stats = await syncService.getSyncStats(userId);
print(stats);

// Test background sync
await backgroundSyncService.registerOneOffTask();
```

## 📈 Performance Considerations

### 1. Database Optimization

- Indexes on frequently queried fields
- Batch operations for multiple transactions
- Efficient query patterns

### 2. Sync Optimization

- Debounced sync requests
- Batch sync operations
- Incremental sync (only changed data)

### 3. Memory Management

- Dispose of streams properly
- Close database connections
- Clean up resources on app exit

## 🔮 Future Enhancements

1. **Conflict Resolution UI**: Let users choose how to resolve conflicts
2. **Sync Filters**: Sync only specific categories or date ranges
3. **Offline Analytics**: Track spending patterns even when offline
4. **Multi-device Sync**: Enhanced sync across multiple devices
5. **Data Export**: Export sync logs and statistics

## 📚 Additional Resources

- [SQLite Documentation](https://www.sqlite.org/docs.html)
- [WorkManager Guide](https://pub.dev/packages/workmanager)
- [Connectivity Plus](https://pub.dev/packages/connectivity_plus)
- [Firebase Offline Persistence](https://firebase.flutter.dev/docs/firestore/usage#offline-persistence)

---

This offline sync system ensures that ExpenseBuddy works seamlessly whether you're online or offline, providing a reliable and consistent user experience across all network conditions.
