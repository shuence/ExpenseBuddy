import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
import '../../core/constants/colors.dart';
import '../../providers/app_router.dart';

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
    // Show an iOS-style tip notification at the bottom
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 100, // Position above the tab bar
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.systemGrey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.info_circle,
                  color: CupertinoColors.systemBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Press back again to exit',
                    style: TextStyle(
                      color: CupertinoColors.label,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    overlay.insert(overlayEntry);
    
    // Auto-dismiss after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
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
            activeColor: AppColors.primary,
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
