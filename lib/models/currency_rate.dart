import 'package:json_annotation/json_annotation.dart';

part 'currency_rate.g.dart';

@JsonSerializable()
class CurrencyRate {
  final String baseCurrency;
  final String targetCurrency;
  final double rate;
  final DateTime lastUpdated;

  const CurrencyRate({
    required this.baseCurrency,
    required this.targetCurrency,
    required this.rate,
    required this.lastUpdated,
  });

  factory CurrencyRate.fromJson(Map<String, dynamic> json) => _$CurrencyRateFromJson(json);
  Map<String, dynamic> toJson() => _$CurrencyRateToJson(this);

  CurrencyRate copyWith({
    String? baseCurrency,
    String? targetCurrency,
    double? rate,
    DateTime? lastUpdated,
  }) {
    return CurrencyRate(
      baseCurrency: baseCurrency ?? this.baseCurrency,
      targetCurrency: targetCurrency ?? this.targetCurrency,
      rate: rate ?? this.rate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
