import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/expense.dart';
import '../data/remote/firestore_service.dart';

// Events
abstract class ExpenseEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadExpenses extends ExpenseEvent {
  final String userId;
  
  LoadExpenses(this.userId);
  
  @override
  List<Object?> get props => [userId];
}

class AddExpense extends ExpenseEvent {
  final Expense expense;
  
  AddExpense(this.expense);
  
  @override
  List<Object?> get props => [expense];
}

class UpdateExpense extends ExpenseEvent {
  final Expense expense;
  
  UpdateExpense(this.expense);
  
  @override
  List<Object?> get props => [expense];
}

class DeleteExpense extends ExpenseEvent {
  final String expenseId;
  
  DeleteExpense(this.expenseId);
  
  @override
  List<Object?> get props => [expenseId];
}

// States
abstract class ExpenseState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<Expense> expenses;
  
  ExpenseLoaded(this.expenses);
  
  @override
  List<Object?> get props => [expenses];
}

class ExpenseError extends ExpenseState {
  final String message;
  
  ExpenseError(this.message);
  
  @override
  List<Object?> get props => [message];
}

// Bloc
class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final FirestoreService _firestoreService = FirestoreService();

  ExpenseBloc() : super(ExpenseInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<AddExpense>(_onAddExpense);
    on<UpdateExpense>(_onUpdateExpense);
    on<DeleteExpense>(_onDeleteExpense);
  }
  
  Future<void> _onLoadExpenses(LoadExpenses event, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoading());
    try {
      final expenses = await _firestoreService.getUserExpenses(event.userId).first;
      emit(ExpenseLoaded(expenses));
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }
  
  Future<void> _onAddExpense(AddExpense event, Emitter<ExpenseState> emit) async {
    try {
      await _firestoreService.addExpense(event.expense);
      add(LoadExpenses(event.expense.userId));
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }
  
  Future<void> _onUpdateExpense(UpdateExpense event, Emitter<ExpenseState> emit) async {
    try {
      await _firestoreService.updateExpense(event.expense);
      add(LoadExpenses(event.expense.userId));
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }
  
  Future<void> _onDeleteExpense(DeleteExpense event, Emitter<ExpenseState> emit) async {
    try {
      await _firestoreService.deleteExpense(event.expenseId);
      // Reload expenses
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }
}
