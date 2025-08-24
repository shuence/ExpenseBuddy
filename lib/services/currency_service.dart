import 'package:dio/dio.dart';
import '../models/currency_rate.dart';

class CurrencyService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://api.exchangerate-api.com/v4/latest';
  
  Future<List<CurrencyRate>> getCurrencyRates(String baseCurrency) async {
    try {
      final response = await _dio.get('$_baseUrl/$baseCurrency');
      
      if (response.statusCode == 200) {
        final data = response.data;
        final rates = data['rates'] as Map<String, dynamic>;
        final timestamp = DateTime.parse(data['date']);
        
        return rates.entries.map((entry) => CurrencyRate(
          baseCurrency: baseCurrency,
          targetCurrency: entry.key,
          rate: entry.value.toDouble(),
          lastUpdated: timestamp,
        )).toList();
      } else {
        throw Exception('Failed to load currency rates');
      }
    } catch (e) {
      throw Exception('Error fetching currency rates: $e');
    }
  }
  
  Future<double> convertCurrency(double amount, String fromCurrency, String toCurrency) async {
    try {
      final rates = await getCurrencyRates(fromCurrency);
      final targetRate = rates.firstWhere((rate) => rate.targetCurrency == toCurrency);
      return amount * targetRate.rate;
    } catch (e) {
      throw Exception('Error converting currency: $e');
    }
  }
}
