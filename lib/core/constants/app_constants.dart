class AppConstants {
  static const String appName = 'ExpenseBuddy';
  static const String appVersion = '1.0.0';
  
  // API Constants
  static const String baseUrl = 'https://api.expensebuddy.com';
  static const int apiTimeout = 30000; // milliseconds
  
  // Database Constants
  static const String databaseName = 'expensebuddy.db';
  static const int databaseVersion = 1;
  
  // Shared Preferences Keys
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';
  static const String currencyKey = 'selected_currency';
  static const String themeKey = 'app_theme';
  
  // Validation Constants
  static const int minPasswordLength = 6;
  static const int maxExpenseAmount = 999999;
  
  // Notification Constants
  static const String reminderChannelId = 'expense_reminders';
  static const String reminderChannelName = 'Expense Reminders';
  static const String reminderChannelDescription = 'Reminders for expense tracking';
  
  // Expense Categories
  static const List<String> expenseCategories = [
    'Food & Dining',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Healthcare',
    'Education',
    'Housing',
    'Utilities',
    'Insurance',
    'Travel',
    'Gifts',
    'Other',
  ];
  
  // Income Categories
  static const List<String> incomeCategories = [
    'Salary',
    'Freelance',
    'Investment',
    'Business',
    'Gifts',
    'Other',
  ];
  
  // Currencies
  static const List<String> currencies = [
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'CAD',
    'AUD',
    'CHF',
    'CNY',
    'INR',
  ];
}
