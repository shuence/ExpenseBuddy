import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../providers/navigation_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../router/routes.dart';
import 'package:go_router/go_router.dart';
import '../home/home_screen.dart';
import '../transactions/transactions_screen.dart';
import '../budget/budget_screen.dart';
import '../profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  DateTime? _lastBackPressTime;
  
  @override
  void initState() {
    super.initState();
    // Load data after the widget is built to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    
    final authBloc = context.read<AuthBloc>();
    final transactionProvider = context.read<TransactionProvider>();
    
    if (authBloc.currentUser != null) {
      await transactionProvider.loadTransactions(authBloc.currentUser!.uid);
    }
  }

  Future<bool> _onWillPop() async {
    final navigationProvider = context.read<NavigationProvider>();
    final now = DateTime.now();
    const exitWarning = Duration(seconds: 2);
    
    // If not on home tab (index 0), navigate to home first
    if (navigationProvider.currentIndex != 0) {
      navigationProvider.setIndex(0);
      return false; // Don't exit, just navigate to home
    }
    
    // If on home tab, use double back to exit logic
    if (_lastBackPressTime == null || 
        now.difference(_lastBackPressTime!) > exitWarning) {
      _lastBackPressTime = now;
      
      // Show a toast/snackbar message
      _showExitWarning();
      
      return false; // Don't exit yet
    }
    
    // Exit the app
    return true;
  }
  
  void _showExitWarning() {
    // Show a cupertino-style alert dialog
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => CupertinoAlertDialog(
        content: const Text('Press back again to exit ExpenseBuddy'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
    
    // Auto-dismiss after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            SystemNavigator.pop();
          }
        }
      },
      child: Consumer<NavigationProvider>(
        builder: (context, navigationProvider, child) {
        return CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            currentIndex: navigationProvider.currentIndex,
            onTap: (index) {
              // Handle special cases for center button
              if (index == 2) {
                // Add transaction button - don't change the tab, just navigate
                context.push(AppRoutes.addTransaction);
                // Don't change the current index for the center button
                return;
              }
              
              // Set the new tab index
              navigationProvider.setIndex(index);
            },
            backgroundColor: CupertinoColors.systemBackground,
            activeColor: const Color(0xFF2ECC71),
            inactiveColor: CupertinoColors.systemGrey,
            border: const Border(
              top: BorderSide(
                color: CupertinoColors.separator,
                width: 0.5,
              ),
            ),
            items: NavigationProvider.navigationItems.map((item) {
              return BottomNavigationBarItem(
                icon: Icon(
                  navigationProvider.currentIndex == item.index 
                      ? item.activeIcon 
                      : item.icon,
                  size: item.isCenter ? 32 : 24,
                ),
                label: item.title,
              );
            }).toList(),
          ),
          tabBuilder: (context, index) {
            // Handle center button (Add transaction)
            if (index == 2) {
              return CupertinoPageScaffold(
                child: TransactionsScreen()
              );
            }

            return CupertinoTabView(
              builder: (context) {
                switch (index) {
                  case 0:
                    return CupertinoPageScaffold(
                      child: HomeScreen(),
                    );
                  case 1:
                    return const TransactionsScreen();
                  case 3:
                    return const BudgetScreen();
                  case 4:
                    return const ProfileScreen();
                  default:
                    return const CupertinoPageScaffold(
                      child: Center(
                        child: Text('Home Screen'),
                      ),
                    );
                }
              },
            );
          },
        );
        },
      ),
    );
  }
}
