import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/expense.dart';
import '../../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collections
  CollectionReference get expensesCollection => _firestore.collection('expenses');
  CollectionReference get usersCollection => _firestore.collection('users');
  
  // Add expense
  Future<void> addExpense(Expense expense) async {
    await expensesCollection.doc(expense.id).set(expense.toJson());
  }
  
  // Get user expenses
  Stream<List<Expense>> getUserExpenses(String userId) {
    return expensesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Expense.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }
  
  // Update expense
  Future<void> updateExpense(Expense expense) async {
    await expensesCollection.doc(expense.id).update(expense.toJson());
  }
  
  // Delete expense
  Future<void> deleteExpense(String expenseId) async {
    await expensesCollection.doc(expenseId).delete();
  }
  
  // Add user
  Future<void> addUser(UserModel user) async {
    await usersCollection.doc(user.uid).set(user.toJson());
  }
  
  // Get user
  Future<UserModel?> getUser(String userId) async {
    final doc = await usersCollection.doc(userId).get();
    if (doc.exists) {
      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }
}
