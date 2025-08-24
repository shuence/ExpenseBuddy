import '../../models/expense.dart';
import '../local/expense_dao.dart';
import '../remote/firestore_service.dart';

class ExpenseRepository {
  final ExpenseDao _expenseDao;
  final FirestoreService _firestoreService;

  // In-memory storage for simulation
  final List<Expense> _mockExpenses = [];
  final bool _useMockData = true; // Set to true for simulation

  ExpenseRepository(this._expenseDao, this._firestoreService) {
    _initializeMockData();
  }

  void _initializeMockData() {
    final now = DateTime.now();
    final userId = 'demo_user';

    _mockExpenses.addAll([
      Expense(
        id: '1',
        title: 'Coffee at Starbucks',
        amount: 5.50,
        category: 'Food & Drinks',
        date: now.subtract(const Duration(days: 1)),
        description: 'Morning coffee',
        userId: userId,
        currency: 'USD',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Expense(
        id: '2',
        title: 'Uber Ride',
        amount: 12.30,
        category: 'Transportation',
        date: now.subtract(const Duration(days: 2)),
        description: 'Ride to airport',
        userId: userId,
        currency: 'USD',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      Expense(
        id: '3',
        title: 'Grocery Shopping',
        amount: 45.20,
        category: 'Food & Drinks',
        date: now.subtract(const Duration(days: 3)),
        description: 'Weekly groceries',
        userId: userId,
        currency: 'USD',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      Expense(
        id: '4',
        title: 'Movie Tickets',
        amount: 25.00,
        category: 'Entertainment',
        date: now.subtract(const Duration(days: 4)),
        description: 'Cinema tickets',
        userId: userId,
        currency: 'USD',
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 4)),
      ),
      Expense(
        id: '5',
        title: 'Gas Station',
        amount: 35.80,
        category: 'Transportation',
        date: now.subtract(const Duration(days: 5)),
        description: 'Fuel refill',
        userId: userId,
        currency: 'USD',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      Expense(
        id: '6',
        title: 'Office Lunch',
        amount: 18.75,
        category: 'Food & Drinks',
        date: now.subtract(const Duration(days: 6)),
        description: 'Lunch with colleagues',
        userId: userId,
        currency: 'USD',
        createdAt: now.subtract(const Duration(days: 6)),
        updatedAt: now.subtract(const Duration(days: 6)),
      ),
      Expense(
        id: '7',
        title: 'Netflix Subscription',
        amount: 15.99,
        category: 'Entertainment',
        date: now.subtract(const Duration(days: 7)),
        description: 'Monthly streaming',
        userId: userId,
        currency: 'USD',
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 7)),
      ),
    ]);
  }

  // Get all expenses for a user
  Future<List<Expense>> getExpenses(String userId) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      return _mockExpenses.where((expense) => expense.userId == userId).toList();
    }
    return await _expenseDao.getAllExpenses(userId);
  }

  // Add expense
  Future<void> addExpense(Expense expense) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      _mockExpenses.add(expense);
      return;
    }
    await _expenseDao.insert(expense);
    await _firestoreService.addExpense(expense);
  }

  // Update expense
  Future<void> updateExpense(Expense expense) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final index = _mockExpenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _mockExpenses[index] = expense;
      }
      return;
    }
    await _expenseDao.update(expense);
    await _firestoreService.updateExpense(expense);
  }

  // Delete expense
  Future<void> deleteExpense(String expenseId) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      _mockExpenses.removeWhere((expense) => expense.id == expenseId);
      return;
    }
    await _expenseDao.delete(expenseId);
    await _firestoreService.deleteExpense(expenseId);
  }

  // Get expense by ID
  Future<Expense?> getExpenseById(String id) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return _mockExpenses.cast<Expense?>().firstWhere((expense) => expense?.id == id, orElse: () => null);
    }
    return await _expenseDao.getExpenseById(id);
  }
}
