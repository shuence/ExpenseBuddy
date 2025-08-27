import 'package:flutter/cupertino.dart';
import '../../core/theme/app_theme.dart';

class ExpenseCard extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  
  const ExpenseCard({
    super.key,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(CupertinoTheme.brightnessOf(context)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)).withOpacity(0.2),
        ),
      ),
      child: Stack(
        children: [
          // Main card content
          GestureDetector(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'Expense',
                        style: TextStyle(
                          color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expense',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                          ),
                        ),
                        Text(
                          'Expense',
                          style: TextStyle(
                            color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '100',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                        ),
                      ),
                      Text(
                          '100',
                        style: TextStyle(
                          color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Delete button (top right corner)
          if (onDelete != null)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.trash,
                    size: 16,
                    color: AppTheme.errorColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
