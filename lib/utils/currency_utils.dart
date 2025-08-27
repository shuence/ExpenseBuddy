import 'package:intl/intl.dart';

class CurrencyUtils {
  static String formatCurrency(double amount, String currencyCode) {
    final formatter = NumberFormat.currency(
      symbol: getCurrencySymbol(currencyCode),
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
  
  static String getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'CAD':
        return 'C\$';
      case 'AUD':
        return 'A\$';
      case 'CHF':
        return 'CHF';
      case 'CNY':
        return '¥';
      case 'INR':
        return '₹';
      case 'KRW':
        return '₩';
      case 'MXN':
        return '\$';
      case 'BRL':
        return 'R\$';
      case 'RUB':
        return '₽';
      case 'SGD':
        return 'S\$';
      case 'HKD':
        return 'HK\$';
      case 'NZD':
        return 'NZ\$';
      case 'SEK':
        return 'kr';
      case 'NOK':
        return 'kr';
      case 'DKK':
        return 'kr';
      case 'PLN':
        return 'zł';
      case 'CZK':
        return 'Kč';
      case 'HUF':
        return 'Ft';
      case 'RON':
        return 'lei';
      case 'BGN':
        return 'лв';
      case 'HRK':
        return 'kn';
      case 'RSD':
        return 'дин';
      case 'TRY':
        return '₺';
      case 'ILS':
        return '₪';
      case 'AED':
        return 'د.إ';
      case 'SAR':
        return 'ر.س';
      case 'QAR':
        return 'ر.ق';
      case 'KWD':
        return 'د.ك';
      case 'BHD':
        return 'د.ب';
      case 'OMR':
        return 'ر.ع';
      case 'JOD':
        return 'د.ا';
      case 'LBP':
        return 'ل.ل';
      case 'EGP':
        return 'ج.م';
      case 'ZAR':
        return 'R';
      case 'NGN':
        return '₦';
      case 'KES':
        return 'KSh';
      case 'GHS':
        return 'GH₵';
      case 'UGX':
        return 'USh';
      case 'TZS':
        return 'TSh';
      case 'MAD':
        return 'د.م.';
      case 'TND':
        return 'د.ت';
      case 'DZD':
        return 'د.ج';
      case 'LYD':
        return 'ل.د';
      case 'SDG':
        return 'ج.س.';
      case 'ETB':
        return 'Br';
      case 'SOS':
        return 'S';
      case 'DJF':
        return 'Fdj';
      case 'KMF':
        return 'CF';
      case 'MUR':
        return '₨';
      case 'SCR':
        return '₨';
      case 'MVR':
        return 'MVR';
      case 'LKR':
        return 'Rs';
      case 'BDT':
        return '৳';
      case 'NPR':
        return '₨';
      case 'BTN':
        return 'Nu.';
      case 'MMK':
        return 'K';
      case 'LAK':
        return '₭';
      case 'KHR':
        return '៛';
      case 'VND':
        return '₫';
      case 'THB':
        return '฿';
      case 'MYR':
        return 'RM';
      case 'IDR':
        return 'Rp';
      case 'PHP':
        return '₱';
      case 'TWD':
        return 'NT\$';
      case 'MNT':
        return '₮';
      case 'KZT':
        return '₸';
      case 'UZS':
        return 'so\'m';
      case 'TJS':
        return 'ЅM';
      case 'KGS':
        return 'с';
      case 'TMT':
        return 'T';
      case 'AZN':
        return '₼';
      case 'GEL':
        return '₾';
      case 'AMD':
        return '֏';
      case 'BYN':
        return 'Br';
      case 'MDL':
        return 'L';
      case 'UAH':
        return '₴';
      case 'BAM':
        return 'KM';
      case 'ALL':
        return 'L';
      case 'MKD':
        return 'ден';
      case 'ME':
        return '€';
      case 'XK':
        return '€';
      default:
        return currencyCode;
    }
  }
  
