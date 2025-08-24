import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/currency_rate.dart';
import '../services/currency_service.dart';

// Events
abstract class CurrencyEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCurrencyRates extends CurrencyEvent {
  final String baseCurrency;
  
  LoadCurrencyRates(this.baseCurrency);
  
  @override
  List<Object?> get props => [baseCurrency];
}

class ConvertCurrency extends CurrencyEvent {
  final double amount;
  final String fromCurrency;
  final String toCurrency;
  
  ConvertCurrency(this.amount, this.fromCurrency, this.toCurrency);
  
  @override
  List<Object?> get props => [amount, fromCurrency, toCurrency];
}

// States
abstract class CurrencyState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CurrencyInitial extends CurrencyState {}

class CurrencyLoading extends CurrencyState {}

class CurrencyLoaded extends CurrencyState {
  final List<CurrencyRate> rates;
  
  CurrencyLoaded(this.rates);
  
  @override
  List<Object?> get props => [rates];
}

class CurrencyConverted extends CurrencyState {
  final double convertedAmount;
  
  CurrencyConverted(this.convertedAmount);
  
  @override
  List<Object?> get props => [convertedAmount];
}

class CurrencyError extends CurrencyState {
  final String message;
  
  CurrencyError(this.message);
  
  @override
  List<Object?> get props => [message];
}

// Bloc
class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  final CurrencyService _currencyService;
  
  CurrencyBloc(this._currencyService) : super(CurrencyInitial()) {
    on<LoadCurrencyRates>(_onLoadCurrencyRates);
    on<ConvertCurrency>(_onConvertCurrency);
  }
  
  Future<void> _onLoadCurrencyRates(LoadCurrencyRates event, Emitter<CurrencyState> emit) async {
    emit(CurrencyLoading());
    try {
      final rates = await _currencyService.getCurrencyRates(event.baseCurrency);
      emit(CurrencyLoaded(rates));
    } catch (e) {
      emit(CurrencyError(e.toString()));
    }
  }
  
  Future<void> _onConvertCurrency(ConvertCurrency event, Emitter<CurrencyState> emit) async {
    try {
      final convertedAmount = await _currencyService.convertCurrency(
        event.amount,
        event.fromCurrency,
        event.toCurrency,
      );
      emit(CurrencyConverted(convertedAmount));
    } catch (e) {
      emit(CurrencyError(e.toString()));
    }
  }
}
