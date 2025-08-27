import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/responsive_constants.dart';
import '../../../models/budget_model.dart';
import '../../../services/budget_service.dart';
import '../../../services/user_service.dart';

class AdjustBudgetScreen extends StatefulWidget {
  const AdjustBudgetScreen({super.key});

  @override
  State<AdjustBudgetScreen> createState() => _AdjustBudgetScreenState();
}

class _AdjustBudgetScreenState extends State<AdjustBudgetScreen> {
  final BudgetService _budgetService = BudgetService();
  List<BudgetModel> _budgets = [];
  Map<String, TextEditingController> _controllers = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadBudgets() async {
    try {
      final userService = UserService();
      final currentUser = await userService.getCurrentUser();
      final userId = currentUser?.uid;
      
      if (userId == null) {
        _showErrorDialog('User not found. Please log in again.');
        return;
      }

      final budgets = await _budgetService.getAllBudgets(userId);
      if (mounted) {
        setState(() {
          _budgets = budgets;
          _controllers = {
            for (final budget in budgets)
              budget.id: TextEditingController(
                text: budget.allocatedAmount.toStringAsFixed(0)
              )
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isSaving = true;
    });

    try {
      for (final budget in _budgets) {
        final controller = _controllers[budget.id];
        if (controller != null) {
          final newAmount = double.tryParse(controller.text);
          if (newAmount != null && newAmount != budget.allocatedAmount) {
            final updatedBudget = BudgetModel(
              id: budget.id,
              name: budget.name,
              icon: budget.icon,
              allocatedAmount: newAmount,
              spentAmount: budget.spentAmount,
              periodType: budget.periodType,
              startDate: budget.startDate,
              endDate: budget.endDate,
              color: budget.color,
            );
            await _budgetService.updateBudget(updatedBudget);
          }
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Failed to update budgets. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BudgetModel budget) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Delete ${budget.name}?'),
        content: const Text('This action cannot be undone. All data for this budget will be lost.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context);
              await _deleteBudget(budget);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBudget(BudgetModel budget) async {
    try {
      await _budgetService.deleteBudget(budget.id);
      setState(() {
        _budgets.removeWhere((b) => b.id == budget.id);
        _controllers[budget.id]?.dispose();
        _controllers.remove(budget.id);
      });
    } catch (e) {
      _showErrorDialog('Failed to delete budget. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Adjust Budget Limits',
          style: TextStyle(
            color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.getBackgroundColor(CupertinoTheme.brightnessOf(context)),
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: Icon(
            CupertinoIcons.back,
            color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
          ),
        ),
        trailing: _isSaving
            ? const CupertinoActivityIndicator(radius: 10)
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _budgets.isNotEmpty ? _saveChanges : null,
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: _budgets.isNotEmpty 
                        ? AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context))
                        : CupertinoColors.systemGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
      ),
      child: Container(
        color: AppTheme.getBackgroundColor(CupertinoTheme.brightnessOf(context)),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CupertinoActivityIndicator(radius: 16))
              : _budgets.isEmpty
                  ? _buildEmptyState()
                  : CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(ResponsiveConstants.spacing16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Adjust your budget limits below. Changes will take effect immediately.',
                                  style: TextStyle(
                                    fontSize: ResponsiveConstants.fontSize14,
                                    color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)),
                                  ),
                                ),
                                SizedBox(height: ResponsiveConstants.spacing20),
                              ],
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final budget = _budgets[index];
                              return _buildBudgetItem(budget);
                            },
                            childCount: _budgets.length,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(height: ResponsiveConstants.spacing80),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveConstants.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.chart_pie,
              size: ResponsiveConstants.iconSize64,
              color: CupertinoColors.systemGrey,
            ),
            SizedBox(height: ResponsiveConstants.spacing16),
            Text(
              'No Budgets Found',
              style: TextStyle(
                fontSize: ResponsiveConstants.fontSize20,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
              ),
            ),
            SizedBox(height: ResponsiveConstants.spacing8),
            Text(
              'Create your first budget to start tracking your expenses.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveConstants.fontSize14,
                color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetItem(BudgetModel budget) {
    final controller = _controllers[budget.id]!;
    
    return Container(
      margin: EdgeInsets.only(
        left: ResponsiveConstants.spacing16,
        right: ResponsiveConstants.spacing16,
        bottom: ResponsiveConstants.spacing12,
      ),
      padding: EdgeInsets.all(ResponsiveConstants.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(CupertinoTheme.brightnessOf(context)),
        borderRadius: BorderRadius.circular(ResponsiveConstants.radius12),
        border: Border.all(
          color: CupertinoColors.systemGrey4.resolveFrom(context),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getCategoryColor(budget.name).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ResponsiveConstants.radius8),
                ),
                child: Center(
                  child: Text(
                    budget.icon,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveConstants.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budget.name,
                      style: TextStyle(
                        fontSize: ResponsiveConstants.fontSize16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                      ),
                    ),
                    SizedBox(height: ResponsiveConstants.spacing2),
                    Text(
                      'Currently: \$${budget.spentAmount.toStringAsFixed(0)} / \$${budget.allocatedAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: ResponsiveConstants.fontSize12,
                        color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)),
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _showDeleteConfirmation(budget),
                child: Icon(
                  CupertinoIcons.delete,
                  color: CupertinoColors.systemRed,
                  size: ResponsiveConstants.iconSize20,
                ),
              ),
            ],
          ),
          
          SizedBox(height: ResponsiveConstants.spacing16),
          
          Text(
            'New Budget Limit',
            style: TextStyle(
              fontSize: ResponsiveConstants.fontSize14,
              fontWeight: FontWeight.w500,
              color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
            ),
          ),
          
          SizedBox(height: ResponsiveConstants.spacing8),
          
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveConstants.spacing12,
              vertical: ResponsiveConstants.spacing8,
            ),
            decoration: BoxDecoration(
              color: AppTheme.getBackgroundColor(CupertinoTheme.brightnessOf(context)),
              borderRadius: BorderRadius.circular(ResponsiveConstants.radius8),
              border: Border.all(
                color: CupertinoColors.systemGrey4.resolveFrom(context),
                width: 0.5,
              ),
            ),
            child: CupertinoTextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              prefix: Text(
                '\$ ',
                style: TextStyle(
                  fontSize: ResponsiveConstants.fontSize16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                ),
              ),
              decoration: null,
              style: TextStyle(
                fontSize: ResponsiveConstants.fontSize16,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
              ),
            ),
          ),
          
          SizedBox(height: ResponsiveConstants.spacing8),
          
          // Progress bar
          Container(
            width: double.infinity,
            height: 4,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey5,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (budget.spentPercentage / 100).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: _getCategoryColor(budget.name),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String categoryName) {
    switch (categoryName) {
      case 'Food & Dining':
        return const Color(0xFF2ECC71);
      case 'Transportation':
        return const Color(0xFF3498DB);
      case 'Bills & Utilities':
        return const Color(0xFFE74C3C);
      case 'Entertainment':
        return const Color(0xFF9B59B6);
      default:
        return const Color(0xFF2ECC71);
    }
  }
}