  static String getCurrencyName(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return 'US Dollar';
      case 'EUR':
        return 'Euro';
      case 'GBP':
        return 'British Pound';
      case 'JPY':
        return 'Japanese Yen';
      case 'CAD':
        return 'Canadian Dollar';
      case 'AUD':
        return 'Australian Dollar';
      case 'CHF':
        return 'Swiss Franc';
      case 'CNY':
        return 'Chinese Yuan';
      case 'INR':
        return 'Indian Rupee';
      case 'KRW':
        return 'South Korean Won';
      case 'MXN':
        return 'Mexican Peso';
      case 'BRL':
        return 'Brazilian Real';
      case 'RUB':
        return 'Russian Ruble';
      case 'SGD':
        return 'Singapore Dollar';
      case 'HKD':
        return 'Hong Kong Dollar';
      case 'NZD':
        return 'New Zealand Dollar';
      case 'SEK':
        return 'Swedish Krona';
      case 'NOK':
        return 'Norwegian Krone';
      case 'DKK':
        return 'Danish Krone';
      case 'PLN':
        return 'Polish Złoty';
      case 'CZK':
        return 'Czech Koruna';
      case 'HUF':
        return 'Hungarian Forint';
      case 'RON':
        return 'Romanian Leu';
      case 'BGN':
        return 'Bulgarian Lev';
      case 'HRK':
        return 'Croatian Kuna';
      case 'RSD':
        return 'Serbian Dinar';
      case 'TRY':
        return 'Turkish Lira';
      case 'ILS':
        return 'Israeli Shekel';
      case 'AED':
        return 'UAE Dirham';
      case 'SAR':
        return 'Saudi Riyal';
      case 'QAR':
        return 'Qatari Riyal';
      case 'KWD':
        return 'Kuwaiti Dinar';
      case 'BHD':
        return 'Bahraini Dinar';
      case 'OMR':
        return 'Omani Rial';
      case 'JOD':
        return 'Jordanian Dinar';
      case 'LBP':
        return 'Lebanese Pound';
      case 'EGP':
        return 'Egyptian Pound';
      case 'ZAR':
        return 'South African Rand';
      case 'NGN':
        return 'Nigerian Naira';
      case 'KES':
        return 'Kenyan Shilling';
      case 'GHS':
        return 'Ghanaian Cedi';
      case 'UGX':
        return 'Ugandan Shilling';
      case 'TZS':
        return 'Tanzanian Shilling';
      case 'MAD':
        return 'Moroccan Dirham';
      case 'TND':
        return 'Tunisian Dinar';
      case 'DZD':
        return 'Algerian Dinar';
      case 'LYD':
        return 'Libyan Dinar';
      case 'SDG':
        return 'Sudanese Pound';
      case 'ETB':
        return 'Ethiopian Birr';
      case 'SOS':
        return 'Somali Shilling';
      case 'DJF':
        return 'Djiboutian Franc';
      case 'KMF':
        return 'Comorian Franc';
      case 'MUR':
        return 'Mauritian Rupee';
      case 'SCR':
        return 'Seychellois Rupee';
      case 'MVR':
        return 'Maldivian Rufiyaa';
      case 'LKR':
        return 'Sri Lankan Rupee';
      case 'BDT':
        return 'Bangladeshi Taka';
      case 'NPR':
        return 'Nepalese Rupee';
      case 'BTN':
        return 'Bhutanese Ngultrum';
      case 'MMK':
        return 'Myanmar Kyat';
      case 'LAK':
        return 'Lao Kip';
      case 'KHR':
        return 'Cambodian Riel';
      case 'VND':
        return 'Vietnamese Dong';
      case 'THB':
        return 'Thai Baht';
      case 'MYR':
        return 'Malaysian Ringgit';
      case 'IDR':
        return 'Indonesian Rupiah';
      case 'PHP':
        return 'Philippine Peso';
      case 'TWD':
        return 'New Taiwan Dollar';
      case 'MNT':
        return 'Mongolian Tögrög';
      case 'KZT':
        return 'Kazakhstani Tenge';
      case 'UZS':
        return 'Uzbekistani Som';
      case 'TJS':
        return 'Tajikistani Somoni';
      case 'KGS':
        return 'Kyrgyzstani Som';
      case 'TMT':
        return 'Turkmenistan Manat';
      case 'AZN':
        return 'Azerbaijani Manat';
      case 'GEL':
        return 'Georgian Lari';
      case 'AMD':
        return 'Armenian Dram';
      case 'BYN':
        return 'Belarusian Ruble';
      case 'MDL':
        return 'Moldovan Leu';
      case 'UAH':
        return 'Ukrainian Hryvnia';
      case 'BAM':
        return 'Bosnia-Herzegovina Convertible Mark';
      case 'ALL':
        return 'Albanian Lek';
      case 'MKD':
        return 'Macedonian Denar';
      case 'ME':
        return 'Montenegrin Euro';
      case 'XK':
        return 'Kosovo Euro';
      default:
        return currencyCode;
    }
  }
  
  static List<String> getSupportedCurrencies() {
    return [
      'USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD', 'CHF', 'CNY', 'INR',
      'KRW', 'MXN', 'BRL', 'RUB', 'SGD', 'HKD', 'NZD', 'SEK', 'NOK',
      'DKK', 'PLN', 'CZK', 'HUF', 'RON', 'BGN', 'HRK', 'RSD', 'TRY',
      'ILS', 'AED', 'SAR', 'QAR', 'KWD', 'BHD', 'OMR', 'JOD', 'LBP',
      'EGP', 'ZAR', 'NGN', 'KES', 'GHS', 'UGX', 'TZS', 'MAD', 'TND',
      'DZD', 'LYD', 'SDG', 'ETB', 'SOS', 'DJF', 'KMF', 'MUR', 'SCR',
      'MVR', 'LKR', 'BDT', 'NPR', 'BTN', 'MMK', 'LAK', 'KHR', 'VND',
      'THB', 'MYR', 'IDR', 'PHP', 'TWD', 'MNT', 'KZT', 'UZS', 'TJS',
      'KGS', 'TMT', 'AZN', 'GEL', 'AMD', 'BYN', 'MDL', 'UAH', 'BAM',
      'ALL', 'MKD', 'ME', 'XK',
    ];
  }
  
  static bool isValidCurrencyCode(String currencyCode) {
    return getSupportedCurrencies().contains(currencyCode.toUpperCase());
  }
}
