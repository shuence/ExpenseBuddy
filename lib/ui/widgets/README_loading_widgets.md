# Loading Widgets for Transactions

This directory contains widgets that provide loading states and user feedback during transaction operations.

## Widgets

### 1. TransactionLoadingWidget
A simple loading indicator that shows when transactions are being processed.

**Usage:**
```dart
const TransactionLoadingWidget(
  message: 'Custom loading message...',
)
```

**Features:**
- Automatically shows/hides based on `TransactionProvider.isAddingTransaction`
- Displays a loading spinner with customizable message
- Styled with Cupertino design

### 2. LoadingOverlay
A full-screen overlay that blocks user interaction while loading.

**Usage:**
```dart
LoadingOverlay(
  isLoading: transactionProvider.isAddingTransaction,
  message: 'Adding transaction...',
  child: YourFormWidget(),
)
```

**Features:**
- Full-screen overlay with semi-transparent background
- Centered loading dialog with spinner and message
- Blocks all user interaction while loading
- Customizable colors and messages

### 3. TransactionFormLoadingExample
A complete example showing how to implement loading states in a transaction form.

**Features:**
- Form validation
- Loading states for submit button
- Loading overlay during transaction processing
- Success/error handling
- Form reset on success

## Integration with TransactionProvider

The loading widgets work with the enhanced `TransactionProvider` that now provides detailed loading states:

```dart
// Check specific loading states
bool isAdding = transactionProvider.isAddingTransaction;
bool isUpdating = transactionProvider.isUpdatingTransaction;
bool isDeleting = transactionProvider.isDeletingTransaction;
bool isSyncing = transactionProvider.isSyncing;

// General loading state
bool isLoading = transactionProvider.isLoading;
```

## Best Practices

1. **Use specific loading states** for better UX:
   - `isAddingTransaction` for add operations
   - `isUpdatingTransaction` for update operations
   - `isDeletingTransaction` for delete operations

2. **Combine with LoadingOverlay** for forms to prevent user interaction during processing

3. **Show loading in buttons** to indicate the current operation

4. **Provide clear feedback** about what's happening (e.g., "Saving to local database and syncing...")

5. **Handle errors gracefully** with user-friendly error messages

## Example Implementation

```dart
class MyTransactionForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return LoadingOverlay(
          isLoading: provider.isAddingTransaction,
          message: 'Adding transaction...',
          child: Scaffold(
            body: Form(
              child: Column(
                children: [
                  // Your form fields here
                  
                  // Submit button with loading state
                  CupertinoButton.filled(
                    onPressed: provider.isAddingTransaction ? null : _submit,
                    child: provider.isAddingTransaction
                        ? const Row(
                            children: [
                              CupertinoActivityIndicator(color: CupertinoColors.white),
                              SizedBox(width: 8),
                              Text('Adding...'),
                            ],
                          )
                        : const Text('Add Transaction'),
                  ),
                  
                  // Additional loading indicator
                  if (provider.isAddingTransaction)
                    const TransactionLoadingWidget(
                      message: 'Processing your transaction...',
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
```

## Logging

The system now provides comprehensive logging for debugging:

- 🔄 Operation start
- 📱 Transaction details
- 👤 User information
- 🌐 Connectivity status
- 💾 Local database operations
- 🔥 Firebase operations
- ✅ Success confirmations
- ❌ Error details

Check the console/logs for detailed information about what's happening during transaction processing.
