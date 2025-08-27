import 'package:flutter/cupertino.dart';
import '../../utils/currency_utils.dart';

class CurrencyIcon extends StatelessWidget {
  final String currencyCode;
  final double size;

  const CurrencyIcon({
    super.key,
    required this.currencyCode,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      CurrencyUtils.getCurrencySymbol(currencyCode),
      style: TextStyle(fontSize: size),
    );
  }
}
