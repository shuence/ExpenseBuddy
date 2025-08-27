import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/transaction_model.dart';

class TransactionsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collections
  CollectionReference get transactionsCollection => _firestore.collection('transactions');
  CollectionReference get usersCollection => _firestore.collection('users');
  
  // Add transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    await transactionsCollection.doc(transaction.id).set(transaction.toJson());
  }
  
  // Get user transactions
  Stream<List<TransactionModel>> getUserTransactions(String userId) {
    return transactionsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }
  
  // Get transactions by type
  Stream<List<TransactionModel>> getTransactionsByType(String userId, TransactionType type) {
    return transactionsCollection
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: type.toString().split('.').last)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }
  
  // Update transaction
  Future<void> updateTransaction(TransactionModel transaction) async {
    await transactionsCollection.doc(transaction.id).update(transaction.toJson());
  }
  
  // Delete transaction
  Future<void> deleteTransaction(String transactionId) async {
    await transactionsCollection.doc(transactionId).delete();
  }
  
  // Get all transactions (one-time fetch)
  Future<List<TransactionModel>> getAllTransactions(String userId) async {
    final snapshot = await transactionsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .get();
        
    return snapshot.docs
        .map((doc) => TransactionModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
