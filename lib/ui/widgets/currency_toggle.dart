import 'package:flutter/cupertino.dart';
import '../../core/theme/app_theme.dart';

class CurrencyToggle extends StatelessWidget {
  final String selectedCurrency;
  final List<String> currencies;
  final Function(String) onCurrencyChanged;
  
  const CurrencyToggle({
    super.key,
    required this.selectedCurrency,
    required this.currencies,
    required this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text(
            'Currency: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _showCurrencyPicker(context),
            child: Text(
              selectedCurrency,
              style: TextStyle(
                color: AppTheme.getAccentColor(CupertinoTheme.brightnessOf(context)),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 200,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CupertinoButton(
                  child: const Text('Done'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 32,
                onSelectedItemChanged: (int index) {
                  onCurrencyChanged(currencies[index]);
                },
                children: currencies.map((String currency) {
                  return Center(child: Text(currency));
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
