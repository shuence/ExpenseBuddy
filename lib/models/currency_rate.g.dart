// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_rate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrencyRate _$CurrencyRateFromJson(Map<String, dynamic> json) => CurrencyRate(
  baseCurrency: json['baseCurrency'] as String,
  targetCurrency: json['targetCurrency'] as String,
  rate: (json['rate'] as num).toDouble(),
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
);

Map<String, dynamic> _$CurrencyRateToJson(CurrencyRate instance) =>
    <String, dynamic>{
      'baseCurrency': instance.baseCurrency,
      'targetCurrency': instance.targetCurrency,
      'rate': instance.rate,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };
