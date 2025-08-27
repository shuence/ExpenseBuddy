import 'package:flutter/cupertino.dart';
import '../../core/constants/responsive_constants.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final String currency;
  final String subtitle;

  const BalanceCard({
    super.key,
    required this.balance,
    this.currency = 'USD',
    this.subtitle = 'Updated just now',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveConstants.spacing20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF2ECC71), // Green color matching the image
            Color(0xFF27AE60),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ResponsiveConstants.radius20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Balance',
            style: TextStyle(
              fontSize: ResponsiveConstants.fontSize12,
              color: CupertinoColors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: ResponsiveConstants.spacing8),
          Text(
            '${currency == 'USD' ? '\$' : currency} ${balance.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
          SizedBox(height: ResponsiveConstants.spacing6),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: CupertinoColors.white.withOpacity(0.8),
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
