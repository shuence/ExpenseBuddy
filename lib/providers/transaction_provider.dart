import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../data/remote/transactions_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionsService _transactionsService = TransactionsService();
  
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Load all transactions for a user
  Future<void> loadTransactions(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _transactions = await _transactionsService.getAllTransactions(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Add new transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _transactionsService.addTransaction(transaction);
      _transactions.add(transaction);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Update existing transaction
  Future<void> updateTransaction(TransactionModel transaction) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _transactionsService.updateTransaction(transaction);
      
      // Update in local list
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index >= 0) {
        _transactions[index] = transaction;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Delete transaction
  Future<void> deleteTransaction(String transactionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _transactionsService.deleteTransaction(transactionId);
      
      // Remove from local list
      _transactions.removeWhere((t) => t.id == transactionId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Get expenses only
  List<TransactionModel> get expenses => 
      _transactions.where((t) => t.type == TransactionType.expense).toList();
  
  // Get income only
  List<TransactionModel> get income => 
      _transactions.where((t) => t.type == TransactionType.income).toList();
      
  // Get total income
  double getTotalIncome(String currency) {
    return income
        .where((t) => t.currency == currency)
        .fold(0, (sum, t) => sum + t.amount);
  }
  
  // Get total expenses
  double getTotalExpenses(String currency) {
    return expenses
        .where((t) => t.currency == currency)
        .fold(0, (sum, t) => sum + t.amount);
  }
  
  // Get balance
  double getBalance(String currency) {
    return getTotalIncome(currency) - getTotalExpenses(currency);
  }
  
  // Get transactions by category
  List<TransactionModel> getTransactionsByCategory(String category) {
    return _transactions.where((t) => t.category == category).toList();
  }
  
  // Get transactions by date range
  List<TransactionModel> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactions
        .where((t) => t.date.isAfter(start) && t.date.isBefore(end))
        .toList();
  }
}
