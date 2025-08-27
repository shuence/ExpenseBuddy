import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_theme.dart';
import '../transactions/add_transaction_screen.dart';
import '../transactions/transactions_list_screen.dart';
import '../budget/budget_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CupertinoTabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = CupertinoTabController(initialIndex: 0);
    _tabController.addListener(_onTabControllerChanged);
  }

  void _onTabControllerChanged() {
    debugPrint('🏠 HomeScreen: Tab controller changed to index: ${_tabController.index}');
    
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabControllerChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
              backgroundColor: AppTheme.lightBackground,
              controller: _tabController,
            tabBar: CupertinoTabBar(
              backgroundColor: AppTheme.getBackgroundColor(CupertinoTheme.brightnessOf(context)),
              activeColor: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
              inactiveColor: CupertinoColors.systemGrey,
              currentIndex: _tabController.index,
              onTap: (index) {
                _tabController.index = index;
              },
              border: const Border(
                top: BorderSide(
                  color: CupertinoColors.systemGrey4,
                  width: 0.5,
                ),
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.list_bullet),
                  label: 'Transactions',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.add),
                  label: 'Add Expense',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.chart_pie),
                  label: 'Budget',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.person),
                  label: 'Profile',
                ),
              ],
            ),
            tabBuilder: (context, index) {
              return _buildTabView(context, index);
            },
          );
  }

  Widget _buildTabView(BuildContext context, int index) {
    switch (index) {
      case 0:
        return CupertinoTabView(
          builder: (context) => CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: Text(
                'Home',
                style: TextStyle(
                  color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: AppTheme.getBackgroundColor(CupertinoTheme.brightnessOf(context)),
              border: null,
            ),
            child: const Center(child: Text('Home')),
          ),
        );
      case 1:
        return CupertinoTabView(
          builder: (context) => const TransactionsListScreen(),
        );
      case 2:
        return CupertinoTabView(
          builder: (context) => const AddTransactionScreen(),
        );
      case 3:
        return CupertinoTabView(
          builder: (context) => const BudgetScreen(),
        );
      case 4:
        return CupertinoTabView(
          builder: (context) => CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: Text(
                'Profile',
                style: TextStyle(
                  color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: AppTheme.getBackgroundColor(CupertinoTheme.brightnessOf(context)),
              border: null,
            ),
            child: const Center(child: Text('Profile')),
          ),
        );
      default:
        return CupertinoTabView(
          builder: (context) => const AddTransactionScreen(),
        );
    }
  }
}
