import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/responsive_constants.dart';
import '../../../models/user_model.dart';
import '../../../services/user_service.dart';
import '../../../services/user_preferences_service.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/budget_provider.dart';
import '../../../router/routes.dart';
import '../../widgets/greeting_section.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/overview_stats.dart';
import '../../widgets/recent_transactions.dart';
import '../transactions/transaction_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? _currentUser;
  bool _isLoading = true;
  final UserService _userService = UserService();
  final UserPreferencesService _userPreferencesService = UserPreferencesService();
  String _userCurrency = 'USD'; // Default currency

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _userService.getCurrentUser();
      String userCurrency = 'USD'; // Default
      
      if (user != null) {
        try {
          userCurrency = await _userPreferencesService.getUserDefaultCurrency();
        } catch (e) {
          print('Error loading user currency: $e');
        }
      }
      
      if (mounted) {
        setState(() {
          _currentUser = user;
          _userCurrency = userCurrency;
          _isLoading = false;
        });
        
        // Load transactions and budgets for this user
        if (user != null && mounted) {
          final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
          final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
          
          // Load data in parallel
          await Future.wait([
            transactionProvider.loadTransactions(user.uid),
            budgetProvider.loadBudgetsForMonth(user.uid, DateTime.now()),
          ]);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(CupertinoTheme.brightnessOf(context)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveConstants.spacing16,
            vertical: ResponsiveConstants.spacing12,
          ),
          child: Consumer<TransactionProvider>(
            builder: (context, transactionProvider, child) {
              // Calculate financial stats from transactions
              final totalIncome = transactionProvider.getTotalIncome(_userCurrency);
              final totalExpenses = transactionProvider.getTotalExpenses(_userCurrency);
              final balance = transactionProvider.getBalance(_userCurrency);
              final savings = totalIncome - totalExpenses; // This could be more sophisticated
              
              // Get recent transactions (limit to 3)
              final recentTransactions = transactionProvider.transactions.take(3).toList();
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting Section
                  GreetingSection(
                    currentUser: _currentUser,
                    isLoading: _isLoading,
                    userService: _userService,
                  ),
                  
                  SizedBox(height: ResponsiveConstants.spacing20),
                  
                  // Total Balance Card
                  BalanceCard(
                    balance: balance,
                    currency: _userCurrency,
                  ),
                  
                  SizedBox(height: ResponsiveConstants.spacing20),
                  
                  // Overview Stats (Income, Expenses, Savings)
                  OverviewStats(
                    income: totalIncome,
                    expenses: totalExpenses,
                    savings: savings,
                    currency: _userCurrency,
                  ),
                  
                  SizedBox(height: ResponsiveConstants.spacing24),
                  
                  // Navigation Buttons Section
                  _buildNavigationButtons(context),
                  
                  SizedBox(height: ResponsiveConstants.spacing24),
                  
                  // Recent Transactions Section
                  if (transactionProvider.isLoading)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: ResponsiveConstants.spacing24),
                        child: const CupertinoActivityIndicator(),
                      ),
                    )
                  else
                    RecentTransactions(
                      transactions: recentTransactions,
                      onSeeAllPressed: () {
                        context.push(AppRoutes.transactions);
                      },
                      onTransactionTap: (transaction) {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => TransactionDetailsScreen(transaction: transaction),
                          ),
                        );
                      },
                    ),
                  
                  SizedBox(height: ResponsiveConstants.spacing80), // Bottom padding for nav bar
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildNavigationButton(
            context: context,
            icon: CupertinoIcons.chart_pie,
            title: 'Budget',
            subtitle: 'Manage your budget',
            onTap: () {
              // Navigate to budget screen
              context.push(AppRoutes.budget);
            },
          ),
        ),
        SizedBox(width: ResponsiveConstants.spacing12),
        Expanded(
          child: _buildNavigationButton(
            context: context,
            icon: CupertinoIcons.list_bullet,
            title: 'Transactions',
            subtitle: 'View all transactions',
            onTap: () {
              // Navigate to transactions screen
              context.push(AppRoutes.transactions);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: EdgeInsets.all(ResponsiveConstants.spacing16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(ResponsiveConstants.radius12),
          border: Border.all(
            color: CupertinoColors.systemGrey5.resolveFrom(context),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey4.resolveFrom(context).withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32,
              color: const Color(0xFF2ECC71),
            ),
            SizedBox(height: ResponsiveConstants.spacing8),
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveConstants.fontSize16,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
              ),
            ),
            SizedBox(height: ResponsiveConstants.spacing4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: ResponsiveConstants.fontSize12,
                color: CupertinoColors.systemGrey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
